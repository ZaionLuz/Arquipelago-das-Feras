--!strict
-- ItemSystem.lua - Sistema de itens (inventário, uso, crafting)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local ItemSystem = {}

-- Events
ItemSystem.OnItemAdded = Signal.New()
ItemSystem.OnItemRemoved = Signal.New()
ItemSystem.OnItemUsed = Signal.New()

-- Player inventories
local PlayerInventories = {} :: {[number]: {Types.ItemData}}

-- Inventory config
local MAX_INVENTORY_SIZE = 100
local MAX_STACK_SIZE = 99

-- Initialize player inventory
function ItemSystem.InitializePlayer(player: Player)
	PlayerInventories[player.UserId] = {}

	-- Give starter items
	ItemSystem.AddItem(player, "Potion", 5)
	ItemSystem.AddItem(player, "BasicBall", 10)

	print(`[ItemSystem] Initialized inventory for {player.Name}`)
end

-- Cleanup player
function ItemSystem.CleanupPlayer(player: Player)
	PlayerInventories[player.UserId] = nil
end

-- Get player inventory
function ItemSystem.GetInventory(player: Player): {Types.ItemData}
	return PlayerInventories[player.UserId] or {}
end

-- Add item to inventory
function ItemSystem.AddItem(player: Player, itemId: string, count: number?): boolean
	count = count or 1
	local inventory = PlayerInventories[player.UserId]
	if not inventory then return false end

	local itemConfig = Config.Items[itemId]
	if not itemConfig then
		warn(`[ItemSystem] Item not found: {itemId}`)
		return false
	end

	local remaining = count

	-- Try to stack with existing items
	if itemConfig.Stackable then
		for _, item in ipairs(inventory) do
			if item.Id == itemId and item.Count < (itemConfig.MaxStack or MAX_STACK_SIZE) then
				local canAdd = math.min(remaining, (itemConfig.MaxStack or MAX_STACK_SIZE) - item.Count)
				item.Count += canAdd
				remaining -= canAdd
				if remaining <= 0 then
					ItemSystem.OnItemAdded:Fire(player, itemId, count)
					return true
				end
			end
		end
	end

	-- Add new stacks
	while remaining > 0 do
		if #inventory >= MAX_INVENTORY_SIZE then
			warn(`[ItemSystem] Inventory full for {player.Name}`)
			return false
		end

		local stackSize = math.min(remaining, itemConfig.MaxStack or MAX_STACK_SIZE)
		table.insert(inventory, {
			Id = itemId,
			Count = stackSize,
		})
		remaining -= stackSize
	end

	ItemSystem.OnItemAdded:Fire(player, itemId, count)
	return true
end

-- Remove item from inventory
function ItemSystem.RemoveItem(player: Player, itemId: string, count: number?): boolean
	count = count or 1
	local inventory = PlayerInventories[player.UserId]
	if not inventory then return false end

	local remaining = count

	-- Remove from stacks (last added first for LIFO)
	for i = #inventory, 1, -1 do
		local item = inventory[i]
		if item.Id == itemId then
			if item.Count <= remaining then
				remaining -= item.Count
				table.remove(inventory, i)
			else
				item.Count -= remaining
				remaining = 0
			end

			if remaining <= 0 then
				ItemSystem.OnItemRemoved:Fire(player, itemId, count)
				return true
			end
		end
	end

	return false
end

-- Check if player has item
function ItemSystem.HasItem(player: Player, itemId: string, count: number?): boolean
	count = count or 1
	local inventory = PlayerInventories[player.UserId]
	if not inventory then return false end

	local total = 0
	for _, item in ipairs(inventory) do
		if item.Id == itemId then
			total += item.Count
			if total >= count then
				return true
			end
		end
	end

	return false
end

-- Get item count
function ItemSystem.GetItemCount(player: Player, itemId: string): number
	local inventory = PlayerInventories[player.UserId]
	if not inventory then return 0 end

	local total = 0
	for _, item in ipairs(inventory) do
		if item.Id == itemId then
			total += item.Count
		end
	end

	return total
end

