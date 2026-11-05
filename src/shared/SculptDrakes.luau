--!nonstrict
-- Anatomias autorais: volumes sobrepostos, membros articulados e detalhes presos ao esqueleto.
local V = Vector3.new
local A = CFrame.Angles
local C = Color3.fromRGB
local D = {}

local function palette(a, b, d, e)
	return { C(table.unpack(a)), C(table.unpack(b)), C(table.unpack(d)), C(table.unpack(e)) }
end
local function foot(c, name, hip, knee, ankle, width, color, claw, parent, digits)
	local upper = c:segment("Leg" .. name, hip, knee, width, width * 0.95, color, parent, true)
	c:sphere("Knee" .. name, V(width * 0.82, width * 0.78, width * 0.82), knee, color, upper)
	local lower = c:segment("Shin" .. name, knee, ankle, width * 0.65, width * 0.7, color, upper)
	local paw = c:sphere(
		"Paw" .. name,
		V(width * 1.2, width * 0.55, width * 1.65),
		ankle + V(0, -width * 0.12, width * 0.38),
		color,
		lower
	)
	for i = 1, digits do
		c:leaf(
			"Toe" .. name .. i,
			ankle + V((i - (digits + 1) / 2) * width * 0.28, -width * 0.13, width * 0.8),
			ankle + V((i - (digits + 1) / 2) * width * 0.32, -width * 0.19, width * 1.12),
			width * 0.19,
			claw,
			paw
		)
	end
	return upper
end
local function smile(c, head, center, width, color)
	c:segment("SmileL", center + V(-width, 0.05, 0), center + V(0, -0.03, 0.045), 0.055, 0.04, color, head)
	c:segment("SmileR", center + V(0, -0.03, 0.045), center + V(width, 0.05, 0), 0.055, 0.04, color, head)
end

