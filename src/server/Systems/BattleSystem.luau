--!strict
-- BattleSystem.lua - Sistema de batalha (turn-based estilo Pokémon)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")

local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local MathUtil = require(ReplicatedStorage.Shared.Util.Math)
local TableUtil = require(ReplicatedStorage.Shared.Util.Table)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local BattleSystem = {}

-- Events
BattleSystem.OnBattleStarted = Signal.New()
BattleSystem.OnBattleEnded = Signal.New()
BattleSystem.OnTurnChanged = Signal.New()
BattleSystem.OnMoveUsed = Signal.New()
BattleSystem.OnCreatureFainted = Signal.New()
BattleSystem.OnStatusChanged = Signal.New()

-- Active battles
local ActiveBattles = {} :: {[string]: Types.BattleData}
local BattleQueue = {} :: {Types.BattleData}

-- Battle constants
local TURN_TIMEOUT = 30 -- seconds

-- Start wild battle
function BattleSystem.StartWildBattle(player: Player, wildCreature: Types.CreatureData): Types.BattleData
	local battleId = game:GetService("HttpService"):GenerateGUID(false)

	-- Get player's first alive creature
	local partySystem = require(script.Parent.PartySystem)
	local playerCreature = partySystem.GetFirstAlive(player)

	if not playerCreature then
		error("Player has no alive creatures!")
	end

	-- Create battle participants
	local playerParticipant: Types.BattleParticipant = {
		Creature = playerCreature,
		IsPlayer = true,
		StatStages = {
			Attack = 0, Defense = 0, SpecialAttack = 0, SpecialDefense = 0, Speed = 0,
			Accuracy = 0, Evasion = 0,
		},
		VolatileStatus = {},
		LastMoveUsed = nil,
		TurnsAsleep = 0,
		TurnsFrozen = 0,
	}

	local enemyParticipant: Types.BattleParticipant = {
		Creature = wildCreature,
		IsPlayer = false,
		StatStages = {
			Attack = 0, Defense = 0, SpecialAttack = 0, SpecialDefense = 0, Speed = 0,
			Accuracy = 0, Evasion = 0,
		},
		VolatileStatus = {},
		LastMoveUsed = nil,
		TurnsAsleep = 0,
		TurnsFrozen = 0,
	}

	local battle: Types.BattleData = {
		Id = battleId,
		State = "TurnStart",
		PlayerSide = {playerParticipant},
		EnemySide = {enemyParticipant},
		Weather = "None",
		Terrain = "None",
		TurnCount = 0,
		Seed = math.random(1000000),
	}

	ActiveBattles[battleId] = battle

	-- Set creatures to battling state
	playerCreature.State = "Battling"
	wildCreature.State = "Battling"

	BattleSystem.OnBattleStarted:Fire(battle, player)

	return battle
end

-- Start trainer battle (placeholder)
function BattleSystem.StartTrainerBattle(player: Player, trainerData: any): Types.BattleData
	-- Similar to wild battle but with trainer's team
	return BattleSystem.StartWildBattle(player, trainerData.Team[1])
end

-- Process battle action
function BattleSystem.ProcessAction(battleId: string, action: Types.BattleAction): Types.BattleResult
	local battle = ActiveBattles[battleId]
	if not battle then
		return {Success = false, EffectMessages = {"Battle not found"}}
	end

	if battle.State ~= "PlayerTurn" and battle.State ~= "EnemyTurn" then
		return {Success = false, EffectMessages = {"Not your turn"}}
	end

	local isPlayerTurn = battle.State == "PlayerTurn"
	local actor = isPlayerTurn and battle.PlayerSide[1] or battle.EnemySide[1]
	local target = isPlayerTurn and battle.EnemySide[1] or battle.PlayerSide[1]

	if action.Type == "Move" then
		return BattleSystem.ExecuteMove(battle, actor, target, action.MoveId, action.TargetIndex)
	elseif action.Type == "Switch" then
		return BattleSystem.ExecuteSwitch(battle, actor, action.SwitchIndex)
	elseif action.Type == "Item" then
		return BattleSystem.ExecuteItem(battle, actor, action.ItemId)
	elseif action.Type == "Run" then
		return BattleSystem.ExecuteRun(battle, actor)
	end

	return {Success = false, EffectMessages = {"Invalid action"}}
end

