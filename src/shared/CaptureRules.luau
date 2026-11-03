--!nonstrict
local R={SealPrice=25,InitialSeals=5,MaxPerIsland=2,RespawnSeconds=25,MaxDistance=13}
R.Seals={
 Basic={name="Básico",multiplier=1,cost=25,level=1},
 Reinforced={name="Reforçado",multiplier=1.12,cost=60,level=8},
 Elemental={name="Elemental",multiplier=1.25,cost=85,level=16,material="Natureza",amount=1},
 Rare={name="Raro",multiplier=1.4,cost=160,level=24,material="Terra",amount=1},
 Ancient={name="Ancestral",multiplier=1.55,cost=300,level=40,material="Sombra",amount=2},
}
R.SealOrder={"Basic","Reinforced","Elemental","Rare","Ancient"}
function R.multiplier(kind,rarity,activeElement,foeElement,bond)
 if kind=="Elemental" then return activeElement==foeElement and 1.35 or 1.1 end
 if kind=="Rare" then return rarity>=3 and 1.4 or 1.15 end
 if kind=="Ancient" then return bond>=2 and 1.55 or 1.4 end
 return (R.Seals[kind] or R.Seals.Basic).multiplier
end
local base={.8,.5,.28,.12}
function R.chance(rarity,level)
 return math.clamp((base[rarity] or .1)-math.max(0,level-1)*.005,.05,.9)
end
-- Hábitos e peso compartilhados para inspeção; somente servidor sorteia.
function R.species(def)
 return {island=def.island,weight=1/(def.rar*def.rar),behavior=def.shape=="Bird" and "voador" or def.shape=="Serpent" and "reservado" or "curioso",max=def.rar==4 and 1 or 2}
end
return R
