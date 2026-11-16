--!strict
-- CombatRules.luau - Pure combat logic: type chart, damage formulas, status effects
-- No services, no instances, no clock, no client-informed state.

local Text = require(script.Parent.Strings).Text
local C = require(script.Parent.Creatures)
local Elements = require(script.Parent.Elements)
local Skills = require(script.Parent.Skills)
local CaptureMath = require(script.Parent.CaptureMath)
local Moves = require(script.Parent.Moves)

local R = {
	MaxTurns = 40,
	MaxParty = 3,
	LevelGrowth = 0.005,
	TameHealth = 1.08,
	TamePower = 1.085,
	DamageVariance = 0.15,
	PressureStart = 7,
	PressureBase = 1.6,
	MaxStatusDuration = 5,
	StatusChanceBase = 0.3,
	CriticalRate = 0.0625,
	CriticalMultiplier = 1.5,
	EscapeAttempts = 3,
	-- Double battle config
	MaxPartyDouble = 4,
	-- Horde battle config
	HordeSize = 5,
	-- Guardian raid config
	RaidMaxPlayers = 4,
}

-- Status Effect Types
export type StatusEffect =
	| "burn"
	| "freeze"
	| "paralyze"
	| "poison"
	| "sleep"
	| "confuse"
	| "fear"
	| "curse"
	| "bless"

export type StatusData = {
	type: StatusEffect,
	duration: number,
	source: string?,
	potency: number?, -- For damage-over-time effects
}

export type Combatant = {
	id: string,
	lv: number,
	maxHp: number,
	hp: number,
	atk: number,
	def: number,
	speed: number,
	el: string,
	isLegendary: boolean?,
	nextSkill: number?,
	evade: boolean?,
	status: { [StatusEffect]: StatusData }?,
	statStages: {
		atk: number,
		def: number,
		speed: number,
		spAtk: number,
		spDef: number,
		accuracy: number,
		evasion: number
	}?,
	-- Ascension fields
	ascended: boolean?,
	ascensionTurn: number?,
}

export type BattleState = {
	foe: Combatant,
	party: { [string]: Combatant },
	active: string?,
	bond: number,
	turn: number,
	version: number,
	status: "active" | "won" | "lost" | "captured" | "escaped",
	log: { { text: string, kind: string, amount: number?, health: number?, mult: number? } },
	attempts: number,
	capturable: boolean,
	isLegendary: boolean?,
	sealKind: string?,
	spentSeal: boolean?,
	captureBase: number?,
	message: string?,
	intro: string?,
	-- Double battle fields
	battleType: "wild" | "double" | "horde" | "guardian" | "special" | "raid",
	foes: { Combatant }?, -- For multiple foes
	field: {
		weather: string?,
		terrain: string?,
		gravity: number,
		trickRoom: boolean,
		tailwind: { [string]: number },
	}?,
}

-- Type effectiveness is handled by Elements.mult (2, 1, 0.5, 0)

function R.stats(id: string, lv: number): Combatant
	local def = assert(C.ById[id], Text.ESPECIE_DE_COMBATE_DESCONHECIDA_6A7E80)
	local scale = 1 + R.LevelGrowth * (lv - 1)
	local shapeSpeed = ({ Blob = 9, Beast = 15, Bird = 20, Dragon = 13, Serpent = 16, Insect = 18, Quadruped = 14, Winged = 19, Aquatic = 12, Arthropod = 16, Mineral = 8, Spectral = 17, Vegetal = 10, Draconic = 15 })[def.shape] or 12
	return {
		id = id,
		lv = lv,
		maxHp = math.floor(def.hp * scale),
		atk = def.atk * scale,
		def = 4 + def.rar * 3 + lv * 0.35,
		speed = shapeSpeed + lv,
		el = def.el,
		nextSkill = 0,
		statStages = { atk = 0, def = 0, speed = 0, spAtk = 0, spDef = 0, accuracy = 0, evasion = 0 },
		status = {},
	}