D.vulcanodrago = function(c)
	local s, young, adult = c.stage, c.young, c.adult
	local p = palette({ 97, 56, 75 }, { 177, 75, 59 }, { 246, 155, 71 }, { 255, 227, 167 })
	local length = young and 2.65 or adult and 4.35 or 3.55
	local shoulder = young and 1.35 or adult and 2.05 or 1.7
	local body = c:sphere("Body", V(2.4, 1.9, length), V(0, shoulder, -0.25), p[1], nil, true)
	c:sphere("Chest", V(1.9, 2.1, 2.05), V(0, shoulder + 0.25, length * 0.24), p[2], body)
	c:sphere("Belly", V(1.4, 1.4, 1.85), V(0, shoulder + 0.02, length * 0.32), p[4], body)
	local neck = c:segment(
		"Neck",
		V(0, shoulder + 0.4, length * 0.22),
		V(0, shoulder + 1.15, length * 0.42),
		young and 1.1 or 1.3,
		1.25,
		p[2],
		body
	)
	local headY, headZ = shoulder + (young and 1 or 1.45), length * 0.43
	local ratio = young and 1.16 or 1
	local head = c:sphere(
		"Head",
		V(adult and 1.94 or 2.05, adult and 1.52 or 1.65, adult and 2.15 or 1.95) * ratio,
		V(0, headY, headZ),
		p[2],
		neck,
		true
	)
	c:sphere("Jaw", V(1.8, 0.48, 1.55) * ratio, V(0, headY - 0.58, headZ + 0.65), p[4], head)
	c:sphere(
		"Muzzle",
		V(adult and 1.62 or 1.52, 0.65, adult and 1.5 or 1.3) * ratio,
		V(0, headY - 0.27, headZ + 0.85),
		p[2],
		head
	)
	c:eyes(head, V(0, headY + 0.2, headZ + 0.87 * ratio), 1.12 * ratio, young and 0.29 or 0.25, p[3], 0.1)
	for _, side in { -1, 1 } do
		c:sphere(
			"Nostril" .. side,
			V(0.14, 0.1, 0.08),
			V(side * 0.38, headY - 0.05, headZ + 1.47 * ratio),
			c.dark,
			head
		)
		c:leaf(
			"Horn" .. side,
			V(side * 0.72, headY + 0.55, headZ - 0.25),
			V(side * (young and 0.8 or 1.18), headY + (young and 0.82 or 1.5), headZ - 0.5),
			young and 0.25 or 0.42,
			p[4],
			head
		)
		if adult then
			c:leaf(
				"CheekHorn" .. side,
				V(side * 0.87, headY - 0.15, headZ - 0.1),
				V(side * 1.38, headY + 0.15, headZ - 0.65),
				0.35,
				p[1],
				head
			)
		end
		for _, front in { true, false } do
			local z = front and length * 0.22 or -length * 0.3
			foot(
				c,
				(front and "Fore" or "Hind") .. side,
				V(side * 0.88, shoulder - 0.15, z),
				V(side * 1.25, 0.8, z - 0.23),
				V(side * 1.22, 0.3, z + 0.15),
				young and 0.49 or 0.66,
				p[2],
				p[4],
				body,
				young and 2 or 3
			)
		end
	end
	smile(c, head, V(0, headY - 0.39, headZ + 1.42 * ratio), 0.55, c.dark)
	local tailParent = body
	local from = V(0, shoulder - 0.25, -length * 0.48)
	for i = 1, s + 2 do
		local to = V(math.sin(i * 0.55) * i * 0.17, shoulder - 0.35 + i * 0.08, -length * 0.48 - i * 0.7)
		tailParent = c:segment(
			"Tail" .. i,
			from,
			to,
			math.max(0.25, 0.95 - i * 0.16),
			math.max(0.2, 0.9 - i * 0.16),
			p[1],
			tailParent,
			i == 1
		)
		from = to
	end
	c:leaf("TailSpade", from - V(0, 0, 0.15), from + V(0, 0.4, -0.85), 0.9, p[3], tailParent)
	for i = 1, s + 2 do
		local z = length * 0.25 - i * length / (s + 3)
		c:leaf(
			"BasaltSpine" .. i,
			V(0, shoulder + 0.8, z),
			V(0, shoulder + 1.35 + (adult and 0.15 or 0), z - 0.38),
			0.62,
			i % 2 == 0 and p[3] or p[1],
			body
		)
	end
	if not young then
		for _, side in { -1, 1 } do
			local wing = c:segment(
				"Wing" .. side,
				V(side * 0.8, shoulder + 0.7, -0.1),
				V(side * 2.1, shoulder + 1.15, -0.7),
				0.32,
				0.32,
				p[1],
				body,
				true
			)
			for i = 1, adult and 4 or 2 do
				c:leaf(
					"WingMembrane" .. side .. i,
					V(side * 1.6, shoulder + 1, -0.5),
					V(side * (2.6 + i * 0.32), shoulder + 1.65 - i * 0.22, -0.25 - i * 0.52),
					0.85,
					p[2],
					wing
				)
			end
		end
	end
	-- As faces ósseas prolongam o crânio; o peito sustenta o pescoço.
	c:sphere(
		"ThroatKeel",
		V(young and 0.9 or 1.15, young and 1.1 or 1.65, 0.7),
		V(0, shoulder + 0.53, length * 0.34 + 0.37),
		p[4],
		neck,
		false,
		A(-0.25, 0, 0)
	)
	for _, side in { -1, 1 } do
		c:segment(
			"BasaltBrow" .. side,
			V(side * 0.32, headY + 0.48, headZ + 0.88),
			V(side * 0.85, headY + 0.58, headZ + 0.72),
			young and 0.13 or 0.19,
			0.16,
			p[1],
			head
		)
		if not young then
			c:sphere("JawHinge" .. side, V(0.52, 0.62, 0.67), V(side * 0.8, headY - 0.22, headZ + 0.18), p[1], head)
			c:leaf(
				"IvoryFang" .. side,
				V(side * 0.57, headY - 0.33, headZ + 1.28),
				V(side * 0.59, headY - 0.68, headZ + 1.37),
				0.18,
				p[4],
				head
			)
		end
		if adult then
			c:sphere(
				"ShoulderScute" .. side,
				V(0.64, 1.1, 1.32),
				V(side * 1.0, shoulder + 0.12, length * 0.12),
				p[1],
				body,
				false,
				A(0.18, 0, side * 0.24)
			)
		end
	end
	return { body = body, head = head }
end

