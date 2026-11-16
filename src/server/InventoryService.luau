--!nonstrict
-- Serviço de inventário: itens, pedras de evolução, itens segurados
local RS = game:GetService("ReplicatedStorage")
local Text = require(RS.Shared.Strings).Text
local C = require(RS.Shared.Creatures)
local Progression = require(RS.Shared.Progression)
local EvolutionItems = require(RS.Shared.EvolutionItems)
local SpeciesRules = require(RS.Shared.SpeciesRules)

local Inv = {}

-- Tipos de itens
Inv.ItemType = {
	EvolutionStone = "EvolutionStone",
	HeldItem = "HeldItem",
	Consumable = "Consumable",
	Material = "Material",
	Seal = "Seal",
	Egg = "Egg",
	KeyItem = "KeyItem",
}

-- Catálogo de itens
Inv.Items = {
	-- Pedras de Evolução
	evo_stone_fire = {
		id = "evo_stone_fire",
		name = "Pedra de Fogo",
		type = Inv.ItemType.EvolutionStone,
		element = Text.FOGO_F77A3C,
		description = "Evolui certas feras de Fogo. Brilha com calor intenso.",
		icon = "rbxassetid://0",
		price = 500,
		sellPrice = 125,
		stackable = true,
		maxStack = 99,
	},
	evo_stone_water = {
		id = "evo_stone_water",
		name = "Pedra de Água",
		type = Inv.ItemType.EvolutionStone,
		element = Text.AGUA_F11A05,
		description = "Evolui certas feras de Água. Pulsa como uma maré.",
		icon = "rbxassetid://0",
		price = 500,
		sellPrice = 125,
		stackable = true,
		maxStack = 99,
	},
	evo_stone_nature = {
		id = "evo_stone_nature",
		name = "Pedra de Natureza",
		type = Inv.ItemType.EvolutionStone,
		element = Text.NATUREZA_FB1ED9,
		description = "Evolui certas feras de Natureza. Exala aroma de floresta.",
		icon = "rbxassetid://0",
		price = 500,
		sellPrice = 125,
		stackable = true,
		maxStack = 99,
	},
	evo_stone_earth = {
		id = "evo_stone_earth",
		name = "Pedra de Terra",
		type = Inv.ItemType.EvolutionStone,
		element = Text.TERRA_16D3AE,
		description = "Evolui certas feras de Terra. Pesada e sólida.",
		icon = "rbxassetid://0",
		price = 500,
		sellPrice = 125,
		stackable = true,
		maxStack = 99,
	},
	evo_stone_air = {
		id = "evo_stone_air",
		name = "Pedra de Ar",
		type = Inv.ItemType.EvolutionStone,
		element = Text.AR_B623FF,
		description = "Evolui certas feras de Ar. Leve como uma brisa.",
		icon = "rbxassetid://0",
		price = 500,
		sellPrice = 125,
		stackable = true,
		maxStack = 99,
	},
	evo_stone_shadow = {
		id = "evo_stone_shadow",
		name = "Pedra de Sombra",
		type = Inv.ItemType.EvolutionStone,
		element = Text.SOMBRA_94B135,
		description = "Evolui certas feras de Sombra. Absorve a luz ao redor.",
		icon = "rbxassetid://0",
		price = 800,
		sellPrice = 200,
		stackable = true,
		maxStack = 99,
	},
	evo_stone_ice = {
		id = "evo_stone_ice",
		name = "Pedra de Gelo",
		type = Inv.ItemType.EvolutionStone,
		element = Text.GELO_4A90D9,
		description = "Evolui certas feras de Gelo. Fria ao toque.",
		icon = "rbxassetid://0",
		price = 800,
		sellPrice = 200,
		stackable = true,
		maxStack = 99,
	},
	evo_stone_electric = {
		id = "evo_stone_electric",
		name = "Pedra Elétrica",
		type = Inv.ItemType.EvolutionStone,
		element = Text.ELETRICO_FFD600,
		description = "Evolui certas feras Elétricas. Crepita com energia.",
		icon = "rbxassetid://0",
		price = 800,
		sellPrice = 200,
		stackable = true,
		maxStack = 99,
	},
	evo_stone_light = {
		id = "evo_stone_light",
		name = "Pedra de Luz",
		type = Inv.ItemType.EvolutionStone,
		element = Text.LUZ_FFF9C4,
		description = "Evolui certas feras de Luz. Irradia brilho suave.",
		icon = "rbxassetid://0",
		price = 800,
		sellPrice = 200,
		stackable = true,
		maxStack = 99,
	},
	evo_stone_metal = {
		id = "evo_stone_metal",
		name = "Pedra Metálica",
		type = Inv.ItemType.EvolutionStone,
		element = Text.METAL_B0BEC5,
		description = "Evolui certas feras Metálicas. Dura e reflexiva.",
		icon = "rbxassetid://0",
		price = 800,
		sellPrice = 200,
		stackable = true,
		maxStack = 99,
	},

	-- Itens Segurados (Held Items)
	held_power_band = {
		id = "held_power_band",
		name = "Bandana de Força",
		type = Inv.ItemType.HeldItem,
		description = "Aumenta o Ataque em 10% ao segurá-la.",
		icon = "rbxassetid://0",
		price = 1200,
		sellPrice = 300,
		stackable = false,
		effect = { stat = "atk", mult = 1.10 },
	},
	held_life_orb = {
		id = "held_life_orb",
		name = "Orbe da Vida",
		type = Inv.ItemType.HeldItem,
		description = "Aumenta HP em 15% ao segurá-lo.",
		icon = "rbxassetid://0",
		price = 1200,
		sellPrice = 300,
		stackable = false,
		effect = { stat = "hp", mult = 1.15 },
	},
	held_quick_claw = {
		id = "held_quick_claw",
		name = "Garra Rápida",
		type = Inv.ItemType.HeldItem,
		description = "20% de chance de atacar primeiro.",
		icon = "rbxassetid://0",
		price = 1500,
		sellPrice = 375,
		stackable = false,
		effect = { stat = "priority", chance = 0.20 },
	},
	held_focus_sash = {
		id = "held_focus_sash",
		name = "Bandana Foco",
		type = Inv.ItemType.HeldItem,
		description = "Se HP cheio, sobrevive a um golpe fatal com 1 HP.",
		icon = "rbxassetid://0",
		price = 2000,
		sellPrice = 500,
		stackable = false,
		effect = { stat = "survive", once = true },
	},
	held_elemental_gem = {
		id = "held_elemental_gem",
		name = "Gema Elemental",
		type = Inv.ItemType.HeldItem,
		description = "Primeiro golpe do tipo da gema tem 50% mais poder. Consumido ao usar.",
		icon = "rbxassetid://0",
		price = 800,
		sellPrice = 200,
		stackable = true,
		maxStack = 10,
		effect = { stat = "elemental_boost", mult = 1.5, consume = true },
	},
	held_lucky_egg = {
		id = "held_lucky_egg",
		name = "Ovo da Sorte",
		type = Inv.ItemType.HeldItem,
		description = "Dobra o XP ganho em batalhas.",
		icon = "rbxassetid://0",
		price = 3000,
		sellPrice = 750,
		stackable = false,
		effect = { stat = "xp_mult", mult = 2.0 },
	},
	held_wise_glasses = {
		id = "held_wise_glasses",
		name = "Óculos Sábios",
		type = Inv.ItemType.HeldItem,
		description = "Aumenta poder de movimentos especiais em 10%.",
		icon = "rbxassetid://0",
		price = 1200,
		sellPrice = 300,
		stackable = false,
		effect = { stat = "sp_atk", mult = 1.10 },
	},
	held_muscle_band = {
		id = "held_muscle_band",
		name = "Bandana Músculo",
		type = Inv.ItemType.HeldItem,
		description = "Aumenta poder de movimentos físicos em 10%.",
		icon = "rbxassetid://0",
		price = 1200,
		sellPrice = 300,
		stackable = false,
		effect = { stat = "phys_atk", mult = 1.10 },
	},
	held_leftovers = {
		id = "held_leftovers",
		name = "Restos",
		type = Inv.ItemType.HeldItem,
		description = "Recupera 1/16 do HP máximo por turno.",
		icon = "rbxassetid://0",
		price = 2500,
		sellPrice = 625,
		stackable = false,
		effect = { stat = "regen", fraction = 1/16 },
	},
	held_rocky_helmet = {
		id = "held_rocky_helmet",
		name = "Capacete Rochoso",
		type = Inv.ItemType.HeldItem,
		description = "Atacante físico recebe 1/8 do dano causado.",
		icon = "rbxassetid://0",
		price = 2000,
		sellPrice = 500,
		stackable = false,
		effect = { stat = "punish", fraction = 1/8 },
	},

	-- Consumíveis
	consumable_potion_small = {
		id = "consumable_potion_small",
		name = "Poção Pequena",
		type = Inv.ItemType.Consumable,
		description = "Restaura 50 HP.",
		icon = "rbxassetid://0",
		price = 100,
		sellPrice = 25,
		stackable = true,
		maxStack = 99,
		effect = { heal = 50 },
	},
	consumable_potion_medium = {
		id = "consumable_potion_medium",
		name = "Poção Média",
		type = Inv.ItemType.Consumable,
		description = "Restaura 150 HP.",
		icon = "rbxassetid://0",
		price = 300,
		sellPrice = 75,
		stackable = true,
		maxStack = 99,
		effect = { heal = 150 },
	},
	consumable_potion_large = {
		id = "consumable_potion_large",
		name = "Poção Grande",
		type = Inv.ItemType.Consumable,
		description = "Restaura 350 HP.",
		icon = "rbxassetid://0",
		price = 600,
		sellPrice = 150,
		stackable = true,
		maxStack = 99,
		effect = { heal = 350 },
	},
	consumable_ether_small = {
		id = "consumable_ether_small",
		name = "Éter Pequeno",
		type = Inv.ItemType.Consumable,
		description = "Restaura 10 PP de um movimento.",
		icon = "rbxassetid://0",
		price = 150,
		sellPrice = 37,
		stackable = true,
		maxStack = 99,
		effect = { restore_pp = 10 },
	},
	consumable_revive = {
		id = "consumable_revive",
		name = "Reviver",
		type = Inv.ItemType.Consumable,
		description = "Revive uma fera desmaiada com 50% HP.",
		icon = "rbxassetid://0",
		price = 1000,
		sellPrice = 250,
		stackable = true,
		maxStack = 99,
		effect = { revive = true, hp_fraction = 0.5 },
	},
	consumable_max_revive = {
		id = "consumable_max_revive",
		name = "Reviver Máximo",
		type = Inv.ItemType.Consumable,
		description = "Revive uma fera desmaiada com HP cheio.",
		icon = "rbxassetid://0",
		price = 2500,
		sellPrice = 625,
		stackable = true,
		maxStack = 99,
		effect = { revive = true, hp_fraction = 1.0 },
	},
	consumable_rare_candy = {
		id = "consumable_rare_candy",
		name = "Doce Raro",
		type = Inv.ItemType.Consumable,
		description = "Aumenta o nível de uma fera em 1.",
		icon = "rbxassetid://0",
		price = 5000,
		sellPrice = 1250,
		stackable = true,
		maxStack = 99,
		effect = { level_up = 1 },
	},
	consumable_exp_candy_s = {
		id = "consumable_exp_candy_s",
		name = "Doce Exp. P",
		type = Inv.ItemType.Consumable,
		description = "Dá 800 XP a uma fera.",
		icon = "rbxassetid://0",
		price = 200,
		sellPrice = 50,
		stackable = true,
		maxStack = 99,
		effect = { creature_xp = 800 },
	},
	consumable_exp_candy_m = {
		id = "consumable_exp_candy_m",
		name = "Doce Exp. M",
		type = Inv.ItemType.Consumable,
		description = "Dá 3000 XP a uma fera.",
		icon = "rbxassetid://0",
		price = 600,
		sellPrice = 150,
		stackable = true,
		maxStack = 99,
		effect = { creature_xp = 3000 },
	},
	consumable_exp_candy_l = {
		id = "consumable_exp_candy_l",
		name = "Doce Exp. G",
		type = Inv.ItemType.Consumable,
		description = "Dá 10000 XP a uma fera.",
		icon = "rbxassetid://0",
		price = 1800,
		sellPrice = 450,
		stackable = true,
		maxStack = 99,
		effect = { creature_xp = 10000 },
	},
	consumable_exp_candy_xl = {
		id = "consumable_exp_candy_xl",
		name = "Doce Exp. XG",
		type = Inv.ItemType.Consumable,
		description = "Dá 30000 XP a uma fera.",
		icon = "rbxassetid://0",
		price = 5000,
		sellPrice = 1250,
		stackable = true,
		maxStack = 99,
		effect = { creature_xp = 30000 },
	},

	-- Materiais (para crafting/upgrades)
	material_essence_fire = {
		id = "material_essence_fire",
		name = "Essência de Fogo",
		type = Inv.ItemType.Material,
		element = Text.FOGO_F77A3C,
		description = "Obtida de feras de Fogo. Usada em crafting.",
		icon = "rbxassetid://0",
		price = 50,
		sellPrice = 10,
		stackable = true,
		maxStack = 999,
	},
	material_essence_water = {
		id = "material_essence_water",
		name = "Essência de Água",
		type = Inv.ItemType.Material,
		element = Text.AGUA_F11A05,
		description = "Obtida de feras de Água. Usada em crafting.",
		icon = "rbxassetid://0",
		price = 50,
		sellPrice = 10,
		stackable = true,
		maxStack = 999,
	},
	material_essence_nature = {
		id = "material_essence_nature",
		name = "Essência de Natureza",
		type = Inv.ItemType.Material,
		element = Text.NATUREZA_FB1ED9,
		description = "Obtida de feras de Natureza. Usada em crafting.",
		icon = "rbxassetid://0",
		price = 50,
		sellPrice = 10,
		stackable = true,
		maxStack = 999,
	},
	material_essence_earth = {
		id = "material_essence_earth",
		name = "Essência de Terra",
		type = Inv.ItemType.Material,
		element = Text.TERRA_16D3AE,
		description = "Obtida de feras de Terra. Usada em crafting.",
		icon = "rbxassetid://0",
		price = 50,
		sellPrice = 10,
		stackable = true,
		maxStack = 999,
	},
	material_essence_air = {
		id = "material_essence_air",
		name = "Essência de Ar",
		type = Inv.ItemType.Material,
		element = Text.AR_B623FF,
		description = "Obtida de feras de Ar. Usada em crafting.",
		icon = "rbxassetid://0",
		price = 50,
		sellPrice = 10,
		stackable = true,
		maxStack = 999,
	},
	material_essence_shadow = {
		id = "material_essence_shadow",
		name = "Essência de Sombra",
		type = Inv.ItemType.Material,
		element = Text.SOMBRA_94B135,
		description = "Obtida de feras de Sombra. Rara e valiosa.",
		icon = "rbxassetid://0",
		price = 200,
		sellPrice = 50,
		stackable = true,
		maxStack = 999,
	},
	material_essence_ice = {
		id = "material_essence_ice",
		name = "Essência de Gelo",
		type = Inv.ItemType.Material,
		element = Text.GELO_4A90D9,
		description = "Obtida de feras de Gelo. Rara e valiosa.",
		icon = "rbxassetid://0",
		price = 200,
		sellPrice = 50,
		stackable = true,
		maxStack = 999,
	},
	material_essence_electric = {
		id = "material_essence_electric",
		name = "Essência Elétrica",
		type = Inv.ItemType.Material,
		element = Text.ELETRICO_FFD600,
		description = "Obtida de feras Elétricas. Rara e valiosa.",
		icon = "rbxassetid://0",
		price = 200,
		sellPrice = 50,
		stackable = true,
		maxStack = 999,
	},
	material_essence_light = {
		id = "material_essence_light",
		name = "Essência de Luz",
		type = Inv.ItemType.Material,
		element = Text.LUZ_FFF9C4,
		description = "Obtida de feras de Luz. Rara e valiosa.",
		icon = "rbxassetid://0",
		price = 200,
		sellPrice = 50,
		stackable = true,
		maxStack = 999,
	},
	material_essence_metal = {
		id = "material_essence_metal",
		name = "Essência Metálica",
		type = Inv.ItemType.Material,
		element = Text.METAL_B0BEC5,
		description = "Obtida de feras Metálicas. Rara e valiosa.",
		icon = "rbxassetid://0",
		price = 200,
		sellPrice = 50,
		stackable = true,
		maxStack = 999,
	},

	-- Selos (já existem em CaptureRules, mas aqui para loja)
	seal_basic = {
		id = "seal_basic",
		name = "Selo Básico",
		type = Inv.ItemType.Seal,
		description = "Taxa de captura padrão.",
		icon = "rbxassetid://0",
		price = 25,
		sellPrice = 5,
		stackable = true,
		maxStack = 999,
		sealKind = "Basic",
	},
	seal_reinforced = {
		id = "seal_reinforced",
		name = "Selo Reforçado",
		type = Inv.ItemType.Seal,
		description = "+12% taxa de captura. Req. Nv. 8.",
		icon = "rbxassetid://0",
		price = 60,
		sellPrice = 15,
		stackable = true,
		maxStack = 999,
		sealKind = "Reinforced",
		minLevel = 8,
	},
	seal_elemental = {
		id = "seal_elemental",
		name = "Selo Elemental",
		type = Inv.ItemType.Seal,
		description = "+25% taxa contra mesmo elemento. Req. Nv. 16.",
		icon = "rbxassetid://0",
		price = 85,
		sellPrice = 21,
		stackable = true,
		maxStack = 999,
		sealKind = Text.ELEMENTAL_5871BB,
		minLevel = 16,
	},
	seal_rare = {
		id = "seal_rare",
		name = "Selo Raro",
		type = Inv.ItemType.Seal,
		description = "+40% taxa contra raros/épicos. Req. Nv. 24.",
		icon = "rbxassetid://0",
		price = 160,
		sellPrice = 40,
		stackable = true,
		maxStack = 999,
		sealKind = "Rare",
		minLevel = 24,
	},
	seal_ancient = {
		id = "seal_ancient",
		name = "Selo Ancestral",
		type = Inv.ItemType.Seal,
		description = "+55% taxa com vínculo forte. Req. Nv. 40.",
		icon = "rbxassetid://0",
		price = 300,
		sellPrice = 75,
		stackable = true,
		maxStack = 999,
		sealKind = "Ancient",
		minLevel = 40,
	},

	-- Itens Chave (Key Items)
	key_phoenix_feather = {
		id = "key_phoenix_feather",
		name = "Pena da Fênix",
		type = Inv.ItemType.KeyItem,
		description = "Uma pena que brilha com fogo eterno. Necessária para o Santuário da Fênix.",
		icon = "rbxassetid://0",
		price = 0,
		sellPrice = 0,
		stackable = false,
	},
	key_ancient_tablet = {
		id = "key_ancient_tablet",
		name = "Tabuleta Antiga",
		type = Inv.ItemType.KeyItem,
		description = "Fragmento de uma tabuleta com inscrições esquecidas.",
		icon = "rbxassetid://0",
		price = 0,
		sellPrice = 0,
		stackable = true,
		maxStack = 10,
	},
	key_guardian_crest = {
		id = "key_guardian_crest",
		name = "Brasão do Guardião",
		type = Inv.ItemType.KeyItem,
		description = "Prova de vitória sobre um guardião de ilha.",
		icon = "rbxassetid://0",
		price = 0,
		sellPrice = 0,
		stackable = true,
		maxStack = 10,
	},
	key_celestial_shard = {
		id = "key_celestial_shard",
		name = "Estilhaço Celestial",
		type = Inv.ItemType.KeyItem,
		description = "Um fragmento de estrela caída. Poder antigo pulsa dentro.",
		icon = "rbxassetid://0",
		price = 0,
		sellPrice = 0,
		stackable = true,
		maxStack = 20,
	},
}

