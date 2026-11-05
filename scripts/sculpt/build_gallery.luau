-- Galeria estática independente: permite inspecionar os rigs sem DataStore nem Play.
local load = require("../loader").load
local rb = require("@lune/roblox")
local fs = require("@lune/fs")
local C = load("src/shared/Creatures.luau")
local F = load("src/shared/ModelFactory.luau")
local V = rb.Vector3.new
local args = require("@lune/process").args
local detail = args[1] == "low" and "low" or "full"
local place = rb.Instance.new("DataModel")
local world = place:GetService("Workspace")
world.StreamingEnabled = false
local camera = rb.Instance.new("Camera")
camera.Name = "Camera"
camera.CFrame = rb.CFrame.lookAt(V(38, 23, 44), V(23, 3, 0))
camera.Focus = rb.CFrame.new(23, 3, 0)
camera.Parent = world
world.CurrentCamera = camera
local lights = place:GetService("Lighting")
lights.ClockTime, lights.Brightness = 15, 2
lights.Ambient = rb.Color3.fromRGB(113, 107, 144)
lights.OutdoorAmbient = rb.Color3.fromRGB(137, 133, 165)
lights.GlobalShadows = true
local gallery = rb.Instance.new("Folder")
gallery.Name, gallery.Parent = "Galeria40Especies116Formas", world
local function floor(name, size, point, color, kind)
	local part = rb.Instance.new(kind or "Part")
	part.Name, part.Size, part.Position, part.Color = name, size, point, color
	part.Anchored, part.Parent = true, world
	return part
end
floor("PisoDaGaleria", V(340, 1, 345), V(125, -1, 135), rb.Color3.fromRGB(229, 215, 180))
local spawn = floor("Entrada", V(12, 1, 12), V(0, 0, -15), rb.Color3.fromRGB(244, 184, 70), "SpawnLocation")
spawn.Neutral = true
local models, parts = 0, 0
for index, def in C.List do
	local origin = V((index - 1) % 4 * 78, 0, math.floor((index - 1) / 4) * 30)
	local seen = {}
	for _, level in { 1, 7, 15 } do
		local stage = C.stage(level, def.id)
		if seen[stage] then
			continue
		end
		seen[stage] = true
		local model = F.build(def, level, { preview = true, detail = detail })
		local report = F.validate(model)
		local low, high = F.bounds(model)
		local anchor = origin + V((stage - 1) * 23, 0.4, 0)
		local offset = anchor - V((low.X + high.X) * 0.5, low.Y, (low.Z + high.Z) * 0.5)
		for _, p in model:GetDescendants() do
			if p:IsA("BasePart") then
				p.CFrame = rb.CFrame.new(offset) * p.CFrame
			end
		end
		model.Name = def.id .. "_estagio_" .. stage
		model.Parent = gallery
		local podium =
			floor("Base_" .. model.Name, V(21, 0.4, 22), anchor - V(0, 0.4, 0), rb.Color3.fromRGB(50, 49, 77))
		local gui = rb.Instance.new("BillboardGui")
		gui.Size, gui.StudsOffset, gui.MaxDistance = rb.UDim2.fromOffset(240, 54), V(0, report.size.Y + 2, 0), 80
		gui.Parent = podium
		local text = rb.Instance.new("TextLabel")
		text.Size = rb.UDim2.fromScale(1, 1)
		text.BackgroundTransparency, text.TextColor3 = 0.15, rb.Color3.fromRGB(255, 238, 197)
		text.BackgroundColor3, text.TextSize = rb.Color3.fromRGB(36, 38, 65), 17
		text.Text = def.name .. "\n" .. ({ "Filhote", "Jovem", "Adulto" })[stage]
		text.Parent = gui
		models += 1
		parts += report.parts
	end
end
assert(models == 116)
local blob = rb.serializePlace(place)
local restored = rb.deserializePlace(blob)
local count = #restored:GetService("Workspace"):FindFirstChild(gallery.Name):GetChildren()
assert(count == 116, "Galeria incompleta após serialização")
for _, model in restored:GetService("Workspace"):FindFirstChild(gallery.Name):GetChildren() do
	F.validate(model)
end
fs.writeFile(detail == "low" and "releases/Galeria-40-Feras-Leve.rbxl" or "releases/Galeria-40-Feras.rbxl", blob)
print(
	"PASS galeria nativa:",
	detail,
	models,
	"formas /",
	parts,
	"peças; serialização verificada; sem scripts nem DataStore"
)
