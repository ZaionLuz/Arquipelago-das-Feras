--!nonstrict
local RS=game:GetService("ReplicatedStorage");local Run=game:GetService("RunService")
local C=require(RS.Shared.Creatures);local I=require(RS.Shared.Islands);local E=require(RS.Shared.Elements)
local Preview=require(script.Parent.CollectionUI);local Theme=require(script.Parent.UITheme)
local Lore=require(RS.Shared.SpeciesLore)
local J={};local selected="cinzelo";local rarity=0;local island=0;local element=0;local search=""
local function frame(parent,height)
 local f=Instance.new("Frame");f.Size=UDim2.new(1,-8,0,height);f.BackgroundColor3=Theme.Card;f.Parent=parent;Theme.round(f);return f
end
function J.render(parent,s,render)
 local filters=frame(parent,100);filters.BackgroundTransparency=1
 local choices={
  {"Raridade: "..(C.Rarity[rarity] or "Todas"),function() rarity=(rarity+1)%5;render() end},
  {"Bioma: "..(island==0 and "Todos" or I.List[island].name),function() island=(island+1)%(#I.List+1);render() end},
  {"Elemento: "..(E.List[element] or "Todos"),function() element=(element+1)%7;render() end},
 }
 for index,entry in choices do
  local b=Theme.button(filters,entry[1],entry[2]);b.Position=UDim2.new((index-1)%2*.5,2,0,math.floor((index-1)/2)*50);b.Size=UDim2.new(.5,-4,0,46)
 end
 local box=Instance.new("TextBox");box.PlaceholderText="Buscar espécie";box.Text=search;box.TextSize=14;box.ClearTextOnFocus=false;box.Size=UDim2.new(.5,-4,0,46);box.Position=UDim2.new(.5,2,0,50);box.BackgroundColor3=Theme.Card;box.TextColor3=Theme.Ink;box.PlaceholderColor3=Theme.Muted;box.Parent=filters;Theme.round(box)
 box.FocusLost:Connect(function() search=string.sub(box.Text,1,40);render() end)
 local def=C.ById[selected];local known=s.discovered[selected];local lv,count=1,0
 for _,cr in s.creatures do if cr.id==selected then count+=1;lv=math.max(lv,cr.lv) end end
 local card=frame(parent,360);local view=Preview.preview(card,def,lv,not known)
 local world=view:FindFirstChildOfClass("WorldModel");local model=world:FindFirstChildOfClass("Model");local cf,size=model:GetBoundingBox();local distance=math.max(size.X,size.Y,size.Z)*2
 local angle=0;local connection=Run.Heartbeat:Connect(function(dt)
  if not parent.Visible then return end;angle+=dt*.25
  view.CurrentCamera.CFrame=CFrame.lookAt(cf.Position+Vector3.new(math.sin(angle)*distance,distance*.3,math.cos(angle)*distance),cf.Position)
 end)
 card.Destroying:Connect(function() connection:Disconnect() end)
 local info=Theme.label(card,"",14);info.Position=UDim2.fromScale(.03,.66);info.Size=UDim2.fromScale(.94,.33)
 info.Text=known and (def.name.." • "..def.el.." • "..C.Rarity[def.rar].."\n"..(I.ById[def.island] and I.ById[def.island].name or "Híbrido").." • Coleção: "..count.."\nNv."..lv.." • Estágio "..C.stage(lv,def.id)..(def.id=="fenix" and " • Renascimento futuro" or " • Evolui em 7 / 15")) or "Espécie misteriosa\nExplore, capture ou cruze feras para conhecer sua história."
 if known and Lore[def.id] then info.Text..="\n"..Lore[def.id].description.." • "..Lore[def.id].personality end
 local matches={}
 for _,entry in C.List do
  local found=s.discovered[entry.id]
  if (rarity==0 or entry.rar==rarity) and (island==0 or entry.island==I.List[island].id) and (element==0 or entry.el==E.List[element]) and (search=="" or (found and string.find(string.lower(entry.name),string.lower(search),1,true))) then table.insert(matches,entry) end
 end
 if #matches==0 then local f=frame(parent,50);local l=Theme.label(f,"Nenhuma espécie corresponde aos filtros.",14);l.Size=UDim2.fromScale(1,1);return end
 local columns=parent.AbsoluteSize.X>=390 and 3 or 2
 local grid=frame(parent,math.ceil(#matches/columns)*148);grid.BackgroundTransparency=1
 local layout=Instance.new("UIGridLayout");layout.CellSize=UDim2.new(1/columns,-7,0,140);layout.CellPadding=UDim2.fromOffset(7,8);layout.SortOrder=Enum.SortOrder.LayoutOrder;layout.Parent=grid
 for index,entry in matches do
  local found=s.discovered[entry.id];local tile=Instance.new("Frame");tile.LayoutOrder=index;tile.BackgroundColor3=entry.id==selected and Color3.fromRGB(63,88,81) or Theme.Card;tile.Parent=grid;Theme.round(tile)
  local mini
  local function visibility()
   if not tile.Parent then return end
   local top=parent.AbsolutePosition.Y;local y=tile.AbsolutePosition.Y
   local visible=parent.Visible and y+140>=top and y<top+parent.AbsoluteSize.Y
   if visible and not mini then mini=Preview.preview(tile,entry,1,not found);mini.Size=UDim2.fromScale(1,.72)
   elseif not visible and mini then mini:Destroy();mini=nil end
  end
  local scroll=parent:GetPropertyChangedSignal("CanvasPosition"):Connect(visibility)
  local visible=parent:GetPropertyChangedSignal("Visible"):Connect(visibility)
  local pos=tile:GetPropertyChangedSignal("AbsolutePosition"):Connect(visibility)
  tile.Destroying:Connect(function() scroll:Disconnect();visible:Disconnect();pos:Disconnect() end);task.defer(visibility)
  local choose=Theme.button(tile,found and entry.name or "???",function() selected=entry.id;render() end)
  choose.Position=UDim2.new(0,0,1,-44);choose.Size=UDim2.new(1,0,0,44);choose.TextSize=12
 end
end
return J
