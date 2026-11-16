--!strict
-- Itens de evolução: pedras, condições, métodos
local Text = require(script.Parent.Strings).Text
local C = require(script.Parent.Creatures)

local E = {
	BySpecies = {},
	ByItem = {},
}

-- Métodos de evolução: "level", "stone", "trade", "friendship", "item", "location", "time"
-- level: evolui no nível X
-- stone: evolui com pedra de elemento específico
-- trade: evolui ao trocar (com item opcional)
-- friendship: evolui com vínculo alto
-- item: evolui usando item específico
-- location: evolui em local específico
-- time: evolui em horário específico (dia/noite)

local function add(id, data)
	data.species = id
	E.BySpecies[id] = data
	if data.item then
		E.ByItem[data.item] = E.ByItem[data.item] or {}
		table.insert(E.ByItem[data.item], id)
	end
end

-- Evoluções por nível
add("brotinho", { method = "level", level = 16, into = "folhuco" })
add("folhuco", { method = "level", level = 32, into = "aracnoflora" })
add("aracnoflora", { method = "level", level = 48, into = "ancestravore" })

add("cinzelo", { method = "level", level = 16, into = "magmarau" })
add("magmarau", { method = "level", level = 32, into = "fenixfuligem" })
add("fenixfuligem", { method = "level", level = 48, into = "vulcanodrago" })

add("bolhinho", { method = "level", level = 16, into = "marilisco" })
add("marilisco", { method = "level", level = 32, into = "carangueperola" })
add("carangueperola", { method = "level", level = 48, into = "abissauro" })

add("graozinho", { method = "level", level = 16, into = "escorpiodra" })
add("escorpiodra", { method = "level", level = 32, into = "esfingeolito" })
add("esfingeolito", { method = "level", level = 48, into = "colossodune" })

add("penugem", { method = "level", level = 16, into = "ventanil" })
add("ventanil", { method = "level", level = 32, into = "trovoraptor" })
add("trovoraptor", { method = "level", level = 48, into = "aeronimbo" })

add("lodinho", { method = "level", level = 16, into = "caudalume" })
add("caudalume", { method = "level", level = 32, into = "vagalumorte" })
add("vagalumorte", { method = "level", level = 48, into = "reinevoento" })

-- Evoluções por pedra (segunda fase das linhas base)
add("brotinho", { method = "stone", element = Text.NATUREZA_FB1ED9, into = "musgalte", item = "evo_stone_nature" })
add("cinzelo", { method = "stone", element = Text.FOGO_F77A3C, into = "brasegato", item = "evo_stone_fire" })
add("bolhinho", { method = "stone", element = Text.AGUA_F11A05, into = "coralina", item = "evo_stone_water" })
add("graozinho", { method = "stone", element = Text.TERRA_16D3AE, into = "marmure", item = "evo_stone_earth" })
add("penugem", { method = "stone", element = Text.AR_B623FF, into = "cirrandor", item = "evo_stone_air" })
add("lodinho", { method = "stone", element = Text.SOMBRA_94B135, into = "velune", item = "evo_stone_shadow" })

-- Evoluções por pedra (terceira fase)
add("folhuco", { method = "stone", element = Text.NATUREZA_FB1ED9, into = "bambuja", item = "evo_stone_nature" })
add("magmarau", { method = "stone", element = Text.FOGO_F77A3C, into = "flamiris", item = "evo_stone_fire" })
add("marilisco", { method = "stone", element = Text.AGUA_F11A05, into = "orvalume", item = "evo_stone_water" })
add("escorpiodra", { method = "stone", element = Text.TERRA_16D3AE, into = "litorisco", item = "evo_stone_earth" })
add("ventanil", { method = "stone", element = Text.AR_B623FF, into = "sibilobo", item = "evo_stone_air" })
add("caudalume", { method = "stone", element = Text.SOMBRA_94B135, into = "obsidauro", item = "evo_stone_shadow" })

-- Evoluções por pedra para Gelo/Elétrico/Luz/Metal
add("brotinho", { method = "stone", element = Text.GELO_4A90D9, into = "gelifoca", item = "evo_stone_ice" })
add("cinzelo", { method = "stone", element = Text.ELETRICO_FFD600, into = "fulgarru", item = "evo_stone_electric" })
add("bolhinho", { method = "stone", element = Text.LUZ_FFF9C4, into = "candeira", item = "evo_stone_light" })
add("graozinho", { method = "stone", element = Text.METAL_B0BEC5, into = "ferrunila", item = "evo_stone_metal" })

-- Evoluções por item especial (pedras raras)
add("fenixfuligem", { method = "item", item = "key_phoenix_feather", into = "metafalcao" })
add("colossodune", { method = "item", item = "key_ancient_tablet", into = "glaurina" })
add("aeronimbo", { method = "item", item = "key_celestial_shard", into = "nimboreo" })
add("reinevoento", { method = "item", item = "key_guardian_crest", into = "velumosa" })

-- Evoluções por amizade/vínculo
add("musgalte", { method = "friendship", bond = 3, into = "florabelha" })
add("brasegato", { method = "friendship", bond = 3, into = "carvunio" })
add("coralina", { method = "friendship", bond = 3, into = "pelaguir" })
add("marmure", { method = "friendship", bond = 3, into = "sementauro" })
add("cirrandor", { method = "friendship", bond = 3, into = "nimboreo" })
add("velune", { method = "friendship", bond = 3, into = "velumosa" })

-- Evoluções por localização (ilhas específicas)
add("bambuja", { method = "location", location = "Floresta", into = "sementauro" })
add("litorisco", { method = "location", location = "Recife", into = "pelaguir" })

-- Evoluções por horário (dia/noite)
add("aracnoflora", { method = "time", time = "night", into = "vagalumorte" })
add("carangueperola", { method = "time", time = "day", into = "coralina" })

-- Híbridos não evoluem (são terminais)
-- Lendárias não evoluem (são terminais, mas têm Ascensão)

function E.getEvolution(speciesId: string, method: string?)
	local data = E.BySpecies[speciesId]
	if not data then return nil end
	if method and data.method ~= method then return nil end
	return data
end

function E.getAllEvolutions(speciesId: string)
	local results = {}
	for _, data in E.BySpecies do
		if data.species == speciesId then
			table.insert(results, data)
		end
	end
	return results
end

function E.canEvolve(creature, profile, context: { location: string?, timeOfDay: string?, bond: number? }?)
	local data = E.BySpecies[creature.id]
	if not data then return nil end

	if data.method == "level" then
		if creature.lv >= data.level then
			return data
		end
	elseif data.method == "stone" then
		-- Verificado no InventoryService
		return data
	elseif data.method == "friendship" then
		local bond = context and context.bond or creature.bond or 0
		if bond >= data.bond then
			return data
		end
	elseif data.method == "location" then
		if context and context.location == data.location then
			return data
		end
	elseif data.method == "time" then
		if context and context.timeOfDay == data.time then
			return data
		end
	elseif data.method == "item" then
		-- Verificado no InventoryService
		return data
	end

	return nil
end

return E