-- Dependências Roblox simuladas: verifica transações e protocolo, não rede real.
local Random={new=function() return {NextNumber=function() return 0 end} end}
local clock=0;local now=10000
local os={clock=function() return clock end,time=function() return now end}
local data={};local releaseCount=0;local registry={};local emitted={};local removal
local Players={PlayerRemoving={Connect=function(_,callback) removal=callback end}}
local RS={};local Http={GenerateGUID=function() return "token"..tostring(clock) end}
local game={GetService=function(_,name) return ({ReplicatedStorage=RS,Players=Players,HttpService=Http})[name] end}
local Instance={new=function()
 local obj={FireClient=function(_,player,snapshot) emitted[player]=snapshot end}
 return setmetatable(obj,{__newindex=function(t,k,v) rawset(t,k,v);if k=="Name" then registry[v]=t end end})
end}
local task={spawn=function() end,wait=function() end}
local Region={current=function() return "Brasa" end,requireCurrent=function() return {ok=true} end}
local holdSave=false;local saved={}
local Data={save=function(p) if holdSave then coroutine.yield("SAVE_YIELD") end;saved[p]=data[p] and {cooldown=data[p].phoenix and data[p].phoenix.nextAttemptAt};return true end,get=function(p) return data[p] end}
local World={refresh=function() end}
local vector=setmetatable({},{__sub=function() return {Magnitude=0} end})
local function player()
 return {SetAttribute=function() end,Character={FindFirstChild=function() return {Position=vector} end,FindFirstChildOfClass=function() return {Health=100} end}}
end
local SanctuaryBuilder={altarPosition=function() return vector end}
-- SERVICE_MODULE
local p=player();data[p]={gold=100,seals=3,nextId=3,creatures={u1={id="magmarau",lv=20,xp=0}},stats={},discovered={},wins=0,guardians={},sealStock={},playerLevel=1,playerXp=0}
E.start();local net=registry.EncounterNet
local function open()
 clock+=1
 assert(E.open(p,{id="cinzelo",lv=1,position=vector},function() releaseCount+=1 end))
 return emitted[p]
end
local function request(state,action,uid)
 clock+=1;return net.OnServerInvoke(p,state.token,state.version,action,uid)
end
local s=open()
assert(net.OnServerInvoke(p,"forged",0,"Capture")==nil)
local resume=net.OnServerInvoke(p,"",0,"Resume");assert(resume.token==s.token and data[p].seals==3)
local old=s
s=net.OnServerInvoke(p,s.token,999,"Capture");assert(data[p].seals==3 and s.version==0)
s=request(s,"Capture")
-- RNG fixo abaixo faz a captura ter sucesso: uma única concessão e débito.
assert(s.status=="captured" and data[p].seals==2 and data[p].creatures.u3)
local n=releaseCount
request(old,"Capture");assert(data[p].seals==2 and releaseCount==n and not data[p].creatures.u4)
s=open();s=request(s,"Select"," чужой");assert(s.version==0)
s=request(s,"Select","u1");assert(s.version==1)
while s.status=="active" do s=request(s,"Strike") end
assert(s.status=="won" and data[p].gold>100 and data[p].wins==1)
local gold=data[p].gold;request(s,"Strike");assert(data[p].gold==gold and data[p].wins==1)
s=open();now+=151;s=request(s,"Capture");assert(s.status=="escaped" and data[p].seals==2)
s=open();removal(p);assert(not E.active(p))
print("PASS: protocolo do encontro: token, versão, propriedade, débito único, concessão única, recompensa única, timeout e saída")
-- V6: estoque separado e desafios de guardião sem captura.
clock+=1;assert(E.open(p,{id="cinzelo",lv=1,position=vector},function() releaseCount+=1 end));s=emitted[p]
data[p].sealStock.Rare=1
s=request(s,"ChooseSeal","Rare");assert(s.sealType=="Rare" and s.seals==1)
s=request(s,"Capture");assert(s.status=="captured" and data[p].sealStock.Rare==0 and data[p].seals==2)
clock+=1;assert(E.open(p,{id="cinzelo",lv=1,position=vector,capturable=false,guardianId="Brasa"},function() releaseCount+=1 end));s=emitted[p]
local before=data[p].seals;s=request(s,"Capture");assert(s.version==0 and data[p].seals==before)
s=request(s,"Select","u1")
while s.status=="active" do s=request(s,"Strike") end
assert(data[p].guardians.Brasa and data[p].stats.guardian==1)
local oldGold=data[p].gold;request(s,"Strike");assert(data[p].gold==oldGold and data[p].stats.guardian==1)
print("PASS: estoque de selo separado, guardião incapturável e bônus de desafio único")

-- V7: concorrência cooperativa no serviço REAL, interrompendo as duas escritas.
local function solarProfile()
 return {gold=100,seals=30,sealStock={},nextId=2,creatures={u1={id="magmarau",lv=55,xp=0}},stats={},discovered={},wins=0,guardians={},playerLevel=50,playerXp=0,unlocked={Dunas=true},phoenix={glyphs={duneHidden=true,duneRuin=true,skyPeak=true},sanctuaryOpen=true,attempts=0,nextAttemptAt=0,captured=false},grants={}}
end
p=player();data[p]=solarProfile();holdSave=true
local begin=coroutine.create(function() return E.startSpecial(p,"phoenix_solar") end)
local ok,yielded=coroutine.resume(begin);assert(ok and yielded=="SAVE_YIELD" and E.active(p))
for _=1,100 do assert(not E.startSpecial(p,"phoenix_solar")) end
holdSave=false;assert(coroutine.resume(begin));s=emitted[p];assert(s and s.foe.lv==60 and s.intro=="phoenix")
holdSave=true
local capturing=coroutine.create(function() return request(s,"Capture") end)
ok,yielded=coroutine.resume(capturing);assert(ok and yielded=="SAVE_YIELD")
for _=1,100 do request(s,"Capture") end
local n=0;for _,cr in data[p].creatures do if cr.id=="fenix" then n+=1 end end
assert(n==1 and data[p].seals==29 and data[p].phoenix.captured)
holdSave=false;assert(coroutine.resume(capturing));assert(saved[p].cooldown==data[p].phoenix.nextAttemptAt)
assert(not E.startSpecial(p,"phoenix_solar"))
-- Desconexão enquanto a tentativa é persistida não pode abrir ou conceder depois.
local quitting=player();data[quitting]=solarProfile();holdSave=true
local pending=coroutine.create(function() return E.startSpecial(quitting,"phoenix_solar") end)
assert(coroutine.resume(pending));removal(quitting);data[quitting]=nil;holdSave=false
assert(coroutine.resume(pending));assert(not E.active(quitting) and emitted[quitting]==nil)
print("PASS V7.09: reentrada durante yield, 101 capturas intercaladas = 1 concessão/débito, cooldown e desconexão na abertura")
