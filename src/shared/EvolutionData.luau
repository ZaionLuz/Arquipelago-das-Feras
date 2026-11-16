--!strict
-- Marcos reais do jogo. Métodos adicionais do DESIGN.md ainda não são habilitados.
local C = require(script.Parent.Creatures)
local E = { Levels = {1, 7, 15}, MaxStage = 3, Methods = { Level = true } }
function E.forSpecies(id: string)
 local def = C.ById[id]
 if not def then return nil end
 return {minStage = def.minStage or 1, maxStage = E.MaxStage, levels = E.Levels, method = "Level"}
end
return E
