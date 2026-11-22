--!strict
-- SpawnSystem.lua - Sistema de spawn de criaturas selvagens por bioma

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local CreatureSystem = require(script.Parent.CreatureSystem)
local MathUtil = require(ReplicatedStorage.Shared.Util.Math)
local TableUtil = require(ReplicatedStorage.Shared.Util.Table)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local SpawnSystem = {}

-- Events
SpawnSystem.OnCreatureSpawned = Signal.New()
SpawnSystem.OnCreatureDespawned = Signal.New()

-- Spawn configuration
local SpawnConfig = {
	MaxCreaturesPerZone = 15,
	SpawnRadius = 100,
	DespawnRadius = 150,
	SpawnInterval = 10, -- seconds
	DespawnTime = 300, -- 5 minutes
	RarityWeights = {
		Common = 50,
		Rare = 25,
		Epic = 15,
		Legendary = 5,
		Hybrid = 2,
	},
	TimeOfDayModifiers = {
		Day = {Fire = 1.0, Water = 1.0, Nature = 1.2, Earth = 1.0, Air = 1.1, Shadow = 0.8},
		Night = {Fire = 0.8, Water = 1.1, Nature = 1.0, Earth = 1.0, Air = 0.9, Shadow = 1.5},
		Dawn = {Fire = 0.9, Water = 1.2, Nature = 1.3, Earth = 1.0, Air = 1.2, Shadow = 0.9},
		Dusk = {Fire = 1.2, Water = 1.0, Nature = 1.1, Earth = 1.1, Air = 1.0, Shadow = 1.3},
	},
	WeatherModifiers = {
		Sunny = {Fire = 1.5, Water = 0.5, Nature = 1.2, Earth = 1.0, Air = 1.0, Shadow = 0.8},
		Rain = {Fire = 0.5, Water = 1.5, Nature = 1.3, Earth = 1.1, Air = 0.9, Shadow = 1.0},
		Sandstorm = {Fire = 1.0, Water = 0.5, Nature = 0.7, Earth = 1.5, Air = 0.8, Shadow = 1.0},
		Snow = {Fire = 0.5, Water = 1.2, Nature = 0.8, Earth = 1.0, Air = 1.0, Shadow = 1.1},
		Fog = {Fire = 0.8, Water = 1.1, Nature = 1.0, Earth = 0.9, Air = 0.8, Shadow = 1.4},
		Windy = {Fire = 0.9, Water = 1.0, Nature = 1.0, Earth = 0.8, Air = 1.5, Shadow = 1.0},
	},
}

-- Zone spawn points (generated dynamically)
local ZoneSpawnPoints = {} :: {[string]: {Vector3}}
local ZoneCreatureCounts = {} :: {[string]: number}
local ActiveSpawns = {} :: {[string]: {SpawnId: string, Creature: Types.CreatureData, Position: Vector3, ZoneId: string, SpawnTime: number}}

-- Initialize spawn system
function SpawnSystem.Initialize()
	-- Generate spawn points for each zone
	for zoneId, zoneData in pairs(Config.Zones) do
		if zoneData.Spawns and #zoneData.Spawns > 0 then
			ZoneSpawnPoints[zoneId] = SpawnSystem.GenerateSpawnPoints(zoneId, 20)
			ZoneCreatureCounts[zoneId] = 0
		end
	end

	-- Initial spawn
	task.spawn(function()
		task.wait(2)
		SpawnSystem.SpawnInitialCreatures()
	end)

	print("[SpawnSystem] Initialized")
end

-- Generate spawn points for a zone
function SpawnSystem.GenerateSpawnPoints(zoneId: string, count: number): {Vector3}
	local points = {}
	local zoneData = Config.Zones[zoneId]

	-- In a real game, these would be placed manually or generated from terrain
	-- For now, generate random points around zone center
	local center = SpawnSystem.GetZoneCenter(zoneId)

	for i = 1, count do
		local angle = math.random() * 2 * math.pi
		local distance = math.random() * SpawnConfig.SpawnRadius * 0.8
		local x = center.X + math.cos(angle) * distance
		local z = center.Z + math.sin(angle) * distance
		local y = center.Y + math.random(-5, 5)

		table.insert(points, Vector3.new(x, y, z))
	end

	return points
end

