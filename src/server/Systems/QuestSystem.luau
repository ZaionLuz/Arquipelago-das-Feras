--!strict
-- QuestSystem.lua - Sistema de missões/quests

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local PartySystem = require(script.Parent.PartySystem)
local ItemSystem = require(script.Parent.ItemSystem)
local DataStoreSystem = require(script.Parent.DataStoreSystem)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local QuestSystem = {}

-- Events
QuestSystem.OnQuestAccepted = Signal.New()
QuestSystem.OnQuestProgress = Signal.New()
QuestSystem.OnQuestCompleted = Signal.New()
QuestSystem.OnQuestFailed = Signal.New()
QuestSystem.OnQuestTurnedIn = Signal.New()

-- State
local ActiveQuests = {} :: {[number]: {Types.QuestData}} -- PlayerId -> Quests
local QuestDefinitions = {} :: {[string]: Types.QuestData}

-- Initialize
function QuestSystem.Initialize()
	print("[QuestSystem] Initializing...")

	-- Load quest definitions
	QuestSystem.LoadQuestDefinitions()

	-- Setup event listeners
	QuestSystem.SetupEventListeners()

	print("[QuestSystem] Initialized")
end

function QuestSystem.LoadQuestDefinitions()
	-- Main story quests
	QuestDefinitions = {
		-- Starter quests
		Starter_ChoosePartner = {
			Id = "Starter_ChoosePartner",
			Name = "Primeiro Parceiro",
			Description = "Escolha sua primeira criatura no laboratório do Professor.",
			Type = "Capture",
			Objectives = {
				{Type = "Capture", Target = "Any", Count = 1, Current = 0},
			},
			Rewards = {
				{Type = "Item", ItemId = "BasicBall", Amount = 10},
				{Type = "Money", Amount = 500},
			},
			Prerequisites = {},
			Repeatable = false,
		},

		Starter_FirstBattle = {
			Id = "Starter_FirstBattle",
			Name = "Primeira Batalha",
			Description = "Vença sua primeira batalha contra um treinador iniciante.",
			Type = "Defeat",
			Objectives = {
				{Type = "DefeatTrainer", Target = "Rival1", Count = 1, Current = 0},
			},
			Rewards = {
				{Type = "Item", ItemId = "Potion", Amount = 5},
				{Type = "Money", Amount = 300},
				{Type = "Experience", Amount = 100},
			},
			Prerequisites = {"Starter_ChoosePartner"},
			Repeatable = false,
		},

		Starter_VisitHealer = {
			Id = "Starter_VisitHealer",
			Name = "Centro de Cura",
			Description = "Visite o centro de cura na Vila Inicial.",
			Type = "Explore",
			Objectives = {
				{Type = "VisitLocation", Target = "StarterTown_Healer", Count = 1, Current = 0},
			},
			Rewards = {
				{Type = "Item", ItemId = "Potion", Amount = 3},
				{Type = "Money", Amount = 200},
			},
			Prerequisites = {"Starter_FirstBattle"},
			Repeatable = false,
		},

		-- Capture quests
		Catch_5Fire = {
			Id = "Catch_5Fire",
			Name = "Mestre do Fogo",
			Description = "Capture 5 criaturas do tipo Fogo.",
			Type = "Capture",
			Objectives = {
				{Type = "Capture", Target = "Fire", Count = 5, Current = 0},
			},
			Rewards = {
				{Type = "Item", ItemId = "FireStone", Amount = 1},
				{Type = "Money", Amount = 2000},
			},
			Prerequisites = {},
			Repeatable = false,
		},

		Catch_5Water = {
			Id = "Catch_5Water",
			Name = "Mestre da Água",
			Description = "Capture 5 criaturas do tipo Água.",
			Type = "Capture",
			Objectives = {
				{Type = "Capture", Target = "Water", Count = 5, Current = 0},
			},
			Rewards = {
				{Type = "Item", ItemId = "WaterStone", Amount = 1},
				{Type = "Money", Amount = 2000},
			},
			Prerequisites = {},
			Repeatable = false,
		},

		Catch_5Nature = {
			Id = "Catch_5Nature",
			Name = "Mestre da Natureza",
			Description = "Capture 5 criaturas do tipo Natureza.",
			Type = "Capture",
			Objectives = {
				{Type = "Capture", Target = "Nature", Count = 5, Current = 0},
			},
			Rewards = {
				{Type = "Item", ItemId = "NatureStone", Amount = 1},
				{Type = "Money", Amount = 2000},
			},
			Prerequisites = {},
			Repeatable = false,
		},

		-- Defeat quests
		Defeat_TrainerFire = {
			Id = "Defeat_TrainerFire",
			Name = "Desafiante de Fogo",
			Description = "Derrote 3 treinadores especialistas em Fogo.",
			Type = "Defeat",
			Objectives = {
				{Type = "DefeatTrainer", Target = "FireTrainer", Count = 3, Current = 0},
			},
			Rewards = {
				{Type = "Item", ItemId = "GreatBall", Amount = 5},
				{Type = "Money", Amount = 3000},
			},
			Prerequisites = {},
			Repeatable = false,
		},

		-- Evolution quests
		Evolve_Starter = {
			Id = "Evolve_Starter",
			Name = "Evolução Inicial",
			Description = "Evolua sua criatura inicial pela primeira vez.",
			Type = "Evolve",
			Objectives = {
				{Type = "Evolve", Target = "Any", Count = 1, Current = 0},
			},
			Rewards = {
				{Type = "Item", ItemId = "RareCandy", Amount = 1},
				{Type = "Money", Amount = 5000},
			},
			Prerequisites = {"Starter_FirstBattle"},
			Repeatable = false,
		},

		Evolve_AllStages = {
			Id = "Evolve_AllStages",
			Name = "Evolução Completa",
			Description = "Evolua uma criatura até seu estágio final.",
			Type = "Evolve",
			Objectives = {
				{Type = "EvolveToStage", Target = "Any", Count = 3, Current = 0},
			},
			Rewards = {
				{Type = "Item", ItemId = "MasterBall", Amount = 1},
				{Type = "Money", Amount = 10000},
			},
			Prerequisites = {"Evolve_Starter"},
			Repeatable = false,
		},

		-- Collection quests
		Collect_10Berries = {
			Id = "Collect_10Berries",
			Name = "Coletor de Berries",
			Description = "Colete 10 berries na natureza.",
			Type = "Collect",
			Objectives = {
				{Type = "Collect", Target = "Berry", Count = 10, Current = 0},
			},
			Rewards = {
				{Type = "Item", ItemId = "SitrusBerry", Amount = 5},
				{Type = "Money", Amount = 1000},
			},
			Prerequisites = {},
			Repeatable = true,
		},

		-- Exploration quests
		Explore_FireForest = {
			Id = "Explore_FireForest",
			Name = "Explorador da Floresta de Brasas",
			Description = "Descubra todos os pontos de interesse na Floresta de Brasas.",
			Type = "Explore",
			Objectives = {
				{Type = "VisitLocation", Target = "FireForest_Entrance", Count = 1, Current = 0},
				{Type = "VisitLocation", Target = "FireForest_Cave", Count = 1, Current = 0},
				{Type = "VisitLocation", Target = "FireForest_Summit", Count = 1, Current = 0},
			},
			Rewards = {
				{Type = "Item", ItemId = "FireStone", Amount = 1},
				{Type = "Money", Amount = 3000},
				{Type = "Unlock", Amount = 1, ItemId = "FireForest_FastTravel"},
			},
			Prerequisites = {"Starter_VisitHealer"},
			Repeatable = false,
		},

		-- Daily quests (repeatable)
		Daily_Catch3 = {
			Id = "Daily_Catch3",
			Name = "Captura Diária",
			Description = "Capture 3 criaturas selvagens hoje.",
			Type = "Capture",
			Objectives = {
				{Type = "Capture", Target = "Any", Count = 3, Current = 0},
			},
			Rewards = {
				{Type = "Item", ItemId = "GreatBall", Amount = 3},
				{Type = "Money", Amount = 1000},
				{Type = "Experience", Amount = 500},
			},
			Prerequisites = {},
			Repeatable = true,
		},

		Daily_Battle5 = {
			Id = "Daily_Battle5",
			Name = "Batalhador Diário",
			Description = "Vença 5 batalhas hoje.",
			Type = "Defeat",
			Objectives = {
				{Type = "WinBattle", Target = "Any", Count = 5, Current = 0},
			},
			Rewards = {
				{Type = "Item", ItemId = "SuperPotion", Amount = 5},
				{Type = "Money", Amount = 1500},
				{Type = "Experience", Amount = 1000},
			},
			Prerequisites = {},
			Repeatable = true,
		},

		-- Legendary quests
		Legendary_VulcanoDrago = {
			Id = "Legendary_VulcanoDrago",
			Name = "O Dragão Vulcânico",
			Description = "Encontre e capture Vulcano Draco no topo do vulcão.",
			Type = "Capture",
			Objectives = {
				{Type = "Capture", Target = "VULCANODRAGO", Count = 1, Current = 0},
			},
			Rewards = {
				{Type = "Item", ItemId = "MasterBall", Amount = 1},
				{Type = "Money", Amount = 50000},
				{Type = "Creature", ItemId = "VULCANODRAGO", Amount = 1}, -- Garantido
			},
			Prerequisites = {"Catch_5Fire", "Explore_FireForest"},
			Repeatable = false,
		},
	}
