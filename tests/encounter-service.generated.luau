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

end)()

local Progression=(function()
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

-- Dependências Roblox simuladas: verifica transações e protocolo, não rede real.
local clock=0;local now=10000
local os={clock=function() return clock end,time=function() return now end}
local data={};local releaseCount=0;local registry={};local emitted={};local removal
local Players={PlayerRemoving={Connect=function(_,callback) removal=callback end}}
local RS={};local Http={GenerateGUID=function() return "token"..tostring(clock) end}
local game={GetService=function(_,name) return ({ReplicatedStorage=RS,Players=Players,HttpService=Http})[name] end}
local Instance={new=function()
 local obj={FireClient=function(_,player,snapshot) emitted[player]=snapshot end}
 return setmetatable(obj,{__newindex=function(t,k,v) rawset(t,k,v);if k=="Name" then registry[v]=t end end})
end}
local task={spawn=function() end,wait=function() end}
local Data={get=function(p) return data[p] end}
local World={refresh=function() end}
local vector=setmetatable({},{__sub=function() return {Magnitude=0} end})
local function player()
 return {Character={FindFirstChild=function() return {Position=vector} end,FindFirstChildOfClass=function() return {Health=100} end}}
end
local E=(function()
--!nonstrict

local Rules=R
local CaptureRules=Capture
local Progression=Progression
local E={};local sessions={};local rng={NextNumber=function() return 0 end};local net;local events
local function snapshot(session,message)
 local s=session.state;local party={}
 for uid,p in s.party do party[uid]={id=p.id,lv=p.lv,hp=p.hp,maxHp=p.maxHp,nextSkill=p.nextSkill} end
 return {token=session.token,seals=session.seals,sealType=session.sealType or "Basic",sealStock=session.sealStock or {},version=s.version,status=s.status,capturable=s.capturable~=false,turn=s.turn,foe=s.foe,party=party,active=s.active,bond=s.bond,chance=Rules.chance(s),log=s.log,message=message,expires=session.expires}
end
local function finish(player,session)
 if session.released then return end;session.released=true
 local d=Data.get(player);local s=session.state
 if d and s.status=="captured" then
  while d.creatures["u"..d.nextId] do d.nextId+=1 end
  local uid="u"..d.nextId;d.nextId+=1;d.creatures[uid]={id=s.foe.id,lv=s.foe.lv,xp=0}
  d.discovered[s.foe.id]=true;d.stats.capture=(d.stats.capture or 0)+1;Progression.award(d,30+C.ById[s.foe.id].rar*15)
 elseif d and s.status=="won" then
  local def=C.ById[s.foe.id];local reward=20+def.rar*15;d.gold+=reward;d.wins+=1;d.stats.win=(d.stats.win or 0)+1;Progression.award(d,40+def.rar*20)
  local pet=d.creatures[s.active]
  if pet then
   Progression.awardCreature(pet,20+def.rar*10)
   local refreshed,err=pcall(World.refresh,player)
   if not refreshed then warn("Modelo será reconstruído na próxima atualização: "..tostring(err)) end
  end
 end
 if s.status=="won" then table.insert(s.log,{text="Recompensa: "..(20+C.ById[s.foe.id].rar*15).." ouro e experiência para a fera ativa.",kind="reward"}) end
 if d and s.status=="won" and session.guardian and not d.guardians[session.guardian] then
  d.guardians[session.guardian]=true;d.stats.guardian=(d.stats.guardian or 0)+1;d.gold+=100;Progression.award(d,200)
 end
 session.release(s.status=="captured" or s.status=="won")
end
function E.open(player,specimen,release)
 local d=Data.get(player);if not d then return false end
 local old=sessions[player]
 if old and old.state.status=="active" then return false end
 local session={token=Http:GenerateGUID(false),state=Rules.new(specimen.id,specimen.lv),guardian=specimen.guardianId,seals=d.seals,origin=specimen.position,expires=os.time()+150,release=release}
 session.state.capturable=specimen.capturable~=false
 session.sealType="Basic";session.sealStock=d.sealStock or {}
 d.stats.fight=(d.stats.fight or 0)+1
 sessions[player]=session;events:FireClient(player,snapshot(session));return true
end
function E.active(player) local s=sessions[player];return s and s.state.status=="active" end
function E.start()
 net=Instance.new("RemoteFunction");net.Name="EncounterNet";net.Parent=RS
 events=Instance.new("RemoteEvent");events.Name="EncounterNotice";events.Parent=RS
 net.OnServerInvoke=function(player,token,version,action,uid)
  local session=sessions[player];local d=Data.get(player)
  if not session or not d then return nil end
  -- Recuperação da própria sessão caso o evento inicial chegue antes da UI.
  if action=="Resume" then
   if session.readAt and os.clock()-session.readAt<.1 then return nil end
   session.readAt=os.clock();return snapshot(session)
  end
  if typeof(token)~="string" or #token>80 or token~=session.token then return nil end
  if typeof(action)~="string" or #action>16 or (uid~=nil and (typeof(uid)~="string" or #uid>40)) then return snapshot(session,"Pedido inválido.") end
  if action=="State" then
   if session.readAt and os.clock()-session.readAt<.1 then return nil end
   session.readAt=os.clock();return snapshot(session)
  end
  if session.state.status~="active" then return snapshot(session) end
  local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart");local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
  if os.time()>=session.expires or not root or not humanoid or humanoid.Health<=0 or (root.Position-session.origin).Magnitude>40 then
   session.state.status="escaped";finish(player,session);return snapshot(session,"O encontro encerrou: distância, tempo ou personagem indisponível.")
  end
  if typeof(version)~="number" or version~=session.state.version then return snapshot(session,"Estado atualizado. Escolha novamente.") end
  if session.last and os.clock()-session.last<.25 then return snapshot(session,"Aguarde o turno.") end
  session.last=os.clock()
  if action=="ChooseSeal" then
   local seal=CaptureRules.Seals[uid]
   if not seal then return snapshot(session,"Selo inválido") end
   session.sealType=uid;session.state.sealKind=uid;session.state.version+=1;session.state.log={}
   session.seals=uid=="Basic" and d.seals or (d.sealStock or {})[uid] or 0
   return snapshot(session)
  end
  local pet=uid and d.creatures[uid];local count=0;for _ in d.creatures do count+=1 end
  local ok,message=Rules.step(session.state,action,pet and {uid=uid,id=pet.id,lv=pet.lv},rng,session.seals,count<60)
  if not ok then return snapshot(session,message) end
  if session.state.spentSeal then
   if session.sealType=="Basic" then d.seals-=1 else d.sealStock[session.sealType]-=1 end
  end
  session.seals=session.sealType=="Basic" and d.seals or (d.sealStock or {})[session.sealType] or 0
  if session.state.status~="active" then finish(player,session) end
  return snapshot(session)
 end
 Players.PlayerRemoving:Connect(function(player)
  local s=sessions[player];if s then s.state.status="escaped";finish(player,s) end;sessions[player]=nil
 end)
 task.spawn(function()
  while true do task.wait(2)
   for player,s in sessions do
    if s.state.status=="active" and (os.time()>=s.expires or not Data.get(player)) then
     s.state.status="escaped";finish(player,s);events:FireClient(player,snapshot(s,"O encontro terminou."))
    end
   end
  end
 end)
end
return E

end)()
local p=player();data[p]={gold=100,seals=3,nextId=3,creatures={u1={id="magmarau",lv=20,xp=0}},stats={},discovered={},wins=0,guardians={},sealStock={},playerLevel=1,playerXp=0}
E.start();local net=registry.EncounterNet
local function open()
 clock+=1
 assert(E.open(p,{id="cinzelo",lv=1,position=vector},function() releaseCount+=1 end))
 return emitted[p]
end
local function request(state,action,uid)
 clock+=1;return net.OnServerInvoke(p,state.token,state.version,action,uid)
end
local s=open()
assert(net.OnServerInvoke(p,"forged",0,"Capture")==nil)
local resume=net.OnServerInvoke(p,"",0,"Resume");assert(resume.token==s.token and data[p].seals==3)
local old=s
s=net.OnServerInvoke(p,s.token,999,"Capture");assert(data[p].seals==3 and s.version==0)
s=request(s,"Capture")
-- RNG fixo abaixo faz a captura ter sucesso: uma única concessão e débito.
assert(s.status=="captured" and data[p].seals==2 and data[p].creatures.u3)
local n=releaseCount
request(old,"Capture");assert(data[p].seals==2 and releaseCount==n and not data[p].creatures.u4)
s=open();s=request(s,"Select"," чужой");assert(s.version==0)
s=request(s,"Select","u1");assert(s.version==1)
while s.status=="active" do s=request(s,"Strike") end
assert(s.status=="won" and data[p].gold>100 and data[p].wins==1)
local gold=data[p].gold;request(s,"Strike");assert(data[p].gold==gold and data[p].wins==1)
s=open();now+=151;s=request(s,"Capture");assert(s.status=="escaped" and data[p].seals==2)
s=open();removal(p);assert(not E.active(p))
print("PASS: protocolo do encontro: token, versão, propriedade, débito único, concessão única, recompensa única, timeout e saída")
-- V6: estoque separado e desafios de guardião sem captura.
clock+=1;assert(E.open(p,{id="cinzelo",lv=1,position=vector},function() releaseCount+=1 end));s=emitted[p]
data[p].sealStock.Rare=1
s=request(s,"ChooseSeal","Rare");assert(s.sealType=="Rare" and s.seals==1)
s=request(s,"Capture");assert(s.status=="captured" and data[p].sealStock.Rare==0 and data[p].seals==2)
clock+=1;assert(E.open(p,{id="cinzelo",lv=1,position=vector,capturable=false,guardianId="Brasa"},function() releaseCount+=1 end));s=emitted[p]
local before=data[p].seals;s=request(s,"Capture");assert(s.version==0 and data[p].seals==before)
s=request(s,"Select","u1")
while s.status=="active" do s=request(s,"Strike") end
assert(data[p].guardians.Brasa and data[p].stats.guardian==1)
local oldGold=data[p].gold;request(s,"Strike");assert(data[p].gold==oldGold and data[p].stats.guardian==1)
print("PASS: estoque de selo separado, guardião incapturável e bônus de desafio único")
