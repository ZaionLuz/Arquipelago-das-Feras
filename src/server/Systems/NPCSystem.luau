--!strict
-- NPCSystem.lua - Sistema de NPCs (treinadores, lojistas, curandeiros, quest givers)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CollectionService = game:GetService("CollectionService")

local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local CreatureSystem = require(script.Parent.CreatureSystem)
local PartySystem = require(script.Parent.PartySystem)
local ItemSystem = require(script.Parent.ItemSystem)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local NPCSystem = {}

-- Events
NPCSystem.OnNPCTalked = Signal.New()
NPCSystem.OnTradeOpened = Signal.New()
NPCSystem.OnQuestAccepted = Signal.New()
NPCSystem.OnQuestCompleted = Signal.New()

-- State
local NPCs = {} :: {[string]: {Model: Model, Data: Types.NPCData, Connections: {RBXScriptConnection}}}
local PlayerInteractions = {} :: {[number]: {NPCId: string, InteractionType: string}}

-- Initialize
function NPCSystem.Initialize()
	print("[NPCSystem] Initializing...")

	-- Load NPCs from config
	NPCSystem.LoadNPCsFromConfig()

	-- Setup interaction detection
	NPCSystem.SetupInteractionDetection()

	-- Handle player leaving
	Players.PlayerRemoving:Connect(function(player)
		PlayerInteractions[player.UserId] = nil
	end)

	print("[NPCSystem] Initialized")
end

function NPCSystem.LoadNPCsFromConfig()
	for zoneId, zoneData in pairs(Config.Zones) do
		if zoneData.NPCs then
			for _, npcData in ipairs(zoneData.NPCs) do
				NPCSystem.SpawnNPC(npcData, zoneId)
			end
		end
	end
end

function NPCSystem.SpawnNPC(npcData: Types.NPCData, zoneId: string)
	-- Create NPC model
	local model = Instance.new("Model")
	model.Name = npcData.Id
	model.Parent = workspace

	-- Humanoid for animation/pathfinding
	local humanoid = Instance.new("Humanoid")
	humanoid.Name = "Humanoid"
	humanoid.DisplayDistanceType = Enum.HumanoidDisplayDistanceType.None
	humanoid.WalkSpeed = 0 -- Stationary by default
	humanoid.Parent = model

	-- Root part - adjust position relative to island center if needed
	local zoneData = Config.Zones[zoneId]
	local npcPosition = npcData.Position
	if zoneData and zoneData.IslandPosition then
		-- If NPC position is relative to zone center, adjust
		local isRelative = (npcPosition.Position - zoneData.IslandPosition).Magnitude < 500
		if isRelative then
			npcPosition = CFrame.new(zoneData.IslandPosition + npcPosition.Position)
		end
	end

	local rootPart = Instance.new("Part")
	rootPart.Name = "HumanoidRootPart"
	rootPart.Size = Vector3.new(2, 2, 1)
	rootPart.Transparency = 1
	rootPart.CanCollide = false
	rootPart.Anchored = true
	rootPart.CFrame = npcPosition
	rootPart.Parent = model

	model.PrimaryPart = rootPart

	-- Visual representation (placeholder)
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = Vector3.new(2, 4, 1)
	body.Position = npcData.Position.Position + Vector3.new(0, 2, 0)
	body.Anchored = true
	body.CanCollide = false
	body.Material = Enum.Material.Neon
	body.Color = NPCSystem.GetNPCColor(npcData.Type)
	body.Parent = model

	-- Name tag
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NameTag"
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.Adornee = body
	billboard.AlwaysOnTop = true
	billboard.Parent = model

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 1, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = npcData.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextStrokeTransparency = 0
	nameLabel.Parent = billboard

	-- Type icon
	local typeIcons = {
		Trainer = "⚔️",
		Shopkeeper = "🏪",
		Healer = "❤️",
		QuestGiver = "📜",
	}

	local iconLabel = Instance.new("TextLabel")
	iconLabel.Size = UDim2.new(0, 30, 0, 30)
	iconLabel.Position = UDim2.new(1, -35, 0, 0)
	iconLabel.BackgroundTransparency = 1
	iconLabel.Text = typeIcons[npcData.Type] or "👤"
	iconLabel.TextScaled = true
	iconLabel.Parent = billboard

	-- Proximity prompt for interaction
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = NPCSystem.GetInteractionText(npcData.Type)
	prompt.ObjectText = npcData.Name
	prompt.MaxActivationDistance = 10
	prompt.KeyboardKeyCode = Enum.KeyCode.E
	prompt.Parent = body

	prompt.Triggered:Connect(function(player)
		NPCSystem.OnPlayerInteract(player, npcData.Id, npcData.Type)
	end)

	-- Store NPC data
	NPCs[npcData.Id] = {
		Model = model,
		Data = npcData,
		Connections = {},
	}

	-- Setup patrol if trainer
	if npcData.Type == "Trainer" and npcData.Team then
		NPCSystem.SetupTrainerBehavior(npcData.Id, npcData)
	end

	print(`[NPCSystem] Spawned NPC: {npcData.Name} ({npcData.Type}) at {npcData.Position}`)
