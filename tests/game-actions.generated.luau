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
local E=(function()
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
local B=(function()
--!nonstrict
local C=C
local B={}
-- Cruzamento: 25% de híbrido (elementos diferentes); senão sorteia por raridade. Lendário exige pais raros+.
function B.pick(a,b,rng)
	local A,Z=C.ById[a],C.ById[b]
	if A.el~=Z.el and rng:NextNumber()<0.25 then
		local pool={}
		for _,c in C.List do
			local h=c.hybrid
			if h and ((h[1]==A.el and h[2]==Z.el) or (h[1]==Z.el and h[2]==A.el)) then table.insert(pool,c.id) end
		end
		if #pool>0 then return pool[rng:NextInteger(1,#pool)] end
	end
	local cap=math.min(4,math.max(A.rar,Z.rar)+(rng:NextNumber()<0.1 and 1 or 0))
	if cap>=4 and math.min(A.rar,Z.rar)<3 then cap=3 end
	local pool,tot={},0
	for _,c in C.List do
		if not c.hybrid and c.rar<=cap and (c.el==A.el or c.el==Z.el) then local w=1/(c.rar*c.rar);table.insert(pool,{c.id,w});tot+=w end
	end
	local r=rng:NextNumber()*tot
	for _,e in pool do r-=e[2];if r<=0 then return e[1] end end
	return pool[1][1]
end
-- Distribuição exata do algoritmo pick: mesma regra, sem mudar receitas existentes.
function B.outcomes(a,b)
 local A,Z=C.ById[a],C.ById[b];if not A or not Z then return {} end
 local out={};local hybrids={}
 if A.el~=Z.el then
  for _,c in C.List do local h=c.hybrid
   if h and ((h[1]==A.el and h[2]==Z.el) or (h[2]==A.el and h[1]==Z.el)) then table.insert(hybrids,c.id) end
  end
 end
 local hybridChance=#hybrids>0 and .25 or 0
 for _,id in hybrids do out[id]=hybridChance/#hybrids end
 for boost=0,1 do
  local cap=math.min(4,math.max(A.rar,Z.rar)+boost)
  if cap>=4 and math.min(A.rar,Z.rar)<3 then cap=3 end
  local total=0;local pool={}
  for _,c in C.List do
   if not c.hybrid and c.rar<=cap and (c.el==A.el or c.el==Z.el) then
    local weight=1/(c.rar*c.rar);pool[c.id]=weight;total+=weight
   end
  end
  local branch=(1-hybridChance)*(boost==1 and .1 or .9)
  for id,w in pool do out[id]=(out[id] or 0)+branch*w/total end
 end
 return out
end
return B

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
local Balance=(function()
--!strict
return {MaxLevel=100,InventoryLimit=60,IncubatorSlots=3,BreedCost=50,IncubationBase=30,OfflineCap=8*3600}

end)()
local profiles={};local Data={get=function(p) return profiles[p] end,snapshot=function(p) return profiles[p] end}
local World={refresh=function() end};local Sanctuary={home=function() return true end}
local Transport={go=function() return true end}
local Mon={buy=function() return false,"desativado" end}
local Random={new=function() return {NextNumber=function() return .5 end,NextInteger=function(_,a) return a end} end}
local Players={GetPlayerByUserId=function() return nil end}
local game={GetService=function(_,name) return name=="Players" and Players or {} end}
local workspace={GetServerTimeNow=function() return 123 end}
local G=(function()
--!nonstrict
local RS=game:GetService("ReplicatedStorage")
local C=C;local I=I;local E=E;local B=B
local M=M
local SR=SR
local CaptureRules=CaptureRules
local Story=Story
local Progression=Progression
local Transport=Transport
local Sanctuary=Sanctuary
local Data=Data;local World=World
local G={};local rng=Random.new()
local Mon=Mon
local lastBattle=setmetatable({},{__mode="k"})
local Balance=Balance
local MAXLV,OFFLINE_CAP,BREED_COST=Balance.MaxLevel,Balance.OfflineCap,Balance.BreedCost
local function lvMul(lv) return 1+0.15*(lv-1) end
local function bump(d,k) d.stats[k]=(d.stats[k] or 0)+1 end
local function fail(m) return {ok=false,msg=m} end
local function ok(p,m) return {ok=true,msg=m,data=Data.snapshot(p)} end
-- Renda por tempo REAL do servidor (os.time), limitada a 8 h: alterar o relógio do cliente não adianta.
local function settle(p)
	local d=Data.get(p);local now=os.time();local mins=math.clamp(now-d.last,0,OFFLINE_CAP)/60;local gold=0;local EV=M.event(now)
	for isl,list in d.habitat do
		for _,uid in list do
			local cr=d.creatures[uid]
			if cr then local cd=C.ById[cr.id];gold+=cd.gpm*lvMul(cr.lv)*(cd.el==I.ById[isl].el and 1.5 or 1)*(cd.el==EV and 1.5 or 1)*(d.pass.Dobro and 2 or 1)*mins end
		end
	end
	gold=math.floor(gold);d.gold+=gold;d.last=now;return gold
end
G.Actions={}
local A=G.Actions
function A.Home(p) if not Sanctuary.home(p) then return fail("Personagem ou destino indisponível. Aguarde e tente novamente.") end;return ok(p,"Bem-vindo ao seu santuário") end
function A.Travel(p,id)
 local d=Data.get(p);local def=I.ById[id];local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
 if not def or not d.unlocked[id] or not root then return fail("Destino indisponível") end
 if not Transport.go(p,I.pos(def.idx)+Vector3.new(0,9,24)) then return fail("Destino ainda não carregou. Tente novamente.") end
 return ok(p,"Chegou a "..def.name)
end
function A.Companion(p,uid)
 local d=Data.get(p)
 if uid~=nil and not d.creatures[uid] then return fail("Escolha uma fera sua") end
 if d.companion==uid then d.companion=nil else d.companion=uid end
 World.refresh(p);return ok(p,d.companion and "Companheiro escolhido" or "Companheiro guardado")
end
function A.Pet(p)
 local d=Data.get(p);if not d.companion then return fail("Escolha um companheiro") end
 p:SetAttribute("PetHappyUntil",workspace:GetServerTimeNow()+2);return ok(p,"Seu companheiro gostou do carinho!")
end
function A.BuildHabitat(p,id,slot)
 local d=Data.get(p);local def=I.ById[id]
 if not def or not d.unlocked[id] or d.sanctuary[id] or not SR.available(d.sanctuary,slot) then return fail("Habitat, posição ou desbloqueio inválido") end
 local cost=SR.buildCost(def);if d.gold<cost then return fail("Precisa de "..cost.." ouro") end
 d.gold-=cost;d.sanctuary[id]={slot=slot,level=1};bump(d,"habitatBuild");World.refresh(p);return ok(p,"Habitat construído no seu terreno")
end
function A.MoveHabitat(p,id,slot)
 local d=Data.get(p);local entry=d.sanctuary[id]
 if not entry or not SR.available(d.sanctuary,slot,id) then return fail("Posição ocupada ou inválida") end
 entry.slot=slot;World.refresh(p);return ok(p,"Habitat movido")
end
function A.UpgradeHabitat(p,id)
 local d=Data.get(p);local entry=d.sanctuary[id]
 if not entry or entry.level>=SR.MaxLevel then return fail("Habitat indisponível ou máximo") end
 local cost=SR.upgradeCost(entry);if d.gold<cost then return fail("Precisa de "..cost.." ouro") end
 settle(p);d.gold-=cost;entry.level+=1;bump(d,"habitatUpgrade");World.refresh(p);return ok(p,"Habitat melhorado: mais duas vagas")
end
function A.RemoveHabitat(p,id)
 local d=Data.get(p)
 if not d.sanctuary[id] or #(d.habitat[id] or {})>0 then return fail("Transfira as feras antes de remover o habitat") end
 d.sanctuary[id]=nil;World.refresh(p);return ok(p,"Estrutura removida, sem reembolso")
end
function A.ClaimStory(p,id)
 local d=Data.get(p);if not Story.canClaim(d,id) then return fail("Conclua o capítulo atual primeiro") end
 local q=Story.ById[id];d.storyClaimed[id]=true;d.gold+=q.gold;d.seals=math.min(10000,d.seals+q.seals);Progression.award(d,q.xp)
 return ok(p,"Capítulo concluído! +"..q.gold.." ouro, +"..q.xp.." XP e +"..q.seals.." selos")
end
function A.CraftSeal(p,kind)
 local d=Data.get(p);kind=kind or "Basic";local recipe=CaptureRules.Seals[kind]
 if not recipe then return fail("Tipo de selo inválido") end
 local count=kind=="Basic" and d.seals or d.sealStock[kind] or 0
 if count>=10000 or d.gold<recipe.cost or d.playerLevel<recipe.level then return fail("Precisa de nível "..recipe.level.." e "..recipe.cost.." ouro; limite 10 mil selos") end
 if recipe.material and (d.materials[recipe.material] or 0)<recipe.amount then return fail("Precisa de "..recipe.amount.." essência de "..recipe.material) end
 d.gold-=recipe.cost
 if recipe.material then d.materials[recipe.material]-=recipe.amount end
 if kind=="Basic" then d.seals+=1 else d.sealStock[kind]=count+1 end
 return ok(p,"+1 Selo "..recipe.name)
end
function A.Get(p) return ok(p) end
function A.Collect(p) local g=settle(p);bump(Data.get(p),"collect");return ok(p,"+"..g.." ouro") end
function A.Feed(p,uid)
	local d=Data.get(p);local cr=d.creatures[uid]
	if not cr then return fail("Criatura inválida") end
	if cr.lv>=MAXLV then return fail("Nível máximo") end
	settle(p);local cost=cr.lv*20
	if d.gold<cost then return fail("Ouro insuficiente ("..cost..")") end
	d.gold-=cost;cr.lv+=1;bump(d,"feed");World.refresh(p);return ok(p,"Subiu para o nível "..cr.lv..(C.stage(cr.lv,cr.id)>C.stage(cr.lv-1,cr.id) and " — EVOLUIU!" or ""))
end
function A.Place(p,uid,isl)
	local d=Data.get(p);local def=I.ById[isl]
	if not d.creatures[uid] or not def or not d.unlocked[isl] then return fail("Ilha ou criatura inválida") end
	local structure=d.sanctuary[isl]
 if not structure then return fail("Construa esse habitat no Santuário") end
 local creature=C.ById[d.creatures[uid].id]
 if creature.el~=def.el and not (creature.hybrid and table.find(creature.hybrid,def.el)) then return fail("Elemento incompatível com este habitat") end
 local list=d.habitat[isl] or {}
	if #list-(table.find(list,uid) and 1 or 0)>=SR.capacity(def,structure) then return fail("Habitat cheio") end
	settle(p)
	for _,l in d.habitat do local i=table.find(l,uid);if i then table.remove(l,i) end end
	d.habitat[isl]=d.habitat[isl] or {};table.insert(d.habitat[isl],uid);World.refresh(p)
	return ok(p,C.ById[d.creatures[uid].id].name.." agora vive em "..def.name)
end
function A.Unlock(p,isl)
	local d=Data.get(p);local def=I.ById[isl]
	if not def or d.unlocked[isl] then return fail("Ilha inválida") end
	if (d.playerLevel or 1)<(def.minLevel or 1) then return fail("Explorador nível "..def.minLevel.." necessário") end
 if d.gold<def.cost then return fail("Precisa de "..def.cost.." ouro") end
	d.gold-=def.cost;d.unlocked[isl]=true;return ok(p,def.name.." desbloqueada!")
end
function A.Breed(p,a,b)
	local d=Data.get(p)
	if a==b or not d.creatures[a] or not d.creatures[b] then return fail("Escolha duas feras diferentes") end
	if #d.eggs>=Balance.IncubatorSlots then return fail("Chocadeira cheia") end
	if d.gold<BREED_COST then return fail("Precisa de "..BREED_COST.." ouro") end
	d.gold-=BREED_COST;bump(d,"breed");local id=B.pick(d.creatures[a].id,d.creatures[b].id,rng);local r=C.ById[id].rar
	table.insert(d.eggs,{id=id,ready=os.time()+Balance.IncubationBase*r*r});return ok(p,"Ovo misterioso! Eclode em "..Balance.IncubationBase*r*r.."s")
end
function A.Hatch(p,i)
	local d=Data.get(p);local e=typeof(i)=="number" and d.eggs[i]
	if not e then return fail("Ovo inválido") end
	if os.time()<e.ready then return fail("Ainda não eclodiu") end
	local n=0;for _ in d.creatures do n+=1 end
	if n>=Balance.InventoryLimit then return fail("Limite de 60 feras") end
	while d.creatures["u"..d.nextId] do d.nextId+=1 end
 local uid="u"..d.nextId;d.nextId+=1;d.creatures[uid]={id=e.id,lv=1,xp=0};d.discovered[e.id]=true;table.remove(d.eggs,i);bump(d,"hatch")
	return ok(p,"Nasceu "..C.ById[e.id].name.."!")
end
function A.Battle(p,uid,isl)
	local d=Data.get(p);local cr=d.creatures[uid];local def=I.ById[isl]
	if not cr or not def or not d.unlocked[isl] then return fail("Batalha inválida") end
	if lastBattle[p] and os.clock()-lastBattle[p]<20 then return fail("Suas feras descansam: "..math.ceil(20-(os.clock()-lastBattle[p])).."s") end
	lastBattle[p]=os.clock();bump(d,"fight")
	local pool={};for _,c in C.List do if c.island==isl then table.insert(pool,c) end end
	if #pool==0 then for _,c in C.List do if c.el==def.el and c.rar<=2 then table.insert(pool,c) end end end
 local g=pool[rng:NextInteger(1,#pool)];local glv=math.min(MAXLV,(def.minLevel or 1)+g.rar*2);local me=C.ById[cr.id]
	local m1,m2=me.hp*lvMul(cr.lv),g.hp*lvMul(glv);local hp1,hp2,log=m1,m2,{}
	for _=1,40 do
		local x=me.atk*lvMul(cr.lv)*E.mult(me.el,g.el);hp2-=x
		table.insert(log,{me=true,dmg=math.floor(x),hp=math.max(0,hp2)/m2,mult=E.mult(me.el,g.el)});if hp2<=0 then break end
		x=g.atk*lvMul(glv)*E.mult(g.el,me.el);hp1-=x
		table.insert(log,{me=false,dmg=math.floor(x),hp=math.max(0,hp1)/m1,mult=E.mult(g.el,me.el)});if hp1<=0 then break end
	end
	local info={log=log,me={id=cr.id,lv=cr.lv},foe={id=g.id,lv=glv},win=hp2<=0}
	if hp2>0 then local r=ok(p,"Derrota para "..g.name.." (Nv."..glv.."). Treine e tente de novo!");r.battle=info;return r end
	local gold=math.floor(12*def.idx*g.rar*(me.el==M.event(os.time()) and 1.25 or 1));local gem=rng:NextNumber()<0.2 and 1 or 0
	d.gold+=gold;d.gems+=gem;d.wins+=1;bump(d,"win")
	local r=ok(p,"Vitória sobre "..g.name.."! +"..gold.." ouro"..(gem>0 and " +1 gema" or ""));r.battle=info;return r
end

function A.Claim(p,id)
	local d=Data.get(p);local m=M.ById[id]
	if not m or d.claimed[id] or M.progress(d,m.stat)<m.goal then return fail("Missão indisponível") end
	d.claimed[id]=true;d.gold+=m.gold;d.gems+=m.gems;return ok(p,"Recompensa: +"..m.gold.." ouro, +"..m.gems.." gemas")
end
function A.BuyEgg(p,isl)
	local d=Data.get(p);local def=I.ById[isl]
	if not def or not d.unlocked[isl] then return fail("Ilha inválida") end
	if #d.eggs>=Balance.IncubatorSlots then return fail("Chocadeira cheia") end
	local cost=80*def.idx;if d.gold<cost then return fail("Precisa de "..cost.." ouro") end
	local pool,tot={},0
	for _,c in C.List do if c.island==isl and c.rar<=3 then local w=1/(c.rar*c.rar);table.insert(pool,{c,w});tot+=w end end
	if #pool==0 then return fail("Não há ovos comerciais desta região nesta versão") end
 local r=rng:NextNumber()*tot;local pick=pool[1][1]
	for _,e in pool do r-=e[2];if r<=0 then pick=e[1];break end end
	d.gold-=cost;table.insert(d.eggs,{id=pick.id,ready=os.time()+Balance.IncubationBase*pick.rar*pick.rar});return ok(p,"Ovo de "..def.name.." comprado!")
end
function A.Speed(p,i)
	local d=Data.get(p);local e=typeof(i)=="number" and d.eggs[i]
	if not e then return fail("Ovo inválido") end
	local left=e.ready-os.time();if left<=0 then return fail("Já pode chocar") end
	local cost=math.max(1,math.ceil(left/30));if d.gems<cost then return fail("Precisa de "..cost.." gemas") end
	d.gems-=cost;e.ready=os.time();return ok(p,"Ovo acelerado!")
end
function A.Daily(p)
	local d=Data.get(p);local today=os.time()//86400
	if d.dailyDay>=today then return fail("Volte amanhã!") end
	d.streak=(d.dailyDay==today-1) and d.streak+1 or 1;d.dailyDay=today
	local gold=50*math.min(d.streak,7);local gem=d.streak%3==0 and 1 or 0
	d.gold+=gold;d.gems+=gem;return ok(p,"Dia "..d.streak.." seguido: +"..gold.." ouro"..(gem>0 and " +1 gema" or ""))
end
function A.Buy(p,key)
	if typeof(key)~="string" then return fail("Item inválido") end
	local s,m=Mon.buy(p,key);if not s then return fail(m) end;return ok(p,"Abrindo a compra...")
end
local Players=game:GetService("Players")
local invitations={}
local lastDuel=setmetatable({},{__mode="k"})
local function sim(ca,la,cb,lb)
	local m1,m2=ca.hp*lvMul(la),cb.hp*lvMul(lb);local hp1,hp2,log=m1,m2,{}
	for _=1,40 do
		local x=ca.atk*lvMul(la)*E.mult(ca.el,cb.el);hp2-=x
		table.insert(log,{me=true,dmg=math.floor(x),hp=math.max(0,hp2)/m2,mult=E.mult(ca.el,cb.el)});if hp2<=0 then break end
		x=cb.atk*lvMul(lb)*E.mult(cb.el,ca.el);hp1-=x
		table.insert(log,{me=false,dmg=math.floor(x),hp=math.max(0,hp1)/m1,mult=E.mult(cb.el,ca.el)});if hp1<=0 then break end
	end
	return log,hp2<=0
end
local function best(d) local b,bs;for _,cr in d.creatures do local sc=C.ById[cr.id].rar*10+cr.lv;if not bs or sc>bs then b,bs=cr,sc end end;return b end
-- Duelo online: sua melhor fera contra a melhor fera de outro jogador do servidor (o rival não perde nada).
function A.Duel(p,tid)
	local t=typeof(tid)=="number" and Players:GetPlayerByUserId(tid);local d=Data.get(p);local td=t and Data.get(t)
	if not td or t==p then return fail("Jogador indisponível") end
	local key=tostring(p.UserId)..":"..tostring(t.UserId)
 local reverse=tostring(t.UserId)..":"..tostring(p.UserId)
 if not invitations[reverse] or invitations[reverse]<os.clock() then
  invitations[key]=os.clock()+30
  return ok(p,"Convite enviado. O rival deve tocar Desafiar no seu nome em até 30s para aceitar.")
 end
 invitations[reverse]=nil;invitations[key]=nil
 if lastDuel[p] and os.clock()-lastDuel[p]<30 then return fail("Suas feras descansam: "..math.ceil(30-(os.clock()-lastDuel[p])).."s") end
	lastDuel[p]=os.clock()
	local a,b=best(d),best(td);local log,win=sim(C.ById[a.id],a.lv,C.ById[b.id],b.lv)
	local info={log=log,me={id=a.id,lv=a.lv},foe={id=b.id,lv=b.lv},win=win}
	if not win then local r=ok(p,"Derrota para "..t.DisplayName..". Treine e tente de novo!");r.battle=info;return r end
	local gold=40+5*b.lv;d.gold+=gold;d.trophies+=1;bump(d,"duelwin")
	local r=ok(p,"Vitória contra "..t.DisplayName.."! +"..gold.." ouro, +1 troféu");r.battle=info;return r
end
function A.Tut(p) Data.get(p).tut=true;return ok(p,"Tutorial concluído!") end
return G

end)()
local a,b={UserId=1},{UserId=2}
local function profile()
 return {gold=2000,gems=5,seals=5,sealStock={},playerLevel=50,playerXp=0,creatures={u1={id="cinzelo",lv=1},u2={id="bolhinho",lv=1}},sanctuary={Brasa={slot=1,level=1}},habitat={Brasa={"u1"}},unlocked={Brasa=true,Recife=true},materials={Natureza=1,Terra=1,Sombra=2},pass={},last=os.time(),stats={},storyClaimed={}}
end
profiles[a]=profile();profiles[b]=profile();local d=profiles[a]
assert(G.Actions.BuildHabitat(a,"Recife",2).ok and d.sanctuary.Recife.slot==2)
assert(profiles[b].gold==2000 and not profiles[b].sanctuary.Recife)
assert(not G.Actions.MoveHabitat(a,"Brasa",2).ok)
assert(G.Actions.MoveHabitat(a,"Brasa",7).ok and d.sanctuary.Brasa.slot==7)
assert(G.Actions.UpgradeHabitat(a,"Brasa").ok and d.sanctuary.Brasa.level==2)
assert(not G.Actions.RemoveHabitat(a,"Brasa").ok)
assert(not G.Actions.Place(a,"u1","Recife").ok)
assert(G.Actions.Place(a,"u2","Recife").ok)
assert(not G.Actions.Place(a,"foreign","Recife").ok)
assert(G.Actions.Companion(a,"u1").ok and d.companion=="u1")
assert(G.Actions.Companion(a,"u1").ok and d.companion==nil)
assert(not G.Actions.Companion(a,"foreign").ok)
local old=d.gold
assert(G.Actions.CraftSeal(a,"Basic").ok and d.gold==old-25)
for _,kind in {"Reinforced","Elemental","Rare","Ancient"} do assert(G.Actions.CraftSeal(a,kind).ok and d.sealStock[kind]==1) end
old=d.gold;assert(not G.Actions.CraftSeal(a,"Elemental").ok and d.gold==old)
assert(not G.Actions.CraftSeal(a,"invented").ok)
assert(not G.Actions.Travel(a,"Pantano").ok)
d.stats.capture=1;assert(G.Actions.ClaimStory(a,"arrival").ok)
old=d.gold;assert(not G.Actions.ClaimStory(a,"arrival").ok and d.gold==old)
print("PASS: ações reais em serviços simulados: construir, mover, melhorar, capacidade, propriedade, companheiro, cinco selos e capítulos sem duplicação")