end

function R.damage(attacker: Combatant, defender: Combatant, power: number, guard: boolean, move: Moves.MoveData?): number
	local levelGap = math.clamp(attacker.lv - defender.lv, -30, 30)
	local pressure = 1.008 ^ levelGap
		* R.PressureBase ^ (math.max(0, math.abs(levelGap) - R.PressureStart) * (levelGap >= 0 and 1 or -1))
	if attacker.isLegendary or defender.isLegendary then
		pressure = 1.008 ^ levelGap
	end

	local typeMult = Elements.mult(attacker.el, defender.el)

	-- Stat stage modifiers
	local atkStage = attacker.statStages and attacker.statStages.atk or 0
	local defStage = defender.statStages and defender.statStages.def or 0
	local stageMult = (2 + atkStage) / (2 - defStage)

	-- Critical hit
	local isCrit = math.random() < R.CriticalRate
	local critMult = isCrit and R.CriticalMultiplier or 1

	-- Damage variance
	local variance = 1 - R.DamageVariance + math.random() * R.DamageVariance * 2

	local baseDamage = attacker.atk * power * typeMult * 100 / (100 + defender.def) * pressure * stageMult * variance * critMult * (guard and 0.45 or 1)

	-- Status effect modifiers
	if attacker.status and attacker.status.burn and move and move.category == "physical" then
		baseDamage *= 0.5
	end

	-- Ascension bonus
	if attacker.ascended then
		baseDamage *= 1.2
	end

	return math.max(1, math.floor(baseDamage))
end

function R.applyStatus(target: Combatant, statusType: StatusEffect, duration: number, source: string?, potency: number?): boolean
	if target.status[statusType] then
		return false -- Already has this status
	end

	-- Type-based immunities
	if statusType == "burn" and target.el == "Fogo" then return false end
	if statusType == "freeze" and target.el == "Gelo" then return false end
	if statusType == "paralyze" and target.el == "Elétrico" then return false end
	if statusType == "poison" and (target.el == "Metal" or target.el == "Cristal") then return false end
	if statusType == "sleep" and target.el == "Arcano" then return false end
	if statusType == "confuse" and target.el == "Luz" then return false end
	if statusType == "fear" and target.el == "Sombra" then return false end
	if statusType == "curse" and target.el == "Luz" then return false end

	-- Bless prevents negative status effects
	if target.status.bless and (statusType ~= "bless") then
		local chance = math.random()
		if chance < 0.3 then
			return false -- Bless blocked the status
		end
	end

	target.status[statusType] = {
		type = statusType,
		duration = math.min(duration, R.MaxStatusDuration),
		source = source,
		potency = potency,
	}
	return true
end

function R.removeStatus(target: Combatant, statusType: StatusEffect): boolean
	if target.status[statusType] then
		target.status[statusType] = nil
		return true
	end
	return false
end

