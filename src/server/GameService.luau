--!nonstrict
local RS=game:GetService("ReplicatedStorage")
local C=require(RS.Shared.Creatures);local I=require(RS.Shared.Islands);local E=require(RS.Shared.Elements);local B=require(RS.Shared.Breeding)
local M=require(RS.Shared.Missions)
local SR=require(RS.Shared.SanctuaryRules)
local CaptureRules=require(RS.Shared.CaptureRules)
local Story=require(RS.Shared.Story)
local Progression=require(RS.Shared.Progression)
local Transport=require(script.Parent.Transport)
local Sanctuary=require(script.Parent.SanctuaryService)
local Data=require(script.Parent.DataService);local World=require(script.Parent.World)
local G={};local rng=Random.new()
local Mon=require(script.Parent.MonetizationService)
local lastBattle=setmetatable({},{__mode="k"})
local Balance=require(RS.Shared.Economy)
local MAXLV,OFFLINE_CAP,BREED_COST=Balance.MaxLevel,Balance.OfflineCap,Balance.BreedCost
local function lvMul(lv) return 1+0.15*(lv-1) end
local function bump(d,k) d.stats[k]=(d.stats[k] or 0)+1 end
local function fail(m) return {ok=false,msg=m} end
local function ok(p,m) return {ok=true,msg=m,data=Data.snapshot(p)} end
-- Renda por tempo REAL do servidor (os.time), limitada a 8 h: alterar o relógio do cliente não adianta.
local function settle(p)
	local d=Data.get(p);local now=os.time();local mins=math.clamp(now-d.last,0,OFFLINE_CAP)/60;local gold=0;local EV=M.event(now)
	for isl,list in d.habitat do
		for _,uid in list do
			local cr=d.creatures[uid]
			if cr then local cd=C.ById[cr.id];gold+=cd.gpm*lvMul(cr.lv)*(cd.el==I.ById[isl].el and 1.5 or 1)*(cd.el==EV and 1.5 or 1)*(d.pass.Dobro and 2 or 1)*mins end
		end
	end
	gold=math.floor(gold);d.gold+=gold;d.last=now;return gold
end
G.Actions={}
local A=G.Actions
function A.Home(p) if not Sanctuary.home(p) then return fail("Personagem ou destino indisponível. Aguarde e tente novamente.") end;return ok(p,"Bem-vindo ao seu santuário") end
function A.Travel(p,id)
 local d=Data.get(p);local def=I.ById[id];local root=p.Character and p.Character:FindFirstChild("HumanoidRootPart")
 if not def or not d.unlocked[id] or not root then return fail("Destino indisponível") end
 if not Transport.go(p,I.pos(def.idx)+Vector3.new(0,9,24)) then return fail("Destino ainda não carregou. Tente novamente.") end
 return ok(p,"Chegou a "..def.name)
end
function A.Companion(p,uid)
 local d=Data.get(p)
 if uid~=nil and not d.creatures[uid] then return fail("Escolha uma fera sua") end
 if d.companion==uid then d.companion=nil else d.companion=uid end
 World.refresh(p);return ok(p,d.companion and "Companheiro escolhido" or "Companheiro guardado")
end
function A.Pet(p)
 local d=Data.get(p);if not d.companion then return fail("Escolha um companheiro") end
 p:SetAttribute("PetHappyUntil",workspace:GetServerTimeNow()+2);return ok(p,"Seu companheiro gostou do carinho!")
end
function A.BuildHabitat(p,id,slot)
 local d=Data.get(p);local def=I.ById[id]
 if not def or not d.unlocked[id] or d.sanctuary[id] or not SR.available(d.sanctuary,slot) then return fail("Habitat, posição ou desbloqueio inválido") end
 local cost=SR.buildCost(def);if d.gold<cost then return fail("Precisa de "..cost.." ouro") end
 d.gold-=cost;d.sanctuary[id]={slot=slot,level=1};bump(d,"habitatBuild");World.refresh(p);return ok(p,"Habitat construído no seu terreno")
end
function A.MoveHabitat(p,id,slot)
 local d=Data.get(p);local entry=d.sanctuary[id]
 if not entry or not SR.available(d.sanctuary,slot,id) then return fail("Posição ocupada ou inválida") end
 entry.slot=slot;World.refresh(p);return ok(p,"Habitat movido")