D.trovoraptor = function(c)
	local s, young, adult = c.stage, c.young, c.adult
	local p = palette({ 56, 96, 136 }, { 103, 165, 191 }, { 255, 211, 102 }, { 245, 231, 194 })
	local hipY = young and 1.05 or adult and 2.25 or 1.65
	local body = c:sphere(
		"Body",
		V(1.75, young and 1.4 or 2.15, young and 2.1 or 2.85),
		V(0, hipY + 0.65, -0.5),
		p[1],
		nil,
		true,
		A(-0.25, 0, 0)
	)
	c:sphere("Chest", V(1.27, 1.55, 1.65), V(0, hipY + 0.95, 0.35), p[4], body, false, A(-0.23, 0, 0))
	local neckTop = V(0, hipY + (young and 1.05 or adult and 1.72 or 1.85), adult and 1.32 or 1.03)
	local neck = c:segment("Neck", V(0, hipY + 0.85, 0.3), neckTop, young and 0.8 or 0.93, 0.86, p[2], body)
	local head = c:sphere(
		"Head",
		V(young and 1.7 or 1.45, young and 1.4 or 1.2, young and 1.7 or adult and 2.15 or 1.9),
		neckTop,
		p[2],
		neck,
		true
	)
	c:sphere("Muzzle", V(1.1, 0.65, 1.45), neckTop + V(0, -0.2, 0.85), p[2], head)
	c:sphere("Jaw", V(1.02, 0.25, 1.3), neckTop + V(0, -0.48, 0.83), p[4], head)
	c:eyes(head, neckTop + V(0, 0.22, 0.75), young and 1.04 or 0.9, young and 0.26 or 0.21, p[3], 0.16)
	smile(c, head, neckTop + V(0, -0.29, 1.48), 0.38, c.dark)
	for _, side in { -1, 1 } do
		foot(
			c,
			"Hind" .. side,
			V(side * 0.65, hipY + 0.1, -0.8),
			V(side * 1.02, hipY * 0.7, 0.05),
			V(side * 0.97, 0.25, -0.32),
			young and 0.55 or 0.78,
			p[1],
			p[3],
			body,
			3
		)
		local arm = c:segment(
			"Forearm" .. side,
			V(side * 0.62, hipY + 1.1, 0.4),
			V(side * 1.05, hipY + 0.65, 0.95),
			0.3,
			0.3,
			p[2],
			body,
			true
		)
		for digit = 1, young and 1 or 2 do
			c:leaf(
				"ForeClaw" .. side .. digit,
				V(side * (1 + digit * 0.08), hipY + 0.66, 0.92),
				V(side * (1.05 + digit * 0.1), hipY + 0.48, 1.25),
				0.13,
				p[3],
				arm
			)
		end
		c:leaf(
			"LightningEar" .. side,
			neckTop + V(side * 0.55, 0.35, -0.25),
			neckTop + V(side * 0.92, young and 0.95 or 1.35, -0.55),
			0.38,
			p[3],
			head
		)
		if not young then
			c:leaf(
				"LightningProng" .. side,
				neckTop + V(side * 0.8, 0.7, -0.42),
				neckTop + V(side * 1.22, 0.98, -0.2),
				0.27,
				p[4],
				head
			)
		end
	end
	local tail, from = body, V(0, hipY + 0.3, -1.65)
	for i = 1, s + 2 do
		local to = V(math.sin(i * 0.45) * 0.6, hipY + 0.25 + i * 0.09, -1.65 - i * 0.72)
		tail = c:segment(
			"Tail" .. i,
			from,
			to,
			math.max(0.12, 0.67 - i * 0.12),
			math.max(0.12, 0.67 - i * 0.12),
			p[1],
			tail,
			i == 1
		)
		from = to
	end
	c:leaf("TailBoltA", from, from + V(0.5, 0.48, -0.65), 0.46, p[3], tail)
	c:leaf("TailBoltB", from + V(0.4, 0.35, -0.55), from + V(0.1, 0.8, -1), 0.35, p[3], tail)
	for i = 1, s + 1 do
		c:leaf("DorsalBolt" .. i, V(0, hipY + 1.3, 0.5 - i * 0.48), V(0, hipY + 1.9, 0.2 - i * 0.48), 0.5, p[3], body)
	end
	if adult then
		for _, side in { -1, 1 } do
			for i = 1, 3 do
				c:leaf(
					"HipQuill" .. side .. i,
					V(side * 0.7, hipY + 0.4, -1.25),
					V(side * (1.5 + i * 0.15), hipY + 0.8 - i * 0.2, -1.5 - i * 0.25),
					0.4,
					p[2],
					body
				)
			end
		end
	end
	for _, side in { -1, 1 } do
		c:segment(
			"RaptorBrow" .. side,
			neckTop + V(side * 0.22, 0.42, 0.86),
			neckTop + V(side * 0.66, 0.51, 0.67),
			young and 0.11 or 0.15,
			0.13,
			p[1],
			head
		)
		if adult then
			local clawBase = V(side * 0.78, 0.31, -0.02)
			local knuckle = c:sphere(
				"SickleKnuckle" .. side,
				V(0.31, 0.31, 0.35),
				clawBase,
				p[3],
				c.model:FindFirstChild("PawHind" .. side) or body
			)
			c:segment("SickleClawRoot" .. side, clawBase, clawBase + V(0, 0.18, 0.36), 0.23, 0.22, p[4], knuckle)
			c:leaf(
				"SickleClawTip" .. side,
				clawBase + V(0, 0.18, 0.29),
				clawBase + V(0, -0.1, 0.65),
				0.17,
				p[4],
				knuckle
			)
			c:leaf(
				"SternumFeather" .. side,
				V(side * 0.35, hipY + 1.42, 0.9),
				V(side * 0.57, hipY + 0.64, 1.1),
				0.48,
				p[4],
				body
			)
		end
	end
	return { body = body, head = head }
end