-- Get zone center (placeholder - would use actual zone positions)
function SpawnSystem.GetZoneCenter(zoneId: string): Vector3
	-- Default centers for each zone
	local centers = {
		StarterTown = Vector3.new(0, 5, 0),
		FireForest = Vector3.new(200, 10, 0),
		WaterCaves = Vector3.new(-200, -20, 0),
		NaturePlains = Vector3.new(0, 10, 200),
		EarthDesert = Vector3.new(-200, 15, -200),
		AirPeaks = Vector3.new(200, 50, 200),
		ShadowRuins = Vector3.new(0, 5, -200),
	}

	return centers[zoneId] or Vector3.new(0, 5, 0)
end

-- Initial spawn for all zones
function SpawnSystem.SpawnInitialCreatures()
	for zoneId, zoneData in pairs(Config.Zones) do
		if zoneData.Spawns and #zoneData.Spawns > 0 then
			local targetCount = math.min(SpawnConfig.MaxCreaturesPerZone, 5)
			for i = 1, targetCount do
				SpawnSystem.TrySpawnInZone(zoneId)
			end
		end
	end
end

-- Main update loop
function SpawnSystem.Update(deltaTime: number)
	-- Check for despawns
	SpawnSystem.CheckDespawns()

	-- Try to spawn new creatures
	SpawnSystem.TrySpawnCreatures()
end

-- Check for creatures that should despawn
function SpawnSystem.CheckDespawns()
	local currentTime = tick()

	for spawnId, spawnData in pairs(ActiveSpawns) do
		-- Check despawn time
		if currentTime - spawnData.SpawnTime > SpawnConfig.DespawnTime then
			SpawnSystem.DespawnCreature(spawnId, "Timeout")
			continue
		end

		-- Check distance from players
		local hasNearbyPlayer = false
		for _, player in ipairs(game.Players:GetPlayers()) do
			if player.Character and player.Character.PrimaryPart then
				local distance = (player.Character.PrimaryPart.Position - spawnData.Position).Magnitude
				if distance < SpawnConfig.DespawnRadius then
					hasNearbyPlayer = true
					break
				end
			end
		end

		if not hasNearbyPlayer and currentTime - spawnData.SpawnTime > 60 then
			-- Despawn if no players nearby for 1 minute
			SpawnSystem.DespawnCreature(spawnId, "NoPlayers")
		end
	end
end

-- Try to spawn creatures in zones that need them
function SpawnSystem.TrySpawnCreatures()
	for zoneId, zoneData in pairs(Config.Zones) do
		if not zoneData.Spawns then continue end

		local currentCount = ZoneCreatureCounts[zoneId] or 0
		if currentCount < SpawnConfig.MaxCreaturesPerZone then
			-- Chance to spawn based on deficit
			local deficit = SpawnConfig.MaxCreaturesPerZone - currentCount
			local spawnChance = deficit * 0.1 -- 10% per missing creature

			if math.random() < spawnChance then
				SpawnSystem.TrySpawnInZone(zoneId)
			end
		end
	end
end

