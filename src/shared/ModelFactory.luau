--!nonstrict
local C = require(script.Parent.Creatures)
local D = require(script.Parent.CreatureDesigns)
local Context = require(script.Parent.SculptContext)
local LOD = require(script.Parent.SculptLOD)
local builders = {}
for _, family in
	{
		require(script.Parent.SculptOrganic),
		require(script.Parent.SculptTidal),
		require(script.Parent.SculptSky),
		require(script.Parent.SculptMystic),
		require(script.Parent.SculptDrakes),
		require(script.Parent.SculptExpansionA),
		require(script.Parent.SculptExpansionB),
	}
do
	for id, build in family do
		assert(not builders[id], "Escultura duplicada: " .. id)
		builders[id] = build
	end
end
local Art = require(script.Parent.ArtTokens)
local Factory = {}
local cache = {}
local V = Vector3.new
local function bounds(model)
	local low = V(math.huge, math.huge, math.huge)
	local high = -low
	for _, p in model:GetDescendants() do
		if p:IsA("BasePart") and p.Name ~= "Root" then
			for _, x in { -1, 1 } do
				for _, y in { -1, 1 } do
					for _, z in { -1, 1 } do
						local pos = p.CFrame:PointToWorldSpace(p.Size * V(x, y, z) * 0.5)
						low = V(math.min(low.X, pos.X), math.min(low.Y, pos.Y), math.min(low.Z, pos.Z))
						high = V(math.max(high.X, pos.X), math.max(high.Y, pos.Y), math.max(high.Z, pos.Z))
					end
				end
			end
		end
	end
	return low, high
end
Factory.bounds = bounds
function Factory.validate(model)
	assert(model.PrimaryPart and model.PrimaryPart.Name == "Root", "Raiz ausente")
	local design = D[model:GetAttribute("Species")]
	local stage = model:GetAttribute("Stage")
	assert(design and stage, "Receita ou estágio ausente")
	local count, joints, emitters, lights = 0, {}, 0, 0
	local parents = {}
	for _, obj in model:GetDescendants() do
		assert(not obj:IsA("LuaSourceContainer"), "Script dentro da criatura")
		if obj:IsA("BasePart") then
			count += 1
			for _, n in { obj.Size.X, obj.Size.Y, obj.Size.Z } do
				assert(n == n and n > 0 and n < 100, "Size inválido")
			end
			assert(
				not obj.CanCollide and not obj.CanQuery and not obj.CanTouch and obj.Massless,
				"Colisão/massa inválida"
			)
			for _, component in { obj.CFrame:GetComponents() } do
				assert(component == component and math.abs(component) < 1000000, "Transform inválido: " .. obj.Name)
			end
			assert(obj == model.PrimaryPart or not obj.Anchored, "Parte visual ancorada")
		elseif obj:IsA("Motor6D") then
			assert(not joints[obj.Name], "Joint duplicado")
			joints[obj.Name] = true
			assert(obj.Part0 and obj.Part1, "Motor desconectado")
			parents[obj.Part1] = obj.Part0
		elseif obj:IsA("WeldConstraint") then
			assert(obj.Part0 and obj.Part1, "Weld desconectado")
			parents[obj.Part1] = obj.Part0
		elseif obj:IsA("ParticleEmitter") then
			emitters += 1
		elseif obj:IsA("Light") then
			lights += 1
		end
	end
	for part in parents do
		local cursor, seen = part, {}
		while cursor ~= model.PrimaryPart do
			assert(cursor and cursor:IsDescendantOf(model) and not seen[cursor], "Rig inválido ou cíclico")
			seen[cursor] = true
			cursor = parents[cursor]
		end
	end
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") and part ~= model.PrimaryPart then
			assert(parents[part], "Parte solta: " .. part.Name)
		end
	end
	assert(count <= design.budget[stage], "Orçamento excedido: " .. count)
	assert(emitters <= (design.head == "solarbeak" and 2 or 1) and lights <= 1, "Orçamento de efeitos excedido")
	local low, high = bounds(model)
	local size = high - low
	assert(
		size.Magnitude > 0.6 and size.Magnitude < (design.head == "solarbeak" and 70 or ({ 20, 30, 45 })[stage]),
		"Bounding box inválida"
	)
	return { parts = count, joints = joints, size = size, emitters = emitters, lights = lights }
end
local function template(def, stage)
	local d = assert(D[def.id], "Design ausente")
	local m = Instance.new("Model")
	m.Name = def.name
	m.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	for key, value in
		{
			Species = def.id,
			Stage = stage,
			Family = d.family,
			EyeType = d.eyes,
			HeadType = d.head,
			TailType = d.tail,
			LimbCount = d.limbs,
			ArtStyle = "StorybookSculpt3D",
			Expression = d.expression.mouth,
			BlinkOffset = #def.id * 0.2,
		}
	do
		m:SetAttribute(key, value)
	end
	local context = Context.new(m, d, stage)
	local builder = assert(builders[def.id], "Escultura exclusiva ausente: " .. def.id)
	local anatomy = builder(context)
	assert(anatomy and anatomy.body and anatomy.head, "Estrutura anatômica ausente")
	assert(anatomy.body.Name == "Body" and anatomy.head.Name == "Head", "Corpo/cabeça não identificados")
	LOD.annotate(m)
	Factory.validate(m)
	return m
end
function Factory.detailKey(options)
	if options and options.detail then
		return options.detail == "low" and "low" or "full"
	end
	local success, detail = pcall(function()
		if not game:GetService("RunService"):IsClient() then
			return "full"
		end
		local p = game:GetService("Players").LocalPlayer
		local quality = p and p:GetAttribute("GraphicsQuality")
		return p and (quality == "Baixo" or quality ~= "Alto" and p:GetAttribute("AdaptiveDetailLow") == true) and "low"
			or "full"
	end)
	return success and detail or "full"
end
function Factory.build(def, level, options)
	options = options or {}
	local stage = C.stage(level, def.id)
	local base = def.id .. ":" .. stage .. ":"
	local detail = Factory.detailKey(options)
	local key = base .. detail
	if not cache[key] then
		local made = template(def, stage)
		if detail == "low" then
			LOD.reduce(made)
			Factory.validate(made)
		end
		-- Uma variante por espécie/estágio: mudar qualidade não duplica a memória dos templates.
		local other = base .. (detail == "low" and "full" or "low")
		if cache[other] then
			cache[other]:Destroy()
			cache[other] = nil
		end
		cache[key] = made
	end
	local model = cache[key]:Clone()
	model.Name = def.name
	model:SetAttribute("Level", level)
	if not options.preview then
		local gui = Instance.new("BillboardGui")
		gui.Size = UDim2.fromOffset(180, 32)
		gui.StudsOffset = V(0, 4, 0)
		gui.MaxDistance = 60
		gui.Parent = model.PrimaryPart
		local label = Instance.new("TextLabel")
		label.Size = UDim2.fromScale(1, 1)
		label.BackgroundTransparency = 1
		label.TextColor3 = Art.Ink
		label.TextStrokeTransparency = 0
		label.TextStrokeColor3 = Art.Shadow
		label.TextSize = 16
		label.Font = Art.Font
		label.Text = def.name .. " • Nv." .. level
		label.Parent = gui
	end
	Factory.validate(model)
	return model
end
function Factory.clearCache()
	for _, m in cache do
		m:Destroy()
	end
	cache = {}
end
function Factory.cacheStats()
	local templates, parts = 0, 0
	for _, model in cache do
		templates += 1
		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") then
				parts += 1
			end
		end
	end
	return { templates = templates, parts = parts }
end
return Factory
