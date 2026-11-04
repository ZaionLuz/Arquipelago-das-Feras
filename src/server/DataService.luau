--!nonstrict
local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local DSS = game:GetService("DataStoreService")
local RS = game:GetService("ReplicatedStorage")
local C = require(RS.Shared.Creatures)
local I = require(RS.Shared.Islands)
local M = require(RS.Shared.Missions)
local SR = require(RS.Shared.SanctuaryRules)
local Story = require(RS.Shared.Story)
local Migration = require(RS.Shared.Migration)
local Quest = require(RS.Shared.PhoenixQuest)
local Access = require(RS.Shared.Access)
local Grant = require(RS.Shared.CreatureGrant)
local CaptureRules = require(RS.Shared.CaptureRules)
local store = DSS:GetDataStore("ArquipelagoV1")
local D = {}
local profiles = {}
local VERSION = require(RS.Shared.Config).ProfileVersion
local sessions = {}
local Http = game:GetService("HttpService")
local LEASE = 180
local function clone(t)
	local out = {}
	for k, v in t do
		out[k] = typeof(v) == "table" and clone(v) or v
	end
	return out
end
local function default()
	local result = {
		v = VERSION,
		gold = 100,
		gems = 5,
		seals = 5,
		playerLevel = 1,
		playerXp = 0,
		sealStock = {},
		companion = nil,
		storyClaimed = {},
		guardians = {},
		visited = {},
		materials = {},
		gatherAt = {},
		sanctuary = { Alvorecer = { slot = 5, level = 1 } },
		nextId = 1,
		last = os.time(),
		wins = 0,
		creatures = {},
		eggs = {},
		stats = {},
		claimed = {},
		pass = {},
		receipts = {},
		dailyDay = 0,
		streak = 0,
		trophies = 0,
		tut = false,
		habitat = { Alvorecer = { "u1", "u2" } },
		unlocked = { Alvorecer = true },
		legacyGrandfathered = {},
		grants = {},
		phoenix = { glyphs = {}, sanctuaryOpen = false, attempts = 0, nextAttemptAt = 0, captured = false },
		legacyEggPermits = {},
		discovered = {},
	}
	assert(Grant.grant(result, "brotinho", "starter", "starter:1"))
	assert(Grant.grant(result, "folhuco", "starter", "starter:2"))
	return result