-- Execute move
function BattleSystem.ExecuteMove(
	battle: Types.BattleData,
	actor: Types.BattleParticipant,
	target: Types.BattleParticipant,
	moveId: string,
	targetIndex: number?
): Types.BattleResult
	local move = BattleSystem.GetMoveById(moveId)
	if not move then
		return {Success = false, EffectMessages = {"Move not found"}}
	end

	-- Check PP
	if move.PP <= 0 then
		return {Success = false, EffectMessages = {"No PP left for this move"}}
	end

	-- Check if actor can move (status conditions)
	local canMove, message = BattleSystem.CheckCanMove(actor)
	if not canMove then
		return {Success = false, EffectMessages = {message}}
	end

	move.PP -= 1
	actor.LastMoveUsed = moveId

	-- Calculate accuracy
	local accuracy = move.Accuracy * BattleSystem.GetAccuracyModifier(actor, target)
	local hit = math.random(100) <= accuracy

	if not hit then
		return {
			Success = true,
			Damage = 0,
			EffectMessages = {`{actor.Creature.SpeciesId} usou {move.Name}, mas errou!`},
		}
	end

	-- Calculate damage
	local damage = 0
	local messages = {}

	if move.Category ~= "Status" then
		damage = BattleSystem.CalculateDamage(actor, target, move, battle)
		target.Creature.CurrentHP = math.max(0, target.Creature.CurrentHP - damage)

		table.insert(messages, `{actor.Creature.SpeciesId} usou {move.Name}!`)
		table.insert(messages, `Causou {damage} de dano!`)

		-- Check effectiveness
		local effectiveness = BattleSystem.GetEffectiveness(move.Type, target.Creature.SpeciesId)
		if effectiveness > 1 then
			table.insert(messages, "Foi super efetivo!")
		elseif effectiveness < 1 and effectiveness > 0 then
			table.insert(messages, "Não foi muito efetivo...")
		elseif effectiveness == 0 then
			table.insert(messages, "Não teve efeito!")
		end

		-- Check critical hit
		local isCrit = BattleSystem.CheckCriticalHit(actor, move)
		if isCrit then
			damage = math.floor(damage * 1.5)
			table.insert(messages, "Acerto crítico!")
		end
	else
		table.insert(messages, `{actor.Creature.SpeciesId} usou {move.Name}!`)
	end

	-- Apply move effects
	if move.Effect then
		local effectMessages = BattleSystem.ApplyMoveEffect(actor, target, move, battle)
		for _, msg in ipairs(effectMessages) do
			table.insert(messages, msg)
		end
	end

	-- Check for faint
	local fainted = false
	if target.Creature.CurrentHP <= 0 then
		target.Creature.CurrentHP = 0
		target.Creature.Status = "Fainted"
		fainted = true
		table.insert(messages, `{target.Creature.SpeciesId} desmaiou!`)
		BattleSystem.OnCreatureFainted:Fire(battle, target)
	end

	BattleSystem.OnMoveUsed:Fire(battle, actor, target, move, damage)

	return {
		Success = true,
		Damage = damage,
		EffectMessages = messages,
		Fainted = fainted,
		StateChange = fainted and "BattleEnd" or nil,
	}
end

-- Check if actor can move
function BattleSystem.CheckCanMove(actor: Types.BattleParticipant): (boolean, string?)
	local creature = actor.Creature

	if creature.Status == "Sleep" then
		actor.TurnsAsleep += 1
		if actor.TurnsAsleep >= 3 or math.random() < 0.2 then
			creature.Status = "None"
			actor.TurnsAsleep = 0
			return true, ""
		end
		return false, `{creature.SpeciesId} está dormindo!`
	end

	if creature.Status == "Freeze" then
		actor.TurnsFrozen += 1
		if math.random() < 0.2 then
			creature.Status = "None"
			actor.TurnsFrozen = 0
			return true, ""
		end
		return false, `{creature.SpeciesId} está congelado!`
	end

	if creature.Status == "Paralysis" then
		if math.random() < 0.25 then
			return false, `{creature.SpeciesId} está paralisado e não consegue se mover!`
		end
	end

	if creature.Status == "Confusion" then
		if math.random() < 0.33 then
			-- Self damage
			return false, `{creature.SpeciesId} se machucou na confusão!`
		end
	end

	return true, ""
end

