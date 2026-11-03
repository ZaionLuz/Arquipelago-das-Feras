--!nonstrict
-- Regras puras: sem serviços, instâncias, relógio ou recursos informados pelo cliente.
local C=require(script.Parent.Creatures)
local Elements=require(script.Parent.Elements)
local Skills=require(script.Parent.Skills)
local Capture=require(script.Parent.CaptureRules)
local R={MaxTurns=30,MaxParty=3}
function R.stats(id,lv)
 local def=assert(C.ById[id]);local scale=1+.15*(lv-1)
 return {id=id,lv=lv,maxHp=math.floor(def.hp*scale),atk=math.floor(def.atk*scale),def=4+def.rar*3+lv,speed=({Blob=9,Beast=15,Bird=20,Dragon=13,Serpent=16,Insect=18})[def.shape]+lv,el=def.el}
end
function R.damage(a,b,power,guard)
 return math.max(1,math.floor(a.atk*power*Elements.mult(a.el,b.el)*100/(100+b.def)*(guard and .45 or 1)))
end
function R.chance(s)
 if s.capturable==false then return 0 end
 local def=C.ById[s.foe.id]
 return math.clamp(Capture.chance(def.rar,s.foe.lv)*Capture.multiplier(s.sealKind or "Basic",def.rar,s.active and s.party[s.active].el,s.foe.el,s.bond)+(1-s.foe.hp/s.foe.maxHp)*.45+s.bond*.08,.05,.94)
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
  if s.capturable==false then return false,"Guardiões não podem ser capturados." end
  if seals<1 then return false,"Sem selos. Crie mais no Mercado." end
  if not room then return false,"Inventário cheio. Nenhum selo foi gasto." end
 elseif action=="Bond" and s.capturable==false then return false,"Este desafio exige uma batalha."
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
