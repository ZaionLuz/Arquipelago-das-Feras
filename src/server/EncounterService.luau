--!nonstrict
local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local Data = require(script.Parent.DataService)
local C = require(RS.Shared.Creatures)
local Rules = require(RS.Shared.CombatRules)
local CaptureRules = require(RS.Shared.CaptureRules)
local Progression = require(RS.Shared.Progression)
local Grant = require(RS.Shared.CreatureGrant)
local Quest = require(RS.Shared.PhoenixQuest)
local Config = require(RS.Shared.Config)
local Region = require(script.Parent.RegionService)
local Species = require(RS.Shared.SpeciesRules)
local E = {}
local opening = {}
local sessions = {}
local rng = Random.new()
local net
local events
local function snapshot(session, message)
	local s = session.state
	local party = {}
	for uid, p in s.party do
		party[uid] = { id = p.id, lv = p.lv, hp = p.hp, maxHp = p.maxHp, nextSkill = p.nextSkill }
	end
	return {
		token = session.token,
		seals = session.seals,
		sealType = session.sealType or "Basic",
		sealStock = session.sealStock or {},
		version = s.version,
		status = s.status,
		capturable = s.capturable ~= false,
		turn = s.turn,
		foe = s.foe,
		party = party,
		active = s.active,
		bond = s.bond,
		chance = Rules.chance(s),
		log = s.log,
		message = message,
		expires = session.expires,
		intro = session.special and "phoenix" or nil,
	}
end
local function finish(player, session)
	if session.released then
		return
	end
	session.released = true
	local d = Data.get(player)
	local s = session.state
	if d and s.status == "captured" then
		local origin = session.special and "phoenix_sanctuary" or "wild_capture"
		local uid, reason = Grant.grant(d, s.foe.id, origin, session.token, { level = s.foe.lv })
		if uid then
			d.stats.capture = (d.stats.capture or 0) + 1
			local pet = s.active and d.creatures[s.active]
			local reward =
				Progression.rewards(session.region, s.foe.lv, C.ById[s.foe.id].rar, pet and pet.lv or s.foe.lv)
			Progression.award(d, math.floor(reward.xp * 0.6))
		else
			s.status = "escaped"
			table.insert(s.log, { text = Text.CONCESSAO_RECUSADA_951368 .. reason, kind = "error" })
		end
	elseif d and s.status == "won" then
		local def = C.ById[s.foe.id]
		local teamLevel = 0
		for uid in s.party do
			local pet = d.creatures[uid]
			if pet then
				teamLevel = math.max(teamLevel, pet.lv)
			end
		end
		local reward = Progression.rewards(session.region, s.foe.lv, def.rar, teamLevel)
		d.gold += reward.gold
		d.wins += 1
		d.stats.win = (d.stats.win or 0) + 1
		Progression.award(d, reward.xp)
		local pet = d.creatures[s.active]
		if pet then
			Progression.awardCreature(pet, reward.creatureXp)
			local refreshed, err = pcall(require(script.Parent.World).refresh, player)
			if not refreshed then
				warn(Text.MODELO_SERA_RECONSTRUIDO_NA_PROXIMA_ATUALIZACAO_BF3624 .. tostring(err))
			end
		end
		table.insert(s.log, {
			text = "Recompensa: "
				.. reward.gold
				.. " ouro · "
				.. reward.xp
				.. " XP · "
				.. reward.creatureXp
				.. Text.XP_DA_FERA_1A37A2,
			kind = "reward",
		})
	end
	if d and s.status == "won" and session.guardian and not d.guardians[session.guardian] then
		d.guardians[session.guardian] = true
		d.stats.guardian = (d.stats.guardian or 0) + 1
		d.gold += 100
		Progression.award(d, 200)
	end
	if session.special and d then
		d.phoenix.encounterId = nil
		d.phoenix.nextAttemptAt = math.max(d.phoenix.nextAttemptAt or 0, os.time() + Config.PhoenixRetrySeconds)
		local saved = Data.save(player)
		if not saved then
			table.insert(s.log, { text = Text.SALVAMENTO_PENDENTE_AGUARDE_ANTES_DE_SAIR_5F0A13, kind = "error" })
		end
	end
	session.release(s.status == "captured" or s.status == "won")
end
function E.open(player, specimen, release)
	local d = Data.get(player)
	if not d then
		return false
	end
	if opening[player] and not specimen.special then
		return false
	end
	if not specimen.special and not Species.isGeneral(specimen.id) then
		return false
	end
	local region = specimen.region or Region.current(player, "encounter")
	if not Region.requireCurrent(player, region, "encounter").ok then
		return false
	end
	local old = sessions[player]
	if old and old.state.status == "active" then
		return false
	end
	local session = {
		token = specimen.nonce or Http:GenerateGUID(false),
		region = region,
		special = specimen.special == true,
		state = Rules.new(
			specimen.id,
			specimen.lv,
			{ statMultiplier = specimen.statMultiplier, isLegendary = specimen.special }
		),
		guardian = specimen.guardianId,
		seals = d.seals,
		origin = specimen.position,
		expires = os.time() + 150,
		release = release,
	}
	session.state.capturable = specimen.capturable ~= false
	session.state.isLegendary = session.special
	session.state.captureBase = specimen.captureBase
	session.sealType = "Basic"
	session.sealStock = d.sealStock or {}
	d.stats.fight = (d.stats.fight or 0) + 1
	sessions[player] = session
	events:FireClient(player, snapshot(session))
	return true