end

function QuestSystem.SetupEventListeners()
	-- Listen for creature captures
	local remote = ReplicatedStorage:FindFirstChild("Remotes")
	if remote then
		local captureEvent = remote:FindFirstChild("CreatureCaptured")
		if captureEvent then
			-- This would be connected via RemoteSystem
		end
	end

	-- We'll use a different approach - check quest progress on relevant actions
end

-- Get available quests for player at NPC
function QuestSystem.GetAvailableQuests(player: Player, npcId: string): {Types.QuestData}
	local playerData = DataStoreSystem.LoadPlayerData(player.UserId)
	if not playerData then return {} end

	local available = {}
	local completedQuests = playerData.CompletedQuests or {}
	local activeQuests = ActiveQuests[player.UserId] or {}

	-- Find quests given by this NPC
	for questId, questDef in pairs(QuestDefinitions) do
		-- Check if NPC gives this quest (would need NPC->Quest mapping)
		local givesQuest = QuestSystem.NPCGivesQuest(npcId, questId)
		if not givesQuest then continue end

		-- Check if already completed (and not repeatable)
		if completedQuests[questId] and not questDef.Repeatable then continue end

		-- Check if already active
		local alreadyActive = false
		for _, activeQuest in ipairs(activeQuests) do
			if activeQuest.Id == questId then
				alreadyActive = true
				break
			end
		end
		if alreadyActive then continue end

		-- Check prerequisites
		local canAccept = true
		for _, prereq in ipairs(questDef.Prerequisites or {}) do
			if not completedQuests[prereq] then
				canAccept = false
				break
			end
		end

		if canAccept then
			table.insert(available, questDef)
		end
	end

	return available
