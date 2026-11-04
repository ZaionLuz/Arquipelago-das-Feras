local loader = require("./loader")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local C = loader.load("src/shared/Creatures.luau")
local D = loader.load("src/shared/CreatureDesigns.luau")
local Lore = loader.load("src/shared/SpeciesLore.luau")
local rows = {}
for _, def in C.List do
	local d = D[def.id]
	table.insert(rows, {
		id = def.id,
		name = def.name,
		element = def.el,
		family = d.family,
		head = d.head,
		eyes = d.eyes,
		tail = d.tail,
		limbs = d.limbs,
		feature = d.feature,
		surface = d.surface,
		budget = d.budget,
		story = Lore[def.id].description,
	})
end
fs.writeFile("/tmp/v7-design-export.json", serde.encode("json", rows, true))
