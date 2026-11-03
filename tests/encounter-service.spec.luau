-- Dependências Roblox simuladas: verifica transações e protocolo, não rede real.
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
local Data={get=function(p) return data[p] end}
local World={refresh=function() end}
local vector=setmetatable({},{__sub=function() return {Magnitude=0} end})
local function player()
 return {Character={FindFirstChild=function() return {Position=vector} end,FindFirstChildOfClass=function() return {Health=100} end}}
end
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
