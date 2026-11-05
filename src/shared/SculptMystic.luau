--!nonstrict
-- Anatomias autorais de sementes, pedra, musgo e vapor. Coordenadas locais; frente = +Z.
local M = {}

local function smile(c, head, y, z, width)
	local V = c.V
	c:segment("SmileL", V(-width, y + 0.035, z), V(0, y - 0.025, z + 0.025), 0.045, 0.045, c.dark, head)
	c:segment("SmileR", V(0, y - 0.025, z + 0.025), V(width, y + 0.035, z), 0.045, 0.045, c.dark, head)
end

local function cyclops(c, head, center, radius, iris)
	local V = c.V
	local eye = c:sphere("EyeCenter", V(radius * 2.15, radius * 2.3, radius * 0.78), center, c.cream, head, true)
	c:sphere("IrisCenter", V(radius * 1.44, radius * 1.63, radius * 0.36), center + V(0, 0, radius * 0.35), iris, eye)
	c:sphere(
		"PupilCenter",
		V(radius * 0.77, radius * 1.14, radius * 0.24),
		center + V(0.025, -0.015, radius * 0.52),
		c.dark,
		eye
	)
	c:sphere(
		"EyeGlintCenter",
		V(radius * 0.42, radius * 0.46, radius * 0.16),
		center + V(-radius * 0.3, radius * 0.37, radius * 0.66),
		c.cream,
		eye
	)
	c:sphere(
		"EyeGlintSmall",
		V(radius * 0.18, radius * 0.18, radius * 0.12),
		center + V(radius * 0.22, -radius * 0.31, radius * 0.65),
		c.cream,
		eye
	)
	return eye
end

function M.brotinho(c)
	local V, A = c.V, c.A
	local s = c.stage
	local jade = Color3.fromRGB(86, 132, 76)
	local leaf = Color3.fromRGB(160, 190, 94)
	local bud = Color3.fromRGB(225, 150, 142)
	local bark = Color3.fromRGB(142, 106, 70)
	local height = ({ 0.96, 1.25, 1.5 })[s]
	local body = c:sphere("Body", V(1.48 + s * 0.14, height * 1.35, 1.36), V(0, height, -0.12), jade, c.root, true)
	c:sphere("SeedBelly", V(1.08, height * 1.05, 0.64), V(0, height - 0.08, 0.48), c.cream, body)
	local headY = height + (s == 1 and 0.72 or 0.9)
	local head = c:sphere("Head", V(s == 1 and 1.75 or 1.61, 1.4, 1.3), V(0, headY, 0.38), leaf, body, true)
	c:sphere("FaceMask", V(1.36, 0.97, 0.62), V(0, headY - 0.15, 0.88), c.cream, head)
	c:eyes(head, V(0, headY + 0.1, 1.08), 0.8, s == 1 and 0.25 or 0.225, jade, -0.08)
	smile(c, head, headY - 0.34, 1.18, 0.18)
	for _, side in { -1, 1 } do
		c:sphere("Cheek" .. side, V(0.27, 0.14, 0.12), V(side * 0.52, headY - 0.22, 1.14), bud, head)
		for _, front in { -1, 1 } do
			local hip = V(side * 0.56, height - 0.22, front * 0.39)
			local toe = V(side * (s == 1 and 0.78 or 0.94), 0.15, front * 0.62 + 0.12)
			local knee = V(side * 0.77, 0.42, front * 0.48)
			local upper = c:segment("LegRoot" .. side .. front, hip, knee, 0.31, 0.34, bark, body, true)
			c:segment("RootAnkle" .. side .. front, knee, toe, 0.2, 0.24, bark, upper)
			c:sphere("RootToe" .. side .. front, V(0.4, 0.22, 0.54), toe, bark, upper)
		end
		local arm = c:segment(
			"LeafArm" .. side,
			V(side * 0.67, height + 0.12, 0),
			V(side * 1.08, height - 0.05, 0.27),
			0.22,
			0.24,
			jade,
			body,
			true
		)
		c:leaf(
			"LeafHand" .. side,
			V(side * 1.02, height - 0.05, 0.26),
			V(side * 1.33, height + 0.26, 0.4),
			0.51,
			leaf,
			arm
		)
		c:leaf(
			"LeafEar" .. side,
			V(side * 0.55, headY + 0.43, 0.23),
			V(side * (0.92 + s * 0.08), headY + 1.12, 0.11),
			0.64,
			jade,
			head,
			true
		)
		c:segment(
			"EarVein" .. side,
			V(side * 0.58, headY + 0.52, 0.33),
			V(side * 0.88, headY + 1, 0.24),
			0.04,
			0.04,
			leaf,
			head
		)
	end
	local crownBase = V(0, headY + 0.54, 0.14)
	local stem = c:segment("SeedStem", crownBase, crownBase + V(0.06, 0.63 + s * 0.09, -0.12), 0.16, 0.16, bark, head)
	if s == 1 then
		c:leaf("UnfurledBud", crownBase + V(0, 0.43, -0.1), crownBase + V(0.42, 1.1, -0.12), 0.58, leaf, stem)
		c:sphere("SleepingSeed", V(0.32, 0.44, 0.34), crownBase + V(-0.12, 0.81, -0.16), bud, stem)
	else
		for n = 1, s == 3 and 7 or 4 do
			local angle = n / (s == 3 and 7 or 4) * math.pi * 2
			local start = crownBase + V(0.04, 0.61, -0.12)
			local finish = start + V(math.cos(angle) * 0.62, 0.22, math.sin(angle) * 0.62)
			c:leaf("FlowerPetal" .. n, start, finish, 0.48, n % 2 == 0 and bud or c.cream, stem)
		end
		c:sphere("PollenHeart", V(0.35, 0.3, 0.35), crownBase + V(0.04, 0.76, -0.12), c.gold, stem)
		for n = 1, 5 do
			local angle = n * math.pi * 2 / 5
			c:leaf(
				"LeafCollar" .. n,
				V(0, height + 0.51, -0.12),
				V(math.cos(angle) * 1.03, height + 0.12, math.sin(angle) * 0.79 - 0.12),
				0.44,
				n % 2 == 0 and leaf or jade,
				body
			)
		end
	end
	if s == 3 then
		for n = 1, 4 do
			local angle = n * math.pi / 2
			c:leaf(
				"BackFrond" .. n,
				V(0, height + 0.2, -0.47),
				V(math.cos(angle) * 0.9, height + 0.6, -1.03 - math.sin(angle) * 0.21),
				0.48,
				jade,
				body,
				false,
				A(0, 0, 0)
			)
		end
	end
	return { body = body, head = head }
