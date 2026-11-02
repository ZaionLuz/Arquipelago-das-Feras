--!nonstrict
local RS=game:GetService("ReplicatedStorage");local Players=game:GetService("Players");local Http=game:GetService("HttpService")
local Data=require(script.Parent.DataService);local C=require(RS.Shared.Creatures);local Rules=require(RS.Shared.CombatRules)
local E={};local sessions={};local rng=Random.new();local net;local events
local function snapshot(session,message)
 local s=session.state;local party={}
 for uid,p in s.party do party[uid]={id=p.id,lv=p.lv,hp=p.hp,maxHp=p.maxHp,nextSkill=p.nextSkill} end
 return {token=session.token,seals=session.seals,version=s.version,status=s.status,turn=s.turn,foe=s.foe,party=party,active=s.active,bond=s.bond,chance=Rules.chance(s),log=s.log,message=message,expires=session.expires}
end
local function finish(player,session)
 if session.released then return end;session.released=true
 local d=Data.get(player);local s=session.state
 if d and s.status=="captured" then
  while d.creatures["u"..d.nextId] do d.nextId+=1 end
  local uid="u"..d.nextId;d.nextId+=1;d.creatures[uid]={id=s.foe.id,lv=s.foe.lv,xp=0}
  d.discovered[s.foe.id]=true;d.stats.capture=(d.stats.capture or 0)+1
 elseif d and s.status=="won" then
  local def=C.ById[s.foe.id];local reward=20+def.rar*15;d.gold+=reward;d.wins+=1;d.stats.win=(d.stats.win or 0)+1
  local pet=d.creatures[s.active]
  if pet then
   pet.xp=(pet.xp or 0)+20+def.rar*10
   while pet.lv<20 and pet.xp>=35+pet.lv*15 do pet.xp-=35+pet.lv*15;pet.lv+=1 end
   local refreshed,err=pcall(require(script.Parent.World).refresh,player)
   if not refreshed then warn("Modelo será reconstruído na próxima atualização: "..tostring(err)) end
  end
 end
 if s.status=="won" then table.insert(s.log,{text="Recompensa: "..(20+C.ById[s.foe.id].rar*15).." ouro e experiência para a fera ativa.",kind="reward"}) end
 session.release(s.status=="captured" or s.status=="won")
end
function E.open(player,specimen,release)
 local d=Data.get(player);if not d then return false end
 local old=sessions[player]
 if old and old.state.status=="active" then return false end
 local session={token=Http:GenerateGUID(false),state=Rules.new(specimen.id,specimen.lv),seals=d.seals,origin=specimen.position,expires=os.time()+150,release=release}
 d.stats.fight=(d.stats.fight or 0)+1
 sessions[player]=session;events:FireClient(player,snapshot(session));return true
end
function E.active(player) local s=sessions[player];return s and s.state.status=="active" end
function E.start()
 net=Instance.new("RemoteFunction");net.Name="EncounterNet";net.Parent=RS
 events=Instance.new("RemoteEvent");events.Name="EncounterNotice";events.Parent=RS
 net.OnServerInvoke=function(player,token,version,action,uid)
  local session=sessions[player];local d=Data.get(player)
  if not session or not d then return nil end
  -- Recuperação da própria sessão caso o evento inicial chegue antes da UI.
  if action=="Resume" then
   if session.readAt and os.clock()-session.readAt<.1 then return nil end
   session.readAt=os.clock();return snapshot(session)
  end
  if typeof(token)~="string" or #token>80 or token~=session.token then return nil end
  if typeof(action)~="string" or #action>16 or (uid~=nil and (typeof(uid)~="string" or #uid>40)) then return snapshot(session,"Pedido inválido.") end
  if action=="State" then
   if session.readAt and os.clock()-session.readAt<.1 then return nil end
   session.readAt=os.clock();return snapshot(session)
  end
  if session.state.status~="active" then return snapshot(session) end
  local root=player.Character and player.Character:FindFirstChild("HumanoidRootPart");local humanoid=player.Character and player.Character:FindFirstChildOfClass("Humanoid")
  if os.time()>=session.expires or not root or not humanoid or humanoid.Health<=0 or (root.Position-session.origin).Magnitude>40 then
   session.state.status="escaped";finish(player,session);return snapshot(session,"O encontro encerrou: distância, tempo ou personagem indisponível.")
  end
  if typeof(version)~="number" or version~=session.state.version then return snapshot(session,"Estado atualizado. Escolha novamente.") end
  if session.last and os.clock()-session.last<.25 then return snapshot(session,"Aguarde o turno.") end
  session.last=os.clock()
  local pet=uid and d.creatures[uid];local count=0;for _ in d.creatures do count+=1 end
  local ok,message=Rules.step(session.state,action,pet and {uid=uid,id=pet.id,lv=pet.lv},rng,d.seals,count<60)
  if not ok then return snapshot(session,message) end
  if session.state.spentSeal then d.seals-=1 end
  session.seals=d.seals
  if session.state.status~="active" then finish(player,session) end
  return snapshot(session)
 end
 Players.PlayerRemoving:Connect(function(player)
  local s=sessions[player];if s then s.state.status="escaped";finish(player,s) end;sessions[player]=nil
 end)
 task.spawn(function()
  while true do task.wait(2)
   for player,s in sessions do
    if s.state.status=="active" and (os.time()>=s.expires or not Data.get(player)) then
     s.state.status="escaped";finish(player,s);events:FireClient(player,snapshot(s,"O encontro terminou."))
    end
   end
  end
 end)
end
return E
