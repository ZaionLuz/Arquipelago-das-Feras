--!strict
-- CombatService.luau - Server-side battle logic
-- Handles turn processing, damage calculation, status effects, battle types

local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local HttpService = game:GetService("HttpService")
local RunService = game:GetService("RunService")

local Data = require(script.Parent.DataService)
local C = require(RS.Shared.Creatures)
local CombatRules = require(RS.Shared.CombatRules)
local CaptureRules = require(RS.Shared.CaptureRules)
local Progression = require(RS.Shared.Progression)
local Grant = require(RS.Shared.CreatureGrant)
local Quest = require(RS.Shared.PhoenixQuest)
local Config = require(RS.Shared.Config)
local Region = require(script.Parent.RegionService)
local Species = require(RS.Shared.SpeciesRules)
local Elements = require(RS.Shared.Elements)
local Moves = require(RS.Shared.Moves)

local CombatService = {}

-- Battle types
export type BattleType = "wild" | "trainer" | "double" | "horde" | "guardian" | "special"

export type BattleParticipant = {
	player: Player,
	team: { [string]: CombatRules.Combatant }, -- uid -> combatant
	active: string?,
	items: { [string]: number },
	seals: { [string]: number },
}

export type BattleState = {
	id: string,
	type: BattleType,
	region: string,
	participants: { [Player]: BattleParticipant },
	wildFoes: { CombatRules.Combatant }, -- For wild/horde/guardian
	turn: number,
	maxTurns: number,
	status: "waiting" | "active" | "ended",
	turnOrder: { { participant: Player | "wild", unitId: string, speed: number } },
	currentTurnIndex: number,
	field: {
		weather: string?,
		terrain: string?,
		gravity: number,
		trickRoom: boolean,
		tailwind: { [Player]: number },
	},
	log: { { text: string, kind: string, data: any? } },
	rewards: { xp: number, gold: number, items: { [string]: number }? },
	endedAt: number?,
}

local activeBattles: { [string]: BattleState } = {}
local playerBattleMap: { [Player]: string } = {}
local rng = Random.new()

-- Remote setup
local remotesFolder: Folder
local net: RemoteFunction
local events: RemoteEvent

-- Battle type configurations
local BATTLE_CONFIGS = {
	wild = { maxParty = 3, maxTurns = 40, capturable = true, double = false },
	trainer = { maxParty = 3, maxTurns = 60, capturable = false, double = false },
	double = { maxParty = 4, maxTurns = 60, capturable = false, double = true },
	horde = { maxParty = 3, maxTurns = 50, capturable = true, double = false, hordeSize = 5 },
	guardian = { maxParty = 3, maxTurns = 80, capturable = false, double = false, isLegendary = true },
	special = { maxParty = 3, maxTurns = 100, capturable = true, double = false, isLegendary = true },
}

function CombatService.init()
	-- Create remotes
	remotesFolder = Instance.new("Folder")
	remotesFolder.Name = "CombatRemotes"
	remotesFolder.Parent = RS

	net = Instance.new("RemoteFunction")
	net.Name = "CombatNet"
	net.Parent = remotesFolder

	events = Instance.new("RemoteEvent")
	events.Name = "CombatEvents"
	events.Parent = remotesFolder

	net.OnServerInvoke = CombatService.onServerInvoke
	Players.PlayerRemoving:Connect(CombatService.onPlayerRemoving)

	-- Periodic cleanup
	task.spawn(function()
		while true do
			task.wait(30)
			CombatService.cleanupExpiredBattles()
		end
	end)
end

function CombatService.start()
	-- Already initialized in init
end

