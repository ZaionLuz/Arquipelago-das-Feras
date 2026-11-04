--!nonstrict
-- Superfícies de exploração contínuas. Os níveis descrevem perigo, nunca portões.
local RS = game:GetService("ReplicatedStorage")
local Layout = require(RS.Shared.WorldLayout)
local Islands = require(RS.Shared.Islands)
local Tokens = require(RS.Shared.ArtTokens)
local Bands = require(RS.Shared.LevelBands)
local E = { Budget = 850 }
local V = Vector3.new
local function part(parent, name, size, cf, color, solid, kind)
	local p = Instance.new(kind == "wedge" and "WedgePart" or "Part")
	p.Name = name
	p.Size = size
	p.CFrame = cf
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = solid == true
	p.CanTouch = false
	p.CanQuery = solid == true
	p.CastShadow = size.Magnitude > 12
	p.Parent = parent
	if kind == "cylinder" then
		p.Shape = Enum.PartType.Cylinder
	end
	return p
end
local function sign(parent, point, def)
	local ramp = Tokens.ramp(def.id)
	part(parent, "PosteDeTrilha", V(2, 10, 2), CFrame.new(point + V(0, 5, 0)), ramp[2], false)
	local board = part(parent, "PlacaDeTrilha", V(15, 5, 0.6), CFrame.new(point + V(0, 10, 0)), Tokens.Panel, false)
	local gui = Instance.new("BillboardGui")
	gui.Name = "Indicacao"
	gui.Size = UDim2.fromOffset(250, 68)
	gui.StudsOffset = V(0, 3, 0)
	gui.MaxDistance = 120
	gui.Parent = board
	local text = Instance.new("TextLabel")
	text.Size = UDim2.fromScale(1, 1)
	text.BackgroundTransparency = 0.12
	text.BackgroundColor3 = Tokens.Panel
	text.TextColor3 = Tokens.Ink
	text.Font = Tokens.Font
	text.TextSize = 14
	text.TextWrapped = true
	local band = Bands.ById[def.id]
	text.Text = def.name .. "\nTrilha livre · Feras Nv. " .. band.min .. "–" .. band.max
	text.Parent = gui
