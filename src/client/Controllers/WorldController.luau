--!strict
-- WorldController.lua - Controlador do mundo (spawns, criaturas selvagens, zonas)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local TweenService = game:GetService("TweenService")

local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local MathUtil = require(ReplicatedStorage.Shared.Util.Math)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local WorldController = {}

-- Events
WorldController.OnCreatureSpawned = Signal.New()
WorldController.OnCreatureDespawned = Signal.New()
WorldController.OnZoneChanged = Signal.New()
WorldController.OnWeatherChanged = Signal.New()
WorldController.OnTimeOfDayChanged = Signal.New()

-- State
local SpawnedCreatures = {} :: {[string]: {Creature: Types.CreatureData, Model: Model, Position: Vector3, SpawnTime: number}}
local CurrentZone: Types.ZoneData?
local CurrentWeather: Types.WeatherType = "Clear"
local CurrentTimeOfDay: "Dawn" | "Day" | "Dusk" | "Night" = "Day"
local RenderDistance = 300
local DespawnDistance = 350

-- Island models
local IslandModels = {} :: {[string]: Model}
local IslandConfig = {}

-- Initialize
function WorldController.Initialize()
	print("[WorldController] Initializing...")

	-- Load island configurations
	WorldController.LoadIslandConfig()

	-- Load island models from ReplicatedStorage
	WorldController.LoadIslandModels()

	-- Setup time/weather cycle
	WorldController.StartTimeCycle()
	WorldController.StartWeatherCycle()

	-- Listen for spawn/despawn from server
	-- (Handled via RemoteClient in init.client.luau)

	print("[WorldController] Initialized")
end

-- Load island configuration (aligned with server Config.Zones)
function WorldController.LoadIslandConfig()
	IslandConfig = {
		StarterTown = {
			Id = "StarterTown",
			Name = "Vila Inicial",
			Biome = "Nature",
			Position = Vector3.new(0, 0, 0),
			Size = 80,
			SafeZone = true,
			LevelRange = {Min = 1, Max = 5},
		},
		FireForest = {
			Id = "FireForest",
			Name = "Floresta de Brasas",
			Biome = "Fire",
			Position = Vector3.new(300, 0, 0),
			Size = 100,
			LevelRange = {Min = 3, Max = 12},
		},
		WaterCaves = {
			Id = "WaterCaves",
			Name = "Cavernas Aquáticas",
			Biome = "Water",
			Position = Vector3.new(0, -20, 300),
			Size = 90,
			LevelRange = {Min = 5, Max = 15},
		},
		NaturePlains = {
			Id = "NaturePlains",
			Name = "Planícies Verdentes",
			Biome = "Nature",
			Position = Vector3.new(-300, 0, 0),
			Size = 110,
			LevelRange = {Min = 2, Max = 10},
		},
		EarthDesert = {
			Id = "EarthDesert",
			Name = "Deserto de Dunas",
			Biome = "Earth",
			Position = Vector3.new(0, 0, -300),
			Size = 100,
			LevelRange = {Min = 8, Max = 18},
		},
		AirPeaks = {
			Id = "AirPeaks",
			Name = "Picos Ventosos",
			Biome = "Air",
			Position = Vector3.new(200, 150, 200),
			Size = 80,
			LevelRange = {Min = 10, Max = 20},
		},
		ShadowRuins = {
			Id = "ShadowRuins",
			Name = "Ruínas Sombrias",
			Biome = "Shadow",
			Position = Vector3.new(-200, -20, -200),
			Size = 85,
			LevelRange = {Min = 12, Max = 22},
		},
		VolcanoIsle = {
			Id = "VolcanoIsle",
			Name = "Ilha Vulcânica",
			Biome = "Fire",
			Position = Vector3.new(350, 0, 350),
			Size = 60,
			LevelRange = {Min = 20, Max = 35},
		},
	}
end

