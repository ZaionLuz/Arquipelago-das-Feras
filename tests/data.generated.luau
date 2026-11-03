-- Stub para testes estruturais. Não implementa render, física ou rotações Roblox.
local V={};V.__index=function(t,k) if k=="Magnitude" then return math.sqrt(t.X*t.X+t.Y*t.Y+t.Z*t.Z) end;return V[k] end
local function vector(x,y,z) return setmetatable({X=x or 0,Y=y or 0,Z=z or 0},V) end
V.__add=function(a,b) return vector(a.X+b.X,a.Y+b.Y,a.Z+b.Z) end
V.__sub=function(a,b) return vector(a.X-b.X,a.Y-b.Y,a.Z-b.Z) end
V.__mul=function(a,b)
 if type(b)=="number" then return vector(a.X*b,a.Y*b,a.Z*b) end
 return vector(a.X*b.X,a.Y*b.Y,a.Z*b.Z)
end
local Vector3={new=vector}
local F={};F.__index=F;F.__mul=function(a,b) return setmetatable({Position=a.Position+b.Position},F) end
local CFrame={new=function(x,y,z) return setmetatable({Position=type(x)=="table" and x or vector(x,y,z)},F) end,Angles=function() return setmetatable({Position=vector()},F) end}
CFrame.identity=CFrame.new()
local Color={};Color.__index=Color
function Color:Lerp(other,alpha) return setmetatable({r=self.r+(other.r-self.r)*alpha,g=self.g+(other.g-self.g)*alpha,b=self.b+(other.b-self.b)*alpha},Color) end
local function color(r,g,b) return setmetatable({r=r,g=g,b=b},Color) end
local Color3={new=color,fromRGB=function(r,g,b) return color(r/255,g/255,b/255) end}
local enum=setmetatable({},{__index=function(_,k) return k end})
local Enum={PartType=enum,Material=enum,Font=enum,ModelStreamingMode=enum}
local UDim2={fromOffset=function(x,y) return {x,y} end,fromScale=function(x,y) return {x,y} end}
local Methods={}
function Methods:SetAttribute(k,v) self._props["attr_"..k]=v end
function Methods:GetAttribute(k) return self._props["attr_"..k] end
function Methods:IsA(name) return self._class==name or (name=="BasePart" and self._class=="Part") end
function Methods:GetDescendants()
 local out={};local function visit(o) for _,child in o._children do table.insert(out,child);visit(child) end end;visit(self);return out
end
function Methods:Destroy() self._destroyed=true end
function Methods:GetPivot() return self.PrimaryPart and self.PrimaryPart.CFrame or CFrame.identity end
function Methods:GetBoundingBox()
 local min=vector(math.huge,math.huge,math.huge);local max=vector(-math.huge,-math.huge,-math.huge)
 for _,p in self:GetDescendants() do if p:IsA("BasePart") then
  local pos=p.CFrame.Position;local size=p.Size
  min=vector(math.min(min.X,pos.X-size.X/2),math.min(min.Y,pos.Y-size.Y/2),math.min(min.Z,pos.Z-size.Z/2))
  max=vector(math.max(max.X,pos.X+size.X/2),math.max(max.Y,pos.Y+size.Y/2),math.max(max.Z,pos.Z+size.Z/2))
 end end
 return CFrame.new((min+max)*.5),max-min
