--!nonstrict
local Text = require(script.Parent.Strings).Text
-- Fichas das espécies com geometria integrada. Não inclui conceitos ainda sem modelo.
return {
	cinzelo = {
		description = Text.UM_NUCLEO_DE_CARVAO_VIVO_PROTEGIDO_POR_PEQUENAS__769F23,
		personality = "Curioso",
		family = Text.NUCLEO_DE_BRASAS_D7AC7B,
	},
	magmarau = {
		description = Text.FERA_DE_FOCINHO_LARGO_E_PRESAS_MINERAIS_QUE_PROC_12FD1E,
		personality = "Protetor",
		family = Text.FERA_VULCANICA_66F6AD,
	},
	fenixfuligem = {
		description = Text.UMA_AVE_DE_PENAS_ESCURAS_COM_UMA_CRISTA_QUE_PARE_4E5191,
		personality = "Observadora",
		family = Text.AVE_DE_CINZAS_2EE51C,
	},
	vulcanodrago = {
		description = Text.REPTIL_ALADO_COM_PLACAS_DE_BASALTO_E_UM_BRILHO_Q_A1E28C,
		personality = "Territorial",
		family = Text.DRAGAO_DE_BASALTO_ACD199,
	},
	bolhinho = {
		description = Text.CRIATURA_ARREDONDADA_COM_PEQUENAS_GUELRAS_QUE_OB_D759C9,
		personality = Text.BRINCALHAO_5822EE,
		family = Text.ANFIBIO_DE_BOLHAS_42099D,
	},
	marilisco = {
		description = Text.SERPENTE_DE_NADADEIRAS_ALTAS_QUE_REPOUSA_ENTRE_C_F61F34,
		personality = "Reservado",
		family = Text.SERPENTE_MARINHA_BF701F,
	},
	carangueperola = {
		description = Text.UM_GUARDIAO_DE_PEQUENAS_PEROLAS_COM_CARAPACA_LAR_B53600,
		personality = "Cauteloso",
		family = Text.CRUSTACEO_PEROLADO_057427,
	},
	abissauro = {
		description = Text.REPTIL_MARINHO_QUE_ILUMINA_SEU_CAMINHO_COM_UMA_P_4A0F69,
		personality = "Paciente",
		family = Text.REPTIL_ABISSAL_4DCBF3,
	},
	brotinho = {
		description = Text.UM_PEQUENO_BROTO_AMBULANTE_QUE_ABRE_SUAS_FOLHAS__24DCAD,
		personality = "Afetuoso",
		family = Text.BROTO_VIVO_30A437,
	},
	folhuco = {
		description = Text.FERA_DE_CORPO_ESGUIO_E_ORELHAS_VEGETAIS_QUE_SE_E_066C4A,
		personality = "Alerta",
		family = Text.FERA_FOLHOSA_F92CC9,
	},
	aracnoflora = {
		description = Text.ARACNIDEO_COM_PETALAS_PROTETORAS_QUE_SE_CAMUFLA__618FB3,
		personality = Text.TIMIDO_3CCD3C,
		family = Text.ARACNIDEO_VEGETAL_A28194,
	},
	ancestravore = {
		description = Text.FERA_ROBUSTA_CUJOS_GALHOS_LEMBRAM_A_COPA_DE_ARVO_4AD52F,
		personality = "Sereno",
		family = Text.GUARDIAO_ARBOREO_471EEF,
	},
	graozinho = {
		description = Text.UMA_PEQUENA_GEODA_VIVA_COM_UM_NUCLEO_QUE_PULSA_S_8A27ED,
		personality = "Persistente",
		family = Text.GEODA_VIVA_87C5A2,
	},
	escorpiodra = {
		description = Text.ARTROPODE_BAIXO_DE_CARAPACA_LONGA_E_CAUDA_MINERA_5CAC82,
		personality = "Defensivo",
		family = Text.ARTROPODE_DAS_DUNAS_BD4686,
	},
	esfingeolito = {
		description = Text.FERA_DE_POSTURA_CERIMONIAL_E_ADORNOS_QUE_LEMBRAM_2734EF,
		personality = "Orgulhoso",
		family = Text.FERA_DAS_RUINAS_21B747,
	},
	colossodune = {
		description = Text.UM_GOLEM_MONUMENTAL_QUE_CARREGA_MARCAS_LUMINOSAS_240E80,
		personality = "Calmo",
		family = Text.GOLEM_DE_ARENITO_430BBE,
	},
	penugem = {
		description = Text.AVE_PEQUENA_DE_CABECA_GRANDE_E_PENAS_LEVES_QUE_B_9F5B3C,
		personality = Text.SOCIAVEL_3658F4,
		family = Text.AVE_DE_PENUGEM_64B3BF,
	},
	ventanil = {
		description = Text.AVE_ESGUIA_DE_PENAS_COMPRIDAS_PARECIDAS_COM_FITA_3210A8,
		personality = "Inquieto",
		family = Text.AVE_DE_CORRENTES_BE2743,
	},
	trovoraptor = {
		description = Text.REPTIL_ALADO_DE_CRISTA_ANGULAR_E_PENAS_LUMINOSAS_1BDA7B,
		personality = "Impulsivo",
		family = Text.REPTIL_DA_TORMENTA_866C78,
	},
	aeronimbo = {
		description = Text.SERPENTE_DE_CAUDA_LONGA_CERCADA_POR_PEQUENAS_FOR_F1F994,
		personality = Text.DISTRAIDO_F06BBE,
		family = Text.SERPENTE_DE_NUVENS_996D8C,
	},
	lodinho = {
		description = Text.CRIATURA_BAIXA_E_ARREDONDADA_COM_TUFOS_QUE_PAREC_435F19,
		personality = Text.DOCIL_8D04ED,
		family = Text.ESPIRITO_DO_LODO_E4FC60,
	},
	caudalume = {
		description = Text.SERPENTE_DELGADA_QUE_GUIA_OS_PASSOS_DE_VIAJANTES_F40CC1,
		personality = "Atento",
		family = "Serpente-lanterna",
	},
	vagalumorte = {
		description = Text.INSETO_DE_CARAPACA_ESCURA_QUE_PRODUZ_UMA_LUZ_SUA_47ED1F,
		personality = "Noturno",
		family = Text.INSETO_LUMINESCENTE_CAD635,
	},
	reinevoento = {
		description = Text.ESPIRITO_ALTO_DE_MANTO_FLUIDO_E_COROA_QUE_EMERGE_0AF473,
		personality = Text.ENIGMATICO_6A79E0,
		family = Text.ESPIRITO_COROADO_EE88B7,
	},
	vaporino = {
		description = Text.SERPENTE_HIBRIDA_QUE_TRANSFORMA_O_ENCONTRO_DE_FO_337A4D,
		personality = "Expansivo",
		family = Text.SERPENTE_DE_VAPOR_C3B66D,
	},
	magmaterra = {
		description = Text.FERA_DE_PLACAS_GROSSAS_QUE_COMBINA_O_PESO_DA_TER_C2DEC4,
		personality = "Tenaz",
		family = Text.FERA_DE_PLACAS_B3BE4D,
	},
	tempestalia = {
		description = Text.AVE_DE_PENAS_VIVAS_QUE_ACOMPANHA_AS_NUVENS_CARRE_D137E5,
		personality = "Intensa",
		family = Text.AVE_DE_TEMPESTADE_9144A1,
	},
	nevoamusgo = {
		description = Text.ESPIRITO_DE_GALHOS_E_LIQUENS_QUE_SURGE_ONDE_A_FL_090F2A,
		personality = "Discreto",
		family = Text.ESPIRITO_DE_LIQUEN_6F48F0,
	},
	cinzavento = {
		description = Text.REPTIL_DE_ASAS_COMPRIDAS_COM_PENAS_QUE_ESPALHAM__15C278,
		personality = "Independente",
		family = Text.REPTIL_DE_CINZAS_EDC942,
	},
	fenix = {
		description = Text.AVE_LENDARIA_ADULTA_DE_HALO_SOLAR_E_CAUDA_TRIPLA_CC26C7,
		personality = "Majestosa",
		family = Text.AVE_SOLAR_LENDARIA_06397E,
	},
	bambunim = {
		description = "Capivara de bambu que carrega brotos nas costas e abre trilhas para seus companheiros.",
		personality = "Sereno",
		family = "Capivara dos bambuzais",
	},
	brasebode = {
		description = "Seus chifres de cobre guardam calor; bate os cascos para afastar cinzas das encostas.",
		personality = "Valente",
		family = "Caprino de cobre e brasa",
	},
	coralote = {
		description = "Anfíbio de guelras corais que cultiva pequenas flores marinhas ao redor do pescoço.",
		personality = "Brincalhão",
		family = "Anfíbio dos corais",
	},
	dunatatu = {
		description = "Protege o focinho sob placas de cerâmica e desenha espirais na areia com sua cauda.",
		personality = "Cauteloso",
		family = "Tatu de cerâmica",
	},
	nimburso = {
		description = "Urso envolto em nuvens macias; seus passos silenciosos anunciam a chegada da neblina.",
		personality = "Gentil",
		family = "Urso das nuvens",
	},
	lumissapo = {
		description = "Acende a bolsa de sua garganta para guiar viajantes por caminhos seguros do pântano.",
		personality = "Vigilante",
		family = "Anuro de luz noturna",
	},
	nectarim = {
		description = "Guarda néctar em um abdômen brilhante e espalha pólen com asas que lembram pétalas.",
		personality = "Dedicado",
		family = "Abelha das orquídeas",
	},
	cristalince = {
		description = "As pontas de quartzo de suas orelhas vibram antes das tempestades de areia.",
		personality = "Perspicaz",
		family = "Felino de quartzo",
	},
	maritromba = {
		description = "Mamífero das marés com tromba curta e presas de marfim; navega entre bancos de coral.",
		personality = "Sociável",
		family = "Elefante das marés",
	},
	kraken = {
		description = "Guardião adulto das profundezas, reconhecido por oito braços curvos e uma coroa de coral antigo. Surge raramente no Recife e não participa de cruzamentos.",
		personality = "Majestoso",
		family = "Cefalópode lendário",
	},
}
