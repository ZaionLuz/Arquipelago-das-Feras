-- Migração e leases com DataStore simulado; não valida APIs ou concorrência real.
local store={values={}}
local function copy(x) if type(x)~="table" then return x end;local t={};for k,v in x do t[k]=copy(v) end;return t end
function store:UpdateAsync(key,callback)
 if self.holdBefore then coroutine.yield("BEFORE_READ") end
 if self.fail then error("falha simulada") end
 local value=callback(copy(self.values[key]))
 if value==nil then return nil end;self.values[key]=copy(value);if self.holdAfter then coroutine.yield("AFTER_WRITE") end;return copy(value)
end
local serial=0
local Http={GenerateGUID=function() serial+=1;return tostring(serial) end}
local DSS={GetDataStore=function() return store end}
local game={GetService=function(_,name) return ({DataStoreService=DSS,ReplicatedStorage={},HttpService=Http})[name] end}
local task={wait=function() end,spawn=function(f) f() end}
local warn=function() end
local function who(id) return {UserId=id,Name="Teste",Kick=function(self,reason) self.kicked=reason end} end
-- DATA_FACTORY
local D=factory();local Other=factory()
local old={v=3,gold=432,gems=12,creatures={u1={id="cinzelo",lv=20,xp=70},u99={id="bolhinho",lv=100,xp=3}},nextId=3,unlocked={Brasa=true,Recife=true},habitat={Brasa={"u1","u99"}},seals=4}
local migrated=D.validate(old)
assert(migrated.v==6 and migrated.gold==432 and migrated.gems==12 and migrated.seals==4)
assert(migrated.creatures.u1.lv==20 and migrated.creatures.u99.lv==100 and migrated.nextId==100)
assert(migrated.sanctuary.Brasa and migrated.unlocked.Alvorecer and #migrated.habitat.Brasa==2)
local newer=copy(migrated);newer.companion="u99";newer.playerLevel=80;newer.playerXp=100;newer.materials={Natureza=5};newer.sealStock={Rare=3};newer.sanctuary.Brasa.level=3
newer.guardians={Brasa=true};newer.visited={Alvorecer=true};newer.storyClaimed={arrival=true}
local checked=D.validate(newer)
assert(checked.companion=="u99" and checked.playerLevel==80 and checked.materials.Natureza==5 and checked.sealStock.Rare==3)
assert(checked.sanctuary.Brasa.level==3 and checked.guardians.Brasa and checked.storyClaimed.arrival)
local a,b=who(1),who(1);assert(D.load(a));assert(not Other.load(b))
local data=D.get(a);data.gold=654;data.receipts.secret=true
local snap=D.snapshot(a);assert(snap.receipts==nil);snap.gold=1;assert(data.gold==654)
assert(D.save(a));assert(store.values.P1.gold==654)
D.release(a);local c=who(1);assert(Other.load(c));assert(Other.get(c).gold==654)
store.values.P1._session.token="alien";assert(not Other.save(c));assert(store.values.P1.gold==654)
store.fail=true;local failed=who(8);assert(not D.load(failed));assert(not store.values.P8)
print("PASS: migração v3→v6, UID, níveis, santuário, companion, inventário, snapshot, lease, sessão concorrente e falha de dados simulados")
-- V7: nenhum perfil inválido/futuro é substituído por um perfil inicial.
store.fail=false
for index,bad in {{v=99,creatures={u1={id="cinzelo",lv=1}},gold=888},{v=4,creatures={},gold=777},{v=4,creatures={u1={id="unknown",lv=5}},gold=666}} do
 local id=100+index;store.values["P"..id]=copy(bad);local whoBad=who(id)
 assert(not D.load(whoBad));assert(store.values["P"..id].gold==bad.gold and store.values["P"..id].v==bad.v)
end
local fresh=who(200);assert(D.load(fresh));local f=D.get(fresh)
assert(f.unlocked.Alvorecer and f.unlocked.Brasa and f.unlocked.Pantano and f.navigation.checkpoint=="Alvorecer")
assert(f.nextId==3 and f.creatures.u1.id=="brotinho" and f.creatures.u2.id=="folhuco")
local legacy=copy(old);legacy.creatures={};legacy.habitat={Brasa={}};legacy.eggs={}
for index=1,65 do legacy.creatures["u"..index]={id="cinzelo",lv=65,xp=250};table.insert(legacy.habitat.Brasa,"u"..index) end
for index=1,5 do table.insert(legacy.eggs,{id="fenix",ready=200}) end
local preserved=D.validate(legacy);local count=0;for _ in preserved.creatures do count+=1 end
assert(count==65 and #preserved.eggs==5 and #preserved.habitat.Brasa==65)
assert(preserved.gold==legacy.gold and preserved.creatures.u65.lv==65 and preserved.creatures.u65.xp==250)
assert(D.save(fresh));D.release(fresh);local round=who(200);assert(D.load(round));assert(D.get(round).creatures.u1.id=="brotinho")
print("PASS V7.01/13: corrupção/futuro intactos no storage, inicial no Alvorecer com regiões abertas, estoques legados acima do cap e round-trip")

for _,field in {"sanctuary","habitat","discovered"} do
 local corrupt=copy(old)
 if field=="sanctuary" then corrupt.sanctuary={Brasa={slot="invalid",level=1}}
 elseif field=="habitat" then corrupt.habitat={Brasa={"missing"}}
 else corrupt.discovered="invalid" end
 store.values.P999=copy(corrupt);local entrant=who(999);assert(not D.load(entrant));assert(store.values.P999.v==corrupt.v and store.values.P999.gold==corrupt.gold)
end
local futureTime=copy(old);futureTime.last=os.time()+500;futureTime.dailyDay=os.time()//86400+1
local keepTime=D.validate(futureTime);assert(keepTime.last==futureTime.last and keepTime.dailyDay==futureTime.dailyDay)
print("PASS: estruturas/flags corrompidos recusados antes da escrita; timestamps legados preservados")

local extras=copy(old);extras.creatures.u1.legacyCounter=123;extras.eggs={{id="cinzelo",ready=123,legacyQuality=8}};extras.materials={customLegacy=77};extras.sealStock={customLegacy=14}
local retain=D.validate(extras);assert(retain.creatures.u1.legacyCounter==123 and retain.eggs[1].legacyQuality==8 and retain.materials.customLegacy==77 and retain.sealStock.customLegacy==14)
print("PASS: metadados numéricos adicionais de criaturas, ovos e inventários preservados")

-- Cancelamento durante carregamento, antes e depois da escrita do lease.
for _,phase in {"Before","After"} do
 local id=phase=="Before" and 901 or 902;local entering=who(id);store.values["P"..id]=copy(old);store["hold"..phase]=true
 local loader=coroutine.create(function() return D.load(entering) end)
 local ok,stage=coroutine.resume(loader);assert(ok and (stage=="BEFORE_READ" or stage=="AFTER_WRITE"))
 D.release(entering);store["hold"..phase]=false
 local resumed,loaded=coroutine.resume(loader);assert(resumed and loaded==false)
 assert(D.get(entering)==nil and store.values["P"..id].gold==old.gold and store.values["P"..id]._session==nil)
end
-- Habitat criado fora da região inicial sobrevive ao novo round-trip.
local remoteHabitat=D.validate(old);remoteHabitat.sanctuary.Pantano={slot=8,level=1};remoteHabitat.habitat.Pantano={"u99"};remoteHabitat.habitat.Brasa={"u1"}
local reloaded=D.validate(remoteHabitat);assert(reloaded.unlocked.Pantano and reloaded.habitat.Pantano[1]=="u99")
print("PASS open world: cancelamento do load antes/depois do lease sem perfil fantasma; habitat em região livre preservado")

-- Bestiário40: novos IDs sobrevivem à validação, snapshot e ao save/load do mesmo schema6.
local expansionIds={"bambunim","brasebode","coralote","dunatatu","nimburso","lumissapo","nectarim","cristalince","maritromba","kraken"}
local expanded=copy(old);expanded.creatures=copy(old.creatures);expanded.habitat={Brasa={"u1"},Recife={"u99"}}
expanded.eggs={};expanded.discovered={};expanded.gold=9876;expanded.gems=321
for index,id in expansionIds do
 local uid="u"..(300+index);expanded.creatures[uid]={id=id,lv=15+index,xp=100+index,legacyCounter=index}
 expanded.discovered[id]=true
 if id~="kraken" then table.insert(expanded.eggs,{id=id,ready=400+index,legacyQuality=index}) end
end
expanded.companion="u310"
store.values.P400=copy(expanded);local collector=who(400);assert(D.load(collector))
local owned=D.get(collector);assert(owned.v==6 and owned.gold==9876 and owned.gems==321 and owned.companion=="u310")
local public=D.snapshot(collector)
for index,id in expansionIds do
 local uid="u"..(300+index)
 assert(owned.creatures[uid].id==id and public.creatures[uid].id==id and public.discovered[id])
 assert(owned.creatures[uid].legacyCounter==index and owned.creatures[uid].lv==15+index)
end
assert(#owned.eggs==9 and owned.creatures.u1.id=="cinzelo" and owned.creatures.u99.id=="bolhinho")
assert(D.save(collector));D.release(collector);local reopened=who(400);assert(Other.load(reopened))
local after=Other.get(reopened);assert(after.v==6 and after.gold==9876 and after.gems==321 and after.companion=="u310" and #after.eggs==9)
for index,id in expansionIds do
 local row=after.creatures["u"..(300+index)]
 assert(row.id==id and row.lv==15+index and row.xp==100+index and row.legacyCounter==index and after.discovered[id])
 if index<=9 then assert(after.eggs[index].id==id and after.eggs[index].legacyQuality==index) end
end
assert(after.creatures.u1.lv==20 and after.creatures.u99.lv==100 and after.habitat.Brasa[1]=="u1" and after.habitat.Recife[1]=="u99")
Other.release(reopened)
print("PASS bestiário40: 10 novos IDs, Kraken companion, 9 ovos elegíveis e criaturas/inventários legados preservados em snapshot e round-trip schema6")
