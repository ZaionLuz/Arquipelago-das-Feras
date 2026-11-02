--!nonstrict
local RS=game:GetService("ReplicatedStorage")
local C=require(RS.Shared.Creatures);local E=require(RS.Shared.Elements)
local MF=require(RS.Shared.ModelFactory)
local UI={}
local function label(parent,text,pos,size)
 local t=Instance.new("TextLabel");t.BackgroundTransparency=1;t.Position=pos;t.Size=size;t.Text=text;t.TextWrapped=true;t.Font=Enum.Font.GothamBold;t.TextSize=16;t.TextColor3=Color3.new(1,1,1);t.Parent=parent;return t
end
function UI.preview(parent,def,lv,unknown)
 local v=Instance.new("ViewportFrame");v.Size=UDim2.fromScale(1,.65);v.BackgroundTransparency=1;v.Ambient=Color3.fromRGB(185,185,200);v.LightColor=Color3.new(1,1,1);v.Parent=parent
 local world=Instance.new("WorldModel");world.Parent=v
 local model=MF.build(def,lv,{preview=true})
 for _,obj in model:GetDescendants() do
  if obj:IsA("BillboardGui") then obj:Destroy()
  elseif unknown and obj:IsA("BasePart") then obj.Color=Color3.fromRGB(25,25,40);obj.Material=Enum.Material.SmoothPlastic end
 end
 model.Parent=world
 local cf,size=model:GetBoundingBox();local camera=Instance.new("Camera");camera.FieldOfView=40
 local distance=math.max(size.X,size.Y,size.Z)*2
 camera.CFrame=CFrame.lookAt(cf.Position+Vector3.new(distance*.55,distance*.25,distance),cf.Position)
 camera.Parent=v;v.CurrentCamera=camera
 return v
end
function UI.card(parent,def,lv,known,order)
 local card=Instance.new("Frame");card.Name="CollectionCard";card.LayoutOrder=order;card.Size=UDim2.new(1,-12,0,190);card.BackgroundColor3=known and E.Color[def.el]:Lerp(Color3.fromRGB(20,20,40),.65) or Color3.fromRGB(35,35,50);card.Parent=parent
 local corner=Instance.new("UICorner");corner.CornerRadius=UDim.new(0,12);corner.Parent=card
 local preview
 local function visible()
  if not card.Parent then return end
  local y=card.AbsolutePosition.Y;local top=parent.AbsolutePosition.Y
  local shown=y+card.AbsoluteSize.Y>=top and y<=top+parent.AbsoluteSize.Y
  if shown and not preview then preview=UI.preview(card,def,lv,not known)
  elseif not shown and preview then preview:Destroy();preview=nil end
 end
 local connection=parent:GetPropertyChangedSignal("CanvasPosition"):Connect(visible)
 local resize=parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(visible)
 card.Destroying:Connect(function() connection:Disconnect();resize:Disconnect() end)
 task.defer(visible)
 label(card,known and def.name or "Espécie desconhecida",UDim2.fromScale(0,.65),UDim2.fromScale(1,.15))
 label(card,known and (def.el.." • "..C.Rarity[def.rar].." • Nv."..lv) or "Descubra novos ovos",UDim2.fromScale(0,.8),UDim2.fromScale(1,.18)).TextSize=12
 return card
end
function UI.discovery(gui,def,lv,evolved)
 local overlay=Instance.new("Frame");overlay.Size=UDim2.fromScale(1,1);overlay.BackgroundColor3=Color3.fromRGB(12,10,30);overlay.BackgroundTransparency=.08;overlay.ZIndex=30;overlay.Parent=gui
 local panel=Instance.new("Frame");panel.Size=UDim2.fromScale(.8,.8);panel.Position=UDim2.fromScale(.1,.1);panel.BackgroundColor3=E.Color[def.el]:Lerp(Color3.fromRGB(20,20,40),.65);panel.Parent=overlay
 Instance.new("UICorner",panel).CornerRadius=UDim.new(0,20)
 UI.preview(panel,def,lv,false)
 label(panel,evolved and "SUA FERA EVOLUIU!" or (def.rar>=3 and "ECLOSÃO EXTRAORDINÁRIA!" or "UMA FERA NASCEU!"),UDim2.fromScale(0,0),UDim2.fromScale(1,.12))
 label(panel,def.name.." • "..C.Rarity[def.rar].." • Nv."..lv,UDim2.fromScale(0,.68),UDim2.fromScale(1,.12))
 label(panel,"Vida "..def.hp.." • Ataque "..def.atk.." • Ouro/min base "..def.gpm.." • Estágio "..C.stage(lv,def.id),UDim2.fromScale(.05,.77),UDim2.fromScale(.9,.06)).TextSize=12
 local close=Instance.new("TextButton");close.Size=UDim2.fromScale(.8,.13);close.Position=UDim2.fromScale(.1,.84);close.Text="Continuar aventura";close.TextSize=18;close.Font=Enum.Font.GothamBold;close.BackgroundColor3=Color3.fromRGB(255,200,90);close.Parent=panel
 close.Selectable=true;close.Activated:Connect(function() overlay:Destroy() end)
 -- Segurança: nunca bloquear permanentemente por menu fechado ou controle perdido.
 task.delay(20,function() if overlay.Parent then overlay:Destroy() end end)
 return overlay
end
return UI
