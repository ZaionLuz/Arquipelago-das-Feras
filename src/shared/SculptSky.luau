--!nonstrict
-- Seis anatomias de céu: volumes conectados, olhos legíveis e asas com uma raiz articulada.
local S = {}
local V = Vector3.new
local A = CFrame.Angles
local function rgb(r, g, b)
	return Color3.fromRGB(r, g, b)
end
local navy = rgb(43, 46, 79)
local gold = rgb(247, 184, 75)

local function feet(c, body, y, spread, z, color, heavy)
	for _, side in { -1, 1 } do
		local x = side * spread
		local ankle = V(x, 0.34, z + 0.07)
		local hip = V(x * 0.8, y, z - 0.12)
		local knee = V(x * 0.9, 0.34 + (y - 0.34) * 0.45, z - 0.03)
		local thigh = c:segment(
			"FeatheredThigh" .. side,
			hip,
			knee,
			heavy and 0.66 or 0.48,
			heavy and 0.72 or 0.56,
			heavy and rgb(255, 222, 151) or body.Color,
			body
		)
		for tuft = 1, 1 do
			local from = hip:Lerp(knee, 0.2 + tuft * 0.12) + V(side * 0.12, 0, 0.22)
			c:leaf(
				"HockFeather" .. side .. "_" .. tuft,
				from,
				from + V(side * 0.15, -0.48, 0.09),
				heavy and 0.32 or 0.25,
				heavy and rgb(247, 184, 75) or body.Color,
				thigh
			)
		end
		local shin =
			c:segment("Leg" .. side, knee, ankle, heavy and 0.25 or 0.15, heavy and 0.3 or 0.19, color, thigh, true)
		local foot = c:sphere("Foot" .. side, V(heavy and 0.48 or 0.34, 0.22, 0.56), ankle, color, shin)
		for toe = 1, 3 do
			c:segment(
				"Toe" .. side .. "_" .. toe,
				ankle + V((toe - 2) * 0.1, -0.05, 0.12),
				ankle + V((toe - 2) * (heavy and 0.28 or 0.18), -0.07, 0.48),
				0.1,
				0.12,
				color,
				foot
			)
			if c.stage == 3 and toe == 2 then
				local tip = ankle + V((toe - 2) * (heavy and 0.28 or 0.18), -0.07, 0.48)
				c:leaf("TalonTip" .. side .. "_" .. toe, tip, tip + V((toe - 2) * 0.03, -0.09, 0.18), 0.105, navy, foot)
			end
		end
	end
end

local function eyeRim(c, head, center, spacing, radius, color)
	-- A sobrancelha se apoia sobre a órbita; não é outra antena flutuante.
	for _, side in { -1, 1 } do
		local eye = center + V(side * spacing * 0.5, radius * 0.91, radius * 0.16)
		c:segment(
			"OrbitalRim" .. side,
			eye + V(-radius * 0.78, side * radius * 0.09, 0),
			eye + V(radius * 0.78, -side * radius * 0.09, 0.015),
			radius * 0.38,
			radius * 0.42,
			color,
			head
		)
	end
end

local function beak(c, head, center, width, length, color)
	local upper =
		c:sphere("UpperBeak", V(width, width * 0.52, length * 0.77), center, color, head, false, A(-0.1, 0, 0))
	c:leaf(
		"BeakHook",
		center + V(0, width * 0.03, length * 0.25),
		center + V(0, -width * 0.34, length * 0.57),
		width * 0.62,
		color,
		upper
	)
	c:sphere(
		"LowerBeak",
		V(width * 0.78, width * 0.18, length * 0.69),
		center + V(0, -width * 0.24, -0.025),
		color,
		head
	)
	c:segment(
		"BeakInlay",
		center + V(-width * 0.36, -width * 0.16, length * 0.11),
		center + V(width * 0.36, -width * 0.16, length * 0.11),
		width * 0.065,
		width * 0.08,
		navy,
		head
	)
	for _, side in { -1, 1 } do
		c:sphere(
			"Nostril" .. side,
			V(0.05, 0.055, 0.07),
			center + V(side * width * 0.22, width * 0.12, length * 0.14),
			navy,
			head
		)
	end
end

