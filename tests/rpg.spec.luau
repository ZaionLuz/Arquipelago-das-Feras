local player={playerLevel=1,playerXp=0}
P.award(player,P.playerCost(1));assert(player.playerLevel==2 and player.playerXp==0)
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
d.storyClaimed.arrival=true;d.stats.feed=3;assert(not Story.canClaim(d,"care"));d.stats.regionVisit=2;assert(Story.canClaim(d,"care"))
for _,id in Capture.SealOrder do
 local seal=Capture.Seals[id];assert(seal.cost>0 and seal.multiplier>=1 and seal.level>=1)
end
print("PASS: progressão até 100, 9 posições únicas, sobreposição, validação, capacidade, capítulos e cinco receitas")

assert(Capture.multiplier("Elemental",2,"Fogo","Fogo",0)>Capture.multiplier("Elemental",2,"Água","Fogo",0))
assert(Capture.multiplier("Rare",3,nil,"Fogo",0)>Capture.multiplier("Rare",1,nil,"Fogo",0))
assert(Capture.multiplier("Ancient",4,nil,"Fogo",3)>Capture.multiplier("Ancient",4,nil,"Fogo",0))
print("PASS: efeito de selo elemental, raro e ancestral depende das condições do encontro")
