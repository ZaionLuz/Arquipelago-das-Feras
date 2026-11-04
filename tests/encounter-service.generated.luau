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
--!nonstrict
-- Seis elementos. Strong[atacante] = alvos que sofrem dano dobrado.
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
local M_CombatRules=(function()
--!nonstrict
local Text = M_Strings.Text
-- Regras puras: sem serviços, instâncias, relógio ou recursos informados pelo cliente.
local C = M_Creatures
local Elements = M_Elements
local Skills = M_Skills
local CaptureMath = M_CaptureMath
local R = {
	MaxTurns = 40,
	MaxParty = 3,
	LevelGrowth = 0.005,
	TameHealth = 1.08,
	TamePower = 1.085,
	DamageVariance = 0.5,
	PressureStart = 7,
	PressureBase = 1.6,
}
function R.stats(id, lv)
	local def = assert(C.ById[id], Text.ESPECIE_DE_COMBATE_DESCONHECIDA_6A7E80)
	local scale = 1 + R.LevelGrowth * (lv - 1)
	return {
		id = id,
		lv = lv,
		maxHp = math.floor(def.hp * scale),
		atk = def.atk * scale,
		def = 4 + def.rar * 3 + lv * 0.35,
		speed = ({ Blob = 9, Beast = 15, Bird = 20, Dragon = 13, Serpent = 16, Insect = 18 })[def.shape] + lv,
		el = def.el,
	}
end
function R.damage(a, b, power, guard)
	local gap = math.clamp(a.lv - b.lv, -30, 30)
	local pressure = 1.008 ^ gap
		* R.PressureBase ^ (math.max(0, math.abs(gap) - R.PressureStart) * (gap >= 0 and 1 or -1))
	if a.isLegendary or b.isLegendary then
		pressure = 1.008 ^ gap
	end
	return math.max(
		1,
		a.atk * power * Elements.mult(a.el, b.el) * 100 / (100 + b.def) * pressure * (guard and 0.45 or 1)
	)
end
function R.chance(s)
	return CaptureMath.chance(s)
end
function R.new(id, lv, settings)
	settings = settings or {}
	local foe = R.stats(id, lv)
	foe.isLegendary = settings.isLegendary == true
	for _, key in { "maxHp", "atk", "def", "speed" } do
		foe[key] = foe[key] * (settings.statMultiplier or 1)
		if key == "maxHp" then
			foe[key] = math.floor(foe[key])
		end
	end
	foe.hp = foe.maxHp
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
	}
end
local function note(s, text, kind)
	table.insert(s.log, { text = text, kind = kind or "info" })