function CombatService.onServerInvoke(player: Player, battleId: string, action: string, ...: any): any
	local battle = activeBattles[battleId]
	if not battle then return { error = "BATTLE_NOT_FOUND" } end

	local participant = battle.participants[player]
	if not participant then return { error = "NOT_IN_BATTLE" } end

	if action == "getState" then
		return CombatService.getBattleSnapshot(battle, player)
	elseif action == "selectAction" then
		local actionData = ...
		return CombatService.processAction(battle, player, actionData)
	elseif action == "switchCreature" then
		local uid = ...
		return CombatService.switchCreature(battle, player, uid)
	elseif action == "useItem" then
		local itemId = ...
		return CombatService.useItem(battle, player, itemId)
	elseif action == "tryCapture" then
		local sealType = ...
		return CombatService.tryCapture(battle, player, sealType)
	elseif action == "flee" then
		return CombatService.attemptFlee(battle, player)
	end
	return { error = "INVALID_ACTION" }
end

function CombatService.onPlayerRemoving(player: Player)
	local battleId = playerBattleMap[player]
	if battleId then
		local battle = activeBattles[battleId]
		if battle then
			CombatService.forfeitBattle(battle, player)
		end
	end
end

function CombatService.cleanupExpiredBattles()
	local now = os.time()
	for id, battle in activeBattles do
		if battle.endedAt and now - battle.endedAt > 60 then
			activeBattles[id] = nil
			for player in battle.participants do
				playerBattleMap[player] = nil
			end
		end
	end
end

-- Battle creation
function CombatService.createWildBattle(player: Player, foeData: { id: string, lv: number, region: string, capturable: boolean?, isLegendary: boolean?, statMultiplier: number?, captureBase: number? }): (boolean, string?)
	local d = Data.get(player)
	if not d then return false, "NO_DATA" end

	-- Check region access
	local regionCheck = Region.requireCurrent(player, foeData.region, "encounter")
	if not regionCheck.ok then return false, regionCheck.reason end

	-- Check existing battle
	if playerBattleMap[player] then return false, "ALREADY_IN_BATTLE" end

	local config = BATTLE_CONFIGS.wild
	local battleId = HttpService:GenerateGUID(false)

	-- Create wild foe
	local foe = CombatRules.stats(foeData.id, foeData.lv)
	if foeData.isLegendary then foe.isLegendary = true end
	if foeData.statMultiplier then
		for _, key in { "maxHp", "atk", "def", "speed" } do
			foe[key] = foe[key] * foeData.statMultiplier
			if key == "maxHp" then foe[key] = math.floor(foe[key]) end
		end
		foe.hp = foe.maxHp
	end

	-- Create participant
	local participant: BattleParticipant = {
		player = player,
		team = {},
		active = nil,
		items = d.items or {},
		seals = d.sealStock or {},
	}

	local battle: BattleState = {
		id = battleId,
		type = "wild",
		region = foeData.region,
		participants = { [player] = participant },
		wildFoes = { foe },
		turn = 0,
		maxTurns = config.maxTurns,
		status = "waiting",
		turnOrder = {},
		currentTurnIndex = 1,
		field = { weather = nil, terrain = nil, gravity = 1, trickRoom = false, tailwind = {} },
		log = {},
		rewards = { xp = 0, gold = 0 },
	}

	activeBattles[battleId] = battle
	playerBattleMap[player] = battleId

	-- Send initial state
	CombatService.sendBattleState(battle, player, { intro = "wild" })
	return true, battleId
end

