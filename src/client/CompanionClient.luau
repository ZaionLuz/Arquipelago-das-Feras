--!nonstrict
local Players=game:GetService("Players");local RS=game:GetService("ReplicatedStorage");local Run=game:GetService("RunService")
local C=require(RS.Shared.Creatures);local MF=require(RS.Shared.ModelFactory)
local U={}
function U.start()
 local folder=Instance.new("Folder");folder.Name="Companheiros";folder.Parent=workspace
 local models={};local timer=0
 Run.Heartbeat:Connect(function(dt)
  timer+=dt;if timer<.05 then return end;local step=timer;timer=0
  local camera=workspace.CurrentCamera;if not camera then return end
  local active={};local candidates={}
  for _,p in Players:GetPlayers() do
   local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart");local id=p:GetAttribute("CompanionSpecies")
   if root and id and C.ById[id] and (root.Position-camera.CFrame.Position).Magnitude<110 then table.insert(candidates,{p=p,root=root,id=id}) end
  end
  table.sort(candidates,function(a,b) return (a.root.Position-camera.CFrame.Position).Magnitude<(b.root.Position-camera.CFrame.Position).Magnitude end)
  local quality=Players.LocalPlayer:GetAttribute("GraphicsQuality") or "Médio"
  for index=1,math.min(quality=="Baixo" and 3 or quality=="Alto" and 6 or 4,#candidates) do
   local item=candidates[index];local p,root,id=item.p,item.root,item.id;active[p]=true
   local lv=p:GetAttribute("CompanionLevel") or 1;local key=id..":"..lv;local entry=models[p]
   if not entry or entry.key~=key then
    if entry then entry.model:Destroy() end
    local m=MF.build(C.ById[id],lv,{preview=true});local _,size=m:GetBoundingBox()
    if math.max(size.X,size.Y,size.Z)>7 then m:ScaleTo(m:GetScale()*7/math.max(size.X,size.Y,size.Z)) end
    local cf,scaled=m:GetBoundingBox();local lift=m:GetPivot().Position.Y-(cf.Position.Y-scaled.Y/2)
    m.Parent=folder;entry={model=m,key=key,lift=lift,position=root.Position};models[p]=entry
   end
   local params=RaycastParams.new();params.FilterType=Enum.RaycastFilterType.Exclude;params.FilterDescendantsInstances={folder,p.Character}
   local desired=root.Position-root.CFrame.LookVector*5+root.CFrame.RightVector*4
   local recalc=not entry.rayAt or os.clock()-entry.rayAt>=.2
   if recalc then entry.obstructed=workspace:Raycast(root.Position,desired-root.Position,params)~=nil end
   if entry.obstructed then desired=root.Position+root.CFrame.RightVector*4 end
   if recalc then
    local ground=workspace:Raycast(desired+Vector3.new(0,12,0),Vector3.new(0,-70,0),params)
    entry.floor=ground and ground.Position.Y or root.Position.Y-3;entry.rayAt=os.clock()
   end
   local floor=entry.floor
   local hover=C.ById[id].shape=="Bird" and 1.8 or 0
   local happy=not Players.LocalPlayer:GetAttribute("MotionReduced") and (p:GetAttribute("PetHappyUntil") or 0)>workspace:GetServerTimeNow()
   desired=Vector3.new(desired.X,floor+entry.lift+hover+(happy and math.abs(math.sin(os.clock()*6))*.6 or 0),desired.Z)
   if (entry.position-desired).Magnitude>50 then entry.position=desired else entry.position=entry.position:Lerp(desired,math.min(1,step*5)) end
   local direction=root.CFrame.LookVector
   entry.model:PivotTo(CFrame.lookAt(entry.position,entry.position-direction))
  end
  for p,entry in models do if not active[p] then entry.model:Destroy();models[p]=nil end end
 end)
end
return U