end

function NPCSystem.GetNPCColor(npcType: string): Color3
	local colors = {
		Trainer = Color3.fromRGB(255, 100, 100),
		Shopkeeper = Color3.fromRGB(100, 255, 100),
		Healer = Color3.fromRGB(100, 200, 255),
		QuestGiver = Color3.fromRGB(255, 255, 100),
	}
	return colors[npcType] or Color3.fromRGB(200, 200, 200)
end

function NPCSystem.GetInteractionText(npcType: string): string
	local texts = {
		Trainer = "Desafiar",
		Shopkeeper = "Comprar",
		Healer = "Curar",
		QuestGiver = "Conversar",
	}
	return texts[npcType] or "Interagir"
end

function NPCSystem.SetupInteractionDetection()
	-- Global interaction handler via RemoteEvent
	local remote = ReplicatedStorage:FindFirstChild("Remotes")
	if remote then
		local interactRemote = remote:FindFirstChild("InteractNPC")
		if not interactRemote then
			interactRemote = Instance.new("RemoteFunction")
			interactRemote.Name = "InteractNPC"
			interactRemote.Parent = remote
		end

		interactRemote.OnServerInvoke = function(player: Player, npcId: string)
			local npc = NPCs[npcId]
			if not npc then return {Success = false, Error = "NPC not found"} end

			-- Check distance
			if player.Character and player.Character.PrimaryPart then
				local dist = (player.Character.PrimaryPart.Position - npc.Model.PrimaryPart.Position).Magnitude
				if dist > 15 then
					return {Success = false, Error = "Too far"}
				end
			end

			return NPCSystem.HandleInteraction(player, npcId, npc.Data.Type)
		end
	end
end

function NPCSystem.OnPlayerInteract(player: Player, npcId: string, npcType: string)
	-- Called from ProximityPrompt
	NPCSystem.HandleInteraction(player, npcId, npcType)
end

function NPCSystem.HandleInteraction(player: Player, npcId: string, npcType: string): any
	local npc = NPCs[npcId]
	if not npc then return end

	PlayerInteractions[player.UserId] = {
		NPCId = npcId,
		InteractionType = npcType,
		StartTime = tick(),
	}

	NPCSystem.OnNPCTalked:Fire(player, npcId, npcType)

	if npcType == "Healer" then
		return NPCSystem.HandleHealer(player, npc)
	elseif npcType == "Shopkeeper" then
		return NPCSystem.HandleShopkeeper(player, npc)
	elseif npcType == "Trainer" then
		return NPCSystem.HandleTrainer(player, npc)
	elseif npcType == "QuestGiver" then
		return NPCSystem.HandleQuestGiver(player, npc)
	end

	return {Success = true}
end

function NPCSystem.HandleHealer(player: Player, npc: any)
	local partySystem = require(script.Parent.PartySystem)
	local party = partySystem.GetPlayerParty(player)

	local healed = 0
	for _, creature in ipairs(party) do
		if creature.CurrentHP < creature.MaxHP or creature.StatusCondition ~= "None" then
			creature.CurrentHP = creature.MaxHP
			creature.StatusCondition = "None"
			healed += 1
		end
	end

	-- Also heal storage
	local storage = partySystem.GetPlayerStorage(player)
	for _, box in ipairs(storage) do
		for _, creature in ipairs(box) do
			if creature.CurrentHP < creature.MaxHP or creature.StatusCondition ~= "None" then
				creature.CurrentHP = creature.MaxHP
				creature.StatusCondition = "None"
			end
		end
	end

	-- Fire client event for UI
	local remote = ReplicatedStorage:FindFirstChild("Remotes")
	if remote then
		local healRemote = remote:FindFirstChild("NPCHealComplete")
		if not healRemote then
			healRemote = Instance.new("RemoteEvent")
			healRemote.Name = "NPCHealComplete"
			healRemote.Parent = remote
		end
		healRemote:FireClient(player, healed)
	end

	return {Success = true, Healed = healed, Message = `Suas {healed} criaturas foram curadas!`}