function CombatService.createDoubleBattle(player1: Player, player2: Player, foeData1: { id: string, lv: number }, foeData2: { id: string, lv: number }, region: string): (boolean, string?)
	local d1 = Data.get(player1)
	local d2 = Data.get(player2)
	if not d1 or not d2 then return false, "NO_DATA" end

	if playerBattleMap[player1] or playerBattleMap[player2] then return false, "ALREADY_IN_BATTLE" end

	local config = BATTLE_CONFIGS.double
	local battleId = HttpService:GenerateGUID(false)

	local foe1 = CombatRules.stats(foeData1.id, foeData1.lv)
	local foe2 = CombatRules.stats(foeData2.id, foeData2.lv)

	local p1: BattleParticipant = { player = player1, team = {}, active = nil, items = d1.items or {}, seals = d1.sealStock or {} }
	local p2: BattleParticipant = { player = player2, team = {}, active = nil, items = d2.items or {}, seals = d2.sealStock or {} }

	local battle: BattleState = {
		id = battleId,
		type = "double",
		region = region,
		participants = { [player1] = p1, [player2] = p2 },
		wildFoes = { foe1, foe2 },
		turn = 0,
		maxTurns = config.maxTurns,
		status = "waiting",
		turnOrder = {},
		currentTurnIndex = 1,
		field = { weather = nil, terrain = nil, gravity = 1, trickRoom = false, tailwind = {} },
		log = {},
		rewards = { xp = 0, gold = 0 },
	}

	activeBattles[battleId] = battle
	playerBattleMap[player1] = battleId
	playerBattleMap[player2] = battleId

	CombatService.sendBattleState(battle, player1, { intro = "double" })
	CombatService.sendBattleState(battle, player2, { intro = "double" })
	return true, battleId
end

function CombatService.createHordeBattle(player: Player, foeSpecies: string, foeLevel: number, count: number, region: string): (boolean, string?)
	local d = Data.get(player)
	if not d then return false, "NO_DATA" end

	local regionCheck = Region.requireCurrent(player, region, "encounter")
	if not regionCheck.ok then return false, regionCheck.reason end

	if playerBattleMap[player] then return false, "ALREADY_IN_BATTLE" end

	local config = BATTLE_CONFIGS.horde
	local battleId = HttpService:GenerateGUID(false)

	local foes = {}
	for i = 1, math.min(count, config.hordeSize or 5) do
		local foe = CombatRules.stats(foeSpecies, foeLevel)
		foe.hp = foe.maxHp
		table.insert(foes, foe)
	end

	local participant: BattleParticipant = { player = player, team = {}, active = nil, items = d.items or {}, seals = d.sealStock or {} }

	local battle: BattleState = {
		id = battleId,
		type = "horde",
		region = region,
		participants = { [player] = participant },
		wildFoes = foes,
		turn = 0,
		maxTurns = config.maxTurns,
		status = "waiting",
		turnOrder = {},
		currentTurnIndex = 1,
		field = { weather = nil, terrain = nil, gravity = 1, trickRoom = false, tailwind = {} },
		log = {},
		rewards = { xp = 0, gold = 0 },
	}

	activeBattles[battleId] = battle
	playerBattleMap[player] = battleId

	CombatService.sendBattleState(battle, player, { intro = "horde" })
	return true, battleId
end

function CombatService.createGuardianBattle(player: Player, guardianId: string, region: string): (boolean, string?)
	local d = Data.get(player)
	if not d then return false, "NO_DATA" end

	local guardianData = Species.Guardians[guardianId]
	if not guardianData then return false, "INVALID_GUARDIAN" end

	if d.guardians[guardianId] then return false, "ALREADY_DEFEATED" end

	local regionCheck = Region.requireCurrent(player, region, "encounter")
	if not regionCheck.ok then return false, regionCheck.reason end

	if playerBattleMap[player] then return false, "ALREADY_IN_BATTLE" end

	local config = BATTLE_CONFIGS.guardian
	local battleId = HttpService:GenerateGUID(false)

	local foe = CombatRules.stats(guardianData.species, guardianData.level)
	foe.isLegendary = true
	foe.hp = foe.maxHp

	local participant: BattleParticipant = { player = player, team = {}, active = nil, items = d.items or {}, seals = d.sealStock or {} }

	local battle: BattleState = {
		id = battleId,
		type = "guardian",
		region = region,
		participants = { [player] = participant },
		wildFoes = { foe },
		turn = 0,
		maxTurns = config.maxTurns,
		status = "waiting",
		turnOrder = {},
		currentTurnIndex = 1,
		field = { weather = nil, terrain = nil, gravity = 1, trickRoom = false, tailwind = {} },
		log = {},
		rewards = { xp = 0, gold = 0 },
		guardianId = guardianId,
	}

	activeBattles[battleId] = battle
	playerBattleMap[player] = battleId

	CombatService.sendBattleState(battle, player, { intro = "guardian" })
	return true, battleId
