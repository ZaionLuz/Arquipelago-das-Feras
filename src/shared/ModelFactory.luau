--!nonstrict
local C = require(script.Parent.Creatures)
local D = require(script.Parent.CreatureDesigns)
local Features = require(script.Parent.CreatureFeatures)
local Art = require(script.Parent.ArtTokens)
local Factory = {}
local cache = {}
local V = Vector3.new
local A = CFrame.Angles
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
			assert(obj == model.PrimaryPart or not obj.Anchored, "Parte visual ancorada")
		elseif obj:IsA("Motor6D") then
			assert(not joints[obj.Name], "Joint duplicado")
			joints[obj.Name] = true
			assert(obj.Part0 and obj.Part1, "Motor desconectado")
		elseif obj:IsA("ParticleEmitter") then
			emitters += 1
		elseif obj:IsA("Light") then
			lights += 1
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
	local d = D[def.id]
	assert(d, "Design ausente")
	local recipe = d.stages[stage]
	local scale = recipe.scale
	local palette = d.palette
	local m = Instance.new("Model")
	m.Name = def.name
	m.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	m:SetAttribute("Species", def.id)
	m:SetAttribute("Stage", stage)
	m:SetAttribute("Family", d.family)
	m:SetAttribute("EyeType", d.eyes)
	m:SetAttribute("HeadType", d.head)
	m:SetAttribute("TailType", d.tail)
	m:SetAttribute("LimbCount", d.limbs)
	m:SetAttribute("ArtStyle", "PixelSculpt")
	m:SetAttribute("Expression", d.expression.mouth)
	m:SetAttribute("BlinkOffset", #def.id * 0.2)
	local root = Instance.new("Part")
	root.Name = "Root"
	root.Size = V(0.1, 0.1, 0.1) * scale
	root.CFrame = CFrame.new(0, 2 * scale, 0)
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide = false
	root.CanQuery = false
	root.CanTouch = false
	root.Massless = true
	root.CastShadow = false
	root.Parent = m
	m.PrimaryPart = root
	root.CollisionGroup = "Creatures"
	local names = {}
	local function make(name, kind, size, pos, color, rotation, motor, parent)
		names[name] = (names[name] or 0) + 1
		local suffix = names[name] > 1 and "_" .. names[name] or ""
		local p = Instance.new(kind == "wedge" and "WedgePart" or kind == "corner" and "CornerWedgePart" or "Part")
		p.Name = name .. suffix
		p.Size = size * scale
		p.CFrame = CFrame.new(pos * scale) * (rotation or CFrame.identity)
		p.Color = Art.nearest(color)
		p.Material = Enum.Material.SmoothPlastic
		p.Reflectance = 0
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.Massless = true
		p.Anchored = false
		p.CastShadow = p.Size.Magnitude > 2
		p.CollisionGroup = "Creatures"
		-- Head meshes remain softly expressive; bodies become hand-cut silhouette planes.
		if
			kind == "sphere"
			and (name == "Body" or name == "Haunch" or name:find("Coil") or name:find("Tail%d") or name:find("Leg"))
		then
			kind = "block"
		end
		if kind == "sphere" or kind == "head" then
			local mesh = Instance.new("SpecialMesh")
			mesh.MeshType = kind == "head" and Enum.MeshType.Head or Enum.MeshType.Sphere
			mesh.Scale = kind == "head" and V(1, 0.9, 1) or V(1, 1, 1)
			mesh.Parent = p
		elseif kind == "cylinder" then
			p.Shape = Enum.PartType.Cylinder
		end
		if name == "Body" or name == "Haunch" then
			p.Color = Art.nearest(color:Lerp(Art.Ramps.Veil[1], 0.08))
		end
		p:SetAttribute("Feature", name:gsub("%d+", ""))
		p.Parent = m
		local anchor = parent or root
		if motor then
			local joint = Instance.new("Motor6D")
			joint.Name = "J_" .. p.Name
			joint.Part0 = anchor
			joint.Part1 = p
			joint.C0 = anchor.CFrame:ToObjectSpace(p.CFrame)
			joint.Parent = p
			joint:SetAttribute("Role", name)
			joint:SetAttribute("Phase", #m:GetChildren() * 0.27)
		else
			local weld = Instance.new("WeldConstraint")
			weld.Name = "W_" .. p.Name
			weld.Part0 = anchor
			weld.Part1 = p
			weld.Parent = p
		end
		return p
	end
	local w, h, l = d.dimensions.X, d.dimensions.Y, d.dimensions.Z
	local child = stage == 1
	local limbHeight = child and 0.55 or stage == 2 and 1 or 1.45
	local headPos
	local torso
	local family = d.family
	if family == "draconic" and d.head == "raptor" then
		torso = make(
			"Body",
			"wedge",
			V(w, h, l * 0.55),
			V(0, limbHeight + h * 0.6, 0),
			palette[1],
			A(-0.3, math.pi, 0),
			true
		)
		make(
			"Keel",
			"wedge",
			V(w * 0.6, h * 0.6, l * 0.4),
			V(0, limbHeight + h * 0.4, 0.7),
			palette[2],
			nil,
			false,
			torso
		)
		headPos = V(0, limbHeight + h * 1.15, l * 0.25)
	elseif family == "quadruped" or family == "draconic" then
		torso = make("Body", "sphere", V(w * 0.94, h * 0.7, l), V(0, limbHeight + h * 0.35, 0), palette[1], nil, true)
		make(
			"Haunch",
			"sphere",
			V(w * 0.85, h * 0.65, l * 0.6),
			V(0, limbHeight + h * 0.25, -l * 0.35),
			palette[2],
			nil,
			false,
			torso
		)
		headPos = V(0, limbHeight + h * 0.7, l * 0.5)
	elseif family == "biped" or (family == "mineral" and d.limbs == 4) then
		torso =
			make("Body", "wedge", V(w, h, l * 0.65), V(0, limbHeight + h * 0.5, 0), palette[1], A(0, math.pi, 0), true)
		headPos = V(0, limbHeight + h + 0.4, 0.3)
	elseif family == "winged" then
		torso =
			make("Body", "sphere", V(w, h * 0.65, l), V(0, limbHeight + h * 0.35, 0), palette[1], A(-0.2, 0, 0), true)
		local neck = child and 0.35 or stage == 2 and 0.9 or 1.4
		make(
			"Neck",
			"sphere",
			V(w * 0.5, neck + 1, w * 0.5),
			V(0, limbHeight + h * 0.7, 0.5),
			palette[2],
			A(0.2, 0, 0),
			false,
			torso
		)
		headPos = V(0, limbHeight + h * 0.8 + neck, l * 0.35)
	elseif family == "serpentine" then
		torso = make("Body", "sphere", V(w, h, l * 0.5), V(0, h * 0.8, 0.4), palette[1], nil, true)
		headPos = V(0, h * 1.3, 1.3)
		for i = 1, stage + 1 do
			make(
				"Coil" .. i,
				"sphere",
				V(w * (1 - i * 0.1), h * 0.7, l * 0.45),
				V(math.sin(i * 0.9) * 0.8, h * 0.45, -i * 0.8),
				palette[i % 2 + 1],
				A(0, math.sin(i) * 0.3, 0),
				true,
				torso
			)
		end
	elseif family == "arthropod" then
		torso = make("Body", "sphere", V(w, h, l), V(0, 1 + h * 0.4, 0), palette[1], nil, true)
		make(
			"Carapace",
			"wedge",
			V(w * 0.9, h * 0.7, l * 0.75),
			V(0, 1 + h * 0.7, -0.2),
			palette[2],
			A(0, math.pi, 0),
			false,
			torso
		)
		headPos = V(0, 1 + h * 0.5, l * 0.5)
	elseif family == "aquatic" then
		torso = make("Body", "sphere", V(w, h, l), V(0, h * 0.6, 0), palette[1], nil, true)
		headPos = V(0, h * 0.7, l * 0.4)
		for _, s in { -1, 1 } do
			make(
				"Fin" .. s,
				"wedge",
				V(0.2, h, l * 0.55),
				V(s * w * 0.55, h * 0.5, 0),
				palette[2],
				A(0, 0, s * 0.5),
				true,
				torso
			)
		end
	elseif family == "vegetal" then
		torso = make("Body", "sphere", V(w, h, l), V(0, 1 + h * 0.4, 0), palette[1], A(0.1, 0, 0), true)
		headPos = V(0, 1 + h * 0.9, 0.3)
	elseif family == "spectral" then
		torso = make("Body", "wedge", V(w, h, l), V(0, h * 0.6, 0), palette[1], A(0, math.pi, 0), true)
		torso.Material = Enum.Material.Fabric
		headPos = V(0, h + 0.5, 0.3)
		for i = 1, stage + 1 do
			local veil = make(
				"Veil" .. i,
				"wedge",
				V(w * 0.4, 1.1, l * 0.5),
				V((i - (stage + 2) / 2) * 0.5, 0.7, -0.4),
				palette[2],
				A(0, 0, i * 0.15),
				true,
				torso
			)
			veil.Transparency = 0.2
		end
	else
		torso = make("Body", "wedge", V(w, h, l), V(0, h * 0.5 + 0.3, 0), palette[1], A(0, math.pi / 3, 0), true)
		make(
			"StoneShoulder",
			"corner",
			V(w * 0.65, h * 0.6, l * 0.6),
			V(w * 0.3, h * 0.7, 0),
			palette[2],
			nil,
			false,
			torso
		)
		headPos = V(0, h + 0.3, 0.3)
	end
	local headRatio = recipe.headRatio
	local heads = {
		embermask = { "wedge", V(1.4, 0.8, 1.2) },
		boar = { "sphere", V(1.9, 1.2, 1.7) },
		hookbeak = { "head", V(1.3, 1.4, 1.3) },
		hornjaw = { "head", V(1.8, 1.5, 1.8) },
		puffer = { "sphere", V(1.8, 1.5, 1.4) },
		narrow = { "wedge", V(0.9, 0.8, 1.8) },
		crab = { "wedge", V(1.5, 0.75, 1) },
		angler = { "sphere", V(2, 1.4, 1.8) },
		bud = { "sphere", V(1.2, 1.6, 1.2) },
		fox = { "wedge", V(1.4, 1.2, 1.8) },
		trilobe = { "head", V(1.6, 0.7, 1.2) },
		stagmask = { "head", V(1.6, 2, 1.2) },
		geode = { "corner", V(1.4, 1, 1.2) },
		mandible = { "wedge", V(1.3, 0.8, 1.5) },
		sphinx = { "head", V(1.8, 1.8, 1.5) },
		obelisk = { "wedge", V(1.1, 2, 1.2) },
		chick = { "head", V(1.7, 1.8, 1.3) },
		needlebeak = { "head", V(0.9, 1.6, 1.2) },
		raptor = { "wedge", V(1.1, 1.3, 1.7) },
		cloudcap = { "sphere", V(2, 1.4, 1.6) },
		puddle = { "sphere", V(1.8, 0.9, 1.8) },
		lanterncap = { "wedge", V(0.9, 1.6, 1) },
		mothmask = { "head", V(1.4, 0.9, 1.3) },
		royalmask = { "wedge", V(1.3, 2.1, 0.7) },
		steamcap = { "sphere", V(1.5, 1.3, 1.7) },
		armoredjaw = { "wedge", V(1.8, 1, 2) },
		crestbeak = { "head", V(1.2, 1.8, 1.4) },
		hood = { "wedge", V(1.5, 2, 1.2) },
		sweptjaw = { "wedge", V(1.3, 1, 2.2) },
		solarbeak = { "head", V(1.1, 1.7, 1.7) },
	}
	local hp = heads[d.head]
	local headSize = hp[2] * headRatio
	local head = make("Head", hp[1], headSize, headPos, palette[2], A(d.expression.look, 0, 0), true, torso)
	if family == "mineral" then
		torso.Material = Enum.Material.Slate
		head.Material = Enum.Material.Slate
	elseif family == "vegetal" then
		torso.Material = Enum.Material.SmoothPlastic
		head.Material = Enum.Material.SmoothPlastic
	elseif family == "aquatic" or family == "arthropod" then
		torso.Material = Enum.Material.SmoothPlastic
	end
	if family == "quadruped" or family == "draconic" then
		make(
			"Snout",
			"sphere",
			V(d.head == "boar" and 1.3 or 0.9, 0.6, 0.9) * headRatio,
			headPos + V(0, -0.25, 0.75),
			palette[1],
			nil,
			false,
			head
		)
	end
	if family == "winged" then
		make(
			"Beak",
			"wedge",
			V(0.55, 0.4, d.head == "needlebeak" and 1.1 or 0.8),
			headPos + V(0, -0.15, 0.9),
			palette[3],
			A(0, math.pi, 0),
			false,
			head
		)
	end
	local bodySize = torso.Size / scale
	local bodyCenter = torso.CFrame.Position / scale
	make(
		"BellyBib",
		(family == "spectral" or family == "mineral") and "wedge" or "block",
		V(bodySize.X * 0.58, bodySize.Y * 0.5, 0.09),
		bodyCenter + V(0, -bodySize.Y * 0.1, bodySize.Z * 0.5 + 0.025),
		palette[3],
		nil,
		false,
		torso
	)
	make(
		"DorsalRim",
		"wedge",
		V(bodySize.X * 0.72, 0.09, bodySize.Z * 0.65),
		bodyCenter + V(-bodySize.X * 0.08, bodySize.Y * 0.5 + 0.02, 0),
		palette[2],
		nil,
		false,
		torso
	)
	Features.face(make, d, head, headPos, headRatio, stage, headSize)
	-- Esqueleto locomotor varia: raízes, patas articuladas, braços ou pernas de artrópode.
	local legs = family == "winged" and 2 or family == "draconic" and 4 or family == "arthropod" and d.limbs or d.limbs
	for i = 1, legs do
		local side = i % 2 == 1 and -1 or 1
		local pair = math.floor((i - 1) / 2)
		local z = legs >= 4 and ((pair - (math.ceil(legs / 2) - 1) / 2) * l * 0.45) or 0.2
		local x = side * w * 0.4
		local y = limbHeight * 0.55
		if d.head == "raptor" and i > 2 then
			y = limbHeight + h * 0.6
			z = 0.7
		end
		local shape = (family == "arthropod" or family == "vegetal") and "cylinder" or "sphere"
		local leg = make(
			"Leg" .. i,
			shape,
			V(family == "arthropod" and 0.16 or 0.45, limbHeight, 0.5),
			V(x, y, z),
			palette[1],
			family == "arthropod" and A(0, 0, side * 0.9) or nil,
			true,
			torso
		)
		if not child then
			make("Foot" .. i, "wedge", V(0.55, 0.3, 0.8), V(x, 0.2, z + 0.2), palette[3], nil, false, leg)
		end
	end
	if family == "winged" or family == "draconic" then
		local feathers = child and 1 or stage == 2 and 3 or 5
		if def.acquisition == "special" then
			feathers = 8
		end
		local rows = def.acquisition == "special" and 3 or 1
		for _, side in { -1, 1 } do
			for row = 1, rows do
				for i = 1, feathers do
					local name = "Wing" .. (side < 0 and "L" or "R") .. "_" .. row .. "_" .. i
					local wingColor = palette[math.min(4, row + 1)]
					if def.acquisition == "special" then
						wingColor = Art.nearest(palette[row]:Lerp(palette[row + 1], 0.3 + i / feathers * 0.7))
					end
					make(
						name,
						"wedge",
						V(0.45, 0.25, child and 1 or 1.8 + i * 0.25),
						V(side * (w * 0.4 + i * 0.55), headPos.Y - 0.8 - row * 0.12, -row * 0.45 - i * 0.13),
						wingColor,
						A(
							d.feature == "stormcrown" and -0.5 or 0.1 * row,
							side * (d.feature == "stormcrown" and 0.8 or 0.25),
							side * (0.15 + i * 0.035)
						),
						true,
						torso
					)
				end
			end
		end
	end
	local tails = child and 1 or stage == 2 and 2 or 4
	if def.acquisition == "special" then
		tails = 11
	end
	for i = 1, tails do
		local feathered = family == "winged"
		local width = feathered and (def.acquisition == "special" and 0.54 or 0.46)
			or (d.tail == "leafbrush" and 0.75 or 0.55)
		local pos = feathered and V((i - (tails + 1) / 2) * 0.3, h * 0.6, -l * 0.6 - i * 0.15)
			or V(math.sin(i * 0.8) * 0.35, h * 0.4 - i * 0.12, -l * 0.5 - i * 0.55)
		make(
			"Tail" .. i,
			feathered and "wedge" or "sphere",
			V(width, 0.4, feathered and (2 + i * 0.25) or 0.9),
			pos,
			palette[i % 3 + 1],
			A(feathered and -0.25 or 0, (i - (tails + 1) / 2) * 0.09, 0),
			true,
			torso
		)
	end
	if def.acquisition ~= "special" then
		local tip = V(0, h * 0.4 - tails * 0.12, -l * 0.5 - tails * 0.55 - 0.3)
		local broad = { club = true, cinder = true, gravel = true, anchor = true, stump = true, hammer = true }
		if broad[d.tail] then
			make(
				"TailTip",
				"wedge",
				V(d.tail == "hammer" and 1.5 or 0.8, 0.5, 0.7),
				tip,
				palette[3],
				A(0, 0.3, 0),
				true,
				torso
			)
		elseif d.tail == "stinger" or d.tail == "bolt" or d.tail == "spade" then
			make(
				"TailTip",
				"wedge",
				V(0.3, child and 0.25 or 1.1, 0.6),
				tip + V(0, 0.5, 0),
				palette[3],
				A(0.35, 0, 0),
				true,
				torso
			)
		elseif d.tail == "lantern" or d.tail == "glowbulb" then
			local bulb = make("TailLantern", "sphere", V(0.8, 0.7, 0.7), tip, palette[3], nil, true, torso)
			bulb.Material = Enum.Material.Neon
		elseif not (family == "winged") then
			for _, side in { -1, 1 } do
				make(
					"TailFin" .. side,
					"wedge",
					V(0.2, child and 0.3 or 0.8, 1.2),
					tip + V(side * 0.4, 0, 0),
					palette[2],
					A(0, 0, side * 0.5),
					true,
					torso
				)
			end
		end
	end
	Features.trait(make, d, headPos, stage, head, torso)
	Features.surface(make, d, bodyCenter, stage, torso, bodySize)
	if def.acquisition == "special" then
		for i = 1, 16 do
			local a = i * math.pi / 8
			make(
				"HaloSegment" .. i,
				"cylinder",
				V(0.14, 0.45, 0.45),
				headPos + V(math.cos(a) * 1.8, 1.3 + math.sin(a) * 1.8, -0.6),
				palette[3],
				A(0, 0, a),
				true,
				head
			)
		end
		for i = 1, 8 do
			local a = i * math.pi / 4
			make(
				"HaloRay" .. i,
				"wedge",
				V(0.18, 0.7, 0.18),
				headPos + V(math.cos(a) * 2.2, 1.3 + math.sin(a) * 2.2, -0.6),
				palette[4],
				A(0, 0, -a),
				true,
				head
			)
		end
		for i = 1, 6 do
			make(
				"ChestFeather" .. i,
				"wedge",
				V(0.8, 0.25, 0.8),
				V(0, h * 0.7 + i * 0.2, l * 0.3),
				palette[i % 3 + 2 > 4 and 4 or i % 3 + 2],
				A(0.3, 0, 0),
				false,
				torso
			)
		end
	end
	if def.acquisition == "special" then
		for i = 1, 11 do
			make(
				"TailGildedTip" .. i,
				"wedge",
				V(0.24, 0.12, 0.8),
				V((i - 6) * 0.3, h * 0.6 - 0.3, -l * 0.6 - i * 0.15 - (2 + i * 0.25) * 0.35),
				palette[3]:Lerp(palette[4], i / 11),
				A(-0.25, (i - 6) * 0.09, 0),
				false,
				m:FindFirstChild("Tail" .. i)
			)
		end
	end
	Factory.validate(m)
	return m
end
function Factory.build(def, level, options)
	options = options or {}
	local stage = C.stage(level, def.id)
	local key = def.id .. ":" .. stage
	if not cache[key] then
		cache[key] = template(def, stage)
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
return Factory
