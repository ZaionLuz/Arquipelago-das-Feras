--!nonstrict
-- Vantagens legadas preservadas; novos elementos usam relações neutras até balanceamento explícito.
local E = { List = { "Fogo", "Água", "Natureza", "Terra", "Ar", "Sombra" } }
E.Strong = {
	Fogo = { "Natureza" },
	["Água"] = { "Fogo", "Terra" },
	Natureza = { "Água", "Terra" },
	Terra = { "Fogo", "Ar" },
	Ar = { "Natureza" },
	Sombra = { "Ar", "Água" },
}
E.Color = {
	Fogo = Color3.fromRGB(255, 110, 50),
	["Água"] = Color3.fromRGB(70, 160, 255),
	Natureza = Color3.fromRGB(110, 210, 80),
	Terra = Color3.fromRGB(190, 140, 80),
	Ar = Color3.fromRGB(200, 230, 255),
	Sombra = Color3.fromRGB(140, 80, 200),
}
for name,color in {
 Gelo=Color3.fromRGB(156,219,255), ["Elétrico"]=Color3.fromRGB(255,211,105), Luz=Color3.fromRGB(248,237,191),
 Metal=Color3.fromRGB(168,184,197),Cristal=Color3.fromRGB(202,180,227),Arcano=Color3.fromRGB(178,142,210),
} do
 table.insert(E.List,name);E.Color[name]=color;E.Strong[name]={}
end
function E.mult(att, def)
	if table.find(E.Strong[att] or {}, def) then
		return 2
	end
	if table.find(E.Strong[def] or {}, att) then
		return 0.5
	end
	return 1
end
return E
