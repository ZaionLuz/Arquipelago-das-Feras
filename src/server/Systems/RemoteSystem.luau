--!strict
-- RemoteSystem.lua - Gerenciamento de RemoteEvents/Functions tipados

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local RemoteSystem = {}

-- Remote instances
local Remotes = {} :: {[string]: RemoteEvent | RemoteFunction}
local RemoteFolder: Folder

-- Event handlers
local EventHandlers = {} :: {[string]: (...any) -> ...any}
local FunctionHandlers = {} :: {[string]: (...any) -> ...any}

-- Initialize remotes
function RemoteSystem.Initialize()
	RemoteFolder = Instance.new("Folder")
	RemoteFolder.Name = "Remotes"
	RemoteFolder.Parent = ReplicatedStorage

	-- Create all remotes
	RemoteSystem.CreateRemotes()

	-- Connect server listeners
	RemoteSystem.ConnectServerListeners()

	print("[RemoteSystem] Initialized with " .. #TableUtil.Keys(Remotes) .. " remotes")
end

-- Helper
local TableUtil = require(ReplicatedStorage.Shared.Util.Table)

-- Create all remote events/functions
function RemoteSystem.CreateRemotes()
	local remoteDefs = {
		-- Data
		DataLoaded = {Type = "Event", ClientToServer = false},
		RequestData = {Type = "Function", ClientToServer = true},
		SaveGame = {Type = "Function", ClientToServer = true},

		-- Party
		GetParty = {Type = "Function", ClientToServer = true},
		GetStorage = {Type = "Function", ClientToServer = true},
		SwapParty = {Type = "Event", ClientToServer = true},
		MoveToStorage = {Type = "Event", ClientToServer = true},
		MoveToParty = {Type = "Event", ClientToServer = true},
		ReleaseCreature = {Type = "Event", ClientToServer = true},
		NicknameCreature = {Type = "Event", ClientToServer = true},

		-- Creatures
		CaptureCreature = {Type = "Function", ClientToServer = true},
		GetCreatureInfo = {Type = "Function", ClientToServer = true},
		HealCreature = {Type = "Event", ClientToServer = true},
		EvolveCreature = {Type = "Function", ClientToServer = true},
		LearnMove = {Type = "Event", ClientToServer = true},
		ReplaceMove = {Type = "Event", ClientToServer = true},

		-- Battle
		StartBattle = {Type = "Function", ClientToServer = true},
		BattleAction = {Type = "Function", ClientToServer = true},
		GetBattleState = {Type = "Function", ClientToServer = true},
		ForfeitBattle = {Type = "Event", ClientToServer = true},

		-- Items
		GetInventory = {Type = "Function", ClientToServer = true},
		UseItem = {Type = "Function", ClientToServer = true},
		BuyItem = {Type = "Event", ClientToServer = true},
		SellItem = {Type = "Event", ClientToServer = true},

		-- Spawn/World
		GetNearbyCreatures = {Type = "Function", ClientToServer = true},
		RequestSpawn = {Type = "Event", ClientToServer = true},

		-- Player
		GetPlayerData = {Type = "Function", ClientToServer = true},
		UpdateSettings = {Type = "Event", ClientToServer = true},

		-- Social/Trading (future)
		RequestTrade = {Type = "Event", ClientToServer = true},
		AcceptTrade = {Type = "Event", ClientToServer = true},
		CancelTrade = {Type = "Event", ClientToServer = true},
	}

	for name, def in pairs(remoteDefs) do
		local remote: RemoteEvent | RemoteFunction

		if def.Type == "Event" then
			remote = Instance.new("RemoteEvent")
		else
			remote = Instance.new("RemoteFunction")
		end

		remote.Name = name
		remote.Parent = RemoteFolder
		Remotes[name] = remote
	end
end

-- Connect server-side listeners
function RemoteSystem.ConnectServerListeners()
	-- Data
	RemoteSystem.OnServerInvoke("RequestData", function(player: Player)
		local dataStoreSystem = require(script.Parent.DataStoreSystem)
		return dataStoreSystem.LoadPlayerData(player.UserId)
	end)

	RemoteSystem.OnServerInvoke("SaveGame", function(player: Player)
		local dataStoreSystem = require(script.Parent.DataStoreSystem)
		-- Player data is saved automatically, but can force save
		return true
	end)

	-- Party
	RemoteSystem.OnServerInvoke("GetParty", function(player: Player)
		local partySystem = require(script.Parent.PartySystem)
		return partySystem.GetPartySummary(player)
	end)

	RemoteSystem.OnServerInvoke("GetStorage", function(player: Player, boxIndex: number?)
		local partySystem = require(script.Parent.PartySystem)
		if boxIndex then
			return partySystem.GetStorageBox(player, boxIndex)
		else
			return partySystem.GetPlayerStorage(player)
		end
	end)

	RemoteSystem.OnServerEvent("SwapParty", function(player: Player, index1: number, index2: number)
		local partySystem = require(script.Parent.PartySystem)
		return partySystem.SwapPartyMembers(player, index1, index2)
	end)

	RemoteSystem.OnServerEvent("MoveToStorage", function(player: Player, creatureId: string)
		local partySystem = require(script.Parent.PartySystem)
		return partySystem.MoveCreature(player, creatureId, "Party", "Storage")
	end)

	RemoteSystem.OnServerEvent("MoveToParty", function(player: Player, creatureId: string, boxIndex: number?)
		local partySystem = require(script.Parent.PartySystem)
		return partySystem.MoveCreature(player, creatureId, "Storage", "Party", boxIndex)
	end)

	RemoteSystem.OnServerEvent("ReleaseCreature", function(player: Player, creatureId: string)
		local partySystem = require(script.Parent.PartySystem)
		return partySystem.ReleaseCreature(player, creatureId)
	end)

	RemoteSystem.OnServerEvent("NicknameCreature", function(player: Player, creatureId: string, nickname: string)
		local partySystem = require(script.Parent.PartySystem)
		local party = partySystem.GetPlayerParty(player)
		for _, creature in ipairs(party) do
			if creature.Id == creatureId then
				creature.Nickname = nickname
				return true
			end
		end
		-- Check storage
		for _, box in ipairs(partySystem.GetPlayerStorage(player)) do
			for _, creature in ipairs(box) do
				if creature.Id == creatureId then
					creature.Nickname = nickname
					return true
				end
			end
		end
		return false
	end)

	-- Creatures
	RemoteSystem.OnServerInvoke("CaptureCreature", function(player: Player, spawnId: string, ballType: string)
		local creatureSystem = require(script.Parent.CreatureSystem)
		return creatureSystem.AttemptCapture(player, spawnId, ballType)
	end)

	RemoteSystem.OnServerInvoke("GetCreatureInfo", function(player: Player, creatureId: string)
		local partySystem = require(script.Parent.PartySystem)
		-- Search party
		for _, creature in ipairs(partySystem.GetPlayerParty(player)) do
			if creature.Id == creatureId then
				return creature
			end
		end
		-- Search storage
		for _, box in ipairs(partySystem.GetPlayerStorage(player)) do
			for _, creature in ipairs(box) do
				if creature.Id == creatureId then
					return creature
				end
			end
		end
		return nil
	end)

	RemoteSystem.OnServerEvent("HealCreature", function(player: Player, creatureId: string)
		-- Would use healing item or heal at center
		return true
	end)

	RemoteSystem.OnServerInvoke("EvolveCreature", function(player: Player, creatureId: string)
		local evolutionSystem = require(script.Parent.EvolutionSystem)
		return evolutionSystem.AttemptEvolution(player, creatureId)
	end)

	RemoteSystem.OnServerEvent("LearnMove", function(player: Player, creatureId: string, moveId: string, replaceIndex: number?)
		-- Implementation for learning moves
		return true
	end)

	RemoteSystem.OnServerEvent("ReplaceMove", function(player: Player, creatureId: string, oldMoveIndex: number, newMoveId: string)
		-- Implementation for replacing moves
		return true
	end)

	-- Battle
	RemoteSystem.OnServerInvoke("StartBattle", function(player: Player, enemyType: string, enemyData: any)
		local battleSystem = require(script.Parent.BattleSystem)
		if enemyType == "Wild" then
			return battleSystem.StartWildBattle(player, enemyData)
		else
			return battleSystem.StartTrainerBattle(player, enemyData)
		end
	end)

	RemoteSystem.OnServerInvoke("BattleAction", function(player: Player, battleId: string, action: Types.BattleAction)
		local battleSystem = require(script.Parent.BattleSystem)
		return battleSystem.ProcessAction(battleId, action)
	end)

	RemoteSystem.OnServerInvoke("GetBattleState", function(player: Player, battleId: string)
		local battleSystem = require(script.Parent.BattleSystem)
		local battle = battleSystem.GetBattle(battleId)
		if battle then
			-- Return sanitized battle state (hide enemy info if needed)
			return battle
		end
		return nil
	end)

	RemoteSystem.OnServerEvent("ForfeitBattle", function(player: Player, battleId: string)
		local battleSystem = require(script.Parent.BattleSystem)
		battleSystem.EndBattle(battleId, "EnemyWon")
	end)

	-- Items
	RemoteSystem.OnServerInvoke("GetInventory", function(player: Player)
		local itemSystem = require(script.Parent.ItemSystem)
		return itemSystem.GetInventoryWithInfo(player)
	end)

	RemoteSystem.OnServerInvoke("UseItem", function(player: Player, itemId: string, targetCreatureId: string?)
		local itemSystem = require(script.Parent.ItemSystem)
		return itemSystem.UseItem(player, itemId, targetCreatureId)
	end)

	RemoteSystem.OnServerEvent("BuyItem", function(player: Player, itemId: string, count: number)
		-- Shop system would handle this
		return false
	end)

	RemoteSystem.OnServerEvent("SellItem", function(player: Player, itemId: string, count: number)
		-- Shop system would handle this
		return false
	end)

	-- Spawn
	RemoteSystem.OnServerInvoke("GetNearbyCreatures", function(player: Player)
		local spawnSystem = require(script.Parent.SpawnSystem)
		if not player.Character or not player.Character.PrimaryPart then return {} end

		-- Find creatures near player
		-- Simplified - would check distance
		return {}
	end)

	-- Player
	RemoteSystem.OnServerInvoke("GetPlayerData", function(player: Player)
		local dataStoreSystem = require(script.Parent.DataStoreSystem)
		return dataStoreSystem.LoadPlayerData(player.UserId)
	end)

	RemoteSystem.OnServerEvent("UpdateSettings", function(player: Player, settings: Types.PlayerSettings)
		local dataStoreSystem = require(script.Parent.DataStoreSystem)
		local success, data = dataStoreSystem.LoadPlayerData(player.UserId)
		if success and data then
			data.Settings = settings
			dataStoreSystem.SavePlayerData(player.UserId, data)
		end
	end)
end

-- Server event listener
function RemoteSystem.OnServerEvent(name: string, handler: (Player, ...any) -> ...any)
	local remote = Remotes[name]
	if remote and remote:IsA("RemoteEvent") then
		remote.OnServerEvent:Connect(handler)
		EventHandlers[name] = handler
	else
		warn(`[RemoteSystem] RemoteEvent not found: {name}`)
	end
end

-- Server function listener
function RemoteSystem.OnServerInvoke(name: string, handler: (Player, ...any) -> ...any)
	local remote = Remotes[name]
	if remote and remote:IsA("RemoteFunction") then
		remote.OnServerInvoke = handler
		FunctionHandlers[name] = handler
	else
		warn(`[RemoteSystem] RemoteFunction not found: {name}`)
	end
end

-- Fire to specific client
function RemoteSystem.FireClient(player: Player, name: string, ...: any)
	local remote = Remotes[name]
	if remote and remote:IsA("RemoteEvent") then
		remote:FireClient(player, ...)
	else
		warn(`[RemoteSystem] Cannot fire client - remote not found: {name}`)
	end
end

-- Fire to all clients
function RemoteSystem.FireAllClients(name: string, ...: any)
	local remote = Remotes[name]
	if remote and remote:IsA("RemoteEvent") then
		remote:FireAllClients(...)
	else
		warn(`[RemoteSystem] Cannot fire all - remote not found: {name}`)
	end
end

-- Fire to all clients except one
function RemoteSystem.FireAllClientsExcept(excludePlayer: Player, name: string, ...: any)
	local remote = Remotes[name]
	if remote and remote:IsA("RemoteEvent") then
		for _, player in ipairs(Players:GetPlayers()) do
			if player ~= excludePlayer then
				remote:FireClient(player, ...)
			end
		end
	else
		warn(`[RemoteSystem] Cannot fire all except - remote not found: {name}`)
	end
end

-- Invoke client (with timeout)
function RemoteSystem.InvokeClient(player: Player, name: string, timeout: number?, ...: any): (...any)
	local remote = Remotes[name]
	if remote and remote:IsA("RemoteFunction") then
		local thread = coroutine.running()
		local result = {nil}
		local completed = false

		task.spawn(function()
			local success, res = pcall(function()
				return remote:InvokeClient(player, ...)
			end)
			if success then
				result = {res}
			else
				result = {nil, res}
			end
			completed = true
			if coroutine.status(thread) == "suspended" then
				task.spawn(thread)
			end
		end)

		if not completed then
			task.wait(timeout or 10)
		end

		if not completed then
			return nil, "Timeout"
		end

		return unpack(result)
	else
		warn(`[RemoteSystem] Cannot invoke client - remote not found: {name}`)
		return nil, "Remote not found"
	end
end

-- Get remote instance (for client-side)
function RemoteSystem.GetRemote(name: string): RemoteEvent | RemoteFunction?
	return Remotes[name]
end

return RemoteSystem