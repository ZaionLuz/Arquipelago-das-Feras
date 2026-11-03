--!nonstrict
local L={
{id="Alvorecer",name="Ilha do Alvorecer",el="Natureza",cost=0,slots=4,ground=Color3.fromRGB(95,157,102),accent=Color3.fromRGB(183,232,139),deco="Ball",desc="Campos, nascentes e o primeiro acampamento de pesquisa."},
{id="Brasa",name="Ilha das Brasas",el="Fogo",cost=0,slots=4,ground=Color3.fromRGB(60,38,36),accent=Color3.fromRGB(255,96,32),deco="Block",desc="Vulcões e rios de magma."},
{id="Recife",name="Recife Cristalino",el="Água",cost=400,slots=5,ground=Color3.fromRGB(70,150,190),accent=Color3.fromRGB(120,255,235),deco="Ball",desc="Corais que cantam à noite."},
{id="Floresta",name="Floresta Murmurante",el="Natureza",cost=1200,slots=5,ground=Color3.fromRGB(60,130,70),accent=Color3.fromRGB(150,230,90),deco="Cylinder",desc="Árvores que sussurram segredos."},
{id="Dunas",name="Dunas Quebradas",el="Terra",cost=3500,slots=6,ground=Color3.fromRGB(210,170,100),accent=Color3.fromRGB(150,100,60),deco="Block",desc="Ruínas enterradas na areia."},
{id="Picos",name="Picos Celestes",el="Ar",cost=9000,slots=6,ground=Color3.fromRGB(190,210,235),accent=Color3.fromRGB(255,255,255),deco="Ball",desc="Ilhas de nuvem e tempestade."},
{id="Pantano",name="Pântano Umbral",el="Sombra",cost=22000,slots=8,ground=Color3.fromRGB(45,40,70),accent=Color3.fromRGB(190,90,255),deco="Cylinder",desc="Névoa viva e luzes que enganam."}}
local AMB={Alvorecer={Color3.fromRGB(134,163,137),11},Brasa={Color3.fromRGB(150,80,50),17},Recife={Color3.fromRGB(90,150,190),13},Floresta={Color3.fromRGB(80,140,90),10},Dunas={Color3.fromRGB(200,160,100),15},Picos={Color3.fromRGB(180,200,230),12},Pantano={Color3.fromRGB(70,50,110),23}}
local M={List=L,ById={}}
function M.pos(i) local a=(i-1)/#L*math.pi*2;return Vector3.new(math.cos(a)*150,10,math.sin(a)*150) end
for i,d in L do d.idx=i;d.minLevel=({1,1,10,18,26,34,42})[i];d.cost=math.min(d.cost,math.max(0,(i-1)*180));d.ambient=AMB[d.id][1];d.clock=AMB[d.id][2];M.ById[d.id]=d end
return M
