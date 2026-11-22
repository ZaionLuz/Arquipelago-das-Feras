--!strict
-- PartySystem.lua - Gerenciamento de party e storage do jogador

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local PartySystem = {}

-- Events
PartySystem.OnPartyChanged = Signal.New()
PartySystem.OnStorageChanged = Signal.New()
PartySystem.OnCreatureAdded = Signal.New()
PartySystem.OnCreatureRemoved = Signal.New()

-- Player party/storage cache
local PlayerParties = {} :: {[number]: {Types.CreatureData}}
local PlayerStorage = {} :: {[number]: {{Types.CreatureData}}}

-- Initialize player
function PartySystem.InitializePlayer(player: Player, playerData: Types.PlayerData)
	PlayerParties[player.UserId] = playerData.Party or {}
	PlayerStorage[player.UserId] = playerData.Storage or {}

	-- Ensure storage has correct number of boxes
	while #PlayerStorage[player.UserId] < Config.Game.MaxStorageBoxes do
		table.insert(PlayerStorage[player.UserId], {})
	end

	print(`[PartySystem] Initialized party for {player.Name}: {#PlayerParties[player.UserId]} in party, {#PlayerStorage[player.UserId]} storage boxes`)
end

-- Cleanup player
function PartySystem.CleanupPlayer(player: Player)
	PlayerParties[player.UserId] = nil
	PlayerStorage[player.UserId] = nil
end

-- Get player's party
function PartySystem.GetPlayerParty(player: Player): {Types.CreatureData}
	return PlayerParties[player.UserId] or {}
end

-- Get player's storage
function PartySystem.GetPlayerStorage(player: Player): {{Types.CreatureData}}
	return PlayerStorage[player.UserId] or {}
end

-- Get specific storage box
function PartySystem.GetStorageBox(player: Player, boxIndex: number): {Types.CreatureData}?
	local storage = PlayerStorage[player.UserId]
	if storage and storage[boxIndex] then
		return storage[boxIndex]
	end
	return nil
end

-- Add creature to party
function PartySystem.AddToParty(player: Player, creature: Types.CreatureData): boolean
	local party = PlayerParties[player.UserId]
	if not party then return false end

	if #party >= Config.Game.MaxPartySize then
		return false -- Party full
	end

	creature.State = "InParty"
	table.insert(party, creature)

	PartySystem.OnPartyChanged:Fire(player, party)
	PartySystem.OnCreatureAdded:Fire(player, creature, "Party")

	return true
end

-- Remove creature from party
function PartySystem.RemoveFromParty(player: Player, creatureId: string): Types.CreatureData?
	local party = PlayerParties[player.UserId]
	if not party then return nil end

	for i, creature in ipairs(party) do
		if creature.Id == creatureId then
			table.remove(party, i)
			creature.State = "InStorage"

			PartySystem.OnPartyChanged:Fire(player, party)
			PartySystem.OnCreatureRemoved:Fire(player, creature, "Party")

			return creature
		end
	end

	return nil
end

-- Add creature to storage
function PartySystem.AddToStorage(player: Player, creature: Types.CreatureData): boolean
	local storage = PlayerStorage[player.UserId]
	if not storage then return false end

	-- Find first box with space
	for boxIndex = 1, #storage do
		local box = storage[boxIndex]
		if #box < Config.Game.StorageBoxSize then
			creature.State = "InStorage"
			creature.StorageBox = boxIndex
			table.insert(box, creature)

			PartySystem.OnStorageChanged:Fire(player, boxIndex, box)
			PartySystem.OnCreatureAdded:Fire(player, creature, "Storage", boxIndex)

			return true
		end
	end

	-- All boxes full
	return false
end

-- Remove creature from storage
function PartySystem.RemoveFromStorage(player: Player, creatureId: string): Types.CreatureData?
	local storage = PlayerStorage[player.UserId]
	if not storage then return nil end

	for boxIndex, box in ipairs(storage) do
		for i, creature in ipairs(box) do
			if creature.Id == creatureId then
				table.remove(box, i)
				creature.State = "InParty"
				creature.StorageBox = nil

				PartySystem.OnStorageChanged:Fire(player, boxIndex, box)
				PartySystem.OnCreatureRemoved:Fire(player, creature, "Storage", boxIndex)

				return creature
			end
		end
	end

	return nil
end

