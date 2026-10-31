--!nonstrict
local RS=game:GetService("ReplicatedStorage")
local C=require(RS.Shared.Creatures);local E=require(RS.Shared.Elements);local Balance=require(RS.Shared.Economy)
local Preview=require(script.Parent.CollectionUI)
local N={}
local function frame(parent,height)
 local f=Instance.new("Frame");f.Size=UDim2.new(1,-12,0,height);f.BackgroundColor3=Color3.fromRGB(40,40,73);f.Parent=parent
 Instance.new("UICorner",f).CornerRadius=UDim.new(0,14);return f
end
local function text(parent,name,value,pos,size)
 local t=Instance.new("TextLabel");t.Name=name;t.Text=value;t.Position=pos;t.Size=size;t.BackgroundTransparency=1;t.TextColor3=Color3.new(1,1,1);t.TextSize=14;t.TextWrapped=true;t.Font=Enum.Font.GothamBold;t.Parent=parent;return t
end
local function button(parent,name,value,x,callback)
 local b=Instance.new("TextButton");b.Name=name;b.Text=value;b.Position=UDim2.fromScale(x,.72);b.Size=UDim2.fromScale(.31,.24);b.BackgroundColor3=Color3.fromRGB(245,186,73);b.TextColor3=Color3.fromRGB(25,25,50);b.Font=Enum.Font.GothamBold;b.TextSize=14;b.Parent=parent;b.Activated:Connect(callback);Instance.new("UICorner",b);return b
end
local function enabled(b,yes)
 b.Active=yes;b.Selectable=yes;b.AutoButtonColor=yes;b.BackgroundTransparency=yes and 0 or .65
end
function N.egg(parent,def,left,hatch,speed)
 local f=frame(parent,154);f.Name="IncubatingEgg";f:SetAttribute("ReadyClock",os.clock()+left)
 local v=Instance.new("ViewportFrame");v.Size=UDim2.fromScale(.3,1);v.BackgroundTransparency=1;v.Ambient=Color3.fromRGB(200,200,200);v.Parent=f
 local egg=Instance.new("Part");egg.Shape=Enum.PartType.Ball;egg.Size=Vector3.new(3,4,3);egg.Anchored=true;egg.CanCollide=false;egg.Color=E.Color[def.el];egg.Material=Enum.Material.SmoothPlastic;egg.Parent=v
 local gem=Instance.new("Part");gem.Shape=Enum.PartType.Ball;gem.Size=Vector3.new(.8,1,.5);gem.Position=Vector3.new(0,.3,1.4);gem.Anchored=true;gem.Color=def.hybrid and E.Color[def.hybrid[2]] or Color3.fromRGB(255,237,174);gem.Parent=v
 local camera=Instance.new("Camera");camera.CFrame=CFrame.lookAt(Vector3.new(4,2,9),Vector3.zero);camera.Parent=v;v.CurrentCamera=camera
 text(f,"Element","Ovo de "..def.el,UDim2.fromScale(.32,.04),UDim2.fromScale(.65,.22))
 text(f,"Countdown","",UDim2.fromScale(.32,.28),UDim2.fromScale(.65,.36))
 button(f,"Hatch","Chocar",.33,function() if os.clock()>=f:GetAttribute("ReadyClock") then hatch() end end)
 button(f,"Speed","Acelerar",.66,speed)
 N.tick(parent)
 return f
end
function N.tick(parent)
 for _,f in parent:GetChildren() do
  if f.Name~="IncubatingEgg" then continue end
  local left=math.max(0,math.ceil(f:GetAttribute("ReadyClock")-os.clock()))
  f.Countdown.Text=left==0 and "Pronto para eclodir!" or ("Incubando: "..left.."s\nAcelerar: "..math.max(1,math.ceil(left/30)).." gemas")
  enabled(f.Hatch,left==0);enabled(f.Speed,left>0)
 end
end
function N.parents(parent,a,b,outcomes,available,breed)
 local f=frame(parent,360);f.Name="BreedingPreview"
 local names={}
 for index,def in {a,b} do
  local holder=Instance.new("Frame");holder.Size=UDim2.fromScale(.5,.52);holder.Position=UDim2.fromScale((index-1)*.5,0);holder.BackgroundTransparency=1;holder.Parent=f
  Preview.preview(holder,def,1,false)
  text(holder,"Name",def.name.." • "..def.el,UDim2.fromScale(0,.65),UDim2.fromScale(1,.3))
 end
 for _,def in C.List do local chance=outcomes[def.id]
  if chance then table.insert(names,def.name.." "..string.format("%.1f%%",chance*100)) end
 end
 text(f,"Outcomes",table.concat(names," • "),UDim2.fromScale(.03,.5),UDim2.fromScale(.94,.2)).TextSize=12
 text(f,"Cost","Custo: "..Balance.BreedCost.." ouro • Incubação: 30–480s\n"..(available and "Chocadeira disponível" or "Precisa de ouro e vaga na chocadeira"),UDim2.fromScale(.03,.7),UDim2.fromScale(.94,.14))
 local start=button(f,"Breed","Cruzar",.33,breed);start.Position=UDim2.fromScale(.15,.86);start.Size=UDim2.fromScale(.7,.12);enabled(start,available)
 return f
end
return N
