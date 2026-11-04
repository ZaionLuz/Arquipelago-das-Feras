local Loader = require("./loader")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local load = Loader.load
local C = load("src/shared/Creatures.luau")
local Bands = load("src/shared/LevelBands.luau")
local Access = load("src/shared/Access.luau")
local Migration = load("src/shared/Migration.luau")
local Grant = load("src/shared/CreatureGrant.luau")
local Pools = load("src/shared/EncounterPools.luau")
local Breed = load("src/shared/Breeding.luau")
local Q = load("src/shared/PhoenixQuest.luau")
local Math = load("src/shared/CaptureMath.luau")
local Rules = load("src/shared/CombatRules.luau")
local Seals = load("src/shared/CaptureRules.luau")
local seed = 718
local rng = {}
function rng:NextNumber()
	seed = seed * 16807 % 2147483647
	return seed / 2147483647
end
function rng:NextInteger(a, b)
	return a + math.floor(self:NextNumber() * (b - a + 1))
end
local function same(a, b)
	if type(a) ~= type(b) then
		return false
	end
	if type(a) ~= "table" then
		return a == b
	end
	for k, v in a do
		if not same(v, b[k]) then
			return false
		end
	end
	for k in b do
		if a[k] == nil then
			return false
		end
	end
	return true
end
local function profile(version)
	return {
		v = version or 4,
		gold = 1000,
		gems = 12,
		playerLevel = 1,
		playerXp = 70,
		nextId = 2,
		seals = 10,
		creatures = { u1 = { id = "cinzelo", lv = 15, xp = 200 } },
		eggs = { { id = "bolhinho", ready = 12345 } },
		unlocked = { Brasa = true, Recife = true },
		sanctuary = { Brasa = { slot = 1, level = 3 } },
		habitat = { Brasa = { "u1" } },
		stats = { win = 12 },
		claimed = { m1 = true },
		storyClaimed = { arrival = true },
	}
end
local fixtures = {}
-- Versões de aplicação V1–V6 usam esquemas 1,2,2,3,3,4: fixtures sintéticas rotuladas.
for app, schema in { 1, 2, 2, 3, 3, 4 } do
	local old = profile(schema)
	local migrated = assert(Migration.run(old))
	assert(same(migrated, Migration.run(migrated)))
	assert(
		same(old.creatures, migrated.creatures) and same(old.habitat, migrated.habitat) and old.gold == migrated.gold
	)
	assert(migrated.unlocked.Brasa and migrated.legacyGrandfathered.Brasa and not migrated.phoenix.captured)
	fixtures["V" .. app] = { application = app, schema = schema, synthetic = true, profile = old }
end
fs.writeFile("tests/fixtures/v1-v6.json", serde.encode("json", fixtures, true))
for _ = 1, 1000 do
	local old = profile()
	old.gold = rng:NextInteger(0, 1000000000)
	old.creatures.u1.lv = rng:NextInteger(1, 100)
	old.creatures.u1.xp = rng:NextInteger(0, 100000)
	if rng:NextNumber() < 0.5 then
		old.unlocked.Pantano = true
	end
	local m = assert(Migration.run(old))
	assert(same(old.creatures, m.creatures) and same(m, Migration.run(m)))
	for id, v in old.unlocked do
		assert(not v or m.unlocked[id])
	end
	assert(old.playerXp == m.playerXp and old.gold == m.gold)
end
for _, raw in
	{
		{},
		{ v = 99, creatures = { u1 = { id = "cinzelo", lv = 1 } } },
		{ v = 4, creatures = {} },
		{ v = 4, creatures = { u1 = { id = "inventado", lv = 1 } } },
		{ v = 4, creatures = { u1 = { id = "cinzelo", lv = 1 } }, phoenix = "erro" },
	}
do
	assert(not Migration.run(raw))
end
print("PASS V7.01: migração, 6 fixtures sintéticas, 1000 perfis, idempotência e rejeição segura")
local Config = load("src/shared/Config.luau")
local checks = 0
for _, open in { true, false } do
	Config.World.FreeExploration = open
	for level = 1, 100 do
		for _, id in Bands.Order do
			for _, purpose in
				{ "travel", "encounter", "capture", "battle", "hatch", "shop", "habitat", "sanctuary", "unlock" }
			do
				local d = profile(5)
				d.playerLevel = level
				d.unlocked = {}
				for _, island in Bands.Order do
					d.unlocked[island] = true
				end
				d.gold = 1e6
				local result = Access.check(d, id, purpose)
				assert(result.ok == (open or level >= Bands.ById[id].min))
				checks += 1
				d.unlocked[id] = nil
				if purpose ~= "unlock" then
					assert(Access.check(d, id, purpose).ok == open)
				end
				d.legacyGrandfathered = { [id] = true }
				d.unlocked[id] = true
				assert(Access.check(d, id, purpose).ok)
			end
		end
	end
end
Config.World.FreeExploration = true
for _, bad in { {}, 0 / 0, 123, false, "inexistente" } do
	assert(not Access.check(profile(), bad, "travel").ok)
end
local invalid = profile()
invalid.playerLevel = 0 / 0
assert(not Access.check(invalid, "Brasa", "travel").ok)
print("PASS V7.02: matriz Access", checks, "decisões, argumentos forjados, legado")
local distributions = {}
for _, id in Bands.Order do
	distributions[id] = {}
	for rarity = 1, 4 do
		local distinct = {}
		local n = 0
		local band = Bands.ById[id]
		for _ = 1, 10000 do
			local lv = Pools.rollLevel(id, rarity, rng)
			assert(lv >= band.min and lv <= band.max + (rarity == 4 and 3 or rarity == 3 and 2 or 0))
			distinct[lv] = true
		end
		for _ in distinct do
			n += 1
		end
		assert(n >= 5)
		distributions[id][rarity] = n
	end
	for _, commercial in { false, true } do
		for _ = 1, 10000 do
			local def = assert(Pools.pick(id, rng, commercial))
			assert(def.acquisition ~= "special")
		end
	end
