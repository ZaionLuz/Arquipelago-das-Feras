--!strict
-- DataStoreSystem.lua - Persistência segura de dados do jogador

local DataStoreService = game:GetService("DataStoreService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Types = require(game.ReplicatedStorage.Shared.Types)
local Config = require(game.ReplicatedStorage.Shared.Config)
local Signal = require(game.ReplicatedStorage.Shared.Util.Signal)

local DataStoreSystem = {}

-- DataStores
local PlayerDataStore = DataStoreService:GetDataStore("PlayerData_v2")
local BackupDataStore = DataStoreService:GetDataStore("PlayerData_Backup_v2")
local GlobalDataStore = DataStoreService:GetDataStore("GlobalData_v2")

-- Session locking
local SessionLocks = {} :: {[number]: boolean}
local PendingSaves = {} :: {[number]: Types.PlayerData}
local SAVE_INTERVAL = 60 -- segundos
local MAX_RETRIES = 3
local RETRY_DELAY = 2

-- Events
DataStoreSystem.OnDataLoaded = Signal.New()
DataStoreSystem.OnDataSaved = Signal.New()
DataStoreSystem.OnDataError = Signal.New()

-- Generate session lock token
local function GenerateSessionToken(): string
	return `{game.JobId}-{tick()}-{math.random(1000000)}`
end

-- Acquire session lock
local function AcquireSessionLock(userId: number): (boolean, string?)
	local token = GenerateSessionToken()
	local lockKey = `SessionLock_{userId}`

	for attempt = 1, MAX_RETRIES do
		local success, result = pcall(function()
			return PlayerDataStore:UpdateAsync(lockKey, function(oldValue)
				if oldValue and oldValue.Token and oldValue.Token ~= token then
					-- Check if lock is stale (older than 10 minutes)
					if oldValue.Timestamp and (tick() - oldValue.Timestamp) > 600 then
						return {Token = token, Timestamp = tick(), UserId = userId}
					end
					return nil -- Lock held by another server
				end
				return {Token = token, Timestamp = tick(), UserId = userId}
			end)
		end)

		if success and result and result.Token == token then
			SessionLocks[userId] = true
			return true, token
		end

		task.wait(RETRY_DELAY)
	end

	return false, nil
end

-- Release session lock
local function ReleaseSessionLock(userId: number, token: string)
	local lockKey = `SessionLock_{userId}`

	pcall(function()
		PlayerDataStore:UpdateAsync(lockKey, function(oldValue)
			if oldValue and oldValue.Token == token then
				return nil -- Release lock
			end
			return oldValue -- Keep existing lock
		end)
	end)

	SessionLocks[userId] = nil
end

-- Load player data with session locking
function DataStoreSystem.LoadPlayerData(userId: number): (boolean, Types.PlayerData?)
	local lockAcquired, token = AcquireSessionLock(userId)
	if not lockAcquired then
		warn(`[DataStore] Could not acquire session lock for user {userId}`)
		return false, nil
	end

	local success, data = pcall(function()
		return PlayerDataStore:GetAsync(`Player_{userId}`)
	end)

	ReleaseSessionLock(userId, token)

	if success and data then
		-- Validate data structure
		if DataStoreSystem.ValidatePlayerData(data) then
			DataStoreSystem.OnDataLoaded:Fire(userId, data)
			return true, data
		else
			warn(`[DataStore] Invalid data structure for user {userId}, attempting backup`)
			return DataStoreSystem.LoadFromBackup(userId)
		end
	elseif success and not data then
		-- New player
		return true, nil
	else
		warn(`[DataStore] Failed to load data for user {userId}: {data}`)
		DataStoreSystem.OnDataError:Fire(userId, "LoadFailed", data)
		return false, nil
	end
end

-- Load from backup
function DataStoreSystem.LoadFromBackup(userId: number): (boolean, Types.PlayerData?)
	local success, data = pcall(function()
		return BackupDataStore:GetAsync(`Player_{userId}`)
	end)

	if success and data and DataStoreSystem.ValidatePlayerData(data) then
		warn(`[DataStore] Restored from backup for user {userId}`)
		return true, data
	end

	return false, nil
end

-- Save player data
function DataStoreSystem.SavePlayerData(userId: number, playerData: Types.PlayerData): boolean
	if not SessionLocks[userId] then
		warn(`[DataStore] No session lock for user {userId}, attempting to acquire...`)
		local lockAcquired, token = AcquireSessionLock(userId)
		if not lockAcquired then
			-- Queue for later
			PendingSaves[userId] = playerData
			return false
		end
		-- Save with acquired lock
		local result = DataStoreSystem.SavePlayerDataInternal(userId, playerData, token)
		ReleaseSessionLock(userId, token)
		return result
	end

	-- We have the lock, save directly
	return DataStoreSystem.SavePlayerDataInternal(userId, playerData, GenerateSessionToken())
end

-- Internal save with token
function DataStoreSystem.SavePlayerDataInternal(userId: number, playerData: Types.PlayerData, token: string): boolean
	-- Update timestamp
	playerData.LastSaved = tick()

	local success, result = pcall(function()
		-- Save to main DataStore
		PlayerDataStore:SetAsync(`Player_{userId}`, playerData)

		-- Save to backup
		BackupDataStore:SetAsync(`Player_{userId}`, playerData)
	end)

	if success then
		PendingSaves[userId] = nil
		DataStoreSystem.OnDataSaved:Fire(userId)
		return true
	else
		warn(`[DataStore] Failed to save data for user {userId}: {result}`)
		DataStoreSystem.OnDataError:Fire(userId, "SaveFailed", result)
		-- Queue for retry
		PendingSaves[userId] = playerData
		return false
	end
end

-- Create new player data
function DataStoreSystem.CreateNewPlayerData(player: Player): Types.PlayerData
	local starterCreature = DataStoreSystem.GenerateStarterCreature()

	return {
		UserId = player.UserId,
		Username = player.Name,
		Money = 1000,
		Party = {starterCreature},
		Storage = {{}, {}, {}, {}, {}, {}, {}, {}}, -- 8 boxes
		CurrentZone = "StarterTown",
		PlayTime = 0,
		Badges = {},
		Settings = {
			MusicVolume = 0.7,
			SFXVolume = 0.8,
			BattleSpeed = 1.0,
			AutoSave = true,
			Language = "pt-BR",
		},
		LastSaved = tick(),
	}
end

-- Generate starter creature
function DataStoreSystem.GenerateStarterCreature(): Types.CreatureData
	-- Random starter from Common Fire, Water, Nature
	local starters = {"CINZELO", "HIDROSONDA", "VERDANTIS"}
	local speciesId = starters[math.random(#starters)]
	local speciesData = Config.SpeciesList[speciesId]

	local ivs = DataStoreSystem.GenerateIVs()
	local nature = DataStoreSystem.GetRandomNature()

	return {
		Id = game:GetService("HttpService"):GenerateGUID(false),
		SpeciesId = speciesId,
		Nickname = nil,
		Level = 5,
		Experience = 0,
		Stats = DataStoreSystem.CalculateStats(speciesData.BaseStats, ivs, {}, 5, nature),
		IVs = ivs,
		EVs = {HP = 0, Attack = 0, Defense = 0, SpecialAttack = 0, SpecialDefense = 0, Speed = 0},
		Nature = nature,
		Ability = speciesData.Abilities[1],
		Moves = DataStoreSystem.GetStartingMoves(speciesId, 5),
		CurrentHP = 0, -- Will be set to MaxHP
		Status = "None",
		State = "InParty",
		CaughtAt = tick(),
		CaughtLocation = "StarterTown",
		OriginalTrainer = "",
		IsShiny = math.random() < Config.Game.ShinyRate,
		Gender = "Male",
		EvolutionStage = 1,
		Friendship = 70,
	}
end

-- Generate random IVs (0-31)
function DataStoreSystem.GenerateIVs(): Types.IVs
	return {
		HP = math.random(0, 31),
		Attack = math.random(0, 31),
		Defense = math.random(0, 31),
		SpecialAttack = math.random(0, 31),
		SpecialDefense = math.random(0, 31),
		Speed = math.random(0, 31),
	}
end

-- Get random nature
function DataStoreSystem.GetRandomNature(): string
	local natures = {}
	for name in pairs(Config.Natures) do
		table.insert(natures, name)
	end
	return natures[math.random(#natures)]
end

-- Calculate stats from base, IVs, EVs, level, nature
function DataStoreSystem.CalculateStats(
	baseStats: Types.CreatureStats,
	ivs: Types.IVs,
	evs: Types.EVs,
	level: number,
	nature: string
): Types.CreatureStats
	local natureMod = Config.Natures[nature] or Config.Natures.Hardy

	local function calcStat(base: number, iv: number, ev: number, isHP: boolean): number
		if isHP then
			return math.floor(((2 * base + iv + math.floor(ev / 4)) * level) / 100) + level + 10
		else
			local stat = math.floor(((2 * base + iv + math.floor(ev / 4)) * level) / 100) + 5
			return math.floor(stat * (natureMod[isHP and "HP" or "Atk"] or 1.0))
		end
	end

	return {
		HP = calcStat(baseStats.HP, ivs.HP, evs.HP, true),
		Attack = calcStat(baseStats.Attack, ivs.Attack, evs.Attack, false),
		Defense = calcStat(baseStats.Defense, ivs.Defense, evs.Defense, false),
		SpecialAttack = calcStat(baseStats.SpecialAttack, ivs.SpecialAttack, evs.SpecialAttack, false),
		SpecialDefense = calcStat(baseStats.SpecialDefense, ivs.SpecialDefense, evs.SpecialDefense, false),
		Speed = calcStat(baseStats.Speed, ivs.Speed, evs.Speed, false),
	}
end

-- Get starting moves for species at level
function DataStoreSystem.GetStartingMoves(speciesId: string, level: number): {Types.Move}
	local speciesData = Config.SpeciesList[speciesId]
	local moves = {}

	if speciesData and speciesData.Learnset then
		for lvl, moveId in pairs(speciesData.Learnset) do
			if lvl <= level then
				table.insert(moves, DataStoreSystem.CreateMove(moveId))
			end
		end
	end

	-- Limit to 4 moves
	while #moves > 4 do
		table.remove(moves, 1)
	end

	return moves
end

-- Create move from ID
function DataStoreSystem.CreateMove(moveId: string): Types.Move
	-- Simplified move database
	local moveDatabase: {[string]: Types.Move} = {
		Tackle = {Id = "Tackle", Name = "Investida", Type = "Nature", Category = "Physical", Power = 40, Accuracy = 100, PP = 35, MaxPP = 35, Priority = 0},
		Ember = {Id = "Ember", Name = "Brasa", Type = "Fire", Category = "Special", Power = 40, Accuracy = 100, PP = 25, MaxPP = 25, Priority = 0, Effect = {Type = "Status", Params = {Status = "Burn"}, Chance = 10}},
		WaterGun = {Id = "WaterGun", Name = "Jato d'Água", Type = "Water", Category = "Special", Power = 40, Accuracy = 100, PP = 25, MaxPP = 25, Priority = 0},
		VineWhip = {Id = "VineWhip", Name = "Chicote de Vinha", Type = "Nature", Category = "Physical", Power = 45, Accuracy = 100, PP = 25, MaxPP = 25, Priority = 0},
		RockThrow = {Id = "RockThrow", Name = "Lançamento de Rocha", Type = "Earth", Category = "Physical", Power = 50, Accuracy = 90, PP = 15, MaxPP = 15, Priority = 0},
		Gust = {Id = "Gust", Name = "Ventania", Type = "Air", Category = "Special", Power = 40, Accuracy = 100, PP = 35, MaxPP = 35, Priority = 0},
		ShadowSneak = {Id = "ShadowSneak", Name = "Golpe Sombrio", Type = "Shadow", Category = "Physical", Power = 40, Accuracy = 100, PP = 30, MaxPP = 30, Priority = 1},
	}

	return moveDatabase[moveId] or moveDatabase.Tackle
end

-- Validate player data structure
function DataStoreSystem.ValidatePlayerData(data: any): boolean
	if type(data) ~= "table" then return false end
	if type(data.UserId) ~= "number" then return false end
	if type(data.Money) ~= "number" then return false end
	if type(data.Party) ~= "table" then return false end
	if type(data.Storage) ~= "table" then return false end
	if type(data.Settings) ~= "table" then return false end
	return true
end

-- Auto-save loop
task.spawn(function()
	while true do
		task.wait(SAVE_INTERVAL)

		for userId, playerData in pairs(PendingSaves) do
			if SessionLocks[userId] then
				DataStoreSystem.SavePlayerData(userId, playerData)
			else
				local lockAcquired, token = AcquireSessionLock(userId)
				if lockAcquired then
					DataStoreSystem.SavePlayerDataInternal(userId, playerData, token)
					ReleaseSessionLock(userId, token)
				end
			end
		end

		-- Also save all loaded players periodically
		-- (In production, this would iterate through active players)
	end
end)

-- Process pending saves on player leave
function DataStoreSystem.ProcessPendingSaves(userId: number)
	local playerData = PendingSaves[userId]
	if playerData then
		DataStoreSystem.SavePlayerData(userId, playerData)
	end
end

return DataStoreSystem