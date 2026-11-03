--!nonstrict
local RS=game:GetService("ReplicatedStorage")
local Data=require(script.Parent.DataService);local I=require(RS.Shared.Islands);local Rules=require(RS.Shared.SanctuaryRules)
local S={};local plots={};local used={}
local V=Vector3.new
local function part(parent,name,size,position,color,material,collide,shape)
 local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=position;p.Anchored=true;p.CanCollide=collide==true;p.CanTouch=false;p.Material=material or Enum.Material.SmoothPlastic;p.Color=color;p.Shape=shape or Enum.PartType.Block;p.Parent=parent;return p
end
function S.ensure(player)
 if plots[player] then return plots[player] end
 local index=1;while used[index] do index+=1 end;used[index]=true
 local center=V(((index-1)%4)*190,12,850+math.floor((index-1)/4)*190)
 local root=workspace:FindFirstChild("Santuarios") or Instance.new("Folder",workspace);root.Name="Santuarios"
 local folder=Instance.new("Folder");folder.Name=tostring(player.UserId);folder:SetAttribute("OwnerUserId",player.UserId);folder.Parent=root
 local base=part(folder,"Ilha pessoal",V(144,4,144),center,Color3.fromRGB(85,132,106),Enum.Material.Grass,true)
 part(folder,"Rocha flutuante",V(142,35,142),center-V(0,15,0),Color3.fromRGB(74,87,92),Enum.Material.Rock,false,Enum.PartType.Ball)
 part(folder,"Caminho central",V(9,.2,125),center+V(0,2.2,0),Color3.fromRGB(202,194,165),Enum.Material.Cobblestone,false)
 local sign=part(folder,"Portal de retorno",V(7,9,2),center+V(0,6,61),Color3.fromRGB(80,146,166),Enum.Material.Neon,false)
 local prompt=Instance.new("ProximityPrompt");prompt.ActionText="Voltar à aventura";prompt.ObjectText="Portal do santuário";prompt.HoldDuration=.4;prompt.MaxActivationDistance=10;prompt.Parent=sign
 prompt.Triggered:Connect(function(p)
  local d=Data.get(p);local hrp=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
  if p~=player or not d or not hrp or (hrp.Position-sign.Position).Magnitude>12 then return end
  if require(script.Parent.EncounterService).active(p) then return end
  require(script.Parent.Transport).go(p,I.pos(1)+V(0,9,24))
 end)
 local plot={index=index,center=center,folder=folder,signature=""};plots[player]=plot;return plot
end
function S.position(player,island)
 local d=Data.get(player);local entry=d and d.sanctuary[island]
 if not entry then return nil end
 local x,z=Rules.slot(entry.slot);return S.ensure(player).center+V(x,2,z)
end
function S.refresh(player)
 local d=Data.get(player);if not d then return end
 local plot=S.ensure(player);local keys={}
 for id,entry in d.sanctuary do table.insert(keys,id..":"..entry.slot..":"..entry.level..":"..#(d.habitat[id] or {})) end;table.sort(keys)
 local signature=table.concat(keys,"|");if plot.signature==signature then return end;plot.signature=signature
 local old=plot.folder:FindFirstChild("Habitats");if old then old:Destroy() end
 local folder=Instance.new("Folder");folder.Name="Habitats";folder.Parent=plot.folder
 for id,entry in d.sanctuary do
  local def=I.ById[id];local pos=S.position(player,id);local zone=Instance.new("Model");zone.Name=def.name;zone:SetAttribute("OwnerUserId",player.UserId);zone.Parent=folder
  local base=part(zone,"Habitat",V(28,.4,28),pos+V(0,.2,0),def.ground,Enum.Material.Slate,true)
  for _,sx in {-1,1} do for _,sz in {-1,1} do
   part(zone,"Marco elemental",V(2,3+entry.level,2),pos+V(sx*12,2,sz*12),def.accent,Enum.Material.Neon,false)
  end end
  local label=Instance.new("BillboardGui");label.Size=UDim2.fromOffset(190,45);label.StudsOffset=V(0,5,0);label.MaxDistance=70;label.Parent=base
  local text=Instance.new("TextLabel");text.Size=UDim2.fromScale(1,1);text.BackgroundTransparency=1;text.TextColor3=Color3.new(1,1,1);text.TextStrokeTransparency=.4;text.TextSize=14;text.Font=Enum.Font.GothamBold;text.Text=def.el.." • Habitat "..entry.level.."\n"..#(d.habitat[id] or {}).." / "..Rules.capacity(def,entry);text.Parent=label
 end
end
function S.home(player)
 local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
 if not root then return false end
 return require(script.Parent.Transport).go(player,S.ensure(player).center+V(0,7,55))
end
function S.release(player)
 local plot=plots[player];if not plot then return end
 plot.folder:Destroy();used[plot.index]=nil;plots[player]=nil
end
return S