-- Load island models from ReplicatedStorage.Assets.Islands
function WorldController.LoadIslandModels()
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	local islandsFolder = assets and assets:FindFirstChild("Islands")

	if not islandsFolder then
		warn("[WorldController] Assets.Islands folder not found in ReplicatedStorage!")
		warn("[WorldController] Import island FBX files and place them in ReplicatedStorage.Assets.Islands")
		WorldController.CreatePlaceholderIslands()
		return
	end

	for islandId, config in pairs(IslandConfig) do
		local islandModel = islandsFolder:FindFirstChild(islandId)
			or islandsFolder:FindFirstChild("Island_" .. islandId)
			or islandsFolder:FindFirstChild(islandId:lower())

		if islandModel then
			local clone = islandModel:Clone()
			clone.Name = islandId
			clone.Parent = Workspace

			-- Ensure primary part
			if not clone.PrimaryPart then
				local center = clone:FindFirstChild("IslandCenter")
					or clone:FindFirstChildWhichIsA("BasePart")
				if center then
					clone.PrimaryPart = center
				end
			end

			-- Position at island location
			if clone.PrimaryPart then
				clone:PivotTo(CFrame.new(config.Position))
			end

			-- Anchor all parts
			for _, part in ipairs(clone:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Anchored = true
				end
			end

			IslandModels[islandId] = clone
			print(`[WorldController] Loaded island model: {islandId}`)
		else
			warn(`[WorldController] Island model not found: {islandId}`)
			WorldController.CreatePlaceholderIsland(islandId, config)
		end
	end

	-- Load bridges
	WorldController.LoadBridges(islandsFolder)
end

function WorldController.LoadBridges(islandsFolder)
	local bridgesFolder = islandsFolder:FindFirstChild("Bridges")
	if not bridgesFolder then return end

	for _, bridgeModel in ipairs(bridgesFolder:GetChildren()) do
		if bridgeModel:IsA("Model") or bridgeModel:IsA("BasePart") then
			local clone = bridgeModel:Clone()
			clone.Name = bridgeModel.Name
			clone.Parent = Workspace

			if not clone.PrimaryPart and clone:IsA("Model") then
				clone.PrimaryPart = clone:FindFirstChildWhichIsA("BasePart")
			end

			for _, part in ipairs(clone:GetDescendants()) do
				if part:IsA("BasePart") then
					part.Anchored = true
					part.CanCollide = true
				end
			end

			IslandModels[bridgeModel.Name] = clone
			print(`[WorldController] Loaded bridge: {bridgeModel.Name}`)
		end
	end
end

-- Create placeholder islands if models not available
function WorldController.CreatePlaceholderIslands()
	for islandId, config in pairs(IslandConfig) do
		WorldController.CreatePlaceholderIsland(islandId, config)
	end
end

function WorldController.CreatePlaceholderIsland(islandId: string, config: any)
	local model = Instance.new("Model")
	model.Name = islandId
	model.Parent = Workspace

	-- Main terrain base
	local terrain = Instance.new("Part")
	terrain.Name = "Terrain"
	terrain.Size = Vector3.new(config.Size * 2, 5, config.Size * 2)
	terrain.Position = config.Position + Vector3.new(0, -2.5, 0)
	terrain.Anchored = true
	terrain.CanCollide = true
	terrain.Material = WorldController.GetBiomeMaterial(config.Biome)
	terrain.Color = WorldController.GetBiomeColor(config.Biome)
	terrain.Parent = model

	model.PrimaryPart = terrain

	-- Add some decorative elements
	WorldController.AddIslandProps(model, config)

	IslandModels[islandId] = model
	print(`[WorldController] Created placeholder island: {islandId}`)
end

function WorldController.GetBiomeMaterial(biome: string): Enum.Material
	local materials = {
		Nature = Enum.Material.Grass,
		Fire = Enum.Material.Basalt,
		Water = Enum.Material.Sand,
		Earth = Enum.Material.Sandstone,
		Air = Enum.Material.SmoothPlastic,
		Shadow = Enum.Material.Slate,
	}
	return materials[biome] or Enum.Material.Grass
end

function WorldController.GetBiomeColor(biome: string): Color3
	local colors = {
		Nature = Color3.fromRGB(60, 140, 60),
		Fire = Color3.fromRGB(80, 40, 30),
		Water = Color3.fromRGB(194, 178, 128),
		Earth = Color3.fromRGB(140, 120, 90),
		Air = Color3.fromRGB(220, 230, 255),
		Shadow = Color3.fromRGB(40, 30, 60),
	}
	return colors[biome] or Color3.fromRGB(100, 100, 100)
end

function WorldController.AddIslandProps(model: Model, config: any)
	local center = config.Position
	local count = 20

	for i = 1, count do
		local angle = math.random() * 2 * math.pi
		local dist = math.random(config.Size * 0.3, config.Size * 0.7)
		local pos = center + Vector3.new(math.cos(angle), 0, math.sin(angle)) * dist
		pos = pos + Vector3.new(0, 3, 0)

		local prop = Instance.new("Part")
		prop.Name = "Prop_" .. i
		prop.Size = Vector3.new(math.random(3, 8), math.random(5, 15), math.random(3, 8))
		prop.Position = pos
		prop.Anchored = true
		prop.CanCollide = false
		prop.Material = Enum.Material.Neon
		prop.Color = WorldController.GetBiomeAccentColor(config.Biome)
		prop.Parent = model
	end
end

function WorldController.GetBiomeAccentColor(biome: string): Color3
	local colors = {
		Nature = Color3.fromRGB(80, 200, 80),
		Fire = Color3.fromRGB(255, 100, 50),
		Water = Color3.fromRGB(50, 150, 255),
		Earth = Color3.fromRGB(180, 140, 80),
		Air = Color3.fromRGB(180, 200, 255),
		Shadow = Color3.fromRGB(120, 60, 180),
	}
	return colors[biome] or Color3.fromRGB(200, 200, 200)
end

-- Update loop
function WorldController.Update(deltaTime: number)
	-- Check despawn distances
	WorldController.CheckDespawns()

	-- Update creature animations
	WorldController.UpdateCreatureAnimations(deltaTime)

	-- Update time of day visuals
	WorldController.UpdateTimeVisuals(deltaTime)

	-- Check player zone
	WorldController.CheckPlayerZone()
end

function WorldController.CheckPlayerZone()
	local player = Players.LocalPlayer
	if not player.Character or not player.Character.PrimaryPart then return end

	WorldController.CheckZoneFromPosition(player.Character.PrimaryPart.Position)
end

-- Spawn a creature in the world
function WorldController.OnCreatureSpawned(spawnId: string, creature: Types.CreatureData, position: Vector3)
	print(`[WorldController] Creature spawned: {creature.SpeciesId} at {position}`)

	-- Load model
	local model = WorldController.LoadCreatureModel(creature)
	if not model then
		warn(`[WorldController] Failed to load model for {creature.SpeciesId}`)
		return
	end

	-- Position model
	model:PivotTo(CFrame.new(position))
	model.Parent = Workspace

	-- Add to tracking
	SpawnedCreatures[spawnId] = {
		Creature = creature,
		Model = model,
		Position = position,
		SpawnTime = tick(),
	}

	-- Play spawn animation
	WorldController.PlaySpawnAnimation(model)

	-- Add interaction
	WorldController.SetupCreatureInteraction(model, spawnId, creature)

	WorldController.OnCreatureSpawned:Fire(spawnId, creature, position)
end

function WorldController.LoadCreatureModel(creature: Types.CreatureData): Model?
	-- Try to load from ReplicatedStorage.Assets.Creatures
	local model = ReplicatedStorage:FindFirstChild("Assets")
		and ReplicatedStorage.Assets:FindFirstChild("Creatures")
		and ReplicatedStorage.Assets.Creatures:FindFirstChild(creature.SpeciesId)

	if not model then
		-- Create placeholder
		model = WorldController.CreatePlaceholderModel(creature)
	end

	return model:Clone()
end

function WorldController.CreatePlaceholderModel(creature: Types.CreatureData): Model
	local model = Instance.new("Model")
	model.Name = creature.SpeciesId

	-- Main body
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(3, 3, 3)
	body.Shape = Enum.PartType.Ball
	body.Anchored = true
	body.CanCollide = false
	body.Material = Enum.Material.Neon
	body.Color = WorldController.GetElementColor(creature.Element1)
	body.Parent = model

	model.PrimaryPart = body

	-- Name tag
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NameTag"
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.Adornee = body
	billboard.AlwaysOnTop = true
	billboard.Parent = model

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.5, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = creature.Nickname ~= "" and creature.Nickname or creature.SpeciesId
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.Parent = billboard

	local levelLabel = Instance.new("TextLabel")
	levelLabel.Size = UDim2.new(1, 0, 0.5, 0)
	levelLabel.Position = UDim2.new(0, 0, 0.5, 0)
	levelLabel.BackgroundTransparency = 1
	levelLabel.Text = `Lv.{creature.Level}`
	levelLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
	levelLabel.TextScaled = true
	levelLabel.Font = Enum.Font.GothamBold
	levelLabel.TextStrokeTransparency = 0
	levelLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	levelLabel.Parent = billboard

	-- Element icon
	local elementLabel = Instance.new("TextLabel")
	elementLabel.Size = UDim2.new(0, 30, 0, 30)
	elementLabel.Position = UDim2.new(1, -35, 0, 0)
	elementLabel.BackgroundColor3 = WorldController.GetElementColor(creature.Element1)
	elementLabel.BorderSizePixel = 0
	elementLabel.Text = Types.ElementIcons[creature.Element1] or "?"
	elementLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	elementLabel.TextScaled = true
	elementLabel.Font = Enum.Font.GothamBold
	elementLabel.Parent = billboard

	local elemCorner = Instance.new("UICorner")
	elemCorner.CornerRadius = UDim.new(1, 0)
	elemCorner.Parent = elementLabel

	-- Shiny effect
	if creature.IsShiny then
		local sparkles = Instance.new("ParticleEmitter")
		sparkles.Name = "ShinySparkles"
		sparkles.Color = ColorSequence.new(Color3.fromRGB(255, 255, 200))
		sparkles.Size = NumberSequence.new(0.3)
		sparkles.Lifetime = NumberRange.new(0.5, 1.5)
		sparkles.Rate = 25
		sparkles.Speed = NumberRange.new(2, 5)
		sparkles.SpreadAngle = Vector2.new(180, 180)
		sparkles.Parent = body

		-- Shiny tag
		local shinyTag = Instance.new("TextLabel")
		shinyTag.Size = UDim2.new(0, 60, 0, 20)
		shinyTag.Position = UDim2.new(0, -65, 0, 0)
		shinyTag.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
		shinyTag.BorderSizePixel = 0
		shinyTag.Text = "✨ SHINY"
		shinyTag.TextColor3 = Color3.fromRGB(50, 40, 0)
		shinyTag.TextScaled = true
		shinyTag.Font = Enum.Font.GothamBold
		shinyTag.Parent = billboard

		local shinyCorner = Instance.new("UICorner")
		shinyCorner.CornerRadius = UDim.new(0, 4)
		shinyCorner.Parent = shinyTag
	end

	return model
end

function WorldController.GetElementColor(element: Types.ElementType): Color3
	local colors = {
		Fire = Color3.fromRGB(255, 100, 50),
		Water = Color3.fromRGB(50, 150, 255),
		Nature = Color3.fromRGB(80, 200, 80),
		Earth = Color3.fromRGB(180, 140, 80),
		Air = Color3.fromRGB(180, 200, 255),
		Shadow = Color3.fromRGB(120, 60, 180),
		Light = Color3.fromRGB(255, 240, 180),
		Metal = Color3.fromRGB(180, 180, 200),
		Crystal = Color3.fromRGB(200, 220, 255),
	}
	return colors[element] or Color3.fromRGB(200, 200, 200)
end

function WorldController.PlaySpawnAnimation(model: Model)
	local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not primaryPart then return end

	-- Scale up from 0
	local originalSize = primaryPart.Size
	primaryPart.Size = Vector3.new(0.1, 0.1, 0.1)

	local tween = TweenService:Create(primaryPart, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = originalSize
	})
	tween:Play()

	-- Particle burst
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255))
	emitter.Size = NumberSequence.new(0.5, 2)
	emitter.Lifetime = NumberRange.new(0.5, 1)
	emitter.Rate = 0
	emitter.Speed = NumberRange.new(5, 15)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Parent = primaryPart
	emitter:Emit(20)

	task.delay(1, function()
		emitter:Destroy()
	end)
