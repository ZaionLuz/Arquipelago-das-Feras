--!nonstrict
local RS=game:GetService("ReplicatedStorage");local Players=game:GetService("Players")
local RunService=game:GetService("RunService");local Lighting=game:GetService("Lighting");local TS=game:GetService("TweenService")
local Missions=require(RS.Shared.Missions)
local E=require(RS.Shared.Elements);local Sounds=require(RS.Shared.Sounds);local SS=game:GetService("SoundService")
local C=require(RS.Shared.Creatures);local I=require(RS.Shared.Islands)
local Net=RS:WaitForChild("Net")
local gui=Instance.new("ScreenGui");gui.ResetOnSpawn=false;gui.ScreenInsets=Enum.ScreenInsets.DeviceSafeInsets;gui.Parent=Players.LocalPlayer:WaitForChild("PlayerGui")
local S,tab,isl,pick,snapAt=nil,"Feras","Brasa",{},os.clock()
local render;local tabBtn={};local tutorial
local CollectionUI=require(script.Parent.CollectionUI)
local inFlight=false
local bestiaryFilter="Todos"
local Breeding=require(RS.Shared.Breeding)
local Balance=require(RS.Shared.Economy)
local Nursery=require(script.Parent.NurseryUI)
local function mk(cls,props,parent) local o=Instance.new(cls);for k,v in props do o[k]=v end;if cls=="TextButton" or cls=="Frame" or cls=="ScrollingFrame" then Instance.new("UICorner",o).CornerRadius=UDim.new(0,12) end
	if (cls=="TextButton" or cls=="TextLabel") and o.TextScaled then Instance.new("UITextSizeConstraint",o).MaxTextSize=28 end
	if cls=="TextButton" then local g=Instance.new("UIGradient",o);g.Rotation=90;g.Color=ColorSequence.new(Color3.new(1,1,1),Color3.fromRGB(180,180,190)) end
	o.Parent=parent;return o end
local WHITE=Color3.new(1,1,1)
local top=mk("TextLabel",{Size=UDim2.new(1,-130,0,44),BackgroundColor3=Color3.fromRGB(40,30,70),TextColor3=WHITE,TextScaled=true,Font=Enum.Font.GothamBold},gui)
local msg=mk("TextLabel",{Position=UDim2.new(0,0,0,46),Size=UDim2.new(1,0,0,28),BackgroundTransparency=1,TextColor3=Color3.fromRGB(255,240,150),TextStrokeTransparency=0.4,TextScaled=true,Font=Enum.Font.GothamBold},gui)
local list=mk("ScrollingFrame",{Position=UDim2.fromScale(0,0.5),Size=UDim2.fromScale(1,0.34),BackgroundColor3=Color3.fromRGB(25,20,50),BackgroundTransparency=0.15,CanvasSize=UDim2.new(),AutomaticCanvasSize=Enum.AutomaticSize.Y},gui)
mk("UIListLayout",{Padding=UDim.new(0,8),SortOrder=Enum.SortOrder.LayoutOrder},list)
local muted=false
local function sfx(n)
	if muted or Sounds[n]=="" then return end
	local s=Instance.new("Sound");s.SoundId=Sounds[n];s.Volume=0.6;s.Parent=SS;s.Ended:Once(function() s:Destroy() end);s:Play()
end
-- Efeito de golpe por elemento: projétil com trajetória própria + explosão de partículas + onda de choque.
local FX={Fogo={shape="Ball",size=3,path="line",n=45,spd=34},["Água"]={shape="Ball",size=2.5,path="arc",n=35,spd=22},
	Natureza={shape="Block",size=2,path="line",n=28,spd=18,spin=true},Terra={shape="Block",size=4,path="drop",n=30,spd=26},
	Ar={shape="Cylinder",size=1.5,path="line",n=40,spd=40,spin=true},Sombra={shape="Ball",size=3,path="arc",n=40,spd=14}}
