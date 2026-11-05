--!nonstrict
-- Anatomias autorais: volumes contínuos, focinhos construídos e apêndices com raízes físicas.
-- +Z é a frente. O contexto aplica escala, rig e propriedades de colisão.
local V = Vector3.new
local A = CFrame.Angles
local rgb = Color3.fromRGB
local S = {}

local function paw(c, name, pos, size, color, parent, claws, clawColor)
	local foot = c:sphere(name, size, pos, color, parent, false)
	if claws then
		for toe = -1, 1 do
			c:sphere(
				name .. "Toe" .. toe,
				V(size.X * 0.22, size.Y * 0.38, size.Z * 0.38),
				pos + V(toe * size.X * 0.24, -size.Y * 0.08, size.Z * 0.4),
				clawColor,
				foot,
				false
			)
		end
	end
	return foot
end

local function smile(c, parent, center, width, color)
	c:segment("SmileL", center + V(-width, 0.06, 0), center + V(0, -0.02, 0.035), 0.055, 0.045, color, parent)
	c:segment("SmileR", center + V(0, -0.02, 0.035), center + V(width, 0.06, 0), 0.055, 0.045, color, parent)
end

-- Cinzelo: salamandra barriguda cuja carapaça é um forno de alvenaria.
function S.cinzelo(c)
	local s = c.stage
	local young = s == 1
	local plum, copper, amber = rgb(72, 47, 70), rgb(174, 95, 64), rgb(249, 177, 75)
	local skin, cream, dark = rgb(111, 73, 88), c.cream, c.dark
	local length = young and 2.6 or s == 2 and 3.3 or 3.8
	local body = c:sphere("Body", V(young and 2.6 or 3.3, 1.45, length), V(0, 1.02, -0.15), skin, c.root, true)
	c:sphere("WarmBelly", V(young and 2.2 or 2.9, 0.72, length * 0.86), V(0, 0.75, 0.04), cream, body)
	local head = c:sphere("Head", V(young and 2.15 or 2.6, 1.3, 1.8), V(0, 1.18, length * 0.44), skin, body, true)
	c:sphere("CheekL", V(0.8, 0.75, 1.02), V(-0.83, 0.96, length * 0.44 + 0.34), copper, head)
	c:sphere("CheekR", V(0.8, 0.75, 1.02), V(0.83, 0.96, length * 0.44 + 0.34), copper, head)
	c:sphere("LowerJaw", V(young and 1.9 or 2.45, 0.55, 1.45), V(0, 0.77, length * 0.44 + 0.39), cream, head)
	c:sphere("Snout", V(young and 2 or 2.5, 0.65, 1.15), V(0, 1.03, length * 0.44 + 0.69), skin, head)
	local front = length * 0.44 + 1.12
	c:eyes(head, V(0, 1.48, front - 0.27), young and 1.14 or 1.5, young and 0.29 or 0.27, amber, -0.12)
	for _, side in { -1, 1 } do
		c:sphere("Nostril" .. side, V(0.12, 0.08, 0.06), V(side * 0.47, 1.15, front + 0.04), dark, head)
		for _, back in { -1, 1 } do
			local start = V(side * (young and 1.03 or 1.38), 0.85, back * length * 0.24)
			local endPos = start + V(side * 0.42, -0.37, 0.18)
			local leg = c:segment("Leg" .. side .. "_" .. back, start, endPos, 0.55, 0.58, skin, body, true)
			paw(
				c,
				"Paw" .. side .. "_" .. back,
				endPos + V(0, -0.1, 0.13),
				V(0.78, 0.38, 0.83),
				copper,
				leg,
				s == 3,
				cream
			)
		end
	end
	smile(c, head, V(0, 0.92, front + 0.08), young and 0.58 or 0.83, dark)
	local tail = {
		V(0, 0.93, -length * 0.4),
		V(0.35, 0.79, -length * 0.65 - 0.3),
		V(0.87, 0.72, -length * 0.72 - 0.8),
		V(1.35, 0.94, -length * 0.7 - 1.18),
	}
	for i = 1, young and 2 or 3 do
		c:segment("Tail" .. i, tail[i], tail[i + 1], 0.92 - i * 0.19, 0.75 - i * 0.12, skin, body, true)
	end
	local shell = c:sphere(
		"KilnCarapace",
		V(young and 2.2 or 2.9, young and 1.55 or 2.15, length * 0.83),
		V(0, 1.85, -0.28),
		plum,
		body
	)
	local windowY = young and 2.05 or 2.35
	local windowZ = length * 0.34 - 0.08
	c:sphere("KilnArch", V(1.25, 1.44, 0.2), V(0, windowY, windowZ), copper, shell)
	c:sphere("KilnGlow", V(0.93, 1.1, 0.14), V(0, windowY, windowZ + 0.11), amber, shell)
	for bar = -1, 1 do
		c:segment(
			"WindowBar" .. bar,
			V(bar * 0.27, windowY - 0.4, windowZ + 0.2),
			V(bar * 0.27, windowY + 0.39, windowZ + 0.2),
			0.07,
			0.065,
			plum,
			shell
		)
	end
	if not young then
		for _, side in { -1, 1 } do
			c:sphere("SideKilnArch" .. side, V(0.18, 0.83, 0.86), V(side * 1.3, 2.03, -0.37), copper, shell)
			c:sphere("SideKilnGlow" .. side, V(0.15, 0.54, 0.56), V(side * 1.39, 2.06, -0.34), amber, shell)
			for brick = 1, 3 do
				c:block(
					"Brick" .. side .. "_" .. brick,
					V(0.23, 0.24, 0.62),
					V(side * (1.31 - brick * 0.1), 1.95 + brick * 0.3, -0.5 + (brick % 2) * 0.2),
					copper,
					shell,
					false,
					A(0, 0, side * 0.15)
				)
			end
		end
	end
	local chimneyHeight = young and 0.65 or s == 2 and 1.04 or 1.5
	local chimneyBase = young and 2.3 or 2.7
	c:block("Chimney", V(0.68, chimneyHeight, 0.72), V(0.2, chimneyBase + chimneyHeight * 0.5, -0.85), plum, shell)
	c:block("ChimneyLip", V(0.95, 0.22, 0.97), V(0.2, chimneyBase + chimneyHeight, -0.85), copper, shell)
	c:block("ChimneyOpening", V(0.61, 0.08, 0.63), V(0.2, chimneyBase + chimneyHeight + 0.13, -0.85), dark, shell)
	if s == 3 then
		for puff = 1, 3 do
			c:sphere(
				"SoftSmoke" .. puff,
				V(0.35 + puff * 0.13, 0.34 + puff * 0.1, 0.36 + puff * 0.12),
				V(0.18 + puff * 0.14, chimneyBase + chimneyHeight + 0.17 + puff * 0.31, -0.85 - puff * 0.12),
				cream,
				shell
			)
		end
		c:leaf("TailEmber", tail[4] - V(0.03, 0.05, 0), tail[4] + V(0.38, 0.47, -0.11), 0.62, amber, body)
	end
	return { body = body, head = head }
