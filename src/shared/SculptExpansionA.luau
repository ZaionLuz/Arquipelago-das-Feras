--!nonstrict
-- Cinco anatomias originais: brotos, cobre, coral, cerâmica e nuvens.
local V, A, rgb = Vector3.new, CFrame.Angles, Color3.fromRGB
local S = {}
local function mouth(c, head, pos, width, color)
	c:segment("MouthL", pos + V(-width, 0.05, 0), pos + V(0, -0.025, 0.035), 0.045, 0.04, color, head)
	c:segment("MouthR", pos + V(0, -0.025, 0.035), pos + V(width, 0.05, 0), 0.045, 0.04, color, head)
end
local function leg(c, parent, name, hip, knee, ankle, width, color, hoof, digits)
	local upper = c:segment("Leg" .. name, hip, knee, width, width * 0.92, color, parent, true)
	local shin = c:segment("Shin" .. name, knee, ankle, width * 0.65, width * 0.68, color, upper)
	local paw = c:sphere(
		"Paw" .. name,
		V(width * 1.3, width * 0.58, width * 1.5),
		ankle + V(0, -0.08, 0.18),
		hoof or color,
		shin
	)
	for i = 1, digits or 0 do
		c:sphere(
			"Toe" .. name .. i,
			V(width * 0.24, width * 0.27, width * 0.46),
			ankle + V((i - ((digits or 0) + 1) / 2) * width * 0.31, -0.12, width * 0.7),
			color,
			paw
		)
	end
	return paw
end
local function curve(c, name, points, widths, color, parent, depth)
	local anchor = parent
	for i = 1, #points - 1 do
		anchor =
			c:segment(name .. i, points[i], points[i + 1], widths[i], widths[i] * (depth or 1), color, anchor, i == 1)
	end
	return anchor
end

-- Capivara de focinho largo; o bosque de bambu cresce junto de sua espinha.
function S.bambunim(c)
	local s, young, adult = c.stage, c.young, c.adult
	local fur, shade, leaf, stem = rgb(174, 130, 78), rgb(111, 85, 69), rgb(97, 159, 91), rgb(182, 207, 105)
	local length = young and 2.55 or adult and 4.25 or 3.45
	local y = young and 1.05 or adult and 1.5 or 1.28
	local body =
		c:sphere("Body", V(young and 2.0 or 2.65, young and 1.45 or 1.9, length), V(0, y, -0.4), fur, nil, true)
	c:sphere(
		"RoundedRump",
		V(young and 1.9 or 2.35, young and 1.4 or 1.75, 2.0),
		V(0, y - 0.05, -length * 0.34),
		fur,
		body
	)
	c:sphere("BellyApron", V(1.85, 0.72, length * 0.76), V(0, y - 0.5, -0.18), c.cream, body)
	local hp = V(0, y + (young and 0.35 or 0.6), length * 0.37)
	local neck = c:sphere("Neck", V(1.6, 1.5, 1.55), hp - V(0, 0.25, 0.35), fur, body)
	local head = c:sphere("Head", V(young and 2.0 or 2.2, young and 1.4 or 1.6, 1.95), hp, fur, neck, true)
	c:sphere("CapybaraMuzzle", V(young and 1.85 or 2.08, 0.91, 1.45), hp + V(0, -0.28, 0.75), fur, head)
	c:sphere("CreamChin", V(1.65, 0.32, 1.15), hp + V(0, -0.63, 0.69), c.cream, head)
	c:eyes(head, hp + V(0, 0.29, 0.83), young and 1.24 or 1.45, young and 0.25 or 0.21, rgb(107, 76, 42), -0.11)
	for _, side in { -1, 1 } do
		local ear = c:sphere("RoundEar" .. side, V(0.54, 0.61, 0.37), hp + V(side * 0.83, 0.66, -0.16), fur, head)
		c:sphere("EarInlay" .. side, V(0.3, 0.38, 0.15), hp + V(side * 0.83, 0.67, 0.02), rgb(211, 158, 111), ear)
		c:sphere("Nostril" .. side, V(0.15, 0.09, 0.08), hp + V(side * 0.48, -0.02, 1.42), shade, head)
		c:segment(
			"SleepyBrow" .. side,
			hp + V(side * 0.88, 0.48, 0.85),
			hp + V(side * 0.5, 0.52, 0.94),
			0.1,
			0.09,
			fur,
			head
		)
		for _, front in { false, true } do
			local z = front and length * 0.22 or -length * 0.37
			leg(
				c,
				body,
				(front and "Fore" or "Hind") .. side,
				V(side * 0.85, y - 0.25, z),
				V(side * 1.05, 0.62, z - 0.15),
				V(side * 1.06, 0.23, z + 0.16),
				young and 0.4 or 0.55,
				fur,
				shade,
				adult and 3 or 0
			)
		end
	end
	mouth(c, head, hp + V(0, -0.42, 1.46), 0.42, shade)
	if not young then
		for _, side in { -1, 1 } do
			c:block("Incisor" .. side, V(0.16, 0.18, 0.1), hp + V(side * 0.1, -0.5, 1.48), c.cream, head)
		end
	end
	for stalk = 1, young and 1 or adult and 3 or 2 do
		local x, z = (stalk - (young and 1 or adult and 2 or 1.5)) * 0.53, -0.22 - stalk * 0.38
		local base = V(x, y + 0.72, z)
		local bend = base + V((stalk % 2 == 0 and -1 or 1) * 0.2, young and 0.75 or adult and 1.85 or 1.2, -0.13)
		local bamboo = c:segment("Bamboo" .. stalk, base, bend, 0.19, 0.19, stem, body)
		for node = 1, s do
			local point = base:Lerp(bend, node / (s + 1))
			c:sphere("BambooNode" .. stalk .. node, V(0.25, 0.09, 0.24), point, leaf, bamboo)
		end
		for _, side in { -1, 1 } do
			local tip = bend + V(side * (young and 0.5 or 0.85), 0.08, -0.18)
			c:leaf("BambooLeaf" .. stalk .. side, bend - V(0, 0.18, 0), tip, young and 0.33 or 0.48, leaf, bamboo)
		end
	end
	return { body = body, head = head }
