--!nonstrict
-- Decoração determinística; centro e entradas das pontes permanecem livres.
local B={}
local V=Vector3.new
function B.decorate(parent,origin,def)
 local folder=Instance.new("Folder");folder.Name="Bioma_"..def.id;folder.Parent=parent
 local rng=Random.new(100+def.idx)
 local function part(shape,size,pos,color,material,solid)
  local p=Instance.new("Part");p.Shape=shape;p.Size=size;p.Position=origin+pos
  p.Anchored=true;p.CanCollide=solid==true;p.CanTouch=false;p.Color=color;p.Material=material or Enum.Material.SmoothPlastic;p.Parent=folder;return p
 end
 local function crystal(pos,color)
  local p=part(Enum.PartType.Block,V(1.8,5,1.8),pos,color,Enum.Material.Neon)
  p.CFrame*=CFrame.Angles(.2,0,.4)
 end
 for i=1,10 do
  local angle=i*math.pi*2/10+.13
  local pos=V(math.cos(angle)*29,4,math.sin(angle)*29)
  if def.id=="Brasa" then
   part(Enum.PartType.Ball,V(7,6,7),pos+V(0,1,0),Color3.fromRGB(40,35,40),Enum.Material.Basalt)
   crystal(pos+V(0,4,0),def.accent)
  elseif def.id=="Recife" then
   for j=1,3 do
    local coral=part(Enum.PartType.Cylinder,V(4,.7,.7),pos+V(j-2,2+j*.4,0),j%2==0 and def.accent or Color3.fromRGB(240,145,180))
    coral.CFrame*=CFrame.Angles(0,0,math.pi/2+(j-2)*.3)
   end
   crystal(pos+V(0,5,0),def.accent)
  elseif def.id=="Floresta" or def.id=="Pantano" then
   local shadow=def.id=="Pantano"
   local trunk=part(Enum.PartType.Cylinder,V(10,2,2),pos+V(0,5,0),Color3.fromRGB(80,57,55),Enum.Material.Wood)
   trunk.CFrame*=CFrame.Angles(0,0,math.pi/2+(shadow and .25 or 0))
   part(Enum.PartType.Ball,V(9,7,8),pos+V(1,11,0),shadow and Color3.fromRGB(60,43,82) or Color3.fromRGB(52,120,77),Enum.Material.Grass)
   part(Enum.PartType.Ball,V(2,1,2),pos+V(3,1,2),def.accent,Enum.Material.Neon)
  elseif def.id=="Dunas" then
   local pillar=part(Enum.PartType.Cylinder,V(7,3,3),pos+V(0,3.5,0),def.accent,Enum.Material.Sandstone)
   pillar.CFrame*=CFrame.Angles(0,0,math.pi/2+.1)
   part(Enum.PartType.Block,V(5,1,4),pos+V(0,7,0),def.ground,Enum.Material.Sandstone)
  else
   part(Enum.PartType.Ball,V(10,3,7),pos+V(0,5,0),Color3.fromRGB(235,243,255))
   crystal(pos+V(0,8,0),def.accent)
  end
 end
 -- Marco de exploração e caminho radial: tudo abaixo dos pés ou sem colisão.
 local path=part(Enum.PartType.Block,V(8,.15,58),V(0,4.1,0),def.ground:Lerp(Color3.new(1,1,1),.2),Enum.Material.Cobblestone)
 local stone=part(Enum.PartType.Ball,V(7,3,7),V(24,5,0),def.ground,Enum.Material.Slate)
 local prompt=Instance.new("ProximityPrompt");prompt.ActionText="Conhecer bioma";prompt.ObjectText=def.name.." • "..def.desc;prompt.HoldDuration=0;prompt.MaxActivationDistance=12;prompt.Parent=stone
 prompt.Triggered:Connect(function(player)
  local ch=player.Character;local root=ch and ch:FindFirstChild("HumanoidRootPart")
  if root and (root.Position-stone.Position).Magnitude<16 then player:SetAttribute("BiomaVisitado",def.id) end
 end)
end
return B
