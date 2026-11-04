--!nonstrict
-- Camada cenográfica: nenhuma peça é sólida, consultável ou interativa.
local RS = game:GetService("ReplicatedStorage")
local T = require(RS.Shared.ArtTokens)
local I = require(RS.Shared.Islands)
local Layout = require(RS.Shared.WorldLayout)
local A = { BudgetPerIsland = 340 }
local V = Vector3.new
local function block(parent, name, size, position, color, rotation, kind)
	local p = Instance.new(kind == "wedge" and "WedgePart" or "Part")
	p.Name = name
	p.Size = size
	p.CFrame = CFrame.new(position) * (rotation or CFrame.identity)
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = size.Magnitude > 4
	p.Parent = parent
	return p
end
local function motion(part, kind, phase)
	part:SetAttribute("ArtMotion", kind)
	part:SetAttribute("ArtPhase", phase or 0)
end
local function shrub(parent, origin, ramp, style, index)
	local trunk = T.Ramps.Sand
	local ground = block(parent, "SombraRecortada", V(7, 0.04, 5), origin + V(1, 0.02, 0.6), ramp[1])
	ground.Transparency = 0.3
	ground.CastShadow = false
	if style == "Leaf" then
		block(
			parent,
			"TroncoFacetado",
			V(1.3, 7, 1.5),
			origin + V(0, 3.5, 0),
			trunk[2],
			CFrame.Angles(0, index * 0.7, 0.08)
		)
		block(parent, "Ramo", V(3, 0.7, 0.7), origin + V(1, 5, 0), trunk[3], CFrame.Angles(0, 0, 0.4))
		for tier = 1, 3 do
			local size = 8 - tier * 1.5
			local leaf = block(
				parent,
				"CopaEmCamadas",
				V(size, 1.4, size * 0.85),
				origin + V(tier % 2 * 0.5, 6 + tier, 0),
				ramp[tier + 1],
				CFrame.Angles(0, math.pi / 4, 0)
			)
			if tier == 3 then
				motion(leaf, "leaf", index * 0.5)
			end
		end
	elseif style == "Ember" then
		for tier = 1, 3 do
			block(
				parent,
				"BasaltoEstratificado",
				V(5 - tier, 1.6, 4.5 - tier),
				origin + V(0, tier * 0.9, 0),
				ramp[tier % 2 + 1],
				CFrame.Angles(0, index * 0.7, 0),
				"wedge"
			)
		end
		local shard = block(
			parent,
			"VidroDeBrasa",
			V(0.5, 3, 0.6),
			origin + V(0.2, 3, 0),
			ramp[4],
			CFrame.Angles(0.2, 0, 0.3),
			"wedge"
		)
		motion(shard, "spark", index)
	elseif style == "Tidal" then
		for side = -1, 1 do
			block(
				parent,
				"CoralRamo",
				V(0.8, 3 + side * 0.4, 0.8),
				origin + V(side * 1.2, 1.5, 0),
				T.Ramps.Rose[side + 3],
				CFrame.Angles(0, 0, side * 0.3)
			)
			block(
				parent,
				"CoralLeque",
				V(2, 0.6, 1),
				origin + V(side * 1.3, 3 + side * 0.4, 0),
				T.Ramps.Rose[4],
				CFrame.Angles(0, side * 0.2, 0)
			)
		end
		block(
			parent,
			"ConchaListrada",
			V(2.2, 0.7, 1.6),
			origin + V(2, 0.4, 1),
			T.Ramps.Sand[5],
			CFrame.Angles(0, 0.4, 0),
			"wedge"
		)
	elseif style == "Sand" then
		block(parent, "PedestalDeAreia", V(5, 1.2, 4), origin + V(0, 0.6, 0), ramp[3])
		block(
			parent,
			"EstelaInclinada",
			V(1.8, 5, 1.8),
			origin + V(0, 3.1, 0),
			ramp[4],
			CFrame.Angles(0, index * 0.4, 0.1)
		)
		block(parent, "FaixaDeEstela", V(2, 0.4, 2), origin + V(0, 4, 0), ramp[1], CFrame.Angles(0, index * 0.4, 0.1))
	elseif style == "Sky" then
		for tier = 1, 3 do
			local c = block(
				parent,
				"NuvemEscalonada",
				V(6 - tier, 1.4, 4.5 - tier * 0.4),
				origin + V(tier * 0.5, 1.5 + tier * 0.6, 0),
				ramp[tier + 2]
			)
			motion(c, "cloud", index * 0.7 + tier)
		end
		block(
			parent,
			"CristalCeleste",
			V(1.4, 4, 1.4),
			origin + V(1, 4, 0),
			ramp[4],
			CFrame.Angles(0.2, 0.5, 0.3),
			"wedge"
		)
	else
		block(parent, "RaizTorcida", V(1.2, 5, 1.2), origin + V(0, 2.5, 0), ramp[1], CFrame.Angles(0.1, 0, 0.3))
		block(parent, "CogumeloBase", V(0.8, 2, 0.8), origin + V(1, 1, 0), ramp[3])
		block(
			parent,
			"CogumeloChapeu",
			V(3, 0.6, 2.5),
			origin + V(1, 2.3, 0),
			ramp[4],
			CFrame.Angles(0, math.pi / 4, 0)
		)
		local glow = block(parent, "LuzDeEsporo", V(0.3, 0.3, 0.3), origin + V(1.3, 3.2, 0), ramp[5])
		motion(glow, "spark", index * 0.9)
	end
