--!nonstrict
local L={}
local function add(id,text,stat,goal,gold,gems) table.insert(L,{id=id,text=text,stat=stat,goal=goal,gold=gold,gems=gems or 0}) end
add("f1","Alimente uma fera","feed",1,40)
add("f2","Alimente 5 vezes","feed",5,120,1)
add("f3","Alimente 20 vezes","feed",20,400,3)
add("b1","Cruze duas feras","breed",1,60)
add("b2","Cruze 5 vezes","breed",5,200,2)
add("h1","Choque um ovo","hatch",1,60)
add("h2","Choque 5 ovos","hatch",5,250,2)
add("w1","Vença uma batalha","win",1,80)
add("w2","Vença 10 batalhas","win",10,500,3)
add("w3","Vença 30 batalhas","win",30,1500,8)
add("c1","Colete ouro 5 vezes","collect",5,100)
add("d1","Descubra 8 feras","found",8,300,3)
add("d2","Descubra 15 feras","found",15,1200,6)
add("i1","Tenha 3 ilhas","isles",3,400,3)
add("i2","Tenha todas as ilhas","isles",6,5000,15)
add("p1","Vença um duelo online","duelwin",1,200,3)
add("a1","Conquista: descubra todas as feras","found",#require(script.Parent.Creatures).List,3000,20)
add("a2","Conquista: 100 vitórias","win",100,5000,20)
add("a3","Conquista: alimente 100 vezes","feed",100,2000,10)
add("a4","Conquista: choque 25 ovos","hatch",25,2500,10)
add("a5","Conquista: colete 50 vezes","collect",50,1500,8)
local M={List=L,ById={}}
for _,m in L do M.ById[m.id]=m end
function M.progress(d,stat)
	if stat=="found" or stat=="isles" then local n=0;for _ in (stat=="found" and d.discovered or d.unlocked) do n+=1 end;return n end
	return d.stats[stat] or 0
end
-- Evento rotativo: a cada 3 dias um elemento rende +50% de ouro.
local EL={"Fogo","Água","Natureza","Terra","Ar","Sombra"}
function M.event(now) local per=3*86400;return EL[(now//per)%6+1],per-now%per end
return M