end

-- Cabra de cobre: cascos fendidos e chifres enrolados substituem o simples cone.
function S.brasebode(c)
	local young, adult = c.young, c.adult
	local coat, rust, ember, copper = rgb(89, 67, 83), rgb(160, 87, 71), rgb(247, 158, 73), rgb(218, 171, 110)
	local y = young and 1.3 or adult and 1.95 or 1.65
	local length = young and 2.45 or adult and 3.75 or 3.15
	local body = c:sphere("Body", V(young and 1.65 or 2.05, 1.65, length), V(0, y, -0.3), coat, nil, true)
	c:sphere(
		"ShoulderRuff",
		V(young and 1.7 or 2.25, young and 1.55 or 2.25, 1.75),
		V(0, y + 0.26, length * 0.24),
		rust,
		body
	)
	local hp = V(0, y + (young and 0.85 or 1.25), length * 0.41)
	local neck = c:segment("Neck", V(0, y + 0.2, length * 0.3), hp - V(0, 0.27, 0.16), 0.95, 1.1, rust, body)
	local head = c:sphere("Head", V(young and 1.75 or 1.55, 1.5, 1.65), hp, rust, neck, true)
	c:sphere("GoatBridge", V(0.95, 1.05, 1.15), hp + V(0, -0.18, 0.68), rust, head)
	c:sphere("GoatMuzzle", V(1.05, 0.55, 0.85), hp + V(0, -0.52, 1.02), copper, head)
	c:sphere("Nose", V(0.52, 0.2, 0.23), hp + V(0, -0.37, 1.38), coat, head)
	c:eyes(head, hp + V(0, 0.22, 0.71), young and 1.13 or 1.02, young and 0.25 or 0.21, ember, 0.06)
	mouth(c, head, hp + V(0, -0.66, 1.39), 0.25, coat)
	for _, side in { -1, 1 } do
		c:leaf("GoatEar" .. side, hp + V(side * 0.57, 0.25, 0), hp + V(side * 1.3, 0.18, -0.3), 0.52, rust, head)
		if young then
			c:leaf(
				"HornBud" .. side,
				hp + V(side * 0.48, 0.57, -0.1),
				hp + V(side * 0.58, 1.02, -0.28),
				0.28,
				copper,
				head
			)
		else
			local r = adult and 0.85 or 0.58
			local points = {}
			for i = 0, adult and 6 or 4 do
				local a = -0.25 + i * (adult and 0.59 or 0.72)
				table.insert(
					points,
					hp + V(side * (0.54 + i * 0.055), 0.55 + math.sin(a) * r + r * 0.24, -0.22 - (1 - math.cos(a)) * r)
				)
			end
			local widths = {}
			for i = 1, #points - 1 do
				widths[i] = 0.48 - i * 0.045
			end
			curve(c, "CopperHorn" .. side .. "_", points, widths, copper, head)
		end
		for _, front in { true, false } do
			local z = front and length * 0.23 or -length * 0.34
			local ankle = V(side * 0.83, 0.25, z + 0.08)
			local paw = leg(
				c,
				body,
				(front and "Fore" or "Hind") .. side,
				V(side * 0.7, y - 0.3, z),
				V(side * 0.93, y * 0.48, z - 0.2),
				ankle,
				young and 0.32 or 0.44,
				rust,
				coat,
				0
			)
			for split = -1, 1, 2 do
				c:sphere(
					"ClovenHoof" .. side .. split .. tostring(front),
					V(0.23, 0.26, 0.44),
					ankle + V(split * 0.13, -0.1, 0.31),
					coat,
					paw
				)
			end
		end
	end
	if not young then
		c:leaf(
			"CopperBeard",
			hp + V(0, -0.7, 0.86),
			hp + V(0, adult and -1.55 or -1.16, 0.92),
			adult and 0.6 or 0.42,
			copper,
			head
		)
	end
	for i = 1, young and 1 or adult and 5 or 3 do
		local z = length * 0.27 - i * length / (young and 2 or adult and 6 or 4)
		c:leaf(
			"EmberMane" .. i,
			V(0, y + 0.7, z),
			V(0, y + (adult and 1.4 or 1.1), z - 0.23),
			0.48,
			i % 2 == 0 and ember or rust,
			body
		)
	end
	c:leaf("Tail1", V(0, y + 0.2, -length * 0.49), V(0.15, y + 0.65, -length * 0.49 - 0.55), 0.43, copper, body, true)
	if adult then
		c:sphere("ChestRuneRim", V(0.48, 0.58, 0.2), V(0, y + 0.4, length * 0.25 + 0.82), copper, body)
		c:sphere("ChestRune", V(0.26, 0.36, 0.16), V(0, y + 0.41, length * 0.25 + 0.93), ember, body)
	end
	return { body = body, head = head }
