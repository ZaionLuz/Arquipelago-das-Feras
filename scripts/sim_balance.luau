local loader = require("./loader")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local C = loader.load("src/shared/Creatures.luau")
local R = loader.load("src/shared/CombatRules.luau")
local P = loader.load("src/shared/Progression.luau")
local Bands = loader.load("src/shared/LevelBands.luau")
local seed = 3103
local rng = {}
function rng:NextNumber()
	seed = seed * 16807 % 2147483647
	return seed / 2147483647
end
function rng:NextInteger(a, b)
	return a + math.floor(self:NextNumber() * (b - a + 1))
end
local function fight(id, level, enemy, enemyLevel, mult, partySize)
	local s = R.new(enemy, enemyLevel, { statMultiplier = mult, isLegendary = enemy == "fenix" })
	local function species(n)
		return type(id) == "table" and id[n] or id
	end
	local nextPet = 1
	R.step(s, "Select", { id = species(1), lv = level, uid = "p1" }, rng, 0, true)
	while s.status == "active" do
		local pet = s.party[s.active]
		if pet.hp <= 0 then
			if nextPet >= (partySize or 1) then
				return false
			end
			nextPet += 1
			R.step(s, "Select", { id = species(nextPet), lv = level, uid = "p" .. nextPet }, rng, 0, true)
		else
			local action = s.turn >= (pet.nextSkill or 0) and "Skill" or "Strike"
			R.step(s, action, nil, rng, 0, true)
		end
	end
	return s.status == "won"
end
local phoenix = {}
for level = 45, 55 do
	local raw, prepared = 0, 0
	for _ = 1, 1000 do
		raw += fight({ "fenixfuligem", "fenixfuligem", "fenixfuligem" }, level, "fenix", 60, 1.3, 3) and 1 or 0
		prepared += fight({ "marilisco", "cinzelo", "magmarau" }, level, "fenix", 60, 1.3, 3) and 1 or 0
	end
	table.insert(phoenix, { level = level, unprepared = raw / 1000, prepared = prepared / 1000 })
	print("phoenix", level, raw / 1000, prepared / 1000)
end
local rows = {}
for _, level in { 10, 18, 26, 34, 42, 50 } do
	local win, plus, guardian, under = 0, 0, 0, 0
	for _ = 1, 1000 do
		win += fight("cinzelo", level, "cinzelo", level, 1, 1) and 1 or 0
		plus += fight("cinzelo", level, "cinzelo", level + 5, 1, 1) and 1 or 0
		guardian += fight({ "magmarau", "cinzelo", "magmarau" }, level + 7, "fenixfuligem", level + 9, 1.17, 3) and 1 or 0
		under += fight("cinzelo", level - 10 > 0 and level - 10 or 1, "cinzelo", level, 1, 3) and 1 or 0
	end
	table.insert(rows, {
		level = level,
		common = win / 1000,
		plusFive = plus / 1000,
		guardian = guardian / 1000,
		underTen = under / 1000,
	})
	print("balance", level, win / 1000, plus / 1000, guardian / 1000, under / 1000)
end
local pace = {}
local hours = 0
for level = 1, 49 do
	local index = 1
	for _, id in Bands.Order do
		if level >= Bands.ById[id].min then
			index = Bands.ById[id].index
		end
	end
	hours += P.playerCost(level) / (P.EncountersPerHour * (60 + index * 10))
	if table.find({ 10, 18, 26, 34, 42, 50 }, level + 1) then
		table.insert(pace, { level = level + 1, hours = hours })
	end
end
local aggregate = { common = 0, plusFive = 0, guardian = 0, underTen = 0, unprepared = 0, prepared = 0 }
for _, row in rows do
	for _, key in { "common", "plusFive", "guardian", "underTen" } do
		aggregate[key] += row[key] / #rows
	end
end
for _, row in phoenix do
	aggregate.unprepared += row.unprepared / #phoenix
	aggregate.prepared += row.prepared / #phoenix
end
assert(
	aggregate.common >= 0.85 and aggregate.common <= 0.95 and aggregate.plusFive >= 0.55 and aggregate.plusFive <= 0.70
)
assert(aggregate.guardian >= 0.45 and aggregate.guardian <= 0.60 and aggregate.underTen < 0.15)
assert(
	aggregate.unprepared >= 0.25
		and aggregate.unprepared <= 0.40
		and aggregate.prepared >= 0.60
		and aggregate.prepared <= 0.75
)
for index, row in pace do
	assert(math.abs(row.hours - ({ 0.75, 2, 4, 7, 11, 16 })[index]) < 0.02)
end
local gold = {}
local previousMax = 0
local C = loader.load("src/shared/Creatures.luau")
for index, id in Bands.Order do
	local band = Bands.ById[id]
	local min = P.rewards(id, band.min, 1, band.min)
	local max = P.rewards(id, band.max + 3, 4, band.min)
	assert(min.gold > previousMax)
	previousMax = max.gold
	local penalty = P.rewards(id, band.min, 1, band.min + 8)
	local reduced = P.rewards(id, band.min, 1, band.min + 15)
	assert(penalty.penalty == 0.5 and reduced.penalty == 0.1 and reduced.xp < penalty.xp and penalty.xp < min.xp)
	if index > 1 then
		local previous = Bands.ById[Bands.Order[index - 1]]
		local income = 4 * C.ById.cinzelo.gpm * (1 + 0.15 * (previous.min - 1)) * 1.5
		local hours = band.cost / income / 60
		assert(hours >= 0.7 and hours <= 1.2)
		table.insert(gold, { island = id, cost = band.cost, hours = hours, incomePerMinute = income })
	end
end
local explorer = { playerLevel = 1, playerXp = 0 }
P.award(explorer, 1e9)
assert(explorer.playerLevel >= 50)
local creature = { lv = 1, xp = 0 }
P.awardCreature(creature, 1e9)
assert(creature.lv >= 60)
print(
	"PASS V7.05/06: médias de combate e Fênix nas metas; ouro crescente, penalidades, ritmo e limites alcançáveis"
)
fs.writeFile(
	"docs/BALANCE_SIMULATION.json",
	serde.encode("json", {
		seed = 3103,
		aggregate = aggregate,
		gold = gold,
		executionsPerCase = 1000,
		combat = rows,
		pacing = pace,
		phoenix = phoenix,
		assumptions = "50 vitórias/h, XP comum, sem missões/offline/penalidade; combate sem vantagem elemental: 1 comum; guardião na borda superior: raro/comum/raro; abaixo: 3 comuns. Fênix: 3 épicos fogo sem preparo; raro água/comum fogo/raro fogo preparado. Metas avaliadas na média das faixas, não por espécie individual",
	}, true)
)
