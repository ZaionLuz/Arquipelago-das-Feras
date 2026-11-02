-- Executado pelo harness sem serviços Roblox.
local low={NextNumber=function() return 0 end}
local high={NextNumber=function() return .999 end}
local function pet(uid,id,lv) return {uid=uid,id=id or "cinzelo",lv=lv or 1} end
local s=R.new("bolhinho",1)
assert(not R.step(s,"Strike",nil,low,5,true));assert(s.turn==0 and s.version==0)
assert(not R.step(s,"Select",{uid="x",id="bad",lv=1},low,5,true))
assert(not R.step(s,"Capture",nil,low,0,true));assert(s.turn==0)
assert(not R.step(s,"Capture",nil,low,5,false));assert(s.turn==0)
assert(R.step(s,"Capture",nil,low,1,true));assert(s.status=="captured" and s.spentSeal)
assert(not R.step(s,"Capture",nil,low,1,true));assert(s.attempts==1)
s=R.new("fenix",15)
assert(R.step(s,"Select",pet("u1","magmarau",20),low,5,true))
local initial=R.chance(s);s.foe.hp=math.ceil(s.foe.maxHp*.25);s.bond=3;assert(R.chance(s)>initial and R.chance(s)<=.94)
s=R.new("bolhinho",1);R.step(s,"Select",pet("u1","cinzelo",20),low,5,true)
s.foe.hp=1
R.step(s,"Strike",nil,low,5,true);assert(s.status=="won" and s.foe.hp==0)
assert(not R.step(s,"Capture",nil,low,5,true))
s=R.new("fenix",15);R.step(s,"Select",pet("u1","cinzelo",20),low,5,true)
R.step(s,"Select",pet("u2","bolhinho",20),low,5,true);R.step(s,"Select",pet("u3","magmarau",20),low,5,true)
assert(not R.step(s,"Select",pet("u4","magmarau",20),low,5,true))
local unit=s.party.u3;unit.hp=0;assert(not R.step(s,"Strike",nil,low,5,true))
assert(not R.step(s,"Select",pet("u3","magmarau",20),low,5,true))
s=R.new("fenix",15);R.step(s,"Select",pet("u1","magmarau",20),low,5,true)
assert(R.step(s,"Skill",nil,low,5,true));assert(not R.step(s,"Skill",nil,low,5,true))
assert(R.step(s,"Flee",nil,low,5,true));assert(s.status=="escaped")
for _,a in C.List do for _,b in C.List do
 local aa,bb=R.stats(a.id,10),R.stats(b.id,10)
 assert(R.damage(aa,bb,1,false)>=1)
 assert(R.damage(aa,bb,1,true)<=R.damage(aa,bb,1,false))
end end
local seed=19;local rng={}
function rng:NextNumber() seed=seed*48271%2147483647;return seed/2147483647 end
local simulations=0
for _,def in C.List do
 for _,choice in {"Strike","Skill","Capture","Bond","Guard"} do
  s=R.new(def.id,10);R.step(s,"Select",pet("u1","magmarau",20),rng,100,true)
  for i=1,40 do
   if s.status~="active" then break end
   local selected=choice=="Skill" and i%3~=1 and "Guard" or choice
   local ok=R.step(s,selected,nil,rng,100,true)
   if not ok then R.step(s,"Bond",nil,rng,100,true) end
   assert(s.foe.hp>=0 and s.foe.hp<=s.foe.maxHp)
   for _,cr in s.party do assert(cr.hp>=0 and cr.hp<=cr.maxHp) end
   assert(R.chance(s)>=.05 and R.chance(s)<=.94)
  end
  assert(s.status~="active","Encontro não termina no limite")
  simulations+=1
 end
end
print("PASS: combate/captura; 900 pares de dano; "..simulations.." encontros; inválidos sem mutação; cooldown, fim, equipe, selos e limites")