-- Mapeamento de pedra de evolução por elemento
Inv.EvolutionStoneByElement = {
	[Text.FOGO_F77A3C] = "evo_stone_fire",
	[Text.AGUA_F11A05] = "evo_stone_water",
	[Text.NATUREZA_FB1ED9] = "evo_stone_nature",
	[Text.TERRA_16D3AE] = "evo_stone_earth",
	[Text.AR_B623FF] = "evo_stone_air",
	[Text.SOMBRA_94B135] = "evo_stone_shadow",
	[Text.GELO_4A90D9] = "evo_stone_ice",
	[Text.ELETRICO_FFD600] = "evo_stone_electric",
	[Text.LUZ_FFF9C4] = "evo_stone_light",
	[Text.METAL_B0BEC5] = "evo_stone_metal",
}

-- Verifica se uma criatura pode evoluir com pedra
function Inv.canEvolveWithStone(creatureId: string, stoneId: string): boolean
	local species = C.ById[creatureId]
	local stone = Inv.Items[stoneId]
	if not species or not stone or stone.type ~= Inv.ItemType.EvolutionStone then
		return false
	end

	-- Verifica se a espécie evolui por pedra desse elemento
	local evoData = EvolutionItems.BySpecies[creatureId]
	if not evoData or evoData.method ~= "stone" then
		return false
	end

	return evoData.element == stone.element
