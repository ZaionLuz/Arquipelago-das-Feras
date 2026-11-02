--!nonstrict
local RS=game:GetService("ReplicatedStorage");local TS=game:GetService("TweenService");local Run=game:GetService("RunService")
local C=require(RS.Shared.Creatures);local MF=require(RS.Shared.ModelFactory);local Elements=require(RS.Shared.Elements)
local Theme=require(script.Parent.UITheme)
local Skills=require(RS.Shared.Skills)
local CAS=game:GetService("ContextActionService")
local UI={}
function UI.start(gui,getOwned,onClose,onOpen)
 local net=RS:WaitForChild("EncounterNet");local state;local busy=false;local presenting=false;local animation=0;local root;local panel;local viewport;local figures;local foeModel;local allyModel;local allyKey;local actions;local roster;local title;local status;local hpMine;local hpFoe;local chance;local resize
 local function destroy()
  CAS:UnbindAction("FerasEncounterMovement")
  if resize then resize:Disconnect();resize=nil end
  if root then root:Destroy();root=nil end
  animation+=1;state=nil;busy=false;presenting=false;onClose()
 end
 gui.Destroying:Once(function() CAS:UnbindAction("FerasEncounterMovement") end)
 local function pose(model,x)
  local cf,size=model:GetBoundingBox();local lift=model:GetPivot().Position.Y-(cf.Position.Y-size.Y/2)
  model:PivotTo(CFrame.new(x,lift,0)*CFrame.Angles(0,x<0 and math.pi/2 or -math.pi/2,0))
 end
 local render;local function request(action,uid)
  if busy or presenting or not state then return end
  busy=true;status.Text="Resolvendo turno..."
  task.spawn(function()
   local ok,response=pcall(net.InvokeServer,net,state.token,state.version,action,uid)
   busy=false
   if not root then return end
   if ok and response then local changed=response.version~=state.version;state=response;render(changed)
   else status.Text="Conexão indisponível. Toque Atualizar para recuperar o encontro." end
  end)
 end
 local function health(label,unit,name)
  label.Text=name.."\n"..(unit and (unit.hp.." / "..unit.maxHp.." PV") or "Escolha uma fera para batalhar")
  label.TextColor3=unit and unit.hp<=unit.maxHp*.3 and Color3.fromRGB(255,166,140) or Theme.Ink
  local track=label:FindFirstChild("Meter")
  if not track then
   track=Instance.new("Frame");track.Name="Meter";track.Position=UDim2.new(.04,0,1,-4);track.Size=UDim2.new(.92,0,0,4);track.BackgroundColor3=Theme.Card;track.Parent=label;Theme.round(track,2)
   local fill=Instance.new("Frame");fill.Name="Fill";fill.Size=UDim2.fromScale(1,1);fill.BorderSizePixel=0;fill.Parent=track;Theme.round(fill,2)
  end
  track.Fill.BackgroundColor3=label.TextColor3==Theme.Ink and Theme.Mint or Color3.fromRGB(235,135,114)
  TS:Create(track.Fill,TweenInfo.new(.3),{Size=UDim2.fromScale(unit and unit.hp/unit.maxHp or 0,1)}):Play()
 end
 render=function(animate)
  if not root then return end
  animation+=1;local job=animation;presenting=false
  title.Text=C.ById[state.foe.id].name.." • Nv."..state.foe.lv.." • "..C.Rarity[C.ById[state.foe.id].rar]
  chance.Text="Captura "..math.floor(state.chance*100).."%  •  Selos "..(state.seals or 0).."  •  Vínculo "..state.bond.."/3"
  local pet=state.active and state.party[state.active]
  health(hpFoe,state.foe,"SELVAGEM");health(hpMine,pet,pet and C.ById[pet.id].name or "SUA EQUIPE")
  if not foeModel or not foeModel.Parent then foeModel=MF.build(C.ById[state.foe.id],state.foe.lv,{preview=true});foeModel.Parent=figures;pose(foeModel,8) end
  local foe=foeModel
  local key=pet and state.active..":"..pet.lv or "none"
  if key~=allyKey then
   if allyModel then allyModel:Destroy();allyModel=nil end
   if pet then allyModel=MF.build(C.ById[pet.id],pet.lv,{preview=true});allyModel.Parent=figures;pose(allyModel,-8) end
   allyKey=key
  end
  local ally=allyModel
  if animate and #state.log>0 then
   presenting=true
   task.spawn(function()
    for _,event in state.log do
     if not root or not foe.Parent or animation~=job then break end
     status.Text=event.text
     local target=event.kind=="hit" and ally or event.kind=="foe" and foe
     if target then
      local start=target:GetPivot();local toward=event.kind=="hit" and 2 or -2
      local pivot=Instance.new("CFrameValue");pivot.Value=start
      local connection=pivot.Changed:Connect(function(v) if target.Parent then target:PivotTo(v) end end)
      local tween=TS:Create(pivot,TweenInfo.new(.15,Enum.EasingStyle.Quad,Enum.EasingDirection.Out,0,true),{Value=start+CFrame.new(toward,0,0).Position});tween:Play();tween.Completed:Wait();connection:Disconnect();pivot:Destroy()
     elseif event.kind=="capture" or event.kind=="miss" or event.kind=="bond" then
      local orb=Instance.new("Part");orb.Shape=Enum.PartType.Ball;orb.Anchored=true;orb.CanCollide=false;orb.Material=Enum.Material.Neon;orb.Color=Theme.Accent;orb.Size=Vector3.one*2;orb.Position=foe:GetPivot().Position;orb.Parent=figures
      TS:Create(orb,TweenInfo.new(.4),{Size=Vector3.one*12,Transparency=1}):Play();task.wait(.4);orb:Destroy()
     end
     task.wait(.25)
    end
    if animation==job then presenting=false end
   end)
  end
  if state.message then status.Text=state.message elseif #state.log==0 then status.Text="Capture diretamente ou escolha uma fera para enfraquecer o encontro." end
  for _,o in actions:GetChildren() do if o:IsA("GuiButton") then o:Destroy() end end
  local buttons=state.status=="active" and {{"Golpe","Strike"},{pet and Skills[C.ById[pet.id].shape].name or "Habilidade","Skill"},{"Proteger + recuperar","Guard"},{"Criar vínculo","Bond"},{"Lançar Selo","Capture"},{"Fugir","Flee"},{"Atualizar","State"}} or {{state.status=="captured" and "Capturou! Continuar" or state.status=="won" and "Vitória! Continuar" or "Voltar à exploração","Close"}}
  for _,entry in buttons do
   local available=true
   if state.status=="active" then
    if entry[2]=="Strike" or entry[2]=="Guard" or entry[2]=="Skill" then available=pet~=nil and pet.hp>0 end
    if entry[2]=="Skill" and pet and state.turn<(pet.nextSkill or 0) then available=false;entry[1]..=" • recarregando" end
    if entry[2]=="Capture" and (state.seals or 0)<1 then available=false end
   end
   local b=Theme.button(actions,entry[1],function() if entry[2]=="Close" then destroy() else request(entry[2]) end end)
   b.Active=available;b.Selectable=available;b.BackgroundTransparency=available and 0 or .6
  end
  for _,o in roster:GetChildren() do if o:IsA("GuiButton") then o:Destroy() end end
  if state.status=="active" then
   local owned=getOwned();local ids={};for uid in owned do table.insert(ids,uid) end;table.sort(ids)
   for _,uid in ids do local creature=owned[uid];local unit=state.party[uid]
    local b=Theme.button(roster,(uid==state.active and "● " or "")..C.ById[creature.id].name.." • "..(unit and unit.hp.." PV" or "Nv."..creature.lv),function() request("Select",uid) end)
    b.Size=UDim2.fromOffset(155,44)
   end
  end
 end
 local function show(data)
  if root then destroy() end;onOpen();state=data;
  CAS:BindActionAtPriority("FerasEncounterMovement",function() return Enum.ContextActionResult.Sink end,false,3000,table.unpack(Enum.PlayerActions:GetEnumItems()))