end
-- Registro corrompido é recusado. Nunca substituir um perfil real por padrões.
function D.validate(raw)
	if raw ~= nil then
		local migrated, reason = Migration.run(raw)
		assert(migrated, reason)
		raw = migrated
	end
	local d = default()
	if raw == nil then
		return d
	end
	local seeds = d
	d = clone(raw)
	for key, value in seeds do
		if d[key] == nil then
			d[key] = value
		end
	end
	local function num(x, f, _mx)
		return (typeof(x) == "number" and x == x and x >= 0 and x < math.huge) and math.floor(x) or f
	end
	d.seals = num(raw.seals, 5, 10000)
	d.sealStock = clone(raw.sealStock or {})
	for kind in CaptureRules.Seals do
		if kind ~= "Basic" and typeof(raw.sealStock) == "table" then
			d.sealStock[kind] = num(raw.sealStock[kind], 0, 10000)
		end
	end
	d.gold = num(raw.gold, d.gold, 1e12)
	d.gems = num(raw.gems, d.gems, 1e9)
	d.wins = num(raw.wins, 0, 1e9)
	d.nextId = num(raw.nextId, d.nextId, 1e9)
	d.legacyGrandfathered = Migration.clone(raw.legacyGrandfathered or {})
	d.grants = Migration.clone(raw.grants or {})
	d.legacyEggPermits = Migration.clone(raw.legacyEggPermits or {})
	d.phoenix = Migration.clone(raw.phoenix or d.phoenix)
	d.last = num(raw.last, os.time(), 1e12)
	local cr, n = {}, 0
	for uid, c in raw.creatures do
		if typeof(uid) == "string" and typeof(c) == "table" and C.ById[c.id] then
			cr[uid] = clone(c)
			cr[uid].lv = math.max(num(c.lv, 1, 100), 1)
			cr[uid].xp = num(c.xp, 0, 1e9)
			n += 1
		end
	end
	assert(n > 0, "CORRUPT_PROFILE")
	for uid in cr do
		local uidNumber = tonumber(string.match(uid, "^u(%d+)$"))
		if uidNumber then
			d.nextId = math.max(d.nextId, uidNumber + 1)
		end
	end
	d.creatures = cr
	d.discovered = clone(raw.discovered or {})
	for _, c in cr do
		d.discovered[c.id] = true
	end
	if typeof(raw.discovered) == "table" then
		for id in raw.discovered do
			if C.ById[id] then
				d.discovered[id] = true
			end
		end
	end
	d.unlocked = clone(raw.unlocked or {})
	d.unlocked.Alvorecer = true
	if typeof(raw.unlocked) == "table" then
		for id in I.ById do
			if raw.unlocked[id] == true then
				d.unlocked[id] = true
			end
		end
	end
	d.playerLevel = math.max(num(raw.playerLevel, 1, 100), 1)
	d.playerXp = num(raw.playerXp, 0, 1e9)
	d.companion = typeof(raw.companion) == "string" and cr[raw.companion] and raw.companion or nil
	d.guardians = clone(raw.guardians or {})
	d.visited = clone(raw.visited or {})
	d.materials = clone(raw.materials or {})
	d.gatherAt = clone(raw.gatherAt or {})
	for _, def in I.List do
		if typeof(raw.guardians) == "table" and raw.guardians[def.id] == true then
			d.guardians[def.id] = true
		end
		if typeof(raw.visited) == "table" and raw.visited[def.id] == true then
			d.visited[def.id] = true
		end
		if typeof(raw.gatherAt) == "table" then
			d.gatherAt[def.id] = num(raw.gatherAt[def.id], 0, 1e12)
		end
		if typeof(raw.materials) == "table" then
			d.materials[def.el] = num(raw.materials[def.el], 0, 10000)
		end
	end
	d.storyClaimed = clone(raw.storyClaimed or {})
	if typeof(raw.storyClaimed) == "table" then
		for id, claimed in raw.storyClaimed do
			if claimed == true and Story.ById[id] then
				d.storyClaimed[id] = true
			end
		end
	end
	if typeof(raw.sanctuary) == "table" then
		d.sanctuary = clone(raw.sanctuary)
	else -- Migração: habitats legados recebem posição própria; nenhuma criatura é removida.
		d.sanctuary = {}
		local slot = 0
		for _, def in I.List do
			if d.unlocked[def.id] then
				slot += 1
				d.sanctuary[def.id] = { slot = slot, level = 1 }
			end
		end
	end
	d.habitat = {}
	local seen = {}
	if typeof(raw.habitat) == "table" then
		for isl, list in raw.habitat do
			local def = I.ById[isl]
			if def and d.unlocked[isl] and typeof(list) == "table" then
				d.habitat[isl] = {}
				for _, uid in list do
					if typeof(uid) == "string" and cr[uid] and not seen[uid] then
						seen[uid] = true
						table.insert(d.habitat[isl], uid)
					end
				end
			end
		end
	end
	for id, list in d.habitat do
		if #list > 0 and not d.sanctuary[id] then
			for slot = 1, 9 do
				if SR.available(d.sanctuary, slot) then
					d.sanctuary[id] = { slot = slot, level = 1 }
					break
				end
			end
		end
	end
	d.stats = {}
	d.claimed = clone(raw.claimed or {})
	if typeof(raw.stats) == "table" then
		for k, v in raw.stats do
			if typeof(k) == "string" then
				d.stats[k] = num(v, 0, 1e9)
			end
		end
	end
	if typeof(raw.claimed) == "table" then
		for id, value in raw.claimed do
			if value == true and M.ById[id] then
				d.claimed[id] = true
			end
		end
	end
	d.trophies = num(raw.trophies, 0, 1e9)
	d.tut = raw.tut == true
	d.receipts = {}
	d.pass = {}
	d.dailyDay = num(raw.dailyDay, 0, 1e9)
	d.streak = num(raw.streak, 0, 1e6)
	if typeof(raw.receipts) == "table" then
		for k, value in raw.receipts do
			if value == true and typeof(k) == "string" then
				d.receipts[k] = true
			end
		end
	end
	d.eggs = {}
	if typeof(raw.eggs) == "table" then
		for _, e in raw.eggs do
			if
				typeof(e) == "table"
				and C.ById[e.id]
				and typeof(e.ready) == "number"
				and e.ready == e.ready
				and e.ready >= 0
				and e.ready < math.huge
			then
				table.insert(d.eggs, clone(e))
			end
		end
	end
	return d