end

function WorldController.SetupCreatureInteraction(model: Model, spawnId: string, creature: Types.CreatureData)
	local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not primaryPart then return end

	-- Add click detector
	local clickDetector = Instance.new("ClickDetector")
	clickDetector.MaxActivationDistance = 15
	clickDetector.Parent = primaryPart

	clickDetector.MouseClick:Connect(function(player)
		if player == Players.LocalPlayer then
			WorldController.OnCreatureClicked(spawnId, creature)
		end
	end)

	-- Add proximity prompt for mobile
	local proximityPrompt = Instance.new("ProximityPrompt")
	proximityPrompt.ActionText = "Interagir"
	proximityPrompt.ObjectText = creature.SpeciesId
	proximityPrompt.MaxActivationDistance = 10
	proximityPrompt.KeyboardKeyCode = Enum.KeyCode.E
	proximityPrompt.Parent = primaryPart

	proximityPrompt.Triggered:Connect(function(player)
		if player == Players.LocalPlayer then
			WorldController.OnCreatureClicked(spawnId, creature)
		end
	end)
end

function WorldController.OnCreatureClicked(spawnId: string, creature: Types.CreatureData)
	-- Check if player wants to battle or capture
	-- This would open a radial menu or direct to battle
	print(`[WorldController] Clicked creature: {creature.SpeciesId} (Lv.{creature.Level})`)

	-- For now, start wild battle
	local remote = ReplicatedStorage:FindFirstChild("Remotes")
	local battleRemote = remote and remote:FindFirstChild("StartBattle")
	if battleRemote then
		battleRemote:InvokeServer("Wild", {
			SpawnId = spawnId,
			Creature = creature,
		})
	end