end

-- Axolote coralino: guelras em ramos, corpo baixo e leme caudal contínuo.
function S.coralote(c)
	local young, adult = c.young, c.adult
	local skin, blush, reef, blue = rgb(242, 183, 150), rgb(233, 125, 138), rgb(255, 220, 166), rgb(99, 177, 181)
	local length = young and 2.35 or adult and 3.7 or 3.0
	local body = c:sphere("Body", V(young and 1.65 or 2.1, 1.25, length), V(0, 0.95, -0.4), skin, nil, true)
	c:sphere("Belly", V(young and 1.4 or 1.8, 0.6, length * 0.83), V(0, 0.65, -0.25), c.cream, body)
	local hp = V(0, young and 1.15 or 1.35, length * 0.39)
	local head = c:sphere("Head", V(young and 2.15 or 2.6, 1.35, 1.75), hp, skin, body, true)
	c:sphere("Muzzle", V(young and 1.8 or 2.18, 0.67, 0.8), hp + V(0, -0.27, 0.71), reef, head)
	c:eyes(head, hp + V(0, 0.28, 0.76), young and 1.25 or 1.58, young and 0.26 or 0.23, blue, -0.07)
	mouth(c, head, hp + V(0, -0.28, 1.08), young and 0.43 or 0.58, rgb(139, 76, 92))
	for _, side in { -1, 1 } do
		c:sphere("CoralCheek" .. side, V(0.42, 0.26, 0.12), hp + V(side * 0.83, -0.1, 0.88), blush, head)
		for branch = 1, 3 do
			local base = hp + V(side * (young and 0.85 or 1.05), 0.12, -0.2)
			local tip = hp
				+ V(side * (young and 1.4 or adult and 2.13 or 1.8), 0.93 - branch * 0.38, -0.42 + branch * 0.14)
			local gill = c:segment("CoralGill" .. side .. branch, base, tip, 0.17, 0.2, blush, head)
			c:leaf(
				"GillFrond" .. side .. branch,
				tip - V(side * 0.15, 0.04, 0),
				tip + V(side * 0.27, 0.22, 0),
				young and 0.24 or 0.38,
				blush,
				gill
			)
			if adult then
				c:leaf(
					"GillBranch" .. side .. branch,
					tip - V(side * 0.22, 0, 0),
					tip + V(side * 0.11, -0.28, 0.12),
					0.28,
					reef,
					gill
				)
			end
		end
		for _, front in { false, true } do
			local z = front and length * 0.14 or -length * 0.34
			leg(
				c,
				body,
				(front and "Fore" or "Hind") .. side,
				V(side * 0.7, 0.8, z),
				V(side * 1.12, 0.4, z - 0.1),
				V(side * 1.15, 0.19, z + 0.16),
				young and 0.31 or 0.42,
				skin,
				reef,
				young and 0 or 3
			)
		end
	end
	local points = {
		V(0, 0.91, -length * 0.44),
		V(0.38, 0.74, -length * 0.44 - 0.75),
		V(0.83, 0.8, -length * 0.44 - 1.6),
		V(1.25, 1.15, -length * 0.44 - 2.15),
	}
	local tail = curve(c, "Tail", points, { 0.95, 0.65, 0.35 }, skin, body, 0.82)
	for i = 1, young and 1 or adult and 3 or 2 do
		c:leaf(
			"CaudalSail" .. i,
			points[i] + V(0, 0.07, 0),
			points[i + 1] + V(0, adult and 0.72 or 0.48, -0.1),
			0.68,
			blue,
			tail
		)
	end
	for i = 1, young and 2 or adult and 6 or 4 do
		c:sphere(
			"CoralSpot" .. i,
			V(0.28, 0.11, 0.36),
			V((i % 2 == 0 and 1 or -1) * 0.55, 1.53, 0.38 - i * 0.37),
			blush,
			body
		)
	end
	if adult then
		c:leaf("CrownGill", hp + V(0, 0.58, -0.25), hp + V(0, 1.22, -0.55), 0.58, blue, head)
	end
	return { body = body, head = head }
