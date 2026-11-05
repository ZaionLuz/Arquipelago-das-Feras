--!nonstrict
-- Estrutura mensurável; aprovação de arte permanece humana.
local C = require(script.Parent.Creatures)
local D = require(script.Parent.CreatureDesigns)
local F = require(script.Parent.ModelFactory)
local Checks = { MinimumDistance = 0.12, MinimumStageDistance = 0.08 }
local function difference(a, b)
	local sum, count = 0, 0
	local keys = {}
	for k in a do
		keys[k] = true
	end
	for k in b do
		keys[k] = true
	end
	for k in keys do
		sum += math.abs((a[k] or 0) - (b[k] or 0))
		count += 1
	end
	return sum / math.max(1, count)
end
function Checks.signature(model)
	local report = F.validate(model)
	local size = report.size
	local longest = math.max(size.X, size.Y, size.Z)
	local sig = {
		parts = report.parts,
		aspect = { size.X / longest, size.Y / longest, size.Z / longest },
		hist = {},
		features = {},
		layout = {},
		palette = {},
		categorical = {},
	}
	local low, high = F.bounds(model)
	local center = (low + high) * 0.5
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") and p.Name ~= "Root" then
			local mesh = p:FindFirstChildOfClass("SpecialMesh")
			local kind = p.ClassName
				.. ":"
				.. tostring(mesh and mesh.MeshType or p:IsA("Part") and p.Shape or "primitive")
			sig.hist[kind] = (sig.hist[kind] or 0) + 1
			sig.features[p:GetAttribute("Feature") or p.Name] = 1
			local relative = (p.CFrame.Position - center) / longest
			local dim = p.Size / longest
			sig.layout[p.Name] = { relative.X, relative.Y, relative.Z, dim.X, dim.Y, dim.Z }
			local color = p.Color
			local key = math.floor(color.R * 7) .. ":" .. math.floor(color.G * 7) .. ":" .. math.floor(color.B * 7)
			sig.palette[key] = (sig.palette[key] or 0) + 1
		end
	end
	for k, v in sig.hist do
		sig.hist[k] = v / report.parts
	end
	for k, v in sig.palette do
		sig.palette[k] = v / report.parts
	end
	for _, key in { "Family", "HeadType", "EyeType", "TailType", "LimbCount" } do
		sig.categorical[key] = model:GetAttribute(key)
	end
	return sig
end
function Checks.geometryDistance(a, b)
	local partDifference = math.abs(a.parts - b.parts) / math.max(a.parts, b.parts)
	local layout, total = 0, 0
	local keys = {}
	for k in a.layout do
		keys[k] = true
	end
	for k in b.layout do
		keys[k] = true
	end
	for k in keys do
		total += 1
		if a.layout[k] and b.layout[k] then
			layout += math.min(1, difference(a.layout[k], b.layout[k]) * 3)
		else
			layout += 1
		end
	end
	return 0.4 * partDifference + 0.6 * layout / math.max(1, total)
end
function Checks.distance(a, b)
	local same, union = 0, 0
	local keys = {}
	for k in a.features do
		keys[k] = true
	end
	for k in b.features do
		keys[k] = true
	end
	for k in keys do
		union += 1
		if a.features[k] and b.features[k] then
			same += 1
		end
	end
	local categories = 0
	for k, v in a.categorical do
		if v ~= b.categorical[k] then
			categories += 1
		end
	end
	return 0.4 * Checks.geometryDistance(a, b)
		+ 0.15 * difference(a.aspect, b.aspect)
		+ 0.15 * (1 - same / math.max(1, union))
		+ 0.1 * difference(a.hist, b.hist)
		+ 0.1 * difference(a.palette, b.palette)
		+ 0.1 * categories / 5
end
function Checks.run()
	local signatures = {}
	local reports = {}
	local tuple = {}
	local minimum = math.huge
	local closest
	local eyeCounts = {}
	local total = 0
	for _, def in C.List do
		local recipe = assert(D[def.id], "Receita ausente")
		local key = table.concat({ recipe.family, recipe.head, recipe.eyes, recipe.tail, tostring(recipe.limbs) }, ":")
		assert(not tuple[key], "Tupla anatômica repetida")
		tuple[key] = true
		eyeCounts[recipe.eyes] = (eyeCounts[recipe.eyes] or 0) + 1
		signatures[def.id] = {}
		reports[def.id] = {}
		for index, lv in { 1, 7, 15 } do
			local m = F.build(def, lv, { preview = true })
			local sig = Checks.signature(m)
			signatures[def.id][index] = sig
			reports[def.id][index] = { parts = sig.parts, size = F.validate(m).size }
			total += 1
			if index > 1 and not def.minStage then
				assert(
					Checks.geometryDistance(sig, signatures[def.id][index - 1]) >= Checks.MinimumStageDistance,
					"Só escala: " .. def.id .. ":" .. index
				)
			end
			m:Destroy()
		end
		assert(
			C.stage(6, def.id) == (def.minStage or 1)
				and C.stage(7, def.id) == math.max(2, def.minStage or 1)
				and C.stage(15, def.id) == 3,
			"Marco de evolução alterado"
		)
	end
	for _, count in eyeCounts do
		assert(count <= 4, "Olho repetido em mais de quatro espécies")
	end
	for i = 1, #C.List - 1 do
		for j = i + 1, #C.List do
			for stage = 1, 3 do
				local a, b = C.List[i].id, C.List[j].id
				local distance = Checks.distance(signatures[a][stage], signatures[b][stage])
				if distance < minimum then
					minimum = distance
					closest = a .. "/" .. b .. ":" .. stage
				end
				assert(
					distance >= Checks.MinimumDistance,
					"Silhuetas próximas: " .. a .. "/" .. b .. ":" .. stage .. " = " .. distance
				)
			end
		end
	end
	local phoenix = F.build(C.ById.fenix, 60, { preview = true })
	local wings, tail, arcs, rays = 0, 0, 0, 0
	for _, part in phoenix:GetDescendants() do
		if part:IsA("BasePart") then
			if part.Name:match("^PrimaryFeather") then
				wings += 1
			elseif part.Name:match("^TailRibbon") then
				tail += 1
			elseif part.Name:match("^HaloArc") then
				arcs += 1
			elseif part.Name:match("^HaloRay") then
				rays += 1
			end
		end
	end
	assert(wings == 16 and tail == 28 and arcs == 16 and rays == 8, "Anatomia solar incompleta")
	F.validate(phoenix)
	phoenix:Destroy()
	print(
		"PASS: modelos",
		total + 1,
		"construções, 16 rêmiges / 28 segmentos de cauda / halo 16+8; distância mínima",
		minimum,
		closest
	)
	return { reports = reports, minimum = minimum, closest = closest, total = total + 1, signatures = signatures }
end
return Checks