end

-- Aplica evolução por pedra
function Inv.applyStoneEvolution(creature, stoneId: string): boolean
	if not Inv.canEvolveWithStone(creature.id, stoneId) then
		return false
	end

	local evoData = EvolutionItems.BySpecies[creature.id]
	local targetSpecies = C.ById[evoData.into]
	if not targetSpecies then
		return false
	end

	-- Evolui
	creature.id = evoData.into
	creature.evolved = true
	creature.evolutionMethod = "stone"
	creature.evolutionItem = stoneId

	return true
end

-- Adiciona item ao inventário
function Inv.addItem(profile, itemId: string, count: number?): boolean
	count = count or 1
	local item = Inv.Items[itemId]
	if not item then return false end

	profile.inventory = profile.inventory or {}

	if item.stackable then
		local current = profile.inventory[itemId] or 0
		local maxStack = item.maxStack or 99
		profile.inventory[itemId] = math.min(maxStack, current + count)
	else
		-- Itens não empilháveis: usa slots individuais
		profile.inventory[itemId] = (profile.inventory[itemId] or 0) + count
	end

	return true
end

-- Remove item do inventário
function Inv.removeItem(profile, itemId: string, count: number?): boolean
	count = count or 1
	local current = profile.inventory and profile.inventory[itemId] or 0
	if current < count then return false end

	profile.inventory[itemId] = current - count
	if profile.inventory[itemId] <= 0 then
		profile.inventory[itemId] = nil
	end
	return true
