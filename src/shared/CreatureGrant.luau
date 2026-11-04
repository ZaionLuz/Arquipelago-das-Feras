--!nonstrict
local Species = require(script.Parent.SpeciesRules)
local Config = require(script.Parent.Config)
local G = {}
function G.grant(profile, id, origin, nonce, options)
	options = options or {}
	local def = Species.get(id)
	if not def or typeof(nonce) ~= "string" or #nonce == 0 or #nonce > 100 or typeof(origin) ~= "string" then
		return nil, "INVALID_GRANT"
	end
	profile.grants = profile.grants or {}
	if profile.grants[nonce] then
		local uid = profile.grants[nonce]
		if not profile.creatures[uid] or profile.creatures[uid].id ~= id then
			return nil, "NONCE_CONFLICT"
		end
		return uid, "REPLAY"
	end
	local legacy = origin == "legacy_egg" and profile.legacyEggPermits and profile.legacyEggPermits[nonce] == id
	if not Species.isGeneral(id) and not legacy then
		if origin ~= "phoenix_sanctuary" or not profile.phoenix or profile.phoenix.encounterId ~= nonce then
			return nil, "SPECIAL_SOURCE"
		end
		local owned = 0
		for _, c in profile.creatures do
			if c.id == id then
				owned += 1
			end
		end
		if
			owned >= Config.PhoenixMaxPerAccount
			or (profile.phoenix.captureCount or (profile.phoenix.captured and 1 or 0))
				>= Config.PhoenixMaxPerAccount
		then
			return nil, "SPECIAL_LIMIT"
		end
	end
	local count = 0
	for _ in profile.creatures do
		count += 1
	end
	if count >= 60 then
		return nil, "INVENTORY_FULL"
	end
	profile.nextId = math.max(profile.nextId or 1, 1)
	while profile.creatures["u" .. profile.nextId] do
		profile.nextId += 1
	end
	local uid = "u" .. profile.nextId
	profile.nextId += 1
	profile.creatures[uid] = { id = id, lv = math.clamp(math.floor(options.level or 1), 1, 100), xp = 0 }
	profile.discovered = profile.discovered or {}
	profile.discovered[id] = true
	profile.grants[nonce] = uid
	if not Species.isGeneral(id) then
		profile.phoenix.captured = true
		profile.phoenix.captureCount = (profile.phoenix.captureCount or 0) + 1
		profile.phoenix.encounterId = nil
	end
	if legacy then
		profile.legacyEggPermits[nonce] = nil
	end
	return uid, "GRANTED"
end
return G