end

-- Magmarau: épaulas de javali, casco fendido, presas curvas e crina de brasa.
function S.magmarau(c)
	local s, young = c.stage, c.stage == 1
	local bodyColor, mane, glow = rgb(137, 67, 64), rgb(84, 47, 64), rgb(237, 135, 66)
	local cream, dark = c.cream, c.dark
	local body = c:sphere(
		"Body",
		V(young and 2.4 or 3.3, young and 1.9 or 2.55, young and 2.9 or 4.05),
		V(0, young and 1.5 or 1.96, -0.18),
		bodyColor,
		c.root,
		true
	)
	c:sphere(
		"Haunch",
		V(young and 2.1 or 2.6, young and 1.65 or 2.15, 2.25),
		V(0, young and 1.43 or 1.73, -1.37),
		bodyColor,
		body
	)
	c:sphere(
		"ShoulderMantle",
		V(young and 2.5 or 3.55, young and 1.7 or 2.4, 1.55),
		V(0, young and 1.64 or 2.26, 0.73),
		mane,
		body
	)
	local hy = young and 1.65 or 2.15
	local hz = young and 1.38 or 2.02
	local head =
		c:sphere("Head", V(young and 1.9 or 2.37, young and 1.65 or 1.94, 1.8), V(0, hy, hz), bodyColor, body, true)
	c:sphere("LowerJaw", V(1.72, 0.64, 1.25), V(0, hy - 0.5, hz + 0.54), cream, head)
	c:sphere("Muzzle", V(young and 1.58 or 2, 0.97, 1.18), V(0, hy - 0.2, hz + 0.8), glow, head)
	c:sphere("SnoutDisc", V(1.43, 0.72, 0.25), V(0, hy - 0.13, hz + 1.36), bodyColor, head)
	for _, side in { -1, 1 } do
		c:sphere("Nostril" .. side, V(0.2, 0.2, 0.065), V(side * 0.33, hy - 0.1, hz + 1.49), dark, head)
		local earRoot = V(side * 0.78, hy + 0.54, hz - 0.24)
		c:leaf("Ear" .. side, earRoot, earRoot + V(side * 0.62, young and 0.65 or 0.92, -0.32), 0.66, mane, head, true)
		c:leaf(
			"EarInner" .. side,
			earRoot + V(0, 0.11, 0.08),
			earRoot + V(side * 0.4, young and 0.58 or 0.79, -0.15),
			0.38,
			glow,
			head
		)
		local tuskBase = V(side * 0.78, hy - 0.34, hz + 0.9)
		local tuskMid = tuskBase + V(side * 0.3, 0.14, 0.34)
		local tuskEnd = tuskMid + V(side * 0.13, young and 0.26 or s == 2 and 0.52 or 0.85, -0.08)
		c:segment("TuskRoot" .. side, tuskBase, tuskMid, young and 0.2 or 0.31, 0.28, cream, head)
		c:segment("TuskTip" .. side, tuskMid, tuskEnd, young and 0.13 or 0.21, 0.18, cream, head)
		for _, back in { -1, 1 } do
			local hip = V(side * (young and 0.88 or 1.14), young and 1.15 or 1.53, back * (young and 0.83 or 1.24))
			local knee = hip + V(side * 0.12, young and -0.57 or -0.78, back * 0.1)
			local ankle = knee + V(0, young and -0.18 or -0.39, -0.08)
			local leg =
				c:segment("Leg" .. side .. "_" .. back, hip, knee, young and 0.64 or 0.8, 0.73, bodyColor, body, true)
			if not young then
				c:segment("Shin" .. side .. "_" .. back, knee, ankle, 0.49, 0.51, glow, leg)
			end
			for cleft = -1, 1, 2 do
				c:block(
					"ClovenHoof" .. side .. "_" .. back .. "_" .. cleft,
					V(0.29, 0.35, 0.65),
					ankle + V(cleft * 0.17, -0.1, 0.1),
					mane,
					leg
				)
			end
		end
	end
	c:eyes(head, V(0, hy + 0.32, hz + 0.71), young and 1.05 or 1.34, young and 0.28 or 0.25, glow, 0.2)
	smile(c, head, V(0, hy - 0.43, hz + 1.25), 0.52, dark)
	for tuft = 1, young and 2 or s == 2 and 4 or 6 do
		local z = 0.88 - tuft * 0.53
		c:wedge(
			"EmberMane" .. tuft,
			V(0.82 - tuft * 0.045, young and 0.4 or 0.7 + (tuft % 2) * 0.25, 0.96),
			V(0, (young and 2.38 or 3.05) - tuft * 0.055, z),
			tuft % 2 == 0 and glow or mane,
			body,
			false,
			A(-0.1, math.pi, 0)
		)
	end
	if not young then
		for _, side in { -1, 1 } do
			for plate = 1, s == 3 and 3 or 2 do
				c:wedge(
					"ShoulderPlate" .. side .. "_" .. plate,
					V(0.32, 0.8, 0.83),
					V(side * 1.53, 2.25 + plate * 0.17, 1.13 - plate * 0.43),
					glow,
					body,
					false,
					A(0.15, side * 0.24, side * 0.25)
				)
			end
		end
	end
	local tailBase = V(0, young and 1.7 or 2.03, young and -1.47 or -2.03)
	c:segment("Tail1", tailBase, tailBase + V(0.42, 0.32, -0.62), 0.3, 0.29, bodyColor, body, true)
	c:segment("Tail2", tailBase + V(0.42, 0.32, -0.62), tailBase + V(0.65, 0.75, -0.45), 0.21, 0.2, mane, body, true)
	if s == 3 then
		c:leaf("TailFlame", tailBase + V(0.65, 0.64, -0.45), tailBase + V(0.9, 1.27, -0.65), 0.57, glow, body)
	end
	return { body = body, head = head }
