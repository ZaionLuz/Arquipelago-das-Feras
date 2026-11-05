--!nonstrict
-- Anatomias autorais de maré e artrópodes. Coordenadas locais: +Z é a frente.
local S = {}
local C = Color3.fromRGB
local pearl = C(244, 221, 192)
local lagoon = C(82, 184, 183)
local rose = C(220, 133, 158)
local lavender = C(141, 137, 203)
local coral = C(229, 149, 115)
local function mouth(c, head, center, width, color)
	local V = c.V
	c:segment("Mouth", center + V(-width * 0.5, 0.03, 0), center + V(0, -0.04, 0.03), 0.065, 0.06, color, head)
	c:segment("MouthSmile", center + V(0, -0.04, 0.03), center + V(width * 0.5, 0.03, 0), 0.065, 0.06, color, head)
end

local function orbital(c, head, center, spacing, radius, color)
	local V = c.V
	for _, side in { -1, 1 } do
		local at = center + V(side * spacing * 0.5, radius * 0.88, radius * 0.19)
		c:segment(
			"OrbitalRim" .. side,
			at + V(-radius * 0.78, 0.025 * side, 0),
			at + V(radius * 0.78, -0.025 * side, 0.01),
			radius * 0.35,
			radius * 0.43,
			color,
			head
		)
	end
end

function S.bolhinho(c)
	local V, A, s = c.V, c.A, c.stage
	local baby = s == 1
	local blue = C(99, 176, 190)
	local mint = C(162, 222, 210)
	local body = c:sphere(
		"Body",
		V(baby and 2.8 or 3.3, baby and 2.5 or 2.8, baby and 2.7 or 3.4),
		V(0, 1.65, -0.25),
		blue,
		c.root,
		true
	)
	c:sphere("Tummy", V(2.65, 1.9, 1.8), V(0, 1.25, 0.43), pearl, body)
	local head =
		c:sphere("Head", V(baby and 2.5 or 2.85, 2.3, 2.25), V(0, baby and 2.08 or 2.23, 1.03), mint, body, true)
	c:eyes(head, V(0, 2.43, 2.05), 1.39, baby and 0.35 or 0.31, lagoon, -0.05)
	orbital(c, head, V(0, 2.43, 2.05), 1.39, baby and 0.35 or 0.31, blue)
	c:sphere("Muzzle", V(1.28, 0.58, 0.65), V(0, 1.72, 2.03), pearl, head)
	mouth(c, head, V(0, 1.62, 2.34), 0.6, c.dark)
	c:sphere("UpperLip", V(0.86, 0.18, 0.26), V(0, 1.76, 2.31), mint, head)
	c:sphere("DorsalWeb", V(0.34, baby and 0.62 or 0.92, baby and 1.15 or 1.75), V(0, 2.94, -0.91), lagoon, body)
	for _, side in { -1, 1 } do
		c:sphere("Cheek" .. side, V(0.51, 0.23, 0.15), V(side * 0.95, 1.94, 2.0), coral, head)
		local shoulder = V(side * 1.35, 1.55, 0.25)
		local tip = V(side * (baby and 2.02 or 2.7), 0.88, baby and 0.3 or -0.5)
		local fin = c:leaf("Fin" .. side, shoulder, tip, baby and 0.78 or 1.2, lagoon, body, true)
		c:segment("FinRib" .. side, shoulder, tip, 0.12, 0.1, pearl, fin)
		for feather = 1, s + 1 do
			local from = V(side * 1.14, 2.13 + feather * 0.12, 0.95 - feather * 0.3)
			c:leaf(
				"Gill" .. side .. "_" .. feather,
				from,
				from + V(side * (0.5 + s * 0.13), 0.28, -0.27),
				0.42,
				feather % 2 == 0 and lavender or coral,
				head
			)
		end
		c:sphere(
			"PaddleToe" .. side,
			V(0.8, 0.34, 0.95),
			V(side * 0.8, 0.28, 0.42),
			mint,
			body,
			true,
			A(0, side * 0.2, 0)
		)
	end
	local tailFrom, tailTo = V(0, 1.4, -1.48), V(0, 1.77, baby and -2.18 or -3.15)
	local tail = c:segment("Tail", tailFrom, tailTo, 0.7, 0.7, blue, body, true)
	for _, side in { -1, 1 } do
		c:leaf("TailFan" .. side, tailTo, tailTo + V(side * (baby and 0.7 or 1.15), 0.55, -0.45), 0.72, mint, tail)
	end
	local crown = s == 3 and 5 or s
	for i = 1, crown do
		local x = (i - (crown + 1) * 0.5) * 0.32
		c:leaf(
			"DorsalCrest" .. i,
			V(x, 2.78, -0.5),
			V(x * 1.5, 3.33 + (crown * 0.5 - math.abs(i - (crown + 1) * 0.5)) * 0.18, -0.9),
			0.45,
			i % 2 == 0 and pearl or lagoon,
			body
		)
	end
	for i = 1, 3 + s do
		local side = i % 2 == 0 and -1 or 1
		c:sphere(
			"WaterSpot" .. i,
			V(0.2, 0.24, 0.09),
			V(side * (1.05 + (i % 2) * 0.15), 1.65 + (i % 3) * 0.22, 1.43 - math.floor(i / 2) * 0.23),
			pearl,
			head
		)
	end
	return { body = body, head = head }