end

function M.ancestravore(c)
	local V = c.V
	local s = c.stage
	local wood = Color3.fromRGB(115, 88, 65)
	local ridge = Color3.fromRGB(165, 130, 84)
	local moss = Color3.fromRGB(117, 151, 87)
	local leaf = Color3.fromRGB(174, 189, 112)
	local hipY = ({ 1.05, 1.85, 2.35 })[s]
	local chestY = hipY + (s == 1 and 0.7 or 1.2)
	local body =
		c:sphere("Body", V(1.65 + s * 0.24, s == 1 and 1.8 or 2.6, 1.43), V(0, chestY, -0.06), wood, c.root, true)
	c:sphere("RootPelvis", V(1.7 + s * 0.2, 1.1, 1.6), V(0, hipY + 0.13, -0.1), wood, body)
	c:sphere("ChestHeartwood", V(1.32, 1.92, 0.37), V(0, chestY - 0.12, 0.68), ridge, body)
	for n = 1, 3 do
		c:segment(
			"GrainRidge" .. n,
			V((n - 2) * 0.3, chestY - 0.82, 0.87),
			V((n - 2) * 0.26, chestY + 0.78, 0.84),
			0.085,
			0.075,
			wood,
			body
		)
	end
	local neckTop = chestY + (s == 1 and 1.12 or 1.43)
	c:segment("Neck", V(0, chestY + 0.64, 0.08), V(0, neckTop, 0.35), 0.93, 0.84, wood, body)
	local head = c:sphere("Head", V(s == 1 and 1.52 or 1.43, 1.73, 1.36), V(0, neckTop + 0.48, 0.42), ridge, body, true)
	c:sphere("StagMuzzle", V(0.91, 0.62, 1.23), V(0, neckTop + 0.13, 1.04), c.cream, head)
	c:sphere("VelvetNose", V(0.5, 0.27, 0.27), V(0, neckTop + 0.19, 1.58), wood, head)
	c:eyes(head, V(0, neckTop + 0.74, 1.04), 0.91, s == 1 and 0.255 or 0.225, moss, 0.12)
	for _, side in { -1, 1 } do
		local shoulder = V(side * (0.92 + s * 0.07), chestY + 0.59, -0.05)
		local elbow = V(side * (1.23 + s * 0.1), hipY + 0.43, 0.09)
		local handPos = V(side * (1.3 + s * 0.1), hipY - 0.04, 0.63)
		c:sphere("Shoulder" .. side, V(0.85, 1.1, 0.94), shoulder, moss, body)
		local arm = c:segment("ArmBough" .. side, shoulder, elbow, 0.58, 0.64, wood, body, true)
		c:segment("ForearmRoot" .. side, elbow, handPos, 0.47, 0.52, ridge, arm)
		c:sphere("Palm" .. side, V(0.68, 0.63, 0.56), handPos, wood, arm)
		for digit = 1, 3 do
			local base = handPos + V((digit - 2) * 0.2, -0.12, 0.09)
			c:segment("RootFinger" .. side .. digit, base, base + V(side * 0.08, -0.27, 0.26), 0.15, 0.17, ridge, arm)
		end
		local hip = V(side * 0.65, hipY + 0.08, -0.1)
		local knee = V(side * 0.76, hipY * 0.48, 0.03)
		local footPos = V(side * 0.87, 0.23, 0.34)
		local leg = c:segment("LegTrunk" .. side, hip, knee, 0.72, 0.84, wood, body, true)
		c:segment("RootShin" .. side, knee, footPos, 0.54, 0.64, ridge, leg)
		c:sphere("RootFoot" .. side, V(0.96, 0.43, 1.14), footPos, wood, leg)
		for toe = 1, 3 do
			c:segment(
				"FootRoot" .. side .. toe,
				footPos + V((toe - 2) * 0.25, -0.02, 0.2),
				footPos + V((toe - 2) * 0.34, -0.09, 0.74),
				0.18,
				0.22,
				ridge,
				leg
			)
		end
		c:leaf(
			"StagEar" .. side,
			V(side * 0.52, neckTop + 0.77, 0.31),
			V(side * 1.15, neckTop + 1.12, 0.15),
			0.52,
			moss,
			head,
			true
		)
		local antlerRoot = V(side * 0.43, neckTop + 1.1, 0.22)
		local main = c:segment(
			"AntlerStem" .. side,
			antlerRoot,
			antlerRoot + V(side * 0.2, s == 1 and 0.48 or 1.15, -0.1),
			0.19,
			0.2,
			ridge,
			head
		)
		if s >= 2 then
			local first = antlerRoot + V(side * 0.2, 0.78, -0.08)
			local tip = first + V(side * 0.7, 0.68 + (s - 2) * 0.3, -0.1)
			c:segment("AntlerCrown" .. side, first, tip, 0.16, 0.18, ridge, main)
			for branch = 1, s == 3 and 3 or 2 do
				local point = first:Lerp(tip, branch / (s == 3 and 4 or 3))
				local endPos = point + V(-side * 0.38, 0.48 + branch * 0.08, 0.07)
				c:segment("AntlerFork" .. side .. branch, point, endPos, 0.13, 0.14, ridge, main)
				c:leaf(
					"AntlerLeaf" .. side .. branch,
					endPos - V(0, 0.13, 0),
					endPos + V(side * 0.22, 0.24, 0.09),
					0.32,
					leaf,
					main
				)
			end
		end
		if s == 3 then
			for frond = 1, 3 do
				c:leaf(
					"ShoulderMoss" .. side .. frond,
					shoulder + V(0, 0.18, 0),
					shoulder + V(side * (0.27 + frond * 0.13), -0.55, (frond - 2) * 0.24),
					0.47,
					frond % 2 == 0 and leaf or moss,
					body
				)
			end
		end
	end
	if s == 3 then
		c:sphere("HeartwoodCore", V(0.45, 0.5, 0.15), V(0, chestY + 0.25, 0.89), c.gold, body)
		for n = 1, 4 do
			local angle = n * math.pi / 2
			c:leaf(
				"BackCanopy" .. n,
				V(0, chestY + 0.25, -0.64),
				V(math.cos(angle) * 1.25, chestY + 1, -0.9 + math.sin(angle) * 0.55),
				0.75,
				moss,
				body
			)
		end
	end
	return { body = body, head = head }