end

-- Despawn creature
function WorldController.OnCreatureDespawned(spawnId: string)
	local spawnData = SpawnedCreatures[spawnId]
	if not spawnData then return end

	print(`[WorldController] Creature despawned: {spawnId}`)

	-- Play despawn animation
	WorldController.PlayDespawnAnimation(spawnData.Model)

	task.delay(0.5, function()
		spawnData.Model:Destroy()
		SpawnedCreatures[spawnId] = nil
	end)

	WorldController.OnCreatureDespawned:Fire(spawnId)
end

function WorldController.PlayDespawnAnimation(model: Model)
	local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not primaryPart then return end

	local tween = TweenService:Create(primaryPart, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = Vector3.new(0.1, 0.1, 0.1),
		Transparency = 1
	})
	tween:Play()

	-- Particle burst
	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(Color3.fromRGB(200, 200, 255))
	emitter.Size = NumberSequence.new(0.5, 2)
	emitter.Lifetime = NumberRange.new(0.3, 0.8)
	emitter.Rate = 0
	emitter.Speed = NumberRange.new(5, 15)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Parent = primaryPart
	emitter:Emit(15)
end

-- Check despawn distances
function WorldController.CheckDespawns()
	local player = Players.LocalPlayer
	if not player.Character or not player.Character.PrimaryPart then return end

	local playerPos = player.Character.PrimaryPart.Position

	for spawnId, spawnData in pairs(SpawnedCreatures) do
		local distance = (spawnData.Position - playerPos).Magnitude

		if distance > DespawnDistance then
			-- Request despawn from server
			local remote = ReplicatedStorage:FindFirstChild("Remotes")
			local despawnRemote = remote and remote:FindFirstChild("RequestSpawn") -- Would be a despawn remote
			-- For now just despawn locally
			WorldController.OnCreatureDespawned(spawnId)
		end
	end
