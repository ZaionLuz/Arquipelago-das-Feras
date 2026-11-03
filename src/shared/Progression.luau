--!strict
local P={MaxLevel=100}
function P.playerCost(level:number):number return 50+level*25 end
function P.creatureCost(level:number):number return 35+level*15 end
function P.award(data:any,amount:number)
 data.playerXp=math.min(1e9,(data.playerXp or 0)+math.max(0,math.floor(amount)))
 data.playerLevel=data.playerLevel or 1
 while data.playerLevel<P.MaxLevel and data.playerXp>=P.playerCost(data.playerLevel) do
  data.playerXp-=P.playerCost(data.playerLevel);data.playerLevel+=1
 end
end
function P.awardCreature(creature:any,amount:number)
 creature.xp=math.min(1e9,(creature.xp or 0)+math.max(0,math.floor(amount)))
 while creature.lv<P.MaxLevel and creature.xp>=P.creatureCost(creature.lv) do
  creature.xp-=P.creatureCost(creature.lv);creature.lv+=1
 end
end
return P