D.caudalume = function(c)
	local young, adult = c.young, c.adult
	local p = palette({ 93, 77, 127 }, { 163, 135, 178 }, { 124, 205, 188 }, { 255, 220, 137 })
	local body = c:sphere(
		"Body",
		V(young and 1.65 or 1.8, young and 1.45 or 1.9, 2.2),
		V(0, young and 1.2 or 1.65, 0.45),
		p[1],
		nil,
		true
	)
	local hy = young and 1.9 or adult and 2.85 or 2.35
	local head =
		c:sphere("Head", V(young and 1.85 or 1.75, young and 1.7 or 1.85, 1.6), V(0, hy, 1.15), p[2], body, true)
	c:sphere("FaceMask", V(1.37, 1.2, 0.5), V(0, hy - 0.03, 1.84), p[4], head)
	c:eyes(head, V(0, hy + 0.13, 2.02), young and 0.96 or 0.88, young and 0.27 or 0.24, p[3], -0.1)
	c:sphere("Nose", V(0.2, 0.14, 0.12), V(0, hy - 0.18, 2.13), c.dark, head)
	smile(c, head, V(0, hy - 0.34, 2.1), 0.3, p[1])
	for _, side in { -1, 1 } do
		c:leaf(
			"EarFin" .. side,
			V(side * 0.66, hy + 0.38, 1.05),
			V(side * (young and 1.25 or 1.55), hy + 0.85, 0.8),
			young and 0.55 or 0.8,
			p[3],
			head
		)
		if not young then
			c:leaf(
				"CheekFrill" .. side,
				V(side * 0.65, hy - 0.35, 1.2),
				V(side * 1.18, hy - 0.65, 0.85),
				0.55,
				p[2],
				head
			)
		end
	end
	local tail, from = body, V(0, young and 0.9 or 1.25, -0.35)
	local segments = young and 4 or adult and 8 or 6
	for i = 1, segments do
		local t = i / segments
		local to = V(
			math.sin(t * math.pi * 1.4) * (young and 0.7 or 1.3),
			0.5 + t * t * (young and 1.7 or 3.6),
			-0.35 - math.sin(t * math.pi * 0.75) * (young and 2.3 or 4.6)
		)
		local width = 1.25 * (1 - t * 0.78)
		tail = c:segment("Tail" .. i, from, to, width, width * 1.05, p[1], tail, i == 1)
		if i % 2 == 0 then
			c:sphere("LuminousSpot" .. i, V(width * 0.5, width * 0.45, 0.12), to + V(0, 0.04, width * 0.46), p[3], tail)
		end
		from = to
	end
	local bulb = c:sphere(
		"TailLantern",
		V(young and 0.75 or 1.1, young and 0.92 or 1.4, young and 0.75 or 1.1),
		from + V(0, 0.4, 0),
		p[4],
		tail
	)
	for _, side in { -1, 1 } do
		c:leaf(
			"LanternPetal" .. side,
			from + V(side * 0.25, -0.1, 0),
			from + V(side * (adult and 0.85 or 0.6), 0.65, -0.1),
			adult and 0.55 or 0.4,
			p[3],
			bulb
		)
	end
	local antenna = c:segment("AntennaStem", V(0, hy + 0.55, 1.15), V(0.15, hy + 1.15, 1.45), 0.12, 0.12, p[1], head)
	c:sphere("AntennaPearl", V(0.3, 0.34, 0.3), V(0.15, hy + 1.2, 1.45), p[4], antenna)
	if adult then
		for i = 1, 3 do
			c:leaf(
				"NeckRuff" .. i,
				V((i - 2) * 0.45, hy - 0.75, 1.45),
				V((i - 2) * 0.7, hy - 1.3, 1.55),
				0.55,
				p[3],
				body
			)
		end
	end
	for _, side in { -1, 1 } do
		c:segment(
			"LanternLid" .. side,
			V(side * 0.24, hy + 0.4, 2.07),
			V(side * 0.67, hy + 0.48, 1.98),
			0.105,
			0.085,
			p[2],
			head
		)
		if not young then
			c:leaf(
				"PelvicFin" .. side,
				V(side * 0.57, 1.05, 0.18),
				V(side * (adult and 1.65 or 1.19), 0.55, -0.45),
				adult and 0.72 or 0.5,
				p[3],
				body
			)
		end
		if adult then
			c:segment(
				"LanternGill" .. side,
				V(side * 0.85, hy - 0.1, 1.25),
				V(side * 1.02, hy - 0.45, 1.03),
				0.22,
				0.19,
				p[3],
				head
			)
			c:leaf(
				"CrescentLobe" .. side,
				V(side * 0.72, hy + 0.5, 0.98),
				V(side * 1.18, hy + 1.13, 0.73),
				0.53,
				p[2],
				head
			)
		end
	end
	return { body = body, head = head }
end

