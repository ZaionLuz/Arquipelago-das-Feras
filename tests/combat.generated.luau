local Color3={fromRGB=function() return {} end}
local M_Strings=(function()
--!strict
local S = {
	UNKNOWN_ISLAND = "Região inválida",
	NOT_UNLOCKED = "Região ainda bloqueada",
	LOCKED_LEVEL = "Nível do explorador insuficiente",
	LOCKED_PREV = "Desbloqueie a região anterior",
	LOCKED_GOLD = "Ouro insuficiente",
	LOCKED_GUARDIAN = "Vença o guardião anterior",
	LEGACY = "Acesso legado",
	OK = "Acesso permitido",
	WRONG_REGION = "Viaje até a região antes de iniciar esta ação",
}

function S.reason(code: string): string
	return S[code] or code
end
S.Text = {
	ABRINDO_A_COMPRA_5DF77F = "Abrindo a compra...",
	ACAMPAMENTO_DO_ALVORECER_EBD2E1 = "Acampamento do Alvorecer",
	ACARICIAR_COMPANHEIRO_6D295C = "Acariciar companheiro",
	ACESSO_NEGADO_AB7F08 = "Acesso negado",
	AGORA_VIVE_EM_207F92 = " agora vive em ",
	AGUARDE_O_TURNO_25CBEF = "Aguarde o turno.",
	AGUA_F11A05 = "Água",
	AINDA_NAO_ECLODIU_EB8B13 = "Ainda não eclodiu",
	ALIMENTAR_14F041 = "Alimentar",
	ALIMENTE_20_VEZES_CA2277 = "Alimente 20 vezes",
	ALIMENTE_5_VEZES_C4C1AB = "Alimente 5 vezes",
	ALIMENTE_SUAS_FERAS_TRES_VEZES_C051DF = "Alimente suas feras três vezes.",
	ALIMENTE_UMA_FERA_6CB80D = "Alimente uma fera",
	ALTAR_EM_REPOUSO_64BE88 = "Altar em repouso",
	ALTO_F46EDD = "Alto",
	AMBOS_DEVEM_TOCAR_DESAFIAR_EM_ATE_30S_DE8B6F = " — ambos devem tocar Desafiar em até 30s",
	ANCESTRAL_24E41A = "Ancestral",
	ANCESTRAVORE_146E5C = "Ancestrávore",
	ANFIBIO_DE_BOLHAS_42099D = "Anfíbio de bolhas",
	APRESENTACAO_INTERROMPIDA_310A92 = "Apresentação interrompida: ",
	APROXIME_SE_DE_UMA_FERA_SELVAGEM_ESCOLHA_LUTAR_C_CD5B93 = "Aproxime-se de uma fera selvagem. Escolha lutar, criar vínculo ou capturar.",
	ARACNIDEO_COM_PETALAS_PROTETORAS_QUE_SE_CAMUFLA__618FB3 = "Aracnídeo com pétalas protetoras que se camufla como uma flor da floresta.",
	ARACNIDEO_VEGETAL_A28194 = "Aracnídeo vegetal",
	ARENA_1A4BA8 = "Arena",
	ARTROPODE_BAIXO_DE_CARAPACA_LONGA_E_CAUDA_MINERA_5CAC82 = "Artrópode baixo de carapaça longa e cauda mineral erguida.",
	ARTROPODE_DAS_DUNAS_BD4686 = "Artrópode das dunas",
	ARVORES_QUE_SUSSURRAM_SEGREDOS_37CC8A = "Árvores que sussurram segredos.",
	AR_B623FF = "Ar",
	AS_MARCAS_AINDA_NAO_RESPONDEM_A_SUA_PRESENCA_12E579 = "As marcas ainda não respondem à sua presença.",
	AS_MARCAS_REPOUSAM_POR_F8A177 = "As marcas repousam por ",
	AS_RUINAS_DAS_DUNAS_RESPONDEM_AOS_SINAIS_DAS_ALT_695E0C = "As ruínas das Dunas respondem aos sinais das alturas.",
	ATUALIZAR_7ED81F = "Atualizar",
	AVE_DE_CINZAS_2EE51C = "Ave de cinzas",
	AVE_DE_CORRENTES_BE2743 = "Ave de correntes",
	AVE_DE_PENAS_VIVAS_QUE_ACOMPANHA_AS_NUVENS_CARRE_D137E5 = "Ave de penas vivas que acompanha as nuvens carregadas sobre o recife.",
	AVE_DE_PENUGEM_64B3BF = "Ave de penugem",
	AVE_DE_TEMPESTADE_9144A1 = "Ave de tempestade",
	AVE_ESGUIA_DE_PENAS_COMPRIDAS_PARECIDAS_COM_FITA_3210A8 = "Ave esguia de penas compridas, parecidas com fitas sopradas pelo vento.",
	AVE_LENDARIA_ADULTA_DE_HALO_SOLAR_E_CAUDA_TRIPLA_CC26C7 = "Ave lendária adulta de halo solar e cauda tripla. O segredo de seu renascimento ainda não foi descoberto.",
	AVE_PEQUENA_DE_CABECA_GRANDE_E_PENAS_LEVES_QUE_B_9F5B3C = "Ave pequena, de cabeça grande e penas leves que balançam com qualquer brisa.",
	AVE_SOLAR_LENDARIA_06397E = "Ave solar lendária",
	A_PROXIMA_GERACAO_E30F93 = "A próxima geração",
	BAIXO_74FD00 = "Baixo",
	BASICO_303CE5 = "Básico",
	BATALHA_INVALIDA_A8AE42 = "Batalha inválida",
	BEM_VINDO_AO_SEU_SANTUARIO_161FE8 = "Bem-vindo ao seu santuário",
	BESTIARIO_65A46C = "Bestiário",
	BRACO_DB4D66 = "Braço",
	BRINCALHAO_5822EE = "Brincalhão",
	BROTO_VIVO_30A437 = "Broto vivo",
	BUSCAR_ESPECIE_09F339 = "Buscar espécie",
	CABECA_D8228B = "Cabeça",
	CAMINHO_CENTRAL_22B87F = "Caminho central",
	CAMPOS_NASCENTES_E_O_PRIMEIRO_ACAMPAMENTO_DE_PES_4187EC = "Campos, nascentes e o primeiro acampamento de pesquisa.",
	CAPITULO_CONCLUIDO_BF33C2 = "Capítulo concluído! +",
	CAPTURE_DIRETAMENTE_OU_ESCOLHA_UMA_FERA_PARA_ENF_DF3AFD = "Capture diretamente ou escolha uma fera para enfraquecer o encontro.",
	CAPTURE_UMA_FERA_SELVAGEM_E_APRESENTE_SUA_DESCOB_696F7C = "Capture uma fera selvagem e apresente sua descoberta à pesquisadora Maia.",
	CAPTUROU_CONTINUAR_7DA1D5 = "Capturou! Continuar",
	CARANGUEPEROLA_08BAB3 = "Caranguepérola",
	CARREGANDO_SEU_SANTUARIO_53DAC6 = "Carregando seu santuário...",
	CHEGOU_A_FAE834 = "Chegou a ",
	CHOCADEIRA_CHEIA_3D3160 = "Chocadeira cheia",
	CHOCADEIRA_DISPONIVEL_F42230 = "Chocadeira disponível",
	CHOQUE_5_OVOS_5ED8F1 = "Choque 5 ovos",
	CHOQUE_UM_OVO_03D8B3 = "Choque um ovo",
	CHOQUE_UM_OVO_NO_SEU_SANTUARIO_559309 = "Choque um ovo no seu santuário.",
	COLECAO_57798D = " • Coleção: ",
	COLETAR_199B16 = "Coletar",
	COLETE_OURO_5_VEZES_A103BB = "Colete ouro 5 vezes",
	COLETE_OURO_OU_ENCONTRE_UMA_FERA_SELVAGEM_ABRA_M_40C94E = "Colete ouro ou encontre uma fera selvagem. Abra Menu para cuidar da coleção.",
	COMPANHEIRO_ESCOLHIDO_411FF1 = "Companheiro escolhido",
	COMPANHEIRO_FDBCE5 = "Companheiro",
	COMPANHEIRO_GUARDADO_027BB3 = "Companheiro guardado",
	COMPRAR_F8AAD3 = "Comprar",
	COMUM_CA938E = "Comum",
	CONCESSAO_RECUSADA_951368 = "Concessão recusada: ",
	CONCLUA_O_CAPITULO_ATUAL_PRIMEIRO_3187C6 = "Conclua o capítulo atual primeiro",
	CONEXAO_INDISPONIVEL_TOQUE_ATUALIZAR_PARA_RECUPE_DAB864 = "Conexão indisponível. Toque Atualizar para recuperar o encontro.",
	CONEXAO_INTERROMPIDA_TENTE_NOVAMENTE_32854B = "Conexão interrompida. Tente novamente.",
	CONQUISTA_100_VITORIAS_29C94D = "Conquista: 100 vitórias",
	CONQUISTA_ALIMENTE_100_VEZES_9D7566 = "Conquista: alimente 100 vezes",
	CONQUISTA_CHOQUE_25_OVOS_57A023 = "Conquista: choque 25 ovos",
	CONQUISTA_COLETE_50_VEZES_0CDE21 = "Conquista: colete 50 vezes",
	CONQUISTA_DESCUBRA_TODAS_AS_FERAS_8AFA2F = "Conquista: descubra todas as feras",
	CONSTRUA_ESSE_HABITAT_NO_SANTUARIO_6A9DF1 = "Construa esse habitat no Santuário",
	CONSTRUIR_NA_POSICAO_AF4C45 = "Construir na posição ",
	CONTINUAR_AVENTURA_E2F9B1 = "Continuar aventura",
	CONVERSAR_AC3B38 = "Conversar",
	CONVITE_ENVIADO_O_RIVAL_DEVE_TOCAR_DESAFIAR_NO_S_D712DA = "Convite enviado. O rival deve tocar Desafiar no seu nome em até 30s para aceitar.",
	CORAIS_QUE_CANTAM_A_NOITE_DE26D3 = "Corais que cantam à noite.",
	CRIAR_VINCULO_A663E9 = "Criar vínculo",
	CRIATURA_ARREDONDADA_COM_PEQUENAS_GUELRAS_QUE_OB_D759C9 = "Criatura arredondada com pequenas guelras que observa o mundo através de bolhas.",
	CRIATURA_BAIXA_E_ARREDONDADA_COM_TUFOS_QUE_PAREC_435F19 = "Criatura baixa e arredondada com tufos que parecem musgo úmido.",
	CRIATURA_INVALIDA_3A9F3E = "Criatura inválida",
	CRUSTACEO_PEROLADO_057427 = "Crustáceo perolado",
	CRUZE_5_VEZES_E3D7DC = "Cruze 5 vezes",
	CRUZE_DUAS_FERAS_539F57 = "Cruze duas feras",
	DADOS_INDISPONIVEIS_OU_SESSAO_AINDA_ATIVA_AGUARD_97BBDC = "Dados indisponíveis ou sessão ainda ativa. Aguarde e reconecte; nada foi reiniciado.",
	DERROTA_PARA_F29D4F = "Derrota para ",
	DERROTE_UM_GUARDIAO_DE_ILHA_PARA_CONCLUIR_SUA_PR_5B283B = "Derrote um guardião de ilha para concluir sua primeira expedição.",
	DESAFIAR_59C639 = "Desafiar",
	DESAFIAR_GUARDIAO_C2DC77 = "Desafiar guardião",
	DESAFIO_DO_GUARDIAO_NAO_PERMITE_CAPTURA_1198C8 = "Desafio do guardião • não permite captura",
	DESBLOQUEAR_539711 = "Desbloquear",
	DESBLOQUEIE_A_ILHA_CC6976 = "Desbloqueie a ilha",
	DESCUBRA_15_FERAS_B78B13 = "Descubra 15 feras",
	DESCUBRA_8_FERAS_F45F2C = "Descubra 8 feras",
	DESCUBRA_NOVOS_OVOS_38146F = "Descubra novos ovos",
	DESTINO_AINDA_NAO_CARREGOU_TENTE_NOVAMENTE_005D89 = "Destino ainda não carregou. Tente novamente.",
	DESTINO_INDISPONIVEL_06B531 = "Destino indisponível",
	DISTRAIDO_F06BBE = "Distraído",
	DOCIL_8D04ED = "Dócil",
	DRAGAO_DE_BASALTO_ACD199 = "Dragão de basalto",
	DUNAS_QUEBRADAS_B76161 = "Dunas Quebradas",
	ECLOSAO_EXTRAORDINARIA_EA7909 = "ECLOSÃO EXTRAORDINÁRIA!",
	ECO_DE_FOGO_ANTIGO_40525F = "Eco de Fogo Antigo",
	ELEMENTAL_5871BB = "Elemental",
	ELEMENTO_INCOMPATIVEL_COM_ESTE_HABITAT_30076C = "Elemento incompatível com este habitat",
	EM_ANDAMENTO_5CA373 = "Em andamento",
	EM_MISSOES_RESGATE_SUA_PRIMEIRA_RECOMPENSA_AB00E0 = "Em MISSÕES, resgate sua primeira recompensa.",
	ENCONTRAR_FERA_2CE20D = "Encontrar fera",
	ENCONTRE_UM_MARCO_DE_EXPLORACAO_E_RECOLHA_SUA_ES_D6C5D0 = "Encontre um marco de exploração e recolha sua essência.",
	ENIGMATICO_6A79E0 = "Enigmático",
	ENTRAR_7573BA = "Entrar",
	EPICO_7BC392 = "Épico",
	ESCOLHA_DOIS_PROGENITORES_C7CD31 = " • Escolha dois progenitores",
	ESCOLHA_DUAS_FERAS_DIFERENTES_D70C07 = "Escolha duas feras diferentes",
	ESCOLHA_UMA_FERA_PARA_BATALHAR_462F3D = "Escolha uma fera para batalhar",
	ESCOLHA_UMA_FERA_SUA_E1857C = "Escolha uma fera sua",
	ESCOLHA_UM_COMPANHEIRO_FBC455 = "Escolha um companheiro",
	ESCOLHER_D7B72C = "Escolher",
	ESPECIE_DESCONHECIDA_6C9CF9 = "Espécie desconhecida",
	ESPECIE_MISTERIOSA_EXPLORE_CAPTURE_OU_CRUZE_FERA_6D0C6C = "Espécie misteriosa\nExplore, capture ou cruze feras para conhecer sua história.",
	ESPIRITO_ALTO_DE_MANTO_FLUIDO_E_COROA_QUE_EMERGE_0AF473 = "Espírito alto de manto fluido e coroa que emerge da névoa umbral.",
	ESPIRITO_COROADO_EE88B7 = "Espírito coroado",
	ESPIRITO_DE_GALHOS_E_LIQUENS_QUE_SURGE_ONDE_A_FL_090F2A = "Espírito de galhos e líquens que surge onde a floresta encontra a sombra.",
	ESPIRITO_DE_LIQUEN_6F48F0 = "Espírito de líquen",
	ESPIRITO_DO_LODO_E4FC60 = "Espírito do lodo",
	ESSENCIA_2D0983 = " essência ",
	ESSENCIA_DE_0F286A = " essência de ",
	ESSENCIA_DE_3D63D1 = "Essência de ",
	ESTADO_ATUALIZADO_ESCOLHA_NOVAMENTE_CD8857 = "Estado atualizado. Escolha novamente.",
	ESTAGIO_D2FEE2 = " • Estágio ",
	ESTRUTURA_REMOVIDA_SEM_REEMBOLSO_565589 = "Estrutura removida, sem reembolso",
	EVENTO_50_OURO_DE_S_DH_853264 = "Evento: +50%% ouro de %s (%dh)",
	EVOLUI_EM_7_15_75E2ED = " • Evolui em 7 / 15",
	EXAMINAR_F96563 = "Examinar",
	EXPLORADOR_PREPARADO_3D4C3B = "Explorador preparado",
	FALHA_AO_SALVAR_PERFIL_DE_B99672 = "Falha ao salvar perfil de ",
	FECHAR_7B2006 = "Fechar",
	FENIX_A08C9E = "Fênix",
	FLAMIRIS_NAME = "Flamiris",
	CARVUNIO_NAME = "Carvúnio",
	BRASEGATO_NAME = "Brasegato",
	ORVALUME_NAME = "Orvalume",
	CORALINA_NAME = "Coralina",
	PELAGUIR_NAME = "Pelaguir",
	MUSGALTE_NAME = "Musgalte",
	BAMBUJA_NAME = "Bambujá",
	FLORABELHA_NAME = "Florabelha",
	MARMURE_NAME = "Marmuré",
	LITORISCO_NAME = "Litorisco",
	SEMENTAURO_NAME = "Sementauro",
	SIBILOBO_NAME = "Sibilobo",
	CIRRANDOR_NAME = "Cirrandor",
	NIMBOREO_NAME = "Nimbóreo",
	VELUNE_NAME = "Veluné",
	OBSIDAURO_NAME = "Obsidauro",
	VELUMOSA_NAME = "Velumosa",
	GLAURINA_NAME = "Glaurina",
	NIVEOR_NAME = "Níveor",
	GELIFOCA_NAME = "Gelifoca",
	FULGARRU_NAME = "Fulgarru",
	AMPELINCE_NAME = "Ampelince",
	TROVISSIDEO_NAME = "Trovissídeo",
	AURIFITA_NAME = "Aurifita",
	LUNARRU_NAME = "Lunarru",
	CANDEIRA_NAME = "Candeíra",
	FERRUNILA_NAME = "Ferrunila",
	FIARANHA_NAME = "Fiaranha",
	METAFALCAO_NAME = "Metafalcão",
	CINDREL_NAME = "Cindrel",
	EMBERKIT_NAME = "Emberkit",
	SPARKPUP_NAME = "Sparkpup",
	FLAMECUB_NAME = "Flamecub",
	COALCRAWLER_NAME = "Coalcrawler",
	AQUASPRITE_NAME = "Aqua Sprite",
	DROPLET_NAME = "Droplet",
	FINLING_NAME = "Finling",
	TIDEPUP_NAME = "Tidepup",
	CORALKIT_NAME = "Coralkit",
	LEAFLET_NAME = "Leaflet",
	SEEDLING_NAME = "Seedling",
	SPROU_NAME = "Sprou",
	VINECUB_NAME = "Vinecub",
	PETALPAW_NAME = "Petalpaw",
	PEBBLIN_NAME = "Pebblin",
	ROCKLING_NAME = "Rockling",
	SANDPUP_NAME = "Sandpup",
	DUNECUB_NAME = "Dunecub",
	GEODETTE_NAME = "Geodette",
	ZEPHYR_NAME = "Zephyr",
	CLOUDPUFF_NAME = "Cloudpuff",
	BREEZEKIT_NAME = "Breezekit",
	GALEHATCH_NAME = "Galehatch",
	WINDLING_NAME = "Windling",
	SHADE_NAME = "Shade",
	SHADOWMITE_NAME = "Shadowmite",
	GLOOMKIT_NAME = "Gloomkit",
	DUSKPUP_NAME = "Duskpup",
	NIGHTMOTH_NAME = "Nightmoth",
	FROSTBIT_NAME = "Frostbit",
	ICECRYSTAL_NAME = "Icecrystal",
	SNOWKIT_NAME = "Snowkit",
	GLACIERCUB_NAME = "Glaciercub",
	FROSTLING_NAME = "Frostling",
	VOLTKIT_NAME = "Voltkit",
	SPARKLING_NAME = "Sparkling",
	JOLTEON_NAME = "Jolteon",
	ZAPCUB_NAME = "Zapcub",
	BUZZBUG_NAME = "Buzzbug",
	LUMIKIT_NAME = "Lumikit",
	GLOWORB_NAME = "Gloworb",
	SOLARPUP_NAME = "Solarpup",
	RAYCUB_NAME = "Raycub",
	PRISMFLY_NAME = "Prismfly",
	IRONKIT_NAME = "Ironkit",
	SCRAPLET_NAME = "Scraplet",
	BOLTPUP_NAME = "Boltpup",
	GEARCUB_NAME = "Gearcub",
	RIVETBUG_NAME = "Rivetbug",
	GEMLING_NAME = "Gemling",
	SHARDLET_NAME = "Shardlet",
	CRYSTALKIT_NAME = "Crystalkit",
	PRISMPUP_NAME = "Prismpup",
	FACETBUG_NAME = "Facetbug",
	RUNELING_NAME = "Runeling",
	MYSTICORB_NAME = "Mysticorb",
	ARCANKIT_NAME = "Arcankit",
	VOIDPUP_NAME = "Voidpup",
	SIGILBUG_NAME = "Sigilbug",
	FLAMIRIS_NAME = "Flamiris",
	CARVUNIO_NAME = "Carvúnio",
	BRASEGATO_NAME = "Brasegato",
	ORVALUME_NAME = "Orvalume",
	CORALINA_NAME = "Coralina",
	PELAGUIR_NAME = "Pelaguir",
	MUSGALTE_NAME = "Musgalte",
	BAMBUJA_NAME = "Bambujá",
	FLORABELHA_NAME = "Florabelha",
	MARMURE_NAME = "Marmuré",
	LITORISCO_NAME = "Litorisco",
	SEMENTAURO_NAME = "Sementauro",
	SIBILOBO_NAME = "Sibilobo",
	CIRRANDOR_NAME = "Cirrandor",
	NIMBOREO_NAME = "Nimbóreo",
	VELUNE_NAME = "Veluné",
	OBSIDAURO_NAME = "Obsidauro",
	VELUMOSA_NAME = "Velumosa",
	GLAURINA_NAME = "Glaurina",
	NIVEOR_NAME = "Níveor",
	GELIFOCA_NAME = "Gelifoca",
	FULGARRU_NAME = "Fulgarru",
	AMPELINCE_NAME = "Ampelince",
	TROVISSIDEO_NAME = "Trovissídeo",
	AURIFITA_NAME = "Aurifita",
	LUNARRU_NAME = "Lunarru",
	CANDEIRA_NAME = "Candeíra",
	FERRUNILA_NAME = "Ferrunila",
	FIARANHA_NAME = "Fiaranha",
	METAFALCAO_NAME = "Metafalcão",
	CINDREL_NAME = "Cindrel",
	EMBERKIT_NAME = "Emberkit",
	SPARKPUP_NAME = "Sparkpup",
	FLAMECUB_NAME = "Flamecub",
	COALCRAWLER_NAME = "Coalcrawler",
	AQUASPRITE_NAME = "Aqua Sprite",
	DROPLET_NAME = "Droplet",
	FINLING_NAME = "Finling",
	TIDEPUP_NAME = "Tidepup",
	CORALKIT_NAME = "Coralkit",
	LEAFLET_NAME = "Leaflet",
	SEEDLING_NAME = "Seedling",
	SPROU_NAME = "Sprou",
	VINECUB_NAME = "Vinecub",
	PETALPAW_NAME = "Petalpaw",
	PEBBLIN_NAME = "Pebblin",
	ROCKLING_NAME = "Rockling",
	SANDPUP_NAME = "Sandpup",
	DUNECUB_NAME = "Dunecub",
	GEODETTE_NAME = "Geodette",
	ZEPHYR_NAME = "Zephyr",
	CLOUDPUFF_NAME = "Cloudpuff",
	BREEZEKIT_NAME = "Breezekit",
	GALEHATCH_NAME = "Galehatch",
	WINDLING_NAME = "Windling",
	SHADE_NAME = "Shade",
	SHADOWMITE_NAME = "Shadowmite",
	GLOOMKIT_NAME = "Gloomkit",
	DUSKPUP_NAME = "Duskpup",
	NIGHTMOTH_NAME = "Nightmoth",
	FROSTBIT_NAME = "Frostbit",
	ICECRYSTAL_NAME = "Icecrystal",
	SNOWKIT_NAME = "Snowkit",
	GLACIERCUB_NAME = "Glaciercub",
	FROSTLING_NAME = "Frostling",
	VOLTKIT_NAME = "Voltkit",
	SPARKLING_NAME = "Sparkling",
	JOLTEON_NAME = "Jolteon",
	ZAPCUB_NAME = "Zapcub",
	BUZZBUG_NAME = "Buzzbug",
	LUMIKIT_NAME = "Lumikit",
	GLOWORB_NAME = "Gloworb",
	SOLARPUP_NAME = "Solarpup",
	RAYCUB_NAME = "Raycub",
	PRISMFLY_NAME = "Prismfly",
	IRONKIT_NAME = "Ironkit",
	SCRAPLET_NAME = "Scraplet",
	BOLTPUP_NAME = "Boltpup",
	GEARCUB_NAME = "Gearcub",
	RIVETBUG_NAME = "Rivetbug",
	GEMLING_NAME = "Gemling",
	SHARDLET_NAME = "Shardlet",
	CRYSTALKIT_NAME = "Crystalkit",
	PRISMPUP_NAME = "Prismpup",
	FACETBUG_NAME = "Facetbug",
	RUNELING_NAME = "Runeling",
	MYSTICORB_NAME = "Mysticorb",
	ARCANKIT_NAME = "Arcankit",
	VOIDPUP_NAME = "Voidpup",
	SIGILBUG_NAME = "Sigilbug",
	FENIX_FULIGEM_64EF6D = "Fênix Fuligem",
	FENIX_LENDARIA_NV_60_A1FE17 = "FÊNIX · LENDÁRIA · Nv. 60",
	FERAS_EF033A = "Feras",
	FERA_DAS_RUINAS_21B747 = "Fera das ruínas",
	FERA_DE_CORPO_ESGUIO_E_ORELHAS_VEGETAIS_QUE_SE_E_066C4A = "Fera de corpo esguio e orelhas vegetais que se esconde entre folhas novas.",
	FERA_DE_FOCINHO_LARGO_E_PRESAS_MINERAIS_QUE_PROC_12FD1E = "Fera de focinho largo e presas minerais que procura pedras aquecidas.",
	FERA_DE_PLACAS_B3BE4D = "Fera de placas",
	FERA_DE_PLACAS_GROSSAS_QUE_COMBINA_O_PESO_DA_TER_C2DEC4 = "Fera de placas grossas que combina o peso da terra ao calor das brasas.",
	FERA_DE_POSTURA_CERIMONIAL_E_ADORNOS_QUE_LEMBRAM_2734EF = "Fera de postura cerimonial e adornos que lembram as ruínas do deserto.",
	FERA_FOLHOSA_F92CC9 = "Fera folhosa",
	FERA_ROBUSTA_CUJOS_GALHOS_LEMBRAM_A_COPA_DE_ARVO_4AD52F = "Fera robusta cujos galhos lembram a copa de árvores muito antigas.",
	FERA_VULCANICA_66F6AD = "Fera vulcânica",
	FLORESTA_MURMURANTE_DDD13E = "Floresta Murmurante",
	FOGO_F77A3C = "Fogo",
	FOLHUCO_22B5C1 = "Folhuço",
	FUGIR_2C0D38 = "Fugir",
	GEODA_VIVA_87C5A2 = "Geoda viva",
	GOLEM_DE_ARENITO_430BBE = "Golem de arenito",
	GOLPE_EF9EC5 = "Golpe",
	GRAOZINHO_D0C3F0 = "Grãozinho",
	GUARDAR_A0B626 = "Guardar",
	GUARDIAO_6B7FE6 = " · Guardião ",
	GUARDIAO_ARBOREO_471EEF = "Guardião arbóreo",
	HABILIDADE_8425E4 = "Habilidade",
	HABITAT_CHEIO_1E10B0 = "Habitat cheio",
	HABITAT_CONSTRUIDO_NO_SEU_TERRENO_C7F40C = "Habitat construído no seu terreno",
	HABITAT_INDISPONIVEL_OU_MAXIMO_989E00 = "Habitat indisponível ou máximo",
	HABITAT_MELHORADO_MAIS_DUAS_VAGAS_C4EEBD = "Habitat melhorado: mais duas vagas",
	HABITAT_MOVIDO_2E232D = "Habitat movido",
	HABITAT_POSICAO_OU_DESBLOQUEIO_INVALIDO_CC4AAD = "Habitat, posição ou desbloqueio inválido",
	HIBRIDO_9CB40A = "Híbrido",
	ILHAS_577072 = "Ilhas",
	ILHAS_DE_NUVEM_E_TEMPESTADE_9FF959 = "Ilhas de nuvem e tempestade.",
	ILHA_DAS_BRASAS_78BBD5 = "Ilha das Brasas",
	ILHA_DO_ALVORECER_414C6C = "Ilha do Alvorecer",
	ILHA_OU_CRIATURA_INVALIDA_000968 = "Ilha ou criatura inválida",
	ILHA_PESSOAL_498B3B = "Ilha pessoal",
	INSCRICAO_3A97CD = "Inscrição",
	INSETO_DE_CARAPACA_ESCURA_QUE_PRODUZ_UMA_LUZ_SUA_47ED1F = "Inseto de carapaça escura que produz uma luz suave, quase lunar.",
	INSETO_LUMINESCENTE_CAD635 = "Inseto luminescente",
	INVESTIDA_FEROZ_70FE97 = "Investida feroz",
	ITEM_INVALIDO_96E69E = "Item inválido",
	JA_DESBLOQUEADA_118724 = "Já desbloqueada",
	JA_PODE_CHOCAR_035D5F = "Já pode chocar",
	JOGADOR_INDISPONIVEL_D18F3F = "Jogador indisponível",
	LANCAR_SELO_CDEDAC = "Lançar Selo",
	LEASE_INVALIDO_1F2C7F = "Lease inválido",
	LENDARIO_52178E = "Lendário",
	LIMITE_DE_60_FERAS_E2D3F3 = "Limite de 60 feras",
	LOJA_B9614D = "Loja",
	MAIA_PESQUISADORA_1A62F7 = "Maia • Pesquisadora",
	MAIA_PESQUISADORA_DO_ARQUIPELAGO_38D949 = "Maia, pesquisadora do arquipélago",
	MAIA_VOCE_CONCLUIU_NOSSOS_PRIMEIROS_ESTUDOS_CONT_FCC227 = "Maia: Você concluiu nossos primeiros estudos. Continue descobrindo o arquipélago!",
	MARCA_ANTIGA_9C4D11 = "Marca antiga",
	MARCO_ELEMENTAL_3DB8E3 = "Marco elemental",
	MARE_DEBILITANTE_389076 = "Maré debilitante",
	MEDIO_4F48C1 = "Médio",
	MELHORE_UM_DOS_SEUS_HABITATS_EF7888 = "Melhore um dos seus habitats.",
	MENU_57F5F5 = "Menu",
	MERCADO_DE_OVOS_COMPRAS_COM_OURO_DO_JOGO_7CDE97 = "Mercado de ovos — compras com ouro do jogo",
	MISSAO_INDISPONIVEL_EE2728 = "Missão indisponível",
	MISSOES_FAE2D2 = "Missões",
	MODELO_SERA_RECONSTRUIDO_NA_PROXIMA_ATUALIZACAO_BF3624 = "Modelo será reconstruído na próxima atualização: ",
	MOVIMENTOS_REDUZIDOS_285637 = "Movimentos reduzidos",
	NAO_FOI_POSSIVEL_OBTER_O_PERFIL_RECONECTE_PARA_T_9B595C = "Não foi possível obter o perfil. Reconecte para tentar novamente.",
	NATUREZA_FB1ED9 = "Natureza",
	NA_ABA_FERAS_TOQUE_EM_ALIMENTAR_PARA_EVOLUIR_UMA_2E587F = "Na aba FERAS, toque em ALIMENTAR para evoluir uma fera.",
	NA_ABA_OVOS_ESCOLHA_2_FERAS_E_TOQUE_CRUZAR_518B3E = "Na aba OVOS, escolha 2 feras e toque CRUZAR.",
	NENHUMA_ESPECIE_CORRESPONDE_AOS_FILTROS_7AC10E = "Nenhuma espécie corresponde aos filtros.",
	NENHUM_OUTRO_JOGADOR_AGORA_CONVIDE_AMIGOS_C96A34 = "Nenhum outro jogador agora. Convide amigos!",
	NEVOAMUSGO_8FDC87 = "Névoamusgo",
	NEVOA_VIVA_E_LUZES_QUE_ENGANAM_0BE524 = "Névoa viva e luzes que enganam.",
	NIVEIS_769F71 = " níveis · ",
	NIVEL_002242 = " • Nível ",
	NIVEL_2EE2A0 = "Nível ",
	NIVEL_44C4F0 = " · Nível ",
	NIVEL_MAXIMO_8078AA = "Nível máximo",
	NOVA_TENTATIVA_EM_CA2FA0 = "Nova tentativa em ",
	NUCLEO_DE_BRASAS_D7AC7B = "Núcleo de brasas",
	NV_MIN_EC7398 = " · Nv. mín. ",
	OFERECA_UMA_CHAMA_NO_ALTAR_DAS_RUINAS_24F74A = "Ofereça uma chama no altar das ruínas.",
	OFERECER_CHAMA_E43EFE = "Oferecer chama",
	OPCOES_4C8DF5 = "Opções",
	OS_SELOS_SE_ESGOTARAM_A_CHAMA_REPOUSARA_POR_VINT_B19B32 = "Os selos se esgotaram. A chama repousará por vinte minutos.",
	OURO_1_TROFEU_AC2EBF = " ouro, +1 troféu",
	OURO_INCUBACAO_30480S_E8C4B8 = " ouro • Incubação: 30–480s\n",
	OURO_INSUFICIENTE_AF56CF = "Ouro insuficiente (",
	OURO_LIMITE_10_MIL_SELOS_71673A = " ouro; limite 10 mil selos",
	OURO_MIN_BASE_C8313A = " • Ouro/min base ",
	OVOS_99289F = "Ovos",
	OVO_ACELERADO_AB603C = "Ovo acelerado!",
	OVO_DE_763A79 = "Ovo de ",
	OVO_INVALIDO_5146F8 = "Ovo inválido",
	OVO_MISTERIOSO_ECLODE_EM_F655A9 = "Ovo misterioso! Eclode em ",
	OVO_SEM_IDENTIFICACAO_RECONECTE_PARA_MIGRAR_D37C37 = "Ovo sem identificação; reconecte para migrar",
	O_ENCONTRO_ENCERROU_DISTANCIA_TEMPO_OU_PERSONAGE_9012D6 = "O encontro encerrou: distância, tempo ou personagem indisponível.",
	O_ENCONTRO_TERMINOU_6F159C = "O encontro terminou.",
	O_PRIMEIRO_GUARDIAO_CD87B3 = "O primeiro guardião",
	O_PRIMEIRO_VINCULO_273E14 = "O primeiro vínculo",
	PANTANO_UMBRAL_FBA600 = "Pântano Umbral",
	PEDIDO_INVALIDO_C2C28F = "Pedido inválido.",
	PEDRA_ANTIGA_ACE013 = "Pedra antiga",
	PERFIL_INVALIDO_OU_VERSAO_FUTURA_RECUPERACAO_MAN_C36F9F = "Perfil inválido ou versão futura; recuperação manual necessária",
	PERSONAGEM_OU_DESTINO_INDISPONIVEL_AGUARDE_E_TEN_09997D = "Personagem ou destino indisponível. Aguarde e tente novamente.",
	PICOS_CELESTES_4FA949 = "Picos Celestes",
	PORTAL_DE_RETORNO_18016A = "Portal de retorno",
	PORTAL_DO_SANTUARIO_1F3781 = "Portal do santuário",
	POR_944529 = "Pôr: ",
	POSICAO_26334E = " • Posição ",
	POSICAO_OCUPADA_OU_INVALIDA_5582C8 = "Posição ocupada ou inválida",
	PRECISA_DE_3C22C8 = "Precisa de ",
	PRECISA_DE_NIVEL_3806D7 = "Precisa de nível ",
	PRECISA_DE_OURO_E_VAGA_NA_CHOCADEIRA_7FC4F9 = "Precisa de ouro e vaga na chocadeira",
	PRIMEIRA_EXPEDICAO_CONCLUIDA_CONTINUE_EXPLORANDO_04DB58 = "Primeira expedição concluída • Continue explorando",
	PRONTO_PARA_ECLODIR_379A20 = "Pronto para eclodir!",
	PROTEGER_RECUPERAR_0A724A = "Proteger + recuperar",
	PULAR_6EC317 = "Pular",
	PULSO_VITAL_629F87 = "Pulso vital",
	RAJADA_EVASIVA_6F3310 = "Rajada evasiva",
	RARO_851816 = "Raro",
	RECEBER_CAPITULO_3ACD37 = "Receber capítulo",
	RECIFE_CRISTALINO_8D7A14 = "Recife Cristalino",
	ILHA_DE_INVERNO_8F4E2A = "Ilha de Inverno",
	ILHA_DO_TROVAO_9E5F3B = "Ilha do Trovão",
	ILHA_CELESTIAL_A0F1C2 = "Ilha Celestial",
	RECOMPENSA_DIARIA_SEQUENCIA_B9C689 = "Recompensa diária (sequência ",
	REFORCADO_A930AC = "Reforçado",
	REGIAO_BLOQUEADA_47B5A8 = "Região bloqueada: ",
	REGIAO_DESBLOQUEADA_561460 = "Região desbloqueada",
	REI_NEVOENTO_691E87 = "Rei Nevoento",
	RENASCIMENTO_FUTURO_9236DA = " • Renascimento futuro",
	REPTIL_ABISSAL_4DCBF3 = "Réptil abissal",
	REPTIL_ALADO_COM_PLACAS_DE_BASALTO_E_UM_BRILHO_Q_A1E28C = "Réptil alado com placas de basalto e um brilho quente entre as escamas.",
	REPTIL_ALADO_DE_CRISTA_ANGULAR_E_PENAS_LUMINOSAS_1BDA7B = "Réptil alado de crista angular e penas luminosas de tempestade.",
	REPTIL_DA_TORMENTA_866C78 = "Réptil da tormenta",
	REPTIL_DE_ASAS_COMPRIDAS_COM_PENAS_QUE_ESPALHAM__15C278 = "Réptil de asas compridas com penas que espalham um rastro de cinzas.",
	REPTIL_DE_CINZAS_EDC942 = "Réptil de cinzas",
	REPTIL_MARINHO_QUE_ILUMINA_SEU_CAMINHO_COM_UMA_P_4A0F69 = "Réptil marinho que ilumina seu caminho com uma pequena isca sobre a cabeça.",
	RESGATAR_76A111 = "Resgatar",
	RESOLVENDO_TURNO_8CA931 = "Resolvendo turno...",
	ROCHA_FLUTUANTE_B3C46F = "Rocha flutuante",
	RUINAS_ENTERRADAS_NA_AREIA_403002 = "Ruínas enterradas na areia.",
	RUINAS_EXCEDEM_ORCAMENTO_6CD117 = "Ruínas excedem orçamento",
	SALVAMENTO_PENDENTE_AGUARDE_ANTES_DE_SAIR_5F0A13 = "Salvamento pendente. Aguarde antes de sair.",
	SANTUARIO_D50F02 = "Santuário",
	SANTUARIO_EM_CRESCIMENTO_8E370B = "Santuário em crescimento",
	SELECIONAR_4EDC0B = "Selecionar",
	SELO_INVALIDO_51B2D9 = "Selo inválido",
	SELVAGEM_959EBB = "SELVAGEM",
	SEM_ENCONTROS_GERAIS_NESTA_REGIAO_ED1AF7 = "Sem encontros gerais nesta região",
	SEM_OVOS_GERAIS_NESTA_REGIAO_623A41 = "Sem ovos gerais nesta região",
	SERPENTE_DELGADA_QUE_GUIA_OS_PASSOS_DE_VIAJANTES_F40CC1 = "Serpente delgada que guia os passos de viajantes com sua pequena lanterna.",
	SERPENTE_DE_CAUDA_LONGA_CERCADA_POR_PEQUENAS_FOR_F1F994 = "Serpente de cauda longa cercada por pequenas formações de nuvem.",
	SERPENTE_DE_NADADEIRAS_ALTAS_QUE_REPOUSA_ENTRE_C_F61F34 = "Serpente de nadadeiras altas que repousa entre corais cristalinos.",
	SERPENTE_DE_NUVENS_996D8C = "Serpente de nuvens",
	SERPENTE_DE_VAPOR_C3B66D = "Serpente de vapor",
	SERPENTE_HIBRIDA_QUE_TRANSFORMA_O_ENCONTRO_DE_FO_337A4D = "Serpente híbrida que transforma o encontro de fogo e água em vapor morno.",
	SERPENTE_MARINHA_BF701F = "Serpente marinha",
	SESSAO_DE_DADOS_ENCERRADA_RECONECTE_PARA_PROTEGE_C94A14 = "Sessão de dados encerrada. Reconecte para proteger seu progresso.",
	SEU_COMPANHEIRO_GOSTOU_DO_CARINHO_C1382F = "Seu companheiro gostou do carinho!",
	SEU_SANTUARIO_9_POSICOES_SELECIONE_UMA_POSICAO_E_400064 = "Seu santuário • 9 posições\nSelecione uma posição e construa ou mova um habitat.",
	SOCIAVEL_3658F4 = "Sociável",
	SOMBRA_94B135 = "Sombra",
	GELO_4A90D9 = "Gelo",
	ELETRICO_FFD600 = "Elétrico",
	LUZ_FFF9C4 = "Luz",
	SOM_OFF_D3D9A2 = "Som OFF",
	SOM_ON_ACD88F = "Som ON",
	SOPRO_ANCESTRAL_8CD748 = "Sopro ancestral",
	SUAS_FERAS_DESCANSAM_6D6F29 = "Suas feras descansam: ",
	SUA_EQUIPE_C6DEB4 = "SUA EQUIPE",
	SUA_FERA_EVOLUIU_0ACEF1 = "SUA FERA EVOLUIU!",
	SUBIU_PARA_O_NIVEL_0AB637 = "Subiu para o nível ",
	S_NV_D_S_S_10A567 = "%s Nv.%d [%s %s]",
	TEMPESTALIA_27599D = "Tempestália",
	TENHA_3_ILHAS_FDA36F = "Tenha 3 ilhas",
	TENHA_TODAS_AS_ILHAS_D2BB30 = "Tenha todas as ilhas",
	TERRA_16D3AE = "Terra",
	TIMIDO_3CCD3C = "Tímido",
	TIPO_DE_SELO_INVALIDO_9B6D96 = "Tipo de selo inválido",
	TIRAR_F409BD = "Tirar",
	TRAMA_ADERENTE_FB264B = "Trama aderente",
	TRANSFIRA_AS_FERAS_ANTES_DE_REMOVER_O_HABITAT_C629D5 = "Transfira as feras antes de remover o habitat",
	TREINE_E_TENTE_DE_NOVO_74F9F0 = "). Treine e tente de novo!",
	TREINE_E_TENTE_DE_NOVO_F77824 = ". Treine e tente de novo!",
	TREINO_172166 = "Treino",
	TROFEUS_F30057 = "Troféus: ",
	TUTORIAL_CONCLUIDO_EE21ED = "Tutorial concluído!",
	UMA_AVE_DE_PENAS_ESCURAS_COM_UMA_CRISTA_QUE_PARE_4E5191 = "Uma ave de penas escuras com uma crista que parece guardar as últimas brasas.",
	UMA_FERA_NASCEU_A8EB6A = "UMA FERA NASCEU!",
	UMA_INSCRICAO_MENCIONA_DOIS_SINAIS_ENTRE_AREIA_E_4D4A59 = "Uma inscrição menciona dois sinais entre areia e um no alto.",
	UMA_PEQUENA_GEODA_VIVA_COM_UM_NUCLEO_QUE_PULSA_S_8A27ED = "Uma pequena geoda viva com um núcleo que pulsa sob sua carapaça de pedra.",
	UM_GOLEM_MONUMENTAL_QUE_CARREGA_MARCAS_LUMINOSAS_240E80 = "Um golem monumental que carrega marcas luminosas entre blocos de arenito.",
	UM_GUARDIAO_DE_PEQUENAS_PEROLAS_COM_CARAPACA_LAR_B53600 = "Um guardião de pequenas pérolas com carapaça larga e pinças arredondadas.",
	UM_LAR_PARA_SUAS_FERAS_224C2D = "Um lar para suas feras",
	UM_NUCLEO_DE_CARVAO_VIVO_PROTEGIDO_POR_PEQUENAS__769F23 = "Um núcleo de carvão vivo protegido por pequenas placas mornas.",
	UM_PEQUENO_BROTO_AMBULANTE_QUE_ABRE_SUAS_FOLHAS__24DCAD = "Um pequeno broto ambulante que abre suas folhas ao encontrar companhia.",
	VEJA_MISSOES_PARA_RECEBER_A_RECOMPENSA_8B5929 = "). Veja Missões para receber a recompensa.",
	VENCA_10_BATALHAS_CCE0E5 = "Vença 10 batalhas",
	VENCA_30_BATALHAS_AC517C = "Vença 30 batalhas",
	VENCA_UMA_BATALHA_A43940 = "Vença uma batalha",
	VENCA_UMA_BATALHA_CONTRA_UMA_FERA_SELVAGEM_C78BC2 = "Vença uma batalha contra uma fera selvagem.",
	VENCA_UM_DUELO_ONLINE_2F97C7 = "Vença um duelo online",
	VESTIGIOS_513BA0 = "Vestígios",
	VESTIGIOS_DA_CIVILIZACAO_B8949B = "Vestígios da civilização",
	VESTIGIOS_DE_UMA_ESPECIE_DESCONHECIDA_B8DB43 = "???\nVestígios de uma espécie desconhecida.",
	VESTIGIO_A22F5D = "Vestígio",
	VIAJAR_AF3BD5 = "Viajar",
	VINCULO_80DA3F = "  •  Vínculo ",
	VISITAR_MEU_SANTUARIO_A636DA = "Visitar meu santuário",
	VITORIA_CONTINUAR_52F863 = "Vitória! Continuar",
	VITORIA_CONTRA_F35782 = "Vitória contra ",
	VITORIA_SOBRE_36EFE4 = "Vitória sobre ",
	VOCE_3A71A4 = " (você: ",
	VOCE_JA_CONCLUIU_ESTE_DESAFIO_DE_GUARDIAO_12DC0F = "Você já concluiu este desafio de guardião.",
	VOLTAR_A_AVENTURA_D7DC5A = "Voltar à aventura",
	VOLTAR_A_EXPLORACAO_8F4A4A = "Voltar à exploração",
	VOLTE_AMANHA_E195DE = "Volte amanhã!",
	VULCOES_E_RIOS_DE_MAGMA_300BD6 = "Vulcões e rios de magma.",
	CITADELA_DE_GELO_E_AURORA_BOREAL_1A3B4C = "Cidadela de gelo, caverna dos cristais e aurora boreal.",
	TORRE_DO_RELAMPAGO_E_TEMPORTE_PERPETUA_2B4D6E = "Torre do relâmpago, núcleo energético e tempestade perpétua.",
	OBSERVATORIO_COSMICO_E_ESTRELAS_VIVAS_3C5E7F = "Observatório cósmico, jardim das estrelas e constelações vivas."
	XP_DA_FERA_1A37A2 = " XP da fera.",
	XP_E_5EFA95 = " XP e +",
}
S.Text.ABISSAURO_04225F = "Abissauro"
S.Text.ACAO_DESCONHECIDA_9BB0DF = "Ação desconhecida."
S.Text.AERONIMBO_2E256F = "Aeronimbo"
S.Text.ARACNOFLORA_43AC5A = "Aracnoflora"
S.Text.ATAQUE_4EE034 = " • Ataque "
S.Text.A_FERA_CAUSOU_B1492B = "A fera causou "
S.Text.A_FERA_FUGIU_5FDD82 = "A fera fugiu."
S.Text.A_FERA_SE_ASSUSTOU_E_FUGIU_FF44C5 = "A fera se assustou e fugiu."
S.Text.BIOMA_94C907 = "Bioma: "
S.Text.BOLHINHO_2BE987 = "Bolhinho"
S.Text.BROTINHO_57925C = "Brotinho"
S.Text.CAPTURA_9BC665 = "Captura "
S.Text.CAUDALUME_26609C = "Caudalume"
S.Text.CHOCADEIRA_D1AF5D = "Chocadeira: "
S.Text.CINZAVENTO_982DC1 = "Cinzavento"
S.Text.CINZELO_540AA2 = "Cinzelo"
S.Text.COLOSSODUNE_3B3CE0 = "Colossodune"
S.Text.CONSTRUIR_BB999C = "Construir: "
S.Text.CRIAR_BD03AE = "Criar • "
S.Text.CUSTO_805D21 = "Custo: "
S.Text.DE_DANO_04F138 = " de dano."
S.Text.DE_DANO_949A5C = " de dano"
S.Text.ELEMENTO_BB6BA8 = "Elemento: "
S.Text.ENTROU_EM_CAMPO_AC551A = " entrou em campo."
S.Text.EQUIPE_LIMITADA_A_TRES_FERAS_POR_ENCONTRO_31F83A = "Equipe limitada a três feras por encontro."
S.Text.ESCOLHA_UMA_FERA_SUA_699F8C = "Escolha uma fera sua."
S.Text.ESCORPIODRA_B79E74 = "Escorpiodra"
S.Text.ESFINGEOLITO_728F92 = "Esfingeolito"
S.Text.ESPECIE_DE_COMBATE_DESCONHECIDA_6A7E80 = "Espécie de combate desconhecida"
S.Text.ESSA_FERA_ESTA_EXAUSTA_89922B = "Essa fera está exausta."
S.Text.ESSA_FERA_JA_ESTA_EM_CAMPO_198AD6 = "Essa fera já está em campo."
S.Text.ESTE_DESAFIO_EXIGE_UMA_BATALHA_14581F = "Este desafio exige uma batalha."
S.Text.ESTE_ENCONTRO_TERMINOU_EC2596 = "Este encontro terminou."
S.Text.FALTAM_1A9B57 = " · faltam "
S.Text.FERAS_C56D89 = " feras"
S.Text.FRACO_988207 = " fraco"
S.Text.GEMAS_BEE5F6 = " gemas"
S.Text.GUARDIOES_NAO_PODEM_SER_CAPTURADOS_CA285E = "Guardiões não podem ser capturados."
S.Text.HABILIDADE_RECARREGANDO_5B6E68 = "Habilidade recarregando."
S.Text.INCUBANDO_75EABA = "Incubando: "
S.Text.INVENTARIO_CHEIO_NENHUM_SELO_FOI_GASTO_7FC7F9 = "Inventário cheio. Nenhum selo foi gasto."
S.Text.LODINHO_03ED97 = "Lodinho"
S.Text.MAGMARAU_66D92B = "Magmarau"
S.Text.MAGMATERRA_ACDB93 = "Magmaterra"
S.Text.MAIA_2FE34E = "Maia • "
S.Text.MARILISCO_BFD916 = "Marilisco"
S.Text.MELHORAR_5E30CA = "Melhorar • "
S.Text.MOVER_7D5F11 = "Mover → "
S.Text.NV_9D89AA = " • Nv."
S.Text.NV_AE0838 = "\nNv."
S.Text.NV_D_D_D_D_60CA2C = "Nv.%d  ● %d  ◆ %d  ◈ %d"
S.Text.OURO_028C29 = " ouro\n"
S.Text.OURO_6C9D60 = " ouro"
S.Text.O_ENCONTRO_TERMINOU_PELO_LIMITE_DE_TURNOS_28EB70 = "O encontro terminou pelo limite de turnos."
S.Text.O_SELO_SE_DESFEZ_A_FERA_RESISTIU_ECB4B5 = "O selo se desfez. A fera resistiu!"
S.Text.PENUGEM_D3A3F3 = "Penugem"
S.Text.PERIGO_DC2EAE = " · PERIGO +"
S.Text.PV_33D16B = " PV"
S.Text.QUALIDADE_BE9B02 = "Qualidade "
S.Text.RARIDADE_9F174D = "Raridade: "
S.Text.RECARREGANDO_C160E2 = " • recarregando"
S.Text.RENASCIMENTO_FUTURO_EE24AE = "Renascimento (futuro)"
S.Text.REPOUSO_056AEB = "Repouso · "
S.Text.SELECIONE_UMA_FERA_DISPONIVEL_94CE80 = "Selecione uma fera disponível."
S.Text.SELOS_D7B365 = "%  •  Selos "
S.Text.SELO_0B67C2 = "Selo: "
S.Text.SELO_8CBE0B = "Selo "
S.Text.SELVAGENS_492B94 = ")\nSelvagens "
S.Text.SEM_SELOS_CRIE_MAIS_NO_MERCADO_D1B215 = "Sem selos. Crie mais no Mercado."
S.Text.SEU_COMPANHEIRO_ESTA_EXAUSTO_TROQUE_DE_FERA_OU_F_43D62C =
	"Seu companheiro está exausto. Troque de fera ou fuja."
S.Text.SUA_EQUIPE_ESTA_EXAUSTA_RETORNE_PARA_SE_PREPARAR_65F135 = "Sua equipe está exausta. Retorne para se preparar."
S.Text.SUA_FERA_CAUSOU_9F1A6C = "Sua fera causou "
S.Text.SUA_FERA_RECUPEROU_O_FOLEGO_E_SE_PROTEGEU_08D205 = "Sua fera recuperou o fôlego e se protegeu."
S.Text.S_ACELERAR_8DABB8 = "s\nAcelerar: "
S.Text.S_D_D_A1F15E = "%s (%d/%d)"
S.Text.TROVORAPTOR_3E8543 = "Trovoraptor"
S.Text.VAGALUMORTE_40C1CE = "Vagalumorte"
S.Text.VANTAGEM_ELEMENTAL_C12EBC = " — vantagem elemental!"
S.Text.VAPORINO_6940A2 = "Vaporino"
S.Text.VENTANIL_D7000E = "Ventanil"
S.Text.VIDA_41EF99 = "Vida "
S.Text.VINCULO_ESTABELECIDO_21A0FC = "Vínculo estabelecido!"
S.Text.VITORIA_FERAS_EXAUSTAS_NAO_PODEM_SER_CAPTURADAS_08B05D = "Vitória! Feras exaustas não podem ser capturadas."
S.Text.VOCE_SE_APROXIMOU_COM_CUIDADO_VINCULO_555F67 = "Você se aproximou com cuidado. Vínculo "
S.Text.VOCE_VOLTOU_A_EXPLORACAO_29EB17 = "Você voltou à exploração."
S.Text.VULCANODRAGO_CEB8E4 = "Vulcanodrago"
return S

end)()
local M_Creatures=(function()
--!nonstrict
local Text = M_Strings.Text
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

end)()
local M_Elements=(function()
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
end)()
local M_Skills=(function()
--!strict
local Text = M_Strings.Text
return {
	Blob = { name = Text.PULSO_VITAL_629F87, power = 1.1, effect = "heal" },
	Beast = { name = Text.INVESTIDA_FEROZ_70FE97, power = 1.65, effect = "none" },
	Bird = { name = Text.RAJADA_EVASIVA_6F3310, power = 1.25, effect = "evade" },
	Dragon = { name = Text.SOPRO_ANCESTRAL_8CD748, power = 1.7, effect = "none" },
	Serpent = { name = Text.MARE_DEBILITANTE_389076, power = 1.15, effect = "weaken" },
	Insect = { name = Text.TRAMA_ADERENTE_FB264B, power = 1.15, effect = "slow" },
}

end)()
local M_CaptureRules=(function()
--!nonstrict
local Text = M_Strings.Text
local R = { SealPrice = 25, InitialSeals = 5, MaxPerIsland = 2, RespawnSeconds = 25, MaxDistance = 13 }
R.Seals = {
	Basic = { name = Text.BASICO_303CE5, multiplier = 1, cost = 25, level = 1 },
	Reinforced = { name = Text.REFORCADO_A930AC, multiplier = 1.12, cost = 60, level = 8 },
	Elemental = {
		name = Text.ELEMENTAL_5871BB,
		multiplier = 1.25,
		cost = 85,
		level = 16,
		material = Text.NATUREZA_FB1ED9,
		amount = 1,
	},
	Rare = {
		name = Text.RARO_851816,
		multiplier = 1.4,
		cost = 160,
		level = 24,
		material = Text.TERRA_16D3AE,
		amount = 1,
	},
	Ancient = {
		name = Text.ANCESTRAL_24E41A,
		multiplier = 1.55,
		cost = 300,
		level = 40,
		material = Text.SOMBRA_94B135,
		amount = 2,
	},
}
R.SealOrder = { "Basic", "Reinforced", Text.ELEMENTAL_5871BB, "Rare", "Ancient" }
function R.multiplier(kind, rarity, activeElement, foeElement, bond)
	if kind == Text.ELEMENTAL_5871BB then
		return activeElement == foeElement and 1.35 or 1.1
	end
	if kind == "Rare" then
		return rarity >= 3 and 1.4 or 1.15
	end
	if kind == "Ancient" then
		return bond >= 2 and 1.55 or 1.4
	end
	return (R.Seals[kind] or R.Seals.Basic).multiplier
end
local base = { 0.8, 0.5, 0.28, 0.12 }
function R.chance(rarity, level)
	return math.clamp((base[rarity] or 0.1) - math.max(0, level - 1) * 0.005, 0.05, 0.9)
end
-- Hábitos e peso compartilhados para inspeção; somente servidor sorteia.
function R.species(def)
	return {
		island = def.island,
		weight = 1 / (def.rar * def.rar),
		behavior = def.shape == "Bird" and "voador" or def.shape == "Serpent" and "reservado" or "curioso",
		max = def.rar == 4 and 1 or 2,
	}
end
return R

end)()
local M_CaptureMath=(function()
--!nonstrict
local Seals = M_CaptureRules
local C = M_Creatures
local M = {}
function M.chance(state)
	if state.capturable == false then
		return 0
	end
	local foe = state.foe
	local def = C.ById[foe.id]
	local pet = state.active and state.party[state.active]
	local seal = Seals.multiplier(state.sealKind or "Basic", def.rar, pet and pet.el, foe.el, state.bond)
	local health = math.clamp(foe.hp / foe.maxHp, 0, 1)
	if state.isLegendary then
		-- Um selo de categoria superior nunca perde para um inferior neste encontro especial.
		for _, kind in Seals.SealOrder do
			seal = math.max(seal, Seals.multiplier(kind, def.rar, pet and pet.el, foe.el, state.bond))
			if kind == (state.sealKind or "Basic") then
				break
			end
		end
		-- 4% sem preparo, ~10% médio, ~21% ótimo; fórmula multiplicativa.
		return math.clamp(
			(state.captureBase or 0.04) * seal * (1 + 1.8 * (1 - health)) * (1 + state.bond * 0.09),
			0.01,
			0.35
		)
	end
	return math.clamp(Seals.chance(def.rar, foe.lv) * seal + (1 - health) * 0.45 + state.bond * 0.08, 0.05, 0.94)
end
return M

end)()
local M_Moves=(function()
--!strict
-- Moves.luau - All moves: power, accuracy, PP, effects, animation refs
-- Pure data module, no services or instances

local Moves = {}

export type MoveEffect = {
	type: "status" | "stat" | "heal" | "drain" | "multiHit" | "recharge" | "flinch" | "critBoost" | "protect",
	status: string?,          -- For status effects: "burn", "freeze", "paralyze", "poison", "sleep", "confuse", "fear", "curse", "bless"
	duration: number?,        -- Duration in turns
	chance: number?,          -- 0-1 probability
	stat: string?,            -- For stat changes: "atk", "def", "speed", "spAtk", "spDef", "accuracy", "evasion"
	stages: number?,          -- Number of stages (-6 to +6)
	amount: number?,          -- For heal/drain: ratio of max HP
	drainRatio: number?,      -- For drain moves: ratio of damage healed
	turns: number?,           -- For recharge: turns to wait
}

export type MoveData = {
	id: string,
	name: string,
	element: string,
	category: "physical" | "special" | "status",
	power: number,            -- Base power (0 for status moves)
	accuracy: number,         -- 0-1 (1 = never misses)
	pp: number,               -- Base PP
	priority: number,         -- Move priority (higher = acts first)
	effect: MoveEffect?,      -- Additional effect
	animation: string,        -- Animation reference
	description: string,
	target: "enemy" | "self" | "allies" | "all",
	flags: { string },        -- "contact", "sound", "punch", "bite", "powder", "pulse", "ball", "dance", etc.
}

-- Shape-based signature moves (from Skills)
local ShapeMoves = {
	Blob = { id = "vital_pulse", name = "Pulso Vital", element = "Natureza", power = 60, effect = { type = "heal", amount = 0.125 } },
	Beast = { id = "fierce_charge", name = "Investida Feroz", element = "Terra", power = 90 },
	Bird = { id = "evasive_gust", name = "Rajada Evasiva", element = "Ar", power = 70, effect = { type = "stat", stat = "evasion", stages = 1, chance = 1 } },
	Dragon = { id = "ancestral_breath", name = "Sopro Ancestral", element = "Fogo", power = 100 },
	Serpent = { id = "weakening_coil", name = "Maré Debilitante", element = "Água", power = 65, effect = { type = "stat", stat = "atk", stages = -1, chance = 0.3 } },
	Insect = { id = "sticky_web", name = "Trama Aderente", element = "Natureza", power = 65, effect = { type = "stat", stat = "speed", stages = -1, chance = 0.3 } },
	Quadruped = { id = "tackle", name = "Investida", element = "Normal", power = 50 },
	Winged = { id = "wing_attack", name = "Ataque de Asa", element = "Ar", power = 60 },
	Aquatic = { id = "water_gun", name = "Jato d'Água", element = "Água", power = 45 },
	Arthropod = { id = "bug_bite", name = "Picada", element = "Natureza", power = 55 },
	Mineral = { id = "rock_throw", name = "Lançamento de Rocha", element = "Terra", power = 50 },
	Spectral = { id = "shadow_sneak", name = "Golpe Sombrio", element = "Sombra", power = 50, priority = 1 },
	Vegetal = { id = "vine_whip", name = "Chicote de Vinha", element = "Natureza", power = 50 },
	Draconic = { id = "dragon_rage", name = "Fúria Draconica", element = "Fogo", power = 80 },
}

-- Universal moves available to many creatures
local UniversalMoves: { [string]: MoveData } = {
	-- Physical moves
	tackle = {
		id = "tackle", name = "Investida", element = "Normal", category = "physical",
		power = 40, accuracy = 1, pp = 35, priority = 0,
		animation = "tackle", description = "Uma investida física básica.", target = "enemy", flags = { "contact" }
	},
	scratch = {
		id = "scratch", name = "Arranhão", element = "Normal", category = "physical",
		power = 40, accuracy = 1, pp = 35, priority = 0,
		animation = "scratch", description = "Arranha o inimigo com garras afiadas.", target = "enemy", flags = { "contact" }
	},
	quick_attack = {
		id = "quick_attack", name = "Ataque Rápido", element = "Normal", category = "physical",
		power = 40, accuracy = 1, pp = 30, priority = 1,
		animation = "quick_attack", description = "Ataca primeiro. Sempre acerta.", target = "enemy", flags = { "contact" }
	},
	-- Fire moves
	ember = {
		id = "ember", name = "Brasa", element = "Fogo", category = "special",
		power = 40, accuracy = 1, pp = 25, priority = 0,
		effect = { type = "status", status = "burn", chance = 0.1, duration = 3 },
		animation = "ember", description = "Pequena chance de queimar.", target = "enemy", flags = {}
	},
	flamethrower = {
		id = "flamethrower", name = "Lança-Chamas", element = "Fogo", category = "special",
		power = 90, accuracy = 1, pp = 15, priority = 0,
		effect = { type = "status", status = "burn", chance = 0.1, duration = 3 },
		animation = "flamethrower", description = "Chamas intensas que podem queimar.", target = "enemy", flags = {}
	},
	fire_blast = {
		id = "fire_blast", name = "Explosão de Fogo", element = "Fogo", category = "special",
		power = 110, accuracy = 0.85, pp = 5, priority = 0,
		effect = { type = "status", status = "burn", chance = 0.1, duration = 3 },
		animation = "fire_blast", description = "Poderoso, mas impreciso.", target = "enemy", flags = {}
	},
	flare_blitz = {
		id = "flare_blitz", name = "Ímpeto de Chamas", element = "Fogo", category = "physical",
		power = 120, accuracy = 1, pp = 15, priority = 0,
		effect = { type = "status", status = "burn", chance = 0.1, duration = 3 },
		animation = "flare_blitz", description = "Usuário recebe dano de recuo.", target = "enemy", flags = { "contact", "recoil" }
	},
	-- Water moves
	water_gun = {
		id = "water_gun", name = "Jato d'Água", element = "Água", category = "special",
		power = 40, accuracy = 1, pp = 25, priority = 0,
		animation = "water_gun", description = "Jato de água pressurizada.", target = "enemy", flags = {}
	},
	bubble = {
		id = "bubble", name = "Bolha", element = "Água", category = "special",
		power = 40, accuracy = 1, pp = 30, priority = 0,
		effect = { type = "stat", stat = "speed", stages = -1, chance = 0.1 },
		animation = "bubble", description = "Pode reduzir velocidade.", target = "enemy", flags = {}
	},
	hydro_pump = {
		id = "hydro_pump", name = "Hidro Bomba", element = "Água", category = "special",
		power = 110, accuracy = 0.8, pp = 5, priority = 0,
		animation = "hydro_pump", description = "Poderoso, mas impreciso.", target = "enemy", flags = {}
	},
	surf = {
		id = "surf", name = "Surfar", element = "Água", category = "special",
		power = 90, accuracy = 1, pp = 15, priority = 0,
		animation = "surf", description = "Onda massiva atinge o alvo.", target = "enemy", flags = {}
	},
	aquajet = {
		id = "aquajet", name = "Jato Aquático", element = "Água", category = "physical",
		power = 40, accuracy = 1, pp = 20, priority = 1,
		animation = "aquajet", description = "Ataca primeiro.", target = "enemy", flags = { "contact" }
	},
	-- Nature/Grass moves
	vine_whip = {
		id = "vine_whip", name = "Chicote de Vinha", element = "Natureza", category = "physical",
		power = 45, accuracy = 1, pp = 25, priority = 0,
		animation = "vine_whip", description = "Chicoteia com vinhas.", target = "enemy", flags = { "contact" }
	},
	razor_leaf = {
		id = "razor_leaf", name = "Folha Navalha", element = "Natureza", category = "special",
		power = 55, accuracy = 0.95, pp = 25, priority = 0,
		animation = "razor_leaf", description = "Alta taxa de crítico.", target = "enemy", flags = {}
	},
	seed_bomb = {
		id = "seed_bomb", name = "Bomba de Sementes", element = "Natureza", category = "physical",
		power = 80, accuracy = 1, pp = 15, priority = 0,
		animation = "seed_bomb", description = "Explosão de sementes duras.", target = "enemy", flags = { "bullet" }
	},
	petal_dance = {
		id = "petal_dance", name = "Dança de Pétalas", element = "Natureza", category = "special",
		power = 120, accuracy = 1, pp = 10, priority = 0,
		effect = { type = "recharge", turns = 1 },
		animation = "petal_dance", description = "Ataca por 2-3 turnos, então confunde.", target = "enemy", flags = {}
	},
	-- Earth/Ground moves
	rock_throw = {
		id = "rock_throw", name = "Lançamento de Rocha", element = "Terra", category = "physical",
		power = 50, accuracy = 0.9, pp = 15, priority = 0,
		animation = "rock_throw", description = "Arremessa pedras.", target = "enemy", flags = {}
	},
	mud_shot = {
		id = "mud_shot", name = "Tiro de Lama", element = "Terra", category = "special",
		power = 55, accuracy = 0.95, pp = 15, priority = 0,
		effect = { type = "stat", stat = "speed", stages = -1, chance = 1 },
		animation = "mud_shot", description = "Sempre reduz velocidade.", target = "enemy", flags = {}
	},
	earthquake = {
		id = "earthquake", name = "Terremoto", element = "Terra", category = "physical",
		power = 100, accuracy = 1, pp = 10, priority = 0,
		animation = "earthquake", description = "Atinge todos adjacentes.", target = "all", flags = {}
	},
	drill_run = {
		id = "drill_run", name = "Perfuradora", element = "Terra", category = "physical",
		power = 80, accuracy = 0.95, pp = 10, priority = 0,
		animation = "drill_run", description = "Alta taxa de crítico.", target = "enemy", flags = { "contact" }
	},
	-- Air/Flying moves
	wing_attack = {
		id = "wing_attack", name = "Ataque de Asa", element = "Ar", category = "physical",
		power = 60, accuracy = 1, pp = 35, priority = 0,
		animation = "wing_attack", description = "Bate as asas com força.", target = "enemy", flags = { "contact" }
	},
	gust = {
		id = "gust", name = "Rajada", element = "Ar", category = "special",
		power = 40, accuracy = 1, pp = 35, priority = 0,
		animation = "gust", description = "Vento forte.", target = "enemy", flags = {}
	},
	air_slash = {
		id = "air_slash", name = "Corte de Ar", element = "Ar", category = "special",
		power = 75, accuracy = 0.95, pp = 15, priority = 0,
		effect = { type = "flinch", chance = 0.3 },
		animation = "air_slash", description = "Pode fazer o alvo recuar.", target = "enemy", flags = {}
	},
	hurricane = {
		id = "hurricane", name = "Furacão", element = "Ar", category = "special",
		power = 110, accuracy = 0.7, pp = 10, priority = 0,
		effect = { type = "status", status = "confuse", chance = 0.3, duration = 2 },
		animation = "hurricane", description = "Pode confundir.", target = "enemy", flags = {}
	},
	-- Shadow/Dark moves
	shadow_sneak = {
		id = "shadow_sneak", name = "Golpe Sombrio", element = "Sombra", category = "physical",
		power = 40, accuracy = 1, pp = 30, priority = 1,
		animation = "shadow_sneak", description = "Ataca primeiro.", target = "enemy", flags = { "contact" }
	},
	dark_pulse = {
		id = "dark_pulse", name = "Pulso Sombrio", element = "Sombra", category = "special",
		power = 80, accuracy = 1, pp = 15, priority = 0,
		effect = { type = "flinch", chance = 0.2 },
		animation = "dark_pulse", description = "Onda de energia sombria.", target = "enemy", flags = {}
	},
	night_slash = {
		id = "night_slash", name = "Golpe Noturno", element = "Sombra", category = "physical",
		power = 70, accuracy = 1, pp = 15, priority = 0,
		animation = "night_slash", description = "Alta taxa de crítico.", target = "enemy", flags = { "contact" }
	},
	-- Ice moves
	ice_shard = {
		id = "ice_shard", name = "Estilhaço de Gelo", element = "Gelo", category = "physical",
		power = 40, accuracy = 1, pp = 30, priority = 1,
		animation = "ice_shard", description = "Ataca primeiro.", target = "enemy", flags = { "contact" }
	},
	ice_beam = {
		id = "ice_beam", name = "Raio de Gelo", element = "Gelo", category = "special",
		power = 90, accuracy = 1, pp = 10, priority = 0,
		effect = { type = "status", status = "freeze", chance = 0.1, duration = 3 },
		animation = "ice_beam", description = "Pode congelar.", target = "enemy", flags = {}
	},
	blizzard = {
		id = "blizzard", name = "Nevasca", element = "Gelo", category = "special",
		power = 110, accuracy = 0.7, pp = 5, priority = 0,
		effect = { type = "status", status = "freeze", chance = 0.1, duration = 3 },
		animation = "blizzard", description = "Pode congelar. Impreciso.", target = "enemy", flags = {}
	},
	-- Electric moves
	thunder_shock = {
		id = "thunder_shock", name = "Choque do Trovão", element = "Elétrico", category = "special",
		power = 40, accuracy = 1, pp = 30, priority = 0,
		effect = { type = "status", status = "paralyze", chance = 0.1, duration = 3 },
		animation = "thunder_shock", description = "Pode paralisar.", target = "enemy", flags = {}
	},
	thunderbolt = {
		id = "thunderbolt", name = "Raio", element = "Elétrico", category = "special",
		power = 90, accuracy = 1, pp = 15, priority = 0,
		effect = { type = "status", status = "paralyze", chance = 0.1, duration = 3 },
		animation = "thunderbolt", description = "Pode paralisar.", target = "enemy", flags = {}
	},
	thunder = {
		id = "thunder", name = "Trovão", element = "Elétrico", category = "special",
		power = 110, accuracy = 0.7, pp = 10, priority = 0,
		effect = { type = "status", status = "paralyze", chance = 0.3, duration = 3 },
		animation = "thunder", description = "Pode paralisar. Impreciso.", target = "enemy", flags = {}
	},
	volt_tackle = {
		id = "volt_tackle", name = "Investida Elétrica", element = "Elétrico", category = "physical",
		power = 120, accuracy = 1, pp = 15, priority = 0,
		effect = { type = "status", status = "paralyze", chance = 0.1, duration = 3 },
		animation = "volt_tackle", description = "Recuo forte. Pode paralisar.", target = "enemy", flags = { "contact", "recoil" }
	},
	-- Light moves
	flash = {
		id = "flash", name = "Flash", element = "Luz", category = "status",
		power = 0, accuracy = 1, pp = 20, priority = 0,
		effect = { type = "stat", stat = "accuracy", stages = -1, chance = 1 },
		animation = "flash", description = "Reduz precisão do inimigo.", target = "enemy", flags = {}
	},
	dazzling_gleam = {
		id = "dazzling_gleam", name = "Brilho Ofuscante", element = "Luz", category = "special",
		power = 80, accuracy = 1, pp = 10, priority = 0,
		animation = "dazzling_gleam", description = "Luz mágica atinge o alvo.", target = "enemy", flags = {}
	},
	morning_sun = {
		id = "morning_sun", name = "Sol da Manhã", element = "Luz", category = "status",
		power = 0, accuracy = 1, pp = 5, priority = 0,
		effect = { type = "heal", amount = 0.5 },
		animation = "morning_sun", description = "Recupera 50% do HP máximo.", target = "self", flags = {}
	},
	-- Metal/Steel moves
	metal_claw = {
		id = "metal_claw", name = "Garra Metálica", element = "Metal", category = "physical",
		power = 50, accuracy = 0.95, pp = 35, priority = 0,
		effect = { type = "stat", stat = "atk", stages = 1, chance = 0.1 },
		animation = "metal_claw", description = "Pode aumentar ataque.", target = "enemy", flags = { "contact" }
	},
	iron_head = {
		id = "iron_head", name = "Cabeçada de Ferro", element = "Metal", category = "physical",
		power = 80, accuracy = 1, pp = 15, priority = 0,
		effect = { type = "flinch", chance = 0.3 },
		animation = "iron_head", description = "Pode fazer recuar.", target = "enemy", flags = { "contact" }
	},
	flash_cannon = {
		id = "flash_cannon", name = "Canhão de Luz", element = "Metal", category = "special",
		power = 80, accuracy = 1, pp = 10, priority = 0,
		effect = { type = "stat", stat = "spDef", stages = -1, chance = 0.1 },
		animation = "flash_cannon", description = "Pode reduzir def. especial.", target = "enemy", flags = {}
	},
	-- Crystal moves
	power_gem = {
		id = "power_gem", name = "Joia de Poder", element = "Cristal", category = "special",
		power = 80, accuracy = 1, pp = 20, priority = 0,
		animation = "power_gem", description = "Dispara joias afiadas.", target = "enemy", flags = {}
	},
	diamond_storm = {
		id = "diamond_storm", name = "Tempestade de Diamantes", element = "Cristal", category = "physical",
		power = 100, accuracy = 0.95, pp = 5, priority = 0,
		effect = { type = "stat", stat = "def", stages = 2, chance = 0.5 },
		animation = "diamond_storm", description = "Pode aumentar defesa drasticamente.", target = "enemy", flags = {}
	},
	-- Arcane/Psychic moves
	confusion = {
		id = "confusion", name = "Confusão", element = "Arcano", category = "special",
		power = 50, accuracy = 1, pp = 25, priority = 0,
		effect = { type = "status", status = "confuse", chance = 0.1, duration = 2 },
		animation = "confusion", description = "Pode confundir.", target = "enemy", flags = {}
	},
	psychic = {
		id = "psychic", name = "Psíquico", element = "Arcano", category = "special",
		power = 90, accuracy = 1, pp = 10, priority = 0,
		effect = { type = "stat", stat = "spDef", stages = -1, chance = 0.1 },
		animation = "psychic", description = "Pode reduzir def. especial.", target = "enemy", flags = {}
	},
	future_sight = {
		id = "future_sight", name = "Previsão Futura", element = "Arcano", category = "special",
		power = 120, accuracy = 1, pp = 10, priority = 0,
		effect = { type = "recharge", turns = 2 },
		animation = "future_sight", description = "Acerta 2 turnos depois.", target = "enemy", flags = {}
	},
	-- Status moves
	growl = {
		id = "growl", name = "Rosnado", element = "Normal", category = "status",
		power = 0, accuracy = 1, pp = 40, priority = 0,
		effect = { type = "stat", stat = "atk", stages = -1, chance = 1 },
		animation = "growl", description = "Reduz ataque do inimigo.", target = "enemy", flags = { "sound" }
	},
	tail_whip = {
		id = "tail_whip", name = "Chicote de Cauda", element = "Normal", category = "status",
		power = 0, accuracy = 1, pp = 30, priority = 0,
		effect = { type = "stat", stat = "def", stages = -1, chance = 1 },
		animation = "tail_whip", description = "Reduz defesa do inimigo.", target = "enemy", flags = {}
	},
	harden = {
		id = "harden", name = "Endurecer", element = "Normal", category = "status",
		power = 0, accuracy = 1, pp = 30, priority = 0,
		effect = { type = "stat", stat = "def", stages = 1, chance = 1 },
		animation = "harden", description = "Aumenta própria defesa.", target = "self", flags = {}
	},
	recover = {
		id = "recover", name = "Recuperação", element = "Normal", category = "status",
		power = 0, accuracy = 1, pp = 10, priority = 0,
		effect = { type = "heal", amount = 0.5 },
		animation = "recover", description = "Recupera 50% do HP.", target = "self", flags = {}
	},
	protect = {
		id = "protect", name = "Proteção", element = "Normal", category = "status",
		power = 0, accuracy = 1, pp = 10, priority = 4,
		effect = { type = "protect" },
		animation = "protect", description = "Evita todos os efeitos do turno.", target = "self", flags = {}
	},
	rest = {
		id = "rest", name = "Descanso", element = "Normal", category = "status",
		power = 0, accuracy = 1, pp = 5, priority = 0,
		effect = { type = "heal", amount = 1, status = "sleep", duration = 2 },
		animation = "rest", description = "Cura tudo, mas dorme 2 turnos.", target = "self", flags = {}
	},
	calm_mind = {
		id = "calm_mind", name = "Mente Calma", element = "Arcano", category = "status",
		power = 0, accuracy = 1, pp = 20, priority = 0,
		effect = { type = "stat", stat = "spAtk", stages = 1, chance = 1 },
		animation = "calm_mind", description = "Aumenta atq. e def. especial.", target = "self", flags = {}
	},
	swords_dance = {
		id = "swords_dance", name = "Dança de Espadas", element = "Normal", category = "status",
		power = 0, accuracy = 1, pp = 20, priority = 0,
		effect = { type = "stat", stat = "atk", stages = 2, chance = 1 },
		animation = "swords_dance", description = "Aumenta ataque drasticamente.", target = "self", flags = { "dance" }
	},
	-- Signature moves for legendaries
	solar_flare = {
		id = "solar_flare", name = "Erupção Solar", element = "Fogo", category = "special",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "status", status = "burn", chance = 0.3, duration = 4 },
		animation = "solar_flare", description = "Chamas solares devastadoras.", target = "enemy", flags = {}
	},
	abyssal_depths = {
		id = "abyssal_depths", name = "Profundezas Abissais", element = "Água", category = "special",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "stat", stat = "spDef", stages = -2, chance = 0.3 },
		animation = "abyssal_depths", description = "Pressão das profundezas.", target = "enemy", flags = {}
	},
	primordial_force = {
		id = "primordial_force", name = "Força Primordial", element = "Natureza", category = "physical",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "heal", amount = 0.25, drainRatio = 0.5 },
		animation = "primordial_force", description = "Cura 25% do dano causado.", target = "enemy", flags = { "contact" }
	},
	tectonic_upheaval = {
		id = "tectonic_upheaval", name = "Reviravolta Tectônica", element = "Terra", category = "physical",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "stat", stat = "speed", stages = -1, chance = 1 },
		animation = "tectonic_upheaval", description = "Sempre reduz velocidade.", target = "all", flags = {}
	},
	celestial_winds = {
		id = "celestial_winds", name = "Ventos Celestiais", element = "Ar", category = "special",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "flinch", chance = 0.3 },
		animation = "celestial_winds", description = "Ventos divinos.", target = "enemy", flags = {}
	},
	shadow_realm = {
		id = "shadow_realm", name = "Reino das Sombras", element = "Sombra", category = "special",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "status", status = "fear", chance = 0.3, duration = 3 },
		animation = "shadow_realm", description = "Mergulha o alvo no medo.", target = "enemy", flags = {}
	},
	absolute_zero = {
		id = "absolute_zero", name = "Zero Absoluto", element = "Gelo", category = "special",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "status", status = "freeze", chance = 0.3, duration = 4 },
		animation = "absolute_zero", description = "Frio impossível.", target = "enemy", flags = {}
	},
	bolt_strike = {
		id = "bolt_strike", name = "Golpe do Raio", element = "Elétrico", category = "physical",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "status", status = "paralyze", chance = 0.3, duration = 4 },
		animation = "bolt_strike", description = "Raio concentrado.", target = "enemy", flags = { "contact" }
	},
	holy_nova = {
		id = "holy_nova", name = "Nova Sagrada", element = "Luz", category = "special",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "heal", amount = 0.25 },
		animation = "holy_nova", description = "Luz purificadora cura o usuário.", target = "enemy", flags = {}
	},
	metal_burst = {
		id = "metal_burst", name = "Explosão Metálica", element = "Metal", category = "physical",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "stat", stat = "def", stages = 2, chance = 0.5 },
		animation = "metal_burst", description = "Fragmentos metálicos.", target = "enemy", flags = {}
	},
	crystal_prison = {
		id = "crystal_prison", name = "Prisão de Cristal", element = "Cristal", category = "special",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "status", status = "confuse", chance = 0.3, duration = 3 },
		animation = "crystal_prison", description = "Prende em cristais.", target = "enemy", flags = {}
	},
	void_rend = {
		id = "void_rend", name = "Rasgo do Vazio", element = "Arcano", category = "special",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "stat", stat = "spDef", stages = -2, chance = 0.3 },
		animation = "void_rend", description = "Rasga a realidade.", target = "enemy", flags = {}
	},
}