end
function A.UpgradeHabitat(p,id)
 local d=Data.get(p);local entry=d.sanctuary[id]
 if not entry or entry.level>=SR.MaxLevel then return fail("Habitat indisponível ou máximo") end
 local cost=SR.upgradeCost(entry);if d.gold<cost then return fail("Precisa de "..cost.." ouro") end
 settle(p);d.gold-=cost;entry.level+=1;bump(d,"habitatUpgrade");World.refresh(p);return ok(p,"Habitat melhorado: mais duas vagas")
end
function A.RemoveHabitat(p,id)
 local d=Data.get(p)
 if not d.sanctuary[id] or #(d.habitat[id] or {})>0 then return fail("Transfira as feras antes de remover o habitat") end
 d.sanctuary[id]=nil;World.refresh(p);return ok(p,"Estrutura removida, sem reembolso")
end
function A.ClaimStory(p,id)
 local d=Data.get(p);if not Story.canClaim(d,id) then return fail("Conclua o capítulo atual primeiro") end
 local q=Story.ById[id];d.storyClaimed[id]=true;d.gold+=q.gold;d.seals=math.min(10000,d.seals+q.seals);Progression.award(d,q.xp)
 return ok(p,"Capítulo concluído! +"..q.gold.." ouro, +"..q.xp.." XP e +"..q.seals.." selos")
end
function A.CraftSeal(p,kind)
 local d=Data.get(p);kind=kind or "Basic";local recipe=CaptureRules.Seals[kind]
 if not recipe then return fail("Tipo de selo inválido") end
 local count=kind=="Basic" and d.seals or d.sealStock[kind] or 0
 if count>=10000 or d.gold<recipe.cost or d.playerLevel<recipe.level then return fail("Precisa de nível "..recipe.level.." e "..recipe.cost.." ouro; limite 10 mil selos") end
 if recipe.material and (d.materials[recipe.material] or 0)<recipe.amount then return fail("Precisa de "..recipe.amount.." essência de "..recipe.material) end
 d.gold-=recipe.cost
 if recipe.material then d.materials[recipe.material]-=recipe.amount end
 if kind=="Basic" then d.seals+=1 else d.sealStock[kind]=count+1 end
 return ok(p,"+1 Selo "..recipe.name)
end
function A.Get(p) return ok(p) end
function A.Collect(p) local g=settle(p);bump(Data.get(p),"collect");return ok(p,"+"..g.." ouro") end
function A.Feed(p,uid)
	local d=Data.get(p);local cr=d.creatures[uid]
	if not cr then return fail("Criatura inválida") end
	if cr.lv>=MAXLV then return fail("Nível máximo") end
	settle(p);local cost=cr.lv*20
	if d.gold<cost then return fail("Ouro insuficiente ("..cost..")") end
	d.gold-=cost;cr.lv+=1;bump(d,"feed");World.refresh(p);return ok(p,"Subiu para o nível "..cr.lv..(C.stage(cr.lv,cr.id)>C.stage(cr.lv-1,cr.id) and " — EVOLUIU!" or ""))
end
function A.Place(p,uid,isl)
	local d=Data.get(p);local def=I.ById[isl]
	if not d.creatures[uid] or not def or not d.unlocked[isl] then return fail("Ilha ou criatura inválida") end
	local structure=d.sanctuary[isl]
 if not structure then return fail("Construa esse habitat no Santuário") end
 local creature=C.ById[d.creatures[uid].id]
 if creature.el~=def.el and not (creature.hybrid and table.find(creature.hybrid,def.el)) then return fail("Elemento incompatível com este habitat") end
 local list=d.habitat[isl] or {}
	if #list-(table.find(list,uid) and 1 or 0)>=SR.capacity(def,structure) then return fail("Habitat cheio") end
	settle(p)
	for _,l in d.habitat do local i=table.find(l,uid);if i then table.remove(l,i) end end
	d.habitat[isl]=d.habitat[isl] or {};table.insert(d.habitat[isl],uid);World.refresh(p)
	return ok(p,C.ById[d.creatures[uid].id].name.." agora vive em "..def.name)
end
function A.Unlock(p,isl)
	local d=Data.get(p);local def=I.ById[isl]
	if not def or d.unlocked[isl] then return fail("Ilha inválida") end
	if (d.playerLevel or 1)<(def.minLevel or 1) then return fail("Explorador nível "..def.minLevel.." necessário") end
 if d.gold<def.cost then return fail("Precisa de "..def.cost.." ouro") end
	d.gold-=def.cost;d.unlocked[isl]=true;return ok(p,def.name.." desbloqueada!")
