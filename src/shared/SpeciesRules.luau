--!nonstrict
local C = require(script.Parent.Creatures)
local S = { SpecialId = "fenix" }
function S.isGeneral(id)
	return typeof(id) == "string" and C.ById[id] ~= nil and C.ById[id].acquisition ~= "special"
end
function S.isBreedable(value)
	local def
	if typeof(value) == "string" then
		def = C.ById[value]
	elseif typeof(value) == "table" then
		def = value
	else
		return false
	end
	return typeof(def) == "table" and typeof(def.id) == "string" and C.ById[def.id] == def and def.breedable ~= false
end
function S.get(id)
	return typeof(id) == "string" and C.ById[id] or nil
end
return S
