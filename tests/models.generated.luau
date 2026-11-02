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
local Designs=(function()
--!nonstrict
-- Identidade por espécie, sem alterar IDs persistidos ou regras econômicas.
local Designs={
 fenix={crest="solar",body="bird",pattern=5},
 cinzelo={crest="embers",body="round",pattern=1},magmarau={crest="horns",body="long",pattern=2},
 fenixfuligem={crest="plume",body="bird",pattern=3},vulcanodrago={crest="horns",body="dragon",pattern=4},
 bolhinho={crest="bubbles",body="round",pattern=2},marilisco={crest="fins",body="serpent",pattern=3},
 carangueperola={crest="claws",body="insect",pattern=4},abissauro={crest="fins",body="dragon",pattern=1},
 brotinho={crest="leaves",body="round",pattern=3},folhuco={crest="ears",body="long",pattern=4},
 aracnoflora={crest="leaves",body="insect",pattern=1},ancestravore={crest="antlers",body="long",pattern=2},
 graozinho={crest="crystals",body="round",pattern=4},escorpiodra={crest="stinger",body="insect",pattern=1},
 esfingeolito={crest="crown",body="long",pattern=2},colossodune={crest="obelisk",body="golem",pattern=3},
 penugem={crest="plume",body="bird",pattern=1},ventanil={crest="fins",body="bird",pattern=2},
 trovoraptor={crest="crystals",body="dragon",pattern=3},aeronimbo={crest="bubbles",body="serpent",pattern=4},
 lodinho={crest="mist",body="round",pattern=2},caudalume={crest="lantern",body="serpent",pattern=4},
 vagalumorte={crest="lantern",body="insect",pattern=3},reinevoento={crest="crown",body="spirit",pattern=1},
 vaporino={crest="mist",body="serpent",pattern=3},magmaterra={crest="crystals",body="long",pattern=1},
 tempestalia={crest="crystals",body="bird",pattern=4},nevoamusgo={crest="antlers",body="spirit",pattern=2},
 cinzavento={crest="plume",body="dragon",pattern=2},
}

-- Proporções desenhadas por espécie: corpo, cabeça, focinho, motivo e temperamento.
local Anatomy={
 cinzelo={.95,.8,.9,1.15,"coal"},magmarau={1.2,.9,1.15,.9,"tusk"},fenixfuligem={.8,1.1,1,.8,"feathers"},vulcanodrago={1.25,1.1,1.25,.9,"magma"},
 bolhinho={1.1,.8,1.1,1.2,"gills"},marilisco={.8,.8,1.3,.85,"sail"},carangueperola={1.35,.65,1.15,.7,"pearl"},abissauro={1.1,.85,1.5,.85,"angler"},
 brotinho={.8,1.1,.85,1.2,"sprout"},folhuco={.85,1,1.2,1,"leafears"},aracnoflora={1.1,.65,1.2,.75,"flower"},ancestravore={1.35,1.2,1.25,.9,"tree"},
 graozinho={1.05,.75,.9,1.1,"geode"},escorpiodra={.85,.6,1.4,.75,"carapace"},esfingeolito={1,1,1.4,1,"headdress"},colossodune={1.2,1.3,1.1,.7,"runes"},
 penugem={.85,.9,.85,1.25,"tuft"},ventanil={.75,1.15,1.2,.85,"ribbons"},trovoraptor={.85,1.1,1.2,.8,"lightning"},aeronimbo={1.1,.9,1.2,1,"cloud"},
 lodinho={1.2,.65,1.15,1.2,"moss"},caudalume={.7,.85,1.5,.75,"lantern"},vagalumorte={.9,.6,1.1,.8,"firefly"},reinevoento={1.1,1.4,1,.9,"mantle"},
 vaporino={1.15,.85,1.1,1.1,"steam"},magmaterra={1.3,.85,1.2,.85,"plates"},tempestalia={.9,1.2,1.1,.8,"storm"},nevoamusgo={.9,1.1,1.2,1.1,"lichen"},cinzavento={.9,1.15,1.4,.8,"ashwings"},fenix={1.05,1.2,1.15,.8,"solar"},
}
for id,a in Anatomy do
 local d=Designs[id];d.width=a[1];d.height=a[2];d.length=a[3];d.head=a[4];d.motif=a[5]
end
return Designs

end)()
local Features=(function()
--!nonstrict
-- Pequenos conjuntos anatômicos, em vez de emissores, luzes ou acessórios externos.
local F={};local V=Vector3.new;local CF=CFrame.Angles;local T=Enum.PartType
function F.add(p,def,design,stage,y,z,col,dark,accent)
 local motif=design.motif
 local function ball(name,size,pos,color,glow) return p(name,T.Ball,size,pos,color,nil,glow) end
 if motif=="coal" or motif=="geode" or motif=="plates" or motif=="magma" then
  for i=1,stage+1 do p("Plate",T.Block,V(1,.35,1.1),V(0,2+i*.35,-i*.7),dark,CF(.15,0,.25*(i%2)),false) end
  ball("Core",V(.6,.8,.3),V(0,2,1.5),accent,true)
 elseif motif=="gills" or motif=="sail" or motif=="angler" then
  for _,side in {-1,1} do for i=1,2 do
   p("Fin",T.Ball,V(.25,1.1,.9),V(side*1.3,y+(i-1)*.45,z-.5),accent,CF(0,0,side*.5))
  end end
  if motif=="angler" then ball("Lure",V(.5,.5,.5),V(0,y+1.8,z+1),accent,true) end
 elseif motif=="sprout" or motif=="flower" or motif=="leafears" or motif=="lichen" then
  for i=1,(stage==1 and 3 or 5) do
   local a=i*math.pi*2/(stage==1 and 3 or 5)
   p("Petal",T.Ball,V(.6,1.2,.35),V(math.cos(a)*.8,y+1+math.sin(a)*.6,z-.4),accent,CF(0,0,-a))
  end
  ball("Bud",V(.6,.6,.6),V(0,y+1,z-.4),col)
 elseif motif=="tree" or motif=="headdress" or motif=="mantle" then
  for _,side in {-1,1} do
   p("Mantle",T.Ball,V(.6,stage==3 and 2.6 or 1.4,1.4),V(side*1.15,y-.2,z-.6),accent,CF(0,0,side*.25))
   if stage>=2 then p("Branch",T.Block,V(1.1,.3,.3),V(side*1.5,y+1.5,z),dark,CF(0,0,side*.3)) end
  end
 elseif motif=="pearl" or motif=="carapace" or motif=="firefly" then
  local shell=ball("Shell",V(3.2,.9,3.5),V(0,3,0),dark)
  if motif=="pearl" then ball("Pearl",V(1,1,1),V(0,3.65,0),Color3.fromRGB(239,226,240))
  elseif motif=="firefly" then ball("Lantern",V(1.3,1,1.2),V(0,2,-1.6),accent,true) end
 elseif motif=="tusk" or motif=="runes" then
  for _,side in {-1,1} do
   p("Tusk",T.Block,V(.3,stage==3 and 1.7 or .7,.3),V(side*.9,y-.1,z+1),accent,CF(-.3,0,side*.2))
  end
  if motif=="runes" then ball("Rune",V(.4,1.4,.2),V(0,3.8,1.7),accent,true) end
 elseif motif=="cloud" or motif=="steam" or motif=="moss" then
  for i=1,stage+1 do ball("Cloud",V(1,.6,1),V((i-2)*.6,y+.8,z-.6),accent,motif=="steam") end
 elseif motif=="lantern" then
  p("Antenna",T.Block,V(.15,1.3,.15),V(0,y+1,z+.2),dark,CF(.4,0,0));ball("Lantern",V(.7,.7,.7),V(0,y+1.8,z+.6),accent,true)
 elseif motif=="solar" then
  -- Halo e cauda solar próprios já são gerados pelo ModelFactory.
 else
  -- Feathers, ribbons, lightning, ashwings, tuft e storm têm penas distintas.
  for _,side in {-1,1} do for i=1,stage+1 do
   p("Feather",T.Ball,V(.35,1.2+i*.35,.4),V(side*(.5+i*.35),y+.6,z-i*.4),i%2==0 and accent or dark,CF(.2,0,side*.55),motif=="lightning" or motif=="storm")
  end end
 end
end
return F

end)()
local Factory=(function()
--!nonstrict
local C=C
local E=E
local Designs=Designs
local V,CF,T=Vector3.new,CFrame.new,Enum.PartType
local function build(def,lv,options)
 options=options or {}
 local design=Designs[def.id];assert(design,"Espécie sem design: "..def.id)
 local stage=C.stage(lv,def.id);local scale=({.7,1,1.4})[stage]
 local m=Instance.new("Model");m.Name=def.name;m.ModelStreamingMode=Enum.ModelStreamingMode.Atomic
 m:SetAttribute("Family",def.shape);m:SetAttribute("Species",def.id);m:SetAttribute("Stage",stage)
 local col=E.Color[def.el];local dark=col:Lerp(Color3.new(0,0,0),.38)
 local accent=def.hybrid and E.Color[def.hybrid[2]] or col:Lerp(Color3.new(1,1,1),.55)
 local function p(name,shape,size,pos,color,rotation,neon)
  local x=Instance.new("Part");x.Name=name;x.Shape=shape;x.Size=size*scale
  x.Anchored=true;x.CanCollide=false;x.CanTouch=false;x.CanQuery=false;x.CastShadow=not neon
  x.Color=color;x.Material=neon and Enum.Material.Neon or Enum.Material.SmoothPlastic
  x.CFrame=CF(pos*scale)*(rotation or CFrame.identity);x.Parent=m;return x
 end
 local body=design.body
 local torsoSize=body=="long" and V(2.6,2.5,4.4) or body=="bird" and V(2.3,3,2.7) or body=="serpent" and V(2.5,2.2,2.8) or body=="golem" and V(4.5,4,2.8) or V(3.2,3,3)
 torsoSize*=V(design.width,design.height,design.length)
 local y=(body=="golem" and 4 or 2.5)*design.height
 local torso=p("Torso",body=="golem" and T.Block or T.Ball,torsoSize,V(0,y,0),col)
 m.PrimaryPart=torso
 local headY=body=="golem" and 6.4 or body=="long" and 3.1 or 3.7
 local headZ=body=="long" and 2.1 or 1.1
 headY*=design.height;headZ*=design.length
 local headScale=design.head*(stage==1 and 1.12 or stage==3 and .9 or 1)
 p("Head",T.Ball,V(2.3,2.1,2)*headScale,V(0,headY,headZ),col)
 if body=="long" or body=="dragon" then p("Muzzle",T.Ball,V(1.5,.8,1.4)*headScale,V(0,headY-.4,headZ+1.1),accent) end
 for _,side in {-1,1} do
  p("Eye",T.Ball,V(.68,.8,.4),V(side*.6*headScale,headY+.15*headScale,headZ+.88*headScale),Color3.new(1,1,1))
  p("Pupil",T.Ball,V(.3,.43,.18),V(side*.6*headScale,headY+.15*headScale,headZ+1.08*headScale),dark)
  p("EyeGlint",T.Ball,V(.1,.12,.1),V((side*.6-.06)*headScale,headY+.27*headScale,headZ+1.16*headScale),Color3.new(1,1,1))
 end
 p("Smile",T.Ball,V(.6,.12,.15),V(0,headY-.48*headScale,headZ+.98*headScale),dark)
 if body=="long" or body=="dragon" or body=="golem" then
  for _,side in {-1,1} do for _,z in {-1.25,1.25} do
   p("Foot",T.Ball,V(body=="golem" and 1.7 or .95,1.3,1.3),V(side*(body=="golem" and 1.6 or 1),.8,z),dark)
  end end
 end
 if body=="bird" or body=="dragon" then
  for _,side in {-1,1} do
   for feather=1,(stage==1 and 2 or stage==2 and 3 or 4) do
    p("Wing",T.Ball,V(.55,1.1,2.6+feather*.25),V(side*(1.4+feather*.4),y+.6,-feather*.25),feather%2==0 and accent or dark,CFrame.Angles(0,side*.3,side*.25))
   end
   p("Foot",T.Ball,V(.6,.5,1),V(side*.65,.7,.7),accent)
  end
  if body=="bird" then p("Beak",T.Ball,V(.8,.5,1.2),V(0,headY-.2,headZ+1.15),Color3.fromRGB(255,197,77)) end
 end
 if body=="serpent" or body=="dragon" then
  for i=1,4 do local n=1-i*.17
   p("Tail",T.Ball,V(2*n,2*n,2.4*n),V(math.sin(i*.8)*.7,1.3-i*.16,-i*1.25),i%2==0 and accent or col)
  end
 end
 if body=="insect" then
  for _,side in {-1,1} do for i=1,4 do
   p("Leg",T.Block,V(.25,1.6,1.2),V(side*1.9,1.2,(i-2.5)*.8),dark,CFrame.Angles(0,0,side*.8))
  end end
 end
 if body=="spirit" then
  torso.Transparency=.15
  for i=1,3 do p("Wisp",T.Ball,V(1.8-i*.3,1.2,1.8-i*.3),V(math.sin(i)*.4,1.7-i*.5,-i*.5),accent,nil,true) end
 end
 -- Marcas distintas por espécie; mais detalhes nas evoluções, sem emissores contínuos.
 for i=1,math.min(4,design.pattern+stage) do
  local angle=i*2.4
  p("Mark",T.Ball,V(.35,.4,.18),V(math.cos(angle)*1.35,y+math.sin(angle)*.7,1.15),accent,nil,stage==3)
 end
 -- Asas radiantes, cauda tripla e halo: a lendária não é recoloração de Fuligem.
 if def.id=="fenix" then
  local gold=Color3.fromRGB(255,206,78)
  for _,side in {-1,1} do for feather=1,5 do
   p("Wing",T.Ball,V(.5,1.1,4.2+feather*.25),V(side*(2+feather*.45),3+feather*.2,-.8),feather%2==0 and gold or col,CFrame.Angles(0,side*.3,side*.35),feather==5)
  end end
  for i=-1,1 do p("Tail",T.Ball,V(.55,.55,5.5),V(i*.8,1.5,-3.7),gold,CFrame.Angles(-.25,i*.18,0),true) end
  for i=1,8 do local a=i*math.pi/4
   p("SolarHalo",T.Ball,V(.25,.25,.25),V(math.cos(a)*1.5,headY+1.3+math.sin(a)*1.5,headZ-.5),gold,nil,true)
  end
 end
 Features.add(p,def,design,stage,headY,headZ,col,dark,accent)
 local crest=design.crest
 for i=1,stage+1 do
  local x=(i-(stage+2)/2)*.65
  if crest=="leaves" or crest=="plume" or crest=="fins" then
   p("Crest",T.Ball,V(.45,1.5+i*.12,.5),V(x,headY+1.3,headZ-.1),accent,CFrame.Angles(0,0,-x*.35))
  elseif crest=="bubbles" or crest=="mist" or crest=="embers" then
   p("Crest",T.Ball,V(.5,.7,.5),V(x,headY+1.4+i*.15,headZ),accent,nil,true)
  else
   p("Crest",T.Block,V(.35,crest=="obelisk" and 2.5 or 1.2,.4),V(x,headY+1.2,headZ),accent,CFrame.Angles(0,0,-x*.3),stage==3)
  end
 end
 if crest=="claws" then for _,side in {-1,1} do p("Claw",T.Ball,V(1.1,1.2,.8),V(side*2.4,2,2),accent) end end
 if crest=="stinger" then p("Stinger",T.Ball,V(.7,2,.7),V(0,3,-2),accent,CFrame.Angles(.5,0,0)) end
 if crest=="antlers" then for _,side in {-1,1} do p("Antler",T.Block,V(1.3,.3,.3),V(side*1.1,headY+1.6,headZ),accent) end end
 if not options.preview then
 local tag=Instance.new("BillboardGui");tag.Size=UDim2.fromOffset(180,32);tag.StudsOffset=V(0,(headY-y+3)*scale,0);tag.MaxDistance=65;tag.AlwaysOnTop=false;tag.Parent=torso
 local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Font=Enum.Font.GothamBold;text.TextSize=14;text.TextColor3=Color3.new(1,1,1);text.TextStrokeTransparency=.4;text.Text=def.name.." • Nv."..lv;text.Parent=tag
 -- Coordenadas das Parts são locais ao modelo; o pivot é a origem do conjunto.
 end
 m.WorldPivot=CFrame.identity
 return m
end
return {build=build}

end)()
local total,maxParts=0,0
for _,def in C.List do
 for _,lv in {1,7,15} do
  local m=Factory.build(def,lv,{preview=true});local count=0
  assert(m.PrimaryPart)
  for _,part in m:GetDescendants() do if part:IsA("BasePart") then
   count+=1
   assert(part.Anchored and not part.CanCollide and not part.CanTouch)
   assert(part.Size.X>0 and part.Size.Y>0 and part.Size.Z>0)
  end end
  assert(count<=80,def.id.." excedeu orçamento: "..count)
  maxParts=math.max(maxParts,count);total+=1;m:Destroy()
 end
end
print("PASS: "..total.." modelos em stub estrutural (sem render/física); máximo "..maxParts.." partes")