end

-- Folhuco: raposa de orelhas folhosas, peitoral fofo e grande cauda que faz um S.
function S.folhuco(c)
	local s, young = c.stage, c.stage == 1
	local orange, rust, green = rgb(218, 131, 66), rgb(169, 82, 62), rgb(91, 147, 82)
	local lightGreen, cream, dark = rgb(159, 190, 97), c.cream, c.dark
	local by = young and 1.1 or 1.65
	local length = young and 2.3 or 3.2
	local body =
		c:sphere("Body", V(young and 1.8 or 2.1, young and 1.55 or 1.7, length), V(0, by, -0.3), orange, c.root, true)
	c:sphere("Haunch", V(young and 1.7 or 1.95, 1.65, 1.7), V(0, by + 0.04, -1.1), rust, body)
	local chestY = by + (young and 0.2 or 0.45)
	c:sphere("ChestRuff", V(young and 1.4 or 1.7, young and 1.55 or 2.08, 1.32), V(0, chestY, 0.73), cream, body)
	local hy = young and 2.05 or s == 2 and 2.7 or 3.03
	local head =
		c:sphere("Head", V(young and 1.92 or 2.04, young and 1.62 or 1.52, 1.62), V(0, hy, 1.05), orange, body, true)
	for _, side in { -1, 1 } do
		c:sphere("MuzzlePad" .. side, V(0.91, 0.65, 0.92), V(side * 0.36, hy - 0.34, 1.72), cream, head)
		c:leaf("CheekTuft" .. side, V(side * 0.67, hy - 0.25, 1.28), V(side * 1.14, hy - 0.03, 0.96), 0.61, cream, head)
		local earRoot = V(side * 0.64, hy + 0.48, 0.88)
		local earTip = earRoot + V(side * (young and 0.36 or 0.57), young and 0.76 or s == 2 and 1.0 or 1.24, -0.16)
		local direction = (earTip - earRoot).Unit
		local normal = (V(0, 0, 1) - direction * direction:Dot(V(0, 0, 1))).Unit
		local right = direction:Cross(normal).Unit
		local orientation = CFrame.fromMatrix(V(0, 0, 0), right, direction, normal)
		local height, width = (earTip - earRoot).Magnitude, young and 0.9 or 1.14
		local ear = c:sphere(
			"LeafEar" .. side,
			V(width, 0.65, 0.33),
			earRoot + direction * 0.22,
			green,
			head,
			true,
			orientation
		)
		-- Duas metades triangulares formam uma ponta real, em vez de outra orelha oval de coelho.
		for half = -1, 1, 2 do
			c:wedge(
				"LeafEarPoint" .. side .. "_" .. half,
				V(0.25, height - 0.25, width * 0.5),
				earRoot + direction * (0.25 + (height - 0.25) * 0.5) + right * half * width * 0.25,
				green,
				ear,
				false,
				orientation * A(0, -half * math.pi / 2, 0)
			)
		end
		c:leaf(
			"LeafEarInner" .. side,
			earRoot + direction * 0.16 + normal * 0.17,
			earTip - direction * 0.2 + normal * 0.17,
			young and 0.42 or 0.53,
			lightGreen,
			ear
		)
		c:segment(
			"EarVein" .. side,
			earRoot + direction * 0.17 + normal * 0.23,
			earTip - direction * 0.24 + normal * 0.23,
			0.04,
			0.035,
			cream,
			ear
		)
		for _, back in { -1, 1 } do
			local hip = V(side * 0.61, by - 0.34, back * (young and 0.72 or 1.05))
			local knee = hip + V(side * 0.05, young and -0.39 or -0.65, back == -1 and -0.1 or 0.08)
			local footPos = knee + V(0, young and -0.12 or -0.35, 0.14)
			local leg =
				c:segment("Leg" .. side .. "_" .. back, hip, knee, young and 0.36 or 0.46, 0.49, rust, body, true)
			if not young then
				c:segment("LowerLeg" .. side .. "_" .. back, knee, footPos, 0.31, 0.33, cream, leg)
			end
			paw(c, "FoxPaw" .. side .. "_" .. back, footPos, V(0.49, 0.3, 0.68), cream, leg, s == 3, rust)
		end
	end
	c:sphere("Nose", V(0.42, 0.29, 0.3), V(0, hy - 0.2, 2.23), dark, head)
	c:eyes(head, V(0, hy + 0.17, 1.76), young and 1.1 or 1.19, young and 0.29 or 0.255, green, -0.12)
	smile(c, head, V(0, hy - 0.49, 2.1), 0.31, dark)
	for tuft = -1, 1 do
		local front = tuft == 0 and 0.18 or 0
		local drop = young and 0.43 or 0.66
		local from = V(tuft * 0.45, chestY - 0.12, 1.12 + front)
		local middle = V(tuft * 0.46, chestY - drop * 0.58, 1.12 + front)
		local tip = V(tuft * 0.42, chestY - drop, 1.06 + front)
		c:segment("RuffCurveRoot" .. tuft, from, middle, young and 0.35 or 0.45, 0.32, cream, body)
		c:segment("RuffCurveTip" .. tuft, middle, tip, young and 0.26 or 0.33, 0.28, cream, body)
	end
	local tail = young
			and {
				V(0, 1.14, -1.25),
				V(0.53, 1.58, -2.05),
				V(0.97, 2.22, -2.29),
				V(1.09, 2.84, -2.05),
			}
		or {
			V(0, 1.68, -1.63),
			V(0.56, 2.16, -2.52),
			V(1.12, 3.05, -3.0),
			V(1.29, 4.08, -2.93),
		}
	for i = 1, 3 do
		c:segment(
			"Tail" .. i,
			tail[i],
			tail[i + 1],
			young and 0.88 or 1.3 - i * 0.07,
			young and 0.91 or 1.46 - i * 0.08,
			i == 3 and cream or orange,
			body,
			true
		)
	end
	c:leaf(
		"TailBrushTip",
		tail[4] - V(0.03, 0.42, 0.03),
		tail[4] + V(0.07, young and 0.4 or 0.69, 0.18),
		young and 0.61 or 0.77,
		cream,
		body
	)
	if not young then
		for leaf = 1, s == 3 and 5 or 3 do
			local base = tail[1]:Lerp(tail[3], leaf / 7)
			local side = leaf % 2 == 0 and -1 or 1
			c:leaf(
				"TailLeaf" .. leaf,
				base + V(0, 0, 0.48),
				base + V(side * 0.6, 0.53, 0.57),
				0.55,
				leaf % 2 == 0 and lightGreen or green,
				body
			)
		end
		local flowerCenter = V(-0.73, hy + 0.61, 1.1)
		for petal = 1, s == 3 and 5 or 3 do
			local angle = petal * math.pi * 2 / (s == 3 and 5 or 3)
			c:sphere(
				"EarFlower" .. petal,
				V(0.26, 0.39, 0.13),
				flowerCenter + V(math.sin(angle) * 0.21, math.cos(angle) * 0.21, 0),
				cream,
				head,
				false,
				A(0, 0, -angle)
			)
		end
		c:sphere("EarFlowerHeart", V(0.24, 0.24, 0.15), flowerCenter + V(0, 0, 0.08), c.gold, head)
	end
	return { body = body, head = head }
