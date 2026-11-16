--!nonstrict
local C = require(script.Parent.Creatures)
local E = require(script.Parent.EvolutionData)
local S = {}
function S.info(creature)
 if typeof(creature) ~= "table" or not C.ById[creature.id] or typeof(creature.lv) ~= "number"
  or creature.lv ~= creature.lv or creature.lv < 1 or creature.lv > 100 or creature.lv % 1 ~= 0 then return nil end
 local rules = E.forSpecies(creature.id)
 local stage = C.stage(creature.lv, creature.id)
 return {species = creature.id, level = creature.lv, stage = stage, maxStage = rules.maxStage,
  nextLevel = stage < rules.maxStage and rules.levels[stage + 1] or nil, method = "Level",
  automatic = true, ascensionEnabled = false}
end
return S