end

function M.graozinho(c)
	local V, A = c.V, c.A
	local s = c.stage
	local sand = Color3.fromRGB(180, 151, 110)
	local edge = Color3.fromRGB(218, 190, 145)
	local violet = Color3.fromRGB(142, 137, 184)
	local crystal = Color3.fromRGB(190, 196, 222)
	local y = s == 1 and 0.83 or s == 2 and 1 or 1.23
	local width = 1.8 + s * 0.34
	local length = 1.7 + s * 0.38
	local body = c:sphere("Body", V(width, 1.3 + s * 0.12, length), V(0, y, -0.28), sand, c.root, true)
	c:sphere("GeodeUnderside", V(width * 0.84, 0.67, length * 0.87), V(0, y - 0.44, -0.17), edge, body)
	local head =
		c:sphere("Head", V(s == 1 and 1.51 or 1.35, 1.18, 1.12), V(0, y + 0.03, length * 0.34), edge, body, true)
	c:sphere("StoneSnout", V(0.91, 0.47, 0.62), V(0, y - 0.18, length * 0.34 + 0.5), c.cream, head)
	c:eyes(head, V(0, y + 0.23, length * 0.34 + 0.47), 0.76, s == 1 and 0.245 or 0.21, violet, -0.13)
	smile(c, head, y - 0.26, length * 0.34 + 0.8, 0.17)
	for _, side in { -1, 1 } do
		for n = 1, 2 do
			local foot = V(side * width * 0.41, 0.22, n == 1 and length * 0.22 or -length * 0.54)
			c:sphere("PebbleFoot" .. side .. n, V(0.64, 0.42, 0.85), foot, sand, body)
			c:wedge(
				"ToeFacet" .. side .. n,
				V(0.43, 0.22, 0.43),
				foot + V(0, 0.09, 0.23),
				edge,
				body,
				false,
				A(0, 0, side * 0.1)
			)
		end
		for plate = 1, s == 1 and 3 or 5 do
			local z = -length * 0.61 + plate * length * 0.17
			c:sphere(
				"ShellBand" .. side .. plate,
				V(width * 0.54, 0.5, 0.46),
				V(side * width * 0.25, y + 0.48, z),
				plate % 2 == 0 and edge or sand,
				body,
				false,
				A(0, 0, side * 0.27)
			)
		end
	end
	local count = ({ 3, 5, 7 })[s]
	for n = 1, count do
		local z = -length * 0.49 + n / (count + 1) * length * 0.84
		local rise = s == 1 and 0.32 or 0.49 + math.sin(n * 1.9) * 0.2 + (s == 3 and 0.26 or 0)
		local base = V((n % 2 == 0 and -1 or 1) * 0.13, y + 0.56, z)
		c:wedge(
			"GeodeCrystal" .. n,
			V(0.34 + s * 0.035, rise * 1.5, 0.43),
			base + V(0, rise * 0.5, 0),
			n % 2 == 0 and violet or crystal,
			body,
			false,
			A(0.12, n * 0.8, n % 2 == 0 and -0.2 or 0.2)
		)
	end
	if s == 3 then
		for _, side in { -1, 1 } do
			local first = V(side * 0.7, y + 0.36, length * 0.2)
			local horn =
				c:segment("StoneHornBase" .. side, first, first + V(side * 0.49, 0.5, -0.18), 0.45, 0.43, sand, head)
			c:segment(
				"StoneHornCurl" .. side,
				first + V(side * 0.49, 0.5, -0.18),
				first + V(side * 0.55, 0.17, -0.6),
				0.32,
				0.31,
				edge,
				horn
			)
			c:wedge("HornGem" .. side, V(0.19, 0.36, 0.29), first + V(side * 0.55, 0.17, -0.66), violet, horn)
		end
	end
	local tailStart = V(0, y - 0.22, -length * 0.58)
	local tail =
		c:segment("Tail1", tailStart, tailStart + V(0.1, -0.13, -0.55 - s * 0.15), 0.36, 0.35, sand, body, true)
	c:wedge(
		"TailFacet",
		V(0.44, 0.4, 0.51),
		tailStart + V(0.1, -0.13, -0.7 - s * 0.15),
		edge,
		tail,
		false,
		A(0, math.pi, 0)
	)
	return { body = body, head = head }
