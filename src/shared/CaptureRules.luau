--!nonstrict
local R={SealPrice=25,InitialSeals=5,MaxPerIsland=2,RespawnSeconds=25,MaxDistance=13}
local base={.8,.5,.28,.12}
function R.chance(rarity,level)
 return math.clamp((base[rarity] or .1)-math.max(0,level-1)*.005,.05,.9)
end
-- Hábitos e peso compartilhados para inspeção; somente servidor sorteia.
function R.species(def)
 return {island=def.island,weight=1/(def.rar*def.rar),behavior=def.shape=="Bird" and "voador" or def.shape=="Serpent" and "reservado" or "curioso",max=def.rar==4 and 1 or 2}
end
return R
