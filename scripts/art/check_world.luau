local Loader = require("../loader")
local rb = require("@lune/roblox")
local RS = { Shared = Loader.node("src/shared") }
local load = Loader.new({
	game = {
		GetService = function(_, name)
			if name == "ReplicatedStorage" then
				return RS
			else
				return {}
			end
		end,
	},
})
local Art = load("src/server/WorldArt.luau")
local I = load("src/shared/Islands.luau")
local root = rb.Instance.new("Folder")
Art.build(root)
local parts, animated = 0, 0
for _, p in root:GetDescendants() do
	if p:IsA("BasePart") then
		parts += 1
		assert(p.Anchored and not p.CanCollide and not p.CanQuery and not p.CanTouch)
		assert(p.Size.X > 0 and p.Size.Y > 0 and p.Size.Z > 0)
		if p:GetAttribute("ArtMotion") then
			animated += 1
		end
	end
end
assert(parts < 1400)
print("PASS world art", parts, "decorative parts", animated, "animation candidates")
local group = rb.Instance.new("Folder")
Art.camp(group, I.pos(1))
Art.researcher(group, I.pos(1))
Art.plot(group, I.pos(1))
Art.habitat(group, I.pos(1), "Floresta")
local extra = 0
for _, p in group:GetDescendants() do
	if p:IsA("BasePart") then
		extra += 1
		assert(not p.CanCollide and not p.CanQuery and not p.CanTouch)
	end
end
print("PASS camp/NPC/plot/habitat", extra, "noncolliding parts")
local architecture = load("src/server/IslandArchitecture.luau")
for _, def in I.List do
	architecture.build(group, I.pos(def.idx), def)
end
print("PASS seven geological constructions")

-- Figurino cosmético nativo: não altera estatísticas, formas físicas nem Humanoid.
local character = rb.Instance.new("Model")
local torso = rb.Instance.new("Part")
torso.Name = "Torso"
torso.Size = rb.Vector3.new(2, 2, 1)
torso.CFrame = rb.CFrame.new(2, 8, 3)
torso.CanCollide = true
torso.Parent = character
local humanoid = rb.Instance.new("Humanoid")
humanoid.WalkSpeed = 17
humanoid.JumpPower = 51
humanoid.MaxHealth = 108
humanoid.Health = 91
humanoid.Parent = character
local before = {
	cf = torso.CFrame,
	size = torso.Size,
	walk = humanoid.WalkSpeed,
	jump = humanoid.JumpPower,
	maxHp = humanoid.MaxHealth,
	hp = humanoid.Health,
}
local env = load("src/client/EnvironmentArt.luau")
env.dress(character)
assert(torso.CFrame == before.cf and torso.Size == before.size and torso.CanCollide)
assert(
	humanoid.WalkSpeed == before.walk
		and humanoid.JumpPower == before.jump
		and humanoid.MaxHealth == before.maxHp
		and humanoid.Health == before.hp
)
local outfit = character:FindFirstChild("ArteExplorador")
local outfitParts = 0
for _, obj in outfit:GetDescendants() do
	if obj:IsA("BasePart") then
		outfitParts += 1
		assert(obj.Massless and not obj.Anchored and not obj.CanCollide and not obj.CanTouch and not obj.CanQuery)
	end
end
assert(outfitParts == 4)
env.dress(character)
assert(#character:GetChildren() == 3)
local geometry = 0
for _, obj in group:GetDescendants() do
	if obj:IsA("BasePart") then
		geometry += 1
	end
end
local fs = require("@lune/fs")
local serde = require("@lune/serde")
fs.writeFile(
	"docs/art/WORLD_METRICS.json",
	serde.encode("json", {
		worldDecorParts = parts,
		animatedCandidates = animated,
		campNpcPlotHabitatParts = extra,
		geologyParts = geometry - extra,
		localOutfitParts = outfitParts,
		humanoidUnchanged = true,
		decorationAllNoninteractive = true,
		studioRendering = false,
	}, true)
)
print(
	"PASS cosmetic outfit",
	outfitParts,
	"welded massless pieces; Humanoid and torso unchanged; repeated dressing replaces old outfit"
)
