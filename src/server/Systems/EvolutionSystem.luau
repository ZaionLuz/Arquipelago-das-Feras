--!strict
-- EvolutionSystem.lua - Sistema de evolução de criaturas

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local CreatureSystem = require(script.Parent.CreatureSystem)
local PartySystem = require(script.Parent.PartySystem)
local ItemSystem = require(script.Parent.ItemSystem)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local EvolutionSystem = {}

-- Events
EvolutionSystem.OnEvolutionStarted = Signal.New()
EvolutionSystem.OnEvolutionCompleted = Signal.New()
EvolutionSystem.OnEvolutionCancelled = Signal.New()

-- Evolution requirements cache
local EvolutionCache = {}

-- Initialize
function EvolutionSystem.Initialize()
	-- Build evolution lookup cache
	for speciesId, speciesData in pairs(Config.SpeciesList) do
		if speciesData.Evolutions then
			EvolutionCache[speciesId] = speciesData.Evolutions
		end
	end
	print("[EvolutionSystem] Initialized with " .. TableUtil.Length(EvolutionCache) .. " evolutions")
end

-- Check if creature can evolve
function EvolutionSystem.CanEvolve(creature: Types.CreatureData): Types.EvolutionData?
	local evolution = EvolutionCache[creature.SpeciesId]
	if not evolution then return nil end

	-- Check method
	if evolution.Method == "Level" then
		if creature.Level >= evolution.Requirement then
			return evolution
		end
	elseif evolution.Method == "Friendship" then
		if creature.Friendship >= evolution.Requirement then
			return evolution
		end
	elseif evolution.Method == "Item" then
		-- Check if player has the item
		-- This would be checked when item is used
		return evolution
	elseif evolution.Method == "Trade" then
		-- Trade evolution - handled during trade
		return evolution
	elseif evolution.Method == "TimeOfDay" then
		local timeOfDay = EvolutionSystem.GetTimeOfDay()
		if timeOfDay == evolution.Requirement then
			return evolution
		end
	elseif evolution.Method == "Location" then
		-- Location evolution - checked when in specific zone
		return evolution
	end

	return nil
end

-- Get time of day
function EvolutionSystem.GetTimeOfDay(): "Day" | "Night" | "Dawn" | "Dusk"
	local cycleTime = (tick() % Config.Game.DayNightCycle) / Config.Game.DayNightCycle
	if cycleTime < 0.25 then return "Dawn"
	elseif cycleTime < 0.5 then return "Day"
	elseif cycleTime < 0.75 then return "Dusk"
	else return "Night"
	end
end

-- Attempt evolution
function EvolutionSystem.AttemptEvolution(player: Player, creatureId: string, method: string?, itemId: string?): (boolean, Types.CreatureData?)
	-- Find creature in party or storage
	local partySystem = require(script.Parent.PartySystem)
	local creature: Types.CreatureData?
	local location: "Party" | "Storage" = "Party"

	for _, c in ipairs(partySystem.GetPlayerParty(player)) do
		if c.Id == creatureId then
			creature = c
			break
		end
	end

	if not creature then
		location = "Storage"
		for _, box in ipairs(partySystem.GetPlayerStorage(player)) do
			for _, c in ipairs(box) do
				if c.Id == creatureId then
					creature = c
					break
				end
			end
			if creature then break end
		end
	end

	if not creature then
		return false, nil
	end

	-- Check evolution requirements
	local evolution = EvolutionSystem.CanEvolve(creature)

	-- Special checks for item/trade/time/location
	if evolution then
		if evolution.Method == "Item" and itemId then
			local itemConfig = Config.Items[itemId]
			if not itemConfig or itemConfig.Id ~= evolution.Requirement then
				return false, nil
			end
			-- Consume item
			ItemSystem.RemoveItem(player, itemId, 1)
		elseif evolution.Method == "Trade" then
			-- Would need trade system
			return false, nil
		elseif evolution.Method == "TimeOfDay" then
			if EvolutionSystem.GetTimeOfDay() ~= evolution.Requirement then
				return false, nil
			end
		elseif evolution.Method == "Location" then
			-- Check player's current zone
			-- Would need player zone tracking
		end
	else
		return false, nil
	end

	-- Start evolution
	EvolutionSystem.OnEvolutionStarted:Fire(player, creature, evolution.TargetSpecies)

	-- Perform evolution
	local evolvedCreature = CreatureSystem.EvolveCreature(creature, evolution.TargetSpecies)

	-- Update in party/storage
	if location == "Party" then
		-- Already updated by reference
	else
		-- In storage - already updated by reference
	end

	EvolutionSystem.OnEvolutionCompleted:Fire(player, evolvedCreature, evolution.TargetSpecies)

	return true, evolvedCreature
end

-- Get possible evolutions for a species
function EvolutionSystem.GetPossibleEvolutions(speciesId: string): {Types.EvolutionData}
	local evolutions = {}

	-- Direct evolution
	if EvolutionCache[speciesId] then
		table.insert(evolutions, EvolutionCache[speciesId])
	end

	-- Branch evolutions (if multiple)
	-- This would be expanded for complex evolution lines

	return evolutions
end

-- Get evolution chain
function EvolutionSystem.GetEvolutionChain(speciesId: string): {string}
	local chain = {speciesId}
	local current = speciesId

	while EvolutionCache[current] do
		local nextSpecies = EvolutionCache[current].TargetSpecies
		table.insert(chain, nextSpecies)
		current = nextSpecies
	end

	return chain
end

-- Get pre-evolution
function EvolutionSystem.GetPreEvolution(speciesId: string): string?
	for id, evo in pairs(EvolutionCache) do
		if evo.TargetSpecies == speciesId then
			return id
		end
	end
	return nil
end

-- Check all party creatures for evolution
function EvolutionSystem.CheckPartyForEvolutions(player: Player): {Types.CreatureData}
	local partySystem = require(script.Parent.PartySystem)
	local readyToEvolve = {}

	for _, creature in ipairs(partySystem.GetPlayerParty(player)) do
		if EvolutionSystem.CanEvolve(creature) then
			table.insert(readyToEvolve, creature)
		end
	end

	return readyToEvolve
end

-- Cancel evolution (if player presses B)
function EvolutionSystem.CancelEvolution(player: Player, creatureId: string)
	local partySystem = require(script.Parent.PartySystem)

	for _, creature in ipairs(partySystem.GetPlayerParty(player)) do
		if creature.Id == creatureId then
			EvolutionSystem.OnEvolutionCancelled:Fire(player, creature)
			return true
		end
	end

	return false
end

-- Get evolution info for UI
function EvolutionSystem.GetEvolutionInfo(creature: Types.CreatureData): {CanEvolve: boolean, Method: string?, Requirement: any?, TargetSpecies: string?, TargetName: string?}
	local evolution = EvolutionSystem.CanEvolve(creature)

	if not evolution then
		return {CanEvolve = false}
	end

	local targetData = Config.SpeciesList[evolution.TargetSpecies]

	return {
		CanEvolve = true,
		Method = evolution.Method,
		Requirement = evolution.Requirement,
		TargetSpecies = evolution.TargetSpecies,
		TargetName = targetData and targetData.Name or evolution.TargetSpecies,
	}
end

-- Helper: TableUtil.Length
local function TableUtilLength(t: {[any]: any}): number
	local count = 0
	for _ in pairs(t) do count += 1 end
	return count
end

return EvolutionSystem