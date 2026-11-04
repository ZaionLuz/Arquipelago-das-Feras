from harness_modules import *
s=(ROOT/'src/server/GameService.luau').read_text()
mods=re.findall(r'require\(RS.Shared.(\w+)\)',s)
s=replace(s)
for name,var in [('DataService','Data'),('World','World'),('MonetizationService','Mon'),('SanctuaryService','Sanctuary'),('Transport','Transport'),('RegionService','Region')]:s=s.replace(f'require(script.Parent.{name})',var)
spec=(ROOT/'tests/game-actions.spec.luau').read_text().replace('-- GAME_MODULE','local G=(function()\n'+s+'\nend)()')
(ROOT/'tests/game-actions.generated.luau').write_text((ROOT/'tests/roblox-structure-stub.luau').read_text()+'\n'+shared(['Strings']+mods)+'\n'+spec)
