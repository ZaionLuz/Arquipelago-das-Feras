--!nonstrict
-- Volume e silhueta com poucas peças grandes; não altera a superfície segura y=14.
local A={};local V=Vector3.new
function A.build(parent,center,def)
 local group=Instance.new("Folder");group.Name="Geologia_"..def.id;group.Parent=parent
 local rng=Random.new(718+def.idx)
 local function rock(size,pos,color)
  local p=Instance.new("Part");p.Shape=Enum.PartType.Ball;p.Size=size;p.Position=center+pos;p.Color=color;p.Material=Enum.Material.Rock;p.Anchored=true;p.CanCollide=false;p.CanTouch=false;p.CanQuery=false;p.Parent=group;return p
 end
 rock(V(76,21,76),V(0,-9,0),def.ground:Lerp(Color3.fromRGB(30,35,45),.55))
 for i=1,7 do
  local a=i*math.pi*2/7;local radius=33
  local p=rock(V(rng:NextNumber(12,20),rng:NextNumber(12,20),rng:NextNumber(12,20)),V(math.cos(a)*radius,-5,math.sin(a)*radius),def.ground:Lerp(Color3.fromRGB(42,44,51),.4))
  p.CFrame*=CFrame.Angles(rng:NextNumber(),rng:NextNumber(),rng:NextNumber())
 end
 -- Pequenas pedras costeiras: um grupo coeso, em vez de ruído em todo o mapa.
 for i=1,4 do rock(V(5+i,3,5),V(34+i,-.5,(i-2)*5),def.ground:Lerp(Color3.fromRGB(222,201,156),.3)) end
end
return A