local function fx(el,a,b)
	local d=FX[el];local c=E.Color[el];local arena=workspace:FindFirstChild("Arena");if not arena then return end
	local p=Instance.new("Part");p.Anchored=true;p.CanCollide=false;p.Shape=Enum.PartType[d.shape];p.Size=Vector3.one*d.size
	p.Material=Enum.Material.Neon;p.Color=c;p.Parent=arena
	local e=Instance.new("ParticleEmitter");e.Rate=60;e.Lifespan=NumberRange.new(.4);e.Speed=NumberRange.new(1,3);e.Color=ColorSequence.new(c)
	e.LightEmission=1;e.Size=NumberSequence.new(d.size*.6,0);e.Parent=p
	local start=d.path=="drop" and b+Vector3.new(0,25,0) or a;local t0=os.clock()
	while true do
		local k=(os.clock()-t0)/0.35;if k>=1 then break end
		local pos=start:Lerp(b,k);if d.path=="arc" then pos+=Vector3.new(0,math.sin(k*math.pi)*8,0) end
		p.CFrame=CFrame.new(pos)*(d.spin and CFrame.Angles(k*12,k*9,0) or CFrame.identity);task.wait()
	end
	p.CFrame=CFrame.new(b);p.Transparency=1;e.Rate=0;e.Speed=NumberRange.new(d.spd*.5,d.spd);e.Lifespan=NumberRange.new(.5,.9);e:Emit(d.n)
	local ring=Instance.new("Part");ring.Shape=Enum.PartType.Ball;ring.Anchored=true;ring.CanCollide=false;ring.Material=Enum.Material.Neon
	ring.Color=c;ring.Size=Vector3.one;ring.Transparency=.3;ring.Position=b;ring.Parent=arena
	TS:Create(ring,TweenInfo.new(.4),{Size=Vector3.one*14,Transparency=1}):Play()
	task.delay(1,function() p:Destroy();ring:Destroy() end)
end
-- Batalha animada: o servidor decide o resultado; aqui só se reproduz o log de golpes.
local function playBattle(b)
	local MF=require(RS.Shared.ModelFactory)
	local cam=workspace.CurrentCamera;local o=Vector3.new(0,300,0);local ct=cam.CameraType
	local stage=Instance.new("Folder");stage.Name="Arena";stage.Parent=workspace
	local fl=Instance.new("Part");fl.Anchored=true;fl.Size=Vector3.new(70,2,30);fl.Position=o;fl.Color=Color3.fromRGB(70,60,110);fl.Parent=stage
	local function face(pos,to) return CFrame.lookAt(pos,pos+(pos-to)) end
	local pa,pf=o+Vector3.new(-14,5,0),o+Vector3.new(14,5,0)
	local a=MF.build(C.ById[b.me.id],b.me.lv);local f=MF.build(C.ById[b.foe.id],b.foe.lv)
	a:PivotTo(face(pa,pf));f:PivotTo(face(pf,pa));a.Parent=stage;f.Parent=stage
	cam.CameraType=Enum.CameraType.Scriptable;cam.CFrame=CFrame.lookAt(o+Vector3.new(0,14,40),o+Vector3.new(0,5,0))
	local barA=mk("Frame",{Position=UDim2.fromScale(0.05,0.12),Size=UDim2.fromScale(0.4,0.03),BackgroundColor3=Color3.fromRGB(80,220,120)},gui)
	local barF=mk("Frame",{Position=UDim2.fromScale(0.55,0.12),Size=UDim2.fromScale(0.4,0.03),BackgroundColor3=Color3.fromRGB(230,90,90)},gui)
	pcall(function()
		task.wait(0.6)
		for _,s in b.log do
			local att,tgt,bar=s.me and a or f,s.me and f or a,s.me and barF or barA
			local c0=att:GetPivot();local c1=c0+(tgt:GetPivot().Position-c0.Position)*0.75
			for t=0,1,1/8 do att:PivotTo(c0:Lerp(c1,math.sin(t*math.pi)));task.wait(0.03) end
			att:PivotTo(c0);fx(C.ById[(s.me and b.me or b.foe).id].el,c0.Position,tgt:GetPivot().Position);sfx("Hit")
			TS:Create(bar,TweenInfo.new(0.25),{Size=UDim2.fromScale(0.4*s.hp,0.03)}):Play()
			local g=Instance.new("BillboardGui");g.Size=UDim2.fromOffset(120,40);g.StudsOffset=Vector3.new(0,6,0);g.AlwaysOnTop=true;g.Adornee=tgt.PrimaryPart;g.Parent=tgt.PrimaryPart
			mk("TextLabel",{Size=UDim2.fromScale(1,1),BackgroundTransparency=1,TextScaled=true,Font=Enum.Font.GothamBlack,TextColor3=s.mult>1 and Color3.fromRGB(255,220,60) or WHITE,
				Text="-"..s.dmg..(s.mult>1 and "!" or s.mult<1 and " fraco" or "")},g)
			task.delay(1,function() g:Destroy() end)
			local tc=tgt:GetPivot();for i=1,4 do tgt:PivotTo(tc*CFrame.new((i%2*2-1)*0.6,0,0));task.wait(0.03) end;tgt:PivotTo(tc)
			task.wait(0.35)
		end
		sfx(b.win and "Win" or "Lose");task.wait(0.8)
	end)
	barA:Destroy();barF:Destroy();stage:Destroy();cam.CameraType=ct
