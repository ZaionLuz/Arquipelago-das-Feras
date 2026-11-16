--!nonstrict
-- WORLD SERVICE - World state, dynamic events, weather, day/night cycles, world events

local RS = game:GetService("ReplicatedStorage")
local Run = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local I = require(RS.Shared.Islands)
local B = require(script.Parent.Biomes)
local Data = require(script.Parent.DataService)
local EncounterService = require(script.Parent.EncounterService)
local Region = require(script.Parent.RegionService)
local IslandService = require(script.Parent.IslandService)
local GuardianService = require(script.Parent.GuardianService)
local W = {}

-- World state
W.State = {
	serverStartTime = os.time(),
	currentWeather = {},
	activeEvents = {},
	eventHistory = {},
	dayNightCycle = true,
	globalEventCooldown = 0,
	migrationActive = false,
	meteorShowerActive = false,
	eclipseActive = false,
	rareBossSpawned = {},
}

-- World Events
W.EventTypes = {
	Migration = "Migration",
	RareBoss = "RareBoss",
	MeteorShower = "MeteorShower",
	Eclipse = "Eclipse",
	ElementalSurge = "ElementalSurge",
	VoidRift = "VoidRift",
	AuroraBorealis = "AuroraBorealis",
	StormSurge = "StormSurge",
}

-- Event configurations
W.EventConfig = {
	[W.EventTypes.Migration] = {
		interval = 3600, -- 1 hour
		duration = 300, -- 5 minutes
		chance = 0.15,
		biomes = { "Alvorecer", "Floresta", "Recife", "Pantano" },
		description = "Uma migracao de feras raras esta ocorrendo!",
		spawnMultiplier = 3.0,
		rareMultiplier = 5.0,
	},
	[W.EventTypes.RareBoss] = {
		interval = 1800, -- 30 minutes
		duration = 600, -- 10 minutes
		chance = 0.1,
		biomes = { "Brasa", "Picos", "Dunas", "Inverno", "Trovao", "Celestial", "Forja", "Geoda", "Vazio" },
		description = "Um chefe raro apareceu na regiao!",
		levelBonus = 10,
		rewardMultiplier = 2.0,
	},
	[W.EventTypes.MeteorShower] = {
		interval = 7200, -- 2 hours
		duration = 180, -- 3 minutes
		chance = 0.05,
		biomes = { "Picos", "Celestial", "Vazio", "Inverno" },
		description = "Chuva de meteoros! Cristais raros caem do ceu!",
		materialBonus = 10,
		exclusiveItems = { "fragmento_estelar", "metal_meteoro" },
	},
	[W.EventTypes.Eclipse] = {
		interval = 14400, -- 4 hours
		duration = 120, -- 2 minutes
		chance = 0.03,
		biomes = "all",
		description = "Eclipse solar! Condicoes unicas de evolucao ativas!",
		evolutionBonus = 3.0,
		nightCreaturesDay = true,
		shadowPower = 2.0,
	},
	[W.EventTypes.ElementalSurge] = {
		interval = 2700, -- 45 minutes
		duration = 240, -- 4 minutes
		chance = 0.2,
		biomes = "all",
		description = "Surto elemental! Feras de um elemento especifico aparecem mais!",
		elementalMultiplier = 2.5,
	},
	[W.EventTypes.VoidRift] = {
		interval = 5400, -- 1.5 hours
		duration = 180, -- 3 minutes
		chance = 0.08,
		biomes = { "Pantano", "Vazio", "Geoda" },
		description = "Fenda do Vazio aberta! Feras de Sombra e Arcano surgem!",
		shadowMultiplier = 3.0,
		arcaneMultiplier = 2.5,
		voidEssenceBonus = 5,
	},
	[W.EventTypes.AuroraBorealis] = {
		interval = 3600, -- 1 hour
		duration = 300, -- 5 minutes
		chance = 0.12,
		biomes = { "Picos", "Inverno", "Celestial", "Vazio" },
		description = "Aurora Boreal! Luzes magicas aumentam chances de feras raras!",
		rareMultiplier = 3.0,
		luzMultiplier = 2.0,
		iceMultiplier = 1.5,
	},
	[W.EventTypes.StormSurge] = {
		interval = 1800, -- 30 minutes
		duration = 180, -- 3 minutes
		chance = 0.18,
		biomes = { "Brasa", "Recife", "Trovao", "Pantano" },
		description = "Tempestade elemental! Feras de Tempestade e Eletrico dominam!",
		stormMultiplier = 2.5,
		electricMultiplier = 2.0,
		waterMultiplier = 1.5,
	},
}