D.vagalumorte = function(c)
	local young, adult = c.young, c.adult
	local p = palette({ 72, 67, 105 }, { 143, 116, 169 }, { 175, 217, 179 }, { 255, 220, 160 })
	local height = young and 1.4 or adult and 2.65 or 1.85
	local body = c:sphere(
		"Body",
		V(1.2, adult and 1.3 or 1.05, young and 1.7 or adult and 2.85 or 2.4),
		V(0, height, -0.25),
		p[1],
		nil,
		true,
		adult and A(-0.12, 0, 0) or nil
	)
	local abdomen = c:sphere(
		"Abdomen",
		V(young and 1.35 or adult and 1.85 or 1.6, adult and 1.35 or 1.05, young and 1.5 or adult and 2.9 or 2.1),
		V(0, height - 0.15, adult and -1.65 or -1.35),
		p[2],
		body
	)
	local bulb = c:sphere(
		"GlowBulb",
		V(adult and 1.22 or 0.85, adult and 1.05 or 0.7, adult and 1.25 or 0.85),
		V(0, height - 0.12, young and -1.9 or adult and -2.8 or -2.25),
		p[3],
		abdomen
	)
	if adult then
		-- O adulto ganha casulo-lanterna, com nervuras luminosas entre as placas.
		for rib = 1, 4 do
			c:sphere(
				"LanternRib" .. rib,
				V(1.6 - rib * 0.09, 0.17, 0.62),
				V(0, height + 0.43 - rib * 0.025, -0.85 - rib * 0.4),
				p[4],
				abdomen
			)
		end
		for _, side in { -1, 1 } do
			c:leaf(
				"LanternCalyx" .. side,
				V(side * 0.25, height - 0.15, -2.45),
				V(side * 0.6, height + 0.35, -3.25),
				0.42,
				p[4],
				bulb
			)
		end
	end
	local head = c:sphere(
		"Head",
		V(young and 1.65 or adult and 1.48 or 1.6, adult and 1.48 or 1.35, 1.25),
		V(0, height + 0.25, 0.95),
		p[2],
		body,
		true
	)
	c:sphere("FaceMask", V(1.45, 1.1, 0.4), V(0, height + 0.24, 1.48), p[4], head)
	c:eyes(
		head,
		V(0, height + 0.35, 1.63),
		adult and 0.85 or 0.97,
		young and 0.28 or adult and 0.22 or 0.25,
		p[3],
		-0.08
	)
	c:sphere("MothNose", V(0.19, 0.16, 0.12), V(0, height + 0.05, 1.74), p[1], head)
	for _, side in { -1, 1 } do
		local antenna = c:segment(
			"Antenna" .. side,
			V(side * 0.43, height + 0.8, 0.87),
			V(side * 0.86, height + 1.5, 0.96),
			0.1,
			0.1,
			p[1],
			head
		)
		for branch = 1, young and 2 or 4 do
			local t = branch / 5
			c:leaf(
				"AntennaComb" .. side .. branch,
				V(side * (0.43 + t * 0.43), height + 0.8 + t * 0.7, 0.91),
				V(side * (0.69 + t * 0.43), height + 0.92 + t * 0.7, 0.92),
				0.12,
				p[4],
				antenna
			)
		end
		local spread = young and 1.6 or adult and 4.1 or 2.8
		local wing = c:segment(
			"Wing" .. side,
			V(side * 0.38, height + 0.25, 0.05),
			V(side * spread * 0.5, height + 0.75, -0.4),
			0.22,
			0.22,
			p[1],
			body,
			true
		)
		c:leaf(
			"ForeWing" .. side,
			V(side * 0.65, height + 0.35, 0.1),
			V(side * spread, height + (adult and 1.7 or 1.1), 0.55),
			spread * 0.69,
			p[2],
			wing
		)
		c:leaf(
			"HindWing" .. side,
			V(side * 0.5, height + 0.15, -0.45),
			V(side * spread * 0.83, height - 0.35, -1.95),
			spread * 0.57,
			p[3],
			wing
		)
		local mark = V(side * spread * 0.72, height + (adult and 1.05 or 0.72), adult and 1.02 or 0.79)
		c:sphere(
			"WingEyespot" .. side,
			V(young and 0.48 or 0.8, young and 0.58 or 0.95, 0.16),
			mark,
			p[1],
			wing,
			false,
			A(0, 0, side * -0.55)
		)
		c:sphere(
			"WingMoon" .. side,
			V(young and 0.28 or 0.48, young and 0.36 or 0.62, 0.18),
			mark + V(0, 0.02, 0.08),
			p[4],
			wing
		)
		for leg = 1, 3 do
			local from = V(side * 0.45, height - 0.1, 0.6 - leg * 0.58)
			local elbow = from + V(side * 0.65, -0.25, 0.18)
			local upper = c:segment("Leg" .. side .. leg, from, elbow, 0.13, 0.13, p[1], body, true)
			c:segment("MothTarsus" .. side .. leg, elbow, elbow + V(side * 0.13, -0.5, 0.25), 0.09, 0.1, p[4], upper)
		end
		if adult then
			-- Três lobos e nervuras dão desenho próprio à asa adulta, além do crescimento.
			for lobe = 1, 3 do
				local start = V(side * (0.8 + lobe * 0.25), height + 0.4, -0.2)
				local finish = V(side * (spread - lobe * 0.38), height + 2.6 - lobe * 0.62, 0.8 - lobe * 0.45)
				c:leaf(
					"MoonWingLobe" .. side .. lobe,
					start,
					finish,
					1.45 - lobe * 0.1,
					lobe % 2 == 0 and p[3] or p[2],
					wing
				)
				c:segment(
					"MoonWingVein" .. side .. lobe,
					start + V(0, 0, 0.72),
					finish + V(0, -0.12, 0.72),
					0.075,
					0.09,
					p[4],
					wing
				)
			end
			local lowerMark = V(side * spread * 0.55, height - 0.18, -0.7)
			c:sphere("HindMoonRim" .. side, V(0.6, 0.7, 0.18), lowerMark, p[1], wing)
			c:sphere("HindMoonPearl" .. side, V(0.38, 0.48, 0.2), lowerMark + V(0, 0.03, 0.1), p[4], wing)
			c:leaf(
				"WingRibbon" .. side,
				V(side * 1.35, height - 0.25, -1.6),
				V(side * 1.8, height - 0.75, -3),
				0.45,
				p[2],
				wing
			)
			c:sphere("RibbonPearl" .. side, V(0.28, 0.35, 0.28), V(side * 1.8, height - 0.7, -3), p[3], wing)
		end
	end
	if adult then
		for i = 1, 5 do
			local x = (i - 3) * 0.27
			c:leaf(
				"MoonMothRuff" .. i,
				V(x * 0.7, height + 0.35, 0.65),
				V(x * 1.45, height - 0.52 + math.abs(x) * 0.2, 1.1),
				0.48,
				p[4],
				body
			)
		end
	end
	for _, side in { -1, 1 } do
		c:leaf(
			"MothCheekTuft" .. side,
			V(side * 0.5, height + 0.05, 1.1),
			V(side * 0.89, height - 0.36, 1.2),
			young and 0.3 or 0.45,
			p[4],
			head
		)
		if adult then
			for edge = 1, 2 do
				local x = side * (2.6 + edge * 0.53)
				c:leaf(
					"ScallopedWing" .. side .. edge,
					V(x, height + 0.63, 0.55),
					V(x + side * 0.33, height + 0.08, 0.56),
					0.66,
					p[2],
					c.model:FindFirstChild("Wing" .. side) or body
				)
			end
		end
	end
	if not young then
		local prob =
			c:segment("Proboscis1", V(0, height - 0.02, 1.71), V(0.12, height - 0.24, 1.88), 0.12, 0.12, p[1], head)
		c:segment("Proboscis2", V(0.12, height - 0.24, 1.88), V(0.29, height - 0.21, 1.82), 0.09, 0.09, p[1], prob)
	end
	return { body = body, head = head }
