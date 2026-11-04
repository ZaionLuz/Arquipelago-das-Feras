-- Migração e leases com DataStore simulado; não valida APIs ou concorrência real.
local store={values={}}
local function copy(x) if type(x)~="table" then return x end;local t={};for k,v in x do t[k]=copy(v) end;return t end
function store:UpdateAsync(key,callback)
 if self.fail then error("falha simulada") end
 local value=callback(copy(self.values[key]))
 if value==nil then return nil end;self.values[key]=copy(value);return copy(value)
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
assert(migrated.v==5 and migrated.gold==432 and migrated.gems==12 and migrated.seals==4)
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
print("PASS: migração v3→v5, UID, níveis, santuário, companion, inventário, snapshot, lease, sessão concorrente e falha de dados simulados")
-- V7: nenhum perfil inválido/futuro é substituído por um perfil inicial.
store.fail=false
for index,bad in {{v=99,creatures={u1={id="cinzelo",lv=1}},gold=888},{v=4,creatures={},gold=777},{v=4,creatures={u1={id="unknown",lv=5}},gold=666}} do
 local id=100+index;store.values["P"..id]=copy(bad);local whoBad=who(id)
 assert(not D.load(whoBad));assert(store.values["P"..id].gold==bad.gold and store.values["P"..id].v==bad.v)
end
local fresh=who(200);assert(D.load(fresh));local f=D.get(fresh)
assert(f.unlocked.Alvorecer and not f.unlocked.Brasa and not f.unlocked.Recife)
assert(f.nextId==3 and f.creatures.u1.id=="brotinho" and f.creatures.u2.id=="folhuco")
local legacy=copy(old);legacy.creatures={};legacy.habitat={Brasa={}};legacy.eggs={}
for index=1,65 do legacy.creatures["u"..index]={id="cinzelo",lv=65,xp=250};table.insert(legacy.habitat.Brasa,"u"..index) end
for index=1,5 do table.insert(legacy.eggs,{id="fenix",ready=200}) end
local preserved=D.validate(legacy);local count=0;for _ in preserved.creatures do count+=1 end
assert(count==65 and #preserved.eggs==5 and #preserved.habitat.Brasa==65)
assert(preserved.gold==legacy.gold and preserved.creatures.u65.lv==65 and preserved.creatures.u65.xp==250)
assert(D.save(fresh));D.release(fresh);local round=who(200);assert(D.load(round));assert(D.get(round).creatures.u1.id=="brotinho")
print("PASS V7.01/13: corrupção/futuro intactos no storage, inicial só Alvorecer, estoques legados acima do cap e round-trip")
