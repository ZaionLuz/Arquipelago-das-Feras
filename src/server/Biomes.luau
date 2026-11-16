--!nonstrict
-- BIOMES & WORLD SYSTEM - Biome definitions, massive island support, dynamic weather
-- Deterministic decoration; center and bridge entries remain clear.

local Data = require(script.Parent.DataService)
local Progression = require(game:GetService("ReplicatedStorage").Shared.Progression)
local I = require(game:GetService("ReplicatedStorage").Shared.Islands)
local T = require(game:GetService("ReplicatedStorage").Shared.ArtTokens)
local B = {}
local V = Vector3.new

-- Weather types per biome
B.WeatherTypes = {
	Rain = "Rain",
	Ash = "Ash",
	Snow = "Snow",
	Storm = "Storm",
	Aurora = "Aurora",
	VoidFog = "VoidFog",
	Clear = "Clear",
}

-- Biome weather affinities (which weather occurs naturally)
B.BiomeWeather = {
	Alvorecer = { B.WeatherTypes.Rain, B.WeatherTypes.Clear },
	Brasa = { B.WeatherTypes.Ash, B.WeatherTypes.Storm, B.WeatherTypes.Clear },
	Recife = { B.WeatherTypes.Rain, B.WeatherTypes.Storm, B.WeatherTypes.Clear },
	Floresta = { B.WeatherTypes.Rain, B.WeatherTypes.Clear },
	Dunas = { B.WeatherTypes.Storm, B.WeatherTypes.Clear },
	Picos = { B.WeatherTypes.Snow, B.WeatherTypes.Storm, B.WeatherTypes.Aurora, B.WeatherTypes.Clear },
	Pantano = { B.WeatherTypes.VoidFog, B.WeatherTypes.Rain, B.WeatherTypes.Clear },
	Inverno = { B.WeatherTypes.Snow, B.WeatherTypes.Storm, B.WeatherTypes.Aurora, B.WeatherTypes.Clear },
	Trovao = { B.WeatherTypes.Storm, B.WeatherTypes.Rain, B.WeatherTypes.Clear },
	Celestial = { B.WeatherTypes.Aurora, B.WeatherTypes.Clear },
	Forja = { B.WeatherTypes.Ash, B.WeatherTypes.Storm, B.WeatherTypes.Clear },
	Geoda = { B.WeatherTypes.Clear, B.WeatherTypes.Aurora },
	Vazio = { B.WeatherTypes.VoidFog, B.WeatherTypes.Clear },
}

-- Day/night cycle modifiers
B.TimeModifiers = {
	Dawn = { spawnRate = 1.2, rareChance = 1.5, evolutionBonus = 1.1 }, -- 5-7
	Day = { spawnRate = 1.0, rareChance = 1.0, evolutionBonus = 1.0 }, -- 7-18
	Dusk = { spawnRate = 1.3, rareChance = 1.8, evolutionBonus = 1.2 }, -- 18-20
	Night = { spawnRate = 0.8, rareChance = 2.0, evolutionBonus = 1.5 }, -- 20-5
}