-- Creature-specific move pools (learnsets)
local Learnsets: { [string]: { string } } = {}

-- Initialize learnsets based on creature data
local C = M_Creatures
local Elements = M_Elements

for id, def in C.ById do
	if def.acquisition == "special" then
		-- Legendary/mythical get signature + powerful moves
		Learnsets[id] = {}
	else
		-- Regular creatures get moves based on element and shape
		Learnsets[id] = {}
		local element = def.el
		local shape = def.shape

		-- Add shape signature move
		if ShapeMoves[shape] then
			table.insert(Learnsets[id], ShapeMoves[shape].id)
		end

		-- Add element-appropriate moves
		local elementMoves = {
			Fogo = { "ember", "flamethrower", "fire_blast", "flare_blitz" },
			Água = { "water_gun", "bubble", "hydro_pump", "surf", "aquajet" },
			Natureza = { "vine_whip", "razor_leaf", "seed_bomb", "petal_dance" },
			Terra = { "rock_throw", "mud_shot", "earthquake", "drill_run" },
			Ar = { "wing_attack", "gust", "air_slash", "hurricane" },
			Sombra = { "shadow_sneak", "dark_pulse", "night_slash" },
			Gelo = { "ice_shard", "ice_beam", "blizzard" },
			Elétrico = { "thunder_shock", "thunderbolt", "thunder", "volt_tackle" },
			Luz = { "flash", "dazzling_gleam", "morning_sun" },
			Metal = { "metal_claw", "iron_head", "flash_cannon" },
			Cristal = { "power_gem", "diamond_storm" },
			Arcano = { "confusion", "psychic", "future_sight", "calm_mind" },
		}

		local moves = elementMoves[element] or {}
		for _, moveId in ipairs(moves) do
			if UniversalMoves[moveId] then
				table.insert(Learnsets[id], moveId)
			end
		end

		-- Add some universal physical moves for variety
		if def.shape == "Beast" or def.shape == "Quadruped" or def.shape == "Draconic" then
			for _, moveId in ipairs({ "tackle", "scratch", "quick_attack" }) do
				if UniversalMoves[moveId] then table.insert(Learnsets[id], moveId) end
			end
		end
	end
