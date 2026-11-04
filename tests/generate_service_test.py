from harness_modules import *
base='local Color3={fromRGB=function() return {} end}\n'+shared(['Strings','CombatRules','Progression','CreatureGrant','PhoenixQuest','Access'])+'\nlocal C=M_Creatures\n'
s=replace((ROOT/'src/server/EncounterService.luau').read_text())
s=s.replace('require(script.Parent.DataService)','Data').replace('require(script.Parent.RegionService)','Region').replace('require(script.Parent.World)','World').replace('require(script.Parent.SanctuaryBuilder)','SanctuaryBuilder')
s=s.replace('local rng=Random.new()','local rng={NextNumber=function() return 0 end}')
spec=(ROOT/'tests/encounter-service.spec.luau').read_text().replace('-- SERVICE_MODULE','local E=(function()\n'+s+'\nend)()')
(ROOT/'tests/encounter-service.generated.luau').write_text(base+'\n'+spec)
