-- Native geometry and actual Motor6D.Transform sampled headlessly; no renderer/physics claimed.
local Loader = require("../loader")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local rb = require("@lune/roblox")
local process = require("@lune/process")
local base = process.args[1] or "."
local destination = process.args[2] or "/tmp/feras-art-geometry.json"
local time = 0
local heartbeat
local run = {
	Heartbeat = {
		Connect = function(_, callback)
			heartbeat = callback
		end,
	},
	IsStudio = function()
		return false
	end,
}
local player = {
	GetAttribute = function(_, name)
		return name == "GraphicsQuality" and "Alto" or false
	end,
}
local RS = { Shared = Loader.node(base .. "/src/shared") }
local game = {
	GetService = function(_, name)
		return ({ ReplicatedStorage = RS, RunService = run, Players = { LocalPlayer = player } })[name]
	end,
}
local workspace = {
	CurrentCamera = { CFrame = rb.CFrame.new(0, 20, 50) },
	FindFirstChild = function()
		return nil
	end,
}
local load = Loader.new({ game = game, workspace = workspace, os = {
	clock = function()
		return time
	end,
} })
local C = load(base .. "/src/shared/Creatures.luau")
local Factory = load(base .. "/src/shared/ModelFactory.luau")
local animator = load(base .. "/src/client/CreatureAnimator.luau")
animator.start()
local function vector(v)
	return { v.X, v.Y, v.Z }
end
local function read(obj, key, fallback)
	local ok, value = pcall(function()
		return obj[key]
	end)
	return ok and value or fallback
end
local function export(model)
	local links = {}
	for _, joint in model:GetDescendants() do
		if joint:IsA("Motor6D") then
			links[joint.Part1] = {
				part0 = joint.Part0,
				offset = joint.C0
					* read(joint, "Transform", rb.CFrame.identity)
					* read(joint, "C1", rb.CFrame.identity):Inverse(),
			}
		elseif joint:IsA("WeldConstraint") then
			links[joint.Part1] = { part0 = joint.Part0, offset = joint.Part0.CFrame:ToObjectSpace(joint.Part1.CFrame) }
		end
	end
	local poses = {}
	local function pose(part)
		if poses[part] then
			return poses[part]
		end
		local link = links[part]
		local cf = link and pose(link.part0) * link.offset or part.CFrame
		poses[part] = cf
		return cf
	end
	local parts = {}
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") and p.Name ~= "Root" then
			local mesh = p:FindFirstChildOfClass("SpecialMesh")
			table.insert(parts, {
				name = p.Name,
				class = p.ClassName,
				size = vector(p.Size),
				cf = { pose(p):GetComponents() },
				color = { p.Color.R, p.Color.G, p.Color.B },
				material = tostring(p.Material),
				shape = p:IsA("Part") and tostring(p.Shape) or "",
				mesh = mesh and tostring(mesh.MeshType) or "",
				meshScale = mesh and vector(mesh.Scale) or { 1, 1, 1 },
				alpha = 1 - read(p, "Transparency", 0),
			})
		end
	end
	return parts
end
local frames = {
	{ pose = "idle", time = 0 },
	{ pose = "idle", time = 0.15 },
	{ pose = "idle", time = 0.3 },
	{ pose = "idle", time = 0.45 },
	{ pose = "idle", time = 0.6 },
	{ pose = "idle", time = 0.75 },
	{ pose = "attack", time = 0.08 },
	{ pose = "attack", time = 0.22 },
	{ pose = "attack", time = 0.4 },
	{ pose = "damage", time = 0.1 },
	{ pose = "damage", time = 0.3 },
	{ pose = "faint", time = 0.12 },
	{ pose = "faint", time = 0.3 },
	{ pose = "faint", time = 0.48 },
}
local output = {
	source = base,
	description = "Native parts and actual client joint transforms; headless software preview only",
	frames = frames,
	models = {},
}
local hasTokens, tokens = pcall(load, base .. "/src/shared/ArtTokens.luau")
if hasTokens then
	output.palette = {}
	for _, c in tokens.Palette do
		table.insert(output.palette, { c.R, c.G, c.B })
	end
end
for _, def in C.List do
	for _, lv in { 1, 7, 15 } do
		local row = {
			id = def.id,
			name = def.name,
			island = def.island,
			level = lv,
			stage = C.stage(lv, def.id),
			element = def.el,
			frames = {},
		}
		for index, frame in frames do
			time = 0
			local model = Factory.build(def, lv, { preview = true })
			animator.register(model, function()
				return true
			end)
			if frame.pose ~= "idle" then
				animator.play(model, frame.pose, 0.5)
			end
			time = frame.time
			local ok, reason = pcall(heartbeat, 1 / 30 + 0.001)
			if not ok then
				error("Animation sample failed: " .. tostring(reason))
			end
			table.insert(row.frames, export(model))
			model:Destroy()
		end
		table.insert(output.models, row)
	end
end
local hasIcons, icons = pcall(load, base .. "/src/client/PixelIcons.luau")
if hasIcons then
	output.icons = icons.Grids
end
if hasTokens then
	output.tokens = {}
	for _, key in { "Ink", "Muted", "Panel", "Card", "Edge", "Shadow", "Accent", "Mint" } do
		local c = tokens[key]
		output.tokens[key] = { c.R, c.G, c.B }
	end
	local hasStage, Stage = pcall(load, base .. "/src/client/BattleStage.luau")
	if hasStage then
		output.battles = {}
		for _, id in { "Alvorecer", "Brasa", "Recife", "Floresta", "Dunas", "Picos", "Pantano" } do
			local world = rb.Instance.new("WorldModel")
			local scenery = Stage.build(world, id)
			table.insert(
				output.battles,
				{ id = id, parts = export(scenery), count = scenery:GetAttribute("PartCount") }
			)
			world:Destroy()
		end
	end
end
fs.writeFile(destination, serde.encode("json", output))
print("PASS geometry: " .. #output.models .. " model requests × " .. #frames .. " native animation samples")