end

-- Export functions
function Moves.getMove(speciesId: string, isSkill: boolean): MoveData?
	if isSkill and ShapeMoves[C.ById[speciesId] and C.ById[speciesId].shape or ""] then
		local shapeMove = ShapeMoves[C.ById[speciesId].shape]
		return UniversalMoves[shapeMove.id]
	end
	-- Return first available move for basic strike
	local learnset = Learnsets[speciesId] or {}
	for _, moveId in ipairs(learnset) do
		local move = UniversalMoves[moveId]
		if move and move.category ~= "status" then
			return move
		end
	end
	return UniversalMoves.tackle
end

function Moves.getLearnset(speciesId: string): { MoveData }
	local learnset = Learnsets[speciesId] or {}
	local result = {}
	for _, moveId in ipairs(learnset) do
		if UniversalMoves[moveId] then
			table.insert(result, UniversalMoves[moveId])
		end
	end
	return result
end

function Moves.getMoveById(moveId: string): MoveData?
	return UniversalMoves[moveId]
end

function Moves.getAllMoves(): { MoveData }
	local result = {}
	for _, move in UniversalMoves do
		table.insert(result, move)
	end
	table.sort(result, function(a, b) return a.name < b.name end)
	return result
end

function Moves.getMovesByElement(element: string): { MoveData }
	local result = {}
	for _, move in UniversalMoves do
		if move.element == element then
			table.insert(result, move)
		end
	end
	return result
