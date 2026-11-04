--!strict
local Bands = require(script.Parent.LevelBands)
local P = { MaxLevel = 100, EncountersPerHour = 50 }
local checkpoints = {
	{ level = 1, hours = 0 },
	{ level = 10, hours = 0.75 },
	{ level = 18, hours = 2 },
	{ level = 26, hours = 4 },
	{ level = 34, hours = 7 },
	{ level = 42, hours = 11 },
	{ level = 50, hours = 16 },
}
function P.playerCost(level: number): number
	for index = 1, #checkpoints - 1 do
		local a, b = checkpoints[index], checkpoints[index + 1]
		if level >= a.level and level < b.level then
			return math.floor((b.hours - a.hours) / (b.level - a.level) * P.EncountersPerHour * (60 + index * 10) + 0.5)
		end
	end
	return 2200 + (level - 50) * 75
end
function P.rewards(region: string, foeLevel: number, rarity: number, teamLevel: number)
	local band = assert(Bands.ById[region], "Região de recompensa desconhecida")
	local gap = teamLevel - foeLevel
	local penalty = gap >= 15 and 0.1 or gap >= 8 and 0.5 or 1
	return {
		gold = 30 * band.index ^ 2 + foeLevel * 2 + rarity * 3,
		xp = math.max(1, math.floor((60 + band.index * 10 + (rarity - 1) * 5) * penalty)),
		creatureXp = math.max(1, math.floor((45 + band.index * 8 + (rarity - 1) * 5) * penalty)),
		penalty = penalty,
	}
end
function P.creatureCost(level: number): number
	return 35 + level * 15
end
function P.award(data: any, amount: number)
	data.playerXp = math.min(1e9, (data.playerXp or 0) + math.max(0, math.floor(amount)))
	data.playerLevel = data.playerLevel or 1
	while data.playerLevel < P.MaxLevel and data.playerXp >= P.playerCost(data.playerLevel) do
		data.playerXp -= P.playerCost(data.playerLevel)
		data.playerLevel += 1
	end
end
function P.awardCreature(creature: any, amount: number)
	creature.xp = math.min(1e9, (creature.xp or 0) + math.max(0, math.floor(amount)))
	while creature.lv < P.MaxLevel and creature.xp >= P.creatureCost(creature.lv) do
		creature.xp -= P.creatureCost(creature.lv)
		creature.lv += 1
	end
end
return P