end

function M.colossodune(c)
	local V, A = c.V, c.A
	local s = c.stage
	local stone = Color3.fromRGB(157, 130, 94)
	local edge = Color3.fromRGB(213, 183, 132)
	local teal = Color3.fromRGB(88, 143, 145)
	local shadow = Color3.fromRGB(95, 89, 105)
	if s == 1 then
		-- A semente de ruína ainda é maciça e redonda. Os arcos só se abrem na forma juvenil.
		local body = c:sphere("Body", V(2.34, 1.67, 1.86), V(0, 1.04, -0.1), stone, c.root, true)
		c:sphere("InfantFoundation", V(2.03, 0.49, 1.65), V(0, 0.44, -0.01), edge, body)
		local head = c:sphere("Head", V(1.68, 1.39, 1.17), V(0, 1.55, 0.61), edge, body, true)
		cyclops(c, head, V(0, 1.64, 1.13), 0.36, teal)
		c:sphere("InfantChin", V(0.87, 0.37, 0.5), V(0, 1.13, 1.04), stone, head)
		smile(c, head, 1.14, 1.31, 0.15)
		for _, side in { -1, 1 } do
			local hand =
				c:sphere("PebbleArm" .. side, V(0.66, 0.91, 0.75), V(side * 1.16, 0.97, 0.18), stone, body, true)
			c:sphere("InfantPalm" .. side, V(0.64, 0.43, 0.68), V(side * 1.25, 0.61, 0.4), edge, hand)
			c:sphere("LegPebble" .. side, V(0.78, 0.48, 0.96), V(side * 0.69, 0.27, 0.28), stone, body, true)
			c:wedge(
				"CrownSeed" .. side,
				V(0.43, 0.52, 0.61),
				V(side * 0.55, 2.18, 0.17),
				stone,
				head,
				false,
				A(0, side * 0.18, side * -0.15)
			)
			c:sphere("DormantArchGlyph" .. side, V(0.15, 0.25, 0.1), V(side * 0.61, 1.03, 0.78), teal, body)
		end
		c:sphere("CrownSeedGem", V(0.33, 0.3, 0.24), V(0, 2.19, 0.62), teal, head)
		return { body = body, head = head }
	end
	local hips = ({ 1.02, 1.7, 2.2 })[s]
	local chest = hips + (s == 1 and 0.82 or s == 2 and 1.4 or 1.9)
	local body = c:block("Body", V(1.8 + s * 0.28, 0.9, 1.55), V(0, hips + 0.26, 0), stone, c.root, true)
	c:wedge("PelvisKeystone", V(0.94, 0.83, 0.55), V(0, hips + 0.18, 0.94), edge, body, false, A(0, math.pi, 0))
	for _, side in { -1, 1 } do
		local hip = V(side * (0.55 + s * 0.09), hips + 0.08, 0)
		local knee = V(side * (0.69 + s * 0.09), hips * 0.47, 0.08)
		local footPos = V(side * (0.79 + s * 0.1), 0.26, 0.38)
		local leg = c:block(
			"LegPillar" .. side,
			V(0.85, hips * 0.65, 0.97),
			(hip + knee) * 0.5,
			stone,
			body,
			true,
			A(0, 0, side * 0.1)
		)
		c:block("ShinPlinth" .. side, V(0.73, math.max(0.5, hips * 0.52), 0.88), (knee + footPos) * 0.5, edge, leg)
		c:sphere("StoneFoot" .. side, V(1.18, 0.55, 1.46), footPos, stone, leg)
		for toe = 1, 3 do
			c:block(
				"SandstoneToe" .. side .. toe,
				V(0.27, 0.24, 0.43),
				footPos + V((toe - 2) * 0.3, -0.06, 0.56),
				edge,
				leg
			)
		end
		local lower = V(side * (0.8 + s * 0.12), hips + 0.56, 0)
		local curve = V(side * (1.08 + s * 0.1), chest - 0.22, -0.04)
		local top = V(side * 0.61, chest + 0.32, -0.04)
		local arch = c:segment("TorsoArch" .. side, lower, curve, 0.56, 0.72, stone, body)
		c:segment("ArchUpper" .. side, curve, top, 0.63, 0.76, edge, arch)
		c:block("ArchJoint" .. side, V(0.76, 0.62, 0.9), curve, stone, arch, false, A(0, 0, side * -0.28))
		local shoulder = V(side * (1.39 + s * 0.15), chest - 0.07, -0.04)
		c:segment("ShoulderBridge" .. side, curve, shoulder, 0.7, 0.73, edge, body)
		local elbow = shoulder + V(side * 0.24, -0.78, 0.13)
		local hand = elbow + V(side * 0.13, -0.75, 0.42)
		local arm = c:block(
			"ArmBastion" .. side,
			V(0.82, 0.9, 0.95),
			(shoulder + elbow) * 0.5,
			stone,
			body,
			true,
			A(0, 0, side * 0.17)
		)
		c:segment("ArmAxle" .. side, elbow, hand, 0.63, 0.71, shadow, arm)
		c:block("Gauntlet" .. side, V(0.95, 0.75, 1), hand, edge, arm, false, A(-0.18, 0, side * -0.08))
		for digit = 1, 3 do
			c:block(
				"StoneFinger" .. side .. digit,
				V(0.24, 0.42, 0.36),
				hand + V((digit - 2) * 0.28, -0.36, 0.35),
				stone,
				arm,
				false,
				A(0.12, 0, 0)
			)
		end
		c:sphere("ArchGem" .. side, V(0.23, 0.29, 0.12), curve + V(0, 0.04, 0.47), teal, body)
	end
	-- O peito tem um vão real entre dois pilares; o núcleo fica suspenso no arco.
	c:segment("ChestLintel", V(-0.61, chest + 0.32, -0.04), V(0.61, chest + 0.32, -0.04), 0.64, 0.76, edge, body)
	c:segment("CoreHanger", V(0, chest + 0.22, -0.06), V(0, chest - 0.3, -0.06), 0.16, 0.2, shadow, body)
	c:sphere("GeodeHeart", V(0.64, 0.82, 0.54), V(0, chest - 0.62, -0.06), teal, body)
	c:wedge("HeartFacet", V(0.34, 0.45, 0.12), V(0, chest - 0.59, 0.23), c.cream, body)
	local head = c:sphere("Head", V(s == 1 and 1.63 or 1.5, 1.65, 1.37), V(0, chest + 1.13, 0.04), stone, body, true)
	c:block("PharaohBrow", V(1.84, 0.28, 0.72), V(0, chest + 1.61, 0.52), edge, head, false, A(0, 0, 0))
	c:sphere("MaskChin", V(1.05, 0.57, 0.85), V(0, chest + 0.67, 0.58), edge, head)
	c:eyes(head, V(0, chest + 1.22, 0.69), 0.94, s == 1 and 0.255 or 0.22, teal, 0.08)
	c:block("NoseKeystone", V(0.24, 0.41, 0.22), V(0, chest + 1, 0.85), edge, head)
	for _, side in { -1, 1 } do
		c:wedge(
			"CrownPanel" .. side,
			V(0.46, s == 1 and 0.65 or 1.12, 0.87),
			V(side * 0.81, chest + 1.43, -0.03),
			edge,
			head,
			false,
			A(0, 0, side * -0.13)
		)
		if s >= 2 then
			c:block("RoyalStripe" .. side, V(0.12, 0.67, 0.12), V(side * 0.83, chest + 1.44, 0.43), teal, head)
		end
	end
	if s == 3 then
		for _, side in { -1, 1 } do
			local base = V(side * 1.4, chest + 0.18, -0.28)
			local peak = base + V(side * 0.42, 0.93, -0.24)
			local shoulderArch = c:segment("ShoulderArchRise" .. side, base, peak, 0.34, 0.4, edge, body)
			c:segment(
				"ShoulderArchFall" .. side,
				peak,
				base + V(side * 0.85, 0.1, -0.28),
				0.34,
				0.4,
				edge,
				shoulderArch
			)
			c:wedge("CrownSpire" .. side, V(0.29, 0.93, 0.45), V(side * 0.4, chest + 2.06, 0.03), edge, head)
		end
		c:block("CrownCenter", V(0.43, 0.57, 0.48), V(0, chest + 1.94, 0.13), teal, head)
		for n = 1, 3 do
			c:block("BackRune" .. n, V(0.43, 0.18, 0.12), V(0, hips + 0.45 + n * 0.25, -0.82), teal, body)
		end
	end
	return { body = body, head = head }