end

-- Update creature animations
function WorldController.UpdateCreatureAnimations(deltaTime: number)
	for spawnId, spawnData in pairs(SpawnedCreatures) do
		local model = spawnData.Model
		local primaryPart = model.PrimaryPart

		if primaryPart then
			-- Idle bobbing
			local t = tick() * 1.5 + spawnId:byte(1) * 10
			local offset = math.sin(t) * 0.2
			local currentPos = primaryPart.Position
			primaryPart.CFrame = CFrame.new(currentPos.X, currentPos.Y + offset * 0.05, currentPos.Z)

			-- Random movement (wander)
			if math.random() < 0.001 then
				WorldController.WanderCreature(spawnId)
			end
		end
	end
end

function WorldController.WanderCreature(spawnId: string)
	local spawnData = SpawnedCreatures[spawnId]
	if not spawnData then return end

	local model = spawnData.Model
	local primaryPart = model.PrimaryPart
	if not primaryPart then return end

	-- Random direction
	local angle = math.random() * math.pi * 2
	local distance = math.random(5, 15)
	local targetPos = spawnData.Position + Vector3.new(math.cos(angle), 0, math.sin(angle)) * distance

	-- Simple tween movement
	local tween = TweenService:Create(primaryPart, TweenInfo.new(3, Enum.EasingStyle.Quad), {
		CFrame = CFrame.new(targetPos)
	})
	tween:Play()

	tween.Completed:Connect(function()
		spawnData.Position = targetPos
	end)