end
local function reply(s, guard, rng)
	local pet = s.active and s.party[s.active]
	if not pet or pet.hp <= 0 then
		return
	end
	local amount = math.floor(
		R.damage(
			s.foe,
			pet,
			(s.turn % 3 == 0 and 1.35 or 1) * (1 - R.DamageVariance + rng:NextNumber() * R.DamageVariance * 2),
			guard
		) + rng:NextNumber()
	)
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
-- Retorna false sem modificar estado para decisões inválidas.
function R.step(s, action, pet, rng, seals, room)
	if s.status ~= "active" then
		return false, Text.ESTE_ENCONTRO_TERMINOU_EC2596
	end
	if s.turn >= R.MaxTurns then
		s.status = "escaped"
		return true
	end
	local current = s.active and s.party[s.active]
	if action == "Select" then
		if not pet or not C.ById[pet.id] or not pet.uid then
			return false, Text.ESCOLHA_UMA_FERA_SUA_699F8C
		end
		if pet.uid == s.active then
			return false, Text.ESSA_FERA_JA_ESTA_EM_CAMPO_198AD6
		end
		local n = 0
		for _ in s.party do
			n += 1
		end
		if not s.party[pet.uid] and n >= R.MaxParty then
			return false, Text.EQUIPE_LIMITADA_A_TRES_FERAS_POR_ENCONTRO_31F83A
		end
		if s.party[pet.uid] and s.party[pet.uid].hp <= 0 then
			return false, Text.ESSA_FERA_ESTA_EXAUSTA_89922B
		end
	elseif action == "Strike" or action == "Skill" or action == "Guard" then
		if not current or current.hp <= 0 then
			return false, Text.SELECIONE_UMA_FERA_DISPONIVEL_94CE80
		end
		if action == "Skill" and s.turn < (current.nextSkill or 0) then
			return false, Text.HABILIDADE_RECARREGANDO_5B6E68
		end
	elseif action == "Capture" then
		if s.capturable == false then
			return false, Text.GUARDIOES_NAO_PODEM_SER_CAPTURADOS_CA285E
		end
		if seals < 1 then
			return false, Text.SEM_SELOS_CRIE_MAIS_NO_MERCADO_D1B215
		end
		if not room then
			return false, Text.INVENTARIO_CHEIO_NENHUM_SELO_FOI_GASTO_7FC7F9
		end
	elseif action == "Bond" and s.capturable == false then
		return false, Text.ESTE_DESAFIO_EXIGE_UMA_BATALHA_14581F
	elseif action ~= "Bond" and action ~= "Flee" then
		return false, Text.ACAO_DESCONHECIDA_9BB0DF
	end
	s.log = {}
	s.turn += 1
	s.version += 1
	s.spentSeal = false
	if action == "Flee" then
		s.status = "escaped"
		note(s, Text.VOCE_VOLTOU_A_EXPLORACAO_29EB17)
		return true
	end
	if action == "Select" then
		local switching = s.active ~= nil and s.party[s.active].hp > 0
		if not s.party[pet.uid] then
			local unit = R.stats(pet.id, pet.lv)
			unit.maxHp = math.floor(unit.maxHp * R.TameHealth)
			unit.atk = unit.atk * R.TamePower
			unit.hp = unit.maxHp
			unit.nextSkill = 0
			s.party[pet.uid] = unit
		end
		s.active = pet.uid
		note(s, C.ById[pet.id].name .. Text.ENTROU_EM_CAMPO_AC551A)
		if switching then
			reply(s, false, rng)
		end
	elseif action == "Capture" then
		s.spentSeal = true
		s.attempts += 1
		if rng:NextNumber() < R.chance(s) then
			s.status = "captured"
			note(s, Text.VINCULO_ESTABELECIDO_21A0FC, "capture")
		else
			note(s, Text.O_SELO_SE_DESFEZ_A_FERA_RESISTIU_ECB4B5, "miss")
			if current and current.hp > 0 then
				reply(s, false, rng)
			elseif not s.isLegendary and (rng:NextNumber() < 0.3 or s.attempts >= 6) then
				s.status = "escaped"
				note(s, Text.A_FERA_FUGIU_5FDD82)
			end
		end
	elseif action == "Bond" then
		s.bond = math.min(3, s.bond + 1)
		note(s, Text.VOCE_SE_APROXIMOU_COM_CUIDADO_VINCULO_555F67 .. s.bond .. "/3.", "bond")
		if current and current.hp > 0 then
			reply(s, false, rng)
		elseif not s.isLegendary and rng:NextNumber() < 0.15 then
			s.status = "escaped"
			note(s, Text.A_FERA_SE_ASSUSTOU_E_FUGIU_FF44C5)
		end
	elseif action == "Guard" then
		current.hp = math.min(current.maxHp, current.hp + math.floor(current.maxHp * 0.08))
		note(s, Text.SUA_FERA_RECUPEROU_O_FOLEGO_E_SE_PROTEGEU_08D205, "guard")
		reply(s, true, rng)
	else
		local skill = Skills[C.ById[current.id].shape]
		local power = action == "Skill" and skill.power or 1
		local enemyFirst = s.foe.speed > current.speed
		if enemyFirst then
			reply(s, false, rng)
		end
		if current.hp > 0 then
			if action == "Skill" then
				current.nextSkill = s.turn + 3
				if skill.effect == "heal" then
					current.hp = math.min(current.maxHp, current.hp + math.floor(current.maxHp * 0.12))
				elseif skill.effect == "evade" then
					current.evade = true
				elseif skill.effect == "weaken" then
					s.foe.atk = math.max(1, math.floor(s.foe.atk * 0.85))
				elseif skill.effect == "slow" then
					s.foe.speed = math.max(1, math.floor(s.foe.speed * 0.8))
				end
				note(s, skill.name .. "!", "skill")
			end
			local amount = math.floor(
				R.damage(
					current,
					s.foe,
					power * (1 - R.DamageVariance + rng:NextNumber() * R.DamageVariance * 2),
					false
				) + rng:NextNumber()
			)
			s.foe.hp = math.max(0, s.foe.hp - amount)
			note(
				s,
				Text.SUA_FERA_CAUSOU_9F1A6C
					.. amount
					.. Text.DE_DANO_949A5C
					.. (Elements.mult(current.el, s.foe.el) > 1 and Text.VANTAGEM_ELEMENTAL_C12EBC or "."),
				"hit"
			)
			s.log[#s.log].amount = amount
			s.log[#s.log].health = s.foe.hp / s.foe.maxHp
			s.log[#s.log].mult = Elements.mult(current.el, s.foe.el)
			if s.foe.hp == 0 then
				s.status = "won"
				note(s, Text.VITORIA_FERAS_EXAUSTAS_NAO_PODEM_SER_CAPTURADAS_08B05D, "win")
			elseif not enemyFirst then
				reply(s, false, rng)
			end
		end
	end
	if s.status == "active" and s.active and s.party[s.active].hp <= 0 then
		local count, alive = 0, false
		for _, unit in s.party do
			count += 1
			if unit.hp > 0 then
				alive = true
			end
		end
		if count >= R.MaxParty and not alive then
			s.status = "lost"
			note(s, Text.SUA_EQUIPE_ESTA_EXAUSTA_RETORNE_PARA_SE_PREPARAR_65F135, "loss")
		end
	end
	if s.status == "active" and s.turn >= R.MaxTurns then
		s.status = "escaped"
		note(s, Text.O_ENCONTRO_TERMINOU_PELO_LIMITE_DE_TURNOS_28EB70)
	end
	return true
end
function R.resolve(id, level, enemy, enemyLevel, rng)
	local state = R.new(enemy, enemyLevel)
	local log = {}
	R.step(state, "Select", { id = id, lv = level, uid = "active" }, rng, 0, true)
	while state.status == "active" and state.party.active.hp > 0 do
		local action = state.turn >= (state.party.active.nextSkill or 0) and "Skill" or "Strike"
		R.step(state, action, nil, rng, 0, true)
		for _, event in state.log do
			if event.amount then
				table.insert(
					log,
					{ me = event.kind == "hit", dmg = event.amount, hp = event.health, mult = event.mult }
				)
			end
		end
	end
	return log, state.status == "won"
end
return R

end)()
local M_LevelBands=(function()
--!strict
local L = { Order = { "Alvorecer", "Brasa", "Recife", "Floresta", "Dunas", "Picos", "Pantano" }, ById = {} }
for index, id in L.Order do
	local minimum = ({ 1, 10, 18, 26, 34, 42, 50 })[index]
	local maximum = ({ 9, 17, 25, 33, 41, 49, 57 })[index]
	L.ById[id] = {
		id = id,
		index = index,
		min = minimum,
		max = maximum,
		guardian = maximum + 2,
		previous = L.Order[index - 1],
		cost = ({ 0, 1440, 3384, 5112, 6840, 8568, 10296 })[index],
	}
end
return L

end)()
local M_Progression=(function()
--!strict
local Bands = M_LevelBands
local P = { MaxLevel = 100, EncountersPerHour = 50 }
local checkpoints = {
	{ level = 1, hours = 0 },
	{ level = 10, hours = 0.75 },
	{ level = 18, hours = 2 },
	{ level = 26, hours = 4 },
	{ level = 34, hours = 7 },
	{ level = 42, hours = 11 },
	{ level = 50, hours = 16 },
}
function P.playerCost(level: number): number
	for index = 1, #checkpoints - 1 do
		local a, b = checkpoints[index], checkpoints[index + 1]
		if level >= a.level and level < b.level then
			return math.floor((b.hours - a.hours) / (b.level - a.level) * P.EncountersPerHour * (60 + index * 10) + 0.5)
		end
	end
	return 2200 + (level - 50) * 75
end
function P.rewards(region: string, foeLevel: number, rarity: number, teamLevel: number)
	local band = assert(Bands.ById[region], "Região de recompensa desconhecida")
	local gap = teamLevel - foeLevel
	local penalty = gap >= 15 and 0.1 or gap >= 8 and 0.5 or 1
	return {
		gold = 30 * band.index ^ 2 + foeLevel * 2 + rarity * 3,
		xp = math.max(1, math.floor((60 + band.index * 10 + (rarity - 1) * 5) * penalty)),
		creatureXp = math.max(1, math.floor((45 + band.index * 8 + (rarity - 1) * 5) * penalty)),
		penalty = penalty,
	}
end
function P.creatureCost(level: number): number
	return 35 + level * 15
end
function P.award(data: any, amount: number)
	data.playerXp = math.min(1e9, (data.playerXp or 0) + math.max(0, math.floor(amount)))
	data.playerLevel = data.playerLevel or 1
	while data.playerLevel < P.MaxLevel and data.playerXp >= P.playerCost(data.playerLevel) do
		data.playerXp -= P.playerCost(data.playerLevel)
		data.playerLevel += 1
	end
end
function P.awardCreature(creature: any, amount: number)
	creature.xp = math.min(1e9, (creature.xp or 0) + math.max(0, math.floor(amount)))
	while creature.lv < P.MaxLevel and creature.xp >= P.creatureCost(creature.lv) do
		creature.xp -= P.creatureCost(creature.lv)
		creature.lv += 1
	end
end
return P

end)()
local M_SpeciesRules=(function()
--!nonstrict
local C = M_Creatures
local S = { SpecialId = "fenix" }
function S.isGeneral(id)
	return typeof(id) == "string" and C.ById[id] ~= nil and C.ById[id].acquisition ~= "special"
end
function S.get(id)
	return typeof(id) == "string" and C.ById[id] or nil
end
return S

end)()
local M_Config=(function()
--!strict
return {
	V7 = { EnforceIslandLevels = true, PhoenixSanctuary = true, RequireGuardian = false },
	PhoenixMaxPerAccount = 1,
	PhoenixRetrySeconds = 1200,
	ProfileVersion = 5,
	Assets = { PhoenixIntro = "", PhoenixCry = "", SolarAmbience = "" },
}

end)()
local M_CreatureGrant=(function()
--!nonstrict
local Species = M_SpeciesRules
local Config = M_Config
local G = {}
function G.grant(profile, id, origin, nonce, options)
	options = options or {}
	local def = Species.get(id)
	if not def or typeof(nonce) ~= "string" or #nonce == 0 or #nonce > 100 or typeof(origin) ~= "string" then
		return nil, "INVALID_GRANT"
	end
	profile.grants = profile.grants or {}
	if profile.grants[nonce] then
		local uid = profile.grants[nonce]
		if not profile.creatures[uid] or profile.creatures[uid].id ~= id then
			return nil, "NONCE_CONFLICT"
		end
		return uid, "REPLAY"
	end
	local legacy = origin == "legacy_egg" and profile.legacyEggPermits and profile.legacyEggPermits[nonce] == id
	if not Species.isGeneral(id) and not legacy then
		if origin ~= "phoenix_sanctuary" or not profile.phoenix or profile.phoenix.encounterId ~= nonce then
			return nil, "SPECIAL_SOURCE"
		end
		local owned = 0
		for _, c in profile.creatures do
			if c.id == id then
				owned += 1
			end
		end
		if
			owned >= Config.PhoenixMaxPerAccount
			or (profile.phoenix.captureCount or (profile.phoenix.captured and 1 or 0))
				>= Config.PhoenixMaxPerAccount
		then
			return nil, "SPECIAL_LIMIT"
		end
	end
	local count = 0
	for _ in profile.creatures do
		count += 1
	end
	if count >= 60 then
		return nil, "INVENTORY_FULL"
	end
	profile.nextId = math.max(profile.nextId or 1, 1)
	while profile.creatures["u" .. profile.nextId] do
		profile.nextId += 1
	end
	local uid = "u" .. profile.nextId
	profile.nextId += 1
	profile.creatures[uid] = { id = id, lv = math.clamp(math.floor(options.level or 1), 1, 100), xp = 0 }
	profile.discovered = profile.discovered or {}
	profile.discovered[id] = true
	profile.grants[nonce] = uid
	if not Species.isGeneral(id) then
		profile.phoenix.captured = true
		profile.phoenix.captureCount = (profile.phoenix.captureCount or 0) + 1
		profile.phoenix.encounterId = nil
	end
	if legacy then
		profile.legacyEggPermits[nonce] = nil
	end
	return uid, "GRANTED"
end
return G

end)()
local M_PhoenixQuest=(function()
--!nonstrict
local Text = M_Strings.Text
local Config = M_Config
local Q = { Glyphs = { duneHidden = true, duneRuin = true, skyPeak = true } }
function Q.stage(profile)
	local n = 0
	for id, value in (profile.phoenix and profile.phoenix.glyphs or {}) do
		if value == true and Q.Glyphs[id] then
			n += 1
		end
	end
	return math.min(3, n)
end
function Q.public(profile)
	local stage = Q.stage(profile)
	if stage == 0 then
		return { stage = 0 }
	end
	if stage == 1 then
		return {
			stage = 1,
			title = Text.ECO_DE_FOGO_ANTIGO_40525F,
			hint = Text.UMA_INSCRICAO_MENCIONA_DOIS_SINAIS_ENTRE_AREIA_E_4D4A59,
		}
	end
	if stage == 2 then
		return {
			stage = 2,
			title = Text.VESTIGIOS_513BA0,
			hint = Text.AS_RUINAS_DAS_DUNAS_RESPONDEM_AOS_SINAIS_DAS_ALT_695E0C,
		}
	end
	return {
		stage = 3,
		title = Text.VESTIGIOS_513BA0,
		hint = Text.OFERECA_UMA_CHAMA_NO_ALTAR_DAS_RUINAS_24F74A,
		nextAttemptAt = profile.phoenix.nextAttemptAt,
		captured = (profile.phoenix.captureCount or (profile.phoenix.captured and 1 or 0))
			>= Config.PhoenixMaxPerAccount,
	}
end
function Q.check(profile, now)
	if not Config.V7.PhoenixSanctuary then
		return false, "DISABLED"
	end
	if (profile.playerLevel or 1) < 45 or not (profile.unlocked and profile.unlocked.Dunas) then
		return false, "REQUIREMENTS"
	end
	if Q.stage(profile) < 3 then
		return false, "GLYPHS"
	end
	if (profile.phoenix.captureCount or (profile.phoenix.captured and 1 or 0)) >= Config.PhoenixMaxPerAccount then
		return false, "CAPTURED"
	end
	if profile.phoenix.encounterId then
		return false, "ACTIVE"
	end
	if now < (profile.phoenix.nextAttemptAt or 0) then
		return false, "COOLDOWN"
	end
	return true
end
return Q

end)()
local M_Access=(function()
--!nonstrict
local Bands = M_LevelBands
local Config = M_Config
local A = {}
local purposes = {
	travel = true,
	encounter = true,
	capture = true,
	battle = true,
	hatch = true,
	shop = true,
	habitat = true,
	sanctuary = true,
	unlock = true,
}
function A.check(profile, id, purpose)
	if typeof(profile) ~= "table" or typeof(id) ~= "string" or not Bands.ById[id] or not purposes[purpose] then
		return { ok = false, reason = "UNKNOWN_ISLAND" }
	end
	local level = profile.playerLevel or 1
	if typeof(level) ~= "number" or level ~= level or level < 1 or level == math.huge then
		return { ok = false, reason = "LOCKED_LEVEL" }
	end
	local band = Bands.ById[id]
	local unlocked = profile.unlocked and profile.unlocked[id] == true
	local grandfathered = unlocked and profile.legacyGrandfathered and profile.legacyGrandfathered[id] == true
	if purpose ~= "unlock" and not unlocked then
		return { ok = false, reason = "NOT_UNLOCKED" }
	end
	if Config.V7.EnforceIslandLevels and not grandfathered and level < band.min then
		return { ok = false, reason = "LOCKED_LEVEL" }
	end
	if purpose == "unlock" then
		if band.previous and not (profile.unlocked and profile.unlocked[band.previous]) then
			return { ok = false, reason = "LOCKED_PREV" }
		end
		if
			Config.V7.RequireGuardian
			and band.previous
			and not (profile.guardians and profile.guardians[band.previous])
		then
			return { ok = false, reason = "LOCKED_GUARDIAN" }
		end
		if (profile.gold or 0) < band.cost then
			return { ok = false, reason = "LOCKED_GOLD" }
		end
	end
	return { ok = true, reason = grandfathered and "LEGACY" or "OK" }
end
return A

end)()
local C=M_Creatures

-- Dependências Roblox simuladas: verifica transações e protocolo, não rede real.
local Random={new=function() return {NextNumber=function() return 0 end} end}
local clock=0;local now=10000
local os={clock=function() return clock end,time=function() return now end}
local data={};local releaseCount=0;local registry={};local emitted={};local removal
local Players={PlayerRemoving={Connect=function(_,callback) removal=callback end}}
local RS={};local Http={GenerateGUID=function() return "token"..tostring(clock) end}
local game={GetService=function(_,name) return ({ReplicatedStorage=RS,Players=Players,HttpService=Http})[name] end}
local Instance={new=function()
 local obj={FireClient=function(_,player,snapshot) emitted[player]=snapshot end}
 return setmetatable(obj,{__newindex=function(t,k,v) rawset(t,k,v);if k=="Name" then registry[v]=t end end})
end}
local task={spawn=function() end,wait=function() end}
local Region={current=function() return "Brasa" end,requireCurrent=function() return {ok=true} end}
local holdSave=false;local saved={}
local Data={save=function(p) if holdSave then coroutine.yield("SAVE_YIELD") end;saved[p]=data[p] and {cooldown=data[p].phoenix and data[p].phoenix.nextAttemptAt};return true end,get=function(p) return data[p] end}
local World={refresh=function() end}
local vector=setmetatable({},{__sub=function() return {Magnitude=0} end})
local function player()
 return {SetAttribute=function() end,Character={FindFirstChild=function() return {Position=vector} end,FindFirstChildOfClass=function() return {Health=100} end}}
end
local SanctuaryBuilder={altarPosition=function() return vector end}
local E=(function()
--!nonstrict
local Text = M_Strings.Text
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Http = game:GetService("HttpService")
local Data = Data
local C = M_Creatures
local Rules = M_CombatRules
local CaptureRules = M_CaptureRules
local Progression = M_Progression
local Grant = M_CreatureGrant
local Quest = M_PhoenixQuest
local Config = M_Config
local Region = Region
local Species = M_SpeciesRules
local E = {}
local opening = {}
local sessions = {}
local rng = Random.new()
local net
local events
local function snapshot(session, message)
	local s = session.state
	local party = {}
	for uid, p in s.party do
		party[uid] = { id = p.id, lv = p.lv, hp = p.hp, maxHp = p.maxHp, nextSkill = p.nextSkill }
	end
	return {
		token = session.token,
		seals = session.seals,
		sealType = session.sealType or "Basic",
		sealStock = session.sealStock or {},
		version = s.version,
		status = s.status,
		capturable = s.capturable ~= false,
		turn = s.turn,
		foe = s.foe,
		party = party,
		active = s.active,
		bond = s.bond,
		chance = Rules.chance(s),
		log = s.log,
		message = message,
		expires = session.expires,
		intro = session.special and "phoenix" or nil,
	}
end
local function finish(player, session)
	if session.released then
		return
	end
	session.released = true
	local d = Data.get(player)
	local s = session.state
	if d and s.status == "captured" then
		local origin = session.special and "phoenix_sanctuary" or "wild_capture"
		local uid, reason = Grant.grant(d, s.foe.id, origin, session.token, { level = s.foe.lv })
		if uid then
			d.stats.capture = (d.stats.capture or 0) + 1
			local pet = s.active and d.creatures[s.active]
			local reward =
				Progression.rewards(session.region, s.foe.lv, C.ById[s.foe.id].rar, pet and pet.lv or s.foe.lv)
			Progression.award(d, math.floor(reward.xp * 0.6))
		else
			s.status = "escaped"
			table.insert(s.log, { text = Text.CONCESSAO_RECUSADA_951368 .. reason, kind = "error" })
		end
	elseif d and s.status == "won" then
		local def = C.ById[s.foe.id]
		local teamLevel = 0
		for uid in s.party do
			local pet = d.creatures[uid]
			if pet then
				teamLevel = math.max(teamLevel, pet.lv)
			end
		end
		local reward = Progression.rewards(session.region, s.foe.lv, def.rar, teamLevel)
		d.gold += reward.gold
		d.wins += 1
		d.stats.win = (d.stats.win or 0) + 1
		Progression.award(d, reward.xp)
		local pet = d.creatures[s.active]
		if pet then
			Progression.awardCreature(pet, reward.creatureXp)
			local refreshed, err = pcall(World.refresh, player)
			if not refreshed then
				warn(Text.MODELO_SERA_RECONSTRUIDO_NA_PROXIMA_ATUALIZACAO_BF3624 .. tostring(err))
			end
		end
		table.insert(s.log, {
			text = "Recompensa: "
				.. reward.gold
				.. " ouro · "
				.. reward.xp
				.. " XP · "
				.. reward.creatureXp
				.. Text.XP_DA_FERA_1A37A2,
			kind = "reward",
		})
	end
	if d and s.status == "won" and session.guardian and not d.guardians[session.guardian] then
		d.guardians[session.guardian] = true
		d.stats.guardian = (d.stats.guardian or 0) + 1
		d.gold += 100
		Progression.award(d, 200)
	end
	if session.special and d then
		d.phoenix.encounterId = nil
		d.phoenix.nextAttemptAt = math.max(d.phoenix.nextAttemptAt or 0, os.time() + Config.PhoenixRetrySeconds)
		local saved = Data.save(player)
		if not saved then
			table.insert(s.log, { text = Text.SALVAMENTO_PENDENTE_AGUARDE_ANTES_DE_SAIR_5F0A13, kind = "error" })
		end
	end
	session.release(s.status == "captured" or s.status == "won")
end
function E.open(player, specimen, release)
	local d = Data.get(player)
	if not d then
		return false
	end
	if opening[player] and not specimen.special then
		return false
	end
	if not specimen.special and not Species.isGeneral(specimen.id) then
		return false
	end
	local region = specimen.region or Region.current(player, "encounter")
	if not Region.requireCurrent(player, region, "encounter").ok then
		return false
	end
	local old = sessions[player]
	if old and old.state.status == "active" then
		return false
	end
	local session = {
		token = specimen.nonce or Http:GenerateGUID(false),
		region = region,
		special = specimen.special == true,
		state = Rules.new(
			specimen.id,
			specimen.lv,
			{ statMultiplier = specimen.statMultiplier, isLegendary = specimen.special }
		),
		guardian = specimen.guardianId,
		seals = d.seals,
		origin = specimen.position,
		expires = os.time() + 150,
		release = release,
	}
	session.state.capturable = specimen.capturable ~= false
	session.state.isLegendary = session.special
	session.state.captureBase = specimen.captureBase
	session.sealType = "Basic"
	session.sealStock = d.sealStock or {}
	d.stats.fight = (d.stats.fight or 0) + 1
	sessions[player] = session
	events:FireClient(player, snapshot(session))
	return true
end
function E.startSpecial(player, id)
	if id ~= "phoenix_solar" or E.active(player) then
		return false, "ACTIVE_OR_INVALID"
	end
	local d = Data.get(player)
	local ok, reason = Quest.check(d or {}, os.time())
	if not ok then
		return false, reason
	end
	if not Region.requireCurrent(player, "Dunas", "encounter").ok then
		return false, "WRONG_REGION"
	end
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	local altar = SanctuaryBuilder.altarPosition()
	if not root or (root.Position - altar).Magnitude > 15 then
		return false, "DISTANCE"
	end
	opening[player] = true
	local nonce = Http:GenerateGUID(false)
	d.phoenix.encounterId = nonce
	d.phoenix.attempts += 1
	d.phoenix.nextAttemptAt = os.time() + Config.PhoenixRetrySeconds
	local saved = Data.save(player)
	if not saved or not Data.get(player) then
		d.phoenix.encounterId = nil
		opening[player] = nil
		return false, "SAVE_FAILED"
	end
	local opened = E.open(player, {
		id = Species.SpecialId,
		lv = 60,
		region = "Dunas",
		position = altar,
		special = true,
		nonce = nonce,
		captureBase = 0.04,
		statMultiplier = 1.3,
	}, function()
		player:SetAttribute("SolarEncounterEnded", os.time())
	end)
	opening[player] = nil
	if not opened then
		d.phoenix.encounterId = nil
	end
	return opened, opened and "OK" or "INTERRUPTED"
end
function E.active(player)
	if opening[player] then
		return true
	end
	local s = sessions[player]
	return s and s.state.status == "active"
end
function E.start()
	net = Instance.new("RemoteFunction")
	net.Name = "EncounterNet"
	net.Parent = RS
	events = Instance.new("RemoteEvent")
	events.Name = "EncounterNotice"
	events.Parent = RS
	net.OnServerInvoke = function(player, token, version, action, uid)
		local session = sessions[player]
		local d = Data.get(player)
		if not session or not d then
			return nil
		end
		-- Recuperação da própria sessão caso o evento inicial chegue antes da UI.
		if action == "Resume" then
			if session.readAt and os.clock() - session.readAt < 0.1 then
				return nil
			end
			session.readAt = os.clock()
			return snapshot(session)
		end
		if typeof(token) ~= "string" or #token > 80 or token ~= session.token then
			return nil
		end
		if typeof(action) ~= "string" or #action > 16 or (uid ~= nil and (typeof(uid) ~= "string" or #uid > 40)) then
			return snapshot(session, Text.PEDIDO_INVALIDO_C2C28F)
		end
		if action == "State" then
			if session.readAt and os.clock() - session.readAt < 0.1 then
				return nil
			end
			session.readAt = os.clock()
			return snapshot(session)
		end
		if session.state.status ~= "active" then
			return snapshot(session)
		end
		if not Region.requireCurrent(player, session.region, action == "Capture" and "capture" or "battle").ok then
			session.state.status = "escaped"
			finish(player, session)
			return snapshot(session, "REGION_ACCESS_DENIED")
		end
		local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
		local humanoid = player.Character and player.Character:FindFirstChildOfClass("Humanoid")
		if
			os.time() >= session.expires
			or not root
			or not humanoid
			or humanoid.Health <= 0
			or (root.Position - session.origin).Magnitude > 40
		then
			session.state.status = "escaped"
			finish(player, session)
			return snapshot(session, Text.O_ENCONTRO_ENCERROU_DISTANCIA_TEMPO_OU_PERSONAGE_9012D6)
		end
		if typeof(version) ~= "number" or version ~= session.state.version then
			return snapshot(session, Text.ESTADO_ATUALIZADO_ESCOLHA_NOVAMENTE_CD8857)
		end
		if session.last and os.clock() - session.last < 0.25 then
			return snapshot(session, Text.AGUARDE_O_TURNO_25CBEF)
		end
		session.last = os.clock()
		if action == "ChooseSeal" then
			local seal = CaptureRules.Seals[uid]
			if not seal then
				return snapshot(session, Text.SELO_INVALIDO_51B2D9)
			end
			session.sealType = uid
			session.state.sealKind = uid
			session.state.version += 1
			session.state.log = {}
			session.seals = uid == "Basic" and d.seals or (d.sealStock or {})[uid] or 0
			return snapshot(session)
		end
		local pet = uid and d.creatures[uid]
		local count = 0
		for _ in d.creatures do
			count += 1
		end
		local ok, message = Rules.step(
			session.state,
			action,
			pet and { uid = uid, id = pet.id, lv = pet.lv },
			rng,
			session.seals,
			count < 60
		)
		if not ok then
			return snapshot(session, message)
		end
		if session.state.spentSeal then
			if session.sealType == "Basic" then
				d.seals -= 1
			else
				d.sealStock[session.sealType] -= 1
			end
		end
		session.seals = session.sealType == "Basic" and d.seals or (d.sealStock or {})[session.sealType] or 0
		if session.special and session.state.status == "active" then
			local stock = d.seals
			for _, n in d.sealStock or {} do
				stock += n
			end
			if stock <= 0 and action == "Capture" then
				session.state.status = "escaped"
				table.insert(
					session.state.log,
					{ text = Text.OS_SELOS_SE_ESGOTARAM_A_CHAMA_REPOUSARA_POR_VINT_B19B32, kind = "info" }
				)
			end
		end
		if session.state.status ~= "active" then
			finish(player, session)
		end
		return snapshot(session)
	end
	Players.PlayerRemoving:Connect(function(player)
		local s = sessions[player]
		if s then
			s.state.status = "escaped"
			finish(player, s)
		end
		sessions[player] = nil
	end)
	task.spawn(function()
		while true do
			task.wait(2)
			for player, s in sessions do
				if s.state.status == "active" and (os.time() >= s.expires or not Data.get(player)) then
					s.state.status = "escaped"
					finish(player, s)
					events:FireClient(player, snapshot(s, Text.O_ENCONTRO_TERMINOU_6F159C))
				end
			end
		end
	end)
end
return E

end)()
local p=player();data[p]={gold=100,seals=3,nextId=3,creatures={u1={id="magmarau",lv=20,xp=0}},stats={},discovered={},wins=0,guardians={},sealStock={},playerLevel=1,playerXp=0}
E.start();local net=registry.EncounterNet
local function open()
 clock+=1
 assert(E.open(p,{id="cinzelo",lv=1,position=vector},function() releaseCount+=1 end))
 return emitted[p]
end
local function request(state,action,uid)
 clock+=1;return net.OnServerInvoke(p,state.token,state.version,action,uid)
end
local s=open()
assert(net.OnServerInvoke(p,"forged",0,"Capture")==nil)
local resume=net.OnServerInvoke(p,"",0,"Resume");assert(resume.token==s.token and data[p].seals==3)
local old=s
s=net.OnServerInvoke(p,s.token,999,"Capture");assert(data[p].seals==3 and s.version==0)
s=request(s,"Capture")
-- RNG fixo abaixo faz a captura ter sucesso: uma única concessão e débito.
assert(s.status=="captured" and data[p].seals==2 and data[p].creatures.u3)
local n=releaseCount
request(old,"Capture");assert(data[p].seals==2 and releaseCount==n and not data[p].creatures.u4)
s=open();s=request(s,"Select"," чужой");assert(s.version==0)
s=request(s,"Select","u1");assert(s.version==1)
while s.status=="active" do s=request(s,"Strike") end
assert(s.status=="won" and data[p].gold>100 and data[p].wins==1)
local gold=data[p].gold;request(s,"Strike");assert(data[p].gold==gold and data[p].wins==1)
s=open();now+=151;s=request(s,"Capture");assert(s.status=="escaped" and data[p].seals==2)
s=open();removal(p);assert(not E.active(p))
print("PASS: protocolo do encontro: token, versão, propriedade, débito único, concessão única, recompensa única, timeout e saída")
-- V6: estoque separado e desafios de guardião sem captura.
clock+=1;assert(E.open(p,{id="cinzelo",lv=1,position=vector},function() releaseCount+=1 end));s=emitted[p]
data[p].sealStock.Rare=1
s=request(s,"ChooseSeal","Rare");assert(s.sealType=="Rare" and s.seals==1)
s=request(s,"Capture");assert(s.status=="captured" and data[p].sealStock.Rare==0 and data[p].seals==2)
clock+=1;assert(E.open(p,{id="cinzelo",lv=1,position=vector,capturable=false,guardianId="Brasa"},function() releaseCount+=1 end));s=emitted[p]
local before=data[p].seals;s=request(s,"Capture");assert(s.version==0 and data[p].seals==before)
s=request(s,"Select","u1")
while s.status=="active" do s=request(s,"Strike") end
assert(data[p].guardians.Brasa and data[p].stats.guardian==1)
local oldGold=data[p].gold;request(s,"Strike");assert(data[p].gold==oldGold and data[p].stats.guardian==1)
print("PASS: estoque de selo separado, guardião incapturável e bônus de desafio único")

-- V7: concorrência cooperativa no serviço REAL, interrompendo as duas escritas.
local function solarProfile()
 return {gold=100,seals=30,sealStock={},nextId=2,creatures={u1={id="magmarau",lv=55,xp=0}},stats={},discovered={},wins=0,guardians={},playerLevel=50,playerXp=0,unlocked={Dunas=true},phoenix={glyphs={duneHidden=true,duneRuin=true,skyPeak=true},sanctuaryOpen=true,attempts=0,nextAttemptAt=0,captured=false},grants={}}
end
p=player();data[p]=solarProfile();holdSave=true
local begin=coroutine.create(function() return E.startSpecial(p,"phoenix_solar") end)
local ok,yielded=coroutine.resume(begin);assert(ok and yielded=="SAVE_YIELD" and E.active(p))
for _=1,100 do assert(not E.startSpecial(p,"phoenix_solar")) end
holdSave=false;assert(coroutine.resume(begin));s=emitted[p];assert(s and s.foe.lv==60 and s.intro=="phoenix")
holdSave=true
local capturing=coroutine.create(function() return request(s,"Capture") end)
ok,yielded=coroutine.resume(capturing);assert(ok and yielded=="SAVE_YIELD")
for _=1,100 do request(s,"Capture") end
local n=0;for _,cr in data[p].creatures do if cr.id=="fenix" then n+=1 end end
assert(n==1 and data[p].seals==29 and data[p].phoenix.captured)
holdSave=false;assert(coroutine.resume(capturing));assert(saved[p].cooldown==data[p].phoenix.nextAttemptAt)
assert(not E.startSpecial(p,"phoenix_solar"))
-- Desconexão enquanto a tentativa é persistida não pode abrir ou conceder depois.
local quitting=player();data[quitting]=solarProfile();holdSave=true
local pending=coroutine.create(function() return E.startSpecial(quitting,"phoenix_solar") end)
assert(coroutine.resume(pending));removal(quitting);data[quitting]=nil;holdSave=false
assert(coroutine.resume(pending));assert(not E.active(quitting) and emitted[quitting]==nil)
print("PASS V7.09: reentrada durante yield, 101 capturas intercaladas = 1 concessão/débito, cooldown e desconexão na abertura")
