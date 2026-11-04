from harness_modules import *
parts=[shared(['Progression','SanctuaryRules','Story','CaptureRules'])+'\nlocal P=M_Progression;local SR=M_SanctuaryRules;local Story=M_Story;local Capture=M_CaptureRules']
parts.append((ROOT/'tests/rpg.spec.luau').read_text())
(ROOT/'tests/rpg.generated.luau').write_text('\n'.join(parts))
