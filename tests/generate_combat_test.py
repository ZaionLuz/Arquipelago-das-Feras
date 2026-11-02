from pathlib import Path
r=Path(__file__).resolve().parents[1]
modules=[('C','Creatures'),('Capture','CaptureRules'),('Skills','Skills'),('Elements','Elements'),('R','CombatRules')]
parts=['local Color3={fromRGB=function(...) return {} end}']
for var,name in modules:
 s=(r/f'src/shared/{name}.luau').read_text()
 for old,new in [('Creatures','C'),('CaptureRules','Capture'),('Skills','Skills'),('Elements','Elements')]:s=s.replace(f'require(script.Parent.{old})',new)
 parts.append(f'local {var}=(function()\n{s}\nend)()')
parts.append((r/'tests/combat.spec.luau').read_text())
(r/'tests/combat.generated.luau').write_text('\n'.join(parts))