end

-- Time cycle
function WorldController.StartTimeCycle()
	task.spawn(function()
		while true do
			local cycleTime = (tick() % Config.Game.DayNightCycle) / Config.Game.DayNightCycle
			local newTimeOfDay: "Dawn" | "Day" | "Dusk" | "Night"

			if cycleTime < 0.25 then newTimeOfDay = "Dawn"
			elseif cycleTime < 0.5 then newTimeOfDay = "Day"
			elseif cycleTime < 0.75 then newTimeOfDay = "Dusk"
			else newTimeOfDay = "Night" end

			if newTimeOfDay ~= CurrentTimeOfDay then
				CurrentTimeOfDay = newTimeOfDay
				WorldController.OnTimeOfDayChanged:Fire(CurrentTimeOfDay)
			end

			task.wait(10) -- Check every 10 seconds
		end
	end)
end

function WorldController.UpdateTimeVisuals(deltaTime: number)
	-- Update lighting based on time of day
	local lighting = game:GetService("Lighting")

	local timeColors = {
		Dawn = {Ambient = Color3.fromRGB(255, 180, 120), Outdoor = Color3.fromRGB(255, 200, 150), ClockTime = 6},
		Day = {Ambient = Color3.fromRGB(180, 200, 220), Outdoor = Color3.fromRGB(220, 230, 255), ClockTime = 14},
		Dusk = {Ambient = Color3.fromRGB(255, 150, 100), Outdoor = Color3.fromRGB(255, 180, 130), ClockTime = 18},
		Night = {Ambient = Color3.fromRGB(60, 60, 100), Outdoor = Color3.fromRGB(100, 100, 150), ClockTime = 22},
	}

	local colors = timeColors[CurrentTimeOfDay]
	if colors then
		lighting.Ambient = lighting.Ambient:Lerp(colors.Ambient, 0.01)
		lighting.OutdoorAmbient = lighting.OutdoorAmbient:Lerp(colors.Outdoor, 0.01)
		lighting.ClockTime = colors.ClockTime
	end
end

