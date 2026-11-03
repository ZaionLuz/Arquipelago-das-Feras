from pathlib import Path
r=Path(__file__).resolve().parents[1]
parts=[(r/'tests/roblox-structure-stub.luau').read_text()]
mods=[('C','Creatures'),('I','Islands'),('E','Elements'),('B','Breeding'),('M','Missions'),('SR','SanctuaryRules'),('Story','Story'),('CaptureRules','CaptureRules'),('Progression','Progression'),('Balance','Economy')]
for var,name in mods:
 s=(r/f'src/shared/{name}.luau').read_text().replace('require(script.Parent.Creatures)','C').replace('require(script.Parent.Islands)','I')
 parts.append(f'local {var}=(function()\n{s}\nend)()')
s=(r/'src/server/GameService.luau').read_text()
for var,name in mods:s=s.replace(f'require(RS.Shared.{name})',var)
for name,var in [('DataService','Data'),('World','World'),('MonetizationService','Mon'),('SanctuaryService','Sanctuary'),('Transport','Transport')]:s=s.replace(f'require(script.Parent.{name})',var)
spec=(r/'tests/game-actions.spec.luau').read_text().replace('-- GAME_MODULE','local G=(function()\n'+s+'\nend)()')
parts.append(spec);(r/'tests/game-actions.generated.luau').write_text('\n'.join(parts))
