--!nonstrict
local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local C = require(RS.Shared.Creatures)
local I = require(RS.Shared.Islands)
local B = require(RS.Shared.Breeding)
local Access = require(RS.Shared.Access)
local Grant = require(RS.Shared.CreatureGrant)
local Pools = require(RS.Shared.EncounterPools)
local Region = require(script.Parent.RegionService)
local Http = game:GetService("HttpService")
local M = require(RS.Shared.Missions)
local SR = require(RS.Shared.SanctuaryRules)
local CaptureRules = require(RS.Shared.CaptureRules)
local Story = require(RS.Shared.Story)
local Progression = require(RS.Shared.Progression)
local Combat = require(RS.Shared.CombatRules)
local Transport = require(script.Parent.Transport)
local Sanctuary = require(script.Parent.SanctuaryService)
local Data = require(script.Parent.DataService)
local World = require(script.Parent.World)
local G = {}
local rng = Random.new()
local Mon = require(script.Parent.MonetizationService)
local lastBattle = setmetatable({}, { __mode = "k" })
local Balance = require(RS.Shared.Economy)
local MAXLV, OFFLINE_CAP, BREED_COST = Balance.MaxLevel, Balance.OfflineCap, Balance.BreedCost
local function lvMul(lv)
	return 1 + 0.15 * (lv - 1)
end
local function bump(d, k)
	d.stats[k] = (d.stats[k] or 0) + 1
end
local function fail(m)
	return { ok = false, msg = m }
end
local function ok(p, m)
	return { ok = true, msg = m, data = Data.snapshot(p) }
end
-- Renda por tempo REAL do servidor (os.time), limitada a 8 h: alterar o relógio do cliente não adianta.
local function settle(p)
	local d = Data.get(p)
	local now = os.time()
	local mins = math.clamp(now - d.last, 0, OFFLINE_CAP) / 60
	local gold = 0
	local EV = M.event(now)
	for isl, list in d.habitat do
		for _, uid in list do
			local cr = d.creatures[uid]
			if cr then
				local cd = C.ById[cr.id]
				gold += cd.gpm * lvMul(cr.lv) * (cd.el == I.ById[isl].el and 1.5 or 1) * (cd.el == EV and 1.5 or 1) * (d.pass.Dobro and 2 or 1) * mins
			end
		end
	end
	gold = math.floor(gold)
	d.gold += gold
	d.last = now
	return gold
end
G.Actions = {}
local A = G.Actions
function A.Home(p)
	if not Sanctuary.home(p) then
		return fail(Text.PERSONAGEM_OU_DESTINO_INDISPONIVEL_AGUARDE_E_TEN_09997D)
	end
	return ok(p, Text.BEM_VINDO_AO_SEU_SANTUARIO_161FE8)
end
function A.Travel(p, id)
	local d = Data.get(p)
	local def = I.ById[id]
	if not Access.check(d, id, "travel").ok then
		return fail(Text.ACESSO_NEGADO_AB7F08)
	end
	local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
	if not def or not root then
		return fail(Text.DESTINO_INDISPONIVEL_06B531)
	end
	if not Transport.go(p, I.pos(def.idx) + Vector3.new(0, 9, 24), id) then
		return fail(Text.DESTINO_AINDA_NAO_CARREGOU_TENTE_NOVAMENTE_005D89)
	end
	return ok(p, Text.CHEGOU_A_FAE834 .. def.name)
end
function A.Companion(p, uid)
	local d = Data.get(p)
	if uid ~= nil and not d.creatures[uid] then
		return fail(Text.ESCOLHA_UMA_FERA_SUA_E1857C)
	end
	if d.companion == uid then
		d.companion = nil
	else
		d.companion = uid
	end
	World.refresh(p)
	return ok(p, d.companion and Text.COMPANHEIRO_ESCOLHIDO_411FF1 or Text.COMPANHEIRO_GUARDADO_027BB3)
end
function A.Pet(p)
	local d = Data.get(p)
	if not d.companion then
		return fail(Text.ESCOLHA_UM_COMPANHEIRO_FBC455)
	end
	p:SetAttribute("PetHappyUntil", workspace:GetServerTimeNow() + 2)
	return ok(p, Text.SEU_COMPANHEIRO_GOSTOU_DO_CARINHO_C1382F)