-- Weather cycle
function WorldController.StartWeatherCycle()
	task.spawn(function()
		while true do
			-- Random weather change every 5-15 minutes
			task.wait(math.random(300, 900))

			local weathers: {Types.WeatherType} = {"Clear", "Rain", "Sunny", "Fog", "Windy"}
			if math.random() < 0.1 then
				-- Rare weather
				table.insert(weathers, "Sandstorm")
				table.insert(weathers, "Hail")
			end

			local newWeather = weathers[math.random(1, #weathers)]
			WorldController.SetWeather(newWeather)
		end
	end)
end

function WorldController.SetWeather(weather: Types.WeatherType)
	if weather == CurrentWeather then return end

	CurrentWeather = weather
	WorldController.OnWeatherChanged:Fire(weather)

	-- Apply weather effects
	WorldController.ApplyWeatherEffects(weather)
end

function WorldController.ApplyWeatherEffects(weather: Types.WeatherType)
	local lighting = game:GetService("Lighting")

	local weatherEffects = {
		Rain = function()
			-- Rain particle effect
			WorldController.CreateRainEffect()
			lighting.FogEnd = 100
			lighting.FogColor = Color3.fromRGB(150, 150, 180)
		end,
		Sunny = function()
			lighting.Brightness = 2
			lighting.FogEnd = 500
		end,
		Sandstorm = function()
			WorldController.CreateSandstormEffect()
			lighting.FogEnd = 80
			lighting.FogColor = Color3.fromRGB(200, 180, 120)
		end,
		Hail = function()
			WorldController.CreateHailEffect()
			lighting.FogEnd = 120
			lighting.FogColor = Color3.fromRGB(180, 180, 200)
		end,
		Fog = function()
			lighting.FogEnd = 50
			lighting.FogColor = Color3.fromRGB(180, 180, 190)
		end,
		Windy = function()
			WorldController.CreateWindEffect()
		end,
		Clear = function()
			-- Reset to normal
			lighting.Brightness = 1
			lighting.FogEnd = 100000
			WorldController.ClearWeatherEffects()
		end,
	}

	local effectFn = weatherEffects[weather]
	if effectFn then effectFn() end
end

function WorldController.CreateRainEffect()
	-- Create rain attachment on camera
	local camera = workspace.CurrentCamera
	if not camera then return end

	-- Remove existing
	local existing = camera:FindFirstChild("RainAttachment")
	if existing then existing:Destroy() end

	local attachment = Instance.new("Attachment")
	attachment.Name = "RainAttachment"
	attachment.Parent = camera

	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "Rain"
	emitter.Color = ColorSequence.new(Color3.fromRGB(150, 180, 220))
	emitter.Size = NumberSequence.new(0.1, 0.3)
	emitter.Lifetime = NumberRange.new(0.5, 1)
	emitter.Rate = 200
	emitter.Speed = NumberRange.new(50, 80)
	emitter.SpreadAngle = Vector2.new(10, 10)
	emitter.Acceleration = Vector3.new(0, -100, 0)
	emitter.Transparency = NumberSequence.new(0.5)
	emitter.Parent = attachment
end

function WorldController.CreateSandstormEffect()
	local camera = workspace.CurrentCamera
	if not camera then return end

	local existing = camera:FindFirstChild("SandstormAttachment")
	if existing then existing:Destroy() end

	local attachment = Instance.new("Attachment")
	attachment.Name = "SandstormAttachment"
	attachment.Parent = camera

	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "Sand"
	emitter.Color = ColorSequence.new(Color3.fromRGB(200, 180, 120))
	emitter.Size = NumberSequence.new(0.2, 0.5)
	emitter.Lifetime = NumberRange.new(1, 3)
	emitter.Rate = 100
	emitter.Speed = NumberRange.new(10, 30)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Acceleration = Vector3.new(math.random(-20, 20), -5, math.random(-20, 20))
	emitter.Parent = attachment
end

function WorldController.CreateHailEffect()
	local camera = workspace.CurrentCamera
	if not camera then return end

	local existing = camera:FindFirstChild("HailAttachment")
	if existing then existing:Destroy() end

	local attachment = Instance.new("Attachment")
	attachment.Name = "HailAttachment"
	attachment.Parent = camera

	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "Hail"
	emitter.Color = ColorSequence.new(Color3.fromRGB(200, 200, 230))
	emitter.Size = NumberSequence.new(0.15, 0.3)
	emitter.Lifetime = NumberRange.new(0.5, 1)
	emitter.Rate = 80
	emitter.Speed = NumberRange.new(40, 60)
	emitter.SpreadAngle = Vector2.new(20, 20)
	emitter.Acceleration = Vector3.new(0, -80, 0)
	emitter.Parent = attachment
end

function WorldController.CreateWindEffect()
	local camera = workspace.CurrentCamera
	if not camera then return end

	local existing = camera:FindFirstChild("WindAttachment")
	if existing then existing:Destroy() end

	local attachment = Instance.new("Attachment")
	attachment.Name = "WindAttachment"
	attachment.Parent = camera

	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "WindLeaves"
	emitter.Color = ColorSequence.new(Color3.fromRGB(100, 200, 100))
	emitter.Size = NumberSequence.new(0.3, 0.8)
	emitter.Lifetime = NumberRange.new(2, 5)
	emitter.Rate = 20
	emitter.Speed = NumberRange.new(5, 15)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Acceleration = Vector3.new(math.random(-30, 30), -2, math.random(-30, 30))
	emitter.Rotation = NumberRange.new(0, 360)
	emitter.RotSpeed = NumberRange.new(-180, 180)
	emitter.Parent = attachment
end

function WorldController.ClearWeatherEffects()
	local camera = workspace.CurrentCamera
	if not camera then return end

	for _, child in ipairs(camera:GetChildren()) do
		if child.Name:match("Attachment$") then
			child:Destroy()
		end
	end
end

-- Zone management
function WorldController.SetCurrentZone(zone: Types.ZoneData)
	if CurrentZone == zone then return end

	CurrentZone = zone
	WorldController.OnZoneChanged:Fire(zone)

	-- Update zone name display
	WorldController.ShowZoneNotification(zone.Name)
end

function WorldController.ShowZoneNotification(zoneName: string)
	-- Would show a nice UI notification
	print(`[WorldController] Entered zone: {zoneName}`)

	-- Show zone name on screen (could be enhanced with UI)
	local player = Players.LocalPlayer
	if player.PlayerGui then
		local gui = player.PlayerGui:FindFirstChild("ZoneNotification")
		if not gui then
			gui = Instance.new("ScreenGui")
			gui.Name = "ZoneNotification"
			gui.ResetOnSpawn = false
			gui.Parent = player.PlayerGui

			local frame = Instance.new("Frame")
			frame.Name = "ZoneFrame"
			frame.Size = UDim2.new(0, 400, 0, 80)
			frame.Position = UDim2.new(0.5, -200, 0.1, 0)
			frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
			frame.BackgroundTransparency = 0.2
			frame.BorderSizePixel = 0
			frame.Parent = gui

			local corner = Instance.new("UICorner")
			corner.CornerRadius = UDim.new(0, 12)
			corner.Parent = frame

			local stroke = Instance.new("UIStroke")
			stroke.Color = Color3.fromRGB(100, 200, 255)
			stroke.Thickness = 2
			stroke.Parent = frame

			local label = Instance.new("TextLabel")
			label.Name = "ZoneLabel"
			label.Size = UDim2.new(1, -40, 1, 0)
			label.Position = UDim2.new(0, 20, 0, 0)
			label.BackgroundTransparency = 1
			label.Text = zoneName
			label.TextColor3 = Color3.fromRGB(255, 255, 255)
			label.TextScaled = true
			label.Font = Enum.Font.GothamBold
			label.TextStrokeTransparency = 0.5
			label.Parent = frame
		else
			local label = gui.ZoneFrame.ZoneLabel
			label.Text = zoneName
		end

		-- Animate in/out
		local frame = gui.ZoneFrame
		frame.Size = UDim2.new(0, 0, 0, 80)
		local tweenIn = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
			Size = UDim2.new(0, 400, 0, 80)
		})
		tweenIn:Play()

		task.delay(3, function()
			if gui and gui.Parent then
				local tweenOut = TweenService:Create(frame, TweenInfo.new(0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
					Size = UDim2.new(0, 0, 0, 80)
				})
				tweenOut:Play()
				tweenOut.Completed:Wait()
				gui:Destroy()
			end
		end)
	end