function B.decorate(parent, origin, def)
	local folder = Instance.new("Folder")
	folder.Name = "Biome_" .. def.id
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

	-- Main biome ring (10 landmarks)
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
			local pillar = part(Enum.PartType.Cylinder, V(7, 3, 3), pos + V(0, 3.5, 0), def.accent, Enum.Material.Sandstone)
			pillar.CFrame *= CFrame.Angles(0, 0, math.pi / 2 + 0.1)
			part(Enum.PartType.Block, V(5, 1, 4), pos + V(0, 7, 0), def.ground, Enum.Material.Sandstone)
		elseif def.id == "Picos" then
			local peak = part(Enum.PartType.Block, V(6, 12, 6), pos + V(0, 6, 0), def.ground, Enum.Material.Slate)
			peak.CFrame *= CFrame.Angles(0.15, 0, 0.1)
			crystal(pos + V(0, 14, 0), def.accent)
		elseif def.id == "Inverno" then
			local iceSpire = part(Enum.PartType.Block, V(5, 15, 5), pos + V(0, 7.5, 0), Color3.fromRGB(180, 220, 255), Enum.Material.Ice)
			iceSpire.CFrame *= CFrame.Angles(0.1, 0, 0.05)
			crystal(pos + V(0, 16, 0), def.accent)
		elseif def.id == "Trovao" then
			local conductor = part(Enum.PartType.Cylinder, V(3, 18, 3), pos + V(0, 9, 0), Color3.fromRGB(80, 80, 100), Enum.Material.Metal)
			conductor.CFrame *= CFrame.Angles(0.05, 0, 0)
			crystal(pos + V(0, 20, 0), def.accent)
		elseif def.id == "Celestial" then
			local floatIsle = part(Enum.PartType.Ball, V(8, 4, 8), pos + V(0, 12, 0), def.ground, Enum.Material.SmoothPlastic)
			floatIsle.CFrame *= CFrame.Angles(0, 0, 0.2)
			crystal(pos + V(0, 18, 0), def.accent)
		elseif def.id == "Forja" then
			local anvil = part(Enum.PartType.Block, V(10, 3, 8), pos + V(0, 2, 0), Color3.fromRGB(60, 50, 50), Enum.Material.Metal)
			part(Enum.PartType.Cylinder, V(2, 8, 2), pos + V(4, 6, 0), def.accent, Enum.Material.Neon).CFrame *= CFrame.Angles(0, 0, math.pi/2)
		elseif def.id == "Geoda" then
			for j = 1, 4 do
				local a = j * math.pi / 2
				crystal(pos + V(math.cos(a) * 3, 6 + j, math.sin(a) * 3), def.accent)
			end
		elseif def.id == "Vazio" then
			local voidRing = part(Enum.PartType.Ball, V(12, 0.5, 12), pos + V(0, 3, 0), Color3.fromRGB(30, 10, 50), Enum.Material.Glass)
			voidRing.Transparency = 0.3
			crystal(pos + V(0, 8, 0), def.accent)
		else
			part(Enum.PartType.Ball, V(10, 3, 7), pos + V(0, 5, 0), Color3.fromRGB(235, 243, 255))
			crystal(pos + V(0, 8, 0), def.accent)
		end
	end

	-- Major island landmark (background composition, doesn't block center or bridges)
	if def.id == "Brasa" then
		part(Enum.PartType.Ball, V(16, 14, 16), V(0, 7, -27), Color3.fromRGB(46, 35, 39), Enum.Material.Basalt)
		part(Enum.PartType.Cylinder, V(0.5, 8, 8), V(0, 13, -27), def.accent, Enum.Material.Neon).CFrame *= CFrame.Angles(0, 0, math.pi / 2)
	elseif def.id == "Recife" then
		part(Enum.PartType.Ball, V(13, 9, 10), V(0, 8, -28), def.ground, Enum.Material.Slate)
		local fall = part(Enum.PartType.Block, V(5, 8, 0.3), V(0, 8, -22.9), def.accent, Enum.Material.Glass)
		fall.Transparency = 0.35
	elseif def.id == "Floresta" or def.id == "Alvorecer" then
		local tree = part(Enum.PartType.Cylinder, V(18, 4, 4), V(0, 13, -26), Color3.fromRGB(83, 62, 45), Enum.Material.Wood)
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
	elseif def.id == "Picos" then
		part(Enum.PartType.Block, V(22, 18, 14), V(0, 12, -28), Color3.fromRGB(180, 200, 235), Enum.Material.Slate)
		for _, side in { -1, 1 } do
			crystal(V(side * 8, 20, -26), def.accent)
		end
	elseif def.id == "Inverno" then
		part(Enum.PartType.Block, V(20, 20, 16), V(0, 14, -28), Color3.fromRGB(170, 210, 255), Enum.Material.Ice)
		part(Enum.PartType.Ball, V(8, 8, 8), V(0, 24, -28), def.accent, Enum.Material.Neon).Transparency = 0.2
	elseif def.id == "Trovao" then
		part(Enum.PartType.Cylinder, V(1, 25, 1), V(0, 14, -28), Color3.fromRGB(100, 100, 130), Enum.Material.Metal)
		for _, side in { -1, 1 } do
			part(Enum.PartType.Block, V(12, 1, 8), V(side * 10, 6, -28), def.accent, Enum.Material.Neon).Transparency = 0.3
		end
	elseif def.id == "Celestial" then
		part(Enum.PartType.Ball, V(15, 8, 15), V(0, 18, -28), def.ground, Enum.Material.SmoothPlastic)
		part(Enum.PartType.Ball, V(6, 6, 6), V(0, 24, -28), def.accent, Enum.Material.Neon).Transparency = 0.1
	elseif def.id == "Forja" then
		part(Enum.PartType.Block, V(18, 12, 14), V(0, 8, -28), Color3.fromRGB(70, 55, 50), Enum.Material.Metal)
		part(Enum.PartType.Cylinder, V(4, 16, 4), V(0, 16, -28), def.accent, Enum.Material.Neon).Transparency = 0.2
	elseif def.id == "Geoda" then
		part(Enum.PartType.Ball, V(14, 14, 14), V(0, 10, -28), def.ground, Enum.Material.Glass)
		part(Enum.PartType.Ball, V(10, 10, 10), V(0, 10, -28), def.accent, Enum.Material.Neon).Transparency = 0.4
	elseif def.id == "Vazio" then
		part(Enum.PartType.Ball, V(18, 2, 18), V(0, 5, -28), Color3.fromRGB(20, 5, 40), Enum.Material.Glass)
		part(Enum.PartType.Ball, V(10, 10, 10), V(0, 10, -28), def.accent, Enum.Material.Neon).Transparency = 0.5
	else
		for _, side in { -1, 1 } do
			crystal(V(side * 7, 12, -26), def.accent)
		end
		part(Enum.PartType.Ball, V(22, 4, 14), V(0, 16, -26), Color3.fromRGB(236, 243, 255))
	end

	-- Exploration marker and radial path: all below feet or no collision
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
	prompt.ObjectText = def.name .. " \194\183 " .. def.desc
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
		player:SetAttribute("BiomeVisited", def.id)
		if notice then
			notice:FireClient(player, "Descoberta em " .. def.name .. " \194\183 +1 ess\195\170ncia de " .. def.el)
		end
	end)

	-- Cave entrance marker (visual only, actual caves handled by IslandService)
	local caveEntrance = part(Enum.PartType.Ball, V(6, 4, 6), V(-24, 5, 0), Color3.fromRGB(40, 35, 40), Enum.Material.Slate)
	caveEntrance.Name = "CaveEntrance"
	local cavePrompt = Instance.new("ProximityPrompt")
	cavePrompt.ActionText = "Entrar na caverna"
	cavePrompt.ObjectText = "Caverna de " .. def.name .. " \194\183 N\195\173vel " .. (I.ById[def.id].minLevel + 5)
	cavePrompt.HoldDuration = 0.5
	cavePrompt.MaxActivationDistance = 10
	cavePrompt.Parent = caveEntrance
	cavePrompt.Triggered:Connect(function(player)
		require(script.Parent.IslandService).enterCave(player, def.id)
	end)

	return folder