function W.start()
	-- Initialize world state
	W.State.serverStartTime = os.time()
	W.setupDayNightCycle()
	W.setupWeatherSystem()
	W.setupWorldEvents()
	W.setupLighting()

	-- Start event loop
	task.spawn(W.eventLoop)
	task.spawn(W.weatherLoop)
	task.spawn(W.migrationLoop)

	print("[WorldService] World system initialized")
end

function W.setupLighting()
	Lighting.Brightness = 2.1
	Lighting.GeographicLatitude = 28
	Lighting.ShadowSoftness = 0.12
	Lighting.Ambient = T.Ramps.Sky[2]
	Lighting.OutdoorAmbient = T.Ramps.Metal[3]
	Lighting.EnvironmentDiffuseScale = 0.5
	Lighting.EnvironmentSpecularScale = 0.15
	Lighting.ClockTime = 14
	Lighting.GlobalShadows = true

	local at = Instance.new("Atmosphere")
	at.Density = 0.18
	at.Haze = 0.9
	at.Color = T.Ramps.Sky[4]
	at.Parent = Lighting

	local bl = Instance.new("BloomEffect")
	bl.Intensity = 0.12
	bl.Size = 12
	bl.Threshold = 1.8
	bl.Parent = Lighting

	local cc = Instance.new("ColorCorrectionEffect")
	cc.Saturation = 0.05
	cc.Contrast = 0.1
	cc.Parent = Lighting
end

function W.setupDayNightCycle()
	-- 24-minute day cycle (1 minute = 1 hour)
	Run.Heartbeat:Connect(function()
		if not W.State.dayNightCycle then return end
		local cycleTime = (os.time() - W.State.serverStartTime) % 1440 -- 24 min cycle
		local hour = (cycleTime / 60) % 24
		Lighting.ClockTime = hour

		-- Update ambient based on time
		if hour >= 5 and hour < 7 then -- Dawn
			Lighting.Ambient = Color3.fromRGB(180, 150, 100)
			Lighting.OutdoorAmbient = Color3.fromRGB(200, 170, 120)
		elseif hour >= 7 and hour < 18 then -- Day
			Lighting.Ambient = Color3.fromRGB(130, 150, 180)
			Lighting.OutdoorAmbient = Color3.fromRGB(150, 170, 200)
		elseif hour >= 18 and hour < 20 then -- Dusk
			Lighting.Ambient = Color3.fromRGB(150, 100, 80)
			Lighting.OutdoorAmbient = Color3.fromRGB(180, 120, 90)
		else -- Night
			Lighting.Ambient = Color3.fromRGB(40, 50, 80)
			Lighting.OutdoorAmbient = Color3.fromRGB(60, 70, 100)
		end
	end)
end

function W.setupWeatherSystem()
	-- Weather changes every 5-15 minutes
	task.spawn(function()
		while true do
			task.wait(math.random(300, 900)) -- 5-15 minutes
			W.updateBiomeWeather()
		end
	end)
end