end
function E.build(parent)
	local root = Instance.new("Folder")
	root.Name = "TerritoriosExploraveis"
	root.Parent = parent
	for _, def in Islands.List do
		local center = Islands.pos(def.idx)
		local ramp = Tokens.ramp(def.id)
		local region = Instance.new("Model")
		region.Name = def.id
		region:SetAttribute("Region", def.id)
		region:SetAttribute("Radius", Layout.RegionRadius)
		region.Parent = root
		local base = part(
			region,
			"SoloRegional",
			V(8, Layout.RegionRadius * 2, Layout.RegionRadius * 2),
			CFrame.new(center) * CFrame.Angles(0, 0, math.pi / 2),
			ramp[3],
			true,
			"cylinder"
		)
		base:SetAttribute("Walkable", true)
		base:SetAttribute("SurfaceY", Layout.SurfaceY)
		-- Trilhas radiais não criam paredes: terreno principal continua inteiramente caminhável.
		for ray = 1, 6 do
			local angle = ray * math.pi / 3
			local dir = V(math.cos(angle), 0, math.sin(angle))
			local length = Layout.RegionRadius - 58
			local cf = CFrame.lookAt(
				center + dir * (length * 0.5) + V(0, 4.04, 0),
				center + dir * (length * 0.5 + 1) + V(0, 4.04, 0)
			)
			part(region, "TrilhaRadial", V(34, 0.08, length), cf, ramp[4], false)
		end
		-- Três destinos elevados: piso sólido, rampas largas, nada depende de salto especial.
		for terrace = 1, 3 do
			local angle = (terrace - 1) * math.pi * 2 / 3
			local dir = V(math.cos(angle), 0, math.sin(angle))
			local offset = dir * 280
			local height = 4 + terrace * 4
			local plateauCenter = center + offset + V(0, 4 + height * 0.5, 0)
			local plateau = part(
				region,
				"Mirante" .. terrace,
				V(height, 112, 112),
				CFrame.new(plateauCenter) * CFrame.Angles(0, 0, math.pi / 2),
				ramp[terrace % 2 + 2],
				true,
				"cylinder"
			)
			plateau:SetAttribute("Walkable", true)
			plateau:SetAttribute("SurfaceY", Layout.SurfaceY + height)
			local rampCenter = center + offset - dir * 112 + V(0, 4 + height * 0.5, 0)
			local slope = part(
				region,
				"RampaDoMirante" .. terrace,
				V(56, height, 128),
				CFrame.lookAt(rampCenter, rampCenter - dir),
				ramp[3],
				true,
				"wedge"
			)
			slope:SetAttribute("Walkable", true)
			slope:SetAttribute("SlopeRise", height)
			slope:SetAttribute("SlopeRun", 128)
			-- Composição do destino: ruína aberta, mesas e pedras sem fechar o terraço.
			local top = center + offset + V(0, 4 + height, 0)
			for _, side in { -1, 1 } do
				part(region, "ColunaDoMirante", V(5, 14, 5), CFrame.new(top + V(side * 26, 7, -20)), ramp[2], true)
				part(region, "Capitel", V(8, 2, 8), CFrame.new(top + V(side * 26, 15, -20)), ramp[4], false)
			end
			part(region, "MesaDeCampo", V(12, 2, 7), CFrame.new(top + V(0, 3, -23)), ramp[2], false)
			for stone = 1, 4 do
				local a = stone * math.pi / 2
				part(
					region,
					"PedraDeBorda",
					V(8, 5, 6),
					CFrame.new(top + V(math.cos(a) * 42, 2, math.sin(a) * 42)) * CFrame.Angles(0, a, 0.1),
					ramp[2],
					false,
					"wedge"
				)
			end
		end
		-- Anel de marcos de navegação distante do acampamento inicial.
		for marker = 1, 8 do
			local a = marker * math.pi / 4 + 0.25
			local pos = center + V(math.cos(a) * 360, 4, math.sin(a) * 360)
			part(region, "MarcoDeTrilha", V(3, 7, 3), CFrame.new(pos + V(0, 3.5, 0)), ramp[2], false)
			part(region, "FitaDoMarco", V(4, 0.8, 4), CFrame.new(pos + V(0, 6, 0)), ramp[4], false)
		end
		region:SetAttribute("WalkableTerraces", 3)
	end
	local routes = Instance.new("Folder")
	routes.Name = "RotasLivres"
	routes.Parent = root
	for index = 1, #Islands.List do
		local road = Layout.route(index)
		local a, b = road.a, road.b
		local mid = (a + b) * 0.5
		local direction = (b - a).Unit
		local floor = part(
			routes,
			"Rota" .. index,
			V(road.width, 8, (b - a).Magnitude),
			CFrame.lookAt(mid, mid + direction),
			Tokens.Ramps.Sand[3],
			true
		)
		floor:SetAttribute("Walkable", true)
		floor:SetAttribute("FromRegion", road.from)
		floor:SetAttribute("ToRegion", road.to)
		floor:SetAttribute("SurfaceY", Layout.SurfaceY)
		-- Borda baixa de pedra deixa a rota legível sem criar um portão de progressão.
		local right = V(direction.Z, 0, -direction.X)
		for _, side in { -1, 1 } do
			for segment = 1, 4 do
				local t = (segment - 0.5) / 4
				local point = a:Lerp(b, t) + right * side * (road.width * 0.5 + 2)
				part(
					routes,
					"PedraLateral",
					V(3, 2, (b - a).Magnitude / 4 - 8),
					CFrame.lookAt(point + V(0, 5, 0), point + direction + V(0, 5, 0)),
					Tokens.Ramps.Metal[2],
					true
				)
			end
		end
		sign(routes, a - right * 47 + V(0, 4, 0), Islands.List[road.to])
		sign(routes, b + right * 47 + V(0, 4, 0), Islands.List[road.from])
	end
	local count = 0
	for _, p in root:GetDescendants() do
		if p:IsA("BasePart") then
			count += 1
		end
	end
	assert(count <= E.Budget, "Mundo excede orçamento de superfícies")
	root:SetAttribute("PartCount", count)
	root:SetAttribute("RegionDiameter", Layout.RegionRadius * 2)
	root:SetAttribute("RouteWidth", Layout.RouteWidth)
	return root
end
return E
