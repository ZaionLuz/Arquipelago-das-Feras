--!nonstrict
local Data = require(script.Parent.DataService)
local S = {}
function S.sync(player)
	local d = Data.get(player)
	local pet = d and d.companion and d.creatures[d.companion]
	player:SetAttribute("CompanionSpecies", pet and pet.id or nil)
	player:SetAttribute("CompanionLevel", pet and pet.lv or nil)
	player:SetAttribute("CompanionUid", pet and d.companion or nil)
end
return S