end
local function call(...)
	if inFlight then return end
 inFlight=true
 local before=S
 local act=...
 msg.Text="Processando..."
	local success,r=pcall(Net.InvokeServer,Net,...)
 if not success then inFlight=false;msg.Text="Conexão interrompida. Tente novamente.";return end
	if r then
		if r.data then
   S=r.data;snapAt=os.clock()
   if r.ok and before and (act=="Hatch" or act=="Feed") then
    for uid,cr in S.creatures do
     local old=before.creatures[uid]
     if (act=="Hatch" and not old) or (old and C.stage(cr.lv)>C.stage(old.lv)) then
      CollectionUI.discovery(gui,C.ById[cr.id],cr.lv,old~=nil);break
     end
    end
   end
  end
		sfx(r.ok and (act=="Hatch" and "Hatch" or "Click") or "Lose")
		local m=r.msg or ""
		if r.battle then msg.Text="Batalha!";render();playBattle(r.battle) end
		msg.Text=m
	end
	inFlight=false
	render()
	tutorial()
end
local function row(text,acts)
	local f=mk("Frame",{LayoutOrder=0,Size=UDim2.new(1,-8,0,52),BackgroundColor3=Color3.fromRGB(55,45,100)},list)
	mk("TextLabel",{Size=UDim2.fromScale(0.4,1),BackgroundTransparency=1,Text=text,TextScaled=true,TextColor3=WHITE,Font=Enum.Font.Gotham},f)
	local w=0.6/math.max(1,#acts)
	for i,a in acts do
		local b=mk("TextButton",{Position=UDim2.fromScale(0.4+(i-1)*w,0),Size=UDim2.new(w,-4,1,0),Text=a[1],TextScaled=true,Font=Enum.Font.GothamBold,BackgroundColor3=Color3.fromRGB(120,90,210),TextColor3=WHITE},f)
		b.Activated:Connect(a[2])
	end
end
local function crText(cr) local d=C.ById[cr.id];return ("%s Nv.%d [%s %s]"):format(d.name,cr.lv,d.el,C.Rarity[d.rar]) end
render=function()
	for n,b in tabBtn do b.BackgroundColor3=n==tab and Color3.fromRGB(255,170,60) or Color3.fromRGB(90,70,160) end
	for _,c in list:GetChildren() do if c:IsA("Frame") then c:Destroy() end end
	if not S then return end
	local n=0;for _ in S.discovered do n+=1 end
	top.Text=("Ouro %d | Gemas %d | Bestiário %d/%d | Vitórias %d"):format(S.gold,S.gems,n,#C.List,S.wins)
	if tab=="Feras" then
		for uid,cr in S.creatures do
			row(crText(cr),{{"Alimentar",function() call("Feed",uid) end},{"Pôr: "..isl,function() call("Place",uid,isl) end},{"Lutar",function() call("Battle",uid,isl) end}})
		end
	elseif tab=="Bestiário" then
  local filters={"Todos","Descobertos","Misteriosos"}
  for _,el in E.List do table.insert(filters,el) end
  for _,name in filters do
   row((bestiaryFilter==name and "✓ " or "")..name,{{"Filtrar",function() bestiaryFilter=name;render() end}})
  end
  for index,def in C.List do
   local known=S.discovered[def.id]==true
   if bestiaryFilter=="Todos" or (bestiaryFilter=="Descobertos" and known) or (bestiaryFilter=="Misteriosos" and not known) or def.el==bestiaryFilter then
    local lv=1
    for _,cr in S.creatures do if cr.id==def.id then lv=math.max(lv,cr.lv) end end
    CollectionUI.card(list,def,lv,known,index)
   end
  end
 elseif tab=="Arena" then
		row("Troféus: "..S.trophies.." — ambos devem tocar Desafiar em até 30s",{})
		local n=0
		for _,pl in Players:GetPlayers() do
			if pl~=Players.LocalPlayer then n+=1;row(pl.DisplayName,{{"Desafiar",function() call("Duel",pl.UserId) end}}) end
		end
		if n==0 then row("Nenhum outro jogador agora. Convide amigos!",{}) end
	elseif tab=="Missões" then
		local ev=S.event
		row(("Evento: +50%% ouro de %s (%dh)"):format(ev.el,math.ceil(ev.left/3600)),{})
		row("Recompensa diária (sequência "..S.streak..")",{{"Resgatar",function() call("Daily") end}})
		for _,m in Missions.List do
			local pr=Missions.progress(S,m.stat);local done=S.claimed[m.id]
			row(("%s (%d/%d)"):format(m.text,math.min(pr,m.goal),m.goal),{{done and "✓" or (pr>=m.goal and "Resgatar" or "+"..m.gold.." ouro"),function() if not done and pr>=m.goal then call("Claim",m.id) end end}})
		end
	elseif tab=="Loja" then
		row("Mercado de ovos — compras com ouro do jogo",{})
		for _,def in I.List do
			if S.unlocked[def.id] then row("Ovo de "..def.name.." — "..(80*def.idx).." ouro",{{"Comprar",function() call("BuyEgg",def.id) end}}) end
		end
	elseif tab=="Ilhas" then
		for _,def in I.List do
			if S.unlocked[def.id] then row(def.name.." ("..def.el..")"..(def.id==isl and " ✓" or ""),{{"Selecionar",function() isl=def.id;render() end}})
			else row(def.name.." — "..def.cost.." ouro",{{"Desbloquear",function() call("Unlock",def.id) end}}) end
		end
	else
  row("Chocadeira: "..#S.eggs.."/"..Balance.IncubatorSlots.." • Escolha dois progenitores",{})
  for i,e in S.eggs do
   local left=math.max(0,math.ceil(e.left-(os.clock()-snapAt)))
   Nursery.egg(list,C.ById[e.id],left,function() call("Hatch",i) end,function() call("Speed",i) end)
  end
  if #pick==2 and S.creatures[pick[1]] and S.creatures[pick[2]] then
   local a,b=S.creatures[pick[1]],S.creatures[pick[2]]
   Nursery.parents(list,C.ById[a.id],C.ById[b.id],Breeding.outcomes(a.id,b.id),#S.eggs<Balance.IncubatorSlots and S.gold>=Balance.BreedCost,function() call("Breed",pick[1],pick[2]) end)
  end
		for uid,cr in S.creatures do
			local on=table.find(pick,uid)
			row((on and "★ " or "")..crText(cr),{{on and "Tirar" or "Escolher",function()
				if on then table.remove(pick,on) elseif #pick<2 then table.insert(pick,uid) end;render() end}})
		end
	end
end
local bar=mk("Frame",{Position=UDim2.fromScale(0,0.84),Size=UDim2.fromScale(1,0.16),BackgroundTransparency=1},gui)
for i,name in {"Feras","Ilhas","Ovos","Bestiário","Arena","Missões","Loja"} do
	local b=mk("TextButton",{Position=UDim2.fromScale(((i-1)%4)/4,math.floor((i-1)/4)/2),Size=UDim2.fromScale(1/4,.5),Text=name,TextScaled=true,Font=Enum.Font.GothamBold,BackgroundColor3=Color3.fromRGB(90,70,160),TextColor3=WHITE},bar)
	tabBtn[name]=b;b.Activated:Connect(function() tab=name;render() end)
end
local collect=mk("TextButton",{Position=UDim2.new(1,-130,0,0),Size=UDim2.fromOffset(130,44),Text="Coletar",TextScaled=true,Font=Enum.Font.GothamBold,BackgroundColor3=Color3.fromRGB(255,190,50),TextColor3=Color3.fromRGB(40,30,70)},gui)
collect.Activated:Connect(function() call("Collect") end)
task.spawn(function() while true do task.wait(1);if tab=="Ovos" then Nursery.tick(list) end end end)
local music
if Sounds.Music~="" then music=Instance.new("Sound");music.SoundId=Sounds.Music;music.Looped=true;music.Volume=0.25;music.Parent=SS;music:Play() end
local mb=mk("TextButton",{Position=UDim2.new(1,-74,0.5,-40),Size=UDim2.fromOffset(70,36),Text="Som ON",TextScaled=true,Font=Enum.Font.GothamBold,BackgroundColor3=Color3.fromRGB(90,70,160),TextColor3=WHITE},gui)
mb.Activated:Connect(function() muted=not muted;mb.Text=muted and "Som OFF" or "Som ON";if music then music.Volume=muted and 0 or 0.25 end end)
-- Feras respiram e se viram devagar (animação local, só visual).
local base=setmetatable({},{__mode="k"})
local animationAccumulator=0
local limbs=setmetatable({},{__mode="k"})
RunService.Heartbeat:Connect(function(dt)
 animationAccumulator+=dt;if animationAccumulator<.05 then return end;animationAccumulator=0
	local root=workspace:FindFirstChild("Criaturas");if not root then return end
	local t=os.clock()
 local camera=workspace.CurrentCamera
	for _,f in root:GetChildren() do
		for _,m in f:GetChildren() do
			if not m.PrimaryPart then continue end;base[m]=base[m] or m:GetPivot()
			if camera and (base[m].Position-camera.CFrame.Position).Magnitude>130 then continue end
   local family=m:GetAttribute("Family")
   if not limbs[m] then
    local entries={}
    for _,part in m:GetChildren() do
     if part:IsA("BasePart") and (part.Name=="Wing" or part.Name=="Leg" or part.Name=="Tail") then
      table.insert(entries,{part=part,offset=m.PrimaryPart.CFrame:ToObjectSpace(part.CFrame)})
     end
    end
    limbs[m]=entries
   end
   local bob=family=="Bird" and .65 or family=="Serpent" and .12 or .18
   local speed=family=="Insect" and 5 or family=="Bird" and 2 or 1.5
   m:PivotTo(base[m]*CFrame.new(0,math.sin(t*speed+#m.Name)*bob,0)*CFrame.Angles(0,math.sin(t+#m.Name)*.15,family=="Serpent" and math.sin(t*2)*.09 or 0))
   for index,entry in limbs[m] do
    local part=entry.part
    if part.Parent then
     local wave=math.sin(t*(family=="Insect" and 6 or 3)+index*.6)
     local rotation=part.Name=="Wing" and CFrame.Angles(0,0,wave*.2) or part.Name=="Tail" and CFrame.Angles(0,wave*.08,0) or CFrame.Angles(wave*.1,0,0)
     part.CFrame=m.PrimaryPart.CFrame*entry.offset*rotation
    end
   end
		end
	end
end)
-- Clima e hora do dia mudam conforme a ilha mais próxima.
local cur
task.spawn(function()
	while true do
		task.wait(1)
		local ch=Players.LocalPlayer.Character;local hrp=ch and ch:FindFirstChild("HumanoidRootPart")
		if hrp then
			local best,bd=nil,1e9
			for _,d in I.List do local dist=(I.pos(d.idx)-hrp.Position).Magnitude;if dist<bd then best,bd=d,dist end end
			if best and best~=cur then cur=best;TS:Create(Lighting,TweenInfo.new(3),{Ambient=best.ambient,OutdoorAmbient=best.ambient,ClockTime=best.clock}):Play() end
		end
	end
end)
-- Tutorial guiado: cada passo some quando o objetivo é cumprido; o progresso vem dos stats salvos.
local TUT={
	{"Toque em COLETAR para pegar o ouro das suas feras.",function() return collect end,function(s) return (s.stats.collect or 0)>=1 end},
	{"Na aba FERAS, toque em ALIMENTAR para evoluir uma fera.",function() return tabBtn.Feras end,function(s) return (s.stats.feed or 0)>=1 end},
	{"Na aba OVOS, escolha 2 feras e toque CRUZAR.",function() return tabBtn.Ovos end,function(s) return (s.stats.breed or 0)>=1 end},
	{"Na aba FERAS, toque em LUTAR para ver uma batalha!",function() return tabBtn.Feras end,function(s) return (s.stats.fight or 0)>=1 end},
	{"Em MISSÕES, resgate sua primeira recompensa.",function() return tabBtn["Missões"] end,function(s) return next(s.claimed)~=nil end}}
local panel=mk("Frame",{Position=UDim2.new(0.02,0,0.5,-98),Size=UDim2.new(0.74,0,0,92),BackgroundColor3=Color3.fromRGB(255,240,200),Visible=false},gui)
local ptxt=mk("TextLabel",{Size=UDim2.new(1,-90,1,0),Position=UDim2.fromOffset(8,0),BackgroundTransparency=1,TextScaled=true,Font=Enum.Font.GothamBold,TextColor3=Color3.fromRGB(50,35,90),TextXAlignment=Enum.TextXAlignment.Left},panel)
local skip=mk("TextButton",{Size=UDim2.fromOffset(76,36),Position=UDim2.new(1,-80,0.5,-18),Text="Pular",TextScaled=true,Font=Enum.Font.GothamBold,BackgroundColor3=Color3.fromRGB(200,120,120),TextColor3=WHITE},panel)
local stroke=Instance.new("UIStroke");stroke.Color=Color3.fromRGB(255,230,80);stroke.Thickness=2;stroke.ApplyStrokeMode=Enum.ApplyStrokeMode.Border
TS:Create(stroke,TweenInfo.new(0.6,Enum.EasingStyle.Sine,Enum.EasingDirection.InOut,-1,true),{Thickness=8}):Play()
local finishing=false
local function finish() if not finishing then finishing=true;task.spawn(call,"Tut") end end
skip.Activated:Connect(finish)
tutorial=function()
	if not S or S.tut then panel.Visible=false;stroke.Parent=nil;return end
	local step;for _,t in TUT do if not t[3](S) then step=t;break end end
	if not step then finish();return end
	panel.Visible=true;ptxt.Text=step[1];stroke.Parent=step[2]()
end
-- Entrada pode preceder o término de UpdateAsync/consulta de passes.
task.spawn(function()
 for _=1,20 do
  call("Get")
  if S then return end
  msg.Text="Carregando seu santuário..."
  task.wait(.75)
 end
 msg.Text="Não foi possível obter o perfil. Reconecte para tentar novamente."
end)