end

function QuestSystem.NPCGivesQuest(npcId: string, questId: string): boolean
	-- Mapping of NPC to quests they give
	local npcQuests = {
		Professor = {"Starter_ChoosePartner"},
		Rival1 = {"Starter_FirstBattle"},
		StarterTown_Healer = {"Starter_VisitHealer"},
		FireGymLeader = {"Catch_5Fire", "Legendary_VulcanoDrago"},
		WaterGymLeader = {"Catch_5Water"},
		NatureGymLeader = {"Catch_5Nature"},
		QuestBoard_Daily = {"Daily_Catch3", "Daily_Battle5"},
	}

	local quests = npcQuests[npcId] or {}
	for _, q in ipairs(quests) do
		if q == questId then return true end
	end
	return false
end

-- Accept a quest
function QuestSystem.AcceptQuest(player: Player, questId: string): (boolean, string?)
	local questDef = QuestDefinitions[questId]
	if not questDef then
		return false, "Quest não encontrada"
	end

	-- Initialize active quests for player
	if not ActiveQuests[player.UserId] then
		ActiveQuests[player.UserId] = {}
	end

	-- Check if already active
	for _, quest in ipairs(ActiveQuests[player.UserId]) do
		if quest.Id == questId then
			return false, "Quest já ativa"
		end
	end

	-- Create active quest instance
	local activeQuest = {
		Id = questDef.Id,
		Name = questDef.Name,
		Description = questDef.Description,
		Type = questDef.Type,
		Objectives = QuestSystem.DeepCopyObjectives(questDef.Objectives),
		Rewards = questDef.Rewards,
		Progress = {},
		AcceptedAt = tick(),
		Completed = false,
	}

	table.insert(ActiveQuests[player.UserId], activeQuest)
	QuestSystem.OnQuestAccepted:Fire(player, activeQuest)

	-- Save to DataStore
	QuestSystem.SavePlayerQuests(player)

	return true, nil