function R.tickStatus(target: Combatant, rng: Random): { { text: string, kind: string } }?
	local log = {}
	for statusType, data in target.status do
		data.duration -= 1
		local name = C.ById[target.id] and C.ById[target.id].name or "A fera"
		if statusType == "burn" then
			local dmg = math.max(1, math.floor(target.maxHp * 0.0625))
			target.hp = math.max(0, target.hp - dmg)
			table.insert(log, { text = name .. Text.SOFREU_B1492B .. dmg .. Text.DE_DANO_POR_QUEIMADURA_04F138, kind = "status" })
		elseif statusType == "poison" then
			local dmg = math.max(1, math.floor(target.maxHp * 0.125))
			target.hp = math.max(0, target.hp - dmg)
			table.insert(log, { text = name .. Text.SOFREU_B1492B .. dmg .. Text.DE_DANO_POR_VENENO_04F138, kind = "status" })
		elseif statusType == "curse" then
			local dmg = math.max(1, math.floor(target.maxHp * 0.25))
			target.hp = math.max(0, target.hp - dmg)
			table.insert(log, { text = name .. Text.SOFREU_B1492B .. dmg .. Text.DE_DANO_POR_MALDICAO_04F138, kind = "status" })
		elseif statusType == "freeze" then
			if rng:NextNumber() < 0.2 then
				R.removeStatus(target, "freeze")
				table.insert(log, { text = name .. Text.SE_DESGELOU_8F4A4A, kind = "status" })
			end
		elseif statusType == "sleep" then
			if rng:NextNumber() < 0.25 then
				R.removeStatus(target, "sleep")
				table.insert(log, { text = name .. Text.ACORDOU_8F4A4A, kind = "status" })
			end
		elseif statusType == "confuse" then
			if rng:NextNumber() < 0.33 then
				R.removeStatus(target, "confuse")
				table.insert(log, { text = name .. Text.NO_LONGER_CONFUSED, kind = "status" })
			end
		elseif statusType == "fear" then
			-- Fear reduces damage dealt
		elseif statusType == "bless" then
			-- Bless increases crit rate
		end

		if data.duration <= 0 then
			R.removeStatus(target, statusType)
			if statusType ~= "freeze" and statusType ~= "sleep" and statusType ~= "confuse" then
				table.insert(log, { text = name .. Text.NO_LONGER_AFFECTED_BY .. statusType, kind = "status" })
			end
		end
	end
	return #log > 0 and log or nil
end