end

-- Turn processing
function CombatService.processAction(battle: BattleState, player: Player, actionData: { type: string, moveId: string?, target: string? }): any
	if battle.status ~= "active" then return { error = "BATTLE_ENDED" } end

	local participant = battle.participants[player]
	if not participant then return { error = "NOT_IN_BATTLE" } end

	-- Check if it's player's turn
	local currentTurn = battle.turnOrder[battle.currentTurnIndex]
	if not currentTurn or currentTurn.participant ~= player then
		return { error = "NOT_YOUR_TURN" }
	end

	local activeUid = currentTurn.unitId
	local activeUnit = participant.team[activeUid]
	if not activeUnit or activeUnit.hp <= 0 then
		return { error = "UNIT_FAINTED" }
	end

	-- Check status conditions
	local canAct = CombatRules.canAct(activeUnit, rng)
	if not canAct.canAct then
		CombatService.addLog(battle, canAct.log)
		CombatService.nextTurn(battle)
		return CombatService.getBattleSnapshot(battle, player)
	end

	local actionType = actionData.type

	if actionType == "move" then
		local moveId = actionData.moveId
		local targetId = actionData.target
		CombatService.executeMove(battle, player, activeUnit, moveId, targetId)
	elseif actionType == "item" then
		CombatService.useItem(battle, player, actionData.itemId, activeUid)
	elseif actionType == "switch" then
		CombatService.switchCreature(battle, player, actionData.uid)
	elseif actionType == "flee" then
		CombatService.attemptFlee(battle, player)
	end

	CombatService.nextTurn(battle)
	return CombatService.getBattleSnapshot(battle, player)
end

function CombatService.executeMove(battle: BattleState, player: Player, attacker: CombatRules.Combatant, moveId: string, targetId: string?)
	local move = Moves.getMoveById(moveId)
	if not move then return end

	-- Find target
	local target: CombatRules.Combatant?
	if battle.type == "double" then
		-- Double battle targeting logic
		target = CombatService.findDoubleTarget(battle, player, attacker, move, targetId)
	else
		-- Single battle - target is wild foe or opponent's active
		if #battle.wildFoes > 0 then
			target = battle.wildFoes[1]
		else
			-- PvP
			for p, part in battle.participants do
				if p ~= player and part.active then
					target = part.team[part.active]
					break
				end
			end
		end
	end

	if not target then return end

	-- Check accuracy
	if rng:NextNumber() > move.accuracy then
		CombatService.addLog(battle, { { text = C.ById[attacker.id].name .. " errou o ataque!", kind = "miss" } })
		return
	end

	-- Calculate damage
	local damage = 0
	if move.category ~= "status" then
		damage = CombatRules.damage(attacker, target, move.power, false, move)
		target.hp = math.max(0, target.hp - damage)

		local mult = Elements.mult(attacker.el, target.el)
		CombatService.addLog(battle, { {
			text = C.ById[attacker.id].name .. " usou " .. move.name .. " e causou " .. damage .. " de dano!",
			kind = "hit",
			data = { damage = damage, multiplier = mult, targetHp = target.hp, targetMaxHp = target.maxHp }
		} })
	else
		CombatService.addLog(battle, { { text = C.ById[attacker.id].name .. " usou " .. move.name .. "!", kind = "status" } })
	end

	-- Apply move effects
	if move.effect then
		CombatRules.applyMoveEffect(attacker, target, move, battle, rng)
	end

	-- Check for faint
	if target.hp <= 0 then
		CombatService.handleFaint(battle, target, player)
	end

	-- Reduce PP (simplified - would need PP tracking per move)
