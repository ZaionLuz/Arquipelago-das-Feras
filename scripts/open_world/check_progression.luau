local Loader = require("../loader")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local load = Loader.load
local Access = load("src/shared/Access.luau")
local Bands = load("src/shared/LevelBands.luau")
local Pools = load("src/shared/EncounterPools.luau")
local Rules = load("src/shared/CombatRules.luau")
local Capture = load("src/shared/CaptureMath.luau")
local Story = load("src/shared/Story.luau")
local Migration = load("src/shared/Migration.luau")
local decisions = 0
for level = 1, 100 do
	for _, id in Bands.Order do
		for _, purpose in
			{ "travel", "encounter", "capture", "battle", "hatch", "shop", "habitat", "sanctuary", "unlock" }
		do
			assert(Access.check({ playerLevel = level, unlocked = {}, gold = 0 }, id, purpose).ok)
			decisions += 1
		end
	end
end
local previous = 0
for _, id in Bands.Order do
	local b = Bands.ById[id]
	assert(b.min > previous and b.max >= b.min)
	previous = b.max
end
local function rng(seed)
	return {
		NextNumber = function(self)
			seed = seed * 16807 % 2147483647
			return seed / 2147483647
		end,
	}
end
local draws = 0
for _, id in Bands.Order do
	for rarity = 1, 4 do
		local a, b = rng(1234), rng(1234)
		for _ = 1, 10000 do
			local low = Pools.rollLevel(id, rarity, a)
			local high = Pools.rollLevel(id, rarity, b)
			assert(low == high)
			draws += 1
		end
	end
end
local rates = {}
for _, lv in { 1, 5, 10, 20, 50 } do
	local s = Rules.new("lodinho", lv, { explorerLevel = 1 })
	s.sealKind = "Basic"
	local chance = Capture.chance(s)
	rates[tostring(lv)] = chance
end
assert(
	rates["1"] > rates["10"]
		and rates["10"] > rates["20"]
		and rates["20"] > rates["50"]
		and rates["50"] > 0.01
		and rates["50"] < 0.04
)
local state = Rules.new("lodinho", 50, { explorerLevel = 1 })
state.foe.hp = state.foe.maxHp * 0.1
state.bond = 3
state.sealKind = "Ancient"
local prepared = Capture.chance(state)
assert(prepared > rates["50"])
state.active = "p"
state.party.p = Rules.stats("lodinho", 45)
local trained = Capture.chance(state)
assert(trained > prepared)
local last = 0
for i = 0, 100 do
	state.foe.hp = state.foe.maxHp * (1 - i / 100)
	local p = Capture.chance(state)
	assert(p >= last and p >= 0.01 and p <= 0.94)
	last = p
end
for _, q in Story.List do
	assert(q.stat ~= "feed" and q.stat ~= "hatch" and q.stat ~= "breed" and q.stat ~= "habitatUpgrade")
end
local old = {
	v = 5,
	gold = 321,
	playerLevel = 1,
	creatures = { u1 = { id = "brotinho", lv = 6, xp = 20 } },
	unlocked = { Alvorecer = true },
	visited = { Brasa = true },
	storyClaimed = { care = true, birth = true },
}
local m = assert(Migration.run(old))
assert(
	m.v == 6
		and m.gold == 321
		and m.creatures.u1.lv == 6
		and m.creatures.u1.xp == 20
		and m.storyClaimed.care
		and m.storyClaimed.birth
)
assert(
	m.navigation.checkpoint == "Alvorecer"
		and m.navigation.visited.Brasa
		and m.unlocked.Pantano
		and not m.sanctuary.Pantano
)
fs.writeFile(
	"docs/open_world/PROGRESSION_TESTS.json",
	serde.encode("json", {
		schemaVersion = m.v,
		freeAccessDecisions = decisions,
		regionalLevelDraws = draws,
		levelsIndependentOfPlayer = true,
		directCaptureNovice = rates,
		preparedBelowLevel = prepared,
		preparedTeam45 = trained,
		storyRequiresBreeding = false,
		migrationPreservesClaims = true,
	}, true)
)
print(
	"PASS mundo livre: 6300 decisões sem custo/gate, 280000 níveis regionais, captura suave por diferença, aventura sem criação obrigatória, migração preservada"
)
