local Region={current=function() return "Brasa" end,requireContext=function() return {ok=true} end}
local profiles={};local Data={get=function(p) return profiles[p] end,snapshot=function(p) return profiles[p] end}
local World={refresh=function() end};local Sanctuary={home=function() return true end}
local Transport={go=function() return true end}
local Mon={buy=function() return false,"desativado" end}
local Random={new=function() return {NextNumber=function() return .5 end,NextInteger=function(_,a) return a end} end}
local Players={GetPlayerByUserId=function() return nil end}
local game={GetService=function(_,name) return name=="Players" and Players or {} end}
local workspace={GetServerTimeNow=function() return 123 end}
-- GAME_MODULE
local a,b={UserId=1},{UserId=2}
local function profile()
 return {gold=2000,gems=5,seals=5,sealStock={},playerLevel=50,playerXp=0,creatures={u1={id="cinzelo",lv=1},u2={id="bolhinho",lv=1}},sanctuary={Brasa={slot=1,level=1}},habitat={Brasa={"u1"}},unlocked={Brasa=true,Recife=true},materials={Natureza=1,Terra=1,Sombra=2},pass={},last=os.time(),stats={},storyClaimed={}}
end
profiles[a]=profile();profiles[b]=profile();local d=profiles[a]
assert(G.Actions.BuildHabitat(a,"Recife",2).ok and d.sanctuary.Recife.slot==2)
assert(profiles[b].gold==2000 and not profiles[b].sanctuary.Recife)
assert(not G.Actions.MoveHabitat(a,"Brasa",2).ok)
assert(G.Actions.MoveHabitat(a,"Brasa",7).ok and d.sanctuary.Brasa.slot==7)
assert(G.Actions.UpgradeHabitat(a,"Brasa").ok and d.sanctuary.Brasa.level==2)
assert(not G.Actions.RemoveHabitat(a,"Brasa").ok)
assert(not G.Actions.Place(a,"u1","Recife").ok)
assert(G.Actions.Place(a,"u2","Recife").ok)
assert(not G.Actions.Place(a,"foreign","Recife").ok)
assert(G.Actions.Companion(a,"u1").ok and d.companion=="u1")
assert(G.Actions.Companion(a,"u1").ok and d.companion==nil)
assert(not G.Actions.Companion(a,"foreign").ok)
local old=d.gold
assert(G.Actions.CraftSeal(a,"Basic").ok and d.gold==old-25)
for _,kind in {"Reinforced","Elemental","Rare","Ancient"} do assert(G.Actions.CraftSeal(a,kind).ok and d.sealStock[kind]==1) end
old=d.gold;assert(not G.Actions.CraftSeal(a,"Elemental").ok and d.gold==old)
assert(not G.Actions.CraftSeal(a,"invented").ok)
assert(not G.Actions.Travel(a,"Pantano").ok)
d.stats.capture=1;assert(G.Actions.ClaimStory(a,"arrival").ok)
old=d.gold;assert(not G.Actions.ClaimStory(a,"arrival").ok and d.gold==old)
print("PASS: ações reais em serviços simulados: construir, mover, melhorar, capacidade, propriedade, companheiro, cinco selos e capítulos sem duplicação")
