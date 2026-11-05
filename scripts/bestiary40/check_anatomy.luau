-- Verifica a anatomia reconhecível do lendário no rig real, incluindo o modo leve.
local load = require("../loader").load
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local C = load("src/shared/Creatures.luau")
local F = load("src/shared/ModelFactory.luau")
local rows = {}
for _, detail in { "full", "low" } do
	for _, level in { 1, 7, 15, 60 } do
		assert(C.stage(level, "kraken") == 3, "Kraken deve nascer adulto")
		local model = F.build(C.ById.kraken, level, { preview = true, detail = detail })
		local report = F.validate(model)
		local arms, roots, suckers, inlays = 0, 0, 0, 0
		local joints = {}
		for _, item in model:GetDescendants() do
			if item:IsA("Motor6D") or item:IsA("WeldConstraint") then
				joints[item.Part1] = item
			elseif item:IsA("BasePart") then
				if item.Name:match("^TailArm%d+_%d+$") then
					arms += 1
				elseif item.Name:match("^RimPearlSucker") or item.Name:match("^SuckerDisk") then
					suckers += 1
				elseif item.Name:match("^SuckerInlay") then
					inlays += 1
				end
			end
		end
		for arm = 1, 8 do
			local previous, previousWidth, bend = model.Body, math.huge, nil
			for segment = 1, 5 do
				local part = assert(model:FindFirstChild("TailArm" .. arm .. "_" .. segment), "Braço incompleto")
				local joint = assert(joints[part], "Braço sem conexão")
				assert(joint.Part0 == previous and joint.Part1 == part, "Cadeia de braço incorreta")
				assert(part.Size.X < previousWidth and part.Size.Z < previousWidth, "Braço sem afilamento")
				if segment == 1 then
					assert(joint:IsA("Motor6D"), "Raiz de braço sem articulação")
					roots += 1
				else
					assert(joint:IsA("WeldConstraint"), "Segmento deve acompanhar a raiz")
				end
				if segment == 3 then
					bend = part.CFrame.Position
				elseif segment == 5 then
					assert(part.CFrame.Position.Y > bend.Y, "Ponta do tentáculo sem curva ascendente")
				end
				previous, previousWidth = part, part.Size.X
			end
		end
		assert(arms == 40 and roots == 8, "Kraken precisa de oito braços completos")
		assert(model:FindFirstChild("Mantle") and model:FindFirstChild("CoralCrown3"), "Manto/coroa ausentes")
		if detail == "full" then
			assert(suckers == 48 and inlays == 48, "Duas fileiras de ventosas incompletas")
		else
			assert(suckers >= 24 and inlays == 0, "LOD deve preservar ventosas, removendo só adornos")
		end
		table.insert(rows, {
			detail = detail,
			level = level,
			stage = 3,
			parts = report.parts,
			armRoots = roots,
			armSegments = arms,
			suckers = suckers,
			inlays = inlays,
		})
		model:Destroy()
	end
end
fs.writeFile(
	"docs/bestiary40/ANATOMY_METRICS.json",
	serde.encode("json", { species = "kraken", physicsExecuted = false, models = rows }, true)
)
print(
	"PASS Kraken: adulto em todos os níveis; oito raízes articuladas / 40 segmentos em full e low; 48 ventosas full"
)
