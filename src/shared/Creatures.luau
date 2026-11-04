--!nonstrict
local Text = require(script.Parent.Strings).Text
-- Catálogo de feras. Para criar uma nova, basta uma linha add(...). Estatísticas derivam da raridade.
local C =
	{ List = {}, ById = {}, Rarity = { Text.COMUM_CA938E, Text.RARO_851816, Text.EPICO_7BC392, Text.LENDARIO_52178E } }
local function add(id, name, el, rar, island, shape, hybrid)
	local d = {
		id = id,
		name = name,
		el = el,
		rar = rar,
		island = island,
		shape = shape,
		hybrid = hybrid,
		hp = 30 + rar * 25,
		atk = 6 + rar * 5,
		gpm = rar * rar * 2 + 2,
	}
	table.insert(C.List, d)
	C.ById[id] = d
end
add("cinzelo", Text.CINZELO_540AA2, Text.FOGO_F77A3C, 1, "Brasa", "Blob")
add("magmarau", Text.MAGMARAU_66D92B, Text.FOGO_F77A3C, 2, "Brasa", "Beast")
add("fenixfuligem", Text.FENIX_FULIGEM_64EF6D, Text.FOGO_F77A3C, 3, "Brasa", "Bird")
add("vulcanodrago", Text.VULCANODRAGO_CEB8E4, Text.FOGO_F77A3C, 4, "Brasa", "Dragon")
add("bolhinho", Text.BOLHINHO_2BE987, Text.AGUA_F11A05, 1, "Recife", "Blob")
add("marilisco", Text.MARILISCO_BFD916, Text.AGUA_F11A05, 2, "Recife", "Serpent")
add("carangueperola", Text.CARANGUEPEROLA_08BAB3, Text.AGUA_F11A05, 3, "Recife", "Insect")
add("abissauro", Text.ABISSAURO_04225F, Text.AGUA_F11A05, 4, "Recife", "Dragon")
add("brotinho", Text.BROTINHO_57925C, Text.NATUREZA_FB1ED9, 1, "Floresta", "Blob")
add("folhuco", Text.FOLHUCO_22B5C1, Text.NATUREZA_FB1ED9, 2, "Floresta", "Beast")
add("aracnoflora", Text.ARACNOFLORA_43AC5A, Text.NATUREZA_FB1ED9, 3, "Floresta", "Insect")
add("ancestravore", Text.ANCESTRAVORE_146E5C, Text.NATUREZA_FB1ED9, 4, "Floresta", "Beast")
add("graozinho", Text.GRAOZINHO_D0C3F0, Text.TERRA_16D3AE, 1, "Dunas", "Blob")
add("escorpiodra", Text.ESCORPIODRA_B79E74, Text.TERRA_16D3AE, 2, "Dunas", "Insect")
add("esfingeolito", Text.ESFINGEOLITO_728F92, Text.TERRA_16D3AE, 3, "Dunas", "Beast")
add("colossodune", Text.COLOSSODUNE_3B3CE0, Text.TERRA_16D3AE, 4, "Dunas", "Dragon")
add("penugem", Text.PENUGEM_D3A3F3, Text.AR_B623FF, 1, "Picos", "Bird")
add("ventanil", Text.VENTANIL_D7000E, Text.AR_B623FF, 2, "Picos", "Bird")
add("trovoraptor", Text.TROVORAPTOR_3E8543, Text.AR_B623FF, 3, "Picos", "Dragon")
add("aeronimbo", Text.AERONIMBO_2E256F, Text.AR_B623FF, 4, "Picos", "Serpent")
add("lodinho", Text.LODINHO_03ED97, Text.SOMBRA_94B135, 1, "Pantano", "Blob")
add("caudalume", Text.CAUDALUME_26609C, Text.SOMBRA_94B135, 2, "Pantano", "Serpent")
add("vagalumorte", Text.VAGALUMORTE_40C1CE, Text.SOMBRA_94B135, 3, "Pantano", "Insect")
add("reinevoento", Text.REI_NEVOENTO_691E87, Text.SOMBRA_94B135, 4, "Pantano", "Beast")
-- Híbridos: só nascem de cruzamentos entre dois elementos específicos.
add(
	"vaporino",
	Text.VAPORINO_6940A2,
	Text.FOGO_F77A3C,
	3,
	Text.HIBRIDO_9CB40A,
	"Serpent",
	{ Text.FOGO_F77A3C, Text.AGUA_F11A05 }
)
add(
	"magmaterra",
	Text.MAGMATERRA_ACDB93,
	Text.FOGO_F77A3C,
	3,
	Text.HIBRIDO_9CB40A,
	"Beast",
	{ Text.FOGO_F77A3C, Text.TERRA_16D3AE }
)
add(
	"tempestalia",
	Text.TEMPESTALIA_27599D,
	Text.AR_B623FF,
	3,
	Text.HIBRIDO_9CB40A,
	"Bird",
	{ Text.AR_B623FF, Text.AGUA_F11A05 }
)
add(
	"nevoamusgo",
	Text.NEVOAMUSGO_8FDC87,
	Text.SOMBRA_94B135,
	3,
	Text.HIBRIDO_9CB40A,
	"Beast",
	{ Text.SOMBRA_94B135, Text.NATUREZA_FB1ED9 }
)
add(
	"cinzavento",
	Text.CINZAVENTO_982DC1,
	Text.FOGO_F77A3C,
	4,
	Text.HIBRIDO_9CB40A,
	"Dragon",
	{ Text.FOGO_F77A3C, Text.AR_B623FF }
)
-- Fênix é uma espécie adicional; Fênix Fuligem e seus IDs permanecem intactos.
add("fenix", Text.FENIX_A08C9E, Text.FOGO_F77A3C, 4, "Brasa", "Bird")
C.ById.fenix.acquisition = "special"
C.ById.fenix.minStage = 3
C.ById.fenix.futureStage = { target = 4, enabled = false, mechanic = Text.RENASCIMENTO_FUTURO_EE24AE }
function C.stage(lv, id)
	local normal = lv >= 15 and 3 or lv >= 7 and 2 or 1
	return math.max(normal, (id and C.ById[id] and C.ById[id].minStage) or 1)
end
return C