end
function A.biome(parent, center, def)
	local root = Instance.new("Folder")
	root.Name = "Arte_" .. def.id
	root:SetAttribute("ArtDecor", true)
	root.Parent = parent
	local ramp = T.ramp(def.id)
	local style = T.Biomes[def.id]
	-- Rebordo de ladrilhos e pequenos pisos interrompidos deixam legíveis o centro e as entradas.
	for index = 1, 24 do
		local angle = index * math.pi / 12
		local edge = center
			+ V(math.cos(angle) * (Layout.RegionRadius - 4), 4.03, math.sin(angle) * (Layout.RegionRadius - 4))
		block(root, "BordaDeIlha", V(36, 0.18, 3), edge, ramp[4], CFrame.Angles(0, -angle + math.pi / 2, 0))
	end
	for index = 1, 20 do
		local angle = index * math.pi / 10 + 0.15
		local radius = 155 + (index % 3) * 85
		shrub(root, center + V(math.cos(angle) * radius, 4.08, math.sin(angle) * radius), ramp, style, index)
	end
	for index = 1, 64 do
		local angle = index * 2.399
		local radius = 90 + (index % 8) * 39
		local point = center + V(math.cos(angle) * radius, 4.08, math.sin(angle) * radius)
		if math.abs(point.X - center.X) > 7 then
			local grass = block(
				root,
				"DetalheDeSolo",
				V(0.3, style == "Sand" and 0.18 or 0.8, 1.2),
				point,
				ramp[index % 2 + 3],
				CFrame.Angles(0, angle, 0.12),
				"wedge"
			)
			if style == "Leaf" or style == "Veil" then
				motion(grass, "grass", index * 0.5)
			end
			if index % 4 == 0 then
				block(
					root,
					"Petala",
					V(0.4, 0.2, 0.4),
					point + V(0.4, 0.7, 0),
					style == "Leaf" and T.Ramps.Rose[4] or ramp[5]
				)
			end
		end
	end
	-- Vinheta do ponto de descoberta original: livros/placas decorativos, sem tocar no prompt.
	block(root, "PlacaDescoberta", V(5, 0.25, 2), center + V(24, 4.16, 3), ramp[1])
	for index = 1, 3 do
		block(root, "Inscricao", V(0.3, 0.05, 0.8), center + V(22.8 + index * 0.6, 4.33, 3), ramp[4])
	end
	local parts = 0
	for _, obj in root:GetDescendants() do
		if obj:IsA("BasePart") then
			parts += 1
		end
	end
	root:SetAttribute("PartCount", parts)
	assert(parts <= A.BudgetPerIsland, "Cenário acima do orçamento")
	return root
