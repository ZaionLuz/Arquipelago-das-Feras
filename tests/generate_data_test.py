from pathlib import Path
r=Path(__file__).resolve().parents[1]
parts=[(r/'tests/roblox-structure-stub.luau').read_text()]
mods=[('C','Creatures'),('I','Islands'),('M','Missions'),('SR','SanctuaryRules'),('Story','Story'),('CaptureRules','CaptureRules')]
for var,name in mods:
 s=(r/f'src/shared/{name}.luau').read_text().replace('require(script.Parent.Creatures)','C').replace('require(script.Parent.Islands)','I')
 parts.append(f'local {var}=(function()\n{s}\nend)()')
s=(r/'src/server/DataService.luau').read_text()
for name,var in [('Creatures','C'),('Islands','I'),('Missions','M'),('SanctuaryRules','SR'),('Story','Story'),('CaptureRules','CaptureRules')]:s=s.replace(f'require(RS.Shared.{name})',var)
spec=(r/'tests/data.spec.luau').read_text().replace('-- DATA_FACTORY','local function factory()\n'+s+'\nend')
parts.append(spec)
(r/'tests/data.generated.luau').write_text('\n'.join(parts))
