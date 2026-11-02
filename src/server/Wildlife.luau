--!nonstrict
local RS=game:GetService("ReplicatedStorage");local Players=game:GetService("Players")
local C=require(RS.Shared.Creatures);local I=require(RS.Shared.Islands);local MF=require(RS.Shared.ModelFactory)
local Rules=require(RS.Shared.CaptureRules);local Data=require(script.Parent.DataService)
local W={};local rng=Random.new();local cooldown=setmetatable({},{__mode="k"})
local started=false
function W.start()
 if started then return end;started=true
 local notice=Instance.new("RemoteEvent");notice.Name="WildNotice";notice.Parent=RS
 local folder=Instance.new("Folder");folder.Name="Selvagens";folder.Parent=workspace
 local slots={}
 for _,island in I.List do for slot=1,Rules.MaxPerIsland do table.insert(slots,{island=island,slot=slot,nextSpawn=0}) end end
 local function spawn(s)
  local pool,total={},0;local counts={}
  for _,other in slots do if other.model then counts[other.id]=(counts[other.id] or 0)+1 end end
  for _,def in C.List do local cfg=Rules.species(def)
   if cfg.island==s.island.id and (counts[def.id] or 0)<cfg.max then total+=cfg.weight;table.insert(pool,{def=def,w=cfg.weight}) end
  end
  if #pool==0 then return end
  local roll=rng:NextNumber()*total;local def=pool[#pool].def
  for _,entry in pool do roll-=entry.w;if roll<=0 then def=entry.def;break end end
  local level=def.id=="fenix" and 15 or math.max(1,def.rar*2-1)
  local m=MF.build(def,level);local cf,size=m:GetBoundingBox()
  local ground=I.pos(s.island.idx)+Vector3.new(s.slot==1 and -11 or 11,4,6)
  local lift=m:GetPivot().Position.Y-(cf.Position.Y-size.Y/2)
  s.home=ground+Vector3.new(0,lift,0);s.model=m;s.id=def.id;s.level=level;s.born=os.clock()
  m:PivotTo(CFrame.new(s.home));m.Parent=folder
  local prompt=Instance.new("ProximityPrompt");prompt.ActionText="Capturar • 1 Selo";prompt.ObjectText=def.name.." • "..math.floor(Rules.chance(def.rar,level)*100).."%";prompt.HoldDuration=1;prompt.MaxActivationDistance=11;prompt.RequiresLineOfSight=true;prompt.Parent=m.PrimaryPart
  prompt.Triggered:Connect(function(player)
   local d=Data.get(player);local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart")
   if s.model~=m or s.busy or not d or not root or (root.Position-m.PrimaryPart.Position).Magnitude>Rules.MaxDistance then return end
   if cooldown[player] and os.clock()-cooldown[player]<1.5 then return end
   cooldown[player]=os.clock()
   if not d.unlocked[s.island.id] then notice:FireClient(player,"Desbloqueie esta ilha antes de capturar.");return end
   if d.seals<1 then notice:FireClient(player,"Sem Selos! Crie um no Mercado por 25 ouro.");return end
   local count=0;for _ in d.creatures do count+=1 end
   if count>=60 then notice:FireClient(player,"Coleção cheia: limite de 60 feras.");return end
   s.busy=true -- Nenhum yield entre validar, consumir e conceder.
   d.seals-=1
   local position=m.PrimaryPart.Position
   if rng:NextNumber()<Rules.chance(def.rar,level) then
    while d.creatures["u"..d.nextId] do d.nextId+=1 end
    local uid="u"..d.nextId;d.nextId+=1
    d.creatures[uid]={id=def.id,lv=level,xp=0}
    local discovery=not d.discovered[def.id];d.discovered[def.id]=true
    d.stats.capture=(d.stats.capture or 0)+1
    notice:FireClient(player,(discovery and "Nova espécie! " or "Capturou ")..def.name,position,true)
    s.model=nil;m:Destroy();s.nextSpawn=os.clock()+Rules.RespawnSeconds
   else
    notice:FireClient(player,"O vínculo falhou. A fera fugiu; tente outro encontro.",position,false)
    s.model=nil;m:Destroy();s.nextSpawn=os.clock()+Rules.RespawnSeconds
   end
   s.busy=false
  end)
 end
 task.spawn(function()
  while folder.Parent do
   local now=os.clock()
   for _,s in slots do
    if not s.model and now>=s.nextSpawn then spawn(s)
    elseif s.model then
     -- Movimento limitado ao trecho plano e seguro de cada ponto de encontro.
     local elapsed=now-s.born;local pos=s.home+Vector3.new(math.sin(elapsed*.45)*2,0,math.cos(elapsed*.45)*2)
     if C.ById[s.id].shape=="Bird" then pos+=Vector3.new(0,math.max(0,math.sin(elapsed*.5))*2,0) end
     s.model:PivotTo(CFrame.lookAt(pos,pos+Vector3.new(math.cos(elapsed*.45),0,-math.sin(elapsed*.45))))
    end
   end
   task.wait(.25)
  end
 end)
end
return W