end

function NPCSystem.HandleShopkeeper(player: Player, npc: any)
	-- Return shop inventory
	local shopInventory = npc.Data.ShopInventory or {}

	-- Get item details
	local items = {}
	for _, itemId in ipairs(shopInventory) do
		local itemConfig = Config.Items[itemId]
		if itemConfig then
			table.insert(items, {
				Id = itemConfig.Id,
				Name = itemConfig.Name,
				Description = itemConfig.Description,
				Price = itemConfig.Price,
				Type = itemConfig.Type,
			})
		end
	end

	return {Success = true, Items = items, NPCName = npc.Data.Name}
end

function NPCSystem.HandleTrainer(player: Player, npc: any)
	-- Check if already battled today
	local playerData = require(script.Parent.DataStoreSystem).LoadPlayerData(player.UserId)
	local battledTrainers = playerData.BattledTrainers or {}

	if battledTrainers[npc.Data.Id] then
		return {Success = false, Message = "Você já desafiou este treinador hoje!"}
	end

	-- Start trainer battle
	local battleSystem = require(script.Parent.BattleSystem)
	local battleData = battleSystem.StartTrainerBattle(player, {
		TrainerId = npc.Data.Id,
		TrainerName = npc.Data.Name,
		Team = npc.Data.Team,
		RewardMoney = npc.Data.RewardMoney or 500,
		RewardItems = npc.Data.RewardItems or {},
		Dialogue = npc.Data.Dialogue or {},
	})

	return {Success = true, BattleId = battleData.Id}
end

function NPCSystem.HandleQuestGiver(player: Player, npc: any)
	-- Return available quests
	local questSystem = require(script.Parent.QuestSystem)
	local availableQuests = questSystem.GetAvailableQuests(player, npc.Data.Id)

	return {Success = true, Quests = availableQuests, NPCName = npc.Data.Name}
end

-- Trainer behavior (patrol, look at player)
function NPCSystem.SetupTrainerBehavior(npcId: string, npcData: Types.NPCData)
	local model = NPCs[npcId]?.Model
	if not model then return end

	local humanoid = model:FindFirstChild("Humanoid")
	if not humanoid then return end

	-- Simple patrol
	local patrolPoints = npcData.PatrolPoints or {}
	if #patrolPoints > 1 then
		task.spawn(function()
			local currentPoint = 1
			while NPCs[npcId] and model.Parent do
				local target = patrolPoints[currentPoint]
				if target then
					humanoid:MoveTo(target)
					humanoid.MoveToFinished:Wait()
				end
				currentPoint = (currentPoint % #patrolPoints) + 1
				task.wait(math.random(5, 15))
			end
		end)
	end

	-- Look at nearby players
	RunService.Heartbeat:Connect(function()
		if not model.Parent then return end

		for _, player in ipairs(Players:GetPlayers()) do
			if player.Character and player.Character.PrimaryPart then
				local dist = (player.Character.PrimaryPart.Position - model.PrimaryPart.Position).Magnitude
				if dist < 20 then
					-- Face player
					local lookAt = CFrame.new(model.PrimaryPart.Position,
						Vector3.new(player.Character.PrimaryPart.Position.X, model.PrimaryPart.Position.Y, player.Character.PrimaryPart.Position.Z))
					model.PrimaryPart.CFrame = lookAt
					break
				end
			end
		end
	end)
end

-- Get NPC data
function NPCSystem.GetNPC(npcId: string): Types.NPCData?
	return NPCs[npcId]?.Data
end

function NPCSystem.GetAllNPCs(): {Types.NPCData}
	local result = {}
	for _, npc in pairs(NPCs) do
		table.insert(result, npc.Data)
	end
	return result
end

-- Cleanup
function NPCSystem.Cleanup()
	for npcId, npc in pairs(NPCs) do
		for _, conn in ipairs(npc.Connections) do
			conn:Disconnect()
		end
		npc.Model:Destroy()
	end
	NPCs = {}
	PlayerInteractions = {}
end

return NPCSystem