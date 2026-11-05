--!nonstrict
local C = require(script.Parent.Creatures)
local Species = require(script.Parent.SpeciesRules)
local Bands = require(script.Parent.LevelBands)
local P = {}
local function weight(def)
	local multiplier = def.encounterWeight or 1
	if typeof(multiplier) ~= "number" or multiplier ~= multiplier or multiplier <= 0 or multiplier == math.huge then
		return 0
	end
	return multiplier / def.rar ^ 2
end
function P.list(region, commercial)
	local pool = {}
	for _, def in C.List do
		if
			Species.isGeneral(def.id)
			and (def.island == region or (region == "Alvorecer" and table.find(
				{ "brotinho", "folhuco", "penugem" },
				def.id
			)))
			and (not commercial or def.rar <= 3)
		then
			table.insert(pool, def)
		end
	end
	return pool
end
function P.pick(region, rng, commercial, counts)
	local pool = P.list(region, commercial)
	local total, last = 0, nil
	for _, d in pool do
		local value = weight(d)
		if value > 0 and (not counts or (counts[d.id] or 0) < (d.rar == 4 and 1 or 2)) then
			total += value
			last = d
		end
	end
	if total == 0 then
		return nil
	end
	local roll = rng:NextNumber() * total
	for _, d in pool do
		local value = weight(d)
		if value > 0 and (not counts or (counts[d.id] or 0) < (d.rar == 4 and 1 or 2)) then
			roll -= value
			if roll <= 0 then
				return d
			end
		end
	end
	-- O limite superior e o arredondamento só podem escolher o último candidato elegível.
	return last
end
function P.rollLevel(region, rarity, rng)
	local band = Bands.ById[region]
	if not band then
		return nil
	end
	local a, b = rng:NextNumber(), rng:NextNumber()
	local t = rarity == 1 and math.min(a, b) or rarity == 2 and (a + b) / 2 or math.max(a, b)
	local extra = rarity == 4 and 3 or rarity == 3 and 2 or 0
	return math.clamp(math.floor(band.min + t * (band.max + extra - band.min + 1)), band.min, band.max + extra)
end
return P