end
function E.startSpecial(player, id)
	if id ~= "phoenix_solar" or E.active(player) then
		return false, "ACTIVE_OR_INVALID"
	end
	local d = Data.get(player)
	local ok, reason = Quest.check(d or {}, os.time())
	if not ok then
		return false, reason
	end
	if not Region.requireCurrent(player, "Dunas", "encounter").ok then
		return false, "WRONG_REGION"
	end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local altar = require(script.Parent.SanctuaryBuilder).altarPosition()
	if not root or (root.Position - altar).Magnitude > 15 then
		return false, "DISTANCE"
	end
	opening[player] = true
	local nonce = Http:GenerateGUID(false)
	d.phoenix.encounterId = nonce
	d.phoenix.attempts += 1
	d.phoenix.nextAttemptAt = os.time() + Config.PhoenixRetrySeconds
	local saved = Data.save(player)
	if not saved or not Data.get(player) then
		d.phoenix.encounterId = nil
		opening[player] = nil
		return false, "SAVE_FAILED"
	end
	local opened = E.open(player, {
		id = Species.SpecialId,
		lv = 60,
		region = "Dunas",
		position = altar,
		special = true,
		nonce = nonce,
		captureBase = 0.04,
		statMultiplier = 1.3,
	}, function()
		player:SetAttribute("SolarEncounterEnded", os.time())
	end)
	opening[player] = nil
	if not opened then
		d.phoenix.encounterId = nil
	end
	return opened, opened and "OK" or "INTERRUPTED"
end
function E.active(player)
	if opening[player] then
		return true
	end
	local s = sessions[player]
	return s and s.state.status == "active"
end
function E.start()
	net = Instance.new("RemoteFunction")
	net.Name = "EncounterNet"
	net.Parent = RS
	events = Instance.new("RemoteEvent")
	events.Name = "EncounterNotice"
	events.Parent = RS
	net.OnServerInvoke = function(player, token, version, action, uid)
		local session = sessions[player]
		local d = Data.get(player)
		if not session or not d then
			return nil
		end
		-- Recuperação da própria sessão caso o evento inicial chegue antes da UI.
		if action == "Resume" then
			if session.readAt and os.clock() - session.readAt < 0.1 then
				return nil
			end
			session.readAt = os.clock()
			return snapshot(session)
		end
		if typeof(token) ~= "string" or #token > 80 or token ~= session.token then
			return nil
		end
		if typeof(action) ~= "string" or #action > 16 or (uid ~= nil and (typeof(uid) ~= "string" or #uid > 40)) then
			return snapshot(session, Text.PEDIDO_INVALIDO_C2C28F)
		end
		if action == "State" then
			if session.readAt and os.clock() - session.readAt < 0.1 then
				return nil
			end
			session.readAt = os.clock()
			return snapshot(session)
		end
		if session.state.status ~= "active" then
			return snapshot(session)
		end
		if not Region.requireCurrent(player, session.region, action == "Capture" and "capture" or "battle").ok then
			session.state.status = "escaped"
			finish(player, session)
			return snapshot(session, "REGION_ACCESS_DENIED")
		end
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if
			os.time() >= session.expires
			or not root
			or not humanoid
			or humanoid.Health <= 0
			or (root.Position - session.origin).Magnitude > 40
		then
			session.state.status = "escaped"
			finish(player, session)
			return snapshot(session, Text.O_ENCONTRO_ENCERROU_DISTANCIA_TEMPO_OU_PERSONAGE_9012D6)
		end
		if typeof(version) ~= "number" or version ~= session.state.version then
			return snapshot(session, Text.ESTADO_ATUALIZADO_ESCOLHA_NOVAMENTE_CD8857)
		end
		if session.last and os.clock() - session.last < 0.25 then
			return snapshot(session, Text.AGUARDE_O_TURNO_25CBEF)
		end
		session.last = os.clock()
		if action == "ChooseSeal" then
			local seal = CaptureRules.Seals[uid]
			if not seal then
				return snapshot(session, Text.SELO_INVALIDO_51B2D9)
			end
			session.sealType = uid
			session.state.sealKind = uid
			session.state.version += 1
			session.state.log = {}
			session.seals = uid == "Basic" and d.seals or (d.sealStock or {})[uid] or 0
			return snapshot(session)
		end
		local pet = uid and d.creatures[uid]
		local count = 0
		for _ in d.creatures do
			count += 1
		end
		local ok, message = Rules.step(
			session.state,
			action,
			pet and { uid = uid, id = pet.id, lv = pet.lv },
			rng,
			session.seals,
			count < 60
		)
		if not ok then
			return snapshot(session, message)
		end
		if session.state.spentSeal then
			if session.sealType == "Basic" then
				d.seals -= 1
			else
				d.sealStock[session.sealType] -= 1
			end
		end
		session.seals = session.sealType == "Basic" and d.seals or (d.sealStock or {})[session.sealType] or 0
		if session.special and session.state.status == "active" then
			local stock = d.seals
			for _, n in d.sealStock or {} do
				stock += n
			end
			if stock <= 0 and action == "Capture" then
				session.state.status = "escaped"
				table.insert(
					session.state.log,
					{ text = Text.OS_SELOS_SE_ESGOTARAM_A_CHAMA_REPOUSARA_POR_VINT_B19B32, kind = "info" }
				)
			end
		end
		if session.state.status ~= "active" then
			finish(player, session)
		end
		return snapshot(session)
	end
	Players.PlayerRemoving:Connect(function(player)
		local s = sessions[player]
		if s then
			s.state.status = "escaped"
			finish(player, s)
		end
		sessions[player] = nil
	end)
	task.spawn(function()
		while true do
			task.wait(2)
			for player, s in sessions do
				if s.state.status == "active" and (os.time() >= s.expires or not Data.get(player)) then
					s.state.status = "escaped"
					finish(player, s)
					events:FireClient(player, snapshot(s, Text.O_ENCONTRO_TERMINOU_6F159C))
				end
			end
		end
	end)
end
return E