end

function S.marilisco(c)
	local V, s = c.V, c.stage
	local teal = C(70, 145, 158)
	local pale = C(167, 217, 199)
	local body = c:sphere("Body", V(2.1, 1.65, 2.35), V(0, 1.05, 0.47), teal, c.root, true)
	local head = c:sphere("Head", V(s == 1 and 1.95 or 2.1, 1.6, 1.98), V(0, 1.62, 1.98), pale, body, true)
	c:sphere("Snout", V(1.52, 0.69, 1.15), V(0, 1.29, 2.7), pearl, head)
	c:eyes(head, V(0, 1.92, 2.77), 1.1, s == 1 and 0.32 or 0.28, C(204, 151, 91), 0.05)
	orbital(c, head, V(0, 1.92, 2.77), 1.1, s == 1 and 0.32 or 0.28, teal)
	mouth(c, head, V(0, 1.13, 3.2), 0.8, c.dark)
	for _, side in { -1, 1 } do
		c:sphere("Nostril" .. side, V(0.12, 0.1, 0.06), V(side * 0.32, 1.53, 3.2), c.dark, head)
		c:leaf(
			"GillFan" .. side,
			V(side * 0.82, 1.64, 1.85),
			V(side * (1.42 + s * 0.15), 2.11, 1.14),
			0.72,
			lavender,
			head
		)
		local fin = c:leaf(
			"Fin" .. side,
			V(side * 0.78, 0.91, 0.78),
			V(side * (1.7 + 0.2 * s), 0.28, -0.25),
			0.98,
			pale,
			body,
			true
		)
		c:segment(
			"FinVein" .. side,
			V(side * 0.9, 0.9, 0.68),
			V(side * (1.55 + 0.2 * s), 0.35, -0.15),
			0.1,
			0.1,
			pearl,
			fin
		)
	end
	local previous, parent = V(0, 1.04, -0.2), body
	local count = s == 1 and 4 or s == 2 and 6 or 8
	for i = 1, count do
		local t = i / count
		local nextPos = V(
			math.sin(t * math.pi * 1.6) * (0.5 + s * 0.25),
			0.85 + math.sin(t * math.pi) * 0.31,
			-0.2 - t * (3.3 + s * 0.85)
		)
		local width = 1.86 * (1 - t * 0.78)
		local segment = c:segment("Coil" .. i, previous, nextPos, width, width * 0.87, teal, parent, true)
		c:sphere(
			"BellyScute" .. i,
			V(width * 0.72, width * 0.2, (nextPos - previous).Magnitude * 0.85),
			(previous + nextPos) * 0.5 - V(0, width * 0.32, 0),
			pale,
			segment
		)
		if i < count then
			c:leaf(
				"DorsalSail" .. i,
				nextPos,
				nextPos + V(0, 0.55 + math.sin(t * math.pi) * (0.38 + s * 0.18), -0.48),
				0.54 + s * 0.09,
				i % 2 == 0 and lagoon or lavender,
				segment
			)
		end
		previous, parent = nextPos, segment
	end
	for _, side in { -1, 1 } do
		c:leaf("TailBlade" .. side, previous, previous + V(side * (0.68 + s * 0.17), 0.5, -0.6), 0.78, pale, parent)
		if s >= 2 then
			local base = V(side * 0.73, 2.05, 1.95)
			local fork = V(side * 1.03, 2.64 + s * 0.1, 1.35)
			c:segment("CrownStem" .. side, base, fork, 0.17, 0.17, pearl, head)
			c:leaf("CrownSail" .. side, fork, fork + V(side * 0.24, 0.4, -0.45), 0.45, lagoon, head)
		end
	end
	return { body = body, head = head }
