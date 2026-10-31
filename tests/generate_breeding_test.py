from pathlib import Path
r=Path(__file__).resolve().parents[1]
target=r/'tests/breeding.generated.luau'
checks=target.read_text().split('local seed=17',1)[1]
c=(r/'src/shared/Creatures.luau').read_text()
b=(r/'src/shared/Breeding.luau').read_text().replace('local C=require(script.Parent.Creatures)','')
target.write_text('local C=(function()\n'+c+'\nend)()\nlocal B=(function()\n'+b+'\nend)()\nlocal seed=17'+checks)