end
function A.BuildHabitat(p, id, slot)
	local d = Data.get(p)
	local def = I.ById[id]
	if not Access.check(d, id, "habitat").ok or not def or d.sanctuary[id] or not SR.available(d.sanctuary, slot) then
		return fail(Text.HABITAT_POSICAO_OU_DESBLOQUEIO_INVALIDO_CC4AAD)
	end
	local cost = SR.buildCost(def)
	if d.gold < cost then
		return fail(Text.PRECISA_DE_3C22C8 .. cost .. " ouro")
	end
	d.gold -= cost
	d.sanctuary[id] = { slot = slot, level = 1 }
	bump(d, "habitatBuild")
	World.refresh(p)
	return ok(p, Text.HABITAT_CONSTRUIDO_NO_SEU_TERRENO_C7F40C)
end
function A.MoveHabitat(p, id, slot)
	local d = Data.get(p)
	if not Access.check(d, id, "habitat").ok then
		return fail(Text.ACESSO_NEGADO_AB7F08)
	end
	local entry = d.sanctuary[id]
	if not entry or not SR.available(d.sanctuary, slot, id) then
		return fail(Text.POSICAO_OCUPADA_OU_INVALIDA_5582C8)
	end
	entry.slot = slot
	World.refresh(p)
	return ok(p, Text.HABITAT_MOVIDO_2E232D)
end
function A.UpgradeHabitat(p, id)
	local d = Data.get(p)
	if not Access.check(d, id, "habitat").ok then
		return fail(Text.ACESSO_NEGADO_AB7F08)
	end
	local entry = d.sanctuary[id]
	if not entry or entry.level >= SR.MaxLevel then
		return fail(Text.HABITAT_INDISPONIVEL_OU_MAXIMO_989E00)
	end
	local cost = SR.upgradeCost(entry)
	if d.gold < cost then
		return fail(Text.PRECISA_DE_3C22C8 .. cost .. " ouro")
	end
	settle(p)
	d.gold -= cost
	entry.level += 1
	bump(d, "habitatUpgrade")
	World.refresh(p)
	return ok(p, Text.HABITAT_MELHORADO_MAIS_DUAS_VAGAS_C4EEBD)
end
function A.RemoveHabitat(p, id)
	local d = Data.get(p)
	if not Access.check(d, id, "habitat").ok then
		return fail(Text.ACESSO_NEGADO_AB7F08)
	end
	if not d.sanctuary[id] or #(d.habitat[id] or {}) > 0 then
		return fail(Text.TRANSFIRA_AS_FERAS_ANTES_DE_REMOVER_O_HABITAT_C629D5)
	end
	d.sanctuary[id] = nil
	World.refresh(p)
	return ok(p, Text.ESTRUTURA_REMOVIDA_SEM_REEMBOLSO_565589)
end
function A.ClaimStory(p, id)
	local d = Data.get(p)
	if not Story.canClaim(d, id) then
		return fail(Text.CONCLUA_O_CAPITULO_ATUAL_PRIMEIRO_3187C6)
	end
	local q = Story.ById[id]
	d.storyClaimed[id] = true
	d.gold += q.gold
	d.seals = math.min(10000, d.seals + q.seals)
	Progression.award(d, q.xp)
	return ok(
		p,
		Text.CAPITULO_CONCLUIDO_BF33C2 .. q.gold .. " ouro, +" .. q.xp .. Text.XP_E_5EFA95 .. q.seals .. " selos"
	)
end
function A.CraftSeal(p, kind)
	local d = Data.get(p)
	kind = kind or "Basic"
	local recipe = CaptureRules.Seals[kind]
	if not recipe then
		return fail(Text.TIPO_DE_SELO_INVALIDO_9B6D96)
	end
	local count = kind == "Basic" and d.seals or d.sealStock[kind] or 0
	if count >= 10000 or d.gold < recipe.cost or d.playerLevel < recipe.level then
		return fail(
			Text.PRECISA_DE_NIVEL_3806D7 .. recipe.level .. " e " .. recipe.cost .. Text.OURO_LIMITE_10_MIL_SELOS_71673A
		)
	end
	if recipe.material and (d.materials[recipe.material] or 0) < recipe.amount then
		return fail(Text.PRECISA_DE_3C22C8 .. recipe.amount .. Text.ESSENCIA_DE_0F286A .. recipe.material)
	end
	d.gold -= recipe.cost
	if recipe.material then
		d.materials[recipe.material] -= recipe.amount
	end
	if kind == "Basic" then
		d.seals += 1
	else
		d.sealStock[kind] = count + 1
	end
	return ok(p, "+1 Selo " .. recipe.name)
end
function A.Get(p)
	return ok(p)
