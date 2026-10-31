--!nonstrict
-- Seis elementos. Strong[atacante] = alvos que sofrem dano dobrado.
local E={List={"Fogo","Água","Natureza","Terra","Ar","Sombra"}}
E.Strong={Fogo={"Natureza"},["Água"]={"Fogo","Terra"},Natureza={"Água","Terra"},Terra={"Fogo","Ar"},Ar={"Natureza"},Sombra={"Ar","Água"}}
E.Color={Fogo=Color3.fromRGB(255,110,50),["Água"]=Color3.fromRGB(70,160,255),Natureza=Color3.fromRGB(110,210,80),Terra=Color3.fromRGB(190,140,80),Ar=Color3.fromRGB(200,230,255),Sombra=Color3.fromRGB(140,80,200)}
function E.mult(att,def)
	if table.find(E.Strong[att] or {},def) then return 2 end
	if table.find(E.Strong[def] or {},att) then return 0.5 end
	return 1
end
return E