end

-- Verifica quantidade de item
function Inv.getCount(profile, itemId: string): number
	return profile.inventory and profile.inventory[itemId] or 0
end

-- Usa consumível em criatura
function Inv.useConsumable(profile, creatureUid: string, itemId: string): { success: boolean, message: string }
	local creature = profile.creatures and profile.creatures[creatureUid]
	if not creature then
		return { success = false, message = Text.CRIATURA_INVALIDA_3A9F3E }
	end

	if not Inv.removeItem(profile, itemId, 1) then
		return { success = false, message = "Item não encontrado" }
	end

	local item = Inv.Items[itemId]
	if not item or item.type ~= Inv.ItemType.Consumable then
		return { success = false, message = Text.ITEM_INVALIDO_96E69E }
	end

	local effect = item.effect

	if effect.heal then
		local maxHp = Progression.computeStats(creature).hp
		creature.currentHp = math.min(maxHp, (creature.currentHp or maxHp) + effect.heal)
		return { success = true, message = "Restaurado " .. effect.heal .. " HP!" }
	end

	if effect.revive then
		if (creature.currentHp or 0) > 0 then
			return { success = false, message = "A fera não está desmaiada" }
		end
		local maxHp = Progression.computeStats(creature).hp
		creature.currentHp = math.floor(maxHp * effect.hp_fraction)
		return { success = true, message = "A fera foi revivida!" }
	end

	if effect.restore_pp then
		-- Restaura PP do primeiro movimento com PP < max
		if creature.moves then
			for _, move in creature.moves do
				if (move.pp or 0) < (move.maxPp or 0) then
					move.pp = math.min(move.maxPp, move.pp + effect.restore_pp)
					return { success = true, message = "PP restaurado!" }
				end
			end
		end
		return { success = false, message = "Todos os movimentos têm PP cheio" }
	end

	if effect.level_up then
		if creature.lv >= Progression.MaxLevel then
			return { success = false, message = Text.NIVEL_MAXIMO_8078AA }
		end
		Progression.awardCreature(creature, Progression.creatureCost(creature.lv))
		return { success = true, message = "A fera subiu de nível!" }
	end

	if effect.creature_xp then
		Progression.awardCreature(creature, effect.creature_xp)
		return { success = true, message = "XP ganho: " .. effect.creature_xp }
	end

	return { success = false, message = "Efeito desconhecido" }
