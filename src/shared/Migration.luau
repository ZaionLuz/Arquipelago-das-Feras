--!nonstrict
-- Sem serviços. Só acrescenta campos: a sanitização de entrada continua no DataService.
local Config = require(script.Parent.Config)
local C = require(script.Parent.Creatures)
local Bands = require(script.Parent.LevelBands)
local M = {}
function M.clone(value)
	if type(value) ~= "table" then
		return value
	end
	local out = {}
	for k, v in value do
		out[k] = M.clone(v)
	end
	return out
end
function M.run(raw)
	if typeof(raw) ~= "table" or typeof(raw.creatures) ~= "table" or next(raw.creatures) == nil then
		return nil, "CORRUPT_PROFILE"
	end
	if typeof(raw.v) ~= "number" or raw.v % 1 ~= 0 or raw.v < 1 or raw.v > Config.ProfileVersion then
		return nil, "FUTURE_OR_INVALID_VERSION"
	end
	-- Recusa o registro inteiro antes de qualquer escrita se uma estrutura essencial estiver inválida.
	for _, key in
		{
			"unlocked",
			"eggs",
			"habitat",
			"sanctuary",
			"stats",
			"claimed",
			"phoenix",
			"grants",
			"legacyEggPermits",
			"legacyGrandfathered",
		}
	do
		if raw[key] ~= nil and type(raw[key]) ~= "table" then
			return nil, "CORRUPT_" .. key
		end
	end
	for uid, pet in raw.creatures do
		if
			type(uid) ~= "string"
			or type(pet) ~= "table"
			or not C.ById[pet.id]
			or type(pet.lv) ~= "number"
			or pet.lv ~= pet.lv
			or pet.lv < 1
			or pet.lv == math.huge
		then
			return nil, "CORRUPT_CREATURE"
		end
	end
	for _, egg in raw.eggs or {} do
		if
			type(egg) ~= "table"
			or not C.ById[egg.id]
			or type(egg.ready) ~= "number"
			or egg.ready ~= egg.ready
			or egg.ready < 0
			or egg.ready == math.huge
		then
			return nil, "CORRUPT_EGG"
		end
	end
	local function number(value, minimum)
		return value == nil
			or (
				type(value) == "number"
				and value == value
				and value >= minimum
				and value < math.huge
				and value % 1 == 0
			)
	end
	for _, key in { "gold", "gems", "seals", "playerXp", "nextId", "last", "wins", "dailyDay", "streak", "trophies" } do
		if not number(raw[key], 0) then
			return nil, "CORRUPT_NUMBER:" .. key
		end
	end
	if not number(raw.playerLevel, 1) then
		return nil, "CORRUPT_LEVEL"
	end
	for _, pet in raw.creatures do
		if not number(pet.lv, 1) or not number(pet.xp, 0) then
			return nil, "CORRUPT_CREATURE_NUMBER"
		end
	end
	for _, values in { raw.stats or {}, raw.materials or {}, raw.sealStock or {} } do
		if type(values) ~= "table" then
			return nil, "CORRUPT_COUNTERS"
		end
		for _, value in values do
			if not number(value, 0) then
				return nil, "CORRUPT_COUNTER"
			end
		end
	end
	if raw.phoenix and not number(raw.phoenix.captureCount, 0) then
		return nil, "CORRUPT_CAPTURE_COUNT"
	end

	for _, key in
		{
			"discovered",
			"guardians",
			"visited",
			"storyClaimed",
			"legacyGrandfathered",
			"gatherAt",
			"sealStock",
			"materials",
		}
	do
		if raw[key] ~= nil and type(raw[key]) ~= "table" then
			return nil, "CORRUPT_MAP:" .. key
		end
	end
	for _, key in { "unlocked", "discovered", "guardians", "visited", "claimed", "storyClaimed", "legacyGrandfathered" } do
		for _, value in raw[key] or {} do
			if type(value) ~= "boolean" then
				return nil, "CORRUPT_FLAG:" .. key
			end
		end
	end
	for id, entry in raw.sanctuary or {} do
		if
			not Bands.ById[id]
			or type(entry) ~= "table"
			or not number(entry.slot, 1)
			or not entry.slot
			or entry.slot > 9
			or not number(entry.level, 1)
			or not entry.level
		then
			return nil, "CORRUPT_HABITAT_STRUCTURE"
		end
	end
	local assigned = {}
	for id, list in raw.habitat or {} do
		if not Bands.ById[id] or type(list) ~= "table" then
			return nil, "CORRUPT_HABITAT"
		end
		for _, uid in list do
			if type(uid) ~= "string" or not raw.creatures[uid] or assigned[uid] then
				return nil, "CORRUPT_HABITAT_UID"
			end
			assigned[uid] = true
		end
	end
	for _, egg in raw.eggs or {} do
		if
			not number(egg.ready, 0)
			or (egg.region ~= nil and not Bands.ById[egg.region])
			or (egg.nonce ~= nil and type(egg.nonce) ~= "string")
		then
			return nil, "CORRUPT_EGG_FIELDS"
		end
	end
	if raw.phoenix then
		for _, key in { "captured", "sanctuaryOpen" } do
			if raw.phoenix[key] ~= nil and type(raw.phoenix[key]) ~= "boolean" then
				return nil, "CORRUPT_PHOENIX_FLAG"
			end
		end
	end
	local d = M.clone(raw)
	local old = d.v
	d.legacyGrandfathered = d.legacyGrandfathered or {}
	if old < 5 then
		for id, value in d.unlocked or {} do
			if value == true then
				d.legacyGrandfathered[id] = true
			end
		end
	end
	d.phoenix = d.phoenix or { glyphs = {}, sanctuaryOpen = false, attempts = 0, nextAttemptAt = 0, captured = false }
	d.grants = d.grants or {}
	d.legacyEggPermits = d.legacyEggPermits or {}
	for i, egg in d.eggs or {} do
		egg.nonce = egg.nonce or ("legacy:" .. tostring(egg.id) .. ":" .. tostring(egg.ready) .. ":" .. i)
		egg.region = egg.region or "Alvorecer"
		if old < 5 and egg.id == "fenix" then
			d.legacyEggPermits[egg.nonce] = egg.id
		end
	end
	for key, value in { glyphs = {}, sanctuaryOpen = false, attempts = 0, nextAttemptAt = 0, captured = false } do
		if d.phoenix[key] == nil then
			d.phoenix[key] = value
		end
	end
	if type(d.phoenix.glyphs) ~= "table" then
		return nil, "CORRUPT_GLYPHS"
	end
	for _, key in { "attempts", "nextAttemptAt" } do
		local value = d.phoenix[key]
		if type(value) ~= "number" or value ~= value or value < 0 or value == math.huge then
			return nil, "CORRUPT_PHOENIX"
		end
	end
	local existing = 0
	for _, pet in d.creatures do
		if pet.id == "fenix" then
			existing += 1
		end
	end
	d.phoenix.captureCount = math.max(d.phoenix.captureCount or (d.phoenix.captured and 1 or 0), existing)
	if existing > 0 then
		d.phoenix.captured = true
	end

	if d.navigation ~= nil and type(d.navigation) ~= "table" then
		return nil, "CORRUPT_NAVIGATION"
	end
	if not d.navigation then
		local visited = { Alvorecer = true }
		for id, value in d.visited or {} do
			if Bands.ById[id] and value == true then
				visited[id] = true
			end
		end
		d.navigation = { visited = visited, checkpoint = "Alvorecer" }
	end
	if type(d.navigation.visited) ~= "table" or not Bands.ById[d.navigation.checkpoint] then
		return nil, "CORRUPT_NAVIGATION"
	end
	for id, value in d.navigation.visited do
		if not Bands.ById[id] or type(value) ~= "boolean" then
			return nil, "CORRUPT_NAVIGATION"
		end
	end
	if d.sanctuary == nil then
		d.sanctuary = {}
		local slot = 0
		for _, id in Bands.Order do
			if (d.unlocked and d.unlocked[id]) or #(d.habitat and d.habitat[id] or {}) > 0 then
				slot += 1
				d.sanctuary[id] = { slot = slot, level = 1 }
			end
		end
	end
	if Config.World.FreeExploration then
		d.unlocked = d.unlocked or {}
		for _, id in Bands.Order do
			d.unlocked[id] = true
		end
	end
	d.v = Config.ProfileVersion
	return d
end
return M
