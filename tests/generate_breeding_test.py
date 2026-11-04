from harness_modules import *
p=ROOT/'tests/breeding.generated.luau'
checks=p.read_text().split('local seed=17',1)[1]
p.write_text(shared(['Breeding'])+'\nlocal C=M_Creatures;local B=M_Breeding\nlocal seed=17'+checks)