-- Swap two creatures in party
function PartySystem.SwapPartyMembers(player: Player, index1: number, index2: number): boolean
	local party = PlayerParties[player.UserId]
	if not party then return false end

	if index1 < 1 or index1 > #party or index2 < 1 or index2 > #party then
		return false
	end

	party[index1], party[index2] = party[index2], party[index1]

	PartySystem.OnPartyChanged:Fire(player, party)
	return true
end

-- Move creature between party and storage
function PartySystem.MoveCreature(
	player: Player,
	creatureId: string,
	fromType: "Party" | "Storage",
	toType: "Party" | "Storage",
	targetBox: number?
): boolean
	local creature: Types.CreatureData?

	if fromType == "Party" then
		creature = PartySystem.RemoveFromParty(player, creatureId)
	else
		creature = PartySystem.RemoveFromStorage(player, creatureId)
	end

	if not creature then return false end

	if toType == "Party" then
		return PartySystem.AddToParty(player, creature)
	else
		return PartySystem.AddToStorage(player, creature)
	end
end

-- Get first alive creature in party
function PartySystem.GetFirstAlive(player: Player): Types.CreatureData?
	local party = PlayerParties[player.UserId]
	if not party then return nil end

	for _, creature in ipairs(party) do
		if creature.CurrentHP > 0 then
			return creature
		end
	end

	return nil
end

-- Check if party has any alive creatures
function PartySystem.HasAliveCreature(player: Player): boolean
	local party = PlayerParties[player.UserId]
	if not party then return false end

	for _, creature in ipairs(party) do
		if creature.CurrentHP > 0 then
			return true
		end
	end

	return false
end

-- Heal entire party
function PartySystem.HealParty(player: Player): number
	local party = PlayerParties[player.UserId]
	if not party then return 0 end

	local healedCount = 0
	for _, creature in ipairs(party) do
		if creature.CurrentHP < creature.Stats.HP or creature.Status ~= "None" then
			creature.CurrentHP = creature.Stats.HP
			creature.Status = "None"
			for _, move in ipairs(creature.Moves) do
				move.PP = move.MaxPP
			end
			healedCount += 1
		end
	end

	if healedCount > 0 then
		PartySystem.OnPartyChanged:Fire(player, party)
	end

	return healedCount
end

-- Get party summary for UI
function PartySystem.GetPartySummary(player: Player): {{Name: string, Level: number, HP: number, MaxHP: number, Element: string, Status: string, IsShiny: boolean}}
	local party = PlayerParties[player.UserId]
	if not party then return {} end

	local summary = {}
	for _, creature in ipairs(party) do
		local speciesData = Config.SpeciesList[creature.SpeciesId]
		table.insert(summary, {
			Id = creature.Id,
			Name = creature.Nickname or (speciesData and speciesData.Name or creature.SpeciesId),
			Level = creature.Level,
			HP = creature.CurrentHP,
			MaxHP = creature.Stats.HP,
			Element = speciesData and speciesData.Element or "Unknown",
			Status = creature.Status,
			IsShiny = creature.IsShiny,
			SpeciesId = creature.SpeciesId,
		})
	end

	return summary
end

-- Count total creatures owned
function PartySystem.GetTotalCreatureCount(player: Player): number
	local count = #(PlayerParties[player.UserId] or {})
	local storage = PlayerStorage[player.UserId]
	if storage then
		for _, box in ipairs(storage) do
			count += #box
		end
	end
	return count
end

-- Get creatures by species
function PartySystem.GetCreaturesBySpecies(player: Player, speciesId: string): {Types.CreatureData}
	local results = {}

	-- Check party
	for _, creature in ipairs(PlayerParties[player.UserId] or {}) do
		if creature.SpeciesId == speciesId then
			table.insert(results, creature)
		end
	end

	-- Check storage
	local storage = PlayerStorage[player.UserId]
	if storage then
		for _, box in ipairs(storage) do
			for _, creature in ipairs(box) do
				if creature.SpeciesId == speciesId then
					table.insert(results, creature)
				end
			end
		end
	end

	return results
end

-- Release creature (permanent)
function PartySystem.ReleaseCreature(player: Player, creatureId: string): boolean
	local creature = PartySystem.RemoveFromParty(player, creatureId)
	if creature then
		PartySystem.OnCreatureRemovedFire(player, creature)
		return true
	end

	creature = PartySystem.RemoveFromStorage(player, creatureId)
	if creature then
		PartySystem.OnCreatureReleased:Fire(player, creature)
		return true
	end

	return false
end

return PartySystem