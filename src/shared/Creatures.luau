--!nonstrict
local Text = require(script.Parent.Strings).Text
-- Catálogo de feras. Para criar uma nova, basta uma linha add(...). Estatísticas derivam da raridade.
local C =
	{ List = {}, ById = {}, Rarity = { Text.COMUM_CA938E, Text.RARO_851816, Text.EPICO_7BC392, Text.LENDARIO_52178E } }
local function add(id, name, el, rar, island, shape, hybrid)
	assert(not C.ById[id], "ID de criatura duplicado: " .. id)
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
add("flamiris", Text.FLAMIRIS_NAME, Text.FOGO_F77A3C, 2, "Brasa", "Quadruped")
add("carvunio", Text.CARVUNIO_NAME, Text.FOGO_F77A3C, 2, "Brasa", "Quadruped")
add("brasegato", Text.BRASEGATO_NAME, Text.FOGO_F77A3C, 2, "Brasa", "Quadruped")
add("orvalume", Text.ORVALUME_NAME, Text.AGUA_F11A05, 2, "Recife", "Quadruped")
add("coralina", Text.CORALINA_NAME, Text.AGUA_F11A05, 2, "Recife", "Quadruped")
add("pelaguir", Text.PELAGUIR_NAME, Text.AGUA_F11A05, 2, "Recife", "Aquatic")
add("musgalte", Text.MUSGALTE_NAME, Text.NATUREZA_FB1ED9, 2, "Floresta", "Quadruped")
add("bambuja", Text.BAMBUJA_NAME, Text.NATUREZA_FB1ED9, 2, "Floresta", "Quadruped")
add("florabelha", Text.FLORABELHA_NAME, Text.NATUREZA_FB1ED9, 2, "Floresta", "Arthropod")
add("marmure", Text.MARMURE_NAME, Text.TERRA_16D3AE, 2, "Dunas", "Quadruped")
add("litorisco", Text.LITORISCO_NAME, Text.TERRA_16D3AE, 2, "Dunas", "Mineral")
add("sementauro", Text.SEMENTAURO_NAME, Text.TERRA_16D3AE, 2, "Dunas", "Quadruped")
add("sibilobo", Text.SIBILOBO_NAME, Text.AR_B623FF, 2, "Picos", "Quadruped")
add("cirrandor", Text.CIRRANDOR_NAME, Text.AR_B623FF, 2, "Picos", "Winged")
add("nimboreo", Text.NIMBOREO_NAME, Text.AR_B623FF, 2, "Picos", "Draconic")
add("velune", Text.VELUNE_NAME, Text.SOMBRA_94B135, 2, "Pantano", "Quadruped")
add("obsidauro", Text.OBSIDAURO_NAME, Text.SOMBRA_94B135, 2, "Pantano", "Quadruped")
add("velumosa", Text.VELUMOSA_NAME, Text.SOMBRA_94B135, 2, "Pantano", "Winged")
add("glaurina", Text.GLAURINA_NAME, Text.GELO_4A90D9, 2, "Dunas", "Quadruped")
add("niveor", Text.NIVEOR_NAME, Text.GELO_4A90D9, 2, "Dunas", "Quadruped")
add("gelifoca", Text.GELIFOCA_NAME, Text.GELO_4A90D9, 2, "Dunas", "Aquatic")
add("fulgarru", Text.FULGARRU_NAME, Text.ELETRICO_FFD600, 2, "Picos", "Quadruped")
add("ampelince", Text.AMPELINCE_NAME, Text.ELETRICO_FFD600, 2, "Picos", "Quadruped")
add("trovissideo", Text.TROVISSIDEO_NAME, Text.ELETRICO_FFD600, 2, "Picos", "Arthropod")
add("aurifita", Text.AURIFITA_NAME, Text.LUZ_FFF9C4, 2, "Brasa", "Quadruped")
add("lunarru", Text.LUNARRU_NAME, Text.LUZ_FFF9C4, 2, "Brasa", "Quadruped")
add("candeira", Text.CANDEIRA_NAME, Text.LUZ_FFF9C4, 2, "Brasa", "Arthropod")
add("ferrunila", Text.FERRUNILA_NAME, Text.METAL_B0BEC5, 2, "Dunas", "Quadruped")
add("fiaranha", Text.FIARANHA_NAME, Text.METAL_B0BEC5, 2, "Dunas", "Arthropod")
add("metafalcao", Text.METAFALCAO_NAME, Text.METAL_B0BEC5, 2, "Dunas", "Winged")
add("cindrel", Text.CINDREL_NAME, Text.FOGO_F77A3C, 1, "Brasa", "Mineral")
add("emberkit", Text.EMBERKIT_NAME, Text.FOGO_F77A3C, 1, "Brasa", "Quadruped")
add("sparkpup", Text.SPARKPUP_NAME, Text.FOGO_F77A3C, 1, "Brasa", "Quadruped")
add("flamecub", Text.FLAMECUB_NAME, Text.FOGO_F77A3C, 1, "Brasa", "Quadruped")
add("coalcrawler", Text.COALCRAWLER_NAME, Text.FOGO_F77A3C, 1, "Brasa", "Arthropod")
add("aquasprite", Text.AQUASPRITE_NAME, Text.AGUA_F11A05, 1, "Recife", "Aquatic")
add("droplet", Text.DROPLET_NAME, Text.AGUA_F11A05, 1, "Recife", "Mineral")
add("finling", Text.FINLING_NAME, Text.AGUA_F11A05, 1, "Recife", "Quadruped")
add("tidepup", Text.TIDEPUP_NAME, Text.AGUA_F11A05, 1, "Recife", "Quadruped")
add("coralkit", Text.CORALKIT_NAME, Text.AGUA_F11A05, 1, "Recife", "Quadruped")
add("leaflet", Text.LEAFLET_NAME, Text.NATUREZA_FB1ED9, 1, "Floresta", "Vegetal")
add("seedling", Text.SEEDLING_NAME, Text.NATUREZA_FB1ED9, 1, "Floresta", "Mineral")
add("sprou", Text.SPROU_NAME, Text.NATUREZA_FB1ED9, 1, "Floresta", "Quadruped")
add("vinecub", Text.VINECUB_NAME, Text.NATUREZA_FB1ED9, 1, "Floresta", "Quadruped")
add("petalpaw", Text.PETALPAW_NAME, Text.NATUREZA_FB1ED9, 1, "Floresta", "Quadruped")
add("pebblin", Text.PEBBLIN_NAME, Text.TERRA_16D3AE, 1, "Dunas", "Mineral")
add("rockling", Text.ROCKLING_NAME, Text.TERRA_16D3AE, 1, "Dunas", "Mineral")
add("sandpup", Text.SANDPUP_NAME, Text.TERRA_16D3AE, 1, "Dunas", "Quadruped")
add("dunecub", Text.DUNECUB_NAME, Text.TERRA_16D3AE, 1, "Dunas", "Quadruped")
add("geodette", Text.GEODETTE_NAME, Text.TERRA_16D3AE, 1, "Dunas", "Arthropod")
add("zephyr", Text.ZEPHYR_NAME, Text.AR_B623FF, 1, "Picos", "Winged")
add("cloudpuff", Text.CLOUDPUFF_NAME, Text.AR_B623FF, 1, "Picos", "Mineral")
add("breezekit", Text.BREEZEKIT_NAME, Text.AR_B623FF, 1, "Picos", "Quadruped")
add("galehatch", Text.GALEHATCH_NAME, Text.AR_B623FF, 1, "Picos", "Quadruped")
add("windling", Text.WINDLING_NAME, Text.AR_B623FF, 1, "Picos", "Winged")
add("shade", Text.SHADE_NAME, Text.SOMBRA_94B135, 1, "Pantano", "Spectral")
add("shadowmite", Text.SHADOWMITE_NAME, Text.SOMBRA_94B135, 1, "Pantano", "Mineral")
add("gloomkit", Text.GLOOMKIT_NAME, Text.SOMBRA_94B135, 1, "Pantano", "Quadruped")
add("duskpup", Text.DUSKPUP_NAME, Text.SOMBRA_94B135, 1, "Pantano", "Quadruped")
add("nightmoth", Text.NIGHTMOTH_NAME, Text.SOMBRA_94B135, 1, "Pantano", "Arthropod")
add("frostbit", Text.FROSTBIT_NAME, Text.GELO_4A90D9, 1, "Dunas", "Mineral")
add("icecrystal", Text.ICECRYSTAL_NAME, Text.GELO_4A90D9, 1, "Dunas", "Mineral")
add("snowkit", Text.SNOWKIT_NAME, Text.GELO_4A90D9, 1, "Dunas", "Quadruped")
add("glaciercub", Text.GLACIERCUB_NAME, Text.GELO_4A90D9, 1, "Dunas", "Quadruped")
add("frostling", Text.FROSTLING_NAME, Text.GELO_4A90D9, 1, "Dunas", "Winged")
add("voltkit", Text.VOLTKIT_NAME, Text.ELETRICO_FFD600, 1, "Picos", "Quadruped")
add("sparkling", Text.SPARKLING_NAME, Text.ELETRICO_FFD600, 1, "Picos", "Mineral")
add("jolteon", Text.JOLTEON_NAME, Text.ELETRICO_FFD600, 1, "Picos", "Quadruped")
add("zapcub", Text.ZAPCUB_NAME, Text.ELETRICO_FFD600, 1, "Picos", "Quadruped")
add("buzzbug", Text.BUZZBUG_NAME, Text.ELETRICO_FFD600, 1, "Picos", "Arthropod")
add("lumikit", Text.LUMIKIT_NAME, Text.LUZ_FFF9C4, 1, "Brasa", "Quadruped")
add("gloworb", Text.GLOWORB_NAME, Text.LUZ_FFF9C4, 1, "Brasa", "Mineral")
add("solarpup", Text.SOLARPUP_NAME, Text.LUZ_FFF9C4, 1, "Brasa", "Quadruped")
add("raycub", Text.RAYCUB_NAME, Text.LUZ_FFF9C4, 1, "Brasa", "Quadruped")
add("prismfly", Text.PRISMFLY_NAME, Text.LUZ_FFF9C4, 1, "Brasa", "Arthropod")
add("ironkit", Text.IRONKIT_NAME, Text.METAL_B0BEC5, 1, "Dunas", "Quadruped")
add("scraplet", Text.SCRAPLET_NAME, Text.METAL_B0BEC5, 1, "Dunas", "Mineral")
add("boltpup", Text.BOLTPUP_NAME, Text.METAL_B0BEC5, 1, "Dunas", "Quadruped")
add("gearcub", Text.GEARCUB_NAME, Text.METAL_B0BEC5, 1, "Dunas", "Quadruped")
add("rivetbug", Text.RIVETBUG_NAME, Text.METAL_B0BEC5, 1, "Dunas", "Arthropod")
add("gemling", Text.GEMLING_NAME, Text.CRISTAL_E1BEE7, 1, "Recife", "Mineral")
add("shardlet", Text.SHARDLET_NAME, Text.CRISTAL_E1BEE7, 1, "Recife", "Mineral")
add("crystalkit", Text.CRYSTALKIT_NAME, Text.CRISTAL_E1BEE7, 1, "Recife", "Quadruped")
add("prismpup", Text.PRISMPUP_NAME, Text.CRISTAL_E1BEE7, 1, "Recife", "Quadruped")
add("facetbug", Text.FACETBUG_NAME, Text.CRISTAL_E1BEE7, 1, "Recife", "Arthropod")
add("runeling", Text.RUNELING_NAME, Text.ARCANO_CE93D8, 1, "Pantano", "Spectral")
add("mysticorb", Text.MYSTICORB_NAME, Text.ARCANO_CE93D8, 1, "Pantano", "Mineral")
add("arcankit", Text.ARCANKIT_NAME, Text.ARCANO_CE93D8, 1, "Pantano", "Quadruped")
add("voidpup", Text.VOIDPUP_NAME, Text.ARCANO_CE93D8, 1, "Pantano", "Quadruped")
add("sigilbug", Text.SIGILBUG_NAME, Text.ARCANO_CE93D8, 1, "Pantano", "Arthropod")




























































































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