end

function Moves.getMovesByCategory(category: string): { MoveData }
	local result = {}
	for _, move in UniversalMoves do
		if move.category == category then
			table.insert(result, move)
		end
	end
	return result
end

-- Animation reference mapping
Moves.Animations = {
	tackle = "rbxassetid://anim_tackle",
	scratch = "rbxassetid://anim_scratch",
	quick_attack = "rbxassetid://anim_quick_attack",
	ember = "rbxassetid://anim_ember",
	flamethrower = "rbxassetid://anim_flamethrower",
	fire_blast = "rbxassetid://anim_fire_blast",
	flare_blitz = "rbxassetid://anim_flare_blitz",
	water_gun = "rbxassetid://anim_water_gun",
	bubble = "rbxassetid://anim_bubble",
	hydro_pump = "rbxassetid://anim_hydro_pump",
	surf = "rbxassetid://anim_surf",
	aquajet = "rbxassetid://anim_aquajet",
	vine_whip = "rbxassetid://anim_vine_whip",
	razor_leaf = "rbxassetid://anim_razor_leaf",
	seed_bomb = "rbxassetid://anim_seed_bomb",
	petal_dance = "rbxassetid://anim_petal_dance",
	rock_throw = "rbxassetid://anim_rock_throw",
	mud_shot = "rbxassetid://anim_mud_shot",
	earthquake = "rbxassetid://anim_earthquake",
	drill_run = "rbxassetid://anim_drill_run",
	wing_attack = "rbxassetid://anim_wing_attack",
	gust = "rbxassetid://anim_gust",
	air_slash = "rbxassetid://anim_air_slash",
	hurricane = "rbxassetid://anim_hurricane",
	shadow_sneak = "rbxassetid://anim_shadow_sneak",
	dark_pulse = "rbxassetid://anim_dark_pulse",
	night_slash = "rbxassetid://anim_night_slash",
	ice_shard = "rbxassetid://anim_ice_shard",
	ice_beam = "rbxassetid://anim_ice_beam",
	blizzard = "rbxassetid://anim_blizzard",
	thunder_shock = "rbxassetid://anim_thunder_shock",
	thunderbolt = "rbxassetid://anim_thunderbolt",
	thunder = "rbxassetid://anim_thunder",
	volt_tackle = "rbxassetid://anim_volt_tackle",
	flash = "rbxassetid://anim_flash",
	dazzling_gleam = "rbxassetid://anim_dazzling_gleam",
	morning_sun = "rbxassetid://anim_morning_sun",
	metal_claw = "rbxassetid://anim_metal_claw",
	iron_head = "rbxassetid://anim_iron_head",
	flash_cannon = "rbxassetid://anim_flash_cannon",
	power_gem = "rbxassetid://anim_power_gem",
	diamond_storm = "rbxassetid://anim_diamond_storm",
	confusion = "rbxassetid://anim_confusion",
	psychic = "rbxassetid://anim_psychic",
	future_sight = "rbxassetid://anim_future_sight",
	growl = "rbxassetid://anim_growl",
	tail_whip = "rbxassetid://anim_tail_whip",
	harden = "rbxassetid://anim_harden",
	recover = "rbxassetid://anim_recover",
	protect = "rbxassetid://anim_protect",
	rest = "rbxassetid://anim_rest",
	calm_mind = "rbxassetid://anim_calm_mind",
	swords_dance = "rbxassetid://anim_swords_dance",
	solar_flare = "rbxassetid://anim_solar_flare",
	abyssal_depths = "rbxassetid://anim_abyssal_depths",
	primordial_force = "rbxassetid://anim_primordial_force",
	tectonic_upheaval = "rbxassetid://anim_tectonic_upheaval",
	celestial_winds = "rbxassetid://anim_celestial_winds",
	shadow_realm = "rbxassetid://anim_shadow_realm",
	absolute_zero = "rbxassetid://anim_absolute_zero",
	bolt_strike = "rbxassetid://anim_bolt_strike",
	holy_nova = "rbxassetid://anim_holy_nova",
	metal_burst = "rbxassetid://anim_metal_burst",
	crystal_prison = "rbxassetid://anim_crystal_prison",
	void_rend = "rbxassetid://anim_void_rend",
	vital_pulse = "rbxassetid://anim_vital_pulse",
	fierce_charge = "rbxassetid://anim_fierce_charge",
	evasive_gust = "rbxassetid://anim_evasive_gust",
	ancestral_breath = "rbxassetid://anim_ancestral_breath",
	weakening_coil = "rbxassetid://anim_weakening_coil",
	sticky_web = "rbxassetid://anim_sticky_web",
	investida = "rbxassetid://anim_tackle",
	ataque_de_asa = "rbxassetid://anim_wing_attack",
	jato_dagua = "rbxassetid://anim_water_gun",
	chicote_de_vinha = "rbxassetid://anim_vine_whip",
	lancamento_de_rocha = "rbxassetid://anim_rock_throw",
	golpe_sombrio = "rbxassetid://anim_shadow_sneak",
	estilhaco_de_gelo = "rbxassetid://anim_ice_shard",
	choque_do_trovao = "rbxassetid://anim_thunder_shock",
}