end

-- Esfingeolito: felino guardião sentado, com patas monumentais e toucado de lápis-lazúli.
function S.esfingeolito(c)
	local s, young = c.stage, c.stage == 1
	local sand, ochre, lapis = rgb(220, 184, 121), rgb(174, 133, 88), rgb(60, 118, 139)
	local turquoise, cream, dark = rgb(112, 178, 171), c.cream, c.dark
	local by = young and 1.16 or 1.61
	local body = c:sphere(
		"Body",
		V(young and 1.95 or 2.7, young and 1.9 or 2.3, young and 2.45 or 3.9),
		V(0, by, -0.55),
		ochre,
		c.root,
		true
	)
	local chestY = young and 1.55 or s == 2 and 2.1 or 2.42
	c:sphere(
		"UprightChest",
		V(young and 1.65 or 2.18, young and 2 or s == 2 and 2.7 or 3.4, 1.63),
		V(0, chestY, 0.83),
		sand,
		body
	)
	local hy = young and 2.51 or s == 2 and 3.47 or 4.18
	local head = c:sphere("Head", V(young and 1.87 or 2.12, 1.78, 1.72), V(0, hy, 1.1), sand, body, true)
	for _, side in { -1, 1 } do
		c:sphere("WhiskerPad" .. side, V(0.79, 0.55, 0.72), V(side * 0.31, hy - 0.37, 1.8), cream, head)
		local ear = V(side * 0.76, hy + 0.57, 0.98)
		c:leaf("CatEar" .. side, ear, ear + V(side * 0.11, young and 0.69 or 0.86, -0.1), 0.69, ochre, head, true)
		c:leaf("CatEarInner" .. side, ear + V(0, 0.12, 0.09), ear + V(side * 0.07, 0.61, -0.01), 0.36, lapis, head)
		local hip = V(side * (young and 0.77 or 1.02), by, young and -1.08 or -1.5)
		c:sphere(
			"SeatedHaunch" .. side,
			V(young and 1.05 or 1.42, young and 1.38 or 1.87, young and 1.32 or 1.83),
			hip,
			sand,
			body
		)
		local foreTop = V(side * (young and 0.62 or 0.77), young and 1.79 or 2.47, 1.0)
		local foreBottom = V(side * (young and 0.65 or 0.84), 0.43, 1.44)
		local foreleg =
			c:segment("LegFore" .. side, foreTop, foreBottom, young and 0.52 or 0.63, 0.67, sand, body, true)
		paw(
			c,
			"ForePaw" .. side,
			foreBottom + V(0, -0.09, 0.21),
			V(young and 0.79 or 1.01, 0.51, young and 1.1 or 1.43),
			sand,
			foreleg,
			s >= 2,
			cream
		)
		paw(
			c,
			"RearPaw" .. side,
			V(side * (young and 0.86 or 1.13), 0.29, young and -0.61 or -0.66),
			V(young and 0.79 or 1.04, 0.45, young and 1.2 or 1.58),
			ochre,
			body,
			s == 3,
			cream
		)
		if not young then
			c:leaf(
				"NemesFlap" .. side,
				V(side * 0.87, hy + 0.46, 0.7),
				V(side * 1.4, hy - 1.04, 0.73),
				0.8,
				lapis,
				head
			)
			for stripe = 1, s == 3 and 4 or 3 do
				c:block(
					"HeaddressStripe" .. side .. "_" .. stripe,
					V(0.52, 0.11, 0.17),
					V(side * (1.04 + stripe * 0.057), hy + 0.18 - stripe * 0.26, 1.0),
					sand,
					head,
					false,
					A(0, 0, side * -0.15)
				)
			end
		end
	end
	c:eyes(head, V(0, hy + 0.11, 1.83), young and 1.04 or 1.16, young and 0.29 or 0.255, turquoise, 0.04)
	c:wedge("Nose", V(0.31, 0.23, 0.25), V(0, hy - 0.2, 2.12), dark, head, false, A(0, 0, math.pi))
	smile(c, head, V(0, hy - 0.47, 2.08), 0.31, dark)
	c:sphere("CrownCap", V(young and 1.97 or 2.26, 0.68, 1.77), V(0, hy + 0.64, 0.95), lapis, head)
	c:leaf(
		"CrownCobra",
		V(0, hy + 0.48, 1.86),
		V(0, hy + (young and 1.1 or 1.48), 1.8),
		young and 0.39 or 0.56,
		c.gold,
		head
	)
	c:sphere("BrowGem", V(0.34, 0.4, 0.18), V(0, hy + 0.41, 1.98), turquoise, head)
	for collar = 1, young and 1 or 3 do
		c:sphere(
			"NeckCollar" .. collar,
			V(young and 1.79 or 2.32, 0.18, 1.63),
			V(0, hy - 0.74 - collar * 0.19, 0.93),
			collar % 2 == 0 and c.gold or lapis,
			body
		)
	end
	local base = V(0.25, by - 0.12, young and -1.57 or -2.37)
	local points = {
		base,
		base + V(1.16, -0.15, -0.3),
		base + V(1.91, 0.64, 0.04),
		base + V(1.9, young and 1.4 or 2.33, 0.5),
		base + V(1.45, young and 1.63 or 2.62, 0.72),
	}
	for segment = 1, young and 3 or 4 do
		c:segment(
			"Tail" .. segment,
			points[segment],
			points[segment + 1],
			young and 0.29 or 0.37,
			0.35,
			ochre,
			body,
			true
		)
	end
	local tip = points[young and 4 or 5]
	c:leaf("TailLotus", tip - V(0, 0.1, 0), tip + V(0.05, 0.61, 0.1), 0.61, lapis, body)
	if s == 3 then
		for rune = 1, 3 do
			c:wedge(
				"HaunchRune" .. rune,
				V(0.2, 0.43, 0.23),
				V(1.73, 1.31 + rune * 0.23, -1.18),
				turquoise,
				body,
				false,
				A(0, 0, rune % 2 == 0 and 0.45 or -0.45)
			)
		end
	end
	return { body = body, head = head }
