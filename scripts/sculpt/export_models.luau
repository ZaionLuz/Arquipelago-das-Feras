-- Static native geometry for DCC review. Does not render or execute physics.
local Loader = require("../loader")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local process = require("@lune/process")
local base = process.args[1] or "."
local destination = process.args[2] or "/tmp/feras-sculpt-geometry.json"
local load = Loader.new()
local C = load(base .. "/src/shared/Creatures.luau")
local F = load(base .. "/src/shared/ModelFactory.luau")
local function vector(v)
	return { v.X, v.Y, v.Z }
end
local out = {
	format = 1,
	description = "Native Roblox static geometry; DCC reconstruction, not Studio screenshots",
	models = {},
}
for _, def in C.List do
	local stages = {}
	for _, level in { 1, 7, 15 } do
		local stage = C.stage(level, def.id)
		if stages[stage] then
			continue
		end
		stages[stage] = true
		local succeeded, model = pcall(F.build, def, level, { preview = true })
		assert(succeeded, def.id .. " stage " .. stage .. ": " .. tostring(model))
		local row =
			{ id = def.id, name = def.name, stage = stage, level = level, element = def.el, parts = {}, joints = {} }
		for _, obj in model:GetDescendants() do
			if obj:IsA("BasePart") and obj.Name ~= "Root" then
				local mesh = obj:FindFirstChildOfClass("SpecialMesh")
				table.insert(row.parts, {
					name = obj.Name,
					class = obj.ClassName,
					size = vector(obj.Size),
					cf = { obj.CFrame:GetComponents() },
					color = { obj.Color.R, obj.Color.G, obj.Color.B },
					material = tostring(obj.Material),
					shape = obj:IsA("Part") and tostring(obj.Shape) or "",
					mesh = mesh and tostring(mesh.MeshType) or "",
					meshScale = mesh and vector(mesh.Scale) or { 1, 1, 1 },
					alpha = 1 - obj.Transparency,
				})
			elseif obj:IsA("Motor6D") then
				table.insert(row.joints, {
					name = obj.Name,
					part0 = obj.Part0.Name,
					part1 = obj.Part1.Name,
					role = obj:GetAttribute("Role"),
					c0 = { obj.C0:GetComponents() },
				})
			end
		end
		local low, high = F.bounds(model)
		row.bounds = { low = vector(low), high = vector(high) }
		table.insert(out.models, row)
		model:Destroy()
	end
end
fs.writeFile(destination, serde.encode("json", out))
print("PASS static geometry: " .. #out.models .. " distinct forms exported")