end
function A.Breed(p,a,b)
	local d=Data.get(p)
	if a==b or not d.creatures[a] or not d.creatures[b] then return fail("Escolha duas feras diferentes") end
	if #d.eggs>=Balance.IncubatorSlots then return fail("Chocadeira cheia") end
	if d.gold<BREED_COST then return fail("Precisa de "..BREED_COST.." ouro") end
	d.gold-=BREED_COST;bump(d,"breed");local id=B.pick(d.creatures[a].id,d.creatures[b].id,rng);local r=C.ById[id].rar
	table.insert(d.eggs,{id=id,ready=os.time()+Balance.IncubationBase*r*r});return ok(p,"Ovo misterioso! Eclode em "..Balance.IncubationBase*r*r.."s")
end
function A.Hatch(p,i)
	local d=Data.get(p);local e=typeof(i)=="number" and d.eggs[i]
	if not e then return fail("Ovo inválido") end
	if os.time()<e.ready then return fail("Ainda não eclodiu") end
	local n=0;for _ in d.creatures do n+=1 end
	if n>=Balance.InventoryLimit then return fail("Limite de 60 feras") end
	while d.creatures["u"..d.nextId] do d.nextId+=1 end
 local uid="u"..d.nextId;d.nextId+=1;d.creatures[uid]={id=e.id,lv=1,xp=0};d.discovered[e.id]=true;table.remove(d.eggs,i);bump(d,"hatch")
	return ok(p,"Nasceu "..C.ById[e.id].name.."!")