end

-- Magmaterra: tartaruga maciça, placas em degraus e caldeira vazada no dorso.
function S.magmaterra(c)
	local s, young = c.stage, c.stage == 1
	local basalt, clay, lava = rgb(78, 60, 75), rgb(154, 99, 76), rgb(241, 150, 69)
	local skin, cream, dark = rgb(121, 95, 79), c.cream, c.dark
	local width, length = young and 2.55 or 3.65, young and 2.7 or 4.1
	local body = c:sphere("Body", V(width, 1.62, length), V(0, 1.04, -0.16), skin, c.root, true)
	c:sphere("Plastron", V(width * 0.92, 0.55, length * 0.91), V(0, 0.67, -0.1), cream, body)
	local shell = c:sphere(
		"BasaltShell",
		V(width + 0.56, young and 1.77 or 2.67, length + 0.32),
		V(0, young and 1.75 or 2.04, -0.28),
		basalt,
		body
	)
	for _, side in { -1, 1 } do
		for _, back in { -1, 1 } do
			local hip = V(side * width * 0.39, 0.98, back * length * 0.31)
			local endPos = hip + V(side * 0.43, -0.47, back * 0.11)
			local leg = c:segment(
				"Leg" .. side .. "_" .. back,
				hip,
				endPos,
				young and 0.65 or 0.86,
				young and 0.66 or 0.95,
				skin,
				body,
				true
			)
			paw(
				c,
				"TortoiseFoot" .. side .. "_" .. back,
				endPos + V(0, -0.08, 0.13),
				V(young and 0.76 or 1.01, 0.51, young and 0.83 or 1.09),
				clay,
				leg,
				s >= 2,
				cream
			)
		end
	end
	local hz = length * 0.5 + 0.25
	local head = c:sphere("Head", V(young and 1.59 or 1.89, 1.35, 1.68), V(0, 1.16, hz), skin, body, true)
	c:sphere("LowerJaw", V(young and 1.49 or 1.79, 0.51, 1.22), V(0, 0.85, hz + 0.4), cream, head)
	c:wedge("TurtleBeak", V(0.8, 0.56, 0.65), V(0, 1.03, hz + 0.88), clay, head, false, A(0.12, 0, 0))
	c:eyes(head, V(0, 1.44, hz + 0.6), young and 1.02 or 1.22, young and 0.275 or 0.24, lava, 0.1)
	for _, side in { -1, 1 } do
		c:sphere("Nostril" .. side, V(0.1, 0.08, 0.055), V(side * 0.22, 1.13, hz + 1.15), dark, head)
		c:segment(
			"JawCorner" .. side,
			V(side * 0.36, 0.93, hz + 1.05),
			V(side * 0.69, 1.0, hz + 0.7),
			0.05,
			0.045,
			dark,
			head
		)
	end
	local plates = young and 5 or s == 2 and 8 or 10
	for plate = 1, plates do
		local angle = plate * math.pi * 2 / plates
		local x, z = math.cos(angle) * width * 0.4, math.sin(angle) * length * 0.38
		c:wedge(
			"Scute" .. plate,
			V(young and 0.7 or 1, young and 0.55 or 0.83, young and 0.83 or 1.16),
			V(x, young and 1.95 or 2.4, z - 0.3),
			plate % 2 == 0 and clay or basalt,
			shell,
			false,
			A(0.18, -angle + math.pi / 2, math.cos(angle) * 0.13)
		)
	end
	if not young then
		for seam = 1, 3 do
			local from = V((seam - 2) * 0.48, 3.43, 0.35)
			local middle = from + V((seam - 2) * 0.18, -0.3, 0.9)
			local tip = middle + V((seam - 2) * 0.16, -0.52, 0.55)
			c:segment("LavaVeinA" .. seam, from, middle, 0.095, 0.085, lava, shell)
			c:segment("LavaVeinB" .. seam, middle, tip, 0.08, 0.07, lava, shell)
		end
	end
	local volcanoY = young and 2.8 or s == 2 and 3.55 or 3.94
	local radius = young and 0.52 or s == 2 and 0.73 or 0.96
	if s == 3 then
		for tier = 1, 2 do
			c:sphere(
				"VolcanoTerrace" .. tier,
				V(2.95 - tier * 0.57, 0.58, 2.67 - tier * 0.49),
				V(0, 2.74 + tier * 0.36, -0.45),
				tier == 1 and clay or basalt,
				shell
			)
		end
	end
	c:sphere("CraterInterior", V(radius * 1.62, 0.11, radius * 1.62), V(0, volcanoY - 0.1, -0.42), lava, shell)
	for rim = 1, young and 6 or 8 do
		local angle = rim * math.pi * 2 / (young and 6 or 8)
		c:wedge(
			"CraterRim" .. rim,
			V(radius * 0.73, young and 0.37 or 0.52, radius * 0.56),
			V(math.cos(angle) * radius, volcanoY, -0.42 + math.sin(angle) * radius),
			rim % 2 == 0 and basalt or clay,
			shell,
			false,
			A(0, -angle + math.pi / 2, 0)
		)
	end
	local tail = V(0, 0.92, -length * 0.5)
	c:segment("Tail1", tail, tail + V(0.13, -0.1, -0.8), 0.67, 0.63, skin, body, true)
	c:segment("Tail2", tail + V(0.13, -0.1, -0.8), tail + V(0.35, 0.16, -1.43), 0.39, 0.4, clay, body, true)
	if s == 3 then
		c:wedge("TailHammer", V(1.13, 0.73, 0.86), tail + V(0.39, 0.18, -1.48), basalt, body, false, A(0, 0.24, 0.1))
	end
	return { body = body, head = head }