function W.updateBiomeWeather()
	for _, def in I.List do
		local weathers = B.BiomeWeather[def.id] or { B.WeatherTypes.Clear }
		local newWeather = weathers[math.random(1, #weathers)]
		local oldWeather = W.State.currentWeather[def.id]

		if newWeather ~= oldWeather then
			W.State.currentWeather[def.id] = newWeather
			W.applyWeatherEffects(def.id, newWeather)
			W.notifyWeatherChange(def.id, newWeather)
		end
	end
end

function W.applyWeatherEffects(biomeId, weather)
	local biomeFolder = workspace:FindFirstChild("Arquipelago")
	if not biomeFolder then return end

	local islandFolder = biomeFolder:FindFirstChild("Biome_" .. biomeId)
	if not islandFolder then return end

	-- Clear existing weather effects
	for _, child in islandFolder:GetChildren() do
		if child:GetAttribute("WeatherEffect") then
			child:Destroy()
		end
	end

	if weather == B.WeatherTypes.Clear then return end

	-- Apply weather-specific effects
	local center = I.pos(I.ById[biomeId].idx)

	if weather == B.WeatherTypes.Rain then
		W.createRainEffect(islandFolder, center)
	elseif weather == B.WeatherTypes.Ash then
		W.createAshEffect(islandFolder, center)
	elseif weather == B.WeatherTypes.Snow then
		W.createSnowEffect(islandFolder, center)
	elseif weather == B.WeatherTypes.Storm then
		W.createStormEffect(islandFolder, center)
	elseif weather == B.WeatherTypes.Aurora then
		W.createAuroraEffect(islandFolder, center)
	elseif weather == B.WeatherTypes.VoidFog then
		W.createVoidFogEffect(islandFolder, center)
	end
end

function W.createRainEffect(folder, center)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "Rain"
	emitter.Texture = "rbxassetid://241629423"
	emitter.Color = ColorSequence.new(Color3.fromRGB(150, 180, 220))
	emitter.Size = NumberSequence.new(0.2, 0.05)
	emitter.Lifetime = NumberRange.new(1, 2)
	emitter.Rate = 200
	emitter.Speed = NumberRange.new(30, 50)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Drag = 0
	emitter.Acceleration = Vector3.new(0, -20, 0)
	emitter.Parent = folder
	emitter:SetAttribute("WeatherEffect", true)

	-- Rain sound
	local sound = Instance.new("Sound")
	sound.Name = "RainSound"
	sound.SoundId = "rbxassetid://100000013"
	sound.Volume = 0.3
	sound.Looped = true
	sound.Parent = folder
	sound:Play()
end

function W.createAshEffect(folder, center)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "Ash"
	emitter.Texture = "rbxassetid://241629423"
	emitter.Color = ColorSequence.new(Color3.fromRGB(80, 70, 70), Color3.fromRGB(40, 35, 35))
	emitter.Size = NumberSequence.new(0.5, 0.1)
	emitter.Lifetime = NumberRange.new(3, 6)
	emitter.Rate = 50
	emitter.Speed = NumberRange.new(2, 5)
	emitter.SpreadAngle = Vector2.new(360, 360)
	emitter.Drag = 0.5
	emitter.Parent = folder
	emitter:SetAttribute("WeatherEffect", true)
end

function W.createSnowEffect(folder, center)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "Snow"
	emitter.Texture = "rbxassetid://241629423"
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	emitter.Size = NumberSequence.new(0.3, 0.1)
	emitter.Lifetime = NumberRange.new(4, 8)
	emitter.Rate = 100
	emitter.Speed = NumberRange.new(1, 3)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Drag = 1
	emitter.Acceleration = Vector3.new(math.random(-2, 2), -5, math.random(-2, 2))
	emitter.Parent = folder
	emitter:SetAttribute("WeatherEffect", true)
end

function W.createStormEffect(folder, center)
	-- Heavy rain
	local rain = Instance.new("ParticleEmitter")
	rain.Name = "StormRain"
	rain.Texture = "rbxassetid://241629423"
	rain.Color = ColorSequence.new(Color3.fromRGB(100, 120, 160))
	rain.Size = NumberSequence.new(0.3, 0.1)
	rain.Lifetime = NumberRange.new(0.5, 1.5)
	rain.Rate = 400
	rain.Speed = NumberRange.new(50, 80)
	rain.SpreadAngle = Vector2.new(180, 180)
	rain.Drag = 0
	rain.Acceleration = Vector3.new(0, -30, 0)
	rain.Parent = folder
	rain:SetAttribute("WeatherEffect", true)

	-- Lightning
	task.spawn(function()
		for i = 1, 10 do
			task.wait(math.random(2, 8))
			W.createLightning(center)
		end
	end)
end

function W.createLightning(center)
	local start = center + Vector3.new(math.random(-50, 50), 100, math.random(-50, 50))
	local endPos = center + Vector3.new(math.random(-30, 30), 0, math.random(-30, 30))

	local beam = Instance.new("Part")
	beam.Name = "Lightning"
	beam.Size = Vector3.new(0.5, (start - endPos).Magnitude, 0.5)
	beam.CFrame = CFrame.lookAt(start, endPos) * CFrame.new(0, 0, -(start - endPos).Magnitude / 2)
	beam.Anchored = true
	beam.CanCollide = false
	beam.Material = Enum.Material.Neon
	beam.Color = Color3.fromRGB(255, 255, 200)
	beam.Parent = workspace
	beam:SetAttribute("WeatherEffect", true)

	-- Thunder sound
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://100000014"
	sound.Volume = 0.5
	sound.Parent = beam
	sound:Play()

	-- Fade out
	game:GetService("TweenService"):Create(beam, TweenInfo.new(0.1), {Transparency = 1}):Play()
	game:GetService("Debris"):AddItem(beam, 0.2)
end

function W.createAuroraEffect(folder, center)
	local colors = {
		Color3.fromRGB(100, 255, 150),
		Color3.fromRGB(150, 200, 255),
		Color3.fromRGB(200, 150, 255),
		Color3.fromRGB(100, 255, 255),
	}

	for i = 1, 5 do
		local wave = Instance.new("Part")
		wave.Name = "AuroraWave"
		wave.Size = Vector3.new(200, 20, 1)
		wave.Position = center + Vector3.new(0, 50 + i * 5, 0)
		wave.Anchored = true
		wave.CanCollide = false
		wave.Material = Enum.Material.Neon
		wave.Color = colors[math.random(1, #colors)]
		wave.Transparency = 0.7
		wave.Parent = folder
		wave:SetAttribute("WeatherEffect", true)

		-- Animate
		game:GetService("TweenService"):Create(wave, TweenInfo.new(3, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			Position = center + Vector3.new(math.sin(i) * 20, 50 + i * 5, math.cos(i) * 20),
			Transparency = 0.3,
		}):Play()
	end
end

function W.createVoidFogEffect(folder, center)
	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "VoidFog"
	emitter.Texture = "rbxassetid://241629423"
	emitter.Color = ColorSequence.new(Color3.fromRGB(30, 10, 50), Color3.fromRGB(60, 20, 90))
	emitter.Size = NumberSequence.new(5, 1)
	emitter.Lifetime = NumberRange.new(5, 10)
	emitter.Rate = 20
	emitter.Speed = NumberRange.new(0.5, 2)
	emitter.SpreadAngle = Vector2.new(360, 360)
	emitter.Drag = 0.2
	emitter.Parent = folder
	emitter:SetAttribute("WeatherEffect", true)

	-- Darken lighting
	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "VoidCorrection"
	cc.Saturation = -0.5
	cc.Contrast = 0.3
	cc.TintColor = Color3.fromRGB(80, 60, 100)
	cc.Parent = Lighting
	cc:SetAttribute("WeatherEffect", true)
end

function W.notifyWeatherChange(biomeId, weather)
	local notice = RS:FindFirstChild("WildNotice")
	if notice then
		local weatherNames = {
			[B.WeatherTypes.Rain] = "Chuva",
			[B.WeatherTypes.Ash] = "Cinzas",
			[B.WeatherTypes.Snow] = "Neve",
			[B.WeatherTypes.Storm] = "Tempestade",
			[B.WeatherTypes.Aurora] = "Aurora Boreal",
			[B.WeatherTypes.VoidFog] = "Neblina do Vazio",
			[B.WeatherTypes.Clear] = "Ceu Limpo",
		}
		-- Only notify players in that biome
		for _, player in game:GetService("Players"):GetPlayers() do
			local region = Region.current(player, "encounter")
			if region == biomeId then
				notice:FireClient(player, "Clima em " .. I.ById[biomeId].name .. " mudou para: " .. (weatherNames[weather] or weather))
			end
		end
	end
end

function W.setupWorldEvents()
	-- Initialize event cooldowns
	for eventType, config in W.EventConfig do
		W.State.globalEventCooldown = 0
	end
end

function W.eventLoop()
	while true do
		task.wait(60) -- Check every minute
		W.checkAndTriggerEvents()
	end
end

function W.checkAndTriggerEvents()
	local now = os.time()

	for eventType, config in W.EventConfig do
		-- Check cooldown
		if (W.State.activeEvents[eventType] and now < W.State.activeEvents[eventType].endTime) then
			-- Event still active
			continue
		end

		-- Check if enough time passed since last event
		local lastEvent = W.State.eventHistory[eventType] or 0
		if now - lastEvent < config.interval then
			continue
		end

		-- Roll for event
		if math.random() < config.chance then
			W.triggerEvent(eventType)
		end
	end
end

function W.triggerEvent(eventType)
	local config = W.EventConfig[eventType]
	local now = os.time()

	W.State.activeEvents[eventType] = {
		startTime = now,
		endTime = now + config.duration,
		config = config,
	}

	W.State.eventHistory[eventType] = now

	-- Apply event effects
	W.applyEventEffects(eventType, config)

	-- Notify all players
	local notice = RS:FindFirstChild("WildNotice")
	if notice then
		for _, player in game:GetService("Players"):GetPlayers() do
			local region = Region.current(player, "encounter")
			if config.biomes == "all" or table.find(config.biomes, region) then
				notice:FireClient(player, "[EVENTO MUNDIAL] " .. config.description)
			end
		end
	end

	print("[WorldService] Event triggered: " .. eventType)

	-- Schedule cleanup
	task.delay(config.duration, function()
		W.State.activeEvents[eventType] = nil
		W.removeEventEffects(eventType)

		if notice then
			for _, player in game:GetService("Players"):GetPlayers() do
				notice:FireClient(player, "O evento " .. eventType .. " terminou.")
			end
		end
	end)
end

function W.applyEventEffects(eventType, config)
	if eventType == W.EventTypes.Migration then
		W.State.migrationActive = true
		-- Increase spawn rates in migration biomes
		for _, biomeId in config.biomes do
			EncounterService.setBiomeMultiplier(biomeId, config.spawnMultiplier)
		end
	elseif eventType == W.EventTypes.RareBoss then
		-- Spawn rare boss in eligible biome
		local eligibleBiomes = {}
		for _, biomeId in config.biomes do
			if I.ById[biomeId] then
				table.insert(eligibleBiomes, biomeId)
			end
		end
		if #eligibleBiomes > 0 then
			local biomeId = eligibleBiomes[math.random(1, #eligibleBiomes)]
			GuardianService.spawnRareBoss(biomeId, config.levelBonus, config.rewardMultiplier)
			W.State.rareBossSpawned[biomeId] = true
		end
	elseif eventType == W.EventTypes.MeteorShower then
		W.State.meteorShowerActive = true
		W.spawnMeteorites(config.biomes)
	elseif eventType == W.EventTypes.Eclipse then
		W.State.eclipseActive = true
		Lighting.ClockTime = 12 -- Force midday darkness
		Lighting.Ambient = Color3.fromRGB(20, 20, 40)
		Lighting.OutdoorAmbient = Color3.fromRGB(30, 30, 50)
	elseif eventType == W.EventTypes.ElementalSurge then
		-- Pick random element
		local elements = { "Fogo", "Agua", "Natureza", "Terra", "Ar", "Sombra", "Gelo", "Eletrico", "Luz", "Metal", "Cristal", "Arcano" }
		local element = elements[math.random(1, #elements)]
		W.State.elementalSurge = { element = element, multiplier = config.elementalMultiplier }
		EncounterService.setElementalMultiplier(element, config.elementalMultiplier)
	elseif eventType == W.EventTypes.VoidRift then
		for _, biomeId in config.biomes do
			EncounterService.setBiomeMultiplier(biomeId, config.shadowMultiplier)
			IslandService.openVoidRift(biomeId)
		end
	elseif eventType == W.EventTypes.AuroraBorealis then
		for _, biomeId in config.biomes do
			EncounterService.setBiomeMultiplier(biomeId, config.rareMultiplier)
		end
	elseif eventType == W.EventTypes.StormSurge then
		for _, biomeId in config.biomes do
			EncounterService.setBiomeMultiplier(biomeId, config.stormMultiplier)
		end
	end
end

function W.removeEventEffects(eventType)
	if eventType == W.EventTypes.Migration then
		W.State.migrationActive = false
		EncounterService.clearBiomeMultipliers()
	elseif eventType == W.EventTypes.RareBoss then
		W.State.rareBossSpawned = {}
		GuardianService.despawnRareBosses()
	elseif eventType == W.EventTypes.MeteorShower then
		W.State.meteorShowerActive = false
		W.despawnMeteorites()
	elseif eventType == W.EventTypes.Eclipse then
		W.State.eclipseActive = false
		-- Restore normal lighting
		W.setupLighting()
	elseif eventType == W.EventTypes.ElementalSurge then
		W.State.elementalSurge = nil
		EncounterService.clearElementalMultipliers()
	elseif eventType == W.EventTypes.VoidRift then
		EncounterService.clearBiomeMultipliers()
		IslandService.closeVoidRifts()
	elseif eventType == W.EventTypes.AuroraBorealis then
		EncounterService.clearBiomeMultipliers()
	elseif eventType == W.EventTypes.StormSurge then
		EncounterService.clearBiomeMultipliers()
	end
end

function W.spawnMeteorites(biomes)
	for _, biomeId in biomes do
		if not I.ById[biomeId] then continue end
		local center = I.pos(I.ById[biomeId].idx)

		for i = 1, 5 do
			local pos = center + Vector3.new(math.random(-40, 40), 100, math.random(-40, 40))
			local meteor = Instance.new("Part")
			meteor.Name = "Meteorite"
			meteor.Size = Vector3.new(3, 3, 3)
			meteor.Position = pos
			meteor.Anchored = true
			meteor.CanCollide = true
			meteor.Material = Enum.Material.Slate
			meteor.Color = Color3.fromRGB(60, 50, 50)
			meteor.Parent = workspace
			meteor:SetAttribute("Meteorite", true)
			meteor:SetAttribute("Biome", biomeId)

			-- Trail effect
			local trail = Instance.new("ParticleEmitter")
			trail.Texture = "rbxassetid://241629423"
			trail.Color = ColorSequence.new(Color3.fromRGB(255, 150, 50))
			trail.Size = NumberSequence.new(1, 0)
			trail.Lifetime = NumberRange.new(0.5, 1)
			trail.Rate = 50
			trail.Speed = NumberRange.new(10, 20)
			trail.Parent = meteor

			-- Fall animation
			game:GetService("TweenService"):Create(meteor, TweenInfo.new(3), {
				Position = center + Vector3.new(math.random(-40, 40), 5, math.random(-40, 40))
			}):Play()

			-- Touch event for collection
			meteor.Touched:Connect(function(hit)
				local player = game:GetService("Players"):GetPlayerFromCharacter(hit.Parent)
				if player and meteor:GetAttribute("Meteorite") then
					local data = Data.get(player)
					if data then
						data.materials["Cristal"] = math.min(10000, (data.materials["Cristal"] or 0) + 5)
						data.materials["Metal"] = math.min(10000, (data.materials["Metal"] or 0) + 3)
						local notice = RS:FindFirstChild("WildNotice")
						if notice then
							notice:FireClient(player, "Coletou fragmentos de meteorito! +5 Cristal, +3 Metal")
						end
					end
					meteor:Destroy()
				end
			end)

			game:GetService("Debris"):AddItem(meteor, 30)
		end
	end
end

function W.despawnMeteorites()
	for _, obj in workspace:GetChildren() do
		if obj:GetAttribute("Meteorite") then
			obj:Destroy()
		end
	end
end

function W.weatherLoop()
	while true do
		task.wait(300) -- 5 minutes
		W.updateBiomeWeather()
	end
end

function W.migrationLoop()
	while true do
		task.wait(3600) -- 1 hour
		if not W.State.migrationActive and math.random() < 0.3 then
			W.triggerEvent(W.EventTypes.Migration)
		end
	end
end

-- Get current world state for client sync
function W.getWorldState()
	return {
		serverTime = os.time(),
		serverStartTime = W.State.serverStartTime,
		currentWeather = W.State.currentWeather,
		activeEvents = W.State.activeEvents,
		dayNightCycle = W.State.dayNightCycle,
		clockTime = Lighting.ClockTime,
	}
end

-- Force trigger event (admin/debug)
function W.forceEvent(eventType)
	if W.EventConfig[eventType] then
		W.triggerEvent(eventType)
		return true
	end
	return false
end

-- Toggle day/night cycle
function W.setDayNightCycle(enabled)
	W.State.dayNightCycle = enabled
end

return W