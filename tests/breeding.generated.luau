local C=(function()
--!nonstrict
-- Catálogo de feras. Para criar uma nova, basta uma linha add(...). Estatísticas derivam da raridade.
local C={List={},ById={},Rarity={"Comum","Raro","Épico","Lendário"}}
local function add(id,name,el,rar,island,shape,hybrid)
	local d={id=id,name=name,el=el,rar=rar,island=island,shape=shape,hybrid=hybrid,hp=30+rar*25,atk=6+rar*5,gpm=rar*rar*2+2}
	table.insert(C.List,d);C.ById[id]=d
end
add("cinzelo","Cinzelo","Fogo",1,"Brasa","Blob")
add("magmarau","Magmarau","Fogo",2,"Brasa","Beast")
add("fenixfuligem","Fênix Fuligem","Fogo",3,"Brasa","Bird")
add("vulcanodrago","Vulcanodrago","Fogo",4,"Brasa","Dragon")
add("bolhinho","Bolhinho","Água",1,"Recife","Blob")
add("marilisco","Marilisco","Água",2,"Recife","Serpent")
add("carangueperola","Caranguepérola","Água",3,"Recife","Insect")
add("abissauro","Abissauro","Água",4,"Recife","Dragon")
add("brotinho","Brotinho","Natureza",1,"Floresta","Blob")
add("folhuco","Folhuço","Natureza",2,"Floresta","Beast")
add("aracnoflora","Aracnoflora","Natureza",3,"Floresta","Insect")
add("ancestravore","Ancestrávore","Natureza",4,"Floresta","Beast")
add("graozinho","Grãozinho","Terra",1,"Dunas","Blob")
add("escorpiodra","Escorpiodra","Terra",2,"Dunas","Insect")
add("esfingeolito","Esfingeolito","Terra",3,"Dunas","Beast")
add("colossodune","Colossodune","Terra",4,"Dunas","Dragon")
add("penugem","Penugem","Ar",1,"Picos","Bird")
add("ventanil","Ventanil","Ar",2,"Picos","Bird")
add("trovoraptor","Trovoraptor","Ar",3,"Picos","Dragon")
add("aeronimbo","Aeronimbo","Ar",4,"Picos","Serpent")
add("lodinho","Lodinho","Sombra",1,"Pantano","Blob")
add("caudalume","Caudalume","Sombra",2,"Pantano","Serpent")
add("vagalumorte","Vagalumorte","Sombra",3,"Pantano","Insect")
add("reinevoento","Rei Nevoento","Sombra",4,"Pantano","Beast")
-- Híbridos: só nascem de cruzamentos entre dois elementos específicos.
add("vaporino","Vaporino","Fogo",3,"Híbrido","Serpent",{"Fogo","Água"})
add("magmaterra","Magmaterra","Fogo",3,"Híbrido","Beast",{"Fogo","Terra"})
add("tempestalia","Tempestália","Ar",3,"Híbrido","Bird",{"Ar","Água"})
add("nevoamusgo","Névoamusgo","Sombra",3,"Híbrido","Beast",{"Sombra","Natureza"})
add("cinzavento","Cinzavento","Fogo",4,"Híbrido","Dragon",{"Fogo","Ar"})
function C.stage(lv) return lv>=15 and 3 or lv>=7 and 2 or 1 end
return C

end)()
local B=(function()
--!nonstrict

local B={}
-- Cruzamento: 25% de híbrido (elementos diferentes); senão sorteia por raridade. Lendário exige pais raros+.
function B.pick(a,b,rng)
	local A,Z=C.ById[a],C.ById[b]
	if A.el~=Z.el and rng:NextNumber()<0.25 then
		local pool={}
		for _,c in C.List do
			local h=c.hybrid
			if h and ((h[1]==A.el and h[2]==Z.el) or (h[1]==Z.el and h[2]==A.el)) then table.insert(pool,c.id) end
		end
		if #pool>0 then return pool[rng:NextInteger(1,#pool)] end
	end
	local cap=math.min(4,math.max(A.rar,Z.rar)+(rng:NextNumber()<0.1 and 1 or 0))
	if cap>=4 and math.min(A.rar,Z.rar)<3 then cap=3 end
	local pool,tot={},0
	for _,c in C.List do
		if not c.hybrid and c.rar<=cap and (c.el==A.el or c.el==Z.el) then local w=1/(c.rar*c.rar);table.insert(pool,{c.id,w});tot+=w end
	end
	local r=rng:NextNumber()*tot
	for _,e in pool do r-=e[2];if r<=0 then return e[1] end end
	return pool[1][1]
end
-- Distribuição exata do algoritmo pick: mesma regra, sem mudar receitas existentes.
function B.outcomes(a,b)
 local A,Z=C.ById[a],C.ById[b];if not A or not Z then return {} end
 local out={};local hybrids={}
 if A.el~=Z.el then
  for _,c in C.List do local h=c.hybrid
   if h and ((h[1]==A.el and h[2]==Z.el) or (h[2]==A.el and h[1]==Z.el)) then table.insert(hybrids,c.id) end
  end
 end
 local hybridChance=#hybrids>0 and .25 or 0
 for _,id in hybrids do out[id]=hybridChance/#hybrids end
 for boost=0,1 do
  local cap=math.min(4,math.max(A.rar,Z.rar)+boost)
  if cap>=4 and math.min(A.rar,Z.rar)<3 then cap=3 end
  local total=0;local pool={}
  for _,c in C.List do
   if not c.hybrid and c.rar<=cap and (c.el==A.el or c.el==Z.el) then
    local weight=1/(c.rar*c.rar);pool[c.id]=weight;total+=weight
   end
  end
  local branch=(1-hybridChance)*(boost==1 and .1 or .9)
  for id,w in pool do out[id]=(out[id] or 0)+branch*w/total end
 end
 return out
end
return B

end)()
local seed=17
local rng={}
function rng:NextNumber() seed=(seed*48271)%2147483647;return seed/2147483647 end
function rng:NextInteger(a,b) return a+math.floor(self:NextNumber()*(b-a+1)) end
local pairsChecked=0
for _,a in C.List do for _,b in C.List do
 local chances=B.outcomes(a.id,b.id);local sum=0
 for id,chance in chances do assert(C.ById[id]);assert(chance>0 and chance<=1);sum+=chance end
 assert(math.abs(sum-1)<.000001,"Probabilidades não somam 1")
 for _=1,30 do local pick=B.pick(a.id,b.id,rng);assert(chances[pick],"Sorteio fora dos resultados possíveis") end
 pairsChecked+=1
end end
assert(C.stage(1)==1 and C.stage(6)==1 and C.stage(7)==2 and C.stage(14)==2 and C.stage(15)==3)
assert(next(B.outcomes("invalido","cinzelo"))==nil)
local n=0
for _=1,20000 do local id=B.pick("cinzelo","bolhinho",rng);if C.ById[id].hybrid then n+=1 end end
assert(math.abs(n/20000-.25)<.02,"Distribuição híbrida inesperada")
print("PASS",pairsChecked,"pares; 25230 sorteios válidos; estágios; híbridos",n/20000)