end
function A.Collect(p)
	local g = settle(p)
	bump(Data.get(p), "collect")
	return ok(p, "+" .. g .. " ouro")
end
function A.Feed(p, uid)
	local d = Data.get(p)
	local cr = d.creatures[uid]
	if not cr then
		return fail(Text.CRIATURA_INVALIDA_3A9F3E)
	end
	if cr.lv >= MAXLV then
		return fail(Text.NIVEL_MAXIMO_8078AA)
	end
	settle(p)
	local cost = cr.lv * 20
	if d.gold < cost then
		return fail(Text.OURO_INSUFICIENTE_AF56CF .. cost .. ")")
	end
	d.gold -= cost
	cr.lv += 1
	bump(d, "feed")
	World.refresh(p)
	return ok(
		p,
		Text.SUBIU_PARA_O_NIVEL_0AB637
			.. cr.lv
			.. (C.stage(cr.lv, cr.id) > C.stage(cr.lv - 1, cr.id) and " — EVOLUIU!" or "")
	)
end
function A.Place(p, uid, isl)
	local d = Data.get(p)
	local def = I.ById[isl]
	if not d.creatures[uid] or not def or not Access.check(d, isl, "habitat").ok then
		return fail(Text.ILHA_OU_CRIATURA_INVALIDA_000968)
	end
	local structure = d.sanctuary[isl]
	if not structure then
		return fail(Text.CONSTRUA_ESSE_HABITAT_NO_SANTUARIO_6A9DF1)
	end
	local creature = C.ById[d.creatures[uid].id]
	if creature.el ~= def.el and not (creature.hybrid and table.find(creature.hybrid, def.el)) then
		return fail(Text.ELEMENTO_INCOMPATIVEL_COM_ESTE_HABITAT_30076C)
	end
	local list = d.habitat[isl] or {}
	if #list - (table.find(list, uid) and 1 or 0) >= SR.capacity(def, structure) then
		return fail(Text.HABITAT_CHEIO_1E10B0)
	end
	settle(p)
	for _, l in d.habitat do
		local i = table.find(l, uid)
		if i then
			table.remove(l, i)
		end
	end
	d.habitat[isl] = d.habitat[isl] or {}
	table.insert(d.habitat[isl], uid)
	World.refresh(p)
	return ok(p, C.ById[d.creatures[uid].id].name .. Text.AGORA_VIVE_EM_207F92 .. def.name)
end
function A.Unlock(p, isl)
	local d = Data.get(p)
	local check = Access.check(d, isl, "unlock")
	if not check.ok then
		return fail(check.reason)
	end
	if require(RS.Shared.Config).World.FreeExploration then
		return ok(p, "Região livre para explorar; nenhum ouro foi cobrado.")
	end
	if d.unlocked[isl] then
		return fail(Text.JA_DESBLOQUEADA_118724)
	end
	d.gold -= I.ById[isl].cost
	d.unlocked[isl] = true
	return ok(p, Text.REGIAO_DESBLOQUEADA_561460)
end
function A.Breed(p, a, b)
	local d = Data.get(p)
	if a == b or not d.creatures[a] or not d.creatures[b] then
		return fail(Text.ESCOLHA_DUAS_FERAS_DIFERENTES_D70C07)
	end
	local Species = require(RS.Shared.SpeciesRules)
	if not Species.isBreedable(d.creatures[a].id) or not Species.isBreedable(d.creatures[b].id) then
		return fail("Uma das espécies escolhidas não participa da reprodução.")
	end
	if #d.eggs >= Balance.IncubatorSlots then
		return fail(Text.CHOCADEIRA_CHEIA_3D3160)
	end
	if d.gold < BREED_COST then
		return fail(Text.PRECISA_DE_3C22C8 .. BREED_COST .. " ouro")
	end
	local id = B.pick(d.creatures[a].id, d.creatures[b].id, rng)
	if not id or not C.ById[id] then
		return fail("Este par não pode gerar um ovo.")
	end
	d.gold -= BREED_COST
	bump(d, "breed")
	local r = C.ById[id].rar
	table.insert(d.eggs, {
		id = id,
		ready = os.time() + Balance.IncubationBase * r * r,
		nonce = "egg:" .. Http:GenerateGUID(false),
		region = (Data.session(p) and Data.session(p).lastSafe) or "Alvorecer",
	})
	return ok(p, Text.OVO_MISTERIOSO_ECLODE_EM_F655A9 .. Balance.IncubationBase * r * r .. "s")
