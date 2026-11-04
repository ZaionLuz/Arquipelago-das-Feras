from harness_modules import *
(ROOT/'tests/combat.generated.luau').write_text('local Color3={fromRGB=function() return {} end}\n'+shared(['CombatRules'])+'\nlocal C=M_Creatures;local Capture=M_CaptureRules;local Skills=M_Skills;local Elements=M_Elements;local R=M_CombatRules\n'+(ROOT/'tests/combat.spec.luau').read_text())