end
local Instance={new=function(class)
 return setmetatable({_class=class,_children={},_props={}},{__index=function(t,k) return Methods[k] or t._props[k] end,__newindex=function(t,k,v)
  t._props[k]=v;if k=="Parent" and v then table.insert(v._children,t) end
 end})
end}

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
local I=(function()
--!nonstrict
local L={
{id="Alvorecer",name="Ilha do Alvorecer",el="Natureza",cost=0,slots=4,ground=Color3.fromRGB(95,157,102),accent=Color3.fromRGB(183,232,139),deco="Ball",desc="Campos, nascentes e o primeiro acampamento de pesquisa."},
{id="Brasa",name="Ilha das Brasas",el="Fogo",cost=0,slots=4,ground=Color3.fromRGB(60,38,36),accent=Color3.fromRGB(255,96,32),deco="Block",desc="Vulcões e rios de magma."},
{id="Recife",name="Recife Cristalino",el="Água",cost=400,slots=5,ground=Color3.fromRGB(70,150,190),accent=Color3.fromRGB(120,255,235),deco="Ball",desc="Corais que cantam à noite."},
{id="Floresta",name="Floresta Murmurante",el="Natureza",cost=1200,slots=5,ground=Color3.fromRGB(60,130,70),accent=Color3.fromRGB(150,230,90),deco="Cylinder",desc="Árvores que sussurram segredos."},
{id="Dunas",name="Dunas Quebradas",el="Terra",cost=3500,slots=6,ground=Color3.fromRGB(210,170,100),accent=Color3.fromRGB(150,100,60),deco="Block",desc="Ruínas enterradas na areia."},
{id="Picos",name="Picos Celestes",el="Ar",cost=9000,slots=6,ground=Color3.fromRGB(190,210,235),accent=Color3.fromRGB(255,255,255),deco="Ball",desc="Ilhas de nuvem e tempestade."},
{id="Pantano",name="Pântano Umbral",el="Sombra",cost=22000,slots=8,ground=Color3.fromRGB(45,40,70),accent=Color3.fromRGB(190,90,255),deco="Cylinder",desc="Névoa viva e luzes que enganam."}}
local AMB={Alvorecer={Color3.fromRGB(134,163,137),11},Brasa={Color3.fromRGB(150,80,50),17},Recife={Color3.fromRGB(90,150,190),13},Floresta={Color3.fromRGB(80,140,90),10},Dunas={Color3.fromRGB(200,160,100),15},Picos={Color3.fromRGB(180,200,230),12},Pantano={Color3.fromRGB(70,50,110),23}}
local M={List=L,ById={}}
function M.pos(i) local a=(i-1)/#L*math.pi*2;return Vector3.new(math.cos(a)*150,10,math.sin(a)*150) end
for i,d in L do d.idx=i;d.minLevel=({1,1,10,18,26,34,42})[i];d.cost=math.min(d.cost,math.max(0,(i-1)*180));d.ambient=AMB[d.id][1];d.clock=AMB[d.id][2];M.ById[d.id]=d end
return M

end)()
local M=(function()
--!nonstrict
local L={}
local function add(id,text,stat,goal,gold,gems) table.insert(L,{id=id,text=text,stat=stat,goal=goal,gold=gold,gems=gems or 0}) end
add("f1","Alimente uma fera","feed",1,40)
add("f2","Alimente 5 vezes","feed",5,120,1)
add("f3","Alimente 20 vezes","feed",20,400,3)
add("b1","Cruze duas feras","breed",1,60)
add("b2","Cruze 5 vezes","breed",5,200,2)
add("h1","Choque um ovo","hatch",1,60)
add("h2","Choque 5 ovos","hatch",5,250,2)
add("w1","Vença uma batalha","win",1,80)
add("w2","Vença 10 batalhas","win",10,500,3)
add("w3","Vença 30 batalhas","win",30,1500,8)
add("c1","Colete ouro 5 vezes","collect",5,100)
add("d1","Descubra 8 feras","found",8,300,3)
add("d2","Descubra 15 feras","found",15,1200,6)
add("i1","Tenha 3 ilhas","isles",3,400,3)
add("i2","Tenha todas as ilhas","isles",#I.List,5000,15)
add("p1","Vença um duelo online","duelwin",1,200,3)
add("a1","Conquista: descubra todas as feras","found",#C.List,3000,20)
add("a2","Conquista: 100 vitórias","win",100,5000,20)
add("a3","Conquista: alimente 100 vezes","feed",100,2000,10)
add("a4","Conquista: choque 25 ovos","hatch",25,2500,10)
add("a5","Conquista: colete 50 vezes","collect",50,1500,8)
local M={List=L,ById={}}
for _,m in L do M.ById[m.id]=m end
function M.progress(d,stat)
	if stat=="found" or stat=="isles" then local n=0;for _ in (stat=="found" and d.discovered or d.unlocked) do n+=1 end;return n end
	return d.stats[stat] or 0
end
-- Evento rotativo: a cada 3 dias um elemento rende +50% de ouro.
local EL={"Fogo","Água","Natureza","Terra","Ar","Sombra"}
function M.event(now) local per=3*86400;return EL[(now//per)%6+1],per-now%per end
return M

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
local CaptureRules=(function()
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
-- Migração e leases com DataStore simulado; não valida APIs ou concorrência real.
local store={values={}}
local function copy(x) if type(x)~="table" then return x end;local t={};for k,v in x do t[k]=copy(v) end;return t end
function store:UpdateAsync(key,callback)
 if self.fail then error("falha simulada") end
 local value=callback(copy(self.values[key]))
 if value==nil then return nil end;self.values[key]=copy(value);return copy(value)
end
local serial=0
local Http={GenerateGUID=function() serial+=1;return tostring(serial) end}
local DSS={GetDataStore=function() return store end}
local game={GetService=function(_,name) return ({DataStoreService=DSS,ReplicatedStorage={},HttpService=Http})[name] end}
local task={wait=function() end,spawn=function(f) f() end}
local warn=function() end
local function who(id) return {UserId=id,Name="Teste",Kick=function(self,reason) self.kicked=reason end} end
local function factory()
--!nonstrict
local DSS=game:GetService("DataStoreService");local RS=game:GetService("ReplicatedStorage")
local C=C;local I=I
local M=M
local SR=SR
local Story=Story
local CaptureRules=CaptureRules
local store=DSS:GetDataStore("ArquipelagoV1")
local D={};local profiles={}
local VERSION=4
local sessions={}
local Http=game:GetService("HttpService")
local LEASE=180
local function clone(t) local out={};for k,v in t do out[k]=typeof(v)=="table" and clone(v) or v end;return out end
local function default()
	return {v=VERSION,gold=100,gems=5,seals=5,playerLevel=1,playerXp=0,sealStock={},companion=nil,storyClaimed={},guardians={},visited={},materials={},gatherAt={},sanctuary={Brasa={slot=1,level=1},Recife={slot=2,level=1}},nextId=3,last=os.time(),wins=0,
		creatures={u1={id="cinzelo",lv=1,xp=0},u2={id="bolhinho",lv=1,xp=0}},eggs={},
		stats={},claimed={},pass={},receipts={},dailyDay=0,streak=0,trophies=0,tut=false,habitat={Brasa={"u1"},Recife={"u2"}},unlocked={Alvorecer=true,Brasa=true,Recife=true},discovered={cinzelo=true,bolhinho=true}}
end
-- Valida e migra dados salvos; corrompido => padrão (por campo quando possível).
function D.validate(raw)
	local d=default();if typeof(raw)~="table" or typeof(raw.creatures)~="table" then return d end
	local function num(x,f,mx) return (typeof(x)=="number" and x==x and x>=0 and x<=mx) and math.floor(x) or f end
	d.seals=num(raw.seals,5,10000);d.sealStock={}
 for kind in CaptureRules.Seals do
  if kind~="Basic" and typeof(raw.sealStock)=="table" then d.sealStock[kind]=num(raw.sealStock[kind],0,10000) end
 end
	d.gold=num(raw.gold,d.gold,1e12);d.gems=num(raw.gems,d.gems,1e9);d.wins=num(raw.wins,0,1e9);d.nextId=num(raw.nextId,d.nextId,1e9)
	d.last=math.min(num(raw.last,os.time(),1e12),os.time())
	local cr,n={},0
	for uid,c in raw.creatures do
		if typeof(uid)=="string" and typeof(c)=="table" and C.ById[c.id] and n<60 then cr[uid]={id=c.id,lv=math.clamp(num(c.lv,1,100),1,100),xp=num(c.xp,0,1e9)};n+=1 end
	end
	if n==0 then return d end
	for uid in cr do local n=tonumber(string.match(uid,"^u(%d+)$"));if n then d.nextId=math.max(d.nextId,n+1) end end
	d.creatures=cr;d.discovered={};for _,c in cr do d.discovered[c.id]=true end
	if typeof(raw.discovered)=="table" then for id in raw.discovered do if C.ById[id] then d.discovered[id]=true end end end
	d.unlocked={Alvorecer=true,Brasa=true}
	if typeof(raw.unlocked)=="table" then for id in I.ById do if raw.unlocked[id]==true then d.unlocked[id]=true end end end
	d.playerLevel=math.clamp(num(raw.playerLevel,1,100),1,100);d.playerXp=num(raw.playerXp,0,1e9)
 d.companion=typeof(raw.companion)=="string" and cr[raw.companion] and raw.companion or nil
 d.guardians={};d.visited={};d.materials={};d.gatherAt={}
 for _,def in I.List do
  if typeof(raw.guardians)=="table" and raw.guardians[def.id]==true then d.guardians[def.id]=true end
  if typeof(raw.visited)=="table" and raw.visited[def.id]==true then d.visited[def.id]=true end
  if typeof(raw.gatherAt)=="table" then d.gatherAt[def.id]=num(raw.gatherAt[def.id],0,1e12) end
  if typeof(raw.materials)=="table" then d.materials[def.el]=num(raw.materials[def.el],0,10000) end
 end
 d.storyClaimed={}
 if typeof(raw.storyClaimed)=="table" then for id,claimed in raw.storyClaimed do if claimed==true and Story.ById[id] then d.storyClaimed[id]=true end end end
 if typeof(raw.sanctuary)=="table" then d.sanctuary=SR.validate(raw.sanctuary,d.unlocked,I.List)
 else -- Migração: habitats legados recebem posição própria; nenhuma criatura é removida.
  d.sanctuary={};local slot=0
  for _,def in I.List do if d.unlocked[def.id] then slot+=1;d.sanctuary[def.id]={slot=slot,level=1} end end
 end
 d.habitat={};local seen={}
	if typeof(raw.habitat)=="table" then
		for isl,list in raw.habitat do
			local def=I.ById[isl]
			if def and d.unlocked[isl] and typeof(list)=="table" then
				d.habitat[isl]={}
				for _,uid in list do
					if typeof(uid)=="string" and cr[uid] and not seen[uid] and #d.habitat[isl]<SR.capacity(def,d.sanctuary[isl]) then seen[uid]=true;table.insert(d.habitat[isl],uid) end
				end
			end
		end
	end
 for id,list in d.habitat do
  if #list>0 and not d.sanctuary[id] then
   for slot=1,9 do if SR.available(d.sanctuary,slot) then d.sanctuary[id]={slot=slot,level=1};break end end
  end
 end
	d.stats={};d.claimed={}
	if typeof(raw.stats)=="table" then for k,v in raw.stats do if typeof(k)=="string" then d.stats[k]=num(v,0,1e9) end end end
	if typeof(raw.claimed)=="table" then for id,value in raw.claimed do if value==true and M.ById[id] then d.claimed[id]=true end end end
	d.trophies=num(raw.trophies,0,1e9);d.tut=raw.tut==true
	d.receipts={};d.pass={};d.dailyDay=math.min(num(raw.dailyDay,0,1e9),os.time()//86400);d.streak=num(raw.streak,0,1e6)
	if typeof(raw.receipts)=="table" then for k,value in raw.receipts do if value==true and typeof(k)=="string" then d.receipts[k]=true end end end
	d.eggs={}
	if typeof(raw.eggs)=="table" then
		for _,e in raw.eggs do
			if #d.eggs<3 and typeof(e)=="table" and C.ById[e.id] and typeof(e.ready)=="number" and e.ready==e.ready and e.ready>=0 and e.ready<1e12 then table.insert(d.eggs,{id=e.id,ready=math.floor(e.ready)}) end
		end
	end
	return d
end
-- Lease gravado atomicamente no MESMO registro legado (sem trocar a chave).
function D.load(p)
 local token=Http:GenerateGUID(false)
 local raw,ok
 for attempt=1,3 do
  ok,raw=pcall(function()
   return store:UpdateAsync("P"..p.UserId,function(old)
    if old~=nil and (typeof(old)~="table" or typeof(old.creatures)~="table" or (old.v or 1)>VERSION) then error("Perfil inválido ou versão futura; recuperação manual necessária") end
    local lock=old and old._session
    if lock and typeof(lock)~="table" then error("Lease inválido") end
    if lock and lock.token~=token and (lock.expires or 0)>os.time() then return nil end
    local data=D.validate(old);data._session={token=token,expires=os.time()+LEASE};return data
   end)
  end)
  if ok then break end;task.wait(attempt)
 end
 if not ok or not raw then p:Kick("Dados indisponíveis ou sessão ainda ativa. Aguarde e reconecte; nada foi reiniciado.");return false end
 profiles[p]=D.validate(raw);sessions[p]={token=token,expires=raw._session.expires,busy=false}
 return true
end
function D.get(p)
 local session=sessions[p]
 if not session or session.expires<=os.time() or session.closing then return nil end
 return profiles[p]
end
function D.snapshot(p)
 local d=clone(profiles[p]);d.receipts=nil;for _,e in d.eggs do e.left=math.max(0,e.ready-os.time()) end
 local el,left=M.event(os.time());d.event={el=el,left=left};return d
end
function D.save(p,release)
 local session=sessions[p];local d=profiles[p]
 if not session or not d then return false end
 while session.busy do task.wait() end
 if sessions[p]~=session then return false end
 session.busy=true
 local payload=clone(d);payload.pass=nil;payload.event=nil
 for _,egg in payload.eggs do egg.left=nil end
 local expiry=os.time()+LEASE
 payload._session=not release and {token=session.token,expires=expiry} or nil
 local ok,result=pcall(function()
  return store:UpdateAsync("P"..p.UserId,function(old)
   if not old or not old._session or old._session.token~=session.token then return nil end
   return payload
  end)
 end)
 session.busy=false
 if ok and result then session.expires=expiry;return true end
 warn("Falha ao salvar perfil de "..p.Name)
 if ok or os.time()>=session.expires then
  session.closing=true;p:Kick("Sessão de dados encerrada. Reconecte para proteger seu progresso.")
 end
 return false
end
function D.release(p)
 local session=sessions[p];if not session then return end
 session.closing=true
 for _=1,3 do if D.save(p,true) then break end;task.wait(1) end
 profiles[p]=nil;sessions[p]=nil
end
function D.saveAll() for p in profiles do D.save(p) end end
function D.closeAll()
 local pending=0
 for p in profiles do pending+=1;task.spawn(function() D.release(p);pending-=1 end) end
 local deadline=os.clock()+25
 while pending>0 and os.clock()<deadline do task.wait(.1) end
end
return D

end
local D=factory();local Other=factory()
local old={v=3,gold=432,gems=12,creatures={u1={id="cinzelo",lv=20,xp=70},u99={id="bolhinho",lv=100,xp=3}},nextId=3,unlocked={Brasa=true,Recife=true},habitat={Brasa={"u1","u99"}},seals=4}
local migrated=D.validate(old)
assert(migrated.v==4 and migrated.gold==432 and migrated.gems==12 and migrated.seals==4)
assert(migrated.creatures.u1.lv==20 and migrated.creatures.u99.lv==100 and migrated.nextId==100)
assert(migrated.sanctuary.Brasa and migrated.unlocked.Alvorecer and #migrated.habitat.Brasa==2)
local newer=copy(migrated);newer.companion="u99";newer.playerLevel=80;newer.playerXp=100;newer.materials={Natureza=5};newer.sealStock={Rare=3};newer.sanctuary.Brasa.level=3
newer.guardians={Brasa=true};newer.visited={Alvorecer=true};newer.storyClaimed={arrival=true}
local checked=D.validate(newer)
assert(checked.companion=="u99" and checked.playerLevel==80 and checked.materials.Natureza==5 and checked.sealStock.Rare==3)
assert(checked.sanctuary.Brasa.level==3 and checked.guardians.Brasa and checked.storyClaimed.arrival)
local a,b=who(1),who(1);assert(D.load(a));assert(not Other.load(b))
local data=D.get(a);data.gold=654;data.receipts.secret=true
local snap=D.snapshot(a);assert(snap.receipts==nil);snap.gold=1;assert(data.gold==654)
assert(D.save(a));assert(store.values.P1.gold==654)
D.release(a);local c=who(1);assert(Other.load(c));assert(Other.get(c).gold==654)
store.values.P1._session.token="alien";assert(not Other.save(c));assert(store.values.P1.gold==654)
store.fail=true;local failed=who(8);assert(not D.load(failed));assert(not store.values.P8)
print("PASS: migração v3→v4, UID, níveis, santuário, companion, inventário, snapshot, lease, sessão concorrente e falha de dados simulados")
