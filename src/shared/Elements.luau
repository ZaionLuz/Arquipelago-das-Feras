--!strict
-- 12 Elementos. Strong[atacante] = alvos que sofrem dano dobrado.
-- Weak[atacante] = alvos que sofrem metade do dano (defesa forte contra atacante)
-- Immune[atacante] = alvos que não sofrem dano (imunidade total)
local E = {
	List = {
		"Fogo", "Água", "Natureza", "Terra", "Ar", "Sombra",
		"Gelo", "Elétrico", "Luz", "Metal", "Cristal", "Arcano"
	},
}

-- Vantagens ofensivas (dano 2x)
E.Strong = {
	Fogo     = { "Natureza", "Gelo", "Metal", "Cristal" },
	["Água"] = { "Fogo", "Terra", "Metal" },
	Natureza = { "Água", "Terra", "Gelo" },
	Terra    = { "Fogo", "Elétrico", "Metal", "Arcano" },
	Ar       = { "Natureza", "Luz", "Arcano" },
	Sombra   = { "Ar", "Água", "Luz", "Cristal" },
	Gelo     = { "Natureza", "Terra", "Ar", "Dragao" }, -- Dragao não existe, remover
	Elétrico = { "Água", "Ar", "Metal", "Cristal" },
	Luz      = { "Sombra", "Arcano", "Gelo" },
	Metal    = { "Gelo", "Natureza", "Fada" }, -- Fada não existe
	Cristal  = { "Fogo", "Terra", "Ar", "Sombra" },
	Arcano   = { "Sombra", "Luz", "Metal" },
}

-- Resistências (dano 0.5x) - calculado inversamente do Strong
E.Resist = {}
for att, defs in E.Strong do
	for _, def in defs do
		E.Resist[def] = E.Resist[def] or {}
		table.insert(E.Resist[def], att)
	end
end

-- Imunidades (dano 0x)
E.Immune = {
	Elétrico = { "Terra" },
	Terra    = { "Elétrico" }, -- Terra é imune a Elétrico (já coberto acima)
	Normal   = { "Sombra" },   -- Se houver tipo Normal
	Voador   = { "Terra" },    -- Se houver tipo Voador
	-- Adicionar imunidades customizadas se necessário
}

E.Color = {
	Fogo      = Color3.fromRGB(255, 110, 50),
	["Água"]  = Color3.fromRGB(70, 160, 255),
	Natureza  = Color3.fromRGB(110, 210, 80),
	Terra     = Color3.fromRGB(190, 140, 80),
	Ar        = Color3.fromRGB(200, 230, 255),
	Sombra    = Color3.fromRGB(140, 80, 200),
	Gelo      = Color3.fromRGB(125, 210, 255),
	Elétrico  = Color3.fromRGB(255, 200, 20),
	Luz       = Color3.fromRGB(255, 250, 150),
	Metal     = Color3.fromRGB(176, 190, 197),
	Cristal   = Color3.fromRGB(216, 180, 254),
	Arcano    = Color3.fromRGB(196, 181, 253),
}

-- Calcular multiplicador de dano
-- Retorna: 2 (super effective), 1 (normal), 0.5 (not very effective), 0 (no effect)
function E.mult(att: string, def: string): number
	-- Imunidade tem prioridade máxima
	if E.Immune[att] and table.find(E.Immune[att], def) then
		return 0
	end
	if E.Immune[def] and table.find(E.Immune[def], att) then
		return 0
	end

	-- Super efetivo
	if table.find(E.Strong[att] or {}, def) then
		return 2
	end

	-- Não muito efetivo
	if table.find(E.Resist[att] or {}, def) then
		return 0.5
	end

	return 1
end

-- Obter string de eficácia para UI
function E.effectivenessText(mult: number): string
	if mult >= 2 then return "Super efetivo!" end
	if mult <= 0.5 and mult > 0 then return "Não muito efetivo..." end
	if mult == 0 then return "Não tem efeito..." end
	return ""
end

-- Obter cor da eficácia
function E.effectivenessColor(mult: number): Color3
	if mult >= 2 then return Color3.fromRGB(255, 100, 100) end
	if mult <= 0.5 and mult > 0 then return Color3.fromRGB(255, 200, 100) end
	if mult == 0 then return Color3.fromRGB(150, 150, 150) end
	return Color3.fromRGB(255, 255, 255)
end

-- Verificar se elemento existe
function E.exists(element: string): boolean
	return table.find(E.List, element) ~= nil
end

-- Obter todos os elementos efetivos contra um tipo
function E.getSuperEffectiveAgainst(def: string): { string }
	local result = {}
	for att, defs in E.Strong do
		if table.find(defs, def) then
			table.insert(result, att)
		end
	end
	return result
end

-- Obter todos os elementos que resistem a um tipo
function E.getResistsAgainst(att: string): { string }
	return E.Resist[att] or {}
end

return E