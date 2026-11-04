--!nonstrict
local Bands = require(script.Parent.LevelBands)
local Config = require(script.Parent.Config)
local A = {}
local purposes = {
	travel = true,
	encounter = true,
	capture = true,
	battle = true,
	hatch = true,
	shop = true,
	habitat = true,
	sanctuary = true,
	unlock = true,
}
function A.check(profile, id, purpose)
	if typeof(profile) ~= "table" or typeof(id) ~= "string" or not Bands.ById[id] or not purposes[purpose] then
		return { ok = false, reason = "UNKNOWN_ISLAND" }
	end
	local level = profile.playerLevel or 1
	if typeof(level) ~= "number" or level ~= level or level < 1 or level == math.huge then
		return { ok = false, reason = "LOCKED_LEVEL" }
	end
	local band = Bands.ById[id]
	local unlocked = profile.unlocked and profile.unlocked[id] == true
	local grandfathered = unlocked and profile.legacyGrandfathered and profile.legacyGrandfathered[id] == true
	if purpose ~= "unlock" and not unlocked then
		return { ok = false, reason = "NOT_UNLOCKED" }
	end
	if Config.V7.EnforceIslandLevels and not grandfathered and level < band.min then
		return { ok = false, reason = "LOCKED_LEVEL" }
	end
	if purpose == "unlock" then
		if band.previous and not (profile.unlocked and profile.unlocked[band.previous]) then
			return { ok = false, reason = "LOCKED_PREV" }
		end
		if
			Config.V7.RequireGuardian
			and band.previous
			and not (profile.guardians and profile.guardians[band.previous])
		then
			return { ok = false, reason = "LOCKED_GUARDIAN" }
		end
		if (profile.gold or 0) < band.cost then
			return { ok = false, reason = "LOCKED_GOLD" }
		end
	end
	return { ok = true, reason = grandfathered and "LEGACY" or "OK" }
end
return A