end

function M.lodinho(c)
	local V, A = c.V, c.A
	local s = c.stage
	local mud = Color3.fromRGB(111, 109, 126)
	local belly = Color3.fromRGB(164, 151, 166)
	local moss = Color3.fromRGB(133, 163, 104)
	local sprout = Color3.fromRGB(182, 197, 133)
	local length = 1.6 + s * 0.42
	local y = 0.68 + s * 0.12
	local body = c:sphere("Body", V(1.9 + s * 0.18, 1.13 + s * 0.13, length), V(0, y, -0.24), mud, c.root, true)
	c:sphere("SlimeSole", V(2.1 + s * 0.15, 0.42, length * 1.07), V(0, 0.26, -0.13), belly, body)
	for side = -1, 1, 2 do
		for n = 1, s == 1 and 2 or 3 do
			local z = -length * 0.55 + n * length * 0.3
			c:sphere("PuddleLobe" .. side .. n, V(0.6, 0.25, 0.8), V(side * (0.88 + s * 0.07), 0.2, z), mud, body)
		end
	end
	local headY = y + (s == 1 and 0.25 or 0.47)
	local head = c:sphere("Head", V(s == 1 and 1.65 or 1.69, 1.41, 1.24), V(0, headY, length * 0.28), mud, body, true)
	c:sphere("SoftMuzzle", V(1.17, 0.59, 0.61), V(0, headY - 0.35, length * 0.28 + 0.49), belly, head)
	cyclops(c, head, V(0, headY + 0.15, length * 0.28 + 0.52), s == 1 and 0.42 or 0.38, moss)
	smile(c, head, headY - 0.43, length * 0.28 + 0.8, 0.22)
	for _, side in { -1, 1 } do
		c:sphere(
			"MuddyCheek" .. side,
			V(0.24, 0.12, 0.1),
			V(side * 0.57, headY - 0.25, length * 0.28 + 0.66),
			belly,
			head
		)
		local antennaBase = V(side * 0.5, headY + 0.46, length * 0.24)
		local tip = antennaBase + V(side * 0.33, 0.4 + s * 0.13, -0.15)
		local stalk = c:segment("MossAntenna" .. side, antennaBase, tip, 0.18, 0.17, moss, head, true)
		c:sphere("DewBud" .. side, V(0.32, 0.39, 0.3), tip, sprout, stalk)
	end
	local tailStart = V(0, y - 0.13, -length * 0.48)
	local tailMid = tailStart + V(0.35, -0.15, -0.65)
	local tailEnd = tailMid + V(0.44, 0.22, -0.43 - s * 0.13)
	local tail = c:segment("Tail1", tailStart, tailMid, 0.65, 0.6, mud, body, true)
	c:segment("TailCurl", tailMid, tailEnd, 0.37, 0.4, mud, tail)
	c:leaf("TailSprout", tailEnd, tailEnd + V(0.28, 0.41, 0.06), 0.52, moss, tail)
	local stones = ({ 3, 5, 7 })[s]
	for n = 1, stones do
		local angle = n * 2.4
		local point = V(math.cos(angle) * 0.59, y + 0.58, math.sin(angle) * length * 0.28 - 0.33)
		c:sphere("MossCushion" .. n, V(0.66, 0.35, 0.7), point, n % 2 == 0 and sprout or moss, body)
		if s >= 2 and n % 2 == 1 then
			local stem = c:segment("MushroomStem" .. n, point, point + V(0, 0.39, 0), 0.12, 0.14, c.cream, body)
			c:sphere(
				"MushroomCap" .. n,
				V(0.48, 0.23, 0.45),
				point + V(0, 0.42, 0),
				belly,
				stem,
				false,
				A(0, 0, n * 0.06)
			)
		end
	end
	return { body = body, head = head }