end

-- Get current weather for a biome based on time and RNG
function B.getCurrentWeather(biomeId, seed)
	local weathers = B.BiomeWeather[biomeId] or { B.WeatherTypes.Clear }
	local rng = Random.new(seed or os.time())
	return weathers[rng:NextInteger(1, #weathers)]
end

-- Get time of day modifier
function B.getTimeModifier()
	local hour = game:GetService("Lighting").ClockTime
	if hour >= 5 and hour < 7 then return B.TimeModifiers.Dawn
	elseif hour >= 7 and hour < 18 then return B.TimeModifiers.Day
	elseif hour >= 18 and hour < 20 then return B.TimeModifiers.Dusk
	else return B.TimeModifiers.Night end
end

-- Calculate spawn rate modifier for a biome
function B.getSpawnModifier(biomeId)
	local weather = B.getCurrentWeather(biomeId)
	local timeMod = B.getTimeModifier()
	local weatherMod = 1.0

	if weather == B.WeatherTypes.Rain then weatherMod = 1.2
	elseif weather == B.WeatherTypes.Storm then weatherMod = 1.5
	elseif weather == B.WeatherTypes.Ash then weatherMod = 0.8
	elseif weather == B.WeatherTypes.Snow then weatherMod = 0.9
	elseif weather == B.WeatherTypes.VoidFog then weatherMod = 0.7
	elseif weather == B.WeatherTypes.Aurora then weatherMod = 1.3 end

	return timeMod.spawnRate * weatherMod
end

-- Calculate rare encounter chance modifier
function B.getRareModifier(biomeId)
	local weather = B.getCurrentWeather(biomeId)
	local timeMod = B.getTimeModifier()
	local weatherMod = 1.0

	if weather == B.WeatherTypes.Storm then weatherMod = 1.5
	elseif weather == B.WeatherTypes.Aurora then weatherMod = 2.0
	elseif weather == B.WeatherTypes.VoidFog then weatherMod = 1.8
	elseif weather == B.WeatherTypes.Ash then weatherMod = 1.3 end

	return timeMod.rareChance * weatherMod
end

-- Get evolution condition bonus
function B.getEvolutionBonus(biomeId)
	local weather = B.getCurrentWeather(biomeId)
	local timeMod = B.getTimeModifier()
	local weatherMod = 1.0

	if weather == B.WeatherTypes.Aurora then weatherMod = 1.5
	elseif weather == B.WeatherTypes.Storm then weatherMod = 1.2
	elseif weather == B.WeatherTypes.VoidFog then weatherMod = 1.3 end

	return timeMod.evolutionBonus * weatherMod
end

return B