end

D.reinevoento = function(c)
	local s, young, adult = c.stage, c.young, c.adult
	local p = palette({ 68, 58, 94 }, { 136, 117, 168 }, { 193, 204, 173 }, { 241, 218, 166 })
	local top = young and 2.35 or adult and 4.5 or 3.5
	local body = c:sphere(
		"Body",
		V(young and 1.9 or 2.65, top * 0.62, young and 1.15 or 1.7),
		V(0, top * 0.48 + 0.5, -0.2),
		p[1],
		nil,
		true
	)
	local head =
		c:sphere("Head", V(young and 1.85 or 1.9, young and 1.6 or 1.85, 1.3), V(0, top, 0.18), p[2], body, true)
	c:sphere("RoyalMask", V(1.5, 1.45, 0.45), V(0, top - 0.02, 0.72), p[4], head)
	c:eyes(head, V(0, top + 0.08, 0.91), 0.88, young and 0.24 or 0.2, p[3], 0.04)
	c:sphere("NoseBridge", V(0.22, 0.35, 0.18), V(0, top - 0.12, 1), p[2], head)
	c:segment("RoyalMouth", V(-0.2, top - 0.42, 0.98), V(0.2, top - 0.42, 0.98), 0.045, 0.04, p[1], head)
	for _, side in { -1, 1 } do
		local shoulder = V(side * (young and 0.75 or 1.25), top - 1.05, -0.12)
		local veil = c:segment(
			"VeilShoulder" .. side,
			shoulder,
			V(side * (young and 1.1 or 1.75), top - 1.7, -0.25),
			0.75,
			0.7,
			p[2],
			body,
			true
		)
		c:leaf(
			"MantlePanel" .. side,
			shoulder,
			V(side * (young and 0.85 or 1.55), 0.45, -0.6),
			young and 1.1 or 1.65,
			p[2],
			veil
		)
		c:leaf(
			"IvoryMantleTrim" .. side,
			shoulder + V(side * 0.13, -0.2, 0.3),
			V(side * (young and 0.9 or 1.6), 0.55, -0.2),
			0.18,
			p[4],
			veil
		)
		c:sphere(
			"SpectralHand" .. side,
			V(0.52, 0.68, 0.5),
			V(side * (young and 1.12 or 1.8), top - 1.95, 0.1),
			p[3],
			veil
		)
		if not young then
			c:leaf(
				"RoyalCollar" .. side,
				V(side * 0.5, top - 0.72, 0.1),
				V(side * 1.28, top - 0.28, -0.25),
				0.7,
				p[4],
				body
			)
		end
	end
	for i = 1, young and 3 or adult and 7 or 5 do
		local x = (i - (young and 2 or adult and 4 or 3)) * (young and 0.38 or 0.42)
		c:leaf(
			"VeilHem" .. i,
			V(x * 0.7, 1.4, -0.2),
			V(x, 0.2 + math.abs(x) * 0.1, -0.9 - math.cos(i) * 0.3),
			0.7,
			i % 2 == 0 and p[1] or p[2],
			body
		)
	end
	local crownBase = c:sphere("CrownCirclet", V(1.65, 0.2, 1.05), V(0, top + 0.7, 0.05), p[4], head)
	for i = 1, young and 3 or adult and 7 or 5 do
		local n = young and 3 or adult and 7 or 5
		local x = (i - (n + 1) / 2) * 0.23
		c:leaf(
			"CrownProng" .. i,
			V(x, top + 0.72, 0.35),
			V(x * 1.25, top + 1.05 + (1 - math.abs(x)) * (adult and 0.7 or 0.35), 0.27),
			0.25,
			p[4],
			crownBase
		)
	end
	for i = 1, s + 1 do
		c:sphere(
			"MantleStar" .. i,
			V(0.13, 0.22, 0.1),
			V((i % 2 == 0 and 1 or -1) * 0.35, top - 1.1 - i * 0.35, 0.67),
			p[4],
			body
		)
	end
	if adult then
		c:sphere("HeartJewelRim", V(0.7, 0.85, 0.3), V(0, top - 1.2, 0.7), p[4], body)
		c:sphere("HeartJewel", V(0.44, 0.57, 0.31), V(0, top - 1.18, 0.86), p[3], body)
	end
	c:sphere("CarvedJaw", V(young and 1.0 or 1.14, 0.34, 0.43), V(0, top - 0.57, 0.68), p[4], head)
	for _, side in { -1, 1 } do
		c:segment(
			"RoyalBrow" .. side,
			V(side * 0.18, top + 0.32, 0.96),
			V(side * 0.61, top + 0.4, 0.86),
			0.12,
			0.1,
			p[2],
			head
		)
		if not young then
			c:sphere(
				"CloakFold" .. side,
				V(0.55, top * 0.48, 0.58),
				V(side * 0.88, top * 0.42, 0.27),
				p[2],
				body,
				false,
				A(0, 0, -side * 0.13)
			)
		end
		if adult then
			c:leaf(
				"RoyalBeard" .. side,
				V(side * 0.22, top - 0.67, 0.74),
				V(side * 0.46, top - 1.34, 0.82),
				0.32,
				p[3],
				head
			)
			c:segment(
				"SpectralFinger" .. side,
				V(side * 1.9, top - 2.05, 0.1),
				V(side * 2.03, top - 2.45, 0.31),
				0.17,
				0.16,
				p[3],
				c.model:FindFirstChild("SpectralHand" .. side) or body
			)
		end
	end
	return { body = body, head = head }