end
function A.build(parent)
	for _, def in I.List do
		A.biome(parent, I.pos(def.idx), def)
	end
	local ocean = Instance.new("Folder")
	ocean.Name = "ArteOceano"
	ocean.Parent = parent
	-- Linhas de espuma escalonadas são geométricas, sem textura filtrada ou emissor global.
	for index = 1, 42 do
		local angle = index * math.pi / 21
		local distance = Layout.RingRadius + Layout.RegionRadius + 100 + (index % 3) * 28
		local strip = block(
			ocean,
			"Espuma",
			V(7 + index % 4, 0.06, 0.6),
			V(math.cos(angle) * distance, -2.96, math.sin(angle) * distance),
			T.Ramps.Tidal[4],
			CFrame.Angles(0, -angle, 0)
		)
		strip.Transparency = 0.4
		motion(strip, "water", index * 0.3)
	end
end
function A.recolor(parent)
	for _, obj in parent:GetDescendants() do
		if obj:IsA("BasePart") then
			obj.Color = T.nearest(obj.Color)
		elseif obj:IsA("TextLabel") then
			obj.Font = T.Font
			obj.TextColor3 = T.Ink
			obj.TextStrokeColor3 = T.Panel
			obj.TextStrokeTransparency = 0.1
		end
	end
end
function A.camp(parent, center)
	local wood = T.Ramps.Sand
	local roof = T.Ramps.Tidal
	-- Dossel de telhas facetadas e beiral quente sobre o gazebo existente.
	for _, side in { -1, 1 } do
		block(
			parent,
			"TelhadoDePesquisa",
			V(8, 0.7, 16),
			center + V(-20 + side * 3.5, 14.4, -17),
			roof[3],
			CFrame.Angles(0, 0, -side * 0.25)
		)
		block(parent, "Beiral", V(1, 0.6, 16.4), center + V(-20 + side * 7, 13.5, -17), wood[4])
	end
	block(parent, "Cumeeira", V(0.7, 0.8, 16.7), center + V(-20, 15.5, -17), wood[5])
	for index = 1, 4 do
		block(
			parent,
			"AmostraDePesquisa",
			V(0.7, 0.15, 1),
			center + V(-23 + index * 1.2, 6.6, -17),
			T.Palette[10 + index * 3],
			CFrame.Angles(0, index * 0.2, 0)
		)
	end
	block(parent, "LivroAberto", V(2, 0.2, 1.5), center + V(-21, 6.7, -18), T.Ink, CFrame.Angles(0, -0.2, 0))
	block(parent, "Lombada", V(0.1, 0.24, 1.5), center + V(-21, 6.72, -18), wood[2], CFrame.Angles(0, -0.2, 0))
	for index = 1, 5 do
		local a = index * math.pi * 2 / 5
		local ripple = block(
			parent,
			"ReflexoDaFonte",
			V(1, 0.05, 0.2),
			center + V(22 + math.cos(a) * 1.5, 6.22, -16 + math.sin(a) * 1.5),
			T.Ramps.Tidal[5],
			CFrame.Angles(0, -a, 0)
		)
		motion(ripple, "water", index)
	end
	A.recolor(parent)