end

function WorldController.GetCurrentZone(): Types.ZoneData?
	return CurrentZone
end

-- Check which zone player is in based on position
function WorldController.CheckZoneFromPosition(position: Vector3)
	local player = Players.LocalPlayer
	if not player.Character or not player.Character.PrimaryPart then return end

	local closestZone = nil
	local closestDist = math.huge

	for islandId, config in pairs(IslandConfig) do
		local dist = (position - config.Position).Magnitude
		if dist < config.Size and dist < closestDist then
			closestDist = dist
			closestZone = config
		end
	end

	if closestZone and (not CurrentZone or CurrentZone.Id ~= closestZone.Id) then
		-- Convert to ZoneData format
		local zoneData: Types.ZoneData = {
			Id = closestZone.Id,
			Name = closestZone.Name,
			Biome = closestZone.Biome,
			LevelRange = closestZone.LevelRange,
			SafeZone = closestZone.SafeZone or false,
			Position = closestZone.Position,
		}
		WorldController.SetCurrentZone(zoneData)
	end
end

function WorldController.GetCurrentWeather(): Types.WeatherType
	return CurrentWeather
end

function WorldController.GetCurrentTimeOfDay(): string
	return CurrentTimeOfDay
end

-- Get nearby creatures for UI
function WorldController.GetNearbyCreatures(radius: number?): {Types.CreatureData}
	local player = Players.LocalPlayer
	if not player.Character or not player.Character.PrimaryPart then return {} end

	local playerPos = player.Character.PrimaryPart.Position
	local radius = radius or 50
	local nearby = {}

	for _, spawnData in pairs(SpawnedCreatures) do
		local distance = (spawnData.Position - playerPos).Magnitude
		if distance <= radius then
			table.insert(nearby, spawnData.Creature)
		end
	end

	return nearby
end

-- Cleanup
function WorldController.Cleanup()
	for spawnId, spawnData in pairs(SpawnedCreatures) do
		spawnData.Model:Destroy()
	end
	SpawnedCreatures = {}
	WorldController.ClearWeatherEffects()
end

return WorldController