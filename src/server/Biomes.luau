--!nonstrict
-- Decoração determinística; centro e entradas das pontes permanecem livres.
local Data = require(script.Parent.DataService)
local Progression = require(game:GetService("ReplicatedStorage").Shared.Progression)
local B = {}
local V = Vector3.new
function B.decorate(parent, origin, def)
	local folder = Instance.new("Folder")
	folder.Name = "Bioma_" .. def.id
	folder.Parent = parent
	local rng = Random.new(100 + def.idx)
	local function part(shape, size, pos, color, material, solid)
		local p = Instance.new("Part")
		p.Shape = shape
		p.Size = size
		p.Position = origin + pos
		p.Anchored = true
		p.CanCollide = solid == true
		p.CanTouch = false
		p.Color = color
		p.Material = material or Enum.Material.SmoothPlastic
		p.Parent = folder
		return p
	end
	local function crystal(pos, color)
		local p = part(Enum.PartType.Block, V(1.8, 5, 1.8), pos, color, Enum.Material.Neon)
		p.CFrame *= CFrame.Angles(0.2, 0, 0.4)
	end
	for i = 1, 10 do
		local angle = i * math.pi * 2 / 10 + rng:NextNumber(-0.1, 0.1)
		local radius = rng:NextNumber(27, 31)
		local pos = V(math.cos(angle) * radius, 4, math.sin(angle) * radius)
		if def.id == "Brasa" then
			part(Enum.PartType.Ball, V(7, 6, 7), pos + V(0, 1, 0), Color3.fromRGB(40, 35, 40), Enum.Material.Basalt)
			crystal(pos + V(0, 4, 0), def.accent)
		elseif def.id == "Recife" then
			for j = 1, 3 do
				local coral = part(
					Enum.PartType.Cylinder,
					V(4, 0.7, 0.7),
					pos + V(j - 2, 2 + j * 0.4, 0),
					j % 2 == 0 and def.accent or Color3.fromRGB(240, 145, 180)
				)
				coral.CFrame *= CFrame.Angles(0, 0, math.pi / 2 + (j - 2) * 0.3)
			end
			crystal(pos + V(0, 5, 0), def.accent)
		elseif def.id == "Alvorecer" or def.id == "Floresta" or def.id == "Pantano" then
			local shadow = def.id == "Pantano"
			local trunk = part(
				Enum.PartType.Cylinder,
				V(10, 2, 2),
				pos + V(0, 5, 0),
				Color3.fromRGB(80, 57, 55),
				Enum.Material.Wood
			)
			trunk.CFrame *= CFrame.Angles(0, 0, math.pi / 2 + (shadow and 0.25 or 0))
			part(
				Enum.PartType.Ball,
				V(9, 7, 8),
				pos + V(1, 11, 0),
				shadow and Color3.fromRGB(60, 43, 82) or Color3.fromRGB(52, 120, 77),
				Enum.Material.Grass
			)
			part(Enum.PartType.Ball, V(2, 1, 2), pos + V(3, 1, 2), def.accent, Enum.Material.Neon)
		elseif def.id == "Dunas" then
			local pillar =
				part(Enum.PartType.Cylinder, V(7, 3, 3), pos + V(0, 3.5, 0), def.accent, Enum.Material.Sandstone)
			pillar.CFrame *= CFrame.Angles(0, 0, math.pi / 2 + 0.1)
			part(Enum.PartType.Block, V(5, 1, 4), pos + V(0, 7, 0), def.ground, Enum.Material.Sandstone)
		else
			part(Enum.PartType.Ball, V(10, 3, 7), pos + V(0, 5, 0), Color3.fromRGB(235, 243, 255))
			crystal(pos + V(0, 8, 0), def.accent)
		end
	end
	-- Marco maior por ilha: composição ao fundo, sem bloquear o centro ou as pontes.
	if def.id == "Brasa" then
		part(Enum.PartType.Ball, V(16, 14, 16), V(0, 7, -27), Color3.fromRGB(46, 35, 39), Enum.Material.Basalt)
		part(Enum.PartType.Cylinder, V(0.5, 8, 8), V(0, 13, -27), def.accent, Enum.Material.Neon).CFrame *= CFrame.Angles(
			0,
			0,
			math.pi / 2
		)
	elseif def.id == "Recife" then
		part(Enum.PartType.Ball, V(13, 9, 10), V(0, 8, -28), def.ground, Enum.Material.Slate)
		local fall = part(Enum.PartType.Block, V(5, 8, 0.3), V(0, 8, -22.9), def.accent, Enum.Material.Glass)
		fall.Transparency = 0.35
	elseif def.id == "Floresta" or def.id == "Alvorecer" then
		local tree =
			part(Enum.PartType.Cylinder, V(18, 4, 4), V(0, 13, -26), Color3.fromRGB(83, 62, 45), Enum.Material.Wood)
		tree.CFrame *= CFrame.Angles(0, 0, math.pi / 2)
		part(Enum.PartType.Ball, V(19, 10, 16), V(0, 23, -26), Color3.fromRGB(67, 143, 96), Enum.Material.Grass)
	elseif def.id == "Dunas" or def.id == "Pantano" then
		for _, side in { -1, 1 } do
			part(Enum.PartType.Block, V(3, 12, 3), V(side * 6, 10, -25), def.ground, Enum.Material.Slate)
		end
		part(Enum.PartType.Block, V(16, 3, 4), V(0, 16, -25), def.accent, Enum.Material.Slate)
		if def.id == "Pantano" then
			local portal = part(Enum.PartType.Ball, V(7, 9, 0.3), V(0, 9, -25), def.accent, Enum.Material.Neon)
			portal.Transparency = 0.45
		end
	else
		for _, side in { -1, 1 } do
			crystal(V(side * 7, 12, -26), def.accent)
		end
		part(Enum.PartType.Ball, V(22, 4, 14), V(0, 16, -26), Color3.fromRGB(236, 243, 255))
	end
	-- Marco de exploração e caminho radial: tudo abaixo dos pés ou sem colisão.
	local _path = part(
		Enum.PartType.Block,
		V(8, 0.15, 58),
		V(0, 4.1, 0),
		def.ground:Lerp(Color3.new(1, 1, 1), 0.2),
		Enum.Material.Cobblestone
	)
	local stone = part(Enum.PartType.Ball, V(7, 3, 7), V(24, 5, 0), def.ground, Enum.Material.Slate)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Conhecer bioma"
	prompt.ObjectText = def.name .. " • " .. def.desc
	prompt.HoldDuration = 0
	prompt.MaxActivationDistance = 12
	prompt.Parent = stone
	prompt.Triggered:Connect(function(player)
		local ch = player.Character
		local root = ch and ch:FindFirstChild("HumanoidRootPart")
		local data = Data.get(player)
		if not data or not root or (root.Position - stone.Position).Magnitude >= 16 or not data.unlocked[def.id] then
			return
		end
		if not require(script.Parent.RegionService).requireCurrent(player, def.id, "encounter").ok then
			return
		end
		if require(script.Parent.EncounterService).active(player) then
			return
		end
		local notice = game:GetService("ReplicatedStorage"):FindFirstChild("WildNotice")
		if (data.gatherAt[def.id] or 0) > os.time() then
			if notice then
				notice:FireClient(player, "Este ponto se recupera em " .. (data.gatherAt[def.id] - os.time()) .. "s")
			end
			return
		end
		data.gatherAt[def.id] = os.time() + 120
		data.materials[def.el] = math.min(10000, (data.materials[def.el] or 0) + 1)
		if not data.visited[def.id] then
			data.visited[def.id] = true
			data.gold += 30
			data.stats.explore = (data.stats.explore or 0) + 1
			Progression.award(data, 60)
		end
		player:SetAttribute("BiomaVisitado", def.id)
		if notice then
			notice:FireClient(player, "Descoberta em " .. def.name .. " • +1 essência de " .. def.el)
		end
	end)
end
return B