end
-- Lease gravado atomicamente no MESMO registro legado (sem trocar a chave).
function D.load(p)
	local token = Http:GenerateGUID(false)
	local raw, ok
	for attempt = 1, 3 do
		ok, raw = pcall(function()
			return store:UpdateAsync("P" .. p.UserId, function(old)
				if
					old ~= nil
					and (typeof(old) ~= "table" or typeof(old.creatures) ~= "table" or (old.v or 1) > VERSION)
				then
					error(Text.PERFIL_INVALIDO_OU_VERSAO_FUTURA_RECUPERACAO_MAN_C36F9F)
				end
				local lock = old and old._session
				if lock and typeof(lock) ~= "table" then
					error(Text.LEASE_INVALIDO_1F2C7F)
				end
				if lock and lock.token ~= token and (lock.expires or 0) > os.time() then
					return nil
				end
				local migrated
				if old ~= nil then
					local reason
					migrated, reason = Migration.run(old)
					if not migrated then
						error(reason)
					end
				end
				local data = old == nil and default() or D.validate(migrated)
				data._session = { token = token, expires = os.time() + LEASE }
				return data
			end)
		end)
		if ok then
			break
		end
		task.wait(attempt)
	end
	if not ok or not raw then
		p:Kick(Text.DADOS_INDISPONIVEIS_OU_SESSAO_AINDA_ATIVA_AGUARD_97BBDC)
		return false
	end
	profiles[p] = D.validate(raw)
	-- Uma sessão recuperada nunca retoma um encontro do processo anterior.
	profiles[p].phoenix.encounterId = nil
	sessions[p] =
		{ token = token, expires = raw._session.expires, busy = false, region = "Alvorecer", lastSafe = "Alvorecer" }
	return true
end
function D.session(p)
	return sessions[p]
end
function D.get(p)
	local session = sessions[p]
	if not session or session.expires <= os.time() or session.closing then
		return nil
	end
	return profiles[p]
end
function D.snapshot(p)
	local d = clone(profiles[p])
	d.receipts = nil
	d.grants = nil
	d.legacyEggPermits = nil
	d.phoenix = nil
	d.quest = Quest.public(profiles[p])
	d.region = sessions[p] and sessions[p].region or "Alvorecer"
	d.access = {}
	for _, island in I.List do
		local check = Access.check(profiles[p], island.id, "travel")
		local unlock = Access.check(profiles[p], island.id, "unlock")
		d.access[island.id] = { ok = check.ok, reason = check.reason, unlockReason = unlock.reason }
	end
	for _, e in d.eggs do
		e.left = math.max(0, e.ready - os.time())
	end
	local el, left = M.event(os.time())
	d.event = { el = el, left = left }
	return d
end
function D.save(p, release)
	local session = sessions[p]
	local d = profiles[p]
	if not session or not d then
		return false
	end
	while session.busy do
		task.wait()
	end
	if sessions[p] ~= session then
		return false
	end
	session.busy = true
	local payload = clone(d)
	payload.pass = nil
	payload.event = nil
	for _, egg in payload.eggs do
		egg.left = nil
	end
	local expiry = os.time() + LEASE
	payload._session = not release and { token = session.token, expires = expiry } or nil
	local ok, result = pcall(function()
		return store:UpdateAsync("P" .. p.UserId, function(old)
			if not old or not old._session or old._session.token ~= session.token then
				return nil
			end
			return payload
		end)
	end)
	session.busy = false
	if ok and result then
		session.expires = expiry
		return true
	end
	warn(Text.FALHA_AO_SALVAR_PERFIL_DE_B99672 .. p.Name)
	if ok or os.time() >= session.expires then
		session.closing = true
		p:Kick(Text.SESSAO_DE_DADOS_ENCERRADA_RECONECTE_PARA_PROTEGE_C94A14)
	end
	return false
end
function D.release(p)
	local session = sessions[p]
	if not session then
		return
	end
	session.closing = true
	for _ = 1, 3 do
		if D.save(p, true) then
			break
		end
		task.wait(1)
	end
	profiles[p] = nil
	sessions[p] = nil
end
function D.saveAll()
	for p in profiles do
		D.save(p)
	end
end
function D.closeAll()
	local pending = 0
	for p in profiles do
		pending += 1
		task.spawn(function()
			D.release(p)
			pending -= 1
		end)
	end
	local deadline = os.clock() + 25
	while pending > 0 and os.clock() < deadline do
		task.wait(0.1)
	end
end
return D