end

function M.vaporino(c)
	local V, A = c.V, c.A
	local s = c.stage
	local copper = Color3.fromRGB(191, 130, 101)
	local patina = Color3.fromRGB(111, 170, 171)
	local darkCopper = Color3.fromRGB(139, 98, 94)
	local steam = Color3.fromRGB(226, 221, 205)
	local y = 0.88 + s * 0.11
	local body = c:sphere("Body", V(1.75 + s * 0.18, 1.62, 2.12), V(0, y, -0.25), copper, c.root, true)
	c:sphere("BoilerBelly", V(1.52, 1.12, 0.52), V(0, y - 0.13, 0.75), c.cream, body)
	local coilPoints = {
		V(0, y - 0.05, -0.85),
		V(-0.72, y - 0.2, -1.6),
		V(-1.22, y - 0.28, -1.95),
		V(-1.52, y - 0.15, -2.6),
		V(-1.17, y + 0.28, -3.15),
		V(-0.56, y + 0.64, -3.1),
	}
	local count = ({ 2, 4, 5 })[s]
	local parent = body
	for n = 1, count do
		local width = 1.1 - n * 0.14
		local piece = c:segment(
			"Tail" .. n,
			coilPoints[n],
			coilPoints[n + 1],
			width,
			width * 1.05,
			n % 2 == 0 and darkCopper or copper,
			parent,
			n == 1
		)
		local bandPoint = coilPoints[n]:Lerp(coilPoints[n + 1], 0.65)
		c:sphere(
			"PatinaBand" .. n,
			V(width * 1.02, width * 0.94, 0.22),
			bandPoint,
			patina,
			piece,
			false,
			A(0.13, -0.35, 0.1)
		)
		parent = piece
	end
	local last = coilPoints[count + 1]
	c:leaf("SteamTailFin", last, last + V(0.1, 0.53, -0.5), 0.62, patina, parent)
	local neckBase = V(0, y + 0.33, 0.44)
	local neckTop = V(0, y + (s == 1 and 0.98 or 1.4), 0.62)
	c:segment("KettleNeck", neckBase, neckTop, 0.98, 0.92, darkCopper, body)
	local headY = neckTop.Y + 0.35
	local head = c:sphere("Head", V(s == 1 and 1.7 or 1.57, 1.38, 1.4), V(0, headY, 0.7), copper, body, true)
	c:sphere("PorcelainMuzzle", V(1.11, 0.61, 0.83), V(0, headY - 0.24, 1.29), c.cream, head)
	c:eyes(head, V(0, headY + 0.13, 1.26), 0.9, s == 1 and 0.26 or 0.23, patina, -0.08)
	c:sphere("CopperNose", V(0.34, 0.18, 0.19), V(0, headY - 0.17, 1.69), darkCopper, head)
	smile(c, head, headY - 0.39, 1.68, 0.2)
	for _, side in { -1, 1 } do
		local armBase = V(side * 0.72, y + 0.22, 0.13)
		local armEnd = V(side * 1.1, y - 0.12, 0.63)
		local fin = c:segment("SteamFin" .. side, armBase, armEnd, 0.3, 0.4, patina, body, true)
		c:leaf("FinPalm" .. side, armEnd - V(0, 0.08, 0.12), armEnd + V(side * 0.3, 0.16, 0.28), 0.52, patina, fin)
		local lid = c:segment(
			"KettleEar" .. side,
			V(side * 0.56, headY + 0.37, 0.46),
			V(side * 0.91, headY + 0.74, 0.27),
			0.28,
			0.29,
			patina,
			head,
			true
		)
		c:sphere("EarRivet" .. side, V(0.19, 0.19, 0.11), V(side * 0.7, headY + 0.51, 0.53), c.gold, lid)
	end
	local ventTop = V(0, headY + 0.94, 0.49)
	c:sphere("BoilerLid", V(1.32, 0.28, 1.12), V(0, headY + 0.66, 0.62), patina, head)
	c:segment("SteamVent", V(0, headY + 0.68, 0.49), ventTop, 0.37, 0.4, darkCopper, head)
	c:sphere("VentLip", V(0.53, 0.19, 0.52), ventTop, copper, head)
	local plumeCount = ({ 2, 3, 5 })[s]
	for n = 1, plumeCount do
		local swirl = V(math.sin(n * 1.4) * (0.14 + n * 0.03), n * 0.27, math.cos(n * 1.1) * 0.1)
		local puff = c:sphere(
			"SteamPuff" .. n,
			V(0.32 + n * 0.06, 0.34 + n * 0.055, 0.32 + n * 0.06),
			ventTop + swirl,
			steam,
			head
		)
		puff.Transparency = 0.16 + n * 0.035
	end
	if s >= 2 then
		for _, side in { -1, 1 } do
			local start = V(side * 0.88, y + 0.48, -0.3)
			local corner = start + V(side * 0.45, 0.42, -0.18)
			local loop = c:segment("BoilerHandleLower" .. side, start, corner, 0.18, 0.2, darkCopper, body)
			c:segment(
				"BoilerHandleUpper" .. side,
				corner,
				start + V(0.05 * side, 0.76, -0.25),
				0.18,
				0.2,
				darkCopper,
				loop
			)
		end
	end
	if s == 3 then
		local vent = V(0.58, y + 0.65, -0.71)
		c:segment("BackVent", vent, vent + V(0.12, 0.7, -0.2), 0.32, 0.35, copper, body)
		c:sphere("BackVentLip", V(0.48, 0.19, 0.45), vent + V(0.12, 0.71, -0.2), patina, body)
		for n = 1, 3 do
			local puff = c:sphere(
				"BackSteam" .. n,
				V(0.26 + n * 0.1, 0.3 + n * 0.09, 0.3 + n * 0.09),
				vent + V(0.11 + n * 0.06, 0.65 + n * 0.24, -0.2 - n * 0.13),
				steam,
				body
			)
			puff.Transparency = 0.18 + n * 0.04
		end
	end
	return { body = body, head = head }
end

return M
