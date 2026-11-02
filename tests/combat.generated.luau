local Color3={fromRGB=function(...) return {} end}
local C=(function()
--!nonstrict
-- Catálogo de feras. Para criar uma nova, basta uma linha add(...). Estatísticas derivam da raridade.
local C={List={},ById={},Rarity={"Comum","Raro","Épico","Lendário"}}
local function add(id,name,el,rar,island,shape,hybrid)
	local d={id=id,name=name,el=el,rar=rar,island=island,shape=shape,hybrid=hybrid,hp=30+rar*25,atk=6+rar*5,gpm=rar*rar*2+2}
	table.insert(C.List,d);C.ById[id]=d
end
add("cinzelo","Cinzelo","Fogo",1,"Brasa","Blob")
add("magmarau","Magmarau","Fogo",2,"Brasa","Beast")
add("fenixfuligem","Fênix Fuligem","Fogo",3,"Brasa","Bird")
add("vulcanodrago","Vulcanodrago","Fogo",4,"Brasa","Dragon")
add("bolhinho","Bolhinho","Água",1,"Recife","Blob")
add("marilisco","Marilisco","Água",2,"Recife","Serpent")
add("carangueperola","Caranguepérola","Água",3,"Recife","Insect")
add("abissauro","Abissauro","Água",4,"Recife","Dragon")
add("brotinho","Brotinho","Natureza",1,"Floresta","Blob")
add("folhuco","Folhuço","Natureza",2,"Floresta","Beast")
add("aracnoflora","Aracnoflora","Natureza",3,"Floresta","Insect")
add("ancestravore","Ancestrávore","Natureza",4,"Floresta","Beast")
add("graozinho","Grãozinho","Terra",1,"Dunas","Blob")
add("escorpiodra","Escorpiodra","Terra",2,"Dunas","Insect")
add("esfingeolito","Esfingeolito","Terra",3,"Dunas","Beast")
add("colossodune","Colossodune","Terra",4,"Dunas","Dragon")
add("penugem","Penugem","Ar",1,"Picos","Bird")
add("ventanil","Ventanil","Ar",2,"Picos","Bird")
add("trovoraptor","Trovoraptor","Ar",3,"Picos","Dragon")
add("aeronimbo","Aeronimbo","Ar",4,"Picos","Serpent")
add("lodinho","Lodinho","Sombra",1,"Pantano","Blob")
add("caudalume","Caudalume","Sombra",2,"Pantano","Serpent")
add("vagalumorte","Vagalumorte","Sombra",3,"Pantano","Insect")
add("reinevoento","Rei Nevoento","Sombra",4,"Pantano","Beast")
-- Híbridos: só nascem de cruzamentos entre dois elementos específicos.
add("vaporino","Vaporino","Fogo",3,"Híbrido","Serpent",{"Fogo","Água"})
add("magmaterra","Magmaterra","Fogo",3,"Híbrido","Beast",{"Fogo","Terra"})
add("tempestalia","Tempestália","Ar",3,"Híbrido","Bird",{"Ar","Água"})
add("nevoamusgo","Névoamusgo","Sombra",3,"Híbrido","Beast",{"Sombra","Natureza"})
add("cinzavento","Cinzavento","Fogo",4,"Híbrido","Dragon",{"Fogo","Ar"})
-- Fênix é uma espécie adicional; Fênix Fuligem e seus IDs permanecem intactos.
add("fenix","Fênix","Fogo",4,"Brasa","Bird")
C.ById.fenix.minStage=3
C.ById.fenix.futureStage={target=4,enabled=false,mechanic="Renascimento (futuro)"}
function C.stage(lv,id)
 local normal=lv>=15 and 3 or lv>=7 and 2 or 1
 return math.max(normal,(id and C.ById[id] and C.ById[id].minStage) or 1)
end
return C

end)()
local Capture=(function()
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

end)()
local Skills=(function()
--!strict
return {
 Blob={name="Pulso vital",power=1.1,effect="heal"},
 Beast={name="Investida feroz",power=1.65,effect="none"},
 Bird={name="Rajada evasiva",power=1.25,effect="evade"},
 Dragon={name="Sopro ancestral",power=1.7,effect="none"},
 Serpent={name="Maré debilitante",power=1.15,effect="weaken"},
 Insect={name="Trama aderente",power=1.15,effect="slow"},
}

end)()
local Elements=(function()
--!nonstrict
-- Seis elementos. Strong[atacante] = alvos que sofrem dano dobrado.
local E={List={"Fogo","Água","Natureza","Terra","Ar","Sombra"}}
E.Strong={Fogo={"Natureza"},["Água"]={"Fogo","Terra"},Natureza={"Água","Terra"},Terra={"Fogo","Ar"},Ar={"Natureza"},Sombra={"Ar","Água"}}
E.Color={Fogo=Color3.fromRGB(255,110,50),["Água"]=Color3.fromRGB(70,160,255),Natureza=Color3.fromRGB(110,210,80),Terra=Color3.fromRGB(190,140,80),Ar=Color3.fromRGB(200,230,255),Sombra=Color3.fromRGB(140,80,200)}
function E.mult(att,def)
	if table.find(E.Strong[att] or {},def) then return 2 end
	if table.find(E.Strong[def] or {},att) then return 0.5 end
	return 1
end
return E

end)()
local R=(function()
--!nonstrict
-- Regras puras: sem serviços, instâncias, relógio ou recursos informados pelo cliente.
local C=C
local Elements=Elements
local Skills=Skills
local Capture=Capture
local R={MaxTurns=30,MaxParty=3}
function R.stats(id,lv)
 local def=assert(C.ById[id]);local scale=1+.15*(lv-1)
 return {id=id,lv=lv,maxHp=math.floor(def.hp*scale),atk=math.floor(def.atk*scale),def=4+def.rar*3+lv,speed=({Blob=9,Beast=15,Bird=20,Dragon=13,Serpent=16,Insect=18})[def.shape]+lv,el=def.el}
end
function R.damage(a,b,power,guard)
 return math.max(1,math.floor(a.atk*power*Elements.mult(a.el,b.el)*100/(100+b.def)*(guard and .45 or 1)))
end
function R.chance(s)
 local def=C.ById[s.foe.id]
 return math.clamp(Capture.chance(def.rar,s.foe.lv)+(1-s.foe.hp/s.foe.maxHp)*.45+s.bond*.08,.05,.94)
end
function R.new(id,lv)
 local foe=R.stats(id,lv);foe.hp=foe.maxHp
 return {foe=foe,party={},active=nil,bond=0,turn=0,version=0,status="active",log={},attempts=0}
end
local function note(s,text,kind) table.insert(s.log,{text=text,kind=kind or "info"}) end
local function reply(s,guard)
 local pet=s.active and s.party[s.active]
 if not pet or pet.hp<=0 then return end
 local amount=R.damage(s.foe,pet,s.turn%3==0 and 1.35 or 1,guard)
 if pet.evade then amount=math.max(1,math.floor(amount*.65));pet.evade=false end
 pet.hp=math.max(0,pet.hp-amount);note(s,"A fera causou "..amount.." de dano.","foe")
 if pet.hp==0 then note(s,"Seu companheiro está exausto. Troque de fera ou fuja.","faint") end
end
-- Retorna false sem modificar estado para decisões inválidas.
function R.step(s,action,pet,rng,seals,room)
 if s.status~="active" then return false,"Este encontro terminou." end
 if s.turn>=R.MaxTurns then s.status="escaped";return true end
 local current=s.active and s.party[s.active]
 if action=="Select" then
  if not pet or not C.ById[pet.id] or not pet.uid then return false,"Escolha uma fera sua." end
  if pet.uid==s.active then return false,"Essa fera já está em campo." end
  local n=0;for _ in s.party do n+=1 end
  if not s.party[pet.uid] and n>=R.MaxParty then return false,"Equipe limitada a três feras por encontro." end
  if s.party[pet.uid] and s.party[pet.uid].hp<=0 then return false,"Essa fera está exausta." end
 elseif action=="Strike" or action=="Skill" or action=="Guard" then
  if not current or current.hp<=0 then return false,"Selecione uma fera disponível." end
  if action=="Skill" and s.turn<(current.nextSkill or 0) then return false,"Habilidade recarregando." end
 elseif action=="Capture" then
  if seals<1 then return false,"Sem selos. Crie mais no Mercado." end
  if not room then return false,"Inventário cheio. Nenhum selo foi gasto." end
 elseif action~="Bond" and action~="Flee" then return false,"Ação desconhecida." end
 s.log={};s.turn+=1;s.version+=1;s.spentSeal=false
 if action=="Flee" then s.status="escaped";note(s,"Você voltou à exploração.");return true end
 if action=="Select" then
  local switching=s.active~=nil
  if not s.party[pet.uid] then local unit=R.stats(pet.id,pet.lv);unit.hp=unit.maxHp;unit.nextSkill=0;s.party[pet.uid]=unit end
  s.active=pet.uid;note(s,C.ById[pet.id].name.." entrou em campo.")
  if switching then reply(s,false) end
 elseif action=="Capture" then
  s.spentSeal=true;s.attempts+=1
  if rng:NextNumber()<R.chance(s) then s.status="captured";note(s,"Vínculo estabelecido!","capture")
  else
   note(s,"O selo se desfez. A fera resistiu!","miss")
   if current and current.hp>0 then reply(s,false)
   elseif rng:NextNumber()<.3 or s.attempts>=6 then s.status="escaped";note(s,"A fera fugiu.") end
  end
 elseif action=="Bond" then
  s.bond=math.min(3,s.bond+1);note(s,"Você se aproximou com cuidado. Vínculo "..s.bond.."/3.","bond")
  if current and current.hp>0 then reply(s,false)
  elseif rng:NextNumber()<.15 then s.status="escaped";note(s,"A fera se assustou e fugiu.") end
 elseif action=="Guard" then
  current.hp=math.min(current.maxHp,current.hp+math.floor(current.maxHp*.08));note(s,"Sua fera recuperou o fôlego e se protegeu.","guard");reply(s,true)
 else
  local skill=Skills[C.ById[current.id].shape]
  local power=action=="Skill" and skill.power or 1
  local enemyFirst=s.foe.speed>current.speed
  if enemyFirst then reply(s,false) end
  if current.hp>0 then
   if action=="Skill" then
    current.nextSkill=s.turn+3
    if skill.effect=="heal" then current.hp=math.min(current.maxHp,current.hp+math.floor(current.maxHp*.12))
    elseif skill.effect=="evade" then current.evade=true
    elseif skill.effect=="weaken" then s.foe.atk=math.max(1,math.floor(s.foe.atk*.85))
    elseif skill.effect=="slow" then s.foe.speed=math.max(1,math.floor(s.foe.speed*.8)) end
    note(s,skill.name.."!","skill")
   end
   local amount=R.damage(current,s.foe,power,false);s.foe.hp=math.max(0,s.foe.hp-amount)
   note(s,"Sua fera causou "..amount.." de dano"..(Elements.mult(current.el,s.foe.el)>1 and " — vantagem elemental!" or "."),"hit")
   if s.foe.hp==0 then s.status="won";note(s,"Vitória! Feras exaustas não podem ser capturadas.","win")
   elseif not enemyFirst then reply(s,false) end
  end
 end
 if s.status=="active" and s.turn>=R.MaxTurns then s.status="escaped";note(s,"O encontro terminou pelo limite de turnos.") end
 return true
end
return R

end)()
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