end

-- Pangolim cerâmico: placas sobrepostas acompanham a curva do dorso e da cauda.
function S.dunatatu(c)
	local s, young, adult = c.stage, c.young, c.adult
	local sand, terracotta, jade, shade = rgb(203, 162, 106), rgb(181, 110, 83), rgb(107, 167, 159), rgb(99, 76, 87)
	local length, y = young and 2.45 or adult and 4.0 or 3.25, young and 0.95 or adult and 1.35 or 1.15
	local body =
		c:sphere("Body", V(young and 1.85 or 2.5, young and 1.4 or 1.8, length), V(0, y, -0.3), sand, nil, true)
	c:sphere("Underside", V(1.55, 0.6, length * 0.87), V(0, y - 0.46, -0.05), c.cream, body)
	local hp = V(0, y + 0.05, length * 0.43)
	local neck = c:segment("Neck", hp - V(0, 0, 0.55), hp + V(0, 0, 0.3), 1.05, 0.95, sand, body)
	local head = c:sphere("Head", V(young and 1.6 or 1.5, 1.15, 1.6), hp + V(0, 0.05, 0.15), sand, neck, true)
	c:sphere("TaperedMuzzle", V(0.88, 0.67, 1.3), hp + V(0, -0.16, 0.87), sand, head, false, A(0.12, 0, 0))
	c:sphere("Nose", V(0.37, 0.24, 0.32), hp + V(0, -0.09, 1.47), shade, head)
	c:eyes(head, hp + V(0, 0.3, 0.79), young and 0.94 or 0.9, young and 0.23 or 0.19, jade, -0.12)
	mouth(c, head, hp + V(0, -0.28, 1.24), 0.24, shade)
	for _, side in { -1, 1 } do
		c:sphere("Ear" .. side, V(0.38, 0.46, 0.22), hp + V(side * 0.58, 0.48, -0.21), terracotta, head)
		for _, front in { true, false } do
			local z = front and length * 0.23 or -length * 0.3
			local paw = leg(
				c,
				body,
				(front and "Fore" or "Hind") .. side,
				V(side * 0.81, y - 0.1, z),
				V(side * 1.03, 0.62, z - 0.2),
				V(side * 1.05, 0.22, z + 0.09),
				young and 0.34 or 0.48,
				sand,
				shade,
				0
			)
			for claw = 1, front and 3 or 2 do
				c:leaf(
					"PangolinClaw" .. side .. tostring(front) .. claw,
					V(side * 1.05 + (claw - 2) * 0.16, 0.24, z + 0.35),
					V(side * 1.05 + (claw - 2) * 0.2, 0.17, z + 0.85),
					0.18,
					c.cream,
					paw
				)
			end
		end
	end
	for row = 1, young and 2 or adult and 4 or 3 do
		local z = length * 0.22 - (row - 1) * length * 0.22
		for side = -1, 1 do
			local x = side * (young and 0.51 or 0.69)
			c:sphere(
				"CeramicScute" .. row .. "_" .. side,
				V(young and 0.9 or 1.2, side == 0 and 0.55 or 0.45, 1.15),
				V(x, y + (side == 0 and 0.82 or 0.62), z),
				row % 2 == 0 and sand or terracotta,
				body,
				false,
				A(0.12, 0, -side * 0.3)
			)
		end
	end
	local points = {
		V(0, y - 0.05, -length * 0.46),
		V(0.4, y - 0.23, -length * 0.46 - 0.85),
		V(0.95, y - 0.2, -length * 0.46 - 1.65),
		V(1.48, y + 0.04, -length * 0.46 - 2.25),
	}
	local tail = curve(c, "Tail", points, { 1.08, 0.79, 0.45 }, sand, body, 0.78)
	for i = 1, young and 1 or adult and 3 or 2 do
		c:sphere(
			"TailScute" .. i,
			V(1.03 - i * 0.15, 0.36, 0.95),
			points[i + 1] + V(0, 0.28, 0.2),
			terracotta,
			tail,
			false,
			A(0.1, -i * 0.2, 0)
		)
	end
	if not young then
		for i = 1, s + 1 do
			c:sphere("CeramicInlay" .. i, V(0.21, 0.09, 0.36), V(0, y + 1.09, length * 0.21 - i * 0.57), jade, body)
		end
	end
	if adult then
		c:sphere("BrowScute", V(1.02, 0.35, 0.9), hp + V(0, 0.61, 0.1), terracotta, head, false, A(0.08, 0, 0))
		for _, side in { -1, 1 } do
			c:sphere(
				"TempleScute" .. side,
				V(0.32, 0.6, 0.91),
				hp + V(side * 0.61, 0.27, -0.12),
				terracotta,
				head,
				false,
				A(0, 0, side * 0.2)
			)
		end
		c:leaf("TailSpade", points[4] - V(0.14, 0.03, -0.08), points[4] + V(0.67, 0.16, -0.51), 0.71, jade, tail)
	end
	return { body = body, head = head }