end

function QuestSystem.DeepCopyObjectives(objectives: {Types.QuestObjective}): {Types.QuestObjective}
	local copy = {}
	for _, obj in ipairs(objectives) do
		table.insert(copy, {
			Type = obj.Type,
			Target = obj.Target,
			Count = obj.Count,
			Current = obj.Current,
		})
	end
	return copy
end

-- Update quest progress
function QuestSystem.UpdateProgress(player: Player, objectiveType: string, target: string, amount: number?)
	amount = amount or 1

	local quests = ActiveQuests[player.UserId]
	if not quests then return end

	for _, quest in ipairs(quests) do
		if quest.Completed then continue end

		for _, objective in ipairs(quest.Objectives) do
			-- Check if this objective matches
			local matches = false

			if objective.Type == objectiveType then
				if objective.Target == "Any" or objective.Target == target then
					matches = true
				elseif objectiveType == "Capture" and QuestSystem.IsElementMatch(target, objective.Target) then
					matches = true
				elseif objectiveType == "DefeatTrainer" and QuestSystem.IsTrainerTypeMatch(target, objective.Target) then
					matches = true
				end
			end

			if matches then
				objective.Current = math.min(objective.Current + amount, objective.Count)
				QuestSystem.OnQuestProgress:Fire(player, quest, objective)

				-- Check if quest completed
				if QuestSystem.CheckQuestComplete(quest) then
					QuestSystem.CompleteQuest(player, quest)
				end

				QuestSystem.SavePlayerQuests(player)
			end
		end
	end
end

function QuestSystem.IsElementMatch(creatureSpecies: string, targetElement: string): boolean
	local speciesData = Config.SpeciesList[creatureSpecies]
	if not speciesData then return false end
	return speciesData.Element == targetElement
end

function QuestSystem.IsTrainerTypeMatch(trainerId: string, targetType: string): boolean
	-- Would check trainer's specialty
	-- Simplified for now
	return trainerId:find(targetType) ~= nil
end

function QuestSystem.CheckQuestComplete(quest: any): boolean
	for _, objective in ipairs(quest.Objectives) do
		if objective.Current < objective.Count then
			return false
		end
	end
	return true
end

function QuestSystem.CompleteQuest(player: Player, quest: any)
	quest.Completed = true
	QuestSystem.OnQuestCompleted:Fire(player, quest)

	-- Auto-turn in for simple quests, or wait for player to talk to NPC
	if QuestSystem.IsAutoTurnIn(quest.Id) then
		QuestSystem.TurnInQuest(player, quest.Id)
	end
end

function QuestSystem.IsAutoTurnIn(questId: string): boolean
	local autoTurnIn = {
		Daily_Catch3 = true,
		Daily_Battle5 = true,
		Collect_10Berries = true,
	}
	return autoTurnIn[questId] or false
end