-- Calculate damage
function BattleSystem.CalculateDamage(
	actor: Types.BattleParticipant,
	target: Types.BattleParticipant,
	move: Types.Move,
	battle: Types.BattleData
): number
	local attacker = actor.Creature
	local defender = target.Creature

	local attackStat = move.Category == "Physical" and attacker.Stats.Attack or attacker.Stats.SpecialAttack
	local defenseStat = move.Category == "Physical" and defender.Stats.Defense or defender.Stats.SpecialDefense

	-- Apply stat stages
	attackStat = BattleSystem.ApplyStatStage(attackStat, actor.StatStages[move.Category == "Physical" and "Attack" or "SpecialAttack"])
	defenseStat = BattleSystem.ApplyStatStage(defenseStat, target.StatStages[move.Category == "Physical" and "Defense" or "SpecialDefense"])

	-- Base damage formula
	local level = attacker.Level
	local power = move.Power or 0

	local baseDamage = math.floor((((2 * level / 5 + 2) * power * attackStat / defenseStat) / 50) + 2)

	-- Random factor (85-100%)
	baseDamage = math.floor(baseDamage * (0.85 + math.random() * 0.15))

	-- STAB (Same Type Attack Bonus)
	local speciesData = Config.SpeciesList[attacker.SpeciesId]
	if speciesData and (speciesData.Element == move.Type or (speciesData.Element == "FireWater" and (move.Type == "Fire" or move.Type == "Water"))) then
		baseDamage = math.floor(baseDamage * 1.5)
	end

	-- Type effectiveness
	local effectiveness = BattleSystem.GetEffectiveness(move.Type, defender.SpeciesId)
	baseDamage = math.floor(baseDamage * effectiveness)

	-- Burn reduces physical damage
	if attacker.Status == "Burn" and move.Category == "Physical" then
		baseDamage = math.floor(baseDamage * 0.5)
	end

	-- Weather effects
	if battle.Weather == "Sunny" then
		if move.Type == "Fire" then baseDamage = math.floor(baseDamage * 1.5) end
		if move.Type == "Water" then baseDamage = math.floor(baseDamage * 0.5) end
	elseif battle.Weather == "Rain" then
		if move.Type == "Water" then baseDamage = math.floor(baseDamage * 1.5) end
		if move.Type == "Fire" then baseDamage = math.floor(baseDamage * 0.5) end
	end

	return math.max(1, baseDamage)
end

-- Apply stat stage
function BattleSystem.ApplyStatStage(stat: number, stage: number): number
	if stage > 0 then
		return math.floor(stat * (2 + stage) / 2)
	elseif stage < 0 then
		return math.floor(stat * 2 / (2 - stage))
	end
	return stat
end

-- Get accuracy modifier
function BattleSystem.GetAccuracyModifier(actor: Types.BattleParticipant, target: Types.BattleParticipant): number
	local accStage = actor.StatStages.Accuracy or 0
	local evaStage = target.StatStages.Evasion or 0
	local stageDiff = accStage - evaStage

	if stageDiff > 0 then
		return (3 + stageDiff) / 3
	elseif stageDiff < 0 then
		return 3 / (3 - stageDiff)
	end
	return 1
end

-- Get type effectiveness
function BattleSystem.GetEffectiveness(moveType: string, defenderSpeciesId: string): number
	local defenderData = Config.SpeciesList[defenderSpeciesId]
	if not defenderData then return 1 end

	local defenderType = defenderData.Element
	local effectivenessTable = Config.TypeEffectiveness[moveType]

	if effectivenessTable and effectivenessTable[defenderType] then
		return effectivenessTable[defenderType]
	end

	return 1
end

-- Check critical hit
function BattleSystem.CheckCriticalHit(actor: Types.BattleParticipant, move: Types.Move): boolean
	local critRate = move.Priority > 0 and 0.5 or 0.0625 -- 6.25% base, 50% for high priority

	-- Focus Energy effect would increase this

	return math.random() < critRate
end

