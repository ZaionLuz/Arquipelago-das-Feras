--!nonstrict
local C=require(script.Parent.Creatures)
local E=require(script.Parent.Elements)
local Designs=require(script.Parent.CreatureDesigns)
local V,CF,T=Vector3.new,CFrame.new,Enum.PartType
local function build(def,lv)
 local design=Designs[def.id];assert(design,"Espécie sem design: "..def.id)
 local stage=C.stage(lv,def.id);local scale=({.7,1,1.4})[stage]
 local m=Instance.new("Model");m.Name=def.name
 m:SetAttribute("Family",def.shape);m:SetAttribute("Species",def.id);m:SetAttribute("Stage",stage)
 local col=E.Color[def.el];local dark=col:Lerp(Color3.new(0,0,0),.38)
 local accent=def.hybrid and E.Color[def.hybrid[2]] or col:Lerp(Color3.new(1,1,1),.55)
 local function p(name,shape,size,pos,color,rotation,neon)
  local x=Instance.new("Part");x.Name=name;x.Shape=shape;x.Size=size*scale
  x.Anchored=true;x.CanCollide=false;x.CanTouch=false;x.CanQuery=false
  x.Color=color;x.Material=neon and Enum.Material.Neon or Enum.Material.SmoothPlastic
  x.CFrame=CF(pos*scale)*(rotation or CFrame.identity);x.Parent=m;return x
 end
 local body=design.body
 local torsoSize=body=="long" and V(2.6,2.5,4.4) or body=="bird" and V(2.3,3,2.7) or body=="serpent" and V(2.5,2.2,2.8) or body=="golem" and V(4.5,4,2.8) or V(3.2,3,3)
 local y=body=="golem" and 4 or 2.5
 local torso=p("Torso",body=="golem" and T.Block or T.Ball,torsoSize,V(0,y,0),col)
 m.PrimaryPart=torso
 local headY=body=="golem" and 6.4 or body=="long" and 3.1 or 3.7
 local headZ=body=="long" and 2.1 or 1.1
 p("Head",T.Ball,V(2.3,2.1,2),V(0,headY,headZ),col)
 for _,side in {-1,1} do
  p("Eye",T.Ball,V(.68,.8,.4),V(side*.6,headY+.15,headZ+.88),Color3.new(1,1,1))
  p("Pupil",T.Ball,V(.3,.43,.18),V(side*.6,headY+.15,headZ+1.08),dark)
  p("EyeGlint",T.Ball,V(.1,.12,.1),V(side*.6-.06,headY+.27,headZ+1.16),Color3.new(1,1,1))
 end
 p("Smile",T.Ball,V(.6,.12,.15),V(0,headY-.48,headZ+.98),dark)
 if body=="long" or body=="dragon" or body=="golem" then
  for _,side in {-1,1} do for _,z in {-1.25,1.25} do
   p("Foot",T.Ball,V(body=="golem" and 1.7 or .95,1.3,1.3),V(side*(body=="golem" and 1.6 or 1),.8,z),dark)
  end end
 end
 if body=="bird" or body=="dragon" then
  for _,side in {-1,1} do
   for feather=1,3 do
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
 for i=1,design.pattern+stage do
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
 local tag=Instance.new("BillboardGui");tag.Size=UDim2.fromOffset(180,32);tag.StudsOffset=V(0,(headY-y+3)*scale,0);tag.MaxDistance=65;tag.AlwaysOnTop=false;tag.Parent=torso
 local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.Font=Enum.Font.GothamBold;text.TextSize=14;text.TextColor3=Color3.new(1,1,1);text.TextStrokeTransparency=.4;text.Text=def.name.." • Nv."..lv;text.Parent=tag
 -- Coordenadas das Parts são locais ao modelo; o pivot é a origem do conjunto.
 m.WorldPivot=CFrame.identity
 return m
end
return {build=build}