end
function A.researcher(parent, base)
	local skin = T.Ramps.Rose
	local cloth = T.Ramps.Tidal
	local wood = T.Ramps.Sand
	-- Rosto original: olhos com sobrancelha, mecha lateral, óculos e sorriso curto.
	block(parent, "PlanoDoRosto", V(1.45, 1.25, 0.18), base + V(0, 4.65, 0.73), skin[4])
	for _, side in { -1, 1 } do
		block(parent, "Lente", V(0.62, 0.44, 0.09), base + V(side * 0.4, 4.78, 0.86), cloth[1])
		block(parent, "Olho", V(0.14, 0.19, 0.08), base + V(side * 0.4, 4.77, 0.93), T.Ink)
		block(
			parent,
			"Sobrancelha",
			V(0.42, 0.09, 0.08),
			base + V(side * 0.4, 5.1, 0.87),
			wood[1],
			CFrame.Angles(0, 0, side * 0.08)
		)
		block(parent, "Mao", V(0.55, 0.55, 0.55), base + V(side * 1.5, 1.65, 0), skin[4])
	end
	block(parent, "PonteDosOculos", V(0.23, 0.1, 0.09), base + V(0, 4.8, 0.87), cloth[1])
	block(parent, "Sorriso", V(0.3, 0.08, 0.08), base + V(0.09, 4.3, 0.86), skin[2], CFrame.Angles(0, 0, 0.08))
	block(parent, "Cabelo", V(1.9, 0.5, 1.8), base + V(0, 5.55, -0.03), wood[1])
	block(parent, "Mecha", V(0.45, 1.4, 0.3), base + V(-0.7, 5.0, 0.71), wood[2], CFrame.Angles(0, 0, -0.12))
	block(parent, "Gola", V(1.35, 0.3, 1.1), base + V(0, 3.9, 0), T.Ink)
	block(parent, "Bolso", V(0.65, 0.6, 0.14), base + V(-0.5, 2.8, 0.56), cloth[2])
	block(parent, "CadernoDeCampo", V(0.7, 0.9, 0.15), base + V(-0.5, 3, 0.65), wood[4], CFrame.Angles(0, 0, 0.1))
	block(parent, "Cinto", V(2.3, 0.22, 1.1), base + V(0, 1.8, 0), wood[1])
	block(parent, "Fivela", V(0.36, 0.3, 0.1), base + V(0, 1.8, 0.62), wood[4])
	block(parent, "Mochila", V(1.65, 1.8, 0.7), base + V(0, 2.9, -0.8), wood[2])
	local shadow = block(parent, "SombraDaMaia", V(3.2, 0.025, 2), base + V(0.4, 0.03, 0.3), T.Shadow)
	shadow.Transparency = 0.35
	shadow.CastShadow = false
	A.recolor(parent)
end
function A.plot(parent, center)
	local ramp = T.Ramps.Leaf
	for _, side in { -1, 1 } do
		for index = 1, 5 do
			block(
				parent,
				"LadrilhoDeJardim",
				V(3, 0.12, 3),
				center + V(side * 6, 2.12, -45 + index * 18),
				T.Ramps.Sand[4],
				CFrame.Angles(0, math.pi / 4, 0)
			)
		end
		block(parent, "MolduraDoPortal", V(1.1, 10, 2.7), center + V(side * 4.5, 6.5, 61), T.Ramps.Sand[4])
		block(parent, "Canteiro", V(7, 0.6, 5), center + V(side * 58, 2.4, 52), ramp[1])
		for index = 1, 3 do
			block(
				parent,
				"FolhaDeCanteiro",
				V(1.4, 1.2, 1.4),
				center + V(side * 58 + (index - 2) * 1.6, 3.1, 52),
				ramp[index + 1],
				CFrame.Angles(0, index * 0.5, 0),
				"wedge"
			)
		end
	end
	block(parent, "LintelDoPortal", V(11, 1, 2.7), center + V(0, 12, 61), T.Ramps.Sand[5])
	A.recolor(parent)
end
function A.habitat(parent, position, id)
	local ramp = T.ramp(id)
	for _, side in { -1, 1 } do
		block(parent, "RebordoHabitat", V(28, 0.18, 0.6), position + V(0, 0.45, side * 13.5), ramp[2])
		block(parent, "RebordoHabitat", V(0.6, 0.18, 26), position + V(side * 13.5, 0.45, 0), ramp[2])
		block(
			parent,
			"TalheDeCanto",
			V(2, 0.22, 2),
			position + V(side * 12, 0.46, side * 12),
			ramp[4],
			CFrame.Angles(0, math.pi / 4, 0)
		)
	end
	block(parent, "SeloDeHabitat", V(4, 0.08, 4), position + V(0, 0.46, -10), ramp[4], CFrame.Angles(0, math.pi / 4, 0))
	A.recolor(parent)
end
return A