-- Apply move effects
function BattleSystem.ApplyMoveEffect(
	actor: Types.BattleParticipant,
	target: Types.BattleParticipant,
	move: Types.Move,
	battle: Types.BattleData
): {string}
	local messages = {}
	local effect = move.Effect
	local chance = effect.Chance or 100

	if math.random(100) > chance then
		return messages
	end

	if effect.Type == "Status" then
		local status = effect.Params.Status
		if target.Creature.Status == "None" then
			target.Creature.Status = status
			table.insert(messages, `{target.Creature.SpeciesId} ficou {status}!`)
			BattleSystem.OnStatusChanged:Fire(battle, target, status)
		end
	elseif effect.Type == "StatChange" then
		local stat = effect.Params.Stat
		local change = effect.Params.Change
		target.StatStages[stat] = MathUtil.Clamp((target.StatStages[stat] or 0) + change, -6, 6)
		local direction = change > 0 and "subiu" or "caiu"
		table.insert(messages, `{stat} de {target.Creature.SpeciesId} {direction}!`)
	elseif effect.Type == "Heal" then
		local amount = effect.Params.Amount or 0
		local healed = math.min(target.Creature.Stats.HP - target.Creature.CurrentHP, amount)
		target.Creature.CurrentHP += healed
		table.insert(messages, `{target.Creature.SpeciesId} recuperou {healed} HP!`)
	elseif effect.Type == "Charge" then
		-- Move requires charging (like Solar Beam)
		table.insert(messages, `{actor.Creature.SpeciesId} está carregando energia!`)
		actor.VolatileStatus.Charging = {MoveId = move.Id, Turns = effect.Params.Turns or 1}
	end

	return messages
end

-- Execute switch
function BattleSystem.ExecuteSwitch(battle: Types.BattleData, actor: Types.BattleParticipant, switchIndex: number?): Types.BattleResult
	-- Implementation for switching creatures
	return {Success = true, EffectMessages = {"Switch executed"}, StateChange = "TurnEnd"}
end

-- Execute item
function BattleSystem.ExecuteItem(battle: Types.BattleData, actor: Types.BattleParticipant, itemId: string?): Types.BattleResult
	-- Implementation for using items
	return {Success = true, EffectMessages = {"Item used"}, StateChange = "TurnEnd"}
end

-- Execute run
function BattleSystem.ExecuteRun(battle: Types.BattleData, actor: Types.BattleParticipant): Types.BattleResult
	local canRun = true -- Would check speed, trapping moves, etc.

	if canRun then
		BattleSystem.EndBattle(battle.Id, "Fled")
		return {Success = true, EffectMessages = {"Fugiu com sucesso!"}, StateChange = "BattleEnd"}
	else
		return {Success = false, EffectMessages = {"Não conseguiu fugir!"}}
	end
end

-- Get move by ID
function BattleSystem.GetMoveById(moveId: string): Types.Move?
	-- Simplified - in reality would look up from move database
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

	return moveDatabase[moveId]
end

-- End battle
function BattleSystem.EndBattle(battleId: string, result: "PlayerWon" | "EnemyWon" | "Fled" | "PlayerLeft")
	local battle = ActiveBattles[battleId]
	if not battle then return end

	-- Reset creature states
	for _, participant in ipairs(battle.PlayerSide) do
		participant.Creature.State = "InParty"
	end
	for _, participant in ipairs(battle.EnemySide) do
		participant.Creature.State = "Wild"
	end

	ActiveBattles[battleId] = nil
	BattleSystem.OnBattleEnded:Fire(battle, result)
end

-- Update loop
function BattleSystem.Update(deltaTime: number)
	-- Handle battle timeouts, weather effects, etc.
	for battleId, battle in pairs(ActiveBattles) do
		-- Apply weather damage
		if battle.Weather == "Sandstorm" then
			for _, participant in ipairs({...battle.PlayerSide, ...battle.EnemySide}) do
				if participant.Creature.CurrentHP > 0 then
					local speciesData = Config.SpeciesList[participant.Creature.SpeciesId]
					if speciesData and not TableUtil.Contains({"Earth", "Rock", "Steel"}, speciesData.Element) then
						participant.Creature.CurrentHP = math.max(0, participant.Creature.CurrentHP - math.floor(participant.Creature.Stats.HP / 16))
					end
				end
			end
		end

		-- Apply status damage
		for _, participant in ipairs({...battle.PlayerSide, ...battle.EnemySide}) do
			local creature = participant.Creature
			if creature.Status == "Burn" or creature.Status == "Poison" then
				local damage = math.floor(creature.Stats.HP / (creature.Status == "Burn" and 16 or 8))
				creature.CurrentHP = math.max(0, creature.CurrentHP - damage)
				if creature.CurrentHP <= 0 then
					creature.CurrentHP = 0
					creature.Status = "Fainted"
					BattleSystem.OnCreatureFainted:Fire(battle, participant)
				end
			end
		end
	end
end

return BattleSystem