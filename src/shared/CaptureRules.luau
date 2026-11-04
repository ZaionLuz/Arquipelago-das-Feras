--!nonstrict
local Text = require(script.Parent.Strings).Text
local R = { SealPrice = 25, InitialSeals = 5, MaxPerIsland = 2, RespawnSeconds = 25, MaxDistance = 13 }
R.Seals = {
	Basic = { name = Text.BASICO_303CE5, multiplier = 1, cost = 25, level = 1 },
	Reinforced = { name = Text.REFORCADO_A930AC, multiplier = 1.12, cost = 60, level = 8 },
	Elemental = {
		name = Text.ELEMENTAL_5871BB,
		multiplier = 1.25,
		cost = 85,
		level = 16,
		material = Text.NATUREZA_FB1ED9,
		amount = 1,
	},
	Rare = {
		name = Text.RARO_851816,
		multiplier = 1.4,
		cost = 160,
		level = 24,
		material = Text.TERRA_16D3AE,
		amount = 1,
	},
	Ancient = {
		name = Text.ANCESTRAL_24E41A,
		multiplier = 1.55,
		cost = 300,
		level = 40,
		material = Text.SOMBRA_94B135,
		amount = 2,
	},
}
R.SealOrder = { "Basic", "Reinforced", Text.ELEMENTAL_5871BB, "Rare", "Ancient" }
function R.multiplier(kind, rarity, activeElement, foeElement, bond)
	if kind == Text.ELEMENTAL_5871BB then
		return activeElement == foeElement and 1.35 or 1.1
	end
	if kind == "Rare" then
		return rarity >= 3 and 1.4 or 1.15
	end
	if kind == "Ancient" then
		return bond >= 2 and 1.55 or 1.4
	end
	return (R.Seals[kind] or R.Seals.Basic).multiplier
end
local base = { 0.8, 0.5, 0.28, 0.12 }
function R.chance(rarity, level)
	return math.clamp((base[rarity] or 0.1) - math.max(0, level - 1) * 0.005, 0.05, 0.9)
end
-- Hábitos e peso compartilhados para inspeção; somente servidor sorteia.
function R.species(def)
	return {
		island = def.island,
		weight = 1 / (def.rar * def.rar),
		behavior = def.shape == "Bird" and "voador" or def.shape == "Serpent" and "reservado" or "curioso",
		max = def.rar == 4 and 1 or 2,
	}
end
return R
