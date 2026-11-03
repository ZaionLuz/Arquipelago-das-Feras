local P=(function()
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

end)()
local SR=(function()
--!nonstrict
local R={MaxLevel=3,Slots=9,BuildBase=120}
function R.slot(index)
 if typeof(index)~="number" or index%1~=0 or index<1 or index>9 then return nil end
 return ((index-1)%3-1)*36,(math.floor((index-1)/3)-1)*36
end
function R.available(structures,slot,ignore)
 if not R.slot(slot) then return false end
 for id,entry in structures do if id~=ignore and entry.slot==slot then return false end end
 return true
end
function R.capacity(def,entry) return def.slots+((entry and entry.level or 1)-1)*2 end
function R.buildCost(def) return R.BuildBase*def.idx end
function R.upgradeCost(entry) return 180*entry.level end
function R.validate(raw,unlocked,islands)
 local out={};local occupied={}
 if typeof(raw)=="table" then
  for _,def in islands do local entry=raw[def.id]
   if unlocked[def.id] and typeof(entry)=="table" and R.slot(entry.slot) and not occupied[entry.slot] then
    local level=typeof(entry.level)=="number" and entry.level==entry.level and math.clamp(math.floor(entry.level),1,3) or 1
    out[def.id]={slot=entry.slot,level=level};occupied[entry.slot]=true
   end
  end
 end
 return out
end
return R

end)()
local Story=(function()
--!nonstrict
local S={List={
 {id="arrival",name="O primeiro vínculo",text="Capture uma fera selvagem e apresente sua descoberta à pesquisadora Maia.",stat="capture",goal=1,gold=75,xp=90,seals=2},
 {id="care",name="Um lar para suas feras",text="Alimente suas feras três vezes.",stat="feed",goal=3,gold=100,xp=100,seals=1},
 {id="explore",name="Vestígios da civilização",text="Encontre um marco de exploração e recolha sua essência.",stat="explore",goal=1,gold=100,xp=100,seals=1},
 {id="birth",name="A próxima geração",text="Choque um ovo no seu santuário.",stat="hatch",goal=1,gold=150,xp=120,seals=2},
 {id="challenge",name="Explorador preparado",text="Vença uma batalha contra uma fera selvagem.",stat="win",goal=1,gold=200,xp=160,seals=2},
 {id="home",name="Santuário em crescimento",text="Melhore um dos seus habitats.",stat="habitatUpgrade",goal=1,gold=200,xp=200,seals=3},
 {id="guardian",name="O primeiro guardião",text="Derrote um guardião de ilha para concluir sua primeira expedição.",stat="guardian",goal=1,gold=300,xp=300,seals=4},
}}
S.ById={};for _,q in S.List do S.ById[q.id]=q end
function S.current(d)
 for _,q in S.List do if not d.storyClaimed[q.id] then return q end end
 return nil
end
function S.progress(d,q) return math.min(q.goal,d.stats[q.stat] or 0) end
function S.canClaim(d,id)
 local q=S.current(d);return q and q.id==id and S.progress(d,q)>=q.goal
end
return S

end)()
local Capture=(function()
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

end)()
local player={playerLevel=1,playerXp=0}
P.award(player,75);assert(player.playerLevel==2 and player.playerXp==0)
P.award(player,1e9);assert(player.playerLevel==100)
local cr={lv=20,xp=0};P.awardCreature(cr,1e9);assert(cr.lv==100)
local occupied={};local seen={}
for slot=1,9 do
 local x,z=SR.slot(slot);assert(x and z);assert(not seen[x..":"..z]);seen[x..":"..z]=true
 assert(SR.available(occupied,slot));occupied["h"..slot]={slot=slot,level=1};assert(not SR.available(occupied,slot))
end
for _,bad in {0,10,-1,1.5,math.huge,0/0,"1",{}} do assert(not SR.slot(bad)) end
assert(SR.available(occupied,1,"h1"))
assert(SR.capacity({slots=4},{level=3})==8)
local d={storyClaimed={},stats={capture=1}}
assert(Story.canClaim(d,"arrival"));assert(not Story.canClaim(d,"care"))
d.storyClaimed.arrival=true;d.stats.feed=3;assert(Story.canClaim(d,"care"))
for _,id in Capture.SealOrder do
 local seal=Capture.Seals[id];assert(seal.cost>0 and seal.multiplier>=1 and seal.level>=1)
end
print("PASS: progressão até 100, 9 posições únicas, sobreposição, validação, capacidade, capítulos e cinco receitas")

assert(Capture.multiplier("Elemental",2,"Fogo","Fogo",0)>Capture.multiplier("Elemental",2,"Água","Fogo",0))
assert(Capture.multiplier("Rare",3,nil,"Fogo",0)>Capture.multiplier("Rare",1,nil,"Fogo",0))
assert(Capture.multiplier("Ancient",4,nil,"Fogo",3)>Capture.multiplier("Ancient",4,nil,"Fogo",0))
print("PASS: efeito de selo elemental, raro e ancestral depende das condições do encontro")