end
for _, a in C.List do
	for _, b in C.List do
		for id in Breed.outcomes(a.id, b.id) do
			assert(C.ById[id].acquisition ~= "special")
		end
		for _ = 1, 100 do
			assert(Breed.pick(a.id, b.id, rng) ~= "fenix")
		end
	end
end
assert(table.find(Pools.list("Brasa", false), C.ById.fenixfuligem))
assert(table.find(Pools.list("Brasa", true), C.ById.fenixfuligem))
print("PASS V7.04/07: 280 mil níveis, 140 mil pools, 90 mil cruzamentos e Fuligem preservada")
local d = assert(Migration.run(profile()))
local count = 0
for _ in d.creatures do
	count += 1
end
for _, source in
	{
		"wild_capture",
		"hatch",
		"breed",
		"shop",
		"quest",
		"event",
		"daily",
		"starter",
		"migration",
		"legacy_egg",
		"admin",
	}
do
	assert(not Grant.grant(d, "fenix", source, "forged:" .. source))
end
local old = profile()
old.eggs = { { id = "fenix", ready = 123 } }
old = assert(Migration.run(old))
local egg = old.eggs[1]
assert(Grant.grant(old, "fenix", "legacy_egg", egg.nonce))
assert(not old.legacyEggPermits[egg.nonce])
assert(not Grant.grant(old, "fenix", "hatch", "new"))
d.playerLevel = 50
d.unlocked.Dunas = true
d.phoenix.glyphs = { duneHidden = true, duneRuin = true, skyPeak = true }
assert(Q.check(d, 10000))
d.phoenix.encounterId = "single"
local uid = Grant.grant(d, "fenix", "phoenix_sanctuary", "single", { level = 60 })
assert(uid)
for _ = 1, 100 do
	assert(Grant.grant(d, "fenix", "phoenix_sanctuary", "single") == uid)
end
local after = 0
for _ in d.creatures do
	after += 1
end
assert(after == count + 1 and d.phoenix.captured)
d.phoenix.encounterId = "other"
assert(not Grant.grant(d, "fenix", "phoenix_sanctuary", "other"))
local new = profile(5)
new.unlocked = { Alvorecer = true }
new.phoenix = { glyphs = {} }
local payload = serde.encode("json", Q.public(new))
assert(
	payload == '{"stage":0}'
		and not payload:find("Fênix")
		and not payload:find("Santuário")
		and not payload:find("Glifo")
)
print(
	"PASS V7.07/09/10: origens bloqueadas, ovo legado autenticado, 100 replays = 1 concessão, payload zero sem spoilers"
)
local simulations = {}
local s = Rules.new("fenix", 60)
s.isLegendary = true
s.captureBase = 0.04
local scenarios = {
	{ name = "sem preparo", health = 1, bond = 0, seal = "Basic", expected = 25 },
	{ name = "médio", health = 0.5, bond = 1, seal = "Reinforced", expected = 10 },
	{ name = "ótimo", health = 0.1, bond = 3, seal = "Ancient", expected = 5 },
}
for _, scenario in scenarios do
	s.foe.hp = s.foe.maxHp * scenario.health
	s.bond = scenario.bond
	s.sealKind = scenario.seal
	local p = Math.chance(s)
	local attempts, total15 = 0, 0
	for _ = 1, 100000 do
		local n = 1
		while rng:NextNumber() >= p do
			n += 1
		end
		attempts += n
		if n <= 15 then
			total15 += 1
		end
	end
	local mean = attempts / 100000
	local within15 = total15 / 100000
	assert(math.abs(mean - scenario.expected) / scenario.expected < 0.15)
	if scenario.name == "ótimo" then
		assert(p >= 0.18 and p <= 0.25 and within15 >= 0.9)
	end
	if scenario.name == "sem preparo" then
		assert(within15 > 0.42 and within15 < 0.5)
	end
	table.insert(
		simulations,
		{ scenario = scenario.name, chance = p, meanAttempts = mean, within15 = within15, executions = 100000 }
	)
end
for bond = 0, 3 do
	for _, seal in Seals.SealOrder do
		local previous = 0
		for step = 0, 100 do
			s.bond = bond
			s.sealKind = seal
			s.foe.hp = s.foe.maxHp * (1 - step / 100)
			local p = Math.chance(s)
			assert(p >= 0.01 and p <= 0.35 and p >= previous)
			previous = p
		end
	end
end
s.bond = 3
s.foe.hp = s.foe.maxHp * 0.1
local previous = 0
for _, seal in Seals.SealOrder do
	s.sealKind = seal
	local p = Math.chance(s)
	assert(p >= previous)
	previous = p
end
fs.writeFile(
	"docs/CAPTURE_SIMULATION.json",
	serde.encode("json", { seed = 718, scenarios = simulations, levels = distributions }, true)
)
print("PASS V7.08: 300 mil execuções Monte Carlo, monotonicidade e limites")

local legendary = Rules.new("fenix", 60)
legendary.isLegendary = true
legendary.captureBase = 0.04
local resisting = {
	NextNumber = function()
		return 0.99999
	end,
}
for _ = 1, 15 do
	assert(Rules.step(legendary, "Capture", nil, resisting, 100, true))
end
assert(legendary.status == "active" and legendary.attempts == 15)
print("PASS V7.08: encontro especial permite 15 selos sem fuga aleatória herdada de animais comuns")
