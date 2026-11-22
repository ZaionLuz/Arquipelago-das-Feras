--!strict
-- Server Entry Point - Arquipélago das Feras

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

-- Load shared modules
local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local MathUtil = require(ReplicatedStorage.Shared.Util.Math)
local TableUtil = require(ReplicatedStorage.Shared.Util.Table)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

-- Load server systems
local DataStoreSystem = require(ServerScriptService.Server.Systems.DataStoreSystem)
local CreatureSystem = require(ServerScriptService.Server.Systems.CreatureSystem)
local BattleSystem = require(ServerScriptService.Server.Systems.BattleSystem)
local SpawnSystem = require(ServerScriptService.Server.Systems.SpawnSystem)
local PartySystem = require(ServerScriptService.Server.Systems.PartySystem)
local ItemSystem = require(ServerScriptService.Server.Systems.ItemSystem)
local EvolutionSystem = require(ServerScriptService.Server.Systems.EvolutionSystem)
local RemoteSystem = require(ServerScriptService.Server.Systems.RemoteSystem)

-- Server state
local ServerState = {
	IsInitialized = false,
	PlayerData = {} :: {[number]: Types.PlayerData},
	ActiveBattles = {} :: {[string]: Types.BattleData},
	SpawnedCreatures = {} :: {[string]: Model},
}

-- Initialize remotes
RemoteSystem.Initialize()

-- Player joining
Players.PlayerAdded:Connect(function(player: Player)
	print(`[Server] Player joined: {player.Name}`)

	-- Load player data
	local success, playerData = DataStoreSystem.LoadPlayerData(player.UserId)
	if success and playerData then
		ServerState.PlayerData[player.UserId] = playerData
		print(`[Server] Loaded data for {player.Name}`)
	else
		-- Create new player data
		playerData = DataStoreSystem.CreateNewPlayerData(player)
		ServerState.PlayerData[player.UserId] = playerData
		print(`[Server] Created new data for {player.Name}`)
	end

	-- Initialize party system for player
	PartySystem.InitializePlayer(player, playerData)

	-- Fire client loaded event
	RemoteSystem.FireClient(player, "DataLoaded", playerData)
end)

-- Player leaving
Players.PlayerRemoving:Connect(function(player: Player)
	print(`[Server] Player leaving: {player.Name}`)

	-- Save player data
	local playerData = ServerState.PlayerData[player.UserId]
	if playerData then
		DataStoreSystem.SavePlayerData(player.UserId, playerData)
		ServerState.PlayerData[player.UserId] = nil
	end

	-- Clean up any active battles
	for battleId, battle in pairs(ServerState.ActiveBattles) do
		if battle.PlayerSide then
			for _, participant in ipairs(battle.PlayerSide) do
				if participant.Creature and participant.Creature.Id == player.UserId then
					BattleSystem.EndBattle(battleId, "PlayerLeft")
					break
				end
			end
		end
	end

	PartySystem.CleanupPlayer(player)
end)

-- Game closing
game:BindToClose(function()
	print("[Server] Game closing, saving all player data...")
	for userId, playerData in pairs(ServerState.PlayerData) do
		DataStoreSystem.SavePlayerData(userId, playerData)
	end
	task.wait(2)
end)

-- Heartbeat for systems that need it
RunService.Heartbeat:Connect(function(deltaTime: number)
	SpawnSystem.Update(deltaTime)
	BattleSystem.Update(deltaTime)
end)

-- Initialize spawn system
SpawnSystem.Initialize()

ServerState.IsInitialized = true
print("[Server] Arquipélago das Feras server initialized!")

return nil