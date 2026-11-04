--!nonstrict
local Text = require(script.Parent.Strings).Text
-- Regras puras: sem serviços, instâncias, relógio ou recursos informados pelo cliente.
local C = require(script.Parent.Creatures)
local Elements = require(script.Parent.Elements)
local Skills = require(script.Parent.Skills)
local CaptureMath = require(script.Parent.CaptureMath)
local R = {
	MaxTurns = 40,
	MaxParty = 3,
	LevelGrowth = 0.005,
	TameHealth = 1.08,
	TamePower = 1.085,
	DamageVariance = 0.5,
	PressureStart = 7,
	PressureBase = 1.6,
}
function R.stats(id, lv)
	local def = assert(C.ById[id], Text.ESPECIE_DE_COMBATE_DESCONHECIDA_6A7E80)
	local scale = 1 + R.LevelGrowth * (lv - 1)
	return {
		id = id,
		lv = lv,
		maxHp = math.floor(def.hp * scale),
		atk = def.atk * scale,
		def = 4 + def.rar * 3 + lv * 0.35,
		speed = ({ Blob = 9, Beast = 15, Bird = 20, Dragon = 13, Serpent = 16, Insect = 18 })[def.shape] + lv,
		el = def.el,
	}
end
function R.damage(a, b, power, guard)
	local gap = math.clamp(a.lv - b.lv, -30, 30)
	local pressure = 1.008 ^ gap
		* R.PressureBase ^ (math.max(0, math.abs(gap) - R.PressureStart) * (gap >= 0 and 1 or -1))
	if a.isLegendary or b.isLegendary then
		pressure = 1.008 ^ gap
	end
	return math.max(
		1,
		a.atk * power * Elements.mult(a.el, b.el) * 100 / (100 + b.def) * pressure * (guard and 0.45 or 1)
	)
end
function R.chance(s)
	return CaptureMath.chance(s)
end
function R.new(id, lv, settings)
	settings = settings or {}
	local foe = R.stats(id, lv)
	foe.isLegendary = settings.isLegendary == true
	for _, key in { "maxHp", "atk", "def", "speed" } do
		foe[key] = foe[key] * (settings.statMultiplier or 1)
		if key == "maxHp" then
			foe[key] = math.floor(foe[key])
		end
	end
	foe.hp = foe.maxHp
	return {
		explorerLevel = settings.explorerLevel,
		foe = foe,
		party = {},
		active = nil,
		bond = 0,
		turn = 0,
		version = 0,
		status = "active",
		log = {},
		attempts = 0,
	}
end
local function note(s, text, kind)
	table.insert(s.log, { text = text, kind = kind or "info" })