return Moves
end)()
local M_CombatRules=(function()
--!strict
-- CombatRules.luau - Pure combat logic: type chart, damage formulas, status effects
-- No services, no instances, no clock, no client-informed state.

local Text = M_Strings.Text
local C = M_Creatures
local Elements = M_Elements
local Skills = M_Skills
local CaptureMath = M_CaptureMath
local Moves = M_Moves

local R = {
	MaxTurns = 40,
	MaxParty = 3,
	LevelGrowth = 0.005,
	TameHealth = 1.08,
	TamePower = 1.085,
	DamageVariance = 0.15,
	PressureStart = 7,
	PressureBase = 1.6,
	MaxStatusDuration = 5,
	StatusChanceBase = 0.3,
	CriticalRate = 0.0625,
	CriticalMultiplier = 1.5,
	EscapeAttempts = 3,
	-- Double battle config
	MaxPartyDouble = 4,
	-- Horde battle config
	HordeSize = 5,
	-- Guardian raid config
	RaidMaxPlayers = 4,
}

-- Status Effect Types
export type StatusEffect =
	| "burn"
	| "freeze"
	| "paralyze"
	| "poison"
	| "sleep"
	| "confuse"
	| "fear"
	| "curse"
	| "bless"

export type StatusData = {
	type: StatusEffect,
	duration: number,
	source: string?,
	potency: number?, -- For damage-over-time effects
}

export type Combatant = {
	id: string,
	lv: number,
	maxHp: number,
	hp: number,
	atk: number,
	def: number,
	speed: number,
	el: string,
	isLegendary: boolean?,
	nextSkill: number?,
	evade: boolean?,
	status: { [StatusEffect]: StatusData }?,
	statStages: {
		atk: number,
		def: number,
		speed: number,
		spAtk: number,
		spDef: number,
		accuracy: number,
		evasion: number
	}?,
	-- Ascension fields
	ascended: boolean?,
	ascensionTurn: number?,
}

export type BattleState = {
	foe: Combatant,
	party: { [string]: Combatant },
	active: string?,
	bond: number,
	turn: number,
	version: number,
	status: "active" | "won" | "lost" | "captured" | "escaped",
	log: { { text: string, kind: string, amount: number?, health: number?, mult: number? } },
	attempts: number,
	capturable: boolean,
	isLegendary: boolean?,
	sealKind: string?,
	spentSeal: boolean?,
	captureBase: number?,
	message: string?,
	intro: string?,
	-- Double battle fields
	battleType: "wild" | "double" | "horde" | "guardian" | "special" | "raid",
	foes: { Combatant }?, -- For multiple foes
	field: {
		weather: string?,
		terrain: string?,
		gravity: number,
		trickRoom: boolean,
		tailwind: { [string]: number },
	}?,
}

-- Type effectiveness is handled by Elements.mult (2, 1, 0.5, 0)

function R.stats(id: string, lv: number): Combatant
	local def = assert(C.ById[id], Text.ESPECIE_DE_COMBATE_DESCONHECIDA_6A7E80)
	local scale = 1 + R.LevelGrowth * (lv - 1)
	local shapeSpeed = ({ Blob = 9, Beast = 15, Bird = 20, Dragon = 13, Serpent = 16, Insect = 18, Quadruped = 14, Winged = 19, Aquatic = 12, Arthropod = 16, Mineral = 8, Spectral = 17, Vegetal = 10, Draconic = 15 })[def.shape] or 12
	return {
		id = id,
		lv = lv,
		maxHp = math.floor(def.hp * scale),
		atk = def.atk * scale,
		def = 4 + def.rar * 3 + lv * 0.35,
		speed = shapeSpeed + lv,
		el = def.el,
		nextSkill = 0,
		statStages = { atk = 0, def = 0, speed = 0, spAtk = 0, spDef = 0, accuracy = 0, evasion = 0 },
		status = {},
	}
end

function R.damage(attacker: Combatant, defender: Combatant, power: number, guard: boolean, move: Moves.MoveData?): number
	local levelGap = math.clamp(attacker.lv - defender.lv, -30, 30)
	local pressure = 1.008 ^ levelGap
		* R.PressureBase ^ (math.max(0, math.abs(levelGap) - R.PressureStart) * (levelGap >= 0 and 1 or -1))
	if attacker.isLegendary or defender.isLegendary then
		pressure = 1.008 ^ levelGap
	end

	local typeMult = Elements.mult(attacker.el, defender.el)

	-- Stat stage modifiers
	local atkStage = attacker.statStages and attacker.statStages.atk or 0
	local defStage = defender.statStages and defender.statStages.def or 0
	local stageMult = (2 + atkStage) / (2 - defStage)

	-- Critical hit
	local isCrit = math.random() < R.CriticalRate
	local critMult = isCrit and R.CriticalMultiplier or 1

	-- Damage variance
	local variance = 1 - R.DamageVariance + math.random() * R.DamageVariance * 2

	local baseDamage = attacker.atk * power * typeMult * 100 / (100 + defender.def) * pressure * stageMult * variance * critMult * (guard and 0.45 or 1)

	-- Status effect modifiers
	if attacker.status and attacker.status.burn and move and move.category == "physical" then
		baseDamage *= 0.5
	end

	-- Ascension bonus
	if attacker.ascended then
		baseDamage *= 1.2
	end

	return math.max(1, math.floor(baseDamage))
end

function R.applyStatus(target: Combatant, statusType: StatusEffect, duration: number, source: string?, potency: number?): boolean
	if target.status[statusType] then
		return false -- Already has this status
	end

	-- Type-based immunities
	if statusType == "burn" and target.el == "Fogo" then return false end
	if statusType == "freeze" and target.el == "Gelo" then return false end
	if statusType == "paralyze" and target.el == "Elétrico" then return false end
	if statusType == "poison" and (target.el == "Metal" or target.el == "Cristal") then return false end
	if statusType == "sleep" and target.el == "Arcano" then return false end
	if statusType == "confuse" and target.el == "Luz" then return false end
	if statusType == "fear" and target.el == "Sombra" then return false end
	if statusType == "curse" and target.el == "Luz" then return false end

	-- Bless prevents negative status effects
	if target.status.bless and (statusType ~= "bless") then
		local chance = math.random()
		if chance < 0.3 then
			return false -- Bless blocked the status
		end
	end

	target.status[statusType] = {
		type = statusType,
		duration = math.min(duration, R.MaxStatusDuration),
		source = source,
		potency = potency,
	}
	return true
end

function R.removeStatus(target: Combatant, statusType: StatusEffect): boolean
	if target.status[statusType] then
		target.status[statusType] = nil
		return true
	end
	return false
end

function R.tickStatus(target: Combatant, rng: Random): { { text: string, kind: string } }?
	local log = {}
	for statusType, data in target.status do
		data.duration -= 1
		local name = C.ById[target.id] and C.ById[target.id].name or "A fera"
		if statusType == "burn" then
			local dmg = math.max(1, math.floor(target.maxHp * 0.0625))
			target.hp = math.max(0, target.hp - dmg)
			table.insert(log, { text = name .. Text.SOFREU_B1492B .. dmg .. Text.DE_DANO_POR_QUEIMADURA_04F138, kind = "status" })
		elseif statusType == "poison" then
			local dmg = math.max(1, math.floor(target.maxHp * 0.125))
			target.hp = math.max(0, target.hp - dmg)
			table.insert(log, { text = name .. Text.SOFREU_B1492B .. dmg .. Text.DE_DANO_POR_VENENO_04F138, kind = "status" })
		elseif statusType == "curse" then
			local dmg = math.max(1, math.floor(target.maxHp * 0.25))
			target.hp = math.max(0, target.hp - dmg)
			table.insert(log, { text = name .. Text.SOFREU_B1492B .. dmg .. Text.DE_DANO_POR_MALDICAO_04F138, kind = "status" })
		elseif statusType == "freeze" then
			if rng:NextNumber() < 0.2 then
				R.removeStatus(target, "freeze")
				table.insert(log, { text = name .. Text.SE_DESGELOU_8F4A4A, kind = "status" })
			end
		elseif statusType == "sleep" then
			if rng:NextNumber() < 0.25 then
				R.removeStatus(target, "sleep")
				table.insert(log, { text = name .. Text.ACORDOU_8F4A4A, kind = "status" })
			end
		elseif statusType == "confuse" then
			if rng:NextNumber() < 0.33 then
				R.removeStatus(target, "confuse")
				table.insert(log, { text = name .. Text.NO_LONGER_CONFUSED, kind = "status" })
			end
		elseif statusType == "fear" then
			-- Fear reduces damage dealt
		elseif statusType == "bless" then
			-- Bless increases crit rate
		end

		if data.duration <= 0 then
			R.removeStatus(target, statusType)
			if statusType ~= "freeze" and statusType ~= "sleep" and statusType ~= "confuse" then
				table.insert(log, { text = name .. Text.NO_LONGER_AFFECTED_BY .. statusType, kind = "status" })
			end
		end
	end
	return #log > 0 and log or nil
end

function R.canAct(target: Combatant, rng: Random): { canAct: boolean, log: { { text: string, kind: string } }? }
	local log = {}

	if target.status.paralyze and rng:NextNumber() < 0.25 then
		table.insert(log, { text = C.ById[target.id].name .. Text.ESTA_PARALISADO_E_NAO_PODE_SE_MOVER, kind = "status" })
		return { canAct = false, log = log }
	end

	if target.status.sleep then
		table.insert(log, { text = C.ById[target.id].name .. Text.ESTA_DORMINDO, kind = "status" })
		return { canAct = false, log = log }
	end

	if target.status.freeze then
		table.insert(log, { text = C.ById[target.id].name .. Text.ESTA_CONGELADO_E_NAO_PODE_SE_MOVER, kind = "status" })
		-- 20% chance to thaw
		if rng:NextNumber() < 0.2 then
			R.removeStatus(target, "freeze")
			table.insert(log, { text = C.ById[target.id].name .. Text.SE_DESGELOU, kind = "status" })
			return { canAct = true, log = log }
		end
		return { canAct = false, log = log }
	end

	if target.status.confuse and rng:NextNumber() < 0.33 then
		local dmg = math.max(1, math.floor(target.maxHp * 0.25))
		target.hp = math.max(0, target.hp - dmg)
		table.insert(log, { text = C.ById[target.id].name .. Text.SE_MACHUCOU_EM_SUA_CONFUSAO_B1492B .. dmg, kind = "status" })
		return { canAct = false, log = log }
	end

	if target.status.fear and rng:NextNumber() < 0.2 then
		table.insert(log, { text = C.ById[target.id].name .. Text.ESTA_COM_MEDO_E_HESITOU, kind = "status" })
		return { canAct = false, log = log }
	end

	return { canAct = true, log = #log > 0 and log or nil }
end

function R.modifyStatStage(target: Combatant, stat: string, stages: number): boolean
	if not target.statStages then return false end
	if not target.statStages[stat] then return false end
	target.statStages[stat] = math.clamp(target.statStages[stat] + stages, -6, 6)
	return true
end

function R.resetStatStages(target: Combatant)
	if target.statStages then
		for k in target.statStages do
			target.statStages[k] = 0
		end
	end
end

function R.chance(state: BattleState): number
	return CaptureMath.chance(state)
end

function R.new(foeId: string, foeLevel: number, settings: { statMultiplier: number?, isLegendary: boolean?, captureBase: number?, battleType: BattleState["battleType"]? }?): BattleState
	settings = settings or {}
	local foe = R.stats(foeId, foeLevel)
	foe.isLegendary = settings.isLegendary == true
	foe.hp = foe.maxHp
	for _, key in { "maxHp", "atk", "def", "speed" } do
		foe[key] = foe[key] * (settings.statMultiplier or 1)
		if key == "maxHp" then
			foe[key] = math.floor(foe[key])
			foe.hp = foe[key]
		end
	end

	return {
		foe = foe,
		party = {},
		active = nil,
		bond = 0,
		turn = 0,
		version = 0,
		status = "active",
		log = {},
		attempts = 0,
		capturable = true,
		isLegendary = settings.isLegendary,
		captureBase = settings.captureBase,
		battleType = settings.battleType or "wild",
		foes = settings.battleType and settings.battleType ~= "wild" and { foe } or nil,
		field = {
			weather = nil,
			terrain = nil,
			gravity = 1,
			trickRoom = false,
			tailwind = {},
		},
	}
end

local function note(s: BattleState, text: string, kind: string?)
	table.insert(s.log, { text = text, kind = kind or "info" })
end

local function reply(s: BattleState, guard: boolean, rng: Random)
	local pet = s.active and s.party[s.active]
	if not pet or pet.hp <= 0 then return end

	local move = nil -- Foe uses basic attack
	local amount = math.floor(R.damage(s.foe, pet, (s.turn % 3 == 0 and 1.35 or 1) * (1 - R.DamageVariance + rng:NextNumber() * R.DamageVariance * 2), guard, move) + rng:NextNumber())

	if pet.evade then
		amount = math.max(1, math.floor(amount * 0.65))
		pet.evade = false
	end

	pet.hp = math.max(0, pet.hp - amount)
	note(s, Text.A_FERA_CAUSOU_B1492B .. amount .. Text.DE_DANO_04F138, "foe")
	s.log[#s.log].amount = amount
	s.log[#s.log].health = pet.hp / pet.maxHp
	s.log[#s.log].mult = Elements.mult(s.foe.el, pet.el)

	if pet.hp == 0 then
		note(s, Text.SEU_COMPANHEIRO_ESTA_EXAUSTO_TROQUE_DE_FERA_OU_F_43D62C, "faint")
	end
end

function R.step(state: BattleState, action: string, pet: { uid: string, id: string, lv: number }?, rng: Random, seals: number, room: boolean): (boolean, string?)
	if state.status ~= "active" then
		return false, Text.ESTE_ENCONTRO_TERMINOU_EC2596
	end
	if state.turn >= R.MaxTurns then
		state.status = "escaped"
		return true
	end

	local current = state.active and state.party[state.active]

	-- Validate action
	if action == "Select" then
		if not pet or not C.ById[pet.id] or not pet.uid then
			return false, Text.ESCOLHA_UMA_FERA_SUA_699F8C
		end
		if pet.uid == state.active then
			return false, Text.ESSA_FERA_JA_ESTA_EM_CAMPO_198AD6
		end
		local n = 0
		for _ in state.party do n += 1 end
		if not state.party[pet.uid] and n >= R.MaxParty then
			return false, Text.EQUIPE_LIMITADA_A_TRES_FERAS_POR_ENCONTRO_31F83A
		end
		if state.party[pet.uid] and state.party[pet.uid].hp <= 0 then
			return false, Text.ESSA_FERA_ESTA_EXAUSTA_89922B
		end
	elseif action == "Strike" or action == "Skill" or action == "Guard" then
		if not current or current.hp <= 0 then
			return false, Text.SELECIONE_UMA_FERA_DISPONIVEL_94CE80
		end
		if action == "Skill" and state.turn < (current.nextSkill or 0) then
			return false, Text.HABILIDADE_RECARREGANDO_5B6E68
		end
	elseif action == "Capture" then
		if state.capturable == false then
			return false, Text.GUARDIOES_NAO_PODEM_SER_CAPTURADOS_CA285E
		end
		if seals < 1 then
			return false, Text.SEM_SELOS_CRIE_MAIS_NO_MERCADO_D1B215
		end
		if not room then
			return false, Text.INVENTARIO_CHEIO_NENHUM_SELO_FOI_GASTO_7FC7F9
		end
	elseif action == "Bond" and state.capturable == false then
		return false, Text.ESTE_DESAFIO_EXIGE_UMA_BATALHA_14581F
	elseif action == "UseItem" then
		-- Handled separately
	elseif action ~= "Bond" and action ~= "Flee" and action ~= "UseItem" then
		return false, Text.ACAO_DESCONHECIDA_9BB0DF
	end

	state.log = {}
	state.turn += 1
	state.version += 1
	state.spentSeal = false

	if action == "Flee" then
		state.status = "escaped"
		note(state, Text.VOCE_VOLTOU_A_EXPLORACAO_29EB17)
		return true
	end

	if action == "Select" then
		local switching = state.active ~= nil and state.party[state.active].hp > 0
		if not state.party[pet.uid] then
			local unit = R.stats(pet.id, pet.lv)
			unit.maxHp = math.floor(unit.maxHp * R.TameHealth)
			unit.atk = unit.atk * R.TamePower
			unit.hp = unit.maxHp
			unit.nextSkill = 0
			state.party[pet.uid] = unit
		end
		state.active = pet.uid
		note(state, C.ById[pet.id].name .. Text.ENTROU_EM_CAMPO_AC551A)
		if switching then
			reply(state, false, rng)
		end
	elseif action == "Capture" then
		state.spentSeal = true
		state.attempts += 1
		if rng:NextNumber() < R.chance(state) then
			state.status = "captured"
			note(state, Text.VINCULO_ESTABELECIDO_21A0FC, "capture")
		else
			note(state, Text.O_SELO_SE_DESFEZ_A_FERA_RESISTIU_ECB4B5, "miss")
			if current and current.hp > 0 then
				reply(state, false, rng)
			elseif not state.isLegendary and (rng:NextNumber() < 0.3 or state.attempts >= 6) then
				state.status = "escaped"
				note(state, Text.A_FERA_FUGIU_5FDD82)
			end
		end
	elseif action == "Bond" then
		state.bond = math.min(3, state.bond + 1)
		note(state, Text.VOCE_SE_APROXIMOU_COM_CUIDADO_VINCULO_555F67 .. state.bond .. "/3.", "bond")
		if current and current.hp > 0 then
			reply(state, false, rng)
		elseif not state.isLegendary and rng:NextNumber() < 0.15 then
			state.status = "escaped"
			note(state, Text.A_FERA_SE_ASSUSTOU_E_FUGIU_FF44C5)
		end
	elseif action == "Guard" then
		current.hp = math.min(current.maxHp, current.hp + math.floor(current.maxHp * 0.08))
		current.evade = true
		note(state, Text.SUA_FERA_RECUPEROU_O_FOLEGO_E_SE_PROTEGEU_08D205, "guard")
		reply(state, true, rng)
	elseif action == "Strike" or action == "Skill" then
		local skill = Skills[C.ById[current.id].shape]
		local moveData = Moves.getMove(current.id, action == "Skill")
		local power = action == "Skill" and (moveData and moveData.power or skill.power) or 1
		local enemyFirst = state.foe.speed > current.speed

		-- Check if can act
		local actResult = R.canAct(current, rng)
		if actResult and not actResult.canAct then
			for _, entry in actResult.log do
				note(state, entry.text, entry.kind)
			end
			if enemyFirst then
				reply(state, false, rng)
			end
		else
			if enemyFirst then
				reply(state, false, rng)
			end

			if current.hp > 0 then
				if action == "Skill" and moveData then
					current.nextSkill = state.turn + (moveData.cooldown or 3)
					-- Apply move effects
					if moveData.effect then
						R.applyMoveEffect(current, state.foe, moveData, state, rng)
					end
					note(state, moveData.name .. "!", "skill")
				end

				local amount = math.floor(R.damage(current, state.foe, power * (1 - R.DamageVariance + rng:NextNumber() * R.DamageVariance * 2), false, moveData) + rng:NextNumber())
				state.foe.hp = math.max(0, state.foe.hp - amount)

				local mult = Elements.mult(current.el, state.foe.el)
				note(state,
					Text.SUA_FERA_CAUSOU_9F1A6C .. amount .. Text.DE_DANO_949A5C .. (mult > 1 and Text.VANTAGEM_ELEMENTAL_C12EBC or mult < 1 and Text.RESISTENCIA_ELEMENTAL_8F4A4A or "."),
					"hit"
				)
				state.log[#state.log].amount = amount
				state.log[#state.log].health = state.foe.hp / state.foe.maxHp
				state.log[#state.log].mult = mult

				if state.foe.hp == 0 then
					state.status = "won"
					note(state, Text.VITORIA_FERAS_EXAUSTAS_NAO_PODEM_SER_CAPTURADAS_08B05D, "win")
				elseif not enemyFirst then
					reply(state, false, rng)
				end
			end
		end
	end

	-- Tick status effects on active combatant
	if current then
		local statusLog = R.tickStatus(current, rng)
		if statusLog then
			for _, entry in statusLog do
				note(state, entry.text, entry.kind)
			end
		end
	end

	-- Tick status effects on foe
	local foeStatusLog = R.tickStatus(state.foe, rng)
	if foeStatusLog then
		for _, entry in foeStatusLog do
			note(state, entry.text, entry.kind)
		end
	end

	-- Check for faint
	if state.status == "active" and state.active and state.party[state.active].hp <= 0 then
		local count, alive = 0, false
		for _, unit in state.party do
			count += 1
			if unit.hp > 0 then alive = true end
		end
		if count >= R.MaxParty and not alive then
			state.status = "lost"
			note(state, Text.SUA_EQUIPE_ESTA_EXAUSTA_RETORNE_PARA_SE_PREPARAR_65F135, "loss")
		end
	end

	if state.status == "active" and state.turn >= R.MaxTurns then
		state.status = "escaped"
		note(state, Text.O_ENCONTRO_TERMINOU_PELO_LIMITE_DE_TURNOS_28EB70)
	end

	return true
end

function R.applyMoveEffect(attacker: Combatant, defender: Combatant, move: Moves.MoveData, state: BattleState, rng: Random)
	if not move.effect then return end

	local effect = move.effect
	local chance = effect.chance or 1

	if rng:NextNumber() >= chance then return end

	if effect.type == "status" then
		R.applyStatus(defender, effect.status, effect.duration or 3, move.name, effect.potency)
	elseif effect.type == "stat" then
		R.modifyStatStage(defender, effect.stat, effect.stages)
	elseif effect.type == "heal" then
		local heal = math.floor(attacker.maxHp * (effect.amount or 0.125))
		attacker.hp = math.min(attacker.maxHp, attacker.hp + heal)
	elseif effect.type == "drain" then
		local dmg = math.floor(R.damage(attacker, defender, move.power * (effect.drainRatio or 0.5), false, move))
		defender.hp = math.max(0, defender.hp - dmg)
		attacker.hp = math.min(attacker.maxHp, attacker.hp + dmg)
	elseif effect.type == "multiHit" then
		-- Handled in damage calculation
	elseif effect.type == "recharge" then
		attacker.nextSkill = (attacker.nextSkill or 0) + (effect.turns or 1)
	elseif effect.type == "flinch" then
		-- Target loses next turn
		defender.status.flinch = { type = "flinch", duration = 1 }
	elseif effect.type == "critBoost" then
		attacker.statStages = attacker.statStages or { atk = 0, def = 0, speed = 0, spAtk = 0, spDef = 0, accuracy = 0, evasion = 0 }
		R.modifyStatStage(attacker, "spAtk", 1)
	elseif effect.type == "protect" then
		attacker.status.protect = { type = "protect", duration = 1 }
	end
end

function R.resolve(id: string, level: number, enemy: string, enemyLevel: number, rng: Random)
	local state = R.new(enemy, enemyLevel)
	local log = {}
	R.step(state, "Select", { id = id, lv = level, uid = "active" }, rng, 0, true)
	while state.status == "active" and state.party.active.hp > 0 do
		local action = state.turn >= (state.party.active.nextSkill or 0) and "Skill" or "Strike"
		R.step(state, action, nil, rng, 0, true)
		for _, event in state.log do
			if event.amount then
				table.insert(log, { me = event.kind == "hit", dmg = event.amount, hp = event.health, mult = event.mult })
			end
		end
	end
	return log, state.status == "won"
end

-- Legendary Ascension (Mega Evolution equivalent)
function R.checkAscension(pet: Combatant, heldItem: string?): boolean
	if not pet.isLegendary then return false end
	if pet.lv < 100 then return false end
	-- Check for specific ascension items
	local ascensionItems = {
		fenix = "CinaSolar",
		vulcanodrago = "NucleoVulcanico",
		abissauro = "PerolaAbissal",
		ancestravore = "SementePrimordial",
		colossodune = "CoracaoDasDunas",
		aeronimbo = "OlhoDaTempestade",
		reinevoento = "CoroaDoNevoeiro",
	}
	return ascensionItems[pet.id] == heldItem
end

function R.applyAscension(pet: Combatant): Combatant
	local ascended = table.clone(pet)
	ascended.maxHp = math.floor(ascended.maxHp * 1.5)
	ascended.hp = ascended.maxHp
	ascended.atk = ascended.atk * 1.4
	ascended.def = ascended.def * 1.3
	ascended.speed = ascended.speed * 1.2
	ascended.isLegendary = true
	ascended.ascended = true
	ascended.ascensionTurn = 0
	return ascended
end

-- Horde battle support
function R.newHorde(foeId: string, foeLevel: number, count: number, settings: { statMultiplier: number?, captureBase: number? }?): BattleState
	settings = settings or {}
	local foes = {}
	for i = 1, math.min(count, R.HordeSize) do
		local foe = R.stats(foeId, foeLevel)
		foe.hp = foe.maxHp
		for _, key in { "maxHp", "atk", "def", "speed" } do
			foe[key] = foe[key] * (settings.statMultiplier or 1)
			if key == "maxHp" then
				foe[key] = math.floor(foe[key])
				foe.hp = foe[key]
			end
		end
		table.insert(foes, foe)
	end

	return {
		foe = foes[1],
		foes = foes,
		party = {},
		active = nil,
		bond = 0,
		turn = 0,
		version = 0,
		status = "active",
		log = {},
		attempts = 0,
		capturable = true,
		isLegendary = false,
		captureBase = settings.captureBase,
		battleType = "horde",
		field = {
			weather = nil,
			terrain = nil,
			gravity = 1,
			trickRoom = false,
			tailwind = {},
		},
	}
end

-- Double battle support
function R.newDouble(foeId1: string, foeLevel1: number, foeId2: string, foeLevel2: number, settings: { statMultiplier: number? }?): BattleState
	settings = settings or {}
	local foe1 = R.stats(foeId1, foeLevel1)
	local foe2 = R.stats(foeId2, foeLevel2)
	foe1.hp = foe1.maxHp
	foe2.hp = foe2.maxHp
	for _, key in { "maxHp", "atk", "def", "speed" } do
		foe1[key] = foe1[key] * (settings.statMultiplier or 1)
		foe2[key] = foe2[key] * (settings.statMultiplier or 1)
		if key == "maxHp" then
			foe1[key] = math.floor(foe1[key])
			foe1.hp = foe1[key]
			foe2[key] = math.floor(foe2[key])
			foe2.hp = foe2[key]
		end
	end

	return {
		foe = foe1,
		foes = { foe1, foe2 },
		party = {},
		active = nil,
		bond = 0,
		turn = 0,
		version = 0,
		status = "active",
		log = {},
		attempts = 0,
		capturable = false,
		isLegendary = false,
		battleType = "double",
		field = {
			weather = nil,
			terrain = nil,
			gravity = 1,
			trickRoom = false,
			tailwind = {},
		},
	}
end

return R
end)()
local C=M_Creatures;local Capture=M_CaptureRules;local Skills=M_Skills;local Elements=M_Elements;local R=M_CombatRules
-- Executado pelo harness sem serviços Roblox.
local low={NextNumber=function() return 0 end}
local high={NextNumber=function() return .999 end}
local function pet(uid,id,lv) return {uid=uid,id=id or "cinzelo",lv=lv or 1} end
local s=R.new("bolhinho",1)
assert(not R.step(s,"Strike",nil,low,5,true));assert(s.turn==0 and s.version==0)
assert(not R.step(s,"Select",{uid="x",id="bad",lv=1},low,5,true))
assert(not R.step(s,"Capture",nil,low,0,true));assert(s.turn==0)
assert(not R.step(s,"Capture",nil,low,5,false));assert(s.turn==0)
assert(R.step(s,"Capture",nil,low,1,true));assert(s.status=="captured" and s.spentSeal)
assert(not R.step(s,"Capture",nil,low,1,true));assert(s.attempts==1)
s=R.new("fenix",15)
assert(R.step(s,"Select",pet("u1","magmarau",20),low,5,true))
local initial=R.chance(s);s.foe.hp=math.ceil(s.foe.maxHp*.25);s.bond=3;assert(R.chance(s)>initial and R.chance(s)<=.94)
s=R.new("bolhinho",1);R.step(s,"Select",pet("u1","cinzelo",20),low,5,true)
s.foe.hp=1
R.step(s,"Strike",nil,low,5,true);assert(s.status=="won" and s.foe.hp==0)
assert(not R.step(s,"Capture",nil,low,5,true))
s=R.new("fenix",15);R.step(s,"Select",pet("u1","cinzelo",20),low,5,true)
R.step(s,"Select",pet("u2","bolhinho",20),low,5,true);R.step(s,"Select",pet("u3","magmarau",20),low,5,true)
assert(not R.step(s,"Select",pet("u4","magmarau",20),low,5,true))
local unit=s.party.u3;unit.hp=0;assert(not R.step(s,"Strike",nil,low,5,true))
assert(not R.step(s,"Select",pet("u3","magmarau",20),low,5,true))
s=R.new("fenix",15);R.step(s,"Select",pet("u1","magmarau",20),low,5,true)
assert(R.step(s,"Skill",nil,low,5,true));assert(not R.step(s,"Skill",nil,low,5,true))
assert(R.step(s,"Flee",nil,low,5,true));assert(s.status=="escaped")
for _,a in C.List do for _,b in C.List do
 local aa,bb=R.stats(a.id,10),R.stats(b.id,10)
 assert(R.damage(aa,bb,1,false)>=1)
 assert(R.damage(aa,bb,1,true)<=R.damage(aa,bb,1,false))
end end
local seed=19;local rng={}
function rng:NextNumber() seed=seed*48271%2147483647;return seed/2147483647 end
local simulations=0
for _,def in C.List do
 for _,choice in {"Strike","Skill","Capture","Bond","Guard"} do
  s=R.new(def.id,10);R.step(s,"Select",pet("u1","magmarau",20),rng,100,true)
  for i=1,40 do
   if s.status~="active" then break end
   local selected=choice=="Skill" and i%3~=1 and "Guard" or choice
   local ok=R.step(s,selected,nil,rng,100,true)
   if not ok then R.step(s,"Bond",nil,rng,100,true) end
   assert(s.foe.hp>=0 and s.foe.hp<=s.foe.maxHp)
   for _,cr in s.party do assert(cr.hp>=0 and cr.hp<=cr.maxHp) end
   assert(R.chance(s)>=.05 and R.chance(s)<=.94)
  end
  assert(s.status~="active","Encontro não termina no limite")
  simulations+=1
 end
end
print("PASS: combate/captura; 900 pares de dano; "..simulations.." encontros; inválidos sem mutação; cooldown, fim, equipe, selos e limites")
