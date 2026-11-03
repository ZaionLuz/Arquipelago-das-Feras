--!nonstrict
local Run=game:GetService("RunService")
local A={}
function A.start()
 local records=setmetatable({},{__mode="k"});local nearby={};local scan=0;local elapsed=0
 Run.Heartbeat:Connect(function(dt)
  elapsed+=dt;scan+=dt;if elapsed<.05 then return end;elapsed=0
  local camera=workspace.CurrentCamera;if not camera then return end
  if scan>=.5 then
   scan=0;local candidates={}
   for _,name in {"Criaturas","Selvagens","Companheiros"} do
    local folder=workspace:FindFirstChild(name)
    if folder then for _,m in folder:GetDescendants() do
     if m:IsA("Model") and m.PrimaryPart and m:GetAttribute("Species") then
      local dist=(m.PrimaryPart.Position-camera.CFrame.Position).Magnitude
      local quality=game:GetService("Players").LocalPlayer:GetAttribute("GraphicsQuality") or "Médio"
      if dist<(quality=="Baixo" and 70 or quality=="Alto" and 130 or 100) then table.insert(candidates,{model=m,dist=dist,wild=name~="Criaturas"}) end
     end
    end end
   end
   table.sort(candidates,function(a,b) return a.dist<b.dist end)
   nearby={};for i=1,math.min((game:GetService("Players").LocalPlayer:GetAttribute("GraphicsQuality")=="Baixo" and 4 or game:GetService("Players").LocalPlayer:GetAttribute("GraphicsQuality")=="Alto" and 12 or 8),#candidates) do table.insert(nearby,candidates[i]) end
  end
  if game:GetService("Players").LocalPlayer:GetAttribute("MotionReduced") then return end
  local t=os.clock()
  for _,item in nearby do
   local m=item.model;if not m.Parent or not m.PrimaryPart then continue end
   local data=records[m]
   if not data then
    data={base=m:GetPivot(),limbs={},eyes={},face={}}
    data.head=m:FindFirstChild("Head")
    if data.head then data.headOffset=m.PrimaryPart.CFrame:ToObjectSpace(data.head.CFrame) end
    for _,part in m:GetChildren() do
     if part:IsA("BasePart") then
      if part.Name=="Wing" or part.Name=="Leg" or part.Name=="Tail"  then table.insert(data.limbs,{part=part,offset=m.PrimaryPart.CFrame:ToObjectSpace(part.CFrame)}) end
      if data.head and (part.Name=="Eye" or part.Name=="Pupil" or part.Name=="EyeGlint" or part.Name=="Smile" or part.Name=="Muzzle" or part.Name=="Crest") then
       table.insert(data.face,{part=part,offset=data.head.CFrame:ToObjectSpace(part.CFrame)})
      end
      if part.Name=="Eye" or part.Name=="Pupil" or part.Name=="EyeGlint" then table.insert(data.eyes,{part=part,size=part.Size}) end
     end
    end
    records[m]=data
   end
   local family=m:GetAttribute("Family");local phase=#m.Name*.4
   if not item.wild then
    local bob=family=="Bird" and .35 or .09
    m:PivotTo(data.base*CFrame.new(0,math.sin(t*2+phase)*bob,0)*CFrame.Angles(0,math.sin(t*.7+phase)*.09,0))
   end
   for i,entry in data.limbs do
    local wave=math.sin(t*(family=="Insect" and 5 or 2.5)+i*.7+phase)
    local kind=entry.part.Name
    local rotation=kind=="Wing" and CFrame.Angles(0,0,wave*.16) or kind=="Tail" and CFrame.Angles(0,wave*.09,0) or kind=="Head" and CFrame.Angles(0,wave*.07,0) or CFrame.Angles(wave*.1,0,0)
    entry.part.CFrame=m.PrimaryPart.CFrame*entry.offset*rotation
   end
   if data.head and data.head.Parent then
    data.head.CFrame=m.PrimaryPart.CFrame*data.headOffset*CFrame.Angles(0,math.sin(t*.8+phase)*.08,0)
    for _,feature in data.face do feature.part.CFrame=data.head.CFrame*feature.offset end
   end
   local blink=(t+phase)%5<.12
   for _,eye in data.eyes do eye.part.Size=eye.size*Vector3.new(1,blink and .1 or 1,1) end
  end
 end)
end
return A