end
local function reply(s, guard, rng)
	local pet = s.active and s.party[s.active]
	if not pet or pet.hp <= 0 then
		return
	end
	local amount = math.floor(
		R.damage(
			s.foe,
			pet,
			(s.turn % 3 == 0 and 1.35 or 1) * (1 - R.DamageVariance + rng:NextNumber() * R.DamageVariance * 2),
			guard
		) + rng:NextNumber()
	)
	if pet.evade then
		amount = math.max(1, math.floor(amount * 0.65))
		pet.evade = false
	end
	pet.hp = math.max(0, pet.hp - amount)
	note(s, Text.A_FERA_CAUSOU_B1492B .. amount .. Text.DE_DANO_04F138, "foe")
	s.log[#s.log].amount = amount
	s.log[#s.log].health = pet.hp / pet.maxHp
	s.log[#s.log].mult = Elements.mult(s.foe.el, pet.el)
	if pet.hp == 0 then
		note(s, Text.SEU_COMPANHEIRO_ESTA_EXAUSTO_TROQUE_DE_FERA_OU_F_43D62C, "faint")
	end
end
-- Retorna false sem modificar estado para decisões inválidas.
function R.step(s, action, pet, rng, seals, room)
	if s.status ~= "active" then
		return false, Text.ESTE_ENCONTRO_TERMINOU_EC2596
	end
	if s.turn >= R.MaxTurns then
		s.status = "escaped"
		return true
	end
	local current = s.active and s.party[s.active]
	if action == "Select" then
		if not pet or not C.ById[pet.id] or not pet.uid then
			return false, Text.ESCOLHA_UMA_FERA_SUA_699F8C
		end
		if pet.uid == s.active then
			return false, Text.ESSA_FERA_JA_ESTA_EM_CAMPO_198AD6
		end
		local n = 0
		for _ in s.party do
			n += 1
		end
		if not s.party[pet.uid] and n >= R.MaxParty then
			return false, Text.EQUIPE_LIMITADA_A_TRES_FERAS_POR_ENCONTRO_31F83A
		end
		if s.party[pet.uid] and s.party[pet.uid].hp <= 0 then
			return false, Text.ESSA_FERA_ESTA_EXAUSTA_89922B
		end
	elseif action == "Strike" or action == "Skill" or action == "Guard" then
		if not current or current.hp <= 0 then
			return false, Text.SELECIONE_UMA_FERA_DISPONIVEL_94CE80
		end
		if action == "Skill" and s.turn < (current.nextSkill or 0) then
			return false, Text.HABILIDADE_RECARREGANDO_5B6E68
		end
	elseif action == "Capture" then
		if s.capturable == false then
			return false, Text.GUARDIOES_NAO_PODEM_SER_CAPTURADOS_CA285E
		end
		if seals < 1 then
			return false, Text.SEM_SELOS_CRIE_MAIS_NO_MERCADO_D1B215
		end
		if not room then
			return false, Text.INVENTARIO_CHEIO_NENHUM_SELO_FOI_GASTO_7FC7F9
		end
	elseif action == "Bond" and s.capturable == false then
		return false, Text.ESTE_DESAFIO_EXIGE_UMA_BATALHA_14581F
	elseif action ~= "Bond" and action ~= "Flee" then
		return false, Text.ACAO_DESCONHECIDA_9BB0DF
	end
	s.log = {}
	s.turn += 1
	s.version += 1
	s.spentSeal = false
	if action == "Flee" then
		s.status = "escaped"
		note(s, Text.VOCE_VOLTOU_A_EXPLORACAO_29EB17)
		return true
	end
	if action == "Select" then
		local switching = s.active ~= nil and s.party[s.active].hp > 0
		if not s.party[pet.uid] then
			local unit = R.stats(pet.id, pet.lv)
			unit.maxHp = math.floor(unit.maxHp * R.TameHealth)
			unit.atk = unit.atk * R.TamePower
			unit.hp = unit.maxHp
			unit.nextSkill = 0
			s.party[pet.uid] = unit
		end
		s.active = pet.uid
		note(s, C.ById[pet.id].name .. Text.ENTROU_EM_CAMPO_AC551A)
		if switching then
			reply(s, false, rng)
		end
	elseif action == "Capture" then
		s.spentSeal = true
		s.attempts += 1
		if rng:NextNumber() < R.chance(s) then
			s.status = "captured"
			note(s, Text.VINCULO_ESTABELECIDO_21A0FC, "capture")
		else
			note(s, Text.O_SELO_SE_DESFEZ_A_FERA_RESISTIU_ECB4B5, "miss")
			if current and current.hp > 0 then
				reply(s, false, rng)
			elseif not s.isLegendary and (rng:NextNumber() < 0.3 or s.attempts >= 6) then
				s.status = "escaped"
				note(s, Text.A_FERA_FUGIU_5FDD82)
			end
		end
	elseif action == "Bond" then
		s.bond = math.min(3, s.bond + 1)
		note(s, Text.VOCE_SE_APROXIMOU_COM_CUIDADO_VINCULO_555F67 .. s.bond .. "/3.", "bond")
		if current and current.hp > 0 then
			reply(s, false, rng)
		elseif not s.isLegendary and rng:NextNumber() < 0.15 then
			s.status = "escaped"
			note(s, Text.A_FERA_SE_ASSUSTOU_E_FUGIU_FF44C5)
		end
	elseif action == "Guard" then
		current.hp = math.min(current.maxHp, current.hp + math.floor(current.maxHp * 0.08))
		note(s, Text.SUA_FERA_RECUPEROU_O_FOLEGO_E_SE_PROTEGEU_08D205, "guard")
		reply(s, true, rng)
	else
		local skill = Skills[C.ById[current.id].shape]
		local power = action == "Skill" and skill.power or 1
		local enemyFirst = s.foe.speed > current.speed
		if enemyFirst then
			reply(s, false, rng)
		end
		if current.hp > 0 then
			if action == "Skill" then
				current.nextSkill = s.turn + 3
				if skill.effect == "heal" then
					current.hp = math.min(current.maxHp, current.hp + math.floor(current.maxHp * 0.12))
				elseif skill.effect == "evade" then
					current.evade = true
				elseif skill.effect == "weaken" then
					s.foe.atk = math.max(1, math.floor(s.foe.atk * 0.85))
				elseif skill.effect == "slow" then
					s.foe.speed = math.max(1, math.floor(s.foe.speed * 0.8))
				end
				note(s, skill.name .. "!", "skill")
			end
			local amount = math.floor(
				R.damage(
					current,
					s.foe,
					power * (1 - R.DamageVariance + rng:NextNumber() * R.DamageVariance * 2),
					false
				) + rng:NextNumber()
			)
			s.foe.hp = math.max(0, s.foe.hp - amount)
			note(
				s,
				Text.SUA_FERA_CAUSOU_9F1A6C
					.. amount
					.. Text.DE_DANO_949A5C
					.. (Elements.mult(current.el, s.foe.el) > 1 and Text.VANTAGEM_ELEMENTAL_C12EBC or "."),
				"hit"
			)
			s.log[#s.log].amount = amount
			s.log[#s.log].health = s.foe.hp / s.foe.maxHp
			s.log[#s.log].mult = Elements.mult(current.el, s.foe.el)
			if s.foe.hp == 0 then
				s.status = "won"
				note(s, Text.VITORIA_FERAS_EXAUSTAS_NAO_PODEM_SER_CAPTURADAS_08B05D, "win")
			elseif not enemyFirst then
				reply(s, false, rng)
			end
		end
	end
	if s.status == "active" and s.active and s.party[s.active].hp <= 0 then
		local count, alive = 0, false
		for _, unit in s.party do
			count += 1
			if unit.hp > 0 then
				alive = true
			end
		end
		if count >= R.MaxParty and not alive then
			s.status = "lost"
			note(s, Text.SUA_EQUIPE_ESTA_EXAUSTA_RETORNE_PARA_SE_PREPARAR_65F135, "loss")
		end
	end
	if s.status == "active" and s.turn >= R.MaxTurns then
		s.status = "escaped"
		note(s, Text.O_ENCONTRO_TERMINOU_PELO_LIMITE_DE_TURNOS_28EB70)
	end
	return true
end
function R.resolve(id, level, enemy, enemyLevel, rng)
	local state = R.new(enemy, enemyLevel)
	local log = {}
	R.step(state, "Select", { id = id, lv = level, uid = "active" }, rng, 0, true)
	while state.status == "active" and state.party.active.hp > 0 do
		local action = state.turn >= (state.party.active.nextSkill or 0) and "Skill" or "Strike"
		R.step(state, action, nil, rng, 0, true)
		for _, event in state.log do
			if event.amount then
				table.insert(
					log,
					{ me = event.kind == "hit", dmg = event.amount, hp = event.health, mult = event.mult }
				)
			end
		end
	end
	return log, state.status == "won"
end
return R
