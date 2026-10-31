--!nonstrict
local C=require(script.Parent.Creatures)
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
