--!nonstrict
local DSS=game:GetService("DataStoreService");local RS=game:GetService("ReplicatedStorage")
local C=require(RS.Shared.Creatures);local I=require(RS.Shared.Islands)
local M=require(RS.Shared.Missions)
local store=DSS:GetDataStore("ArquipelagoV1")
local D={};local profiles={}
local VERSION=3
local sessions={}
local Http=game:GetService("HttpService")
local LEASE=180
local function clone(t) local out={};for k,v in t do out[k]=typeof(v)=="table" and clone(v) or v end;return out end
local function default()
	return {v=VERSION,gold=100,gems=5,seals=5,nextId=3,last=os.time(),wins=0,
		creatures={u1={id="cinzelo",lv=1,xp=0},u2={id="bolhinho",lv=1,xp=0}},eggs={},
		stats={},claimed={},pass={},receipts={},dailyDay=0,streak=0,trophies=0,tut=false,habitat={Brasa={"u1","u2"}},unlocked={Brasa=true},discovered={cinzelo=true,bolhinho=true}}
end
-- Valida e migra dados salvos; corrompido => padrão (por campo quando possível).
function D.validate(raw)
	local d=default();if typeof(raw)~="table" or typeof(raw.creatures)~="table" then return d end
	local function num(x,f,mx) return (typeof(x)=="number" and x==x and x>=0 and x<=mx) and math.floor(x) or f end
	d.seals=num(raw.seals,5,10000)
	d.gold=num(raw.gold,d.gold,1e12);d.gems=num(raw.gems,d.gems,1e9);d.wins=num(raw.wins,0,1e9);d.nextId=num(raw.nextId,d.nextId,1e9)
	d.last=math.min(num(raw.last,os.time(),1e12),os.time())
	local cr,n={},0
	for uid,c in raw.creatures do
		if typeof(uid)=="string" and typeof(c)=="table" and C.ById[c.id] and n<60 then cr[uid]={id=c.id,lv=math.clamp(num(c.lv,1,20),1,20),xp=num(c.xp,0,1e9)};n+=1 end
	end
	if n==0 then return d end
	for uid in cr do local n=tonumber(string.match(uid,"^u(%d+)$"));if n then d.nextId=math.max(d.nextId,n+1) end end
	d.creatures=cr;d.discovered={};for _,c in cr do d.discovered[c.id]=true end
	if typeof(raw.discovered)=="table" then for id in raw.discovered do if C.ById[id] then d.discovered[id]=true end end end
	d.unlocked={Brasa=true}
	if typeof(raw.unlocked)=="table" then for id in I.ById do if raw.unlocked[id]==true then d.unlocked[id]=true end end end
	d.habitat={};local seen={}
	if typeof(raw.habitat)=="table" then
		for isl,list in raw.habitat do
			local def=I.ById[isl]
			if def and d.unlocked[isl] and typeof(list)=="table" then
				d.habitat[isl]={}
				for _,uid in list do
					if typeof(uid)=="string" and cr[uid] and not seen[uid] and #d.habitat[isl]<def.slots then seen[uid]=true;table.insert(d.habitat[isl],uid) end
				end
			end
		end
	end
	d.stats={};d.claimed={}
	if typeof(raw.stats)=="table" then for k,v in raw.stats do if typeof(k)=="string" then d.stats[k]=num(v,0,1e9) end end end
	if typeof(raw.claimed)=="table" then for id,value in raw.claimed do if value==true and M.ById[id] then d.claimed[id]=true end end end
	d.trophies=num(raw.trophies,0,1e9);d.tut=raw.tut==true
	d.receipts={};d.pass={};d.dailyDay=math.min(num(raw.dailyDay,0,1e9),os.time()//86400);d.streak=num(raw.streak,0,1e6)
	if typeof(raw.receipts)=="table" then for k,value in raw.receipts do if value==true and typeof(k)=="string" then d.receipts[k]=true end end end
	d.eggs={}
	if typeof(raw.eggs)=="table" then
		for _,e in raw.eggs do
			if #d.eggs<3 and typeof(e)=="table" and C.ById[e.id] and typeof(e.ready)=="number" and e.ready==e.ready and e.ready>=0 and e.ready<1e12 then table.insert(d.eggs,{id=e.id,ready=math.floor(e.ready)}) end
		end
	end
	return d
end
-- Lease gravado atomicamente no MESMO registro legado (sem trocar a chave).
function D.load(p)
 local token=Http:GenerateGUID(false)
 local raw,ok
 for attempt=1,3 do
  ok,raw=pcall(function()
   return store:UpdateAsync("P"..p.UserId,function(old)
    if old~=nil and (typeof(old)~="table" or typeof(old.creatures)~="table" or (old.v or 1)>VERSION) then error("Perfil inválido ou versão futura; recuperação manual necessária") end
    local lock=old and old._session
    if lock and typeof(lock)~="table" then error("Lease inválido") end
    if lock and lock.token~=token and (lock.expires or 0)>os.time() then return nil end
    local data=D.validate(old);data._session={token=token,expires=os.time()+LEASE};return data
   end)
  end)
  if ok then break end;task.wait(attempt)
 end
 if not ok or not raw then p:Kick("Dados indisponíveis ou sessão ainda ativa. Aguarde e reconecte; nada foi reiniciado.");return false end
 profiles[p]=D.validate(raw);sessions[p]={token=token,expires=raw._session.expires,busy=false}
 return true
end
function D.get(p)
 local session=sessions[p]
 if not session or session.expires<=os.time() or session.closing then return nil end
 return profiles[p]
end
function D.snapshot(p)
 local d=clone(profiles[p]);d.receipts=nil;for _,e in d.eggs do e.left=math.max(0,e.ready-os.time()) end
 local el,left=M.event(os.time());d.event={el=el,left=left};return d
end
function D.save(p,release)
 local session=sessions[p];local d=profiles[p]
 if not session or not d then return false end
 while session.busy do task.wait() end
 if sessions[p]~=session then return false end
 session.busy=true
 local payload=clone(d);payload.pass=nil;payload.event=nil
 for _,egg in payload.eggs do egg.left=nil end
 local expiry=os.time()+LEASE
 payload._session=not release and {token=session.token,expires=expiry} or nil
 local ok,result=pcall(function()
  return store:UpdateAsync("P"..p.UserId,function(old)
   if not old or not old._session or old._session.token~=session.token then return nil end
   return payload
  end)
 end)
 session.busy=false
 if ok and result then session.expires=expiry;return true end
 warn("Falha ao salvar perfil de "..p.Name)
 if ok or os.time()>=session.expires then
  session.closing=true;p:Kick("Sessão de dados encerrada. Reconecte para proteger seu progresso.")
 end
 return false
end
function D.release(p)
 local session=sessions[p];if not session then return end
 session.closing=true
 for _=1,3 do if D.save(p,true) then break end;task.wait(1) end
 profiles[p]=nil;sessions[p]=nil
end
function D.saveAll() for p in profiles do D.save(p) end end
function D.closeAll()
 local pending=0
 for p in profiles do pending+=1;task.spawn(function() D.release(p);pending-=1 end) end
 local deadline=os.clock()+25
 while pending>0 and os.clock()<deadline do task.wait(.1) end
end
return D
