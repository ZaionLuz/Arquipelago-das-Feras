--!strict
-- CreatureSystem.lua - Sistema de criaturas (spawn, captura, stats, evolução)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")
local RunService = game:GetService("RunService")

local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local MathUtil = require(ReplicatedStorage.Shared.Util.Math)
local TableUtil = require(ReplicatedStorage.Shared.Util.Table)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local CreatureSystem = {}

-- Events
CreatureSystem.OnCreatureSpawned = Signal.New()
CreatureSystem.OnCreatureCaptured = Signal.New()
CreatureSystem.OnCreatureReleased = Signal.New()
CreatureSystem.OnCreatureEvolved = Signal.New()
CreatureSystem.OnCreatureLevelUp = Signal.New()

-- Active wild creatures in world
local WildCreatures = {} :: {[string]: Types.CreatureData & {Model: Model?, SpawnTime: number, ZoneId: string}}
local CreatureModels = {} :: {[string]: Model}

-- Species data cache
local SpeciesCache = Config.SpeciesList

-- Generate a wild creature
function CreatureSystem.GenerateWildCreature(speciesId: string, level: number, zoneId: string): Types.CreatureData
	local speciesData = SpeciesCache[speciesId]
	if not speciesData then
		warn(`[CreatureSystem] Species not found: {speciesId}`)
		speciesData = SpeciesCache.CINZELO
	end

	local ivs = CreatureSystem.GenerateIVs()
	local nature = CreatureSystem.GetRandomNature()
	local isShiny = math.random() < Config.Game.ShinyRate

	-- Calculate stats
	local stats = CreatureSystem.CalculateStats(speciesData.BaseStats, ivs, {}, level, nature)

	-- Get moves for this level
	local moves = CreatureSystem.GetMovesForLevel(speciesId, level)

	local creature: Types.CreatureData = {
		Id = game:GetService("HttpService"):GenerateGUID(false),
		SpeciesId = speciesId,
		Nickname = nil,
		Level = level,
		Experience = CreatureSystem.GetExpForLevel(level),
		Stats = stats,
		IVs = ivs,
		EVs = {HP = 0, Attack = 0, Defense = 0, SpecialAttack = 0, SpecialDefense = 0, Speed = 0},
		Nature = nature,
		Ability = speciesData.Abilities[math.random(#speciesData.Abilities)],
		Moves = moves,
		CurrentHP = stats.HP,
		Status = "None",
		State = "Wild",
		CaughtAt = 0,
		CaughtLocation = zoneId,
		OriginalTrainer = "",
		IsShiny = isShiny,
		Gender = CreatureSystem.GetRandomGender(speciesData),
		EvolutionStage = CreatureSystem.GetEvolutionStage(speciesId),
		Friendship = 0,
	}

	return creature
end

-- Generate IVs
function CreatureSystem.GenerateIVs(): Types.IVs
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
function CreatureSystem.GetRandomNature(): string
	local natures = {}
	for name in pairs(Config.Natures) do
		table.insert(natures, name)
	end
	return natures[math.random(#natures)]
end

-- Get random gender
function CreatureSystem.GetRandomGender(speciesData: Types.SpeciesData): "Male" | "Female" | "Genderless"
	-- Most are 50/50, legendaries genderless
	if speciesData.Rarity == "Legendary" then
		return "Genderless"
	end
	return math.random() < 0.5 and "Male" or "Female"
end

-- Get evolution stage
function CreatureSystem.GetEvolutionStage(speciesId: string): 1 | 2 | 3
	-- Check if this species evolves from something
	for _, data in pairs(SpeciesCache) do
		if data.Evolutions and data.Evolutions.TargetSpecies == speciesId then
			-- This is an evolution
			local baseData = SpeciesCache[data.Evolutions.TargetSpecies]
			if baseData and baseData.Evolutions then
				return 3
			end
			return 2
		end
	end

	-- Check if this species evolves into something
	if SpeciesCache[speciesId] and SpeciesCache[speciesId].Evolutions then
		return 1
	end

	return 1 -- Base form or no evolution
end

-- Calculate stats
function CreatureSystem.CalculateStats(
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
			-- Apply nature modifier
			local mod = 1.0
			if not isHP then
				-- Map stat names to nature keys
				-- This is simplified - in reality you'd map each stat properly
			end
			return math.floor(stat * mod)
		end
	end

	return {
		HP = math.floor(((2 * baseStats.HP + ivs.HP + math.floor(evs.HP / 4)) * level) / 100) + level + 10,
		Attack = math.floor((((2 * baseStats.Attack + ivs.Attack + math.floor(evs.Attack / 4)) * level) / 100) + 5) * (natureMod.Atk or 1.0),
		Defense = math.floor((((2 * baseStats.Defense + ivs.Defense + math.floor(evs.Defense / 4)) * level) / 100) + 5) * (natureMod.Def or 1.0),
		SpecialAttack = math.floor((((2 * baseStats.SpecialAttack + ivs.SpecialAttack + math.floor(evs.SpecialAttack / 4)) * level) / 100) + 5) * (natureMod.SpA or 1.0),
		SpecialDefense = math.floor((((2 * baseStats.SpecialDefense + ivs.SpecialDefense + math.floor(evs.SpecialDefense / 4)) * level) / 100) + 5) * (natureMod.SpD or 1.0),
		Speed = math.floor((((2 * baseStats.Speed + ivs.Speed + math.floor(evs.Speed / 4)) * level) / 100) + 5) * (natureMod.Spe or 1.0),
	}
end

-- Get exp for level
function CreatureSystem.GetExpForLevel(level: number): number
	local curve = Config.ExpCurves[Config.Game.ExpCurve] or Config.ExpCurves.Medium
	return curve(level)
end

-- Get moves for level
function CreatureSystem.GetMovesForLevel(speciesId: string, level: number): {Types.Move}
	local speciesData = SpeciesCache[speciesId]
	local moves = {}

	if speciesData and speciesData.Learnset then
		for lvl, moveId in pairs(speciesData.Learnset) do
			if lvl <= level then
				table.insert(moves, CreatureSystem.CreateMove(moveId))
			end
		end
	end

	-- Sort by level learned (descending) and take last 4
	table.sort(moves, function(a, b) return (a.Priority or 0) > (b.Priority or 0) end)
	while #moves > 4 do
		table.remove(moves, 1)
	end

	return moves
end

-- Create move
function CreatureSystem.CreateMove(moveId: string): Types.Move
	local moveDatabase: {[string]: Types.Move} = {
		Tackle = {Id = "Tackle", Name = "Investida", Type = "Nature", Category = "Physical", Power = 40, Accuracy = 100, PP = 35, MaxPP = 35, Priority = 0},
		Ember = {Id = "Ember", Name = "Brasa", Type = "Fire", Category = "Special", Power = 40, Accuracy = 100, PP = 25, MaxPP = 25, Priority = 0, Effect = {Type = "Status", Params = {Status = "Burn"}, Chance = 10}},
		WaterGun = {Id = "WaterGun", Name = "Jato d'Água", Type = "Water", Category = "Special", Power = 40, Accuracy = 100, PP = 25, MaxPP = 25, Priority = 0},
		VineWhip = {Id = "VineWhip", Name = "Chicote de Vinha", Type = "Nature", Category = "Physical", Power = 45, Accuracy = 100, PP = 25, MaxPP = 25, Priority = 0},
		RockThrow = {Id = "RockThrow", Name = "Lançamento de Rocha", Type = "Earth", Category = "Physical", Power = 50, Accuracy = 90, PP = 15, MaxPP = 15, Priority = 0},
		Gust = {Id = "Gust", Name = "Ventania", Type = "Air", Category = "Special", Power = 40, Accuracy = 100, PP = 35, MaxPP = 35, Priority = 0},
		ShadowSneak = {Id = "ShadowSneak", Name = "Golpe Sombrio", Type = "Shadow", Category = "Physical", Power = 40, Accuracy = 100, PP = 30, MaxPP = 30, Priority = 1},
		Flamethrower = {Id = "Flamethrower", Name = "Lança-chamas", Type = "Fire", Category = "Special", Power = 90, Accuracy = 100, PP = 15, MaxPP = 15, Priority = 0, Effect = {Type = "Status", Params = {Status = "Burn"}, Chance = 10}},
		HydroPump = {Id = "HydroPump", Name = "Hidro Bomba", Type = "Water", Category = "Special", Power = 110, Accuracy = 80, PP = 5, MaxPP = 5, Priority = 0},
		SolarBeam = {Id = "SolarBeam", Name = "Raio Solar", Type = "Nature", Category = "Special", Power = 120, Accuracy = 100, PP = 10, MaxPP = 10, Priority = 0, Effect = {Type = "Charge", Params = {Turns = 1}, Chance = 0}},
		Earthquake = {Id = "Earthquake", Name = "Terremoto", Type = "Earth", Category = "Physical", Power = 100, Accuracy = 100, PP = 10, MaxPP = 10, Priority = 0},
		Hurricane = {Id = "Hurricane", Name = "Furacão", Type = "Air", Category = "Special", Power = 110, Accuracy = 70, PP = 10, MaxPP = 10, Priority = 0, Effect = {Type = "Status", Params = {Status = "Confusion"}, Chance = 30}},
		ShadowBall = {Id = "ShadowBall", Name = "Bola Sombria", Type = "Shadow", Category = "Special", Power = 80, Accuracy = 100, PP = 15, MaxPP = 15, Priority = 0, Effect = {Type = "StatChange", Params = {Stat = "SpecialDefense", Change = -1}, Chance = 20}},
	}

	return moveDatabase[moveId] or moveDatabase.Tackle
end

-- Spawn creature in world
function CreatureSystem.SpawnCreatureInWorld(creature: Types.CreatureData, position: Vector3, zoneId: string): string
	local spawnId = game:GetService("HttpService"):GenerateGUID(false)

	creature.State = "Wild"
	creature.CaughtLocation = zoneId

	local spawnData = {
		Creature = creature,
		Model = nil,
		SpawnTime = tick(),
		ZoneId = zoneId,
		Position = position,
	}

	WildCreatures[spawnId] = spawnData

	-- Load model from ServerStorage/Assets
	local model = CreatureSystem.LoadCreatureModel(creature.SpeciesId)
	if model then
		model = model:Clone()
		model.Name = `Wild_{creature.SpeciesId}_{spawnId}`
		model.Parent = workspace
		model:PivotTo(CFrame.new(position))

		-- Scale based on species size
		local speciesData = SpeciesCache[creature.SpeciesId]
		if speciesData then
			local scale = speciesData.Height / 2 -- Normalize
			model:ScaleTo(scale)
		end

		-- Add interaction
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Capturar"
		prompt.ObjectText = creature.SpeciesId
		prompt.HoldDuration = 1
		prompt.RequiresLineOfSight = false
		prompt.Parent = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")

		prompt.Triggered:Connect(function(player)
			CreatureSystem.OnCreatureSpawned:Fire(player, spawnId, creature)
		end)

		spawnData.Model = model
	end

	return spawnId
end

-- Load creature model
function CreatureSystem.LoadCreatureModel(speciesId: string): Model?
	local assets = ServerStorage:FindFirstChild("ServerAssets")
	if assets then
		local model = assets:FindFirstChild(speciesId)
		if model then
			return model
		end
	end
	return nil
end

-- Despawn creature
function CreatureSystem.DespawnCreature(spawnId: string)
	local spawnData = WildCreatures[spawnId]
	if spawnData then
		if spawnData.Model then
			spawnData.Model:Destroy()
		end
		WildCreatures[spawnId] = nil
	end
end

-- Calculate capture rate
function CreatureSystem.CalculateCaptureRate(
	creature: Types.CreatureData,
	ballType: string,
	playerPartyCount: number
): number
	local speciesData = SpeciesCache[creature.SpeciesId]
	if not speciesData then return 0 end

	-- Base capture rate by rarity
	local baseRate = 0
	if speciesData.Rarity == "Common" then baseRate = 0.4
	elseif speciesData.Rarity == "Rare" then baseRate = 0.2
	elseif speciesData.Rarity == "Epic" then baseRate = 0.1
	elseif speciesData.Rarity == "Legendary" then baseRate = 0.03
	end

	-- HP factor (lower HP = higher catch rate)
	local hpFactor = 1 - (creature.CurrentHP / creature.Stats.HP) * 0.5

	-- Status condition bonus
	local statusBonus = 1
	if creature.Status == "Sleep" or creature.Status == "Freeze" then
		statusBonus = 2.5
	elseif creature.Status == "Paralysis" or creature.Status == "Poison" or creature.Status == "Burn" then
		statusBonus = 1.5
	end

	-- Ball multiplier
	local ballMultiplier = 1
	if ballType == "GreatBall" then ballMultiplier = 1.5
	elseif ballType == "UltraBall" then ballMultiplier = 2.0
	elseif ballType == "MasterBall" then ballMultiplier = 255
	end

	-- Level difference penalty
	local levelDiff = creature.Level - 5 -- Assume player level ~5 for now
	if levelDiff > 10 then
		ballMultiplier *= 0.5
	elseif levelDiff > 20 then
		ballMultiplier *= 0.25
	end

	-- Party size bonus (smaller party = easier catch)
	local partyBonus = 1 + (6 - playerPartyCount) * 0.05

	local finalRate = baseRate * hpFactor * statusBonus * ballMultiplier * partyBonus

	return MathUtil.Clamp(finalRate, 0, 1)
end

-- Attempt capture
function CreatureSystem.AttemptCapture(
	player: Player,
	spawnId: string,
	ballType: string
): (boolean, Types.CreatureData?)
	local spawnData = WildCreatures[spawnId]
	if not spawnData then
		return false, nil
	end

	local creature = spawnData.Creature
	local partySystem = require(script.Parent.PartySystem)
	local partyCount = #partySystem.GetPlayerParty(player)

	local captureRate = CreatureSystem.CalculateCaptureRate(creature, ballType, partyCount)
	local roll = math.random()

	if roll <= captureRate or ballType == "MasterBall" then
		-- Success!
		creature.State = "Captured"
		creature.CaughtAt = tick()
		creature.OriginalTrainer = player.Name
		creature.Nickname = nil

		-- Add to party or storage
		local added = partySystem.AddToParty(player, creature)
		if not added then
			partySystem.AddToStorage(player, creature)
		end

		-- Despawn
		CreatureSystem.DespawnCreature(spawnId)

		CreatureSystem.OnCreatureCaptured:Fire(player, creature)

		return true, creature
	else
		-- Failed - creature might flee
		local fleeChance = 0.1 * (1 - captureRate)
		if math.random() < fleeChance then
			CreatureSystem.DespawnCreature(spawnId)
		end

		return false, nil
	end
end

-- Heal creature
function CreatureSystem.HealCreature(creature: Types.CreatureData, amount: number?): number
	if amount and amount > 0 then
		creature.CurrentHP = math.min(creature.Stats.HP, creature.CurrentHP + amount)
	else
		creature.CurrentHP = creature.Stats.HP
		creature.Status = "None"
	end
	return creature.CurrentHP
end

-- Damage creature
function CreatureSystem.DamageCreature(creature: Types.CreatureData, damage: number): number
	creature.CurrentHP = math.max(0, creature.CurrentHP - damage)
	if creature.CurrentHP <= 0 then
		creature.CurrentHP = 0
		creature.Status = "Fainted"
	end
	return creature.CurrentHP
end

-- Gain experience
function CreatureSystem.GainExperience(creature: Types.CreatureData, exp: number): {LeveledUp: boolean, NewLevel: number?, NewMoves: {Types.Move}?}
	local oldLevel = creature.Level
	creature.Experience += exp

	-- Check for level up
	local newLevel = oldLevel
	while creature.Experience >= CreatureSystem.GetExpForLevel(newLevel + 1) and newLevel < Config.Game.MaxLevel do
		newLevel += 1
	end

	local result = {LeveledUp = false, NewLevel = nil, NewMoves = nil}

	if newLevel > oldLevel then
		creature.Level = newLevel
		result.LeveledUp = true
		result.NewLevel = newLevel

		-- Recalculate stats
		local speciesData = SpeciesCache[creature.SpeciesId]
		if speciesData then
			creature.Stats = CreatureSystem.CalculateStats(speciesData.BaseStats, creature.IVs, creature.EVs, newLevel, creature.Nature)
			creature.CurrentHP = creature.Stats.HP -- Full heal on level up
		end

		-- Learn new moves
		local newMoves = CreatureSystem.GetMovesForLevel(creature.SpeciesId, newLevel)
		local learnedNew = false
		for _, move in ipairs(newMoves) do
			local hasMove = false
			for _, existing in ipairs(creature.Moves) do
				if existing.Id == move.Id then
					hasMove = true
					break
				end
			end
			if not hasMove then
				learnedNew = true
				if #creature.Moves >= 4 then
					-- Would need to replace - handled by LearnMove system
				else
					table.insert(creature.Moves, move)
				end
			end
		end

		if learnedNew then
			result.NewMoves = newMoves
		end

		CreatureSystem.OnCreatureLevelUp:Fire(creature, oldLevel, newLevel)
	end

	return result
end

-- Check evolution
function CreatureSystem.CheckEvolution(creature: Types.CreatureData): Types.EvolutionData?
	local speciesData = SpeciesCache[creature.SpeciesId]
	if not speciesData or not speciesData.Evolutions then
		return nil
	end

	local evo = speciesData.Evolutions

	if evo.Method == "Level" and creature.Level >= evo.Requirement then
		return evo
	elseif evo.Method == "Friendship" and creature.Friendship >= evo.Requirement then
		return evo
	-- Other methods (Item, Trade, TimeOfDay, Location) would be checked elsewhere
	end

	return nil
end

-- Evolve creature
function CreatureSystem.EvolveCreature(creature: Types.CreatureData, targetSpeciesId: string): Types.CreatureData
	local oldSpeciesId = creature.SpeciesId
	creature.SpeciesId = targetSpeciesId
	creature.EvolutionStage += 1

	-- Update stats for new species
	local newSpeciesData = SpeciesCache[targetSpeciesId]
	if newSpeciesData then
		creature.Stats = CreatureSystem.CalculateStats(newSpeciesData.BaseStats, creature.IVs, creature.EVs, creature.Level, creature.Nature)
		creature.CurrentHP = creature.Stats.HP

		-- Update ability
		creature.Ability = newSpeciesData.Abilities[math.random(#newSpeciesData.Abilities)]

		-- Learn new moves for this level
		local newMoves = CreatureSystem.GetMovesForLevel(targetSpeciesId, creature.Level)
		creature.Moves = newMoves
	end

	CreatureSystem.OnCreatureEvolved:Fire(creature, oldSpeciesId, targetSpeciesId)

	return creature
end

-- Get creature display info
function CreatureSystem.GetDisplayInfo(creature: Types.CreatureData): {Name: string, Element: string, Rarity: string, Level: number, HP: number, MaxHP: number, IsShiny: boolean}
	local speciesData = SpeciesCache[creature.SpeciesId]
	return {
		Name = creature.Nickname or (speciesData and speciesData.Name or creature.SpeciesId),
		Element = speciesData and speciesData.Element or "Unknown",
		Rarity = speciesData and speciesData.Rarity or "Common",
		Level = creature.Level,
		HP = creature.CurrentHP,
		MaxHP = creature.Stats.HP,
		IsShiny = creature.IsShiny,
	}
end

return CreatureSystem