-- Use item on target
function ItemSystem.UseItem(player: Player, itemId: string, targetCreatureId: string?): (boolean, string?)
	local inventory = PlayerInventories[player.UserId]
	if not inventory then return false, "No inventory" end

	-- Check if player has item
	if not ItemSystem.HasItem(player, itemId, 1) then
		return false, "Item not in inventory"
	end

	local itemConfig = Config.Items[itemId]
	if not itemConfig then return false, "Invalid item" end

	-- Get target creature
	local targetCreature: Types.CreatureData?
	if targetCreatureId then
		local partySystem = require(script.Parent.PartySystem)
		for _, creature in ipairs(partySystem.GetPlayerParty(player)) do
			if creature.Id == targetCreatureId then
				targetCreature = creature
				break
			end
		end

		-- Check storage if not in party
		if not targetCreature then
			for _, box in ipairs(partySystem.GetPlayerStorage(player)) do
				for _, creature in ipairs(box) do
					if creature.Id == targetCreatureId then
						targetCreature = creature
						break
					end
				end
				if targetCreature then break end
			end
		end
	else
		-- Use on first party member
		local partySystem = require(script.Parent.PartySystem)
		targetCreature = partySystem.GetFirstAlive(player)
	end

	if not targetCreature then
		return false, "No valid target"
	end

	-- Apply item effect
	local success, message = ItemSystem.ApplyItemEffect(itemConfig, targetCreature)

	if success then
		ItemSystem.RemoveItem(player, itemId, 1)
		ItemSystem.OnItemUsed:Fire(player, itemId, targetCreature)
		return true, message
	end

	return false, message
end

-- Apply item effect to creature
function ItemSystem.ApplyItemEffect(itemConfig: Types.ItemData, creature: Types.CreatureData): (boolean, string)
	local effect = itemConfig.Effect

	if effect.Type == "Heal" then
		local amount = effect.Params.Amount or 0
		if amount < 0 then amount = creature.Stats.HP end -- Full heal

		local oldHP = creature.CurrentHP
		creature.CurrentHP = math.min(creature.Stats.HP, creature.CurrentHP + amount)
		local healed = creature.CurrentHP - oldHP

		return true, `Curou {healed} HP!`

	elseif effect.Type == "CureStatus" then
		local status = effect.Params.Status
		if status == "All" then
			creature.Status = "None"
			return true, `Curou todos os status!`
		elseif creature.Status == status then
			creature.Status = "None"
			return true, `Curou {status}!`
		else
			return false, `Não está com {status}`
		end

	elseif effect.Type == "PPRestore" then
		local amount = effect.Params.Amount or 0
		local allMoves = effect.Params.AllMoves or false

		if allMoves then
			for _, move in ipairs(creature.Moves) do
				if amount < 0 then
					move.PP = move.MaxPP
				else
					move.PP = math.min(move.MaxPP, move.PP + amount)
				end
			end
			return true, `Restaurou PP de todos os movimentos!`
		else
			-- Would need to specify which move
			return false, "Especifique o movimento"
		end

	elseif effect.Type == "Revive" then
		if creature.CurrentHP <= 0 then
			local hpPercent = effect.Params.RevivesWithHP or 0.5
			creature.CurrentHP = math.floor(creature.Stats.HP * hpPercent)
			creature.Status = "None"
			return true, `Reviveu com {creature.CurrentHP} HP!`
		else
			return false, "Já está consciente"
		end

	elseif effect.Type == "Evolve" then
		-- Evolution handled by EvolutionSystem
		return true, "Item de evolução usado!"

	elseif effect.Type == "TeachMove" then
		-- Move learning handled separately
		return true, "MT usada!"

	elseif effect.Type == "Capture" then
		-- Capture balls handled by CreatureSystem
		return true, "Bola de captura!"
	end

	return false, "Efeito não implementado"
end

-- Get item info for UI
function ItemSystem.GetItemInfo(itemId: string): Types.ItemData?
	return Config.Items[itemId]
end

-- Get all items in inventory with full info
function ItemSystem.GetInventoryWithInfo(player: Player): {{Item: Types.ItemData, Count: number}}
	local inventory = PlayerInventories[player.UserId] or {}
	local result = {}

	for _, invItem in ipairs(inventory) do
		local itemData = Config.Items[invItem.Id]
		if itemData then
			table.insert(result, {
				Item = itemData,
				Count = invItem.Count,
			})
		end
	end

	return result
end

-- Sort inventory
function ItemSystem.SortInventory(player: Player, sortType: "Name" | "Type" | "Count" | "Rarity")
	local inventory = PlayerInventories[player.UserId]
	if not inventory then return end

	table.sort(inventory, function(a, b)
		local itemA = Config.Items[a.Id]
		local itemB = Config.Items[b.Id]

		if sortType == "Name" then
			return (itemA and itemA.Name or a.Id) < (itemB and itemB.Name or b.Id)
		elseif sortType == "Type" then
			return (itemA and itemA.Type or "") < (itemB and itemB.Type or "")
		elseif sortType == "Count" then
			return a.Count > b.Count
		elseif sortType == "Rarity" then
			-- Would need rarity field on items
			return a.Id < b.Id
		end
		return a.Id < b.Id
	end)
end

return ItemSystem