--!nonstrict
local S={List={
 {id="arrival",name="O primeiro vínculo",text="Capture uma fera selvagem e apresente sua descoberta à pesquisadora Maia.",stat="capture",goal=1,gold=75,xp=90,seals=2},
 {id="care",name="Um lar para suas feras",text="Alimente suas feras três vezes.",stat="feed",goal=3,gold=100,xp=100,seals=1},
 {id="explore",name="Vestígios da civilização",text="Encontre um marco de exploração e recolha sua essência.",stat="explore",goal=1,gold=100,xp=100,seals=1},
 {id="birth",name="A próxima geração",text="Choque um ovo no seu santuário.",stat="hatch",goal=1,gold=150,xp=120,seals=2},
 {id="challenge",name="Explorador preparado",text="Vença uma batalha contra uma fera selvagem.",stat="win",goal=1,gold=200,xp=160,seals=2},
 {id="home",name="Santuário em crescimento",text="Melhore um dos seus habitats.",stat="habitatUpgrade",goal=1,gold=200,xp=200,seals=3},
 {id="guardian",name="O primeiro guardião",text="Derrote um guardião de ilha para concluir sua primeira expedição.",stat="guardian",goal=1,gold=300,xp=300,seals=4},
}}
S.ById={};for _,q in S.List do S.ById[q.id]=q end
function S.current(d)
 for _,q in S.List do if not d.storyClaimed[q.id] then return q end end
 return nil
end
function S.progress(d,q) return math.min(q.goal,d.stats[q.stat] or 0) end
function S.canClaim(d,id)
 local q=S.current(d);return q and q.id==id and S.progress(d,q)>=q.goal
end
return S
