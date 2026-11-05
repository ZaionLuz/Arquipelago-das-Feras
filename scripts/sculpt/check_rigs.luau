local load = require("../loader").load
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local rb = require("@lune/roblox")
local C = load("src/shared/Creatures.luau")
local F = load("src/shared/ModelFactory.luau")
local requests, layouts, maximum, total = 0, 0, 0, 0
local summaries = {}
for _, def in C.List do
	local seen = {}
	local entries = {}
	for _, level in { 1, 7, 15, 60 } do
		local m = F.build(def, level, { preview = true })
		local report = F.validate(m)
		local stage = C.stage(level, def.id)
		assert(m:FindFirstChild("Body") and m:FindFirstChild("Head"), "Anatomia ausente: " .. def.id)
		local joints = 0
		for _, obj in m:GetDescendants() do
			if obj:IsA("Motor6D") then
				joints += 1
				assert(obj.Part0:IsDescendantOf(m) and obj.Part1:IsDescendantOf(m), "Referência fora do clone")
			end
		end
		assert(joints >= 3, "Rig sem articulação suficiente: " .. def.id)
		local color = m.Head.Color
		m.Head.Color = rb.Color3.fromRGB(255, 0, 255)
		local other = F.build(def, level, { preview = true })
		assert(other.Head.Color == color, "Mutação vazou para o template")
		F.validate(other)
		requests += 2
		if not seen[stage] then
			seen[stage] = true
			layouts += 1
			total += report.parts
			maximum = math.max(maximum, report.parts)
			table.insert(entries, {
				stage = stage,
				parts = report.parts,
				joints = joints,
				size = { report.size.X, report.size.Y, report.size.Z },
			})
		end
		m:Destroy()
		other:Destroy()
	end
	table.insert(summaries, { id = def.id, stages = entries })
end
assert(layouts == 116 and #summaries == 40)
fs.writeFile(
	"docs/bestiary40/RIG_METRICS.json",
	serde.encode("json", {
		species = #summaries,
		forms = layouts,
		requests = requests,
		maxParts = maximum,
		totalParts = total,
		cloneIsolation = true,
		graphValidated = true,
		physicsExecuted = false,
		models = summaries,
	}, true)
)
print(
	"PASS esculturas: 40 espécies / 116 formas /",
	requests,
	"construções; rig íntegro, clones isolados; máximo",
	maximum,
	"peças"
)