-- Ponta de pena em prisma afilado: a cunha é orientada no plano da asa, não de perfil.
local function flightTip(c, name, from, to, width, color, parent)
	local direction = (to - from).Unit
	local normal = V(0, 0, 1) - direction * direction:Dot(V(0, 0, 1))
	if normal.Magnitude < 0.05 then
		normal = V(0, 1, 0) - direction * direction:Dot(V(0, 1, 0))
	end
	normal = normal.Unit
	local right = direction:Cross(normal).Unit
	local frame = CFrame.fromMatrix(V(0, 0, 0), -normal, right, -direction)
	return c:wedge(
		name,
		V(width * 0.24, width, (to - from).Magnitude),
		(from + to) * 0.5 + right * width * 0.2,
		color,
		parent,
		false,
		frame
	)
end

-- Leques de penas sobrepostos no plano frontal; ombro e antebraço ficam sob a plumagem.
local function broadWing(c, body, side, shoulder, span, sweep, primary, cover, lining, count, lifted)
	local wing = c:sphere("Wing" .. (side < 0 and "L" or "R"), V(0.42, 0.5, 0.52), shoulder, cover, body, true)
	local folded = lifted <= 0
	local elbow = shoulder + V(side * span * (folded and 0.24 or 0.35), folded and -0.33 or lifted * 0.26, -0.13)
	local wrist = shoulder + V(side * span * (folded and 0.3 or 0.69), folded and -0.78 or lifted * 0.8, -0.25)
	c:segment("WingUpper", shoulder, elbow, 0.48, 0.5, cover, wing)
	c:segment("WingForearm", elbow, wrist, 0.34, 0.4, cover, wing)
	local mantleTip = elbow:Lerp(wrist, 0.66) + V(side * span * 0.045, folded and -0.25 or -0.12, 0.03)
	c:leaf("WingMantleWeb", shoulder + V(0, -0.04, 0.08), mantleTip, math.max(0.72, span * 0.32), cover, wing)
	for feather = 1, count do
		local t = (feather - 1) / math.max(1, count - 1)
		local from, tip, width
		if folded then
			from = shoulder + V(side * span * (0.05 + t * 0.18), -0.02 - t * 0.12, 0.02)
			tip = shoulder + V(side * span * (0.16 + t * 0.32), -sweep * (0.67 + t * 0.2), -0.2 - t * 0.15)
			width = math.max(0.42, span * 0.42)
		else
			from = shoulder + V(side * span * (0.06 + t * 0.16), 0.04 + t * 0.3, -0.04 - t * 0.1)
			tip = shoulder
				+ V(
					side * span * (0.4 + math.sin(t * math.pi * 0.5) * 0.62),
					-sweep * 0.25 + t ^ 1.25 * (lifted * 1.6 + sweep * 0.25),
					-0.21 - t * 0.15
				)
			width = math.max(0.45, span * 0.13 + 0.15)
		end
		local bend = from:Lerp(tip, 0.66) + V(side * width * 0.16, width * 0.08, 0.035)
		local featherPart = c:leaf(
			"PrimaryFeather" .. feather,
			from - (bend - from) * 0.1,
			bend + (tip - bend) * 0.19,
			width,
			primary,
			wing
		)
		flightTip(
			c,
			"FlightFeatherTip" .. feather,
			bend - (bend - from) * 0.16,
			tip,
			width * 0.76,
			primary,
			featherPart
		)
		-- Coberturas alternadas e mais largas evitam três peles sobrepostas em toda rêmige.
		if feather % 2 == 1 or feather == count then
			local middleFrom = from + V(0, 0.01, 0.13)
			c:leaf(
				"FeatherMiddle" .. feather,
				middleFrom,
				from:Lerp(tip, 0.77) + V(0, 0.01, 0.13),
				width * 1.02,
				cover,
				featherPart
			)
		end
		if feather % 2 == 0 or feather == 1 then
			c:leaf(
				"FeatherInner" .. feather,
				from + V(0, 0.02, 0.24),
				from:Lerp(tip, 0.42) + V(0, 0.02, 0.24),
				width * 0.82,
				lining,
				featherPart
			)
		end
	end
	for feather = 1, math.max(2, count - 3), 2 do
		local t = feather / math.max(2, count - 3)
		local from = shoulder + V(side * (0.12 + t * span * (folded and 0.12 or 0.27)), t * lifted * 0.25 + 0.1, 0.28)
		local to = from + V(side * 0.15, folded and -0.43 or -0.27, 0.02)
		c:leaf("WingCover" .. feather, from, to, folded and 0.48 or 0.58, cover, wing)
	end
	return wing