end

-- Nevoamusgo: cervídeo de bosque, longo pescoço, galhadas de líquen e manto vegetal.
function S.nevoamusgo(c)
	local s, young = c.stage, c.stage == 1
	local bark, moss, light = rgb(85, 107, 86), rgb(124, 155, 100), rgb(178, 195, 132)
	local mist, cream, dark = rgb(173, 157, 189), c.cream, c.dark
	local by = young and 1.42 or s == 2 and 2.03 or 2.4
	local body = c:sphere(
		"Body",
		V(young and 1.96 or 2.62, young and 1.75 or 2, young and 2.54 or 3.47),
		V(0, by, -0.37),
		bark,
		c.root,
		true
	)
	local hy = young and 2.43 or s == 2 and 3.56 or 4.18
	c:segment("WoodlandNeck", V(0, by + 0.28, 0.69), V(0, hy - 0.32, 1.14), young and 1.04 or 1.31, 1.24, cream, body)
	local head =
		c:sphere("Head", V(young and 1.65 or 1.85, young and 1.78 or 2.05, 1.63), V(0, hy, 1.1), moss, body, true)
	c:sphere("Muzzle", V(young and 1.2 or 1.29, 0.82, 1.09), V(0, hy - 0.57, 1.73), cream, head)
	c:sphere("Nose", V(0.51, 0.28, 0.22), V(0, hy - 0.43, 2.26), bark, head)
	c:eyes(head, V(0, hy + 0.15, 1.85), young and 0.99 or 1.12, young and 0.29 or 0.25, mist, -0.12)
	smile(c, head, V(0, hy - 0.77, 2.14), 0.32, dark)
	for _, side in { -1, 1 } do
		c:leaf(
			"Ear" .. side,
			V(side * 0.68, hy + 0.39, 0.96),
			V(side * (young and 1.32 or 1.52), hy + 0.72, 0.62),
			0.69,
			bark,
			head,
			true
		)
		c:leaf(
			"EarInner" .. side,
			V(side * 0.77, hy + 0.42, 1.03),
			V(side * (young and 1.19 or 1.36), hy + 0.66, 0.74),
			0.39,
			light,
			head
		)
		for _, back in { -1, 1 } do
			local hip = V(side * (young and 0.66 or 0.89), by - 0.23, back * (young and 0.81 or 1.13))
			local knee = hip + V(side * 0.05, young and -0.67 or -1.02, back == -1 and -0.16 or 0.14)
			local ankle = knee + V(side * 0.03, young and -0.29 or -0.73, back == -1 and 0.19 or -0.09)
			local leg = c:segment(
				"Leg" .. side .. "_" .. back,
				hip,
				knee,
				young and 0.36 or 0.45,
				young and 0.4 or 0.49,
				bark,
				body,
				true
			)
			c:segment("LowerLeg" .. side .. "_" .. back, knee, ankle, young and 0.26 or 0.31, 0.33, cream, leg)
			c:sphere(
				"Hoof" .. side .. "_" .. back,
				V(young and 0.42 or 0.51, 0.35, 0.62),
				ankle + V(0, -0.08, 0.12),
				bark,
				leg
			)
		end
		local root = V(side * 0.58, hy + 0.75, 0.88)
		local main = root + V(side * (young and 0.14 or 0.4), young and 0.57 or s == 2 and 1.22 or 1.72, -0.18)
		local antler = c:segment("AntlerRoot" .. side, root, main, young and 0.2 or 0.26, 0.25, bark, head)
		if young then
			c:sphere("AntlerBud" .. side, V(0.43, 0.47, 0.43), main, light, antler)
		else
			for branch = 1, s == 3 and 3 or 2 do
				local base = root:Lerp(main, 0.3 + branch * 0.16)
				local tip = base
					+ V(side * (0.49 + branch * 0.12), 0.51 + branch * 0.05, branch % 2 == 0 and -0.44 or 0.1)
				c:segment("AntlerBranch" .. side .. "_" .. branch, base, tip, 0.18, 0.16, bark, antler)
				c:leaf(
					"LichenLeaf" .. side .. "_" .. branch,
					tip - V(0, 0.08, 0),
					tip + V(side * 0.16, 0.34, 0.07),
					0.46,
					branch % 2 == 0 and light or moss,
					antler
				)
				if s == 3 and branch % 2 == 1 then
					c:segment(
						"HangingLichen" .. side .. "_" .. branch,
						tip + V(0, -0.06, 0),
						tip + V(side * 0.13, -0.62, 0.03),
						0.12,
						0.1,
						mist,
						antler
					)
				end
			end
			c:sphere("AntlerMossTip" .. side, V(0.65, 0.47, 0.55), main, light, antler)
		end
	end
	local mantle = c:sphere(
		"MossMantle",
		V(young and 2.1 or 2.97, young and 1.04 or 1.34, young and 2.27 or 3.16),
		V(0, by + 0.65, -0.39),
		moss,
		body
	)
	for tuft = 1, young and 3 or s == 2 and 5 or 7 do
		local angle = tuft * math.pi * 2 / (young and 3 or s == 2 and 5 or 7)
		local start =
			V(math.cos(angle) * (young and 0.79 or 1.13), by + 0.66, -0.39 + math.sin(angle) * (young and 0.83 or 1.12))
		c:leaf(
			"MantleFrond" .. tuft,
			start,
			start + V(math.cos(angle) * 0.24, -0.69, math.sin(angle) * 0.24),
			young and 0.47 or 0.62,
			tuft % 2 == 0 and light or moss,
			mantle
		)
	end
	local tailBase = V(0, by, young and -1.5 or -1.96)
	c:segment("Tail1", tailBase, tailBase + V(0.45, 0.06, -0.63), 0.36, 0.32, bark, body, true)
	c:segment("Tail2", tailBase + V(0.45, 0.06, -0.63), tailBase + V(0.78, 0.52, -0.65), 0.25, 0.24, moss, body, true)
	c:leaf("TailFrond", tailBase + V(0.7, 0.38, -0.64), tailBase + V(1, 0.92, -0.53), 0.65, light, body)
	if s == 3 then
		for spot = 1, 3 do
			c:sphere(
				"MossSpore" .. spot,
				V(0.31, 0.26, 0.3),
				V(-0.73 + spot * 0.45, by + 1.26, -0.65 - spot * 0.31),
				cream,
				mantle
			)
		end
	end
	return { body = body, head = head }
