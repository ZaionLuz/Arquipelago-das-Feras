from pathlib import Path
r=Path(__file__).resolve().parents[1]
parts=[]
for var,name in [('P','Progression'),('SR','SanctuaryRules'),('Story','Story'),('Capture','CaptureRules')]:
 parts.append(f'local {var}=(function()\n'+(r/f'src/shared/{name}.luau').read_text()+'\nend)()')
parts.append((r/'tests/rpg.spec.luau').read_text())
(r/'tests/rpg.generated.luau').write_text('\n'.join(parts))