end
function A.Battle(p,uid,isl)
	local d=Data.get(p);local cr=d.creatures[uid];local def=I.ById[isl]
	if not cr or not def or not d.unlocked[isl] then return fail("Batalha inválida") end
	if lastBattle[p] and os.clock()-lastBattle[p]<20 then return fail("Suas feras descansam: "..math.ceil(20-(os.clock()-lastBattle[p])).."s") end
	lastBattle[p]=os.clock();bump(d,"fight")
	local pool={};for _,c in C.List do if c.island==isl then table.insert(pool,c) end end
	if #pool==0 then for _,c in C.List do if c.el==def.el and c.rar<=2 then table.insert(pool,c) end end end
 local g=pool[rng:NextInteger(1,#pool)];local glv=math.min(MAXLV,(def.minLevel or 1)+g.rar*2);local me=C.ById[cr.id]
	local m1,m2=me.hp*lvMul(cr.lv),g.hp*lvMul(glv);local hp1,hp2,log=m1,m2,{}
	for _=1,40 do
		local x=me.atk*lvMul(cr.lv)*E.mult(me.el,g.el);hp2-=x
		table.insert(log,{me=true,dmg=math.floor(x),hp=math.max(0,hp2)/m2,mult=E.mult(me.el,g.el)});if hp2<=0 then break end
		x=g.atk*lvMul(glv)*E.mult(g.el,me.el);hp1-=x
		table.insert(log,{me=false,dmg=math.floor(x),hp=math.max(0,hp1)/m1,mult=E.mult(g.el,me.el)});if hp1<=0 then break end
	end
	local info={log=log,me={id=cr.id,lv=cr.lv},foe={id=g.id,lv=glv},win=hp2<=0}
	if hp2>0 then local r=ok(p,"Derrota para "..g.name.." (Nv."..glv.."). Treine e tente de novo!");r.battle=info;return r end
	local gold=math.floor(12*def.idx*g.rar*(me.el==M.event(os.time()) and 1.25 or 1));local gem=rng:NextNumber()<0.2 and 1 or 0
	d.gold+=gold;d.gems+=gem;d.wins+=1;bump(d,"win")
	local r=ok(p,"Vitória sobre "..g.name.."! +"..gold.." ouro"..(gem>0 and " +1 gema" or ""));r.battle=info;return r
end

function A.Claim(p,id)
	local d=Data.get(p);local m=M.ById[id]
	if not m or d.claimed[id] or M.progress(d,m.stat)<m.goal then return fail("Missão indisponível") end
	d.claimed[id]=true;d.gold+=m.gold;d.gems+=m.gems;return ok(p,"Recompensa: +"..m.gold.." ouro, +"..m.gems.." gemas")
end
function A.BuyEgg(p,isl)
	local d=Data.get(p);local def=I.ById[isl]
	if not def or not d.unlocked[isl] then return fail("Ilha inválida") end
	if #d.eggs>=Balance.IncubatorSlots then return fail("Chocadeira cheia") end
	local cost=80*def.idx;if d.gold<cost then return fail("Precisa de "..cost.." ouro") end
	local pool,tot={},0
	for _,c in C.List do if c.island==isl and c.rar<=3 then local w=1/(c.rar*c.rar);table.insert(pool,{c,w});tot+=w end end
	if #pool==0 then return fail("Não há ovos comerciais desta região nesta versão") end
 local r=rng:NextNumber()*tot;local pick=pool[1][1]
	for _,e in pool do r-=e[2];if r<=0 then pick=e[1];break end end
	d.gold-=cost;table.insert(d.eggs,{id=pick.id,ready=os.time()+Balance.IncubationBase*pick.rar*pick.rar});return ok(p,"Ovo de "..def.name.." comprado!")
end
function A.Speed(p,i)
	local d=Data.get(p);local e=typeof(i)=="number" and d.eggs[i]
	if not e then return fail("Ovo inválido") end
	local left=e.ready-os.time();if left<=0 then return fail("Já pode chocar") end
	local cost=math.max(1,math.ceil(left/30));if d.gems<cost then return fail("Precisa de "..cost.." gemas") end
	d.gems-=cost;e.ready=os.time();return ok(p,"Ovo acelerado!")
end
function A.Daily(p)
	local d=Data.get(p);local today=os.time()//86400
	if d.dailyDay>=today then return fail("Volte amanhã!") end
	d.streak=(d.dailyDay==today-1) and d.streak+1 or 1;d.dailyDay=today
	local gold=50*math.min(d.streak,7);local gem=d.streak%3==0 and 1 or 0
	d.gold+=gold;d.gems+=gem;return ok(p,"Dia "..d.streak.." seguido: +"..gold.." ouro"..(gem>0 and " +1 gema" or ""))
end
function A.Buy(p,key)
	if typeof(key)~="string" then return fail("Item inválido") end
	local s,m=Mon.buy(p,key);if not s then return fail(m) end;return ok(p,"Abrindo a compra...")
end
local Players=game:GetService("Players")
local invitations={}
local lastDuel=setmetatable({},{__mode="k"})
local function sim(ca,la,cb,lb)
	local m1,m2=ca.hp*lvMul(la),cb.hp*lvMul(lb);local hp1,hp2,log=m1,m2,{}
	for _=1,40 do
		local x=ca.atk*lvMul(la)*E.mult(ca.el,cb.el);hp2-=x
		table.insert(log,{me=true,dmg=math.floor(x),hp=math.max(0,hp2)/m2,mult=E.mult(ca.el,cb.el)});if hp2<=0 then break end
		x=cb.atk*lvMul(lb)*E.mult(cb.el,ca.el);hp1-=x
		table.insert(log,{me=false,dmg=math.floor(x),hp=math.max(0,hp1)/m1,mult=E.mult(cb.el,ca.el)});if hp1<=0 then break end
	end
	return log,hp2<=0
end
local function best(d) local b,bs;for _,cr in d.creatures do local sc=C.ById[cr.id].rar*10+cr.lv;if not bs or sc>bs then b,bs=cr,sc end end;return b end
-- Duelo online: sua melhor fera contra a melhor fera de outro jogador do servidor (o rival não perde nada).
function A.Duel(p,tid)
	local t=typeof(tid)=="number" and Players:GetPlayerByUserId(tid);local d=Data.get(p);local td=t and Data.get(t)
	if not td or t==p then return fail("Jogador indisponível") end
	local key=tostring(p.UserId)..":"..tostring(t.UserId)
 local reverse=tostring(t.UserId)..":"..tostring(p.UserId)
 if not invitations[reverse] or invitations[reverse]<os.clock() then
  invitations[key]=os.clock()+30
  return ok(p,"Convite enviado. O rival deve tocar Desafiar no seu nome em até 30s para aceitar.")
 end
 invitations[reverse]=nil;invitations[key]=nil
 if lastDuel[p] and os.clock()-lastDuel[p]<30 then return fail("Suas feras descansam: "..math.ceil(30-(os.clock()-lastDuel[p])).."s") end
	lastDuel[p]=os.clock()
	local a,b=best(d),best(td);local log,win=sim(C.ById[a.id],a.lv,C.ById[b.id],b.lv)
	local info={log=log,me={id=a.id,lv=a.lv},foe={id=b.id,lv=b.lv},win=win}
	if not win then local r=ok(p,"Derrota para "..t.DisplayName..". Treine e tente de novo!");r.battle=info;return r end
	local gold=40+5*b.lv;d.gold+=gold;d.trophies+=1;bump(d,"duelwin")
	local r=ok(p,"Vitória contra "..t.DisplayName.."! +"..gold.." ouro, +1 troféu");r.battle=info;return r
end
function A.Tut(p) Data.get(p).tut=true;return ok(p,"Tutorial concluído!") end
return G