end

-- Segunda passagem de escultura: planos de rosto, apoios e massas secundárias.
-- O rig base continua íntegro; os volumes abaixo fazem parte da anatomia, não de efeitos.
local function point(c, part)
	return part.CFrame.Position / c.scale
end
local function size(c, part)
	return part.Size / c.scale
end
local function lids(c, head, color, angle)
	if c.young then
		return
	end
	for _, side in { -1, 1 } do
		local eye = c.model:FindFirstChild(side < 0 and "EyeL" or "EyeR")
		if eye then
			local at, dimensions = point(c, eye), size(c, eye)
			c:segment(
				"UpperEyelid" .. side,
				at + V(-dimensions.X * 0.43, dimensions.Y * 0.29 + side * angle, dimensions.Z * 0.28),
				at + V(dimensions.X * 0.43, dimensions.Y * 0.29 - side * angle, dimensions.Z * 0.28),
				0.1,
				0.11,
				color,
				head
			)
		end
	end
end
local function haunchSupport(c, body, name, color, width)
	for _, side in { -1, 1 } do
		local foot = c.model:FindFirstChild(name .. side .. "_-1")
		if foot then
			local at = point(c, foot)
			local weld = foot:FindFirstChildOfClass("WeldConstraint")
			local anchor = weld and weld.Part0 or body
			c:sphere("HockSupport" .. side, V(width, 0.58, 0.68), at + V(0, 0.31, -0.16), color, anchor)
		end
	end
end
local finish = {}
finish.cinzelo = function(c, a)
	local head, body = a.head, a.body
	local h, b = point(c, head), point(c, body)
	local skin, copper = head.Color, rgb(174, 95, 64)
	lids(c, head, skin, 0.015)
	-- Uma mandíbula larga com cantos e saco gular evita a antiga cabeça de esfera solta.
	c:sphere("GularThroat", V(c.young and 1.25 or 1.65, 0.55, 0.9), h + V(0, -0.51, -0.23), c.cream, head)
	for _, side in { -1, 1 } do
		c:sphere(
			"ShoulderWeb" .. side,
			V(0.59, 0.55, 0.79),
			b + V(side * (c.young and 1.04 or 1.4), -0.13, 0.63),
			skin,
			body
		)
		if not c.young then
			local from = h + V(side * 0.91, -0.19, 0.53)
			c:segment("JawCorner" .. side, from, from + V(side * 0.18, 0.21, -0.45), 0.2, 0.25, copper, head)
		end
	end
	if c.adult then
		local arch = c.model:FindFirstChild("SideKilnArch-1")
		if arch then
			local pos = point(c, arch)
			c:sphere("KilnDoorShoulder", V(0.2, 1.06, 1.08), pos + V(-0.03, 0, 0), copper, body)
			c:sphere("KilnDoorInset", V(0.15, 0.76, 0.78), pos + V(-0.15, 0.02, 0.01), rgb(249, 177, 75), body)
		end
	end
end
finish.magmarau = function(c, a)
	local h, b = point(c, a.head), point(c, a.body)
	local skin, mane = a.head.Color, rgb(84, 47, 64)
	lids(c, a.head, mane, c.adult and 0.035 or 0.015)
	-- Massas escapulares e máscara de focinho dão peso de javali, não um cão com presas.
	for _, side in { -1, 1 } do
		c:sphere(
			"ScapularMass" .. side,
			V(c.young and 0.65 or 0.9, c.young and 1.0 or 1.4, 1.25),
			b + V(side * (c.young and 0.95 or 1.3), 0.22, 0.65),
			skin,
			a.body
		)
		if not c.young then
			c:leaf(
				"JowlWhorl" .. side,
				h + V(side * 0.71, -0.12, 0.48),
				h + V(side * 1.1, -0.54, 0.02),
				0.5,
				mane,
				a.head
			)
		end
	end
	if c.adult then
		c:segment("NasalBridge", h + V(0, 0.11, 0.45), h + V(0, 0.03, 1.2), 0.43, 0.32, rgb(237, 135, 66), a.head)
		c:leaf("WitherFlame", b + V(0, 0.84, 0.77), b + V(0, 1.64, 0.5), 0.75, rgb(237, 135, 66), a.body)
	end
