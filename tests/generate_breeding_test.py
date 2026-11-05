from harness_modules import *
checks=(ROOT/'tests/breeding.spec.luau').read_text()
(ROOT/'tests/breeding.generated.luau').write_text(shared(['Breeding'])+'\nlocal C=M_Creatures;local B=M_Breeding\n'+checks)
