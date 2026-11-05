local Loader = require("../loader")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local F = Loader.load("src/shared/ModelFactory.luau")
local C = Loader.load("src/shared/Creatures.luau")
F.clearCache()
local rows, forms, fullTotal, lowTotal = {}, 0, 0, 0
local adultsFull, adultsLow, peak = 0, 0, 0
for _, def in C.List do
	local seen = {}
	for _, level in { 1, 7, 15 } do
		local stage = C.stage(level, def.id)
		if seen[stage] then
			continue
		end
		seen[stage] = true
		local full = F.build(def, level, { preview = true, detail = "full" })
		local low = F.build(def, level, { preview = true, detail = "low" })
		local a, b = F.validate(full), F.validate(low)
		assert(b.parts <= a.parts and b.parts == full:GetAttribute("LowPartCount"))
		assert(full:GetAttribute("SculptDetail") == "full" and low:GetAttribute("SculptDetail") == "low")
		assert(low.Body.Size == full.Body.Size and low.Head.Size == full.Head.Size)
		assert(low.Body.Color == full.Body.Color and low.Head.Color == full.Head.Color)
		assert((a.size - b.size).Magnitude / a.size.Magnitude < 0.15, "Silhueta alterada: " .. def.id)
		for _, part in full:GetDescendants() do
			if part:IsA("BasePart") and not part:GetAttribute("LODDetail") then
				local counterpart = assert(low:FindFirstChild(part.Name), "Volume essencial removido: " .. part.Name)
				assert(counterpart.Size == part.Size and counterpart.CFrame == part.CFrame)
			end
		end
		local restored = F.build(def, level, { preview = true, detail = "full" })
		assert(F.validate(restored).parts == a.parts)
		forms += 1
		local memory = F.cacheStats()
		peak = math.max(peak, memory.templates)
		assert(memory.templates == forms, "Cache duplicou variantes de qualidade")
		fullTotal += a.parts
		lowTotal += b.parts
		if stage == 3 then
			adultsFull += a.parts
			adultsLow += b.parts
		end
		table.insert(rows, { id = def.id, stage = stage, full = a.parts, low = b.parts })
		full:Destroy()
		low:Destroy()
		restored:Destroy()
	end
end
assert(forms == 116 and peak == 116 and adultsLow < adultsFull * 0.85)
-- O modo manual Alto vence um sinal adaptativo antigo já no primeiro render.
local quality, adaptive = "Alto", true
local clientF = Loader.new({
	game = {
		GetService = function(_, name)
			if name == "RunService" then
				return {
					IsClient = function()
						return true
					end,
				}
			end
			return {
				LocalPlayer = {
					GetAttribute = function(_, key)
						return key == "GraphicsQuality" and quality or adaptive
					end,
				},
			}
		end,
	},
})("src/shared/ModelFactory.luau")
assert(clientF.detailKey() == "full")
quality = "Médio"
assert(clientF.detailKey() == "low")
adaptive = false
assert(clientF.detailKey() == "full")
quality = "Baixo"
assert(clientF.detailKey() == "low")
assert(clientF.detailKey({ detail = "full" }) == "full")
F.clearCache()
assert(F.cacheStats().templates == 0 and F.cacheStats().parts == 0)
fs.writeFile(
	"docs/bestiary40/LOD_METRICS.json",
	serde.encode("json", {
		forms = forms,
		peakTemplates = peak,
		maxVariantsPerSpeciesStage = 1,
		fullParts = fullTotal,
		lowParts = lowTotal,
		adultFull = adultsFull,
		adultLow = adultsLow,
		adultReduction = 1 - adultsLow / adultsFull,
		essentialVolumesPreserved = true,
		cloneRigsValid = true,
		fpsMeasured = false,
		models = rows,
	}, true)
)
print(
	"PASS LOD: 116 formas válidas, volumes essenciais preservados, cache máximo116; adultos",
	adultsFull,
	"→",
	adultsLow,
	"peças; FPS não medido"
)
