--!nonstrict
local RS=game:GetService("ReplicatedStorage");local Data=require(script.Parent.DataService)
local Story=require(RS.Shared.Story);local I=require(RS.Shared.Islands)
local R={}
function R.start()
 local event=Instance.new("RemoteEvent");event.Name="StoryNotice";event.Parent=RS
 local model=Instance.new("Model");model.Name="Maia • Pesquisadora";model.Parent=workspace
 local base=I.pos(1)+Vector3.new(19,4,23)
 local function part(name,size,offset,color,shape)
  local p=Instance.new("Part");p.Name=name;p.Size=size;p.Position=base+offset;p.Color=color;p.Shape=shape or Enum.PartType.Block;p.Anchored=true;p.CanCollide=false;p.Parent=model;return p
 end
 local torso=part("Casaco",Vector3.new(2.2,2.5,1),Vector3.new(0,2.8,0),Color3.fromRGB(62,121,115))
 local head=part("Cabeça",Vector3.new(1.7,1.7,1.7),Vector3.new(0,4.7,0),Color3.fromRGB(205,159,123),Enum.PartType.Ball)
 for _,side in {-1,1} do
  part("Bota",Vector3.new(.8,1.6,1),Vector3.new(side*.6,.9,0),Color3.fromRGB(65,65,77))
  part("Braço",Vector3.new(.65,2.2,.7),Vector3.new(side*1.5,2.7,0),Color3.fromRGB(62,121,115))
 end
 local prompt=Instance.new("ProximityPrompt");prompt.ActionText="Conversar";prompt.ObjectText="Maia, pesquisadora do arquipélago";prompt.HoldDuration=.2;prompt.MaxActivationDistance=10;prompt.Parent=torso
 prompt.Triggered:Connect(function(p)
  local d=Data.get(p);local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
  if not d or not root or (root.Position-torso.Position).Magnitude>12 then return end
  local q=Story.current(d)
  event:FireClient(p,q and ("Maia: "..q.text.." ("..Story.progress(d,q).."/"..q.goal.."). Veja Missões para receber a recompensa.") or "Maia: Você concluiu nossos primeiros estudos. Continue descobrindo o arquipélago!")
 end)
end
return R
