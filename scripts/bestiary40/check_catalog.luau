-- Catálogo e seleção reais com tipos Roblox nativos; não executa física ou servidor Roblox.
local Loader = require("../loader")
local serde = require("@lune/serde")
local C = Loader.load("src/shared/Creatures.luau")
local D = Loader.load("src/shared/CreatureDesigns.luau")
local Lore = Loader.load("src/shared/SpeciesLore.luau")
local Species = Loader.load("src/shared/SpeciesRules.luau")
local Pools = Loader.load("src/shared/EncounterPools.luau")
local Breed = Loader.load("src/shared/Breeding.luau")
local Migration = Loader.load("src/shared/Migration.luau")
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
local baseline = serde.decode(
	"json",
	[==[[{"atk":11,"el":"Fogo","gpm":4,"hp":55,"id":"cinzelo","island":"Brasa","name":"Cinzelo","rar":1,"shape":"Blob"},{"atk":16,"el":"Fogo","gpm":10,"hp":80,"id":"magmarau","island":"Brasa","name":"Magmarau","rar":2,"shape":"Beast"},{"atk":21,"el":"Fogo","gpm":20,"hp":105,"id":"fenixfuligem","island":"Brasa","name":"Fênix Fuligem","rar":3,"shape":"Bird"},{"atk":26,"el":"Fogo","gpm":34,"hp":130,"id":"vulcanodrago","island":"Brasa","name":"Vulcanodrago","rar":4,"shape":"Dragon"},{"atk":11,"el":"Água","gpm":4,"hp":55,"id":"bolhinho","island":"Recife","name":"Bolhinho","rar":1,"shape":"Blob"},{"atk":16,"el":"Água","gpm":10,"hp":80,"id":"marilisco","island":"Recife","name":"Marilisco","rar":2,"shape":"Serpent"},{"atk":21,"el":"Água","gpm":20,"hp":105,"id":"carangueperola","island":"Recife","name":"Caranguepérola","rar":3,"shape":"Insect"},{"atk":26,"el":"Água","gpm":34,"hp":130,"id":"abissauro","island":"Recife","name":"Abissauro","rar":4,"shape":"Dragon"},{"atk":11,"el":"Natureza","gpm":4,"hp":55,"id":"brotinho","island":"Floresta","name":"Brotinho","rar":1,"shape":"Blob"},{"atk":16,"el":"Natureza","gpm":10,"hp":80,"id":"folhuco","island":"Floresta","name":"Folhuço","rar":2,"shape":"Beast"},{"atk":21,"el":"Natureza","gpm":20,"hp":105,"id":"aracnoflora","island":"Floresta","name":"Aracnoflora","rar":3,"shape":"Insect"},{"atk":26,"el":"Natureza","gpm":34,"hp":130,"id":"ancestravore","island":"Floresta","name":"Ancestrávore","rar":4,"shape":"Beast"},{"atk":11,"el":"Terra","gpm":4,"hp":55,"id":"graozinho","island":"Dunas","name":"Grãozinho","rar":1,"shape":"Blob"},{"atk":16,"el":"Terra","gpm":10,"hp":80,"id":"escorpiodra","island":"Dunas","name":"Escorpiodra","rar":2,"shape":"Insect"},{"atk":21,"el":"Terra","gpm":20,"hp":105,"id":"esfingeolito","island":"Dunas","name":"Esfingeolito","rar":3,"shape":"Beast"},{"atk":26,"el":"Terra","gpm":34,"hp":130,"id":"colossodune","island":"Dunas","name":"Colossodune","rar":4,"shape":"Dragon"},{"atk":11,"el":"Ar","gpm":4,"hp":55,"id":"penugem","island":"Picos","name":"Penugem","rar":1,"shape":"Bird"},{"atk":16,"el":"Ar","gpm":10,"hp":80,"id":"ventanil","island":"Picos","name":"Ventanil","rar":2,"shape":"Bird"},{"atk":21,"el":"Ar","gpm":20,"hp":105,"id":"trovoraptor","island":"Picos","name":"Trovoraptor","rar":3,"shape":"Dragon"},{"atk":26,"el":"Ar","gpm":34,"hp":130,"id":"aeronimbo","island":"Picos","name":"Aeronimbo","rar":4,"shape":"Serpent"},{"atk":11,"el":"Sombra","gpm":4,"hp":55,"id":"lodinho","island":"Pantano","name":"Lodinho","rar":1,"shape":"Blob"},{"atk":16,"el":"Sombra","gpm":10,"hp":80,"id":"caudalume","island":"Pantano","name":"Caudalume","rar":2,"shape":"Serpent"},{"atk":21,"el":"Sombra","gpm":20,"hp":105,"id":"vagalumorte","island":"Pantano","name":"Vagalumorte","rar":3,"shape":"Insect"},{"atk":26,"el":"Sombra","gpm":34,"hp":130,"id":"reinevoento","island":"Pantano","name":"Rei Nevoento","rar":4,"shape":"Beast"},{"atk":21,"el":"Fogo","gpm":20,"hp":105,"hybrid":["Fogo","Água"],"id":"vaporino","island":"Híbrido","name":"Vaporino","rar":3,"shape":"Serpent"},{"atk":21,"el":"Fogo","gpm":20,"hp":105,"hybrid":["Fogo","Terra"],"id":"magmaterra","island":"Híbrido","name":"Magmaterra","rar":3,"shape":"Beast"},{"atk":21,"el":"Ar","gpm":20,"hp":105,"hybrid":["Ar","Água"],"id":"tempestalia","island":"Híbrido","name":"Tempestália","rar":3,"shape":"Bird"},{"atk":21,"el":"Sombra","gpm":20,"hp":105,"hybrid":["Sombra","Natureza"],"id":"nevoamusgo","island":"Híbrido","name":"Névoamusgo","rar":3,"shape":"Beast"},{"atk":26,"el":"Fogo","gpm":34,"hp":130,"hybrid":["Fogo","Ar"],"id":"cinzavento","island":"Híbrido","name":"Cinzavento","rar":4,"shape":"Dragon"},{"acquisition":"special","atk":26,"el":"Fogo","futureStage":{"enabled":false,"mechanic":"Renascimento (futuro)","target":4},"gpm":34,"hp":130,"id":"fenix","island":"Brasa","minStage":3,"name":"Fênix","rar":4,"shape":"Bird"}]]==]
)
local expectedNew = {
	bambunim = { "Natureza", 1, "Floresta" },
	brasebode = { "Fogo", 2, "Brasa" },
	coralote = { "Água", 1, "Recife" },
	dunatatu = { "Terra", 2, "Dunas" },
	nimburso = { "Ar", 2, "Picos" },
	lumissapo = { "Sombra", 2, "Pantano" },
	nectarim = { "Natureza", 3, "Floresta" },
	cristalince = { "Terra", 3, "Dunas" },
	maritromba = { "Água", 2, "Recife" },
	kraken = { "Água", 4, "Recife" },
}
assert(#C.List == 40 and #baseline == 30)
local known, forms, eyeCounts, tuples, newCount = {}, 0, {}, {}, 0
for index, old in baseline do
	assert(same(old, C.List[index]), "Registro legado alterado: " .. old.id)
	assert(C.ById[old.id] == C.List[index])
end
for _, def in C.List do
	assert(not known[def.id] and C.ById[def.id] == def)
	known[def.id] = true
	assert(Lore[def.id] and #Lore[def.id].description > 25)
	local design = assert(D[def.id])
	assert(design.expression and #design.palette == 4)
	local tuple = table.concat({ design.family, design.head, design.eyes, design.tail, tostring(design.limbs) }, ":")
	assert(not tuples[tuple], "Anatomia de catálogo repetida")
	tuples[tuple] = true
	eyeCounts[design.eyes] = (eyeCounts[design.eyes] or 0) + 1
	local seen = {}
	for _, level in { 1, 7, 15 } do
		local stage = C.stage(level, def.id)
		if not seen[stage] then
			forms += 1
			seen[stage] = true
		end
	end
	local extra = expectedNew[def.id]
	if extra then
		newCount += 1
		assert(def.el == extra[1] and def.rar == extra[2] and def.island == extra[3])
		assert(Species.isGeneral(def.id))
		assert(table.find(Pools.list(def.island, false), def))
		assert((def.rar == 4) == (def.id == "kraken"), "Só Kraken é lendário entre os novos")
	end
end
for _, count in eyeCounts do
	assert(count <= 4)
end
assert(newCount == 10 and forms == 116)
assert(C.stage(1, "kraken") == 3 and C.stage(100, "kraken") == 3)
assert(C.stage(1, "fenix") == 3)
assert(not Species.isBreedable("kraken") and not Species.isBreedable(C.ById.kraken))
assert(not Species.isBreedable("invented") and not Species.isBreedable({ id = "cinzelo" }))
assert(Species.isBreedable("fenix"), "Permissão legada de pai da Fênix mudou")
assert(not table.find(Pools.list("Recife", true), C.ById.kraken))
assert(not table.find(Pools.list("Brasa", false), C.ById.fenix))
local seed = 40921
local rng = {}
function rng:NextNumber()
	seed = seed * 16807 % 2147483647
	return seed / 2147483647
end
function rng:NextInteger(a, b)
	return a + math.floor(self:NextNumber() * (b - a + 1))
end
local invalidChecks = 0
local function rejectsParent(value)
	local succeeded, breedable = pcall(Species.isBreedable, value)
	assert(succeeded and breedable == false, "Predicado lançou erro ou aceitou pai inválido")
	for _, pair in { { value, "cinzelo" }, { "cinzelo", value } } do
		assert(Breed.pick(pair[1], pair[2], rng) == nil)
		assert(next(Breed.outcomes(pair[1], pair[2])) == nil)
	end
	invalidChecks += 1
end
rejectsParent(nil)
for _, value in
	{
		false,
		true,
		0 / 0,
		math.huge,
		-math.huge,
		{},
		"invalido",
		"",
		{ id = "cinzelo" },
		{ id = false },
		{ id = 0 / 0 },
	}
do
	rejectsParent(value)
end
assert(invalidChecks == 12)
assert(Species.isBreedable(C.ById.fenix) and Breed.pick("fenix", "cinzelo", rng) ~= nil)
local observed = {}
for _, region in { "Alvorecer", "Brasa", "Recife", "Floresta", "Dunas", "Picos", "Pantano" } do
	for _ = 1, 50000 do
		local def = assert(Pools.pick(region, rng, false))
		assert(def.id ~= "fenix")
		observed[def.id] = (observed[def.id] or 0) + 1
	end
	local atCap = {}
	for _, def in Pools.list(region, false) do
		atCap[def.id] = def.rar == 4 and 1 or 2
	end
	assert(Pools.pick(region, rng, false, atCap) == nil)
end
for id in expectedNew do
	assert((observed[id] or 0) > 0, "Espécie não alcançável: " .. id)
end
assert(observed.kraken / observed.abissauro > 0.12 and observed.kraken / observed.abissauro < 0.24)
local edge = {
	NextNumber = function()
		return 1
	end,
}
assert(Pools.pick("Recife", edge, false, { kraken = 1 }).id ~= "kraken", "Fallback ignorou limite regional")
local pairs = 0
for _, a in C.List do
	for _, b in C.List do
		if not Species.isBreedable(a) or not Species.isBreedable(b) then
			assert(Breed.pick(a.id, b.id, rng) == nil and next(Breed.outcomes(a.id, b.id)) == nil)
		else
			pairs += 1
			local outcomes = Breed.outcomes(a.id, b.id)
			local total = 0
			for id, probability in outcomes do
				assert(id ~= "kraken" and id ~= "fenix" and Species.isBreedable(id))
				assert(probability > 0 and probability <= 1)
				total += probability
			end
			assert(math.abs(total - 1) < 1e-8)
			for _ = 1, 10 do
				assert(outcomes[Breed.pick(a.id, b.id, rng)])
			end
		end
	end
end
assert(pairs == 1521)
local creatures = { u1 = { id = "cinzelo", lv = 17, xp = 241 } }
local index = 1
for id in expectedNew do
	index += 1
	creatures["u" .. index] = { id = id, lv = 26, xp = 11 }
end
local raw = { v = 6, gold = 987, gems = 13, creatures = creatures, unlocked = { Recife = true }, nextId = 12 }
local migrated = assert(Migration.run(raw))
assert(same(raw.creatures, migrated.creatures) and migrated.gold == 987 and migrated.gems == 13)
assert(same(migrated, Migration.run(migrated)))
print(
	"PASS catálogo40: 30 registros legados preservados, 10 novos, 116 formas, 350000 encontros, 1521 pares reprodutíveis; Kraken raro/adulto/sem cruzamento"
)