end
function A.Hatch(p, i)
	local d = Data.get(p)
	local e = typeof(i) == "number" and d.eggs[i]
	if not e then
		return fail(Text.OVO_INVALIDO_5146F8)
	end
	if os.time() < e.ready then
		return fail(Text.AINDA_NAO_ECLODIU_EB8B13)
	end
	local n = 0
	for _ in d.creatures do
		n += 1
	end
	if n >= Balance.InventoryLimit then
		return fail(Text.LIMITE_DE_60_FERAS_E2D3F3)
	end
	local check = Region.requireContext(p, e.region or "Alvorecer", "hatch", true)
	if not check.ok then
		return fail(check.reason)
	end
	local nonce = e.nonce
	if not nonce then
		return fail(Text.OVO_SEM_IDENTIFICACAO_RECONECTE_PARA_MIGRAR_D37C37)
	end
	local origin = d.legacyEggPermits and d.legacyEggPermits[nonce] and "legacy_egg" or "hatch"
	local uid, reason = Grant.grant(d, e.id, origin, nonce, { level = 1 })
	if not uid then
		return fail(reason)
	end
	table.remove(d.eggs, i)
	bump(d, "hatch")
	return ok(p, "Nasceu " .. C.ById[e.id].name .. "!")
end
function A.Battle(p, uid, isl)
	local d = Data.get(p)
	local actual = Region.current(p, "battle")
	if actual ~= isl then
		return fail("WRONG_REGION")
	end
	local cr = d.creatures[uid]
	local def = I.ById[actual]
	if not cr or not def then
		return fail(Text.BATALHA_INVALIDA_A8AE42)
	end
	if lastBattle[p] and os.clock() - lastBattle[p] < 20 then
		return fail(Text.SUAS_FERAS_DESCANSAM_6D6F29 .. math.ceil(20 - (os.clock() - lastBattle[p])) .. "s")
	end
	lastBattle[p] = os.clock()
	bump(d, "fight")
	local pool = Pools.list(actual, false)
	if #pool == 0 then
		return fail(Text.SEM_ENCONTROS_GERAIS_NESTA_REGIAO_ED1AF7)
	end
	local g = pool[rng:NextInteger(1, #pool)]
	local glv = Pools.rollLevel(actual, g.rar, rng)
	local log, win = Combat.resolve(cr.id, cr.lv, g.id, glv, rng)
	local info = { log = log, me = { id = cr.id, lv = cr.lv }, foe = { id = g.id, lv = glv }, win = win }
	if not win then
		local response =
			ok(p, Text.DERROTA_PARA_F29D4F .. g.name .. " (Nv." .. glv .. Text.TREINE_E_TENTE_DE_NOVO_74F9F0)
		response.battle = info
		return response
	end
	local reward = Progression.rewards(actual, glv, g.rar, cr.lv)
	Progression.award(d, reward.xp)
	Progression.awardCreature(cr, reward.creatureXp)
	local gold = reward.gold
	local gem = rng:NextNumber() < 0.2 and 1 or 0
	d.gold += gold
	d.gems += gem
	d.wins += 1
	bump(d, "win")
	local r = ok(p, Text.VITORIA_SOBRE_36EFE4 .. g.name .. "! +" .. gold .. " ouro" .. (gem > 0 and " +1 gema" or ""))
	r.battle = info
	return r
end

function A.Claim(p, id)
	local d = Data.get(p)
	local m = M.ById[id]
	if not m or d.claimed[id] or M.progress(d, m.stat) < m.goal then
		return fail(Text.MISSAO_INDISPONIVEL_EE2728)
	end
	d.claimed[id] = true
	d.gold += m.gold
	d.gems += m.gems
	return ok(p, "Recompensa: +" .. m.gold .. " ouro, +" .. m.gems .. " gemas")
end
function A.BuyEgg(p, isl)
	local d = Data.get(p)
	local def = I.ById[isl]
	local access = Region.requireContext(p, isl, "shop", true)
	if not def or not access.ok then
		return fail(access.reason)
	end
	if #d.eggs >= Balance.IncubatorSlots then
		return fail(Text.CHOCADEIRA_CHEIA_3D3160)
	end
	local cost = 80 * def.idx
	if d.gold < cost then
		return fail(Text.PRECISA_DE_3C22C8 .. cost .. " ouro")
	end
	local pick = Pools.pick(isl, rng, true)
	if not pick then
		return fail(Text.SEM_OVOS_GERAIS_NESTA_REGIAO_623A41)
	end
	d.gold -= cost
	table.insert(d.eggs, {
		id = pick.id,
		ready = os.time() + Balance.IncubationBase * pick.rar * pick.rar,
		nonce = "egg:" .. Http:GenerateGUID(false),
		region = isl,
	})
	return ok(p, Text.OVO_DE_763A79 .. def.name .. " comprado!")
end
function A.Speed(p, i)
	local d = Data.get(p)
	local e = typeof(i) == "number" and d.eggs[i]
	if not e then
		return fail(Text.OVO_INVALIDO_5146F8)
	end
	local left = e.ready - os.time()
	if left <= 0 then
		return fail(Text.JA_PODE_CHOCAR_035D5F)
	end
	local cost = math.max(1, math.ceil(left / 30))
	if d.gems < cost then
		return fail(Text.PRECISA_DE_3C22C8 .. cost .. " gemas")
	end
	d.gems -= cost
	e.ready = os.time()
	return ok(p, Text.OVO_ACELERADO_AB603C)
end
function A.Daily(p)
	local d = Data.get(p)
	local today = os.time() // 86400
	if d.dailyDay >= today then
		return fail(Text.VOLTE_AMANHA_E195DE)
	end
	d.streak = (d.dailyDay == today - 1) and d.streak + 1 or 1
	d.dailyDay = today
	local gold = 50 * math.min(d.streak, 7)
	local gem = d.streak % 3 == 0 and 1 or 0
	d.gold += gold
	d.gems += gem
	return ok(p, "Dia " .. d.streak .. " seguido: +" .. gold .. " ouro" .. (gem > 0 and " +1 gema" or ""))
end
function A.Buy(p, key)
	if typeof(key) ~= "string" then
		return fail(Text.ITEM_INVALIDO_96E69E)
	end
	local s, m = Mon.buy(p, key)
	if not s then
		return fail(m)
	end
	return ok(p, Text.ABRINDO_A_COMPRA_5DF77F)
end
local Players = game:GetService("Players")
local invitations = {}
local lastDuel = setmetatable({}, { __mode = "k" })
local function sim(ca, la, cb, lb)
	return Combat.resolve(ca.id, la, cb.id, lb, rng)
end
local function best(d)
	local b, bs
	for _, cr in d.creatures do
		local sc = C.ById[cr.id].rar * 10 + cr.lv
		if not bs or sc > bs then
			b, bs = cr, sc
		end
	end
	return b
end
-- Duelo online: sua melhor fera contra a melhor fera de outro jogador do servidor (o rival não perde nada).
function A.Duel(p, tid)
	local t = typeof(tid) == "number" and Players:GetPlayerByUserId(tid)
	local d = Data.get(p)
	local td = t and Data.get(t)
	if not td or t == p then
		return fail(Text.JOGADOR_INDISPONIVEL_D18F3F)
	end
	local key = tostring(p.UserId) .. ":" .. tostring(t.UserId)
	local reverse = tostring(t.UserId) .. ":" .. tostring(p.UserId)
	if not invitations[reverse] or invitations[reverse] < os.clock() then
		invitations[key] = os.clock() + 30
		return ok(p, Text.CONVITE_ENVIADO_O_RIVAL_DEVE_TOCAR_DESAFIAR_NO_S_D712DA)
	end
	invitations[reverse] = nil
	invitations[key] = nil
	if lastDuel[p] and os.clock() - lastDuel[p] < 30 then
		return fail(Text.SUAS_FERAS_DESCANSAM_6D6F29 .. math.ceil(30 - (os.clock() - lastDuel[p])) .. "s")
	end
	lastDuel[p] = os.clock()
	local a, b = best(d), best(td)
	local log, win = sim(C.ById[a.id], a.lv, C.ById[b.id], b.lv)
	local info = { log = log, me = { id = a.id, lv = a.lv }, foe = { id = b.id, lv = b.lv }, win = win }
	if not win then
		local r = ok(p, Text.DERROTA_PARA_F29D4F .. t.DisplayName .. Text.TREINE_E_TENTE_DE_NOVO_F77824)
		r.battle = info
		return r
	end
	local gold = 40 + 5 * b.lv
	d.gold += gold
	d.trophies += 1
	bump(d, "duelwin")
	local r = ok(p, Text.VITORIA_CONTRA_F35782 .. t.DisplayName .. "! +" .. gold .. Text.OURO_1_TROFEU_AC2EBF)
	r.battle = info
	return r
end
function A.Tut(p)
	Data.get(p).tut = true
	return ok(p, Text.TUTORIAL_CONCLUIDO_EE21ED)
end
return G