end

-- Equipa item segurado
function Inv.equipHeldItem(profile, creatureUid: string, itemId: string): { success: boolean, message: string }
	local creature = profile.creatures and profile.creatures[creatureUid]
	if not creature then
		return { success = false, message = Text.CRIATURA_INVALIDA_3A9F3E }
	end

	local item = Inv.Items[itemId]
	if not item or item.type ~= Inv.ItemType.HeldItem then
		return { success = false, message = "Não é um item segurável" }
	end

	-- Remove item do inventário (se não stackable)
	if not item.stackable then
		if not Inv.removeItem(profile, itemId, 1) then
			return { success = false, message = "Item não encontrado" }
		end
	end

	-- Devolve item antigo se houver
	if creature.heldItem then
		Inv.addItem(profile, creature.heldItem, 1)
	end

	creature.heldItem = itemId
	return { success = true, message = "Equipado: " .. item.name }
end

-- Remove item segurado
function Inv.unequipHeldItem(profile, creatureUid: string): { success: boolean, message: string }
	local creature = profile.creatures and profile.creatures[creatureUid]
	if not creature then
		return { success = false, message = Text.CRIATURA_INVALIDA_3A9F3E }
	end

	if not creature.heldItem then
		return { success = false, message = "Nenhum item equipado" }
	end

	local itemId = creature.heldItem
	Inv.addItem(profile, itemId, 1)
	creature.heldItem = nil

	return { success = true, message = "Item removido e devolvido ao inventário" }
