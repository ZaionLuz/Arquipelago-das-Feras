--!nonstrict
local Text = require(script.Parent.Strings).Text
local L = {
	{
		id = "Alvorecer",
		name = Text.ILHA_DO_ALVORECER_414C6C,
		el = Text.NATUREZA_FB1ED9,
		cost = 0,
		slots = 4,
		ground = Color3.fromRGB(95, 157, 102),
		accent = Color3.fromRGB(183, 232, 139),
		deco = "Ball",
		desc = Text.CAMPOS_NASCENTES_E_O_PRIMEIRO_ACAMPAMENTO_DE_PES_4187EC,
	},
	{
		id = "Brasa",
		name = Text.ILHA_DAS_BRASAS_78BBD5,
		el = Text.FOGO_F77A3C,
		cost = 0,
		slots = 4,
		ground = Color3.fromRGB(60, 38, 36),
		accent = Color3.fromRGB(255, 96, 32),
		deco = "Block",
		desc = Text.VULCOES_E_RIOS_DE_MAGMA_300BD6,
	},
	{
		id = "Recife",
		name = Text.RECIFE_CRISTALINO_8D7A14,
		el = Text.AGUA_F11A05,
		cost = 400,
		slots = 5,
		ground = Color3.fromRGB(70, 150, 190),
		accent = Color3.fromRGB(120, 255, 235),
		deco = "Ball",
		desc = Text.CORAIS_QUE_CANTAM_A_NOITE_DE26D3,
	},
	{
		id = "Floresta",
		name = Text.FLORESTA_MURMURANTE_DDD13E,
		el = Text.NATUREZA_FB1ED9,
		cost = 1200,
		slots = 5,
		ground = Color3.fromRGB(60, 130, 70),
		accent = Color3.fromRGB(150, 230, 90),
		deco = "Cylinder",
		desc = Text.ARVORES_QUE_SUSSURRAM_SEGREDOS_37CC8A,
	},
	{
		id = "Dunas",
		name = Text.DUNAS_QUEBRADAS_B76161,
		el = Text.TERRA_16D3AE,
		cost = 3500,
		slots = 6,
		ground = Color3.fromRGB(210, 170, 100),
		accent = Color3.fromRGB(150, 100, 60),
		deco = "Block",
		desc = Text.RUINAS_ENTERRADAS_NA_AREIA_403002,
	},
	{
		id = "Picos",
		name = Text.PICOS_CELESTES_4FA949,
		el = Text.AR_B623FF,
		cost = 9000,
		slots = 6,
		ground = Color3.fromRGB(190, 210, 235),
		accent = Color3.fromRGB(255, 255, 255),
		deco = "Ball",
		desc = Text.ILHAS_DE_NUVEM_E_TEMPESTADE_9FF959,
	},
	{
		id = "Pantano",
		name = Text.PANTANO_UMBRAL_FBA600,
		el = Text.SOMBRA_94B135,
		cost = 22000,
		slots = 8,
		ground = Color3.fromRGB(45, 40, 70),
		accent = Color3.fromRGB(190, 90, 255),
		deco = "Cylinder",
		desc = Text.NEVOA_VIVA_E_LUZES_QUE_ENGANAM_0BE524,
	},
}
local AMB = {
	Alvorecer = { Color3.fromRGB(134, 163, 137), 11 },
	Brasa = { Color3.fromRGB(150, 80, 50), 17 },
	Recife = { Color3.fromRGB(90, 150, 190), 13 },
	Floresta = { Color3.fromRGB(80, 140, 90), 10 },
	Dunas = { Color3.fromRGB(200, 160, 100), 15 },
	Picos = { Color3.fromRGB(180, 200, 230), 12 },
	Pantano = { Color3.fromRGB(70, 50, 110), 23 },
}
local Bands = require(script.Parent.LevelBands)
local M = { List = L, ById = {} }
function M.pos(i)
	return require(script.Parent.WorldLayout).center(i)
end
for i, d in L do
	d.idx = i
	d.minLevel = Bands.ById[d.id].min
	d.cost = Bands.ById[d.id].cost
	d.ambient = AMB[d.id][1]
	d.clock = AMB[d.id][2]
	M.ById[d.id] = d
end
return M