function R.canAct(target: Combatant, rng: Random): { canAct: boolean, log: { { text: string, kind: string } }? }
	local log = {}

	if target.status.paralyze and rng:NextNumber() < 0.25 then
		table.insert(log, { text = C.ById[target.id].name .. Text.ESTA_PARALISADO_E_NAO_PODE_SE_MOVER, kind = "status" })
		return { canAct = false, log = log }
	end

	if target.status.sleep then
		table.insert(log, { text = C.ById[target.id].name .. Text.ESTA_DORMINDO, kind = "status" })
		return { canAct = false, log = log }
	end

	if target.status.freeze then
		table.insert(log, { text = C.ById[target.id].name .. Text.ESTA_CONGELADO_E_NAO_PODE_SE_MOVER, kind = "status" })
		-- 20% chance to thaw
		if rng:NextNumber() < 0.2 then
			R.removeStatus(target, "freeze")
			table.insert(log, { text = C.ById[target.id].name .. Text.SE_DESGELOU, kind = "status" })
			return { canAct = true, log = log }
		end
		return { canAct = false, log = log }
	end

	if target.status.confuse and rng:NextNumber() < 0.33 then
		local dmg = math.max(1, math.floor(target.maxHp * 0.25))
		target.hp = math.max(0, target.hp - dmg)
		table.insert(log, { text = C.ById[target.id].name .. Text.SE_MACHUCOU_EM_SUA_CONFUSAO_B1492B .. dmg, kind = "status" })
		return { canAct = false, log = log }
	end

	if target.status.fear and rng:NextNumber() < 0.2 then
		table.insert(log, { text = C.ById[target.id].name .. Text.ESTA_COM_MEDO_E_HESITOU, kind = "status" })
		return { canAct = false, log = log }
	end

	return { canAct = true, log = #log > 0 and log or nil }
end

function R.modifyStatStage(target: Combatant, stat: string, stages: number): boolean
	if not target.statStages then return false end
	if not target.statStages[stat] then return false end
	target.statStages[stat] = math.clamp(target.statStages[stat] + stages, -6, 6)
	return true
end

function R.resetStatStages(target: Combatant)
	if target.statStages then
		for k in target.statStages do
			target.statStages[k] = 0
		end
	end
end

function R.chance(state: BattleState): number
	return CaptureMath.chance(state)
end

function R.new(foeId: string, foeLevel: number, settings: { statMultiplier: number?, isLegendary: boolean?, captureBase: number?, battleType: BattleState["battleType"]? }?): BattleState
	settings = settings or {}
	local foe = R.stats(foeId, foeLevel)
	foe.isLegendary = settings.isLegendary == true
	foe.hp = foe.maxHp
	for _, key in { "maxHp", "atk", "def", "speed" } do
		foe[key] = foe[key] * (settings.statMultiplier or 1)
		if key == "maxHp" then
			foe[key] = math.floor(foe[key])
			foe.hp = foe[key]
		end
	end

	return {
		foe = foe,
		party = {},
		active = nil,
		bond = 0,
		turn = 0,
		version = 0,
		status = "active",
		log = {},
		attempts = 0,
		capturable = true,
		isLegendary = settings.isLegendary,
		captureBase = settings.captureBase,
		battleType = settings.battleType or "wild",
		foes = settings.battleType and settings.battleType ~= "wild" and { foe } or nil,
		field = {
			weather = nil,
			terrain = nil,
			gravity = 1,
			trickRoom = false,
			tailwind = {},
		},
	}
end

local function note(s: BattleState, text: string, kind: string?)
	table.insert(s.log, { text = text, kind = kind or "info" })
end

local function reply(s: BattleState, guard: boolean, rng: Random)
	local pet = s.active and s.party[s.active]
	if not pet or pet.hp <= 0 then return end

	local move = nil -- Foe uses basic attack
	local amount = math.floor(R.damage(s.foe, pet, (s.turn % 3 == 0 and 1.35 or 1) * (1 - R.DamageVariance + rng:NextNumber() * R.DamageVariance * 2), guard, move) + rng:NextNumber())

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

function R.step(state: BattleState, action: string, pet: { uid: string, id: string, lv: number }?, rng: Random, seals: number, room: boolean): (boolean, string?)
	if state.status ~= "active" then
		return false, Text.ESTE_ENCONTRO_TERMINOU_EC2596
	end
	if state.turn >= R.MaxTurns then
		state.status = "escaped"
		return true
	end

	local current = state.active and state.party[state.active]

	-- Validate action
	if action == "Select" then
		if not pet or not C.ById[pet.id] or not pet.uid then
			return false, Text.ESCOLHA_UMA_FERA_SUA_699F8C
		end
		if pet.uid == state.active then
			return false, Text.ESSA_FERA_JA_ESTA_EM_CAMPO_198AD6
		end
		local n = 0
		for _ in state.party do n += 1 end
		if not state.party[pet.uid] and n >= R.MaxParty then
			return false, Text.EQUIPE_LIMITADA_A_TRES_FERAS_POR_ENCONTRO_31F83A
		end
		if state.party[pet.uid] and state.party[pet.uid].hp <= 0 then
			return false, Text.ESSA_FERA_ESTA_EXAUSTA_89922B
		end
	elseif action == "Strike" or action == "Skill" or action == "Guard" then
		if not current or current.hp <= 0 then
			return false, Text.SELECIONE_UMA_FERA_DISPONIVEL_94CE80
		end
		if action == "Skill" and state.turn < (current.nextSkill or 0) then
			return false, Text.HABILIDADE_RECARREGANDO_5B6E68
		end
	elseif action == "Capture" then
		if state.capturable == false then
			return false, Text.GUARDIOES_NAO_PODEM_SER_CAPTURADOS_CA285E
		end
		if seals < 1 then
			return false, Text.SEM_SELOS_CRIE_MAIS_NO_MERCADO_D1B215
		end
		if not room then
			return false, Text.INVENTARIO_CHEIO_NENHUM_SELO_FOI_GASTO_7FC7F9
		end
	elseif action == "Bond" and state.capturable == false then
		return false, Text.ESTE_DESAFIO_EXIGE_UMA_BATALHA_14581F
	elseif action == "UseItem" then
		-- Handled separately
	elseif action ~= "Bond" and action ~= "Flee" and action ~= "UseItem" then
		return false, Text.ACAO_DESCONHECIDA_9BB0DF
	end

	state.log = {}
	state.turn += 1
	state.version += 1
	state.spentSeal = false

	if action == "Flee" then
		state.status = "escaped"
		note(state, Text.VOCE_VOLTOU_A_EXPLORACAO_29EB17)
		return true
	end

	if action == "Select" then
		local switching = state.active ~= nil and state.party[state.active].hp > 0
		if not state.party[pet.uid] then
			local unit = R.stats(pet.id, pet.lv)
			unit.maxHp = math.floor(unit.maxHp * R.TameHealth)
			unit.atk = unit.atk * R.TamePower
			unit.hp = unit.maxHp
			unit.nextSkill = 0
			state.party[pet.uid] = unit
		end
		state.active = pet.uid
		note(state, C.ById[pet.id].name .. Text.ENTROU_EM_CAMPO_AC551A)
		if switching then
			reply(state, false, rng)
		end
	elseif action == "Capture" then
		state.spentSeal = true
		state.attempts += 1
		if rng:NextNumber() < R.chance(state) then
			state.status = "captured"
			note(state, Text.VINCULO_ESTABELECIDO_21A0FC, "capture")
		else
			note(state, Text.O_SELO_SE_DESFEZ_A_FERA_RESISTIU_ECB4B5, "miss")
			if current and current.hp > 0 then
				reply(state, false, rng)
			elseif not state.isLegendary and (rng:NextNumber() < 0.3 or state.attempts >= 6) then
				state.status = "escaped"
				note(state, Text.A_FERA_FUGIU_5FDD82)
			end
		end
	elseif action == "Bond" then
		state.bond = math.min(3, state.bond + 1)
		note(state, Text.VOCE_SE_APROXIMOU_COM_CUIDADO_VINCULO_555F67 .. state.bond .. "/3.", "bond")
		if current and current.hp > 0 then
			reply(state, false, rng)
		elseif not state.isLegendary and rng:NextNumber() < 0.15 then
			state.status = "escaped"
			note(state, Text.A_FERA_SE_ASSUSTOU_E_FUGIU_FF44C5)
		end
	elseif action == "Guard" then
		current.hp = math.min(current.maxHp, current.hp + math.floor(current.maxHp * 0.08))
		current.evade = true
		note(state, Text.SUA_FERA_RECUPEROU_O_FOLEGO_E_SE_PROTEGEU_08D205, "guard")
		reply(state, true, rng)
	elseif action == "Strike" or action == "Skill" then
		local skill = Skills[C.ById[current.id].shape]
		local moveData = Moves.getMove(current.id, action == "Skill")
		local power = action == "Skill" and (moveData and moveData.power or skill.power) or 1
		local enemyFirst = state.foe.speed > current.speed

		-- Check if can act
		local actResult = R.canAct(current, rng)
		if actResult and not actResult.canAct then
			for _, entry in actResult.log do
				note(state, entry.text, entry.kind)
			end
			if enemyFirst then
				reply(state, false, rng)
			end
		else
			if enemyFirst then
				reply(state, false, rng)
			end

			if current.hp > 0 then
				if action == "Skill" and moveData then
					current.nextSkill = state.turn + (moveData.cooldown or 3)
					-- Apply move effects
					if moveData.effect then
						R.applyMoveEffect(current, state.foe, moveData, state, rng)
					end
					note(state, moveData.name .. "!", "skill")
				end

				local amount = math.floor(R.damage(current, state.foe, power * (1 - R.DamageVariance + rng:NextNumber() * R.DamageVariance * 2), false, moveData) + rng:NextNumber())
				state.foe.hp = math.max(0, state.foe.hp - amount)

				local mult = Elements.mult(current.el, state.foe.el)
				note(state,
					Text.SUA_FERA_CAUSOU_9F1A6C .. amount .. Text.DE_DANO_949A5C .. (mult > 1 and Text.VANTAGEM_ELEMENTAL_C12EBC or mult < 1 and Text.RESISTENCIA_ELEMENTAL_8F4A4A or "."),
					"hit"
				)
				state.log[#state.log].amount = amount
				state.log[#state.log].health = state.foe.hp / state.foe.maxHp
				state.log[#state.log].mult = mult

				if state.foe.hp == 0 then
					state.status = "won"
					note(state, Text.VITORIA_FERAS_EXAUSTAS_NAO_PODEM_SER_CAPTURADAS_08B05D, "win")
				elseif not enemyFirst then
					reply(state, false, rng)
				end
			end
		end
	end

	-- Tick status effects on active combatant
	if current then
		local statusLog = R.tickStatus(current, rng)
		if statusLog then
			for _, entry in statusLog do
				note(state, entry.text, entry.kind)
			end
		end
	end

	-- Tick status effects on foe
	local foeStatusLog = R.tickStatus(state.foe, rng)
	if foeStatusLog then
		for _, entry in foeStatusLog do
			note(state, entry.text, entry.kind)
		end
	end

	-- Check for faint
	if state.status == "active" and state.active and state.party[state.active].hp <= 0 then
		local count, alive = 0, false
		for _, unit in state.party do
			count += 1
			if unit.hp > 0 then alive = true end
		end
		if count >= R.MaxParty and not alive then
			state.status = "lost"
			note(state, Text.SUA_EQUIPE_ESTA_EXAUSTA_RETORNE_PARA_SE_PREPARAR_65F135, "loss")
		end
	end

	if state.status == "active" and state.turn >= R.MaxTurns then
		state.status = "escaped"
		note(state, Text.O_ENCONTRO_TERMINOU_PELO_LIMITE_DE_TURNOS_28EB70)
	end

	return true
end

function R.applyMoveEffect(attacker: Combatant, defender: Combatant, move: Moves.MoveData, state: BattleState, rng: Random)
	if not move.effect then return end

	local effect = move.effect
	local chance = effect.chance or 1

	if rng:NextNumber() >= chance then return end

	if effect.type == "status" then
		R.applyStatus(defender, effect.status, effect.duration or 3, move.name, effect.potency)
	elseif effect.type == "stat" then
		R.modifyStatStage(defender, effect.stat, effect.stages)
	elseif effect.type == "heal" then
		local heal = math.floor(attacker.maxHp * (effect.amount or 0.125))
		attacker.hp = math.min(attacker.maxHp, attacker.hp + heal)
	elseif effect.type == "drain" then
		local dmg = math.floor(R.damage(attacker, defender, move.power * (effect.drainRatio or 0.5), false, move))
		defender.hp = math.max(0, defender.hp - dmg)
		attacker.hp = math.min(attacker.maxHp, attacker.hp + dmg)
	elseif effect.type == "multiHit" then
		-- Handled in damage calculation
	elseif effect.type == "recharge" then
		attacker.nextSkill = (attacker.nextSkill or 0) + (effect.turns or 1)
	elseif effect.type == "flinch" then
		-- Target loses next turn
		defender.status.flinch = { type = "flinch", duration = 1 }
	elseif effect.type == "critBoost" then
		attacker.statStages = attacker.statStages or { atk = 0, def = 0, speed = 0, spAtk = 0, spDef = 0, accuracy = 0, evasion = 0 }
		R.modifyStatStage(attacker, "spAtk", 1)
	elseif effect.type == "protect" then
		attacker.status.protect = { type = "protect", duration = 1 }
	end
end

function R.resolve(id: string, level: number, enemy: string, enemyLevel: number, rng: Random)
	local state = R.new(enemy, enemyLevel)
	local log = {}
	R.step(state, "Select", { id = id, lv = level, uid = "active" }, rng, 0, true)
	while state.status == "active" and state.party.active.hp > 0 do
		local action = state.turn >= (state.party.active.nextSkill or 0) and "Skill" or "Strike"
		R.step(state, action, nil, rng, 0, true)
		for _, event in state.log do
			if event.amount then
				table.insert(log, { me = event.kind == "hit", dmg = event.amount, hp = event.health, mult = event.mult })
			end
		end
	end
	return log, state.status == "won"
end

-- Legendary Ascension (Mega Evolution equivalent)
function R.checkAscension(pet: Combatant, heldItem: string?): boolean
	if not pet.isLegendary then return false end
	if pet.lv < 100 then return false end
	-- Check for specific ascension items
	local ascensionItems = {
		fenix = "CinaSolar",
		vulcanodrago = "NucleoVulcanico",
		abissauro = "PerolaAbissal",
		ancestravore = "SementePrimordial",
		colossodune = "CoracaoDasDunas",
		aeronimbo = "OlhoDaTempestade",
		reinevoento = "CoroaDoNevoeiro",
	}
	return ascensionItems[pet.id] == heldItem
end

function R.applyAscension(pet: Combatant): Combatant
	local ascended = table.clone(pet)
	ascended.maxHp = math.floor(ascended.maxHp * 1.5)
	ascended.hp = ascended.maxHp
	ascended.atk = ascended.atk * 1.4
	ascended.def = ascended.def * 1.3
	ascended.speed = ascended.speed * 1.2
	ascended.isLegendary = true
	ascended.ascended = true
	ascended.ascensionTurn = 0
	return ascended
end

-- Horde battle support
function R.newHorde(foeId: string, foeLevel: number, count: number, settings: { statMultiplier: number?, captureBase: number? }?): BattleState
	settings = settings or {}
	local foes = {}
	for i = 1, math.min(count, R.HordeSize) do
		local foe = R.stats(foeId, foeLevel)
		foe.hp = foe.maxHp
		for _, key in { "maxHp", "atk", "def", "speed" } do
			foe[key] = foe[key] * (settings.statMultiplier or 1)
			if key == "maxHp" then
				foe[key] = math.floor(foe[key])
				foe.hp = foe[key]
			end
		end
		table.insert(foes, foe)
	end

	return {
		foe = foes[1],
		foes = foes,
		party = {},
		active = nil,
		bond = 0,
		turn = 0,
		version = 0,
		status = "active",
		log = {},
		attempts = 0,
		capturable = true,
		isLegendary = false,
		captureBase = settings.captureBase,
		battleType = "horde",
		field = {
			weather = nil,
			terrain = nil,
			gravity = 1,
			trickRoom = false,
			tailwind = {},
		},
	}
end

-- Double battle support
function R.newDouble(foeId1: string, foeLevel1: number, foeId2: string, foeLevel2: number, settings: { statMultiplier: number? }?): BattleState
	settings = settings or {}
	local foe1 = R.stats(foeId1, foeLevel1)
	local foe2 = R.stats(foeId2, foeLevel2)
	foe1.hp = foe1.maxHp
	foe2.hp = foe2.maxHp
	for _, key in { "maxHp", "atk", "def", "speed" } do
		foe1[key] = foe1[key] * (settings.statMultiplier or 1)
		foe2[key] = foe2[key] * (settings.statMultiplier or 1)
		if key == "maxHp" then
			foe1[key] = math.floor(foe1[key])
			foe1.hp = foe1[key]
			foe2[key] = math.floor(foe2[key])
			foe2.hp = foe2[key]
		end
	end

	return {
		foe = foe1,
		foes = { foe1, foe2 },
		party = {},
		active = nil,
		bond = 0,
		turn = 0,
		version = 0,
		status = "active",
		log = {},
		attempts = 0,
		capturable = false,
		isLegendary = false,
		battleType = "double",
		field = {
			weather = nil,
			terrain = nil,
			gravity = 1,
			trickRoom = false,
			tailwind = {},
		},
	}
end

return R