end

function CombatService.findDoubleTarget(battle: BattleState, player: Player, attacker: CombatRules.Combatant, move: Moves.MoveData, targetId: string?): CombatRules.Combatant?
	-- Simplified - in a real implementation, would handle ally/enemy targeting
	if move.target == "enemy" or move.target == "all" then
		return battle.wildFoes[1]
	end
	return nil
end

function CombatService.handleFaint(battle: BattleState, fainted: CombatRules.Combatant, victorPlayer: Player)
	CombatService.addLog(battle, { { text = C.ById[fainted.id].name .. " desmaiou!", kind = "faint" } })

	-- Check if battle should end
	if battle.type == "wild" or battle.type == "guardian" or battle.type == "special" then
		-- Check if all wild foes fainted
		local allFainted = true
		for _, foe in battle.wildFoes do
			if foe.hp > 0 then allFainted = false break end
		end
		if allFainted then
			CombatService.endBattle(battle, "victory")
		end
	elseif battle.type == "horde" then
		-- Horde battles end when all foes fainted or player team wiped
		local allFainted = true
		for _, foe in battle.wildFoes do
			if foe.hp > 0 then allFainted = false break end
		end
		if allFainted then
			CombatService.endBattle(battle, "victory")
		end
	elseif battle.type == "double" then
		-- Check both foes
	end
end

function CombatService.nextTurn(battle: BattleState)
	battle.currentTurnIndex += 1
	if battle.currentTurnIndex > #battle.turnOrder then
		battle.turn += 1
		battle.currentTurnIndex = 1
		CombatService.recalculateTurnOrder(battle)

		-- Tick status effects for all active units
		for _, participant in battle.participants do
			if participant.active then
				local unit = participant.team[participant.active]
				if unit then
					local statusLog = CombatRules.tickStatus(unit, rng)
					if statusLog then CombatService.addLog(battle, statusLog) end
				end
			end
		end
		for _, foe in battle.wildFoes do
			if foe.hp > 0 then
				local statusLog = CombatRules.tickStatus(foe, rng)
				if statusLog then CombatService.addLog(battle, statusLog) end
			end
		end

		-- Check turn limit
		if battle.turn >= battle.maxTurns then
			CombatService.endBattle(battle, "timeout")
		end
	end
end

function CombatService.recalculateTurnOrder(battle: BattleState)
	local order = {}

	-- Add player active units
	for player, participant in battle.participants do
		if participant.active then
			local unit = participant.team[participant.active]
			if unit and unit.hp > 0 then
				table.insert(order, { participant = player, unitId = participant.active, speed = unit.speed })
			end
		end
	end

	-- Add wild foes
	for i, foe in battle.wildFoes do
		if foe.hp > 0 then
			table.insert(order, { participant = "wild", unitId = "foe_" .. i, speed = foe.speed })
		end
	end

	-- Sort by speed (trick room reverses)
	table.sort(order, function(a, b)
		if battle.field.trickRoom then
			return a.speed < b.speed
		end
		return a.speed > b.speed
	end)

	battle.turnOrder = order
end

function CombatService.startBattle(battle: BattleState)
	battle.status = "active"
	CombatService.recalculateTurnOrder(battle)

	-- Notify all participants
	for player in battle.participants do
		CombatService.sendBattleState(battle, player, { battleStart = true })
	end

	-- Process wild AI turns
	task.spawn(function()
		while battle.status == "active" do
			local currentTurn = battle.turnOrder[battle.currentTurnIndex]
			if currentTurn and currentTurn.participant == "wild" then
				CombatService.processWildTurn(battle, currentTurn.unitId)
				CombatService.nextTurn(battle)
				task.wait(1) -- Small delay for readability
			else
				task.wait(0.5)
			end
		end
	end)
end

