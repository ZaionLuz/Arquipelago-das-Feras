from harness_modules import *
mods=['CreatureGrant','Strings','Creatures','Islands','Missions','SanctuaryRules','Story','CaptureRules','Migration','PhoenixQuest','Access']
s=replace((ROOT/'src/server/DataService.luau').read_text(encoding='utf-8'))
spec=(ROOT/'tests/data.spec.luau').read_text(encoding='utf-8').replace('-- DATA_FACTORY','local function factory()\n'+s+'\nend')
(ROOT/'tests/data.generated.luau').write_text((ROOT/'tests/roblox-structure-stub.luau').read_text(encoding='utf-8')+'\n'+shared(['Strings']+mods)+'\n'+spec, encoding='utf-8')