end

-- Calcula stats com item segurado
function Inv.computeStatsWithHeldItem(creature)
	local baseStats = Progression.computeStats(creature)
	if not creature.heldItem then
		return baseStats
	end

	local item = Inv.Items[creature.heldItem]
	if not item or not item.effect then
		return baseStats
	end

	local stats = { hp = baseStats.hp, atk = baseStats.atk, gpm = baseStats.gpm }
	local effect = item.effect

	if effect.stat == "atk" and effect.mult then
		stats.atk = math.floor(stats.atk * effect.mult)
	elseif effect.stat == "hp" and effect.mult then
		stats.hp = math.floor(stats.hp * effect.mult)
	elseif effect.stat == "sp_atk" and effect.mult then
		-- Para movimentos especiais (seria usado no combat)
		stats.spAtkMult = effect.mult
	elseif effect.stat == "phys_atk" and effect.mult then
		stats.physAtkMult = effect.mult
	elseif effect.stat == "xp_mult" and effect.mult then
		stats.xpMult = effect.mult
	end

	return stats
end

-- Vende item
function Inv.sellItem(profile, itemId: string, count: number?): { success: boolean, gold: number, message: string }
	count = count or 1
	local item = Inv.Items[itemId]
	if not item then
		return { success = false, gold = 0, message = Text.ITEM_INVALIDO_96E69E }
	end

	if item.sellPrice <= 0 then
		return { success = false, gold = 0, message = "Este item não pode ser vendido" }
	end

	if not Inv.removeItem(profile, itemId, count) then
		return { success = false, gold = 0, message = "Quantidade insuficiente" }
	end

	local gold = item.sellPrice * count
	profile.gold = math.min(1e12, (profile.gold or 0) + gold)

	return { success = true, gold = gold, message = "Vendido por " .. gold .. " ouro" }
end

-- Compra item
function Inv.buyItem(profile, itemId: string, count: number?): { success: boolean, message: string }
	count = count or 1
	local item = Inv.Items[itemId]
	if not item then
		return { success = false, message = Text.ITEM_INVALIDO_96E69E }
	end

	-- Verifica nível mínimo para selos
	if item.minLevel and (profile.playerLevel or 1) < item.minLevel then
		return { success = false, message = "Nível insuficiente (req. " .. item.minLevel .. ")" }
	end

	local totalCost = item.price * count
	if (profile.gold or 0) < totalCost then
		return { success = false, message = Text.OURO_INSUFICIENTE_AF56CF .. totalCost .. ")" }
	end

	profile.gold -= totalCost
	Inv.addItem(profile, itemId, count)

	return { success = true, message = "Comprado: " .. item.name .. " x" .. count }
end

-- Obtém lista de itens para loja (filtrada por categoria)
function Inv.getShopItems(category: string?)
	local result = {}
	for id, item in Inv.Items do
		if not category or item.type == category then
			table.insert(result, { id = id, item = item })
		end
	end
	return result
end

return Inv