end

D.cinzavento = function(c)
	local s, young, adult = c.stage, c.young, c.adult
	local p = palette({ 99, 76, 117 }, { 179, 123, 122 }, { 237, 193, 155 }, { 166, 180, 204 })
	local h = young and 1.3 or adult and 2.4 or 1.8
	local body = c:sphere("Body", V(young and 1.8 or 2.2, 1.65, young and 2.5 or 3.5), V(0, h, -0.45), p[1], nil, true)
	c:sphere("Chest", V(1.5, 1.6, 1.8), V(0, h + 0.15, 0.55), p[3], body)
	local neck = c:segment("Neck", V(0, h + 0.45, 0.7), V(0, h + 1.15, 1.6), 1.1, 1, p[2], body)
	local headPos = V(0, h + 1.35, 1.7)
	local head = c:sphere("Head", V(young and 1.9 or 1.7, young and 1.6 or 1.4, 1.8), headPos, p[2], neck, true)
	c:sphere(
		"SweptMuzzle",
		V(adult and 1.18 or 1.3, 0.68, adult and 1.78 or 1.5),
		headPos + V(0, -0.3, 0.8),
		p[2],
		head
	)
	c:sphere("LowerJaw", V(1.2, 0.26, 1.4), headPos + V(0, -0.57, 0.82), p[3], head)
	c:eyes(head, headPos + V(0, 0.17, 0.82), 1.02, young and 0.27 or 0.22, p[4], 0.06)
	smile(c, head, headPos + V(0, -0.36, 1.48), 0.4, c.dark)
	for _, side in { -1, 1 } do
		c:leaf(
			"SweptHorn" .. side,
			headPos + V(side * 0.56, 0.45, -0.15),
			headPos + V(side * 0.9, young and 0.9 or 1.22, -0.95),
			0.4,
			p[3],
			head
		)
		c:leaf(
			"CheekStreamer" .. side,
			headPos + V(side * 0.7, -0.2, -0.15),
			headPos + V(side * 1.1, -0.05, -1.05),
			0.5,
			p[4],
			head
		)
		foot(
			c,
			"Hind" .. side,
			V(side * 0.75, h - 0.1, -1.2),
			V(side * 1.1, 0.8, -0.65),
			V(side * 1, 0.25, -0.9),
			young and 0.5 or 0.64,
			p[2],
			p[3],
			body,
			young and 2 or 3
		)
		local spread = young and 1.7 or adult and 4.4 or 3.2
		local shoulder = V(side * 0.8, h + 0.45, 0.3)
		local elbow = V(side * spread * 0.6, h + 1.05, 0.1)
		local tip = V(side * spread, h + 1.6 + (adult and side * 0.16 or 0), -1.1)
		local wing = c:segment("Wing" .. side, shoulder, elbow, 0.38, 0.38, p[1], body, true)
		c:segment("WingForearm" .. side, elbow, tip, 0.27, 0.3, p[2], wing)
		for i = 1, young and 3 or adult and 6 or 4 do
			local t = i / (young and 3 or adult and 6 or 4)
			local from = elbow:Lerp(tip, t)
			local to = V(side * (spread * (0.5 + t * 0.5)), h + 0.25 - t * 0.18, -1.2 - t * (adult and 1.65 or 0.9))
			c:leaf("AshWingMembrane" .. side .. i, from, to, young and 0.65 or 0.95, i % 2 == 0 and p[4] or p[2], wing)
		end
		c:leaf("WingThumb" .. side, elbow, elbow + V(side * 0.25, 0.55, 0.4), 0.23, p[3], wing)
	end
	local tail, from = body, V(0, h - 0.1, -1.75)
	for i = 1, s + 3 do
		local to = V(math.sin(i * 0.52) * 0.65, h - 0.2 + math.sin(i * 0.6) * 0.35, -1.75 - i * 0.65)
		tail = c:segment(
			"Tail" .. i,
			from,
			to,
			math.max(0.16, 0.8 - i * 0.12),
			math.max(0.15, 0.8 - i * 0.12),
			p[1],
			tail,
			i == 1
		)
		from = to
	end
	for i = 1, young and 2 or adult and 5 or 3 do
		c:leaf(
			"CometTail" .. i,
			from,
			from + V((i - (young and 1.5 or adult and 3 or 2)) * 0.35, 0.3 + i * 0.1, -1.05 - math.sin(i) * 0.3),
			0.52,
			i % 2 == 0 and p[3] or p[4],
			tail
		)
	end
	for i = 1, s + 1 do
		c:leaf("NapeCrest" .. i, V(0, h + 0.8, 0.9 - i * 0.5), V(0, h + 1.4, 0.7 - i * 0.5), 0.55, p[4], body)
	end
	c:sphere(
		"ThroatKeel",
		V(0.87, young and 1.15 or 1.65, 0.71),
		V(0, h + 0.68, 1.16),
		p[3],
		neck,
		false,
		A(-0.28, 0, 0)
	)
	for _, side in { -1, 1 } do
		c:segment(
			"AshBrow" .. side,
			headPos + V(side * 0.23, 0.4, 0.88),
			headPos + V(side * 0.69, 0.48, 0.72),
			0.13,
			0.11,
			p[1],
			head
		)
		if adult then
			c:sphere(
				"CheekPlane" .. side,
				V(0.47, 0.52, 0.73),
				headPos + V(side * 0.72, -0.18, 0.13),
				p[1],
				head,
				false,
				A(0, side * 0.2, side * 0.16)
			)
			c:leaf(
				"CrestBridge" .. side,
				headPos + V(side * 0.56, 0.49, -0.18),
				headPos + V(side * 0.67, 0.83, -0.7),
				0.5,
				p[4],
				head
			)
		end
	end
	return { body = body, head = head }
end

return D