end
finish.folhuco = function(c, a)
	local h, b = point(c, a.head), point(c, a.body)
	local rust = rgb(169, 82, 62)
	lids(c, a.head, rust, -0.015)
	-- Ponte do focinho e pescoço posterior conectam cabeça, cernelha e peito felpudo.
	c:sphere(
		"FoxNeckNape",
		V(c.young and 0.93 or 1.13, c.young and 0.9 or 1.35, 0.98),
		(h + b) * 0.5 + V(0, 0.15, 0.25),
		a.head.Color,
		a.body
	)
	if not c.young then
		for _, side in { -1, 1 } do
			local cheek = h + V(side * 0.8, -0.18, 0.1)
			c:leaf(
				"RuffFlare" .. side,
				cheek,
				cheek + V(side * (c.adult and 0.59 or 0.38), -0.1, -0.28),
				0.54,
				c.cream,
				a.head
			)
			local hip = b + V(side * 0.67, -0.22, -0.83)
			c:sphere("FoxThigh" .. side, V(0.65, 0.84, 0.83), hip, rust, a.body)
		end
	end
	if c.adult then
		c:sphere("FoxNasalPlane", V(0.54, 0.29, 0.76), h + V(0, -0.16, 0.74), a.head.Color, a.head)
	end
end
finish.esfingeolito = function(c, a)
	local h, b = point(c, a.head), point(c, a.body)
	local lapis, sand = rgb(60, 118, 139), rgb(220, 184, 121)
	lids(c, a.head, lapis, 0)
	c:sphere(
		"SphinxThroat",
		V(c.young and 1.1 or 1.4, c.young and 0.8 or 1.1, 0.72),
		h + V(0, -0.71, -0.18),
		sand,
		a.body
	)
	if not c.young then
		for _, side in { -1, 1 } do
			local start = b + V(side * 0.94, 0.72, 0.59)
			c:leaf("NemesShoulder" .. side, start, start + V(side * 0.5, -0.62, -0.16), 0.73, lapis, a.body)
			c:segment(
				"ForearmCuff" .. side,
				V(side * 0.8, 0.62, 1.37),
				V(side * 0.8, 0.85, 1.32),
				0.69,
				0.74,
				lapis,
				c.model:FindFirstChild("LegFore" .. side) or a.body
			)
		end
	end
	if c.adult then
		c:sphere("SphinxBreastGem", V(0.59, 0.68, 0.2), h + V(0, -1.25, 0.53), rgb(112, 178, 171), a.body)
		c:leaf("NemesBackFan", h + V(0, 0.2, -0.6), h + V(0, -1.09, -0.87), 1.46, lapis, a.head)
	end
end
finish.magmaterra = function(c, a)
	local h, b = point(c, a.head), point(c, a.body)
	local clay, basalt, lava = rgb(154, 99, 76), rgb(78, 60, 75), rgb(241, 150, 69)
	lids(c, a.head, basalt, 0.015)
	c:segment(
		"TortoiseNeckFold",
		h - V(0, 0.15, 0.64),
		h - V(0, 0.13, 0.12),
		c.young and 1.18 or 1.45,
		0.93,
		a.head.Color,
		a.body
	)
	haunchSupport(c, a.body, "TortoiseFoot", clay, c.young and 0.58 or 0.76)
	if not c.young then
		for _, side in { -1, 1 } do
			c:leaf(
				"LateralLavaShelf" .. side,
				b + V(side * 1.23, 1.11, -0.38),
				b + V(side * (c.adult and 2.01 or 1.73), 0.73, -0.65),
				0.81,
				clay,
				a.body
			)
		end
	end
	if c.adult then
		for _, side in { -1, 1 } do
			local from = b + V(side * 1.01, 1.55, 0.5)
			c:segment("LavaRidge" .. side, from, from + V(side * 0.46, -0.39, 0.28), 0.19, 0.2, lava, a.body)
		end
	end
end
finish.nevoamusgo = function(c, a)
	local h, b = point(c, a.head), point(c, a.body)
	local bark, mist = rgb(85, 107, 86), rgb(173, 157, 189)
	lids(c, a.head, bark, -0.025)
	if c.young then
		-- Mandíbula e escápulas arredondadas dão apoio ao perfil do filhote.
		c:sphere("FawnLowerJaw", V(1.04, 0.3, 0.9), h + V(0, -0.88, 0.6), c.cream, a.head)
		for _, side in { -1, 1 } do
			c:sphere("FawnShoulder" .. side, V(0.45, 0.72, 0.56), b + V(side * 0.62, -0.12, 1.05), bark, a.body)
		end
	end
	-- A crista de cernelha e o focinho alongado separam o cervo adulto de um filhote genérico.
	if not c.young then
		c:leaf("WitherMantle", b + V(0, 0.64, 0.38), b + V(0, 1.21, -0.48), 1.06, rgb(124, 155, 100), a.body)
		for _, side in { -1, 1 } do
			c:sphere("DeerHindThigh" .. side, V(0.57, 0.86, 0.75), b + V(side * 0.82, -0.38, -0.97), bark, a.body)
			c:leaf(
				"FogCheek" .. side,
				h + V(side * 0.65, -0.28, -0.11),
				h + V(side * 0.91, -0.75, -0.38),
				0.38,
				mist,
				a.head
			)
		end
	end
	if c.adult then
		c:sphere("StagNasalPlane", V(0.65, 0.33, 0.89), h + V(0, -0.36, 0.75), rgb(178, 195, 132), a.head)
	end
end
for id, polish in finish do
	local build = S[id]
	S[id] = function(c)
		local anatomy = build(c)
		polish(c, anatomy)
		return anatomy
	end
end

return S