end

local function curvedTail(c, body, origin, paths, mainColor, tipColor, width)
	local root = c:sphere("Tail1", V(width * 1.2, width, width), origin, mainColor, body, true)
	for strand, path in paths do
		local previous = origin + V((strand - (#paths + 1) * 0.5) * width * 0.3, 0, 0)
		for index, point in path do
			local overlap = (point - previous) * 0.12
			c:segment(
				"TailRibbon" .. strand .. "_" .. index,
				previous - overlap,
				point + overlap,
				width * (1 - index / (#path + 2) * 0.48),
				width * (1 - index / (#path + 2) * 0.48) * 0.48,
				mainColor,
				root
			)
			if index == #path then
				c:leaf(
					"TailTip" .. strand,
					previous:Lerp(point, 0.72),
					point + overlap * 0.3,
					width * 0.43,
					tipColor,
					root
				)
			end
			previous = point
		end
	end
	return root
end

function S.fenixfuligem(c)
	local stage = c.stage
	local soot, wingColor, warm = rgb(66, 51, 75), rgb(108, 72, 91), rgb(230, 120, 79)
	local height = stage == 1 and 1.45 or stage == 2 and 1.8 or 2.15
	local body = c:sphere(
		"Body",
		V(stage == 1 and 1.65 or 1.8, stage == 1 and 1.55 or 2.05, 1.5),
		V(0, height, 0),
		soot,
		c.root,
		true
	)
	c:sphere("WarmBreast", V(1.15, 1.45, 0.46), V(0, height - 0.05, 0.67), warm, body)
	local neck = V(0, height + 0.8, 0.36)
	c:segment("Neck", V(0, height + 0.35, 0.16), neck, 0.94, 0.9, soot, body)
	local head = c:sphere("Head", V(stage == 1 and 1.5 or 1.3, 1.2, 1.16), neck + V(0, 0.4, 0.18), soot, body, true)
	c:eyes(head, neck + V(0, 0.5, 0.7), 0.72, stage == 1 and 0.29 or 0.24, gold, -0.09)
	eyeRim(c, head, neck + V(0, 0.5, 0.7), 0.72, stage == 1 and 0.29 or 0.24, wingColor)
	beak(c, head, neck + V(0, 0.13, 1.0), 0.46, 0.67, rgb(214, 157, 91))
	for _, side in { -1, 1 } do
		c:segment(
			"AshBrow" .. side,
			neck + V(side * 0.3, 0.77, 0.66),
			neck + V(side * 0.59, 0.9, 0.45),
			0.17,
			0.15,
			wingColor,
			head
		)
		local crownBase = neck + V(side * 0.29, 0.86, 0.03)
		c:leaf("AshCrest" .. side, crownBase, crownBase + V(side * 0.32, 0.55 + stage * 0.15, -0.32), 0.25, warm, head)
		local shoulder = V(side * 0.76, height + 0.25, 0.02)
		broadWing(
			c,
			body,
			side,
			shoulder,
			stage == 1 and 1.0 or stage == 2 and 1.7 or 2.6,
			stage == 1 and 0.9 or 1.4,
			soot,
			wingColor,
			warm,
			stage + 2,
			stage == 3 and 0.62 or -0.4
		)
	end
	feet(c, body, height - 0.35, stage == 1 and 0.38 or 0.47, 0.08, rgb(181, 116, 75), false)
	local tailOrigin = V(0, height - 0.45, -0.58)
	local paths = {}
	for strand = 1, stage + 1 do
		local x = (strand - (stage + 2) / 2) * 0.35
		paths[strand] = { V(x, height - 0.68, -1.3), V(x * 1.7, height - 0.8, -1.7 - stage * 0.27) }
	end
	curvedTail(c, body, tailOrigin, paths, soot, warm, 0.35)
	if stage >= 2 then
		for i = 1, stage + 1 do
			c:sphere(
				"EmberBreast" .. i,
				V(0.11, 0.16, 0.05),
				V((i - (stage + 2) / 2) * 0.21, height - 0.22, 0.93),
				gold,
				body
			)
		end
	end
	return { body = body, head = head }
end

function S.penugem(c)
	local stage = c.stage
	local down, blue, buff = rgb(246, 232, 199), rgb(135, 170, 192), rgb(222, 174, 126)
	local y = stage == 1 and 1.1 or stage == 2 and 1.3 or 1.5
	local body = c:sphere(
		"Body",
		V(stage == 1 and 1.9 or 2.05, stage == 1 and 1.7 or 2.05, 1.65),
		V(0, y, 0),
		blue,
		c.root,
		true
	)
	c:sphere("DownApron", V(1.48, 1.55, 0.55), V(0, y - 0.08, 0.67), down, body)
	local headCenter = V(0, y + 0.88, 0.23)
	local head = c:sphere("Head", V(stage == 1 and 1.8 or 1.88, 1.52, 1.48), headCenter, blue, body, true)
	for _, side in { -1, 1 } do
		c:sphere("FaceDisk" .. side, V(0.88, 1.08, 0.32), headCenter + V(side * 0.43, -0.02, 0.61), down, head)
		c:leaf(
			"EarTuft" .. side,
			headCenter + V(side * 0.58, 0.48, -0.02),
			headCenter + V(side * 0.87, stage == 1 and 0.89 or 1.22, -0.18),
			stage == 1 and 0.32 or 0.43,
			blue,
			head
		)
		c:leaf(
			"InnerTuft" .. side,
			headCenter + V(side * 0.6, 0.58, 0.05),
			headCenter + V(side * 0.82, stage == 1 and 0.89 or 1.09, -0.1),
			0.18,
			down,
			head
		)
		local shoulder = V(side * 0.82, y + 0.27, -0.05)
		if stage == 1 then
			local wing =
				c:sphere("Wing" .. side, V(0.6, 0.93, 0.58), shoulder + V(side * 0.06, -0.24, 0.12), down, body, true)
			c:sphere("WingTip", V(0.33, 0.51, 0.39), shoulder + V(side * 0.07, -0.61, 0.23), blue, wing)
		else
			broadWing(
				c,
				body,
				side,
				shoulder,
				stage == 2 and 1.4 or 2.0,
				1.3,
				blue,
				down,
				buff,
				stage == 2 and 3 or 4,
				-0.26
			)
		end
	end
	c:eyes(head, headCenter + V(0, 0.06, 0.84), 0.88, stage == 1 and 0.3 or 0.28, rgb(91, 126, 151), -0.04)
	eyeRim(c, head, headCenter + V(0, 0.06, 0.84), 0.88, stage == 1 and 0.3 or 0.28, down)
	beak(c, head, headCenter + V(0, -0.29, 1.03), 0.26, 0.36, buff)
	feet(c, body, 0.65, 0.39, 0.13, buff, false)
	curvedTail(c, body, V(0, y - 0.44, -0.6), {
		{ V(-0.35, y - 0.48, -1.1), V(-0.55, y - 0.32, -1.42) },
		{ V(0, y - 0.48, -1.28), V(0, y - 0.12, -1.65) },
		{ V(0.35, y - 0.48, -1.1), V(0.55, y - 0.32, -1.42) },
	}, blue, down, 0.32)
	if stage == 3 then
		for i = 1, 3 do
			c:sphere("ApronScallop" .. i, V(0.37, 0.28, 0.12), V((i - 2) * 0.35, y - 0.38, 0.97), buff, body)
		end
	end
	return { body = body, head = head }
end

function S.ventanil(c)
	local stage = c.stage
	local teal, pale, lavender = rgb(74, 149, 171), rgb(208, 233, 220), rgb(150, 133, 190)
	local y = stage == 1 and 1.3 or stage == 2 and 1.7 or 2.05
	local body = c:sphere(
		"Body",
		V(stage == 1 and 1.45 or 1.5, 1.5, stage == 1 and 1.7 or 2.25),
		V(0, y, -0.2),
		teal,
		c.root,
		true,
		A(-0.12, 0, 0)
	)
	c:sphere("Breast", V(1.05, 1.2, 0.48), V(0, y + 0.05, 0.73), pale, body)
	local neckTop = V(0, y + (stage == 1 and 0.8 or 1.5), 0.75)
	c:segment("NeckBase", V(0, y + 0.4, 0.47), V(0, y + 0.88, 0.63), 0.68, 0.7, pale, body)
	c:segment("NeckArch", V(0, y + 0.72, 0.62), neckTop, stage == 1 and 0.55 or 0.48, 0.54, pale, body)
	local head = c:sphere("Head", V(1.0, 0.93, 1.17), neckTop + V(0, 0.18, 0.1), teal, body, true)
	c:eyes(head, neckTop + V(0, 0.24, 0.65), 0.59, 0.2, lavender, -0.04)
	eyeRim(c, head, neckTop + V(0, 0.24, 0.65), 0.59, 0.2, teal)
	beak(
		c,
		head,
		neckTop + V(0, -0.02, stage == 1 and 0.92 or 1.07),
		0.27,
		stage == 1 and 0.55 or 0.96,
		rgb(227, 179, 116)
	)
	for _, side in { -1, 1 } do
		local from = neckTop + V(side * 0.2, 0.54, -0.15)
		c:leaf(
			"WindCrest" .. side,
			from,
			from + V(side * (0.1 + stage * 0.12), 0.18, -0.65 - stage * 0.12),
			0.18,
			pale,
			head
		)
		broadWing(
			c,
			body,
			side,
			V(side * 0.61, y + 0.2, 0),
			stage == 1 and 1.05 or stage == 2 and 1.9 or 3.0,
			stage == 1 and 1.0 or 1.6,
			teal,
			pale,
			lavender,
			stage + 2,
			stage == 3 and 0.7 or -0.1
		)
	end
	feet(c, body, y - 0.3, stage == 1 and 0.3 or 0.37, 0.3, rgb(174, 135, 125), false)
	local paths = {}
	for strand = 1, stage == 1 and 2 or 3 do
		local x = (strand - (stage == 1 and 1.5 or 2)) * 0.32
		paths[strand] = {
			V(x, y - 0.15, -1.48),
			V(x * 1.7, y - 0.38, -2.0 - stage * 0.15),
			V(x * 2 + 0.35, y + 0.08, -2.6 - stage * 0.2),
		}
	end
	curvedTail(c, body, V(0, y - 0.2, -0.98), paths, pale, lavender, 0.24)
	return { body = body, head = head }
end

function S.aeronimbo(c)
	local stage = c.stage
	local blue, cloud, mauve = rgb(133, 162, 193), rgb(245, 235, 211), rgb(180, 152, 199)
	local y = stage == 1 and 1.1 or stage == 2 and 1.5 or 1.8
	local body = c:sphere("Body", V(1.45, 1.35, stage == 1 and 1.8 or 2.0), V(0, y, 0), blue, c.root, true)
	local tail = c:sphere("Tail1", V(0.9, 0.85, 0.9), V(0, y, -0.72), blue, body, true)
	local steps = stage == 1 and 3 or stage == 2 and 5 or 7
	local previous = V(0, y, -0.5)
	for i = 1, steps do
		local t = i / steps
		local point = V(
			math.sin(t * math.pi * 1.65) * (0.45 + stage * 0.24),
			y + math.sin(t * math.pi) * 0.35,
			-0.55 - t * (1.5 + stage * 0.82)
		)
		local coil = c:segment("Coil" .. i, previous, point, 1.12 - t * 0.75, 1.15 - t * 0.72, blue, tail)
		if i % 2 == 0 then
			c:leaf("CloudSpine" .. i, point + V(0, 0.27, 0), point + V(0.13, 0.64, -0.49), 0.3, cloud, coil)
		end
		if i % 2 == 0 then
			c:sphere("CloudBack" .. i, V(0.78 - t * 0.25, 0.44, 0.65), point + V(0, 0.38, 0), cloud, tail)
		end
		previous = point
	end
	for _, side in { -1, 1 } do
		c:leaf(
			"CloudTailFin" .. side,
			previous,
			previous + V(side * (0.5 + stage * 0.1), 0.22, -0.8),
			0.55,
			mauve,
			tail
		)
	end
	local headCenter = V(0, y + (stage == 1 and 0.75 or 1.15), 1.0)
	local neckBend = V(0, y + (stage == 1 and 0.54 or 0.83), 0.88)
	c:segment("CloudNeck", V(0, y + 0.32, 0.27), neckBend, 1.03, 1.06, blue, body)
	c:segment("CloudNeckArch", neckBend - V(0, 0.08, 0), headCenter + V(0, -0.1, -0.12), 0.83, 0.91, blue, body)
	local head = c:sphere("Head", V(stage == 1 and 1.8 or 1.9, 1.3, 1.55), headCenter, blue, body, true)
	c:sphere("CreamMuzzle", V(1.2, 0.65, 0.9), headCenter + V(0, -0.26, 0.79), cloud, head)
	c:sphere("CloudJaw", V(1.28, 0.33, 1.04), headCenter + V(0, -0.48, 0.59), cloud, head)
	c:sphere("Nose", V(0.33, 0.2, 0.19), headCenter + V(0, -0.1, 1.1), mauve, head)
	c:eyes(head, headCenter + V(0, 0.15, 0.71), 1.02, stage == 1 and 0.26 or 0.23, rgb(95, 121, 165), -0.1)
	eyeRim(c, head, headCenter + V(0, 0.15, 0.71), 1.02, stage == 1 and 0.26 or 0.23, blue)
	for _, side in { -1, 1 } do
		local earBase = headCenter + V(side * 0.63, 0.35, -0.2)
		c:leaf(
			"CloudEar" .. side,
			earBase,
			earBase + V(side * 0.42, stage == 1 and 0.5 or 0.75, -0.42),
			0.48,
			mauve,
			head
		)
		c:leaf(
			"CloudEarInner" .. side,
			earBase + V(0, 0.06, 0.05),
			earBase + V(side * 0.3, 0.58, -0.22),
			0.27,
			cloud,
			head
		)
		c:sphere("CollarCloud" .. side, V(1.04, 0.72, 0.87), V(side * 0.69, y + 0.44, 0.29), cloud, body)
		c:sphere("CheekCloud" .. side, V(0.61, 0.48, 0.49), headCenter + V(side * 0.78, -0.28, 0.34), cloud, head)
		if stage >= 2 then
			local whisker = headCenter + V(side * 0.62, -0.18, 0.91)
			c:segment("CloudWhisker" .. side, whisker, whisker + V(side * 0.63, 0.16, -0.13), 0.11, 0.12, gold, head)
			c:segment(
				"WhiskerCurl" .. side,
				whisker + V(side * 0.61, 0.16, -0.13),
				whisker + V(side * 0.76, 0.43, -0.23),
				0.08,
				0.09,
				gold,
				head
			)
		end
		if stage == 3 then
			local horn = headCenter + V(side * 0.49, 0.55, -0.35)
			c:segment("CloudAntler" .. side, horn, horn + V(side * 0.2, 0.9, -0.43), 0.16, 0.18, gold, head)
			c:segment(
				"CloudAntlerBranch" .. side,
				horn + V(side * 0.1, 0.46, -0.2),
				horn + V(side * 0.58, 0.7, -0.43),
				0.11,
				0.12,
				gold,
				head
			)
		end
	end
	for i = 1, 3 do
		c:sphere(
			"CloudCrown" .. i,
			V(0.77, 0.55 + (i == 2 and 0.16 or 0), 0.82),
			headCenter + V((i - 2) * 0.5, 0.62, -0.13),
			cloud,
			head
		)
	end
	if stage >= 2 then
		for _, side in { -1, 1 } do
			for limb = 1, 2 do
				local start = V(side * 0.57, y - 0.15, limb == 1 and 0.39 or -0.51)
				c:segment("Leg" .. side .. limb, start, start + V(side * 0.17, -0.65, 0.22), 0.27, 0.3, blue, body)
				c:sphere(
					"CloudPaw" .. side .. limb,
					V(0.45, 0.28, 0.56),
					start + V(side * 0.17, -0.65, 0.34),
					cloud,
					body
				)
			end
		end
	end
	return { body = body, head = head }
end

function S.tempestalia(c)
	local stage = c.stage
	local storm, sky, lilac = rgb(66, 91, 137), rgb(150, 204, 219), rgb(151, 109, 173)
	local y = stage == 1 and 1.35 or stage == 2 and 1.75 or 2.05
	local body = c:sphere("Body", V(1.75, stage == 1 and 1.55 or 2.1, 1.62), V(0, y, 0), storm, c.root, true)
	c:sphere("StormBreast", V(1.2, 1.45, 0.5), V(0, y - 0.04, 0.69), sky, body)
	local headCenter = V(0, y + 1.05, 0.35)
	c:segment("Neck", V(0, y + 0.48, 0.12), headCenter, 0.97, 0.95, storm, body)
	local head = c:sphere("Head", V(1.4, 1.23, 1.34), headCenter, sky, body, true)
	c:eyes(head, headCenter + V(0, 0.13, 0.64), 0.81, stage == 1 and 0.26 or 0.22, gold, 0.07)
	eyeRim(c, head, headCenter + V(0, 0.13, 0.64), 0.81, stage == 1 and 0.26 or 0.22, storm)
	beak(c, head, headCenter + V(0, -0.2, 0.94), 0.35, 0.62, gold)
	for _, side in { -1, 1 } do
		c:leaf(
			"StormCheek" .. side,
			headCenter + V(side * 0.47, -0.12, 0.27),
			headCenter + V(side * 0.86, 0.05, -0.35),
			0.36,
			lilac,
			head
		)
		local shoulder = V(side * 0.72, y + 0.4, -0.02)
		broadWing(
			c,
			body,
			side,
			shoulder,
			stage == 1 and 1.1 or stage == 2 and 2.0 or 3.1,
			stage == 1 and 1.0 or 1.8,
			storm,
			sky,
			lilac,
			stage + 3,
			stage == 3 and 1.25 or 0.12
		)
		if stage >= 2 then
			c:leaf(
				"StormMantle" .. side,
				V(side * 0.45, y + 0.65, 0.42),
				V(side * 0.76, y - 0.38, 0.8),
				0.42,
				lilac,
				body
			)
		end
	end
	for crown = 1, stage == 1 and 3 or 5 do
		local t = crown - (stage == 1 and 2 or 3)
		local start = headCenter + V(t * 0.18, 0.49, -0.15)
		local peak = start + V(t * 0.18, 0.55 + (2 - math.abs(t)) * 0.18, -0.31)
		c:leaf("StormCrown" .. crown, start, peak, 0.2, gold, head)
		c:sphere("CrownBead" .. crown, V(0.14, 0.18, 0.14), peak, sky, head)
	end
	feet(c, body, y - 0.4, 0.44, 0.12, rgb(183, 144, 111), false)
	local tailOrigin = V(0, y - 0.5, -0.68)
	local paths = {}
	for strand = 1, stage + 2 do
		local x = (strand - (stage + 3) / 2) * 0.25
		paths[strand] = { V(x, y - 0.65, -1.5), V(x * 1.6, y - 0.9, -2.0 - (1 - math.abs(x)) * 0.5) }
	end
	local tail = curvedTail(c, body, tailOrigin, paths, lilac, sky, 0.31)
	if stage == 3 then
		for _, side in { -1, 1 } do
			c:segment(
				"RainStripe" .. side,
				V(side * 0.23, y - 0.6, -1.5),
				V(side * 0.39, y - 0.82, -2.35),
				0.1,
				0.07,
				gold,
				tail
			)
		end
	end
	return { body = body, head = head }
end

function S.fenix(c)
	-- A Fênix já nasce adulta: não se cria uma forma infantil para a espécie lendária.
	local crimson, scarlet, orange = rgb(143, 39, 70), rgb(209, 64, 72), rgb(239, 117, 61)
	local cream, sunlight = rgb(255, 233, 171), rgb(255, 196, 72)
	local body = c:sphere("Body", V(2.05, 2.85, 1.95), V(0, 2.6, 0), crimson, c.root, true, A(-0.13, 0, 0))
	c:sphere("SolarBreast", V(1.52, 2.34, 0.72), V(0, 2.78, 0.86), cream, body, false, A(-0.12, 0, 0))
	c:segment("NeckLower", V(0, 3.5, 0.26), V(0, 4.22, 0.95), 1.04, 1.08, cream, body)
	c:segment("NeckSwan", V(0, 4.03, 0.89), V(0, 4.86, 0.64), 0.78, 0.86, cream, body)
	local headCenter = V(0, 5.01, 0.85)
	local head = c:sphere("Head", V(1.32, 1.23, 1.52), headCenter, scarlet, body, true, A(-0.06, 0, 0))
	c:sphere("SolarMask", V(1.09, 0.79, 0.35), headCenter + V(0, -0.05, 0.68), orange, head)
	c:eyes(head, headCenter + V(0, 0.15, 0.76), 0.77, 0.21, sunlight, 0.08)
	eyeRim(c, head, headCenter + V(0, 0.15, 0.76), 0.77, 0.21, crimson)
	beak(c, head, headCenter + V(0, -0.16, 1.16), 0.35, 0.9, sunlight)
	for _, side in { -1, 1 } do
		local jaw = headCenter + V(side * 0.43, -0.27, 0.2)
		c:leaf("SolarCheek" .. side, jaw, jaw + V(side * 0.32, -0.11, -0.51), 0.26, cream, head)
		local crest = headCenter + V(side * 0.22, 0.43, -0.17)
		c:leaf("SolarCrest" .. side, crest, crest + V(side * 0.34, 1.01, -0.64), 0.3, sunlight, head)
		c:leaf(
			"SolarCrestFlame" .. side,
			crest + V(0, 0.05, -0.15),
			crest + V(side * 0.51, 0.64, -0.97),
			0.29,
			scarlet,
			head
		)
		local shoulder = V(side * 0.88, 3.47, -0.05)
		local wing = broadWing(c, body, side, shoulder, 4.7, 2.65, scarlet, orange, sunlight, 8, 2.5)
		for cover = 1, 4 do
			local t = cover / 4
			local from = shoulder + V(side * (0.3 + t * 1.2), t * 0.53, 0.24)
			c:segment(
				"GoldenShoulderFeather" .. cover,
				from,
				from + V(side * 0.36, -0.2, -0.75),
				0.44,
				0.22,
				cream,
				wing
			)
		end
		c:leaf("FlameMantle" .. side, V(side * 0.5, 3.65, 0.52), V(side * 0.85, 2.45, 1.0), 0.45, sunlight, body)
	end
	for i = 1, 5 do
		local from = V((i - 3) * 0.18, 3.0, 1.17)
		c:leaf(
			"ChestFeather" .. i,
			from,
			from + V((i - 3) * 0.12, -0.74, -0.02),
			0.25,
			i % 2 == 0 and sunlight or cream,
			body
		)
	end
	feet(c, body, 1.55, 0.5, 0.16, sunlight, true)
	local origin = V(0, 2.0, -0.64)
	local paths = {}
	for strand = 1, 7 do
		local x = (strand - 4) * 0.31
		paths[strand] = {
			V(x, 1.43, -1.65),
			V(x * 1.8, 0.69 + math.abs(x) * 0.2, -2.8),
			V(x * 2.35 + 0.2, 0.8 + math.abs(x) * 0.25, -3.8),
			V(x * 2.5 + 0.65, 1.67 + math.abs(x) * 0.3, -4.48),
		}
	end
	local tail = curvedTail(c, body, origin, paths, scarlet, sunlight, 0.62)
	for strand = 1, 3 do
		local x = (strand - 2) * 0.44
		c:segment("SolarTrainInlay" .. strand, V(x, 1.39, -1.65), V(x * 1.8, 0.79, -2.79), 0.15, 0.08, sunlight, tail)
		c:segment(
			"SolarTrainInlayCurl" .. strand,
			V(x * 1.8, 0.79, -2.79),
			V(x * 2.35 + 0.2, 0.9, -3.78),
			0.12,
			0.08,
			orange,
			tail
		)
	end
	local haloCenter = headCenter + V(0, 0.42, -0.71)
	local radius = 1.4
	for i = 1, 16 do
		local angle = (i - 1) * math.pi * 2 / 16
		local nextAngle = i * math.pi * 2 / 16
		local from = haloCenter + V(math.cos(angle) * radius, math.sin(angle) * radius, 0)
		local to = haloCenter + V(math.cos(nextAngle) * radius, math.sin(nextAngle) * radius, 0)
		c:segment("HaloArc" .. i, from, to, 0.11, 0.12, sunlight, head)
		if i % 2 == 0 then
			local rayFrom = haloCenter + V(math.cos(angle) * 1.43, math.sin(angle) * 1.43, 0)
			local rayTo = haloCenter + V(math.cos(angle) * 1.75, math.sin(angle) * 1.75, 0)
			c:leaf("HaloRay" .. i, rayFrom, rayTo, 0.17, sunlight, head)
		end
	end
	return { body = body, head = head }
end

return S
