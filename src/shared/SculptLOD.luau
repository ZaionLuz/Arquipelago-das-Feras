--!nonstrict
-- Retira apenas ornamentos. Todo ancestral de um volume essencial permanece no rig.
local L = {}
local function decorative(part)
	local name = part.Name
	if name:find("EyeGlintSmall") or name:match("^Iris[LR]") then
		return true
	end
	local index = tonumber(name:match("(%d+)$")) or 1
	if name:find("FeatherMiddle") or name:find("FeatherInner") or name:find("WingCover") then
		return index % 2 == 0
	end
	if name:find("HaloRay") then
		return index % 4 ~= 0
	end
	if name:find("Toe") then
		return index ~= 1
	end
	for _, token in
		{
			"Nostril",
			"Pollen",
			"Vein",
			"Inlay",
			"WaterSpot",
			"RimPearl",
			"CrownBead",
			"PatinaBand",
			"ShellBand",
			"GoldenShoulderFeather",
			"GlowingRib",
			"EmberDot",
			"ChimneyBand",
			"Brick",
			"Whisker",
			"RunicStud",
			"BarkLine",
			"Spore",
		}
	do
		if name:find(token) then
			return true
		end
	end
	return false
end
function L.annotate(model)
	local parts, parents, keep = {}, {}, {}
	for _, item in model:GetDescendants() do
		if item:IsA("BasePart") then
			table.insert(parts, item)
		elseif item:IsA("Motor6D") or item:IsA("WeldConstraint") then
			parents[item.Part1] = item.Part0
		end
	end
	for _, part in parts do
		if part == model.PrimaryPart or not decorative(part) then
			local cursor = part
			while cursor and not keep[cursor] do
				keep[cursor] = true
				cursor = parents[cursor]
			end
		end
	end
	local removed = 0
	for _, part in parts do
		local detail = not keep[part]
		part:SetAttribute("LODDetail", detail)
		if detail then
			removed += 1
		end
	end
	model:SetAttribute("SculptDetail", "full")
	model:SetAttribute("FullPartCount", #parts)
	model:SetAttribute("LowPartCount", #parts - removed)
	return removed
end
function L.reduce(model)
	local removed = 0
	for _, item in model:GetDescendants() do
		if item:IsA("BasePart") and item:GetAttribute("LODDetail") == true then
			item:Destroy()
			removed += 1
		end
	end
	model:SetAttribute("SculptDetail", "low")
	return removed
end
return L
