--!nonstrict
local RS=game:GetService("ReplicatedStorage")
local C=require(RS.Shared.Creatures);local I=require(RS.Shared.Islands)
local Preview=require(script.Parent.CollectionUI)
local J={};local selected="cinzelo";local rarity=0;local island=0
local function button(parent,text,callback)
 local b=Instance.new("TextButton");b.Size=UDim2.new(1,-8,0,48);b.BackgroundColor3=Color3.fromRGB(63,66,91);b.TextColor3=Color3.new(1,1,1);b.Font=Enum.Font.GothamBold;b.TextSize=14;b.Text=text;b.Parent=parent;b.Activated:Connect(callback);Instance.new("UICorner",b);return b
end
function J.render(parent,s,render)
 local filters=Instance.new("Frame");filters.Size=UDim2.new(1,-8,0,52);filters.BackgroundTransparency=1;filters.Parent=parent
 local rarityButton=button(filters,"Raridade: "..(C.Rarity[rarity] or "Todas"),function() rarity=(rarity+1)%5;render() end);rarityButton.Size=UDim2.fromScale(.5,1)
 local islandButton=button(filters,"Bioma: "..(island==0 and "Todos" or I.List[island].name),function() island=(island+1)%7;render() end);islandButton.Position=UDim2.fromScale(.5,0);islandButton.Size=UDim2.fromScale(.5,1)
 local def=C.ById[selected];local known=s.discovered[selected];local lv,count=1,0
 for _,cr in s.creatures do if cr.id==selected then count+=1;lv=math.max(lv,cr.lv) end end
 local card=Instance.new("Frame");card.Size=UDim2.new(1,-8,0,300);card.BackgroundColor3=Color3.fromRGB(29,40,54);card.Parent=parent;Instance.new("UICorner",card)
 local view=Preview.preview(card,def,lv,not known)
 -- Uma prévia principal; giro da câmera só enquanto a gaveta estiver visível.
 local connection;local angle=0;local camera=view.CurrentCamera;local center=(camera.CFrame.Position+camera.CFrame.LookVector*(camera.CFrame.Position.Magnitude))
 local model=view:FindFirstChildOfClass("WorldModel"):FindFirstChildOfClass("Model");local box,size=model:GetBoundingBox();local distance=math.max(size.X,size.Y,size.Z)*2
 connection=game:GetService("RunService").Heartbeat:Connect(function(dt)
  if not parent.Visible then return end
  angle+=dt*.3;camera.CFrame=CFrame.lookAt(box.Position+Vector3.new(math.sin(angle)*distance,distance*.3,math.cos(angle)*distance),box.Position)
 end)
 card.Destroying:Connect(function() connection:Disconnect() end)
 local info=Instance.new("TextLabel");info.Size=UDim2.fromScale(.94,.35);info.Position=UDim2.fromScale(.03,.65);info.BackgroundTransparency=1;info.TextColor3=Color3.new(1,1,1);info.Font=Enum.Font.Gotham;info.TextSize=14;info.TextWrapped=true
 info.Text=known and (def.name.." • "..def.el.." • "..C.Rarity[def.rar].."\nHabitat: "..(I.ById[def.island] and I.ById[def.island].name or "Híbrido").." • Exemplares: "..count.."\nNv."..lv.." • Estágio "..C.stage(lv,def.id)..(def.id=="fenix" and " • Estágio 4: futuro" or " • Evolui nos níveis 7 e 15")) or "Espécie não descoberta\nEncontre ovos ou criaturas selvagens para conhecê-la.";info.Parent=card
 for _,entry in C.List do
  if (rarity==0 or entry.rar==rarity) and (island==0 or entry.island==I.List[island].id) then
   local captured=s.discovered[entry.id]
   button(parent,(entry.id==selected and "▸ " or "")..(captured and entry.name.." • "..entry.el or "??? • Espécie desconhecida"),function() selected=entry.id;render() end)
  end
 end
end
return J
