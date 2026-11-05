--!nonstrict
-- Cinco anatomias originais: anfíbio-lanterna, abelha-orquídea, lince, elefante-marinho e Kraken.
local V, A, rgb = Vector3.new, CFrame.Angles, Color3.fromRGB
local S = {}

local function smile(c, parent, center, width, color)
	c:segment("SmileL", center + V(-width, 0.06, 0), center + V(0, -0.025, 0.035), 0.05, 0.035, color, parent)
	c:segment("SmileR", center + V(0, -0.025, 0.035), center + V(width, 0.06, 0), 0.05, 0.035, color, parent)
end

local function curved(c, name, points, widths, color, parent, motor, depth)
	local anchor = parent
	for i = 1, #points - 1 do
		anchor = c:segment(
			name .. i,
			points[i],
			points[i + 1],
			widths[i],
			widths[i] * (depth or 1),
			color,
			anchor,
			motor and i == 1
		)
	end
	return anchor
end

local function frogFoot(c, name, from, knee, tip, width, color, parent, digits)
	local thigh = c:segment("Leg" .. name, from, knee, width, width * 1.15, color, parent, true)
	local shin = c:segment("Shin" .. name, knee, tip, width * 0.48, width * 0.55, color, thigh)
	local pad = c:sphere("Foot" .. name, V(width * 1.35, 0.18, width * 1.1), tip + V(0, -0.02, 0.16), color, shin)
	for digit = 1, digits do
		local side = digit - (digits + 1) / 2
		local endPoint = tip + V(side * width * 0.5, -0.015, width * 1.1)
		c:segment(
			"Toe" .. name .. digit,
			tip + V(side * width * 0.27, 0, width * 0.3),
			endPoint,
			0.1,
			0.085,
			color,
			pad
		)
		c:sphere("ToePad" .. name .. digit, V(0.17, 0.1, 0.19), endPoint, c.gold, pad)
	end
	return thigh
end

function S.lumissapo(c)
	local stage, young, adult = c.stage, c.young, c.adult
	local skin, back = rgb(76, 107, 125), rgb(55, 65, 105)
	local glow, moss, cap = rgb(153, 232, 204), rgb(113, 167, 138), rgb(166, 122, 184)
	local y = young and 0.88 or adult and 1.48 or 1.15
	local body = c:sphere(
		"Body",
		V(young and 1.75 or 2.7, young and 1.35 or 1.85, young and 2.4 or 2.7),
		V(0, y, -0.37),
		back,
		c.root,
		true
	)
	c:sphere("SoftBelly", V(young and 1.1 or 1.85, 1.25, 1.7), V(0, y - 0.15, 0.2), glow, body)
	local hy = y + (adult and 0.78 or 0.47)
	local hz = young and 0.62 or 0.94
	local head =
		c:sphere("Head", V(young and 1.87 or 2.65, young and 1.24 or 1.55, 1.5), V(0, hy, hz), skin, body, true)
	c:sphere(
		"ThroatLantern",
		V(young and 0.85 or adult and 1.8 or 1.28, adult and 1.35 or 0.8, 0.88),
		V(0, hy - (adult and 0.66 or 0.47), hz + 0.46),
		glow,
		head
	)
	c:eyes(
		head,
		V(0, hy + 0.28, hz + 0.65),
		young and 1.02 or 1.42,
		young and 0.28 or 0.31,
		c.gold,
		adult and 0.15 or -0.1
	)
	for _, side in { -1, 1 } do
		c:sphere(
			"Brow" .. side,
			V(0.67, 0.2, 0.4),
			V(side * (young and 0.51 or 0.71), hy + 0.6, hz + 0.62),
			moss,
			head,
			false,
			A(0, 0, side * 0.13)
		)
		c:sphere(
			"Cheek" .. side,
			V(0.54, 0.33, 0.28),
			V(side * (young and 0.63 or 0.92), hy - 0.17, hz + 0.69),
			moss,
			head
		)
		if not young then
			frogFoot(
				c,
				"Hind" .. side,
				V(side * 0.9, y - 0.15, -0.8),
				V(side * (adult and 1.8 or 1.47), 0.65, -0.9),
				V(side * 1.43, 0.18, -0.13),
				adult and 0.78 or 0.65,
				skin,
				body,
				adult and 3 or 2
			)
		end
		frogFoot(
			c,
			"Fore" .. side,
			V(side * (young and 0.56 or 0.91), y + 0.05, 0.53),
			V(side * (young and 0.8 or 1.1), 0.51, 0.87),
			V(side * (young and 0.8 or 1.14), 0.16, 1.35),
			young and 0.32 or 0.37,
			moss,
			body,
			young and 2 or 3
		)
	end
	smile(c, head, V(0, hy - 0.18, hz + 0.82), young and 0.46 or 0.75, c.dark)
	if young then
		curved(
			c,
			"Tail",
			{ V(0, y - 0.2, -1.2), V(0.45, 0.65, -2), V(0.7, 0.74, -2.65), V(0.44, 1.13, -2.9) },
			{ 0.64, 0.44, 0.23 },
			skin,
			body,
			true
		)
		c:leaf("TadpoleTailFin", V(0.45, 0.78, -2.56), V(0.45, 1.62, -2.98), 0.68, glow, body)
	else
		local stalks = adult and 3 or 2
		for i = 1, stalks do
			local base = V((i - (stalks + 1) / 2) * 0.62, y + 0.66, -0.75 - (i % 2) * 0.28)
			local stalk = c:segment(
				"LanternStalk" .. i,
				base,
				base + V((i - 2) * 0.12, adult and 1.02 or 0.57, 0),
				0.16,
				0.17,
				glow,
				body
			)
			local point = base + V((i - 2) * 0.12, adult and 1.02 or 0.57, 0)
			c:sphere("MushroomCap" .. i, V(adult and 0.87 or 0.63, 0.35, adult and 0.87 or 0.63), point, cap, stalk)
			c:sphere("Spore" .. i, V(0.15, 0.08, 0.15), point + V(0.11, 0.17, 0.1), c.cream, stalk)
		end
	end
	for dot = 1, adult and 5 or stage + 1 do
		c:sphere(
			"SporeMark" .. dot,
			V(0.18, 0.13, 0.12),
			V((dot % 2 == 0 and -1 or 1) * 0.9, y + 0.49, -0.84 + dot * 0.27),
			glow,
			body
		)
	end
	return { body = body, head = head }
end

function S.nectarim(c)
	local young, adult = c.young, c.adult
	local honey, cocoa, cream = rgb(230, 169, 83), rgb(82, 63, 91), c.cream
	local rose, mint, lilac = rgb(225, 130, 168), rgb(154, 215, 195), rgb(160, 155, 215)
	local y = young and 1.13 or adult and 2.02 or 1.67
	local body = c:sphere(
		"Body",
		V(young and 1.4 or 1.8, young and 1.4 or 1.68, young and 1.8 or 2.25),
		V(0, y, 0.2),
		cocoa,
		c.root,
		true
	)
	local abdomen = c:sphere(
		"Abdomen",
		V(young and 1.57 or adult and 2.48 or 2.07, young and 1.47 or 1.86, young and 2.15 or adult and 3.0 or 2.65),
		V(0, y - 0.08, young and -0.82 or -1.15),
		honey,
		body
	)
	for band = 1, young and 2 or 3 do
		local z = -0.43 - band * (young and 0.4 or 0.54)
		c:sphere(
			"AbdomenBand" .. band,
			V(young and 1.5 or adult and 2.32 or 1.97, young and 0.48 or 0.56, 0.21),
			V(0, y + (young and 0.39 or 0.62), z),
			cocoa,
			abdomen,
			false,
			A(0.15, 0, 0)
		)
	end
	local hy, hz = y + 0.56, 1.13
	local head =
		c:sphere("Head", V(young and 1.74 or 1.95, young and 1.56 or 1.72, 1.48), V(0, hy, hz), honey, body, true)
	c:sphere("FaceMask", V(1.56, 1.13, 0.42), V(0, hy - 0.14, hz + 0.55), cream, head)
	c:eyes(
		head,
		V(0, hy + 0.12, hz + 0.7),
		young and 0.98 or 1.1,
		young and 0.29 or 0.27,
		cocoa,
		young and -0.16 or 0.09
	)
	c:sphere("Nose", V(0.18, 0.15, 0.12), V(0, hy - 0.13, hz + 0.85), cocoa, head)
	smile(c, head, V(0, hy - 0.36, hz + 0.78), 0.27, cocoa)
	for _, side in { -1, 1 } do
		local base = V(side * 0.57, hy + 0.58, hz - 0.03)
		local tip = V(side * (adult and 0.98 or 0.84), hy + (adult and 1.42 or 1.02), hz + 0.06)
		curved(
			c,
			"Antenna" .. side,
			{ base, base + V(side * 0.17, 0.57, -0.17), tip },
			{ 0.12, 0.085 },
			cocoa,
			head,
			false
		)
		c:sphere("AntennaBud" .. side, V(0.28, 0.36, 0.25), tip, rose, head)
		for pair = 1, 3 do
			local root = V(side * 0.59, y - 0.35, 0.76 - (pair - 1) * 0.76)
			local knee = root + V(side * (young and 0.42 or 0.66), -0.46, pair == 1 and 0.16 or -0.1)
			local foot = knee + V(side * 0.12, young and -0.28 or -0.55, 0.31)
			local leg =
				c:segment("Leg" .. side .. "_" .. pair, root, knee, young and 0.13 or 0.2, 0.19, cocoa, body, true)
			c:segment("Shin" .. side .. "_" .. pair, knee, foot, 0.12, 0.11, cocoa, leg)
			c:sphere("Foot" .. side .. "_" .. pair, V(0.23, 0.15, 0.34), foot, cream, leg)
		end
		local wingPairs = young and 1 or 2
		for pair = 1, wingPairs do
			local root = V(side * 0.71, y + 0.43, 0.3 - (pair - 1) * 0.75)
			local endPoint = root
				+ V(
					side * (young and 1.22 or adult and 3.1 or 2.3),
					young and 0.58 or pair == 1 and 1.6 or 0.4,
					pair == 1 and -0.3 or -1.43
				)
			local wing = c:sphere("Wing" .. side .. "_" .. pair, V(0.32, 0.32, 0.36), root, cocoa, body, true)
			c:leaf(
				"OrchidWing" .. side .. "_" .. pair,
				root,
				endPoint,
				young and 0.92 or adult and 1.65 or 1.26,
				pair == 1 and lilac or mint,
				wing
			)
			c:leaf(
				"WingCover" .. pair .. side,
				root + V(0, 0, 0.05),
				endPoint - V(side * 0.33, 0.08, -0.02),
				young and 0.57 or 0.95,
				cream,
				wing
			)
			if not young then
				c:segment(
					"Vein" .. side .. "_" .. pair,
					root + V(0, 0, 0.15),
					endPoint - V(side * 0.32, 0.13, -0.12),
					0.065,
					0.05,
					rose,
					wing
				)
			end
		end
	end
	if adult then
		local center = V(0, hy + 0.75, hz + 0.09)
		for petal = 1, 5 do
			local a = petal * math.pi * 2 / 5
			c:leaf(
				"OrchidPetal" .. petal,
				center,
				center + V(math.sin(a) * 0.69, math.cos(a) * 0.62, -0.1),
				0.42,
				rose,
				head
			)
		end
		c:sphere("PollenHeart", V(0.36, 0.32, 0.21), center + V(0, 0, 0.14), honey, head)
	end
	c:leaf(
		"TailSting",
		V(0, y - 0.15, young and -1.65 or -2.4),
		V(0, y - 0.4, young and -2.13 or -3.12),
		0.3,
		cocoa,
		abdomen
	)
	return { body = body, head = head }
end

local function lynxPaw(c, parent, side, front, height, z, color, cream, young)
	local hip = V(side * 0.7, height, z)
	local knee = V(side * 0.94, front and 0.84 or 0.7, z + (front and -0.18 or 0.27))
	local ankle = V(side * 0.96, 0.25, z + 0.25)
	local leg = c:segment(
		"Leg" .. (front and "Fore" or "Hind") .. side,
		hip,
		knee,
		young and 0.4 or 0.55,
		front and 0.48 or 0.66,
		color,
		parent,
		true
	)
	local shin = c:segment("Shin" .. side .. tostring(front), knee, ankle, 0.31, 0.35, color, leg)
	local paw = c:sphere("Paw" .. side .. tostring(front), V(0.62, 0.33, 0.88), ankle + V(0, -0.07, 0.22), cream, shin)
	for toe = 1, young and 2 or 3 do
		c:sphere(
			"Toe" .. side .. tostring(front) .. toe,
			V(0.19, 0.18, 0.29),
			ankle + V((toe - (young and 1.5 or 2)) * 0.2, -0.07, 0.58),
			color,
			paw
		)
	end
end

function S.cristalince(c)
	local young, adult = c.young, c.adult
	local fur, slate, crystal = rgb(153, 179, 196), rgb(81, 102, 135), rgb(150, 221, 224)
	local cream, violet = c.cream, rgb(166, 150, 205)
	local y = young and 1.18 or adult and 1.86 or 1.4
	local length = young and 2.1 or adult and 3.75 or 3.3
	local body =
		c:sphere("Body", V(young and 1.65 or 2.05, young and 1.55 or 1.9, length), V(0, y, -0.35), fur, c.root, true)
	c:sphere(
		"Haunch",
		V(young and 1.45 or 1.95, young and 1.38 or 1.98, 1.71),
		V(0, y - 0.03, -length * 0.33),
		slate,
		body
	)
	c:sphere(
		"Chest",
		V(young and 1.31 or 1.83, adult and 2.25 or 1.57, 1.65),
		V(0, y + 0.2, length * 0.27),
		cream,
		body
	)
	local hy, hz = y + (adult and 1.32 or young and 0.8 or 1.03), length * 0.32
	local head = c:sphere("Head", V(young and 1.84 or 2.0, young and 1.62 or 1.75, 1.58), V(0, hy, hz), fur, body, true)
	c:sphere("LowerJaw", V(1.28, 0.38, 1.01), V(0, hy - 0.55, hz + 0.56), cream, head)
	for _, side in { -1, 1 } do
		c:sphere("WhiskerPad" .. side, V(0.66, 0.42, 0.52), V(side * 0.25, hy - 0.28, hz + 0.75), cream, head)
		local earBase = V(side * 0.6, hy + 0.5, hz - 0.2)
		local tip = earBase + V(side * 0.22, young and 0.75 or 0.97, -0.09)
		local direction = (tip - earBase).Unit
		local normal = (V(0, 0, 1) - direction * direction:Dot(V(0, 0, 1))).Unit
		local right = direction:Cross(normal).Unit
		local orientation = CFrame.fromMatrix(V(0, 0, 0), right, direction, normal)
		local width, height = young and 0.66 or 0.82, (tip - earBase).Magnitude
		local ear = c:sphere(
			"LynxEar" .. side,
			V(width, 0.42, 0.35),
			earBase + direction * 0.17,
			slate,
			head,
			false,
			orientation
		)
		for half = -1, 1, 2 do
			c:wedge(
				"LynxEarPoint" .. side .. "_" .. half,
				V(0.28, height - 0.17, width * 0.5),
				earBase + direction * (0.17 + (height - 0.17) * 0.5) + right * half * width * 0.25,
				slate,
				ear,
				false,
				orientation * A(0, -half * math.pi / 2, 0)
			)
		end
		c:leaf(
			"EarCrystalInner" .. side,
			earBase + direction * 0.16 + normal * 0.19,
			tip - direction * 0.15 + normal * 0.19,
			young and 0.31 or 0.41,
			crystal,
			ear
		)
		c:leaf(
			"LynxEarTuft" .. side,
			tip - direction * 0.09,
			tip + V(side * 0.04, young and 0.29 or 0.42, -0.06),
			0.15,
			slate,
			ear
		)
		if not young then
			c:wedge(
				"CheekPrism" .. side,
				V(0.51, 0.76, 0.43),
				V(side * 0.84, hy - 0.27, hz + 0.2),
				violet,
				head,
				false,
				A(0.15, side * 0.4, side * -0.47)
			)
		end
		for _, front in { true, false } do
			lynxPaw(c, body, side, front, y, front and length * 0.28 or -length * 0.36, fur, cream, young)
		end
	end
	c:eyes(
		head,
		V(0, hy + 0.16, hz + 0.73),
		young and 1.01 or 1.13,
		young and 0.28 or 0.24,
		violet,
		adult and 0.22 or 0.03
	)
	for _, side in { -1, 1 } do
		c:segment(
			"Brow" .. side,
			V(side * 0.3, hy + 0.44, hz + 0.79),
			V(side * 0.84, hy + 0.38, hz + 0.7),
			0.11,
			0.13,
			slate,
			head
		)
	end
	c:sphere("Nose", V(0.28, 0.21, 0.15), V(0, hy - 0.16, hz + 1.06), violet, head)
	c:segment("Philtrum", V(0, hy - 0.27, hz + 1.03), V(0, hy - 0.42, hz + 1.02), 0.045, 0.04, c.dark, head)
	smile(c, head, V(0, hy - 0.44, hz + 1.0), 0.26, c.dark)
	local origin = V(0, y - 0.17, -length * 0.54)
	local endTail = curved(
		c,
		"Tail",
		{ origin, origin + V(0.25, 0.12, -0.54), origin + V(0.5, 0.45, -0.89) },
		{ young and 0.5 or 0.66, young and 0.32 or 0.43 },
		slate,
		body,
		true
	)
	c:wedge(
		"TailCrystal",
		V(0.49, 0.66, 0.53),
		origin + V(0.5, 0.58, -0.95),
		crystal,
		endTail,
		false,
		A(-0.35, 0, -0.25)
	)
	for i = 1, young and 1 or adult and 5 or 3 do
		local z = 0.29 - i * 0.53
		c:wedge(
			"DorsalPrism" .. i,
			V(0.43, young and 0.48 or adult and 0.98 or 0.66, 0.48),
			V(i % 2 == 0 and -0.19 or 0.19, y + 0.95, z),
			i % 2 == 0 and violet or crystal,
			body,
			false,
			A(-0.12, i * 0.39, 0)
		)
	end
	if adult then
		for _, side in { -1, 1 } do
			for shard = 1, 3 do
				c:leaf(
					"CrystalRuff" .. side .. shard,
					V(side * 0.68, y + 0.81, 0.53),
					V(side * (0.99 + shard * 0.12), y + 1.3 - shard * 0.18, 0.15 - shard * 0.19),
					0.45,
					shard % 2 == 0 and violet or crystal,
					body
				)
			end
		end
	end
	return { body = body, head = head }
end

function S.maritromba(c)
	local young, adult = c.young, c.adult
	local blue, deep, cream = rgb(115, 173, 196), rgb(65, 109, 150), c.cream
	local coral, ivory = rgb(213, 143, 151), rgb(245, 218, 169)
	local y = young and 0.99 or adult and 1.58 or 1.25
	local length = young and 2.4 or adult and 4.38 or 3.43
	local body = c:sphere(
		"Body",
		V(young and 1.99 or adult and 3.05 or 2.55, young and 1.65 or adult and 2.5 or 2.03, length),
		V(0, y, -0.62),
		deep,
		c.root,
		true
	)
	c:sphere(
		"Belly",
		V(young and 1.42 or 2.05, young and 1.23 or 1.83, length * 0.74),
		V(0, y - 0.23, -0.14),
		cream,
		body
	)
	local chestY = y + (adult and 0.57 or 0.25)
	c:sphere(
		"Chest",
		V(young and 1.7 or adult and 2.84 or 2.23, adult and 3.0 or young and 1.67 or 2.11, 1.88),
		V(0, chestY, length * 0.22),
		blue,
		body
	)
	local hy, hz = y + (adult and 1.85 or young and 0.8 or 1.25), length * 0.32
	local head =
		c:sphere("Head", V(young and 1.94 or 2.4, young and 1.67 or 2.02, 1.93), V(0, hy, hz), blue, body, true)
	c:sphere("LowerJaw", V(young and 1.36 or 1.83, 0.55, 1.36), V(0, hy - 0.65, hz + 0.56), cream, head)
	for _, side in { -1, 1 } do
		c:sphere(
			"WhiskerPad" .. side,
			V(young and 0.7 or 0.91, 0.51, 0.69),
			V(side * 0.44, hy - 0.3, hz + 0.85),
			ivory,
			head
		)
		local shoulder = V(side * (young and 0.79 or 1.19), y - 0.09, 0.63)
		local elbow = shoulder + V(side * (young and 0.46 or 0.75), -0.32, 0.47)
		local tip = V(elbow.X + side * (adult and 0.49 or 0.32), young and 0.2 or 0.26, elbow.Z + 0.5)
		local arm = c:sphere("LegFlipper" .. side, V(young and 0.7 or 1.0, 0.54, 0.94), shoulder, blue, body, true)
		local wrist = c:leaf(
			"ForeFlipperMembrane" .. side,
			shoulder + V(0, 0.05, 0),
			tip + V(0, 0.03, 0),
			young and 0.8 or 1.3,
			blue,
			arm
		)
		c:sphere(
			"ForeFlipperTip" .. side,
			V(young and 0.91 or 1.36, 0.23, young and 0.64 or 0.86),
			tip,
			blue,
			wrist,
			false,
			A(0, side * 0.47, 0)
		)
		c:leaf("FlipperEdge" .. side, shoulder + V(0, 0.12, 0.13), tip + V(side * 0.12, 0.07, 0.03), 0.13, cream, arm)
		if not young then
			local tuskRoot = V(side * 0.63, hy - 0.46, hz + 0.8)
			curved(c, "Tusk" .. side, {
				tuskRoot,
				tuskRoot + V(side * 0.15, -0.69, 0.36),
				tuskRoot + V(side * 0.27, -0.71, 0.74),
				tuskRoot + V(side * 0.32, adult and -0.2 or -0.44, 0.85),
			}, { adult and 0.3 or 0.23, 0.19, 0.1 }, ivory, head, false)
		end
	end
	c:eyes(
		head,
		V(0, hy + 0.18, hz + 0.83),
		young and 1.17 or 1.44,
		young and 0.28 or 0.26,
		coral,
		adult and 0.14 or -0.06
	)
	local trunkRoot = V(0, hy + 0.07, hz + 0.95)
	local trunkPoints = young and {
		trunkRoot,
		trunkRoot + V(0, -0.19, 0.56),
		trunkRoot + V(0.2, 0.05, 0.9),
	} or {
		trunkRoot,
		trunkRoot + V(0, -0.43, 0.69),
		trunkRoot + V(0.12, -0.84, 1.13),
		trunkRoot + V(0.45, -0.52, 1.4),
		trunkRoot + V(0.51, -0.1, 1.27),
	}
	local trunk = curved(
		c,
		"Trunk",
		trunkPoints,
		young and { 0.6, 0.38 } or { adult and 0.72 or 0.61, 0.51, 0.35, 0.22 },
		blue,
		head,
		false,
		0.9
	)
	c:sphere("Nostril", V(0.18, 0.09, 0.15), trunkPoints[#trunkPoints] + V(0, 0.08, 0.02), c.dark, trunk)
	local tailBase = V(0, y - 0.28, -length * 0.59)
	local tail =
		c:segment("Tail1", tailBase, tailBase + V(0.16, -0.12, -0.69), young and 0.64 or 0.93, 0.5, blue, body, true)
	for _, side in { -1, 1 } do
		c:sphere(
			"TailFluke" .. side,
			V(young and 0.99 or 1.62, 0.29, young and 0.65 or 0.94),
			tailBase + V(side * (young and 0.43 or 0.68), -0.12, -0.85),
			blue,
			tail,
			false,
			A(0, side * -0.34, 0)
		)
	end
	for mark = 1, young and 2 or adult and 6 or 4 do
		local side = mark % 2 == 0 and -1 or 1
		c:sphere(
			"WaterSpot" .. mark,
			V(0.24, 0.16, 0.18),
			V(side * (young and 0.75 or 1.19), y + 0.6, -1.25 + math.floor(mark / 2) * 0.6),
			cream,
			body
		)
	end
	if adult then
		c:leaf("ForeheadShell", V(0, hy + 0.31, hz + 0.68), V(0, hy + 1.13, hz + 0.12), 0.83, coral, head)
		for _, side in { -1, 1 } do
			c:leaf(
				"TempleFin" .. side,
				V(side * 0.86, hy + 0.27, hz - 0.08),
				V(side * 1.44, hy + 0.72, hz - 0.55),
				0.53,
				coral,
				head
			)
		end
	end
	return { body = body, head = head }
end

local function diskRotation(normal)
	local up = math.abs(normal.Y) > 0.92 and V(0, 0, 1) or V(0, 1, 0)
	local right = up:Cross(normal).Unit
	return CFrame.fromMatrix(V(0, 0, 0), right, normal:Cross(right).Unit, normal)
end

function S.kraken(c)
	local indigo, deep, teal = rgb(72, 66, 120), rgb(36, 49, 83), rgb(73, 153, 164)
	local copper, cream, glow = rgb(211, 137, 100), rgb(245, 220, 182), rgb(139, 224, 203)
	local body = c:sphere("Body", V(4.35, 3.4, 4.0), V(0, 2.68, -0.1), indigo, c.root, true)
	c:sphere("Mantle", V(3.63, 4.59, 3.25), V(0, 4.46, -0.55), deep, body, false, A(-0.12, 0, 0))
	c:sphere("MantleCrest", V(2.94, 3.58, 2.63), V(0, 5.05, -0.59), teal, body, false, A(-0.13, 0, 0))
	c:sphere("MantleFlankL", V(1.15, 2.82, 2.67), V(-1.42, 3.94, -0.25), indigo, body, false, A(0.08, 0, -0.15))
	c:sphere("MantleFlankR", V(1.15, 2.82, 2.67), V(1.42, 3.94, -0.25), indigo, body, false, A(0.08, 0, 0.15))
	local head = c:sphere("Head", V(3.43, 2.0, 2.25), V(0, 2.87, 1.14), indigo, body, true)
	c:sphere("BeakGuard", V(1.48, 0.98, 1.03), V(0, 1.98, 1.76), cream, head)
	c:wedge("UpperBeak", V(0.62, 0.63, 0.63), V(0, 2.08, 2.3), deep, head, false, A(0.1, math.pi, 0))
	c:wedge("LowerBeak", V(0.51, 0.32, 0.48), V(0, 1.74, 2.19), copper, head, false, A(-0.13, 0, math.pi))
	for _, side in { -1, 1 } do
		local eyePoint = V(side * 0.97, 3.02, 2.09)
		c:sphere("EyeSocket" .. side, V(1.1, 0.84, 0.42), eyePoint - V(0, 0.01, 0.06), teal, head)
		local eye = c:sphere("Eye" .. (side < 0 and "L" or "R"), V(0.88, 0.61, 0.34), eyePoint, cream, head, true)
		c:sphere("Iris" .. (side < 0 and "L" or "R"), V(0.64, 0.49, 0.18), eyePoint + V(0, 0, 0.2), copper, eye)
		c:sphere("Pupil" .. side, V(0.48, 0.115, 0.12), eyePoint + V(0, 0, 0.31), deep, eye)
		c:sphere("EyeGlint" .. side, V(0.11, 0.1, 0.08), eyePoint + V(-0.12, 0.13, 0.37), cream, eye)
		c:sphere(
			"BrowHood" .. side,
			V(1.01, 0.22, 0.39),
			eyePoint + V(0, 0.27, 0.1),
			indigo,
			head,
			false,
			A(0, 0, side * 0.14)
		)
		c:leaf("GillMantleFin" .. side, V(side * 1.38, 3.36, 1.14), V(side * 2.31, 3.98, 0.41), 0.8, copper, head)
	end
	local armWidths = { 1.19, 0.99, 0.76, 0.52, 0.31 }
	for arm = 1, 8 do
		local angle = (arm - 1) * math.pi / 4 + math.pi / 8
		local radial, tangent = V(math.cos(angle), 0, math.sin(angle)), V(-math.sin(angle), 0, math.cos(angle))
		local asym = arm % 2 == 0 and 0.22 or -0.1
		local points = {
			radial * 1.24 + V(0, 1.88, 0),
			radial * 2.58 + tangent * 0.07 + V(0, 1.19 + asym, 0),
			radial * 4.02 + tangent * 0.38 + V(0, 0.7, 0),
			radial * 5.16 + tangent * 0.82 + V(0, 0.62 + asym, 0),
			radial * 5.89 + tangent * 1.17 + V(0, 1.06 + asym, 0),
			radial * 5.63 + tangent * 1.0 + V(0, 1.87 + asym, 0),
		}
		-- Cada braço tem uma única raiz articulada e cinco volumes sobrepostos em curva.
		local parent = body
		local segments = {}
		for segment = 1, 5 do
			parent = c:segment(
				"TailArm" .. arm .. "_" .. segment,
				points[segment],
				points[segment + 1],
				armWidths[segment],
				armWidths[segment] * 0.9,
				arm % 2 == 0 and teal or indigo,
				parent,
				segment == 1
			)
			segments[segment] = parent
		end
		c:sphere(
			"MantleWeb" .. arm,
			V(1.61, 0.38, 2.72),
			radial * 1.77 + V(0, 1.55, 0),
			indigo,
			body,
			false,
			A(0, -angle + math.pi / 2, 0)
		)
		for sample = 1, 3 do
			local segment = sample + 1
			local direction = (points[segment + 1] - points[segment]).Unit
			local normal = V(0, 0.72, 0.68) - direction * direction:Dot(V(0, 0.72, 0.68))
			normal = normal.Unit
			local across = direction:Cross(normal).Unit
			local center = points[segment]:Lerp(points[segment + 1], 0.48) + normal * (armWidths[segment] * 0.44)
			for row = 1, 2 do
				local position = center + across * (row == 1 and -0.17 or 0.17)
				local diameter = 0.35 - sample * 0.04
				local name = row == 1 and "RimPearlSucker" or "SuckerDisk"
				local disk = c:sphere(
					name .. arm .. "_" .. sample .. "_" .. row,
					V(diameter, diameter, 0.13),
					position,
					cream,
					segments[segment],
					false,
					diskRotation(normal)
				)
				c:sphere(
					"SuckerInlay" .. arm .. "_" .. sample .. "_" .. row,
					V(diameter * 0.48, diameter * 0.48, 0.08),
					position + normal * 0.065,
					copper,
					disk,
					false,
					diskRotation(normal)
				)
			end
		end
	end
	-- Coroa de ruínas e coral; fica ligada ao manto em vez de flutuar sobre a cabeça.
	for branch = 1, 5 do
		local x = (branch - 3) * 0.44
		local base = V(x, 6.13 - math.abs(x) * 0.08, -0.62)
		local top = base + V(x * 0.17, branch == 3 and 1.05 or 0.7, -0.12)
		local coralBranch = c:segment("CoralCrown" .. branch, base, top, 0.23, 0.27, copper, body)
		c:sphere("CoralCrownBud" .. branch, V(0.32, 0.3, 0.3), top, cream, coralBranch)
	end
	for marking = 1, 6 do
		local side = marking % 2 == 0 and -1 or 1
		c:leaf(
			"MantleInlay" .. marking,
			V(side * (0.32 + math.floor(marking / 2) * 0.3), 4.06 + marking * 0.2, 0.84),
			V(side * (0.46 + math.floor(marking / 2) * 0.3), 4.68 + marking * 0.18, 0.9),
			0.16,
			glow,
			body
		)
	end
	c:leaf("ForeheadRune", V(0, 3.57, 2.02), V(0, 4.14, 1.88), 0.39, glow, head)
	return { body = body, head = head }
end

return S