-- Turn in completed quest for rewards
function QuestSystem.TurnInQuest(player: Player, questId: string): (boolean, string?)
	local quests = ActiveQuests[player.UserId]
	if not quests then return false, "Nenhuma quest ativa" end

	local questIndex = nil
	for i, quest in ipairs(quests) do
		if quest.Id == questId and quest.Completed then
			questIndex = i
			break
		end
	end

	if not questIndex then
		return false, "Quest não encontrada ou não completada"
	end

	local quest = quests[questIndex]

	-- Give rewards
	for _, reward in ipairs(quest.Rewards) do
		QuestSystem.GiveReward(player, reward)
	end

	-- Mark as completed in player data
	local playerData = DataStoreSystem.LoadPlayerData(player.UserId)
	if playerData then
		playerData.CompletedQuests = playerData.CompletedQuests or {}
		playerData.CompletedQuests[questId] = {
			CompletedAt = tick(),
			RewardsClaimed = true,
		}
		DataStoreSystem.SavePlayerData(player.UserId, playerData)
	end

	-- Remove from active
	table.remove(quests, questIndex)

	QuestSystem.OnQuestTurnedIn:Fire(player, quest)
	QuestSystem.SavePlayerQuests(player)

	return true, nil
end

function QuestSystem.GiveReward(player: Player, reward: Types.QuestReward)
	if reward.Type == "Item" and reward.ItemId then
		ItemSystem.AddItem(player, reward.ItemId, reward.Amount or 1)
	elseif reward.Type == "Money" then
		local playerData = DataStoreSystem.LoadPlayerData(player.UserId)
		if playerData then
			playerData.Money = (playerData.Money or 0) + (reward.Amount or 0)
			DataStoreSystem.SavePlayerData(player.UserId, playerData)
		end
	elseif reward.Type == "Experience" then
		-- Give XP to party
		local partySystem = require(script.Parent.PartySystem)
		local party = partySystem.GetPlayerParty(player)
		for _, creature in ipairs(party) do
			require(script.Parent.CreatureSystem).GainExperience(creature, reward.Amount or 0)
		end
	elseif reward.Type == "Creature" and reward.ItemId then
		-- Give creature directly
		local creatureSystem = require(script.Parent.CreatureSystem)
		local creature = creatureSystem.CreateWildCreature(reward.ItemId, 50, {GuaranteedCatch = true})
		local partySystem = require(script.Parent.PartySystem)
		partySystem.AddCreature(player, creature)
	end
end

-- Get active quests for player
function QuestSystem.GetActiveQuests(player: Player): {any}
	return ActiveQuests[player.UserId] or {}
end

-- Get quest progress for UI
function QuestSystem.GetQuestProgress(player: Player, questId: string): any?
	local quests = ActiveQuests[player.UserId]
	if not quests then return nil end

	for _, quest in ipairs(quests) do
		if quest.Id == questId then
			return quest
		end
	end
	return nil
end

-- Save/Load player quests
function QuestSystem.SavePlayerQuests(player: Player)
	local quests = ActiveQuests[player.UserId]
	if not quests then return end

	local playerData = DataStoreSystem.LoadPlayerData(player.UserId)
	if playerData then
		playerData.ActiveQuests = quests
		DataStoreSystem.SavePlayerData(player.UserId, playerData)
	end
end

function QuestSystem.LoadPlayerQuests(player: Player)
	local playerData = DataStoreSystem.LoadPlayerData(player.UserId)
	if playerData and playerData.ActiveQuests then
		ActiveQuests[player.UserId] = playerData.ActiveQuests
	end
end

-- Called when player joins
function QuestSystem.OnPlayerJoin(player: Player)
	QuestSystem.LoadPlayerQuests(player)
end

-- Called when player leaves
function QuestSystem.OnPlayerLeave(player: Player)
	QuestSystem.SavePlayerQuests(player)
	ActiveQuests[player.UserId] = nil
end

-- Reset daily quests (called daily)
function QuestSystem.ResetDailyQuests()
	for userId, quests in pairs(ActiveQuests) do
		local newQuests = {}
		for _, quest in ipairs(quests) do
			if quest.Repeatable and QuestDefinitions[quest.Id] and QuestDefinitions[quest.Id].Repeatable then
				-- Reset progress
				for _, obj in ipairs(quest.Objectives) do
					obj.Current = 0
				end
				quest.Completed = false
				quest.AcceptedAt = tick()
				table.insert(newQuests, quest)
			else
				table.insert(newQuests, quest)
			end
		end
		ActiveQuests[userId] = newQuests
	end
end

-- Cleanup
function QuestSystem.Cleanup()
	ActiveQuests = {}
end

return QuestSystem