--!nonstrict
local Seals = require(script.Parent.CaptureRules)
local C = require(script.Parent.Creatures)
local M = {}
function M.chance(state)
	if state.capturable == false then
		return 0
	end
	local foe = state.foe
	local def = C.ById[foe.id]
	local pet = state.active and state.party[state.active]
	local seal = Seals.multiplier(state.sealKind or "Basic", def.rar, pet and pet.el, foe.el, state.bond)
	local health = math.clamp(foe.hp / foe.maxHp, 0, 1)
	if state.isLegendary then
		-- Um selo de categoria superior nunca perde para um inferior neste encontro especial.
		for _, kind in Seals.SealOrder do
			seal = math.max(seal, Seals.multiplier(kind, def.rar, pet and pet.el, foe.el, state.bond))
			if kind == (state.sealKind or "Basic") then
				break
			end
		end
		-- 4% sem preparo, ~10% médio, ~21% ótimo; fórmula multiplicativa.
		return math.clamp(
			(state.captureBase or 0.04) * seal * (1 + 1.8 * (1 - health)) * (1 + state.bond * 0.09),
			0.01,
			0.35
		)
	end
	return math.clamp(Seals.chance(def.rar, foe.lv) * seal + (1 - health) * 0.45 + state.bond * 0.08, 0.05, 0.94)
end
return M