function CombatService.processWildTurn(battle: BattleState, unitId: string)
	-- Find the foe
	local foeIndex = tonumber(unitId:match("foe_(%d+)"))
	local foe = foeIndex and battle.wildFoes[foeIndex]
	if not foe or foe.hp <= 0 then return end

	-- Simple AI: use strongest available move or basic attack
	local move = Moves.getMove(foe.id, foe.nextSkill and battle.turn >= foe.nextSkill)
	if move and move.category ~= "status" then
		-- Target random player active
		local targets = {}
		for player, participant in battle.participants do
			if participant.active then
				local unit = participant.team[participant.active]
				if unit and unit.hp > 0 then
					table.insert(targets, { player = player, unit = unit })
				end
			end
		end

		if #targets > 0 then
			local target = targets[rng:NextInteger(1, #targets)]
			CombatService.executeMove(battle, target.player, foe, move.id, target.unit)
		end
	else
		-- Basic attack
		local targets = {}
		for player, participant in battle.participants do
			if participant.active then
				local unit = participant.team[participant.active]
				if unit and unit.hp > 0 then
					table.insert(targets, { player = player, unit = unit })
				end
			end
		end
		if #targets > 0 then
			local target = targets[rng:NextInteger(1, #targets)]
			CombatService.executeMove(battle, target.player, foe, "tackle", target.unit)
		end
	end
end

-- Battle actions
function CombatService.switchCreature(battle: BattleState, player: Player, uid: string): any
	local participant = battle.participants[player]
	if not participant then return { error = "NOT_IN_BATTLE" } end

	local d = Data.get(player)
	if not d or not d.creatures[uid] then return { error = "INVALID_CREATURE" } end

	local creature = d.creatures[uid]
	if participant.team[uid] and participant.team[uid].hp <= 0 then
		return { error = "CREATURE_FAINTED" }
	end

	-- Create combatant if not exists
	if not participant.team[uid] then
		local unit = CombatRules.stats(creature.id, creature.lv)
		unit.maxHp = math.floor(unit.maxHp * CombatRules.TameHealth)
		unit.atk = unit.atk * CombatRules.TamePower
		unit.hp = unit.maxHp
		participant.team[uid] = unit
	end

	participant.active = uid
	CombatService.addLog(battle, { { text = C.ById[creature.id].name .. " entrou em campo!", kind = "switch" } })

	-- In single battle, this ends the turn
	if battle.type ~= "double" then
		CombatService.nextTurn(battle)
	end

	return CombatService.getBattleSnapshot(battle, player)
end

function CombatService.useItem(battle: BattleState, player: Player, itemId: string, targetUid: string?): any
	local participant = battle.participants[player]
	if not participant then return { error = "NOT_IN_BATTLE" } end

	local d = Data.get(player)
	if not d or not d.items[itemId] or d.items[itemId] <= 0 then
		return { error = "NO_ITEM" }
	end

	-- Item effects would be defined in a separate module
	-- For now, basic healing item
	if itemId == "potion" then
		local targetUid = targetUid or participant.active
		local target = participant.team[targetUid]
		if target then
			local heal = math.min(target.maxHp - target.hp, 50)
			target.hp += heal
			d.items.potion -= 1
			CombatService.addLog(battle, { { text = "Usou Poção. " .. C.ById[target.id].name .. " recuperou " .. heal .. " HP!", kind = "heal" } })
		end
	end

	CombatService.nextTurn(battle)
	return CombatService.getBattleSnapshot(battle, player)
end

function CombatService.tryCapture(battle: BattleState, player: Player, sealType: string): any
	if battle.type ~= "wild" and battle.type ~= "horde" and battle.type ~= "special" then
		return { error = "CANT_CAPTURE" }
	end

	local participant = battle.participants[player]
	if not participant then return { error = "NOT_IN_BATTLE" } end

	local foe = battle.wildFoes[1]
	if not foe or foe.hp <= 0 then return { error = "TARGET_FAINTED" } end

	-- Check seal availability
	local sealData = CaptureRules.Seals[sealType]
	if not sealData then return { error = "INVALID_SEAL" } end

	local hasSeal = false
	if sealType == "Basic" then
		hasSeal = (participant.seals.Basic or 0) > 0
	else
		hasSeal = (participant.seals[sealType] or 0) > 0
	end

	if not hasSeal then return { error = "NO_SEALS" } end

	-- Calculate catch rate
	local catchRate = CaptureRules.calculateCatchRate(foe, sealType, participant)
	local caught = rng:NextNumber() < catchRate

	if sealType == "Basic" then
		participant.seals.Basic -= 1
	else
		participant.seals[sealType] -= 1
	end

	if caught then
		CombatService.addLog(battle, { { text = C.ById[foe.id].name .. " foi capturado!", kind = "capture" } })
		CombatService.endBattle(battle, "captured", { capturedSpecies = foe.id, capturedLevel = foe.lv })
	else
		CombatService.addLog(battle, { { text = "O selo se desfez! " .. C.ById[foe.id].name .. " resistiu!", kind = "miss" } })
		CombatService.nextTurn(battle)
	end

	return CombatService.getBattleSnapshot(battle, player)
end

function CombatService.attemptFlee(battle: BattleState, player: Player): any
	if battle.type == "guardian" or battle.type == "trainer" then
		return { error = "CANT_FLEE" }
	end

	local participant = battle.participants[player]
	if not participant then return { error = "NOT_IN_BATTLE" } end

	-- Calculate flee chance based on speed
	local activeUnit = participant.active and participant.team[participant.active]
	local foe = battle.wildFoes[1]

	local fleeChance = 0.5
	if activeUnit and foe then
		fleeChance = math.clamp(activeUnit.speed / (activeUnit.speed + foe.speed), 0.2, 0.8)
	end

	if rng:NextNumber() < fleeChance then
		CombatService.addLog(battle, { { text = "Fugiu com sucesso!", kind = "flee" } })
		CombatService.endBattle(battle, "fled")
	else
		CombatService.addLog(battle, { { text = "Não conseguiu fugir!", kind = "miss" } })
		CombatService.nextTurn(battle)
	end

	return CombatService.getBattleSnapshot(battle, player)
end

function CombatService.forfeitBattle(battle: BattleState, player: Player)
	CombatService.addLog(battle, { { text = player.Name .. " desistiu da batalha.", kind = "forfeit" } })
	CombatService.endBattle(battle, "forfeit")
end

function CombatService.endBattle(battle: BattleState, result: string, extraData: any?)
	battle.status = "ended"
	battle.endedAt = os.time()

	-- Process rewards
	if result == "victory" or result == "captured" then
		CombatService.grantRewards(battle, result, extraData)
	end

	-- Notify all participants
	for player in battle.participants do
		CombatService.sendBattleState(battle, player, { battleEnd = true, result = result, extra = extraData })
		playerBattleMap[player] = nil
	end

	-- Cleanup after delay
	task.delay(60, function()
		activeBattles[battle.id] = nil
	end)
end

function CombatService.grantRewards(battle: BattleState, result: string, extraData: any?)
	for player, participant in battle.participants do
		local d = Data.get(player)
		if not d then continue end

		local totalXp = 0
		local totalGold = 0

		for _, foe in battle.wildFoes do
			if foe.hp <= 0 or result == "captured" then
				local def = C.ById[foe.id]
				local teamLevel = 0
				for _, unit in participant.team do
					teamLevel = math.max(teamLevel, unit.lv)
				end
				local reward = Progression.rewards(battle.region, foe.lv, def.rar, teamLevel)
				totalXp += reward.xp
				totalGold += reward.gold

				-- Award creature XP to active participant
				if participant.active then
					local pet = d.creatures[participant.active]
					if pet then
						Progression.awardCreature(pet, reward.creatureXp)
					end
				end
			end
		end

		d.gold += totalGold
		Progression.award(d, totalXp)
		d.stats.win = (d.stats.win or 0) + 1

		if battle.type == "guardian" and battle.guardianId then
			d.guardians[battle.guardianId] = true
			d.stats.guardian = (d.stats.guardian or 0) + 1
			d.gold += 100
			Progression.award(d, 200)
		end

		if result == "captured" and extraData then
			local origin = battle.type == "special" and "special_capture" or "wild_capture"
			Grant.grant(d, extraData.capturedSpecies, origin, battle.id, { level = extraData.capturedLevel })
			d.stats.capture = (d.stats.capture or 0) + 1
		end
	end
end

-- Helpers
function CombatService.addLog(battle: BattleState, entries: { { text: string, kind: string, data: any? } })
	for _, entry in entries do
		table.insert(battle.log, entry)
	end
end

function CombatService.getBattleSnapshot(battle: BattleState, player: Player): any
	local participant = battle.participants[player]
	if not participant then return { error = "NOT_IN_BATTLE" } end

	-- Build team data
	local team = {}
	for uid, unit in participant.team do
		team[uid] = {
			id = unit.id,
			lv = unit.lv,
			hp = unit.hp,
			maxHp = unit.maxHp,
			atk = unit.atk,
			def = unit.def,
			speed = unit.speed,
			el = unit.el,
			status = unit.status,
			statStages = unit.statStages,
			nextSkill = unit.nextSkill,
		}
	end

	-- Build foe data
	local foes = {}
	for i, foe in battle.wildFoes do
		foes[i] = {
			id = foe.id,
			lv = foe.lv,
			hp = foe.hp,
			maxHp = foe.maxHp,
			atk = foe.atk,
			def = foe.def,
			speed = foe.speed,
			el = foe.el,
			isLegendary = foe.isLegendary,
			status = foe.status,
			statStages = foe.statStages,
		}
	end

	return {
		battleId = battle.id,
		type = battle.type,
		turn = battle.turn,
		maxTurns = battle.maxTurns,
		status = battle.status,
		activeUid = participant.active,
		team = team,
		foes = foes,
		field = battle.field,
		log = battle.log,
		seals = participant.seals,
		items = participant.items,
		currentTurn = battle.turnOrder[battle.currentTurnIndex],
	}
end

function CombatService.sendBattleState(battle: BattleState, player: Player, extra: any?)
	local snapshot = CombatService.getBattleSnapshot(battle, player)
	if extra then
		for k, v in extra do snapshot[k] = v end
	end
	events:FireClient(player, snapshot)
end

-- Legendary Ascension check
function CombatService.checkAscension(player: Player, creatureUid: string): boolean
	local d = Data.get(player)
	if not d or not d.creatures[creatureUid] then return false end

	local creature = d.creatures[creatureUid]
	local def = C.ById[creature.id]
	if not def or creature.lv < 100 then return false end

	-- Check for ascension item
	local ascensionItems = {
		fenix = "CinaSolar",
		vulcanodrago = "NucleoVulcanico",
		abissauro = "PerolaAbissal",
		ancestravore = "SementePrimordial",
		colossodune = "CoracaoDasDunas",
		aeronimbo = "OlhoDaTempestade",
		reinevoento = "CoroaDoNevoeiro",
	}

	local requiredItem = ascensionItems[creature.id]
	if not requiredItem then return false end

	-- Check if player has item equipped or in inventory
	return (d.items[requiredItem] or 0) > 0
end

function CombatService.triggerAscension(player: Player, creatureUid: string): CombatRules.Combatant?
	local d = Data.get(player)
	if not d or not d.creatures[creatureUid] then return nil end

	local creature = d.creatures[creatureUid]
	local unit = CombatRules.stats(creature.id, creature.lv)

	local ascended = CombatRules.applyAscension(unit)
	return ascended
end

return CombatService