local seed=17
local rng={}
function rng:NextNumber() seed=(seed*48271)%2147483647;return seed/2147483647 end
function rng:NextInteger(a,b) return a+math.floor(self:NextNumber()*(b-a+1)) end
local pairsChecked=0
for _,a in C.List do for _,b in C.List do
 if a.breedable==false or b.breedable==false then
  assert(next(B.outcomes(a.id,b.id))==nil and B.pick(a.id,b.id,rng)==nil)
 else
  local chances=B.outcomes(a.id,b.id);local sum=0
  for id,chance in chances do assert(C.ById[id] and C.ById[id].breedable~=false);assert(chance>0 and chance<=1);sum+=chance end
  assert(math.abs(sum-1)<.000001,"Probabilidades não somam 1")
  for _=1,30 do local pick=B.pick(a.id,b.id,rng);assert(chances[pick],"Sorteio fora dos resultados possíveis") end
  pairsChecked+=1
 end
end end
assert(C.stage(1)==1 and C.stage(6)==1 and C.stage(7)==2 and C.stage(14)==2 and C.stage(15)==3)
assert(next(B.outcomes("invalido","cinzelo"))==nil)
local n=0
for _=1,20000 do local id=B.pick("cinzelo","bolhinho",rng);if C.ById[id].hybrid then n+=1 end end
assert(math.abs(n/20000-.25)<.02,"Distribuição híbrida inesperada")
print("PASS",pairsChecked,"pares; sorteios",pairsChecked*30,"estágios; híbridos",n/20000)

local Capture=(function()
--!nonstrict
local R={SealPrice=25,InitialSeals=5,MaxPerIsland=2,RespawnSeconds=25,MaxDistance=13}
local base={.8,.5,.28,.12}
function R.chance(rarity,level)
 return math.clamp((base[rarity] or .1)-math.max(0,level-1)*.005,.05,.9)
end
-- Hábitos e peso compartilhados para inspeção; somente servidor sorteia.
function R.species(def)
 return {island=def.island,weight=1/(def.rar*def.rar),behavior=def.shape=="Bird" and "voador" or def.shape=="Serpent" and "reservado" or "curioso",max=def.rar==4 and 1 or 2}
end
return R

end)()
for lv=1,20 do
 assert(C.stage(lv,"fenix")==3)
 for rarity=1,4 do
  local chance=Capture.chance(rarity,lv)
  assert(chance>=.05 and chance<=.9)
  if rarity>1 then assert(chance<=Capture.chance(rarity-1,lv)) end
 end
end
assert(C.ById.fenix.futureStage.target==4 and not C.ById.fenix.futureStage.enabled)
assert(C.ById.fenix.rar==4 and C.ById.fenix.shape=="Bird")
print("PASS: Fênix adulta em todos os níveis; estágio 4 bloqueado; probabilidades de captura limitadas")
