--!nonstrict
local RS=game:GetService("ReplicatedStorage");local I=require(RS.Shared.Islands);local C=require(RS.Shared.Creatures);local MF=require(RS.Shared.ModelFactory)
local Data=require(script.Parent.DataService);local Encounters=require(script.Parent.EncounterService)
local G={}
function G.start()
 local folder=Instance.new("Folder");folder.Name="Guardioes";folder.Parent=workspace
 for _,island in I.List do
  local chosen
  for _,def in C.List do if def.el==island.el and not def.hybrid and def.rar>=3 and def.id~="fenix" then chosen=def;break end end
  if not chosen then continue end
  local level=math.min(100,(island.minLevel or 1)+7)
  local model=MF.build(chosen,level);local box,size=model:GetBoundingBox();local lift=model:GetPivot().Position.Y-(box.Position.Y-size.Y/2)
  model:PivotTo(CFrame.new(I.pos(island.idx)+Vector3.new(-20,4+lift,8)));model.Parent=folder
  local prompt=Instance.new("ProximityPrompt");prompt.ActionText="Desafiar guardião";prompt.ObjectText=island.name.." • Nv."..level;prompt.HoldDuration=.8;prompt.MaxActivationDistance=11;prompt.Parent=model.PrimaryPart
  prompt.Triggered:Connect(function(p)
   local d=Data.get(p);local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
   if not d or not root or (root.Position-model.PrimaryPart.Position).Magnitude>13 or not d.unlocked[island.id] or Encounters.active(p) then return end
   if d.guardians[island.id] then local notice=RS:FindFirstChild("WildNotice");if notice then notice:FireClient(p,"Você já concluiu este desafio de guardião.") end;return end
   Encounters.open(p,{id=chosen.id,lv=level,position=model.PrimaryPart.Position,capturable=false,guardianId=island.id},function() model:SetAttribute("LastChallengeEnded",os.time()) end)
  end)
 end
end
return G
