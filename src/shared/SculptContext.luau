--!nonstrict
-- Vocabulário de volumes; anatomia e proporções são desenhadas por espécie.
local Context = {}
Context.__index = Context
local V, A = Vector3.new, CFrame.Angles
function Context.new(model, design, stage)
	local root = Instance.new("Part")
	root.Name = "Root"
	root.Size = V(0.1, 0.1, 0.1) * design.stages[stage].scale
	root.Transparency = 1
	root.Anchored = true
	root.CanCollide, root.CanTouch, root.CanQuery = false, false, false
	root.Massless, root.CastShadow = true, false
	root.CollisionGroup = "Creatures"
	root.Parent = model
	model.PrimaryPart = root
	return setmetatable({
		model = model,
		root = root,
		stage = stage,
		young = stage == 1,
		adult = stage == 3,
		p = design.palette,
		cream = Color3.fromRGB(255, 235, 192),
		dark = Color3.fromRGB(36, 38, 65),
		gold = Color3.fromRGB(244, 184, 70),
		V = V,
		A = A,
		scale = design.stages[stage].scale,
		names = {},
	}, Context)
end
function Context:_make(name, kind, size, position, color, parent, motor, rotation)
	assert(
		typeof(size) == "Vector3" and typeof(position) == "Vector3" and typeof(color) == "Color3",
		"Volume inválido: " .. name
	)
	self.names[name] = (self.names[name] or 0) + 1
	local unique = name .. (self.names[name] > 1 and "_" .. self.names[name] or "")
	local part = Instance.new(kind == "wedge" and "WedgePart" or kind == "corner" and "CornerWedgePart" or "Part")
	part.Name, part.Size = unique, size * self.scale
	part.CFrame = CFrame.new(position * self.scale) * (rotation or CFrame.identity)
	part.Color, part.Material = color, Enum.Material.SmoothPlastic
	part.CanCollide, part.CanTouch, part.CanQuery = false, false, false
	part.Massless, part.Anchored, part.Reflectance = true, false, 0
	part.CastShadow, part.CollisionGroup = size.Magnitude > 0.8, "Creatures"
	part:SetAttribute("Feature", name:gsub("%d+", ""))
	part.Parent = self.model
	if kind == "sphere" then
		local mesh = Instance.new("SpecialMesh")
		mesh.MeshType, mesh.Scale = Enum.MeshType.Sphere, V(1, 1, 1)
		mesh.Parent = part
	elseif kind == "cylinder" then
		part.Shape = Enum.PartType.Cylinder
	end
	parent = parent or self.root
	if motor then
		local joint = Instance.new("Motor6D")
		joint.Name, joint.Part0, joint.Part1 = "J_" .. unique, parent, part
		joint.C0 = parent.CFrame:ToObjectSpace(part.CFrame)
		joint:SetAttribute("Role", name)
		joint:SetAttribute("Phase", self.names[name] * 0.57 + position.X * 1.6 + position.Z * 0.3)
		joint.Parent = part
	else
		local weld = Instance.new("WeldConstraint")
		weld.Name, weld.Part0, weld.Part1 = "W_" .. unique, parent, part
		weld.Parent = part
	end
	return part
end
function Context:sphere(name, size, pos, color, parent, motor, rotation)
	return self:_make(name, "sphere", size, pos, color, parent, motor, rotation)
end
function Context:block(name, size, pos, color, parent, motor, rotation)
	return self:_make(name, "block", size, pos, color, parent, motor, rotation)
end
function Context:wedge(name, size, pos, color, parent, motor, rotation)
	return self:_make(name, "wedge", size, pos, color, parent, motor, rotation)
end
function Context:segment(name, from, to, width, depth, color, parent, motor)
	local distance = (to - from).Magnitude
	assert(distance > 0.001, "Segmento vazio: " .. name)
	local direction = (to - from).Unit
	local up = math.abs(direction.Y) > 0.95 and V(0, 0, 1) or V(0, 1, 0)
	local rotation = CFrame.lookAt(V(0, 0, 0), direction, up) * A(-math.pi / 2, 0, 0)
	return self:sphere(
		name,
		V(width, distance + math.min(width, depth) * 0.65, depth),
		(from + to) * 0.5,
		color,
		parent,
		motor,
		rotation
	)
end
function Context:leaf(name, from, to, width, color, parent, motor)
	local direction = (to - from).Unit
	local normal = V(0, 0, 1) - direction * direction:Dot(V(0, 0, 1))
	if normal.Magnitude < 0.05 then
		normal = V(0, 1, 0) - direction * direction:Dot(V(0, 1, 0))
	end
	normal = normal.Unit
	local right = direction:Cross(normal).Unit
	local rotation = CFrame.fromMatrix(V(0, 0, 0), right, direction, normal)
	return self:sphere(
		name,
		V(width, (to - from).Magnitude, width * 0.26),
		(from + to) * 0.5,
		color,
		parent,
		motor,
		rotation
	)
end
function Context:eyes(head, center, spacing, radius, iris, tilt)
	iris, tilt = iris or self.gold, tilt or 0
	for _, side in { -1, 1 } do
		local label = side < 0 and "L" or "R"
		local pos = center + V(side * spacing * 0.5, 0, 0)
		local eye = self:sphere(
			"Eye" .. label,
			V(radius * 2, radius * 2.28, radius * 0.8),
			pos,
			self.cream,
			head,
			true,
			A(0, side * 0.11, side * tilt)
		)
		self:sphere(
			"Iris" .. label,
			V(radius * 1.5, radius * 1.8, radius * 0.48),
			pos + V(0, -radius * 0.03, radius * 0.35),
			iris,
			eye
		)
		self:sphere(
			"Pupil" .. label,
			V(radius * 0.97, radius * 1.43, radius * 0.3),
			pos + V(0, -radius * 0.04, radius * 0.57),
			self.dark,
			eye
		)
		self:sphere(
			"EyeGlint" .. label,
			V(radius * 0.46, radius * 0.5, radius * 0.2),
			pos + V(-radius * 0.21, radius * 0.38, radius * 0.74),
			Color3.fromRGB(255, 249, 229),
			eye
		)
		self:sphere(
			"EyeGlintSmall" .. label,
			V(radius * 0.21, radius * 0.23, radius * 0.15),
			pos + V(radius * 0.25, -radius * 0.25, radius * 0.74),
			self.cream,
			eye
		)
	end
end
return Context