foeModel=nil;allyModel=nil;allyKey=nil
  root=Instance.new("Frame");root.Size=UDim2.fromScale(1,1);root.BackgroundColor3=Color3.new(0,0,0);root.BackgroundTransparency=.35;root.ZIndex=50;root.Active=true;root.Parent=gui
  panel=Instance.new("Frame");panel.AnchorPoint=Vector2.new(.5,.5);panel.Position=UDim2.fromScale(.5,.5);panel.BackgroundColor3=Theme.Panel;panel.Parent=root;Theme.round(panel,18);Theme.stroke(panel)
  local function layout()
   local size=gui.AbsoluteSize;local w=math.min(860,size.X-16);local h=math.min(720,size.Y-16)
   panel.Size=UDim2.fromOffset(w,h)
  end
  layout();resize=gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
  title=Theme.label(panel,"",18);title.Position=UDim2.new(.03,0,0,10);title.Size=UDim2.new(.94,0,0,32)
  viewport=Instance.new("ViewportFrame");viewport.Position=UDim2.fromScale(.02,.16);viewport.Size=UDim2.fromScale(.96,.36);viewport.BackgroundColor3=Color3.fromRGB(29,54,58);viewport.Ambient=Color3.fromRGB(185,202,210);viewport.LightDirection=Vector3.new(-1,-1,-1);viewport.Parent=panel;Theme.round(viewport)
  local world=Instance.new("WorldModel");world.Parent=viewport;figures=Instance.new("Folder");figures.Parent=world
  local floor=Instance.new("Part");floor.Size=Vector3.new(60,1,30);floor.Position=Vector3.new(0,-.5,0);floor.Anchored=true;floor.Color=Color3.fromRGB(57,87,78);floor.Material=Enum.Material.Grass;floor.Parent=world
  local cam=Instance.new("Camera");cam.FieldOfView=48;cam.CFrame=CFrame.lookAt(Vector3.new(0,14,37),Vector3.new(0,5,0));cam.Parent=viewport;viewport.CurrentCamera=cam
  hpMine=Theme.label(panel,"",14);hpMine.Position=UDim2.fromScale(.03,.07);hpMine.Size=UDim2.fromScale(.44,.09)
  hpFoe=Theme.label(panel,"",14);hpFoe.Position=UDim2.fromScale(.53,.07);hpFoe.Size=UDim2.fromScale(.44,.09)
  chance=Theme.label(panel,"",13);chance.Position=UDim2.fromScale(.03,.52);chance.Size=UDim2.fromScale(.94,.05)
  status=Theme.label(panel,"",14);status.Position=UDim2.fromScale(.03,.57);status.Size=UDim2.fromScale(.94,.08)
  roster=Instance.new("ScrollingFrame");roster.BackgroundTransparency=1;roster.Position=UDim2.fromScale(.03,.65);roster.Size=UDim2.new(.94,0,0,48);roster.AutomaticCanvasSize=Enum.AutomaticSize.X;roster.CanvasSize=UDim2.new();roster.ScrollBarThickness=3;roster.Parent=panel
  local rl=Instance.new("UIListLayout");rl.FillDirection=Enum.FillDirection.Horizontal;rl.Padding=UDim.new(0,8);rl.Parent=roster
  actions=Instance.new("ScrollingFrame");actions.Position=UDim2.new(.03,0,.65,54);actions.Size=UDim2.new(.94,0,.35,-62);actions.BackgroundTransparency=1;actions.CanvasSize=UDim2.new();actions.AutomaticCanvasSize=Enum.AutomaticSize.Y;actions.ScrollBarThickness=3;actions.Parent=panel
  local grid=Instance.new("UIGridLayout");grid.CellSize=UDim2.new(.5,-5,0,44);grid.CellPadding=UDim2.fromOffset(8,8);grid.Parent=actions
  render(false)
 end
 RS:WaitForChild("EncounterNotice").OnClientEvent:Connect(show)
 task.spawn(function()
  local ok,data=pcall(net.InvokeServer,net,"",0,"Resume")
  if ok and data and not root then show(data) end
 end)
end
return UI
