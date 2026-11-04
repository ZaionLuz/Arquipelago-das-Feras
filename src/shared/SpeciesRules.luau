--!nonstrict
local C = require(script.Parent.Creatures)
local S = { SpecialId = "fenix" }
function S.isGeneral(id)
	return typeof(id) == "string" and C.ById[id] ~= nil and C.ById[id].acquisition ~= "special"
end
function S.get(id)
	return typeof(id) == "string" and C.ById[id] or nil
end
return S