end

-- Urso de nuvens: cuboide macio baixo vira guardião ereto com punhos de ar.
function S.nimburso(c)
	local young, adult = c.young, c.adult
	local blue, cloud, violet, sun = rgb(124, 168, 196), rgb(240, 237, 217), rgb(117, 112, 162), rgb(241, 203, 123)
	local hip = young and 1.1 or adult and 2.55 or 1.85
	local body = c:sphere(
		"Body",
		V(young and 2.3 or adult and 3.15 or 2.7, young and 1.65 or adult and 3.0 or 2.25, young and 2.65 or 2.15),
		V(0, hip, young and -0.45 or -0.1),
		blue,
		nil,
		true
	)
	c:sphere(
		"CloudBelly",
		V(young and 1.85 or 2.3, young and 1.25 or adult and 2.45 or 1.8, 0.75),
		V(0, hip - 0.05, young and 0.62 or 0.8),
		cloud,
		body
	)
	local hp = V(0, hip + (young and 0.75 or adult and 2.1 or 1.55), young and 0.92 or 0.3)
	local neck = c:sphere("NeckRuff", V(young and 1.8 or 2.6, 1.5, 1.75), hp - V(0, 0.65, 0.1), cloud, body)
	local head = c:sphere("Head", V(young and 2.35 or 2.5, young and 1.7 or 1.95, 1.8), hp, blue, neck, true)
	c:sphere("BearMuzzle", V(1.65, 0.9, 0.88), hp + V(0, -0.36, 0.87), cloud, head)
	c:sphere("BearNose", V(0.53, 0.29, 0.28), hp + V(0, -0.19, 1.27), violet, head)
	c:eyes(head, hp + V(0, 0.2, 0.84), young and 1.3 or 1.4, young and 0.29 or adult and 0.22 or 0.25, violet, -0.08)
	mouth(c, head, hp + V(0, -0.53, 1.27), 0.34, violet)
	for _, side in { -1, 1 } do
		local ear = c:sphere("BearEar" .. side, V(0.68, 0.72, 0.42), hp + V(side * 0.93, 0.73, -0.1), cloud, head)
		c:sphere("EarInlay" .. side, V(0.35, 0.42, 0.15), hp + V(side * 0.93, 0.75, 0.11), blue, ear)
		if young then
			for _, front in { true, false } do
				local z = front and 0.7 or -1.14
				leg(
					c,
					body,
					(front and "Fore" or "Hind") .. side,
					V(side * 0.85, 0.85, z),
					V(side * 1.03, 0.48, z),
					V(side * 1.02, 0.22, z + 0.12),
					0.49,
					blue,
					cloud,
					0
				)
			end
		else
			leg(
				c,
				body,
				"Hind" .. side,
				V(side * 0.82, hip - 0.7, -0.15),
				V(side * 1.02, 0.91, 0.08),
				V(side * 1.03, 0.29, 0.23),
				adult and 0.85 or 0.66,
				blue,
				cloud,
				3
			)
			local shoulder = V(side * (adult and 1.4 or 1.2), hip + 0.7, 0)
			local elbow = V(side * (adult and 1.85 or 1.5), hip - 0.03, 0.15)
			local arm = c:segment("Arm" .. side, shoulder, elbow, adult and 0.86 or 0.67, 0.74, blue, body, true)
			local fist = c:sphere(
				"CloudFist" .. side,
				V(adult and 1.15 or 0.85, 1.14, 0.98),
				elbow + V(side * 0.06, -0.5, 0.2),
				cloud,
				arm
			)
			for puff = 1, adult and 3 or 2 do
				c:sphere(
					"GauntletPuff" .. side .. puff,
					V(0.44, 0.55, 0.43),
					elbow + V(side * (0.25 + puff * 0.12), -0.3 - puff * 0.19, 0.28),
					cloud,
					fist
				)
			end
		end
	end
	for puff = 1, young and 3 or adult and 7 or 5 do
		local x = (puff - (young and 2 or adult and 4 or 3)) * 0.33
		c:sphere(
			"CumulusCrown" .. puff,
			V(0.65, 0.58 + math.cos(x) * 0.2, 0.66),
			hp + V(x, 0.82 + math.cos(x) * 0.16, -0.13),
			cloud,
			head
		)
	end
	if adult then
		for _, side in { -1, 1 } do
			local shoulder = V(side * 1.19, hip + 0.92, -0.3)
			local wing = c:sphere("Wing" .. side, V(0.7, 0.6, 0.7), shoulder, violet, body, true)
			for feather = 1, 3 do
				c:leaf(
					"AuroraMantle" .. side .. feather,
					shoulder,
					shoulder + V(side * (0.67 + feather * 0.22), -0.13 - feather * 0.3, -0.5 - feather * 0.23),
					0.75,
					feather % 2 == 0 and sun or cloud,
					wing
				)
			end
		end
		c:sphere("WindHeart", V(0.48, 0.62, 0.13), V(0, hip + 0.35, 1.23), sun, body)
	end
	local tail = c:sphere(
		"Tail1",
		V(young and 0.5 or 0.7, 0.63, 0.62),
		V(0, hip - 0.25, young and -1.62 or -1.12),
		cloud,
		body,
		true
	)
	c:sphere("TailPuff", V(0.44, 0.46, 0.43), V(0.13, hip - 0.03, young and -1.75 or -1.25), cloud, tail)
	return { body = body, head = head }
end

return S
