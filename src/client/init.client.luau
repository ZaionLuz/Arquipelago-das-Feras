--!strict
-- Client Entry Point - Arquipélago das Feras

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")

-- Load shared modules
local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local MathUtil = require(ReplicatedStorage.Shared.Util.Math)
local TableUtil = require(ReplicatedStorage.Shared.Util.Table)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

-- Load client controllers
local UIController = require(script.Parent.Controllers.UIController)
local PlayerController = require(script.Parent.Controllers.PlayerController)
local CreatureController = require(script.Parent.Controllers.CreatureController)
local BattleController = require(script.Parent.Controllers.BattleController)
local WorldController = require(script.Parent.Controllers.WorldController)
local InputController = require(script.Parent.Controllers.InputController)
local CameraController = require(script.Parent.Controllers.CameraController)
local AudioController = require(script.Parent.Controllers.AudioController)
local RemoteClient = require(script.Parent.Controllers.RemoteClient)
local QuestController = require(script.Parent.Controllers.QuestController)

local Player = Players.LocalPlayer

-- Client state
local ClientState = {
	IsLoaded = false,
	PlayerData = nil :: Types.PlayerData?,
	CurrentScreen = "Loading",
	ActiveBattle = nil :: Types.BattleData?,
}

-- Initialize remote client
RemoteClient.Initialize()

-- Wait for data loaded from server
RemoteClient.On("DataLoaded", function(playerData: Types.PlayerData)
	ClientState.PlayerData = playerData
	ClientState.IsLoaded = true

	print(`[Client] Data loaded for {Player.Name}`)

	-- Initialize controllers
	UIController.Initialize(playerData)
	PlayerController.Initialize(playerData)
	CreatureController.Initialize(playerData)
	BattleController.Initialize()
	WorldController.Initialize()
	InputController.Initialize()
	CameraController.Initialize()
	AudioController.Initialize()
	QuestController.Initialize()

	-- Show main menu or game UI
	UIController.ShowScreen("MainMenu")

	ClientState.CurrentScreen = "MainMenu"
end)

-- Request initial data
task.spawn(function()
	task.wait(1)
	RemoteClient.Invoke("RequestData")
end)

-- Handle battle state changes
RemoteClient.On("BattleStarted", function(battleData: Types.BattleData)
	ClientState.ActiveBattle = battleData
	ClientState.CurrentScreen = "Battle"
	UIController.ShowScreen("Battle")
	BattleController.StartBattle(battleData)
end)

RemoteClient.On("BattleEnded", function(battleData: Types.BattleData, result: string)
	ClientState.ActiveBattle = nil
	ClientState.CurrentScreen = "Gameplay"
	UIController.ShowScreen("Gameplay")
	BattleController.EndBattle(result)
end)

RemoteClient.On("BattleUpdate", function(battleData: Types.BattleData)
	ClientState.ActiveBattle = battleData
	BattleController.UpdateBattle(battleData)
end)

-- Handle creature spawns
RemoteClient.On("CreatureSpawned", function(spawnId: string, creature: Types.CreatureData, position: Vector3)
	WorldController.OnCreatureSpawned(spawnId, creature, position)
end)

RemoteClient.On("CreatureDespawned", function(spawnId: string)
	WorldController.OnCreatureDespawned(spawnId)
end)

-- Handle party updates
RemoteClient.On("PartyChanged", function(partySummary: any)
	CreatureController.OnPartyChanged(partySummary)
	UIController.UpdatePartyUI(partySummary)
end)

-- Handle creature capture
RemoteClient.On("CreatureCaptured", function(creature: Types.CreatureData)
	CreatureController.OnCreatureCaptured(creature)
	UIController.ShowCaptureAnimation(creature)
end)

-- Handle evolution
RemoteClient.On("CreatureEvolved", function(oldSpecies: string, newSpecies: string, creature: Types.CreatureData)
	CreatureController.OnCreatureEvolved(creature)
	UIController.ShowEvolutionAnimation(oldSpecies, newSpecies, creature)
end)

-- Handle level up
RemoteClient.On("CreatureLevelUp", function(creature: Types.CreatureData, oldLevel: number, newLevel: number)
	CreatureController.OnCreatureLevelUp(creature, oldLevel, newLevel)
	UIController.ShowLevelUpAnimation(creature, oldLevel, newLevel)
end)

-- Input handling
UserInputService.InputBegan:Connect(function(input: InputObject, gameProcessed: boolean)
	if gameProcessed then return end

	InputController.HandleInput(input, "Began")
end)

UserInputService.InputEnded:Connect(function(input: InputObject, gameProcessed: boolean)
	InputController.HandleInput(input, "Ended")
end)

-- Game loop
RunService.RenderStepped:Connect(function(deltaTime: number)
	if not ClientState.IsLoaded then return end

	WorldController.Update(deltaTime)
	CameraController.Update(deltaTime)

	if ClientState.ActiveBattle then
		BattleController.Update(deltaTime)
	end
end)

-- Character loaded
Player.CharacterAdded:Connect(function(character)
	PlayerController.OnCharacterAdded(character)
	CameraController.OnCharacterAdded(character)
end)

if Player.Character then
	PlayerController.OnCharacterAdded(Player.Character)
	CameraController.OnCharacterAdded(Player.Character)
end

print("[Client] Arquipélago das Feras client initialized!")

return nil