-- Try to spawn a single creature in a zone
function SpawnSystem.TrySpawnInZone(zoneId: string): boolean
	local zoneData = Config.Zones[zoneId]
	if not zoneData or not zoneData.Spawns or #zoneData.Spawns == 0 then
		return false
	end

	local spawnPoints = ZoneSpawnPoints[zoneId]
	if not spawnPoints or #spawnPoints == 0 then
		return false
	end

	-- Pick random spawn point
	local position = spawnPoints[math.random(#spawnPoints)]

	-- Select species based on weights, time, weather
	local speciesId = SpawnSystem.SelectSpecies(zoneId)
	if not speciesId then return false end

	-- Determine level
	local level = math.random(zoneData.LevelRange.Min, zoneData.LevelRange.Max)

	-- Generate creature
	local creature = CreatureSystem.GenerateWildCreature(speciesId, level, zoneId)

	-- Spawn in world
	local spawnId = CreatureSystem.SpawnCreatureInWorld(creature, position, zoneId)

	-- Track
	ActiveSpawns[spawnId] = {
		SpawnId = spawnId,
		Creature = creature,
		Position = position,
		ZoneId = zoneId,
		SpawnTime = tick(),
	}

	ZoneCreatureCounts[zoneId] = (ZoneCreatureCounts[zoneId] or 0) + 1

	SpawnSystem.OnCreatureSpawned:Fire(spawnId, creature, position, zoneId)

	return true
end

-- Select species based on zone, time, weather, rarity
function SpawnSystem.SelectSpecies(zoneId: string): string?
	local zoneData = Config.Zones[zoneId]
	if not zoneData or not zoneData.Spawns then return nil end

	-- Get current time of day and weather (simplified)
	local timeOfDay = SpawnSystem.GetTimeOfDay()
	local weather = SpawnSystem.GetCurrentWeather()

	-- Build weighted list
	local weightedSpecies = {}

	for _, speciesId in ipairs(zoneData.Spawns) do
		local speciesData = Config.SpeciesList[speciesId]
		if not speciesData then continue end

		-- Base weight from rarity
		local weight = SpawnConfig.RarityWeights[speciesData.Rarity] or 10

		-- Time of day modifier
		local timeMod = SpawnConfig.TimeOfDayModifiers[timeOfDay]
		if timeMod and timeMod[speciesData.Element] then
			weight = weight * timeMod[speciesData.Element]
		end

		-- Weather modifier
		local weatherMod = SpawnConfig.WeatherModifiers[weather]
		if weatherMod and weatherMod[speciesData.Element] then
			weight = weight * weatherMod[speciesData.Element]
		end

		-- Hybrid bonus for legendary zones
		if speciesData.Rarity == "Legendary" and speciesData.Element:find("FireWater") then
			weight = weight * 0.5 -- Very rare
		end

		table.insert(weightedSpecies, {Item = speciesId, Weight = weight})
	end

	if #weightedSpecies == 0 then return nil end

	return TableUtil.WeightedRandom(weightedSpecies)
end

-- Get current time of day
function SpawnSystem.GetTimeOfDay(): "Day" | "Night" | "Dawn" | "Dusk"
	local cycleTime = (tick() % Config.Game.DayNightCycle) / Config.Game.DayNightCycle

	if cycleTime < 0.25 then return "Dawn"
	elseif cycleTime < 0.5 then return "Day"
	elseif cycleTime < 0.75 then return "Dusk"
	else return "Night"
	end
end

-- Get current weather (simplified)
function SpawnSystem.GetCurrentWeather(): string
	-- In a real game, this would come from a WeatherSystem
	return "None"
end

-- Despawn a creature
function SpawnSystem.DespawnCreature(spawnId: string, reason: string)
	local spawnData = ActiveSpawns[spawnId]
	if not spawnData then return end

	CreatureSystem.DespawnCreature(spawnId)

	ZoneCreatureCounts[spawnData.ZoneId] = math.max(0, (ZoneCreatureCounts[spawnData.ZoneId] or 1) - 1)
	ActiveSpawns[spawnId] = nil

	SpawnSystem.OnCreatureDespawned:Fire(spawnId, reason)
end

-- Force spawn specific creature (for events/quests)
function SpawnSystem.ForceSpawn(zoneId: string, speciesId: string, level: number, position: Vector3?): string?
	local zoneData = Config.Zones[zoneId]
	if not zoneData then return nil end

	local pos = position or ZoneSpawnPoints[zoneId][math.random(#ZoneSpawnPoints[zoneId])]
	local creature = CreatureSystem.GenerateWildCreature(speciesId, level, zoneId)
	local spawnId = CreatureSystem.SpawnCreatureInWorld(creature, pos, zoneId)

	ActiveSpawns[spawnId] = {
		SpawnId = spawnId,
		Creature = creature,
		Position = pos,
		ZoneId = zoneId,
		SpawnTime = tick(),
	}

	ZoneCreatureCounts[zoneId] = (ZoneCreatureCounts[zoneId] or 0) + 1

	return spawnId
end

-- Get active spawns in zone
function SpawnSystem.GetActiveSpawnsInZone(zoneId: string): {string}
	local result = {}
	for spawnId, data in pairs(ActiveSpawns) do
		if data.ZoneId == zoneId then
			table.insert(result, spawnId)
		end
	end
	return result
end

-- Get creature by spawn ID
function SpawnSystem.GetCreatureBySpawnId(spawnId: string): Types.CreatureData?
	local spawnData = ActiveSpawns[spawnId]
	return spawnData and spawnData.Creature or nil
end

-- Get spawn stats for debugging
function SpawnSystem.GetStats(): {TotalActive: number, PerZone: {[string]: number}}
	return {
		TotalActive = #TableUtil.Keys(ActiveSpawns),
		PerZone = ZoneCreatureCounts,
	}
end

return SpawnSystem