end

function S.carangueperola(c)
	local V, s = c.V, c.stage
	local shell = C(160, 148, 191)
	local cream = C(244, 220, 184)
	local body = c:sphere("Body", V(s == 1 and 2.85 or 3.5, 1.65, 2.8), V(0, 1.15, -0.05), shell, c.root, true)
	c:sphere("ShellRim", V(3.12, 0.45, 2.65), V(0, 1.9, -0.17), cream, body)
	local dome =
		c:sphere("PearlDome", V(s == 1 and 1.8 or 2.38, s == 3 and 2.25 or 1.9, 2.16), V(0, 2.02, -0.18), pearl, body)
	c:sphere("PearlIridescence", V(1.2, 0.55, 0.16), V(-0.42, 2.61, 0.77), C(185, 220, 222), dome)
	c:sphere("PearlHighlight", V(0.56, 0.38, 0.1), V(-0.49, 2.73, 0.66), c.cream, dome)
	local head = c:sphere("Head", V(2.35, 1.25, 1.62), V(0, 1.05, 1.28), cream, body, true)
	for _, side in { -1, 1 } do
		c:segment("EyeStalk" .. side, V(side * 0.62, 1.41, 1.6), V(side * 0.72, 2.04, 1.77), 0.26, 0.26, shell, head)
	end
	c:eyes(head, V(0, 2.07, 1.82), 1.5, s == 1 and 0.33 or 0.31, C(98, 172, 186), -0.07)
	orbital(c, head, V(0, 2.07, 1.82), 1.5, s == 1 and 0.33 or 0.31, shell)
	mouth(c, head, V(0, 0.99, 2.04), 0.72, c.dark)
	local pairs = s == 1 and 2 or s == 2 and 3 or 4
	for _, side in { -1, 1 } do
		for leg = 1, pairs do
			local z = 1.0 - (leg - 1) * 0.63
			local hip, elbow = V(side * 1.23, 1.24, z), V(side * (2.05 + leg * 0.08), 0.82, z - 0.2)
			local foot = V(side * (2.5 + leg * 0.09), 0.16, z - 0.48)
			local upper = c:segment("LegUpper" .. side .. "_" .. leg, hip, elbow, 0.43, 0.48, shell, body, true)
			local lower = c:segment("LegLower" .. side .. "_" .. leg, elbow, foot, 0.27, 0.31, cream, upper, true)
			c:sphere("LegKnuckle" .. side .. "_" .. leg, V(0.46, 0.43, 0.44), elbow, lagoon, upper)
			c:leaf(
				"LegToe" .. side .. "_" .. leg,
				foot + V(-side * 0.06, 0.1, 0),
				foot + V(side * 0.23, -0.06, -0.17),
				0.27,
				cream,
				lower
			)
		end
		local elbow = V(side * (s == 1 and 1.63 or 2.02), 1.21, 2.0)
		local arm = c:segment("ClawArm" .. side, V(side * 0.95, 1.15, 1.21), elbow, 0.56, 0.56, shell, body, true)
		local palm =
			c:sphere("ClawPalm" .. side, V(0.93, 0.86, 1.2), elbow + V(side * 0.19, 0.1, 0.43), cream, arm, true)
		local base = elbow + V(side * 0.22, 0.13, 0.7)
		c:leaf(
			"ClawUpper" .. side,
			base + V(-side * 0.23, 0.23, 0),
			base + V(side * 0.14, 0.13, 0.85),
			0.54,
			lagoon,
			palm
		)
		c:leaf(
			"ClawThumb" .. side,
			base + V(side * 0.23, -0.2, 0),
			base + V(side * 0.14, -0.06, 0.65),
			0.37,
			cream,
			palm
		)
		c:leaf(
			"ClawHook" .. side,
			base + V(side * 0.14, 0.13, 0.65),
			base + V(side * 0.12, -0.08, 1.0),
			0.3,
			lagoon,
			palm
		)
		c:sphere("ClawCuff" .. side, V(0.7, 0.62, 0.66), elbow, shell, arm)
		c:sphere("ClawPearl" .. side, V(0.29, 0.28, 0.27), elbow + V(side * 0.22, 0.54, 0.52), pearl, palm)
	end
	for i = 1, s == 1 and 3 or 5 do
		local a = i * math.pi * 2 / (s == 1 and 3 or 5)
		c:sphere(
			"RimPearl" .. i,
			V(0.3, 0.32, 0.3),
			V(math.cos(a) * 1.25, 1.98, math.sin(a) * 0.97 - 0.18),
			i % 2 == 0 and rose or lagoon,
			body
		)
	end
	if s >= 2 then
		for _, side in { -1, 1 } do
			local base = V(side * 0.94, 1.95, -0.74)
			local fork = base + V(side * 0.22, 0.75 + 0.12 * s, -0.11)
			c:segment("CoralTrunk" .. side, base, fork, 0.19, 0.21, rose, body)
			for branch = 1, s do
				local tip = fork + V(side * (0.2 + branch * 0.14), 0.28 + branch * 0.12, (branch - 1.5) * 0.24)
				c:segment("CoralBranch" .. side .. "_" .. branch, fork, tip, 0.13, 0.13, rose, body)
				c:sphere("CoralPolyp" .. side .. "_" .. branch, V(0.24, 0.24, 0.24), tip, coral, body)
			end
		end
	end
	return { body = body, head = head }
end

function S.abissauro(c)
	local V, s = c.V, c.stage
	local blue = C(61, 91, 125)
	local lilac = C(126, 139, 190)
	local glow = C(160, 220, 194)
	local body = c:sphere("Body", V(3.4, 2.5, s == 1 and 3.5 or 4.8), V(0, 1.65, -0.4), blue, c.root, true)
	c:sphere("Belly", V(2.55, 1.3, 3.5), V(0, 0.9, -0.2), lilac, body)
	local head = c:sphere("Head", V(s == 1 and 3.0 or 3.7, 2.5, 2.75), V(0, 1.91, 1.82), lilac, body, true)
	c:sphere("UpperMuzzle", V(2.8, 0.65, 1.0), V(0, 1.99, 3.0), lilac, head)
	local jaw = c:sphere("LowerJaw", V(3.2, 0.72, 2.25), V(0, 0.91, 2.55), pearl, head)
	c:sphere("MouthCavity", V(2.65, 0.9, 0.32), V(0, 1.38, 3.2), blue, head)
	c:segment("MouthUpperRim", V(-1.27, 1.82, 3.39), V(1.27, 1.82, 3.39), 0.22, 0.2, glow, head)
	c:eyes(head, V(0, 2.44, 2.9), 2.05, s == 1 and 0.36 or 0.28, C(224, 174, 90), 0.12)
	orbital(c, head, V(0, 2.44, 2.9), 2.05, s == 1 and 0.36 or 0.28, blue)
	for _, side in { -1, 1 } do
		c:sphere("NoseRidge" .. side, V(0.62, 0.38, 0.56), V(side * 0.65, 2.0, 3.05), blue, head)
		local shoulder = V(side * 1.43, 1.37, 0.75)
		local fin = c:leaf("Fin" .. side, shoulder, V(side * (2.2 + s * 0.3), 0.37, 0.1), 1.3, glow, body, true)
		c:segment("FinRib" .. side, shoulder, V(side * (2.1 + s * 0.3), 0.44, 0.22), 0.22, 0.15, blue, fin)
		for gill = 1, s + 1 do
			c:leaf(
				"GillRidge" .. side .. "_" .. gill,
				V(side * 1.47, 1.65, 1.25 - gill * 0.36),
				V(side * 1.85, 1.02, 0.95 - gill * 0.36),
				0.37,
				gill % 2 == 0 and pearl or glow,
				head
			)
		end
		for tooth = 1, s + 1 do
			local x = side * (0.4 + tooth * 0.24)
			c:leaf("UpperTooth" .. side .. "_" .. tooth, V(x, 1.75, 3.44), V(x * 0.96, 1.4, 3.52), 0.2, pearl, head)
		end
		c:leaf("JawTusk" .. side, V(side * 1.12, 1.05, 3.08), V(side * 1.19, 1.38, 3.25), 0.24, glow, jaw)
	end
	local count = s == 1 and 3 or 4 + s
	local previous, parent = V(0, 1.48, -1.35), body
	for i = 1, count do
		local t = i / count
		local nextPos = V(math.sin(t * 2.5) * 0.65, 1.3 + t * 0.8, -1.35 - t * (2.2 + s * 0.55))
		local tail =
			c:segment("Tail" .. i, previous, nextPos, 1.35 * (1 - t * 0.75), 1.1 * (1 - t * 0.7), blue, parent, true)
		previous, parent = nextPos, tail
	end
	for _, side in { -1, 1 } do
		c:leaf("TailFork" .. side, previous, previous + V(side * (0.65 + s * 0.12), 0.6, -0.55), 0.84, glow, parent)
	end
	local lurePoints = {}
	local p0, p1, p2 = V(0, 2.8, 1.2), V(0, 5.15 + s * 0.18, 0.86), V(0, 3.62 + s * 0.17, 2.42)
	for i = 0, 5 do
		local t = i / 5
		lurePoints[i + 1] = p0 * (1 - t) ^ 2 + p1 * (2 * (1 - t) * t) + p2 * t ^ 2
	end
	for i = 1, #lurePoints - 1 do
		c:segment("LureStem" .. i, lurePoints[i], lurePoints[i + 1], 0.18 - i * 0.009, 0.18 - i * 0.009, blue, head)
	end
	c:sphere("LureLantern", V(0.7, 0.74, 0.68), lurePoints[#lurePoints], glow, head)
	c:sphere("LureGleam", V(0.2, 0.2, 0.11), lurePoints[#lurePoints] + V(-0.13, 0.15, 0.27), c.cream, head)
	for i = 1, s + 2 do
		c:leaf("BackSail" .. i, V(0, 2.54, -0.6 - i * 0.52), V(0, 3.24 - i * 0.11, -1.2 - i * 0.52), 0.75, lilac, body)
	end
	return { body = body, head = head }
end

function S.aracnoflora(c)
	local V, s = c.V, c.stage
	local adult = s == 3
	local green = C(108, 155, 111)
	local light = C(175, 202, 132)
	local petal = C(215, 135, 163)
	local body = c:sphere(
		"Body",
		adult and V(3.3, 2.05, 3.25) or V(2.75, 1.75, 2.55),
		adult and V(0, 1.46, -0.83) or V(0, 1.18, -0.56),
		green,
		c.root,
		true
	)
	local head = c:sphere("Head", V(1.98, 1.35, 1.7), V(0, 1.26, 1.2), light, body, true)
	c:sphere("FaceMask", V(1.68, 0.72, 0.4), V(0, 1.13, 1.96), pearl, head)
	c:eyes(head, V(0, 1.47, 1.96), 1.04, s == 1 and 0.31 or 0.28, C(122, 91, 150), -0.08)
	orbital(c, head, V(0, 1.47, 1.96), 1.04, s == 1 and 0.31 or 0.28, green)
	mouth(c, head, V(0, 0.98, 2.17), 0.56, c.dark)
	for _, side in { -1, 1 } do
		c:sphere("Cheek" .. side, V(0.32, 0.16, 0.1), V(side * 0.7, 1.09, 2.06), petal, head)
		c:leaf("Palp" .. side, V(side * 0.52, 0.95, 1.7), V(side * 0.77, 0.65, 2.32), 0.38, green, head, true)
		local antenna = V(side * 0.66, 1.72, 1.25)
		c:segment("Antenna" .. side, antenna, antenna + V(side * 0.2, 0.62, -0.16), 0.13, 0.13, green, head)
		c:leaf(
			"AntennaLeaf" .. side,
			antenna + V(side * 0.17, 0.47, -0.11),
			antenna + V(side * 0.48, 0.83, -0.31),
			0.42,
			petal,
			head
		)
	end
	local pairs = s == 1 and 3 or 4
	for _, side in { -1, 1 } do
		for leg = 1, pairs do
			local z = 1.0 - (leg - 1) * 0.7
			local hip = V(side * (adult and 1.14 or 0.98), adult and 1.44 or 1.2, z)
			local knee = V(side * (1.7 + leg * 0.11), (adult and 1.72 or 1.22) + (leg % 2) * 0.18, z - 0.2)
			local foot = V(side * ((adult and 2.85 or 2.3) + leg * 0.1), 0.18, z - 0.42)
			local upper = c:leaf("LegUpper" .. side .. "_" .. leg, hip, knee, adult and 0.54 or 0.42, light, body, true)
			local lower
			if adult then
				local ankle = V(side * (2.55 + leg * 0.1), 0.66, z - 0.43)
				lower = c:segment("LegLower" .. side .. "_" .. leg, knee, ankle, 0.2, 0.24, green, upper, true)
				lower = c:segment("LegAnkle" .. side .. "_" .. leg, ankle, foot, 0.17, 0.2, light, lower, true)
			else
				lower = c:segment("LegLower" .. side .. "_" .. leg, knee, foot, 0.17, 0.2, green, upper, true)
			end
			c:sphere("LegBud" .. side .. "_" .. leg, V(0.32, 0.3, 0.3), knee, petal, upper)
			c:leaf(
				"RootFoot" .. side .. "_" .. leg,
				foot + V(-side * 0.1, 0.02, 0),
				foot + V(side * 0.21, -0.11, 0.13),
				0.28,
				light,
				lower
			)
		end
	end
	local center = adult and V(0, 2.62, -0.87) or V(0, 2.02, -0.6)
	c:segment(
		"FlowerPedicel",
		V(0, adult and 2.05 or 1.65, -0.65),
		center + V(0, 0.23, 0),
		adult and 0.92 or 0.65,
		adult and 0.98 or 0.72,
		green,
		body
	)
	if adult then
		-- O cálice adulto sustenta a flor aberta e muda sua silhueta para além de uma escala maior.
		for i = 1, 7 do
			local angle = (i + 0.5) * math.pi * 2 / 7
			local radial = V(math.cos(angle), 0, math.sin(angle))
			c:leaf(
				"FlowerSepal" .. i,
				center - V(0, 0.25, 0),
				center + radial * 2.15 - V(0, 0.46, 0),
				0.72,
				light,
				body
			)
		end
		for _, side in { -1, 1 } do
			c:leaf("AbdomenLeaf" .. side, V(side * 0.45, 1.55, -1.7), V(side * 1.25, 1.78, -3.25), 1.15, green, body)
		end
	end
	local petals = s == 1 and 5 or s == 2 and 7 or 9
	for i = 1, petals do
		local a = i * math.pi * 2 / petals
		local radial = V(math.cos(a), 0, math.sin(a))
		local closed = s == 1
		local tip = center
			+ radial * (closed and 0.65 or s == 2 and 1.55 or 2.15)
			+ V(0, closed and 1.13 or adult and (0.48 + i % 2 * 0.14) or 0.36, 0)
		c:leaf(
			"FlowerOuter" .. i,
			center - radial * 0.23,
			tip,
			closed and 0.83 or adult and 1.22 or 1.1,
			i % 2 == 0 and rose or petal,
			body
		)
		if adult and i % 2 == 1 then
			c:leaf("PetalVein" .. i, center + V(0, 0.13, 0), center:Lerp(tip, 0.85) + V(0, 0.14, 0), 0.13, pearl, body)
		end
	end
	if s >= 2 then
		local innerCount = adult and 7 or 5
		for i = 1, innerCount do
			local a = i * math.pi * 2 / innerCount + 0.4
			local radius = adult and 1.12 or 0.8
			c:leaf(
				"FlowerInner" .. i,
				center,
				center + V(math.cos(a) * radius, adult and 0.9 or 0.76, math.sin(a) * radius),
				adult and 0.85 or 0.7,
				lavender,
				body
			)
		end
	end
	c:sphere(
		"FlowerHeart",
		V(s == 1 and 0.55 or 0.85, 0.48, s == 1 and 0.55 or 0.85),
		center + V(0, 0.58, 0),
		c.gold,
		body
	)
	for i = 1, 3 + s do
		local a = i * math.pi * 2 / (3 + s)
		c:sphere(
			"Pollen" .. i,
			V(0.15, 0.17, 0.15),
			center + V(math.cos(a) * 0.31, 0.88, math.sin(a) * 0.31),
			pearl,
			body
		)
	end
	return { body = body, head = head }
end

function S.escorpiodra(c)
	local V, s = c.V, c.stage
	local sand = C(188, 154, 101)
	local armor = C(121, 101, 93)
	local jade = C(107, 163, 161)
	local body = c:sphere("Body", V(2.4, 1.35, s == 1 and 2.7 or 3.5), V(0, 1.03, -0.3), sand, c.root, true)
	local head = c:sphere("Head", V(1.94, 1.2, 1.64), V(0, 1.2, 1.47), armor, body, true)
	c:sphere("FacePlate", V(1.6, 0.74, 0.42), V(0, 1.07, 2.14), sand, head)
	c:eyes(head, V(0, 1.46, 2.15), 1.04, s == 1 and 0.29 or 0.25, C(219, 171, 86), 0.1)
	orbital(c, head, V(0, 1.46, 2.15), 1.04, s == 1 and 0.29 or 0.25, sand)
	mouth(c, head, V(0, 0.94, 2.35), 0.53, c.dark)
	for plate = 1, 2 + s do
		local z = 0.68 - plate * 0.57
		c:sphere(
			"Carapace" .. plate,
			V(2.14 - plate * 0.09, 0.38, 0.75),
			V(0, 1.65, z),
			plate % 2 == 0 and armor or sand,
			body
		)
		if s == 3 then
			c:leaf("SpinalThorn" .. plate, V(0, 1.78, z), V(0, 2.1, z - 0.23), 0.24, jade, body)
		end
	end
	local pairs = s == 1 and 3 or 4
	for _, side in { -1, 1 } do
		for leg = 1, pairs do
			local z = 0.88 - (leg - 1) * 0.69
			local hip, knee = V(side * 1.0, 1.03, z), V(side * (1.65 + leg * 0.08), 0.8, z - 0.12)
			local foot = V(side * (2.2 + leg * 0.11), 0.14, z - 0.42)
			local upper = c:segment("LegUpper" .. side .. "_" .. leg, hip, knee, 0.29, 0.35, armor, body, true)
			local lower = c:segment("LegLower" .. side .. "_" .. leg, knee, foot, 0.19, 0.24, sand, upper, true)
			c:leaf(
				"ClawedToe" .. side .. "_" .. leg,
				foot + V(-side * 0.06, 0.06, 0),
				foot + V(side * 0.2, -0.04, 0.15),
				0.2,
				jade,
				lower
			)
		end
		local elbow = V(side * (s == 1 and 1.42 or 1.77), 1.12, 1.93)
		local arm = c:segment("PincerArm" .. side, V(side * 0.8, 1.1, 1.18), elbow, 0.4, 0.44, armor, body, true)
		local palmPos = elbow + V(side * 0.33, 0, 0.56)
		local palm = c:sphere("PincerPalm" .. side, V(0.85 + s * 0.1, 0.68, 1.13), palmPos, sand, arm, true)
		c:sphere("PincerKnuckle" .. side, V(0.57, 0.52, 0.6), elbow, sand, arm)
		c:sphere("PincerPlate" .. side, V(0.62, 0.18, 0.78), palmPos + V(0, 0.34, 0), jade, palm)
		local tip = palmPos + V(side * 0.02, 0, 1.16)
		c:leaf(
			"PincerFinger" .. side,
			palmPos + V(-side * 0.32, 0.13, 0.3),
			tip + V(-side * 0.1, 0.16, 0),
			0.45,
			armor,
			palm
		)
		c:leaf(
			"PincerHook" .. side,
			tip + V(-side * 0.1, 0.16, -0.16),
			tip + V(side * 0.04, -0.12, 0.1),
			0.23,
			jade,
			palm
		)
		c:leaf(
			"PincerThumb" .. side,
			palmPos + V(side * 0.31, -0.12, 0.3),
			tip + V(side * 0.1, -0.05, -0.19),
			0.36,
			sand,
			palm
		)
	end
	local count = s == 1 and 3 or s == 2 and 5 or 7
	local previous, parent = V(0, 1.06, -1.28), body
	for i = 1, count do
		local t = i / count
		local nextPos = V(
			0,
			1.06 + math.sin(t * math.pi * 0.7) * (1.1 + s * 0.62),
			-1.28 - math.sin(t * math.pi) * (1.15 + s * 0.3) + t * 0.48
		)
		local width = 0.74 * (1 - t * 0.48)
		local tail = c:segment("Tail" .. i, previous, nextPos, width, width * 1.08, armor, parent, true)
		c:sphere(
			"TailScute" .. i,
			V(width * 1.11, width * 0.5, width * 1.0),
			(previous + nextPos) * 0.5 + V(0, width * 0.24, 0),
			sand,
			tail
		)
		previous, parent = nextPos, tail
	end
	local venom = c:sphere("StingerBulb", V(0.65 + 0.06 * s, 0.68, 0.76), previous + V(0, 0.12, 0.12), armor, parent)
	c:leaf("Stinger", previous + V(0, 0.13, 0.32), previous + V(0, -0.45, 0.91), 0.35, jade, venom)
	return { body = body, head = head }
end
return S
