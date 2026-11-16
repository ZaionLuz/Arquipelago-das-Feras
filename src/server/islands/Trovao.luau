--!strict
-- TROVÃO (Elétrico) - NOVO: Torre do Relâmpago, núcleo energético, ruínas tecnológicas, tempestade perpétua, máquinas antigas
-- The Thunder Isle - Lightning tower, energy core, tech ruins, perpetual storm

export type TrovaoLandmark = {
	Name: string,
	Position: Vector3,
	Size: Vector3,
	Theme: "Elétrico",
	Description: string,
	Interactions: { string },
	RequiredLevel: number,
	UniqueRewards: { string },
}

export type TrovaoCave = {
	Name: string,
	Entrance: Vector3,
	Levels: number,
	Depth: number,
	Biome: string,
	Hazards: { string },
	LootTables: { [number]: { string } },
	BossChamber: Vector3?,
}

export type TrovaoPOI = {
	Name: string,
	Type: "RareSpawn" | "HiddenItem" | "LoreTablet" | "WorldEvent",
	Position: Vector3,
	RespawnTime: number,
	Requirements: { string }?,
	Rewards: { string },
	LoreText: string?,
	EventSchedule: { StartHour: number, EndHour: number, Days: { string } }?,
}

export type TrovaoGuardian = {
	Name: "Zeus, o Senhor do Raio",
	Title: "Guardião da Tempestade Eterna",
	Level: 50,
	Health: 150000,
	Phases: 5,
	Position: Vector3,
	ArenaSize: Vector3,
	Mechanics: { string },
	Rewards: { string },
	MusicTrack: string,
}

export type TrovaoDynamicEvent = {
	Name: string,
	Type: "Weather" | "Migration" | "DayNightCycle",
	Schedule: { StartHour: number, EndHour: number, Probability: number },
	Effects: { string },
	VisualChanges: { string },
	GameplayChanges: { string },
}

export type TrovaoSanctuary = {
	Name: "Santuário do Raio Primordial",
	Position: Vector3,
	Theme: "Elétrico",
	AltarPosition: Vector3,
	Blessings: { string },
	Requirements: { string },
	Cooldown: number,
}

export type TrovaoNavigation = {
	Bridges: { { From: Vector3, To: Vector3, Type: "Wood" | "Stone" | "Living" | "Light", Length: number } },
	FlyingPoints: { { Position: Vector3, Destination: string, Cooldown: number, Requirements: { string } } },
	UnderwaterTunnels: { { Entrance: Vector3, Exit: Vector3, Depth: number, AirPockets: { Vector3 } } },
	ClimbingWalls: { { Base: Vector3, Top: Vector3, Difficulty: number, Handholds: { Vector3 } } },
}

local Trovao = {}

Trovao.Name = "Trovao"
Trovao.DisplayName = "Trovão - A Ilha da Tempestade Eterna"
Trovao.Element = "Elétrico"
Trovao.RecommendedLevel = 45
Trovao.MaxLevel = 75
Trovao.Size = Vector3.new(2000, 1200, 2000)
Trovao.SpawnPoint = Vector3.new(0, 200, 0)
Trovao.Skybox = {
	Day = "rbxassetid://9000000001",
	Dawn = "rbxassetid://9000000002",
	Night = "rbxassetid://9000000003",
}
Trovao.AmbientSound = "rbxassetid://9111111111"
Trovao.MusicTracks = {
	Exploration = "rbxassetid://9222222222",
	Combat = "rbxassetid://9333333333",
	Boss = "rbxassetid://9444444444",
	Sanctuary = "rbxassetid://9555555555",
}

Trovao.Landmarks = {
	{
		Name = "Torre do Relâmpago Infinito",
		Position = Vector3.new(0, 600, 0),
		Size = Vector3.new(300, 800, 300),
		Theme = "Elétrico",
		Description = "Torre impossivelmente alta que perfura as nuvens de tempestade. Relâmpagos a golpeiam constantemente. No topo, o Olho da Tempestade observa tudo. Energia pura flui por condutores de ouro.",
		Interactions = { "Subir a Torre (Perigo)", "Tocar Condutor Principal", "Absorver Carga Total" },
		RequiredLevel = 50,
		UniqueRewards = { "Coroa de Relâmpago", "Cetro de Zeus", "Olho da Tempestade" },
	},
	{
		Name = "Núcleo Energético Primordial",
		Position = Vector3.new(0, -100, 0),
		Size = Vector3.new(200, 400, 200),
		Theme = "Elétrico",
		Description = "Coração pulsante da ilha. Esfera de plasma contido em campo magnético. Fornece energia infinita. Toque = desintegração ou ascensão.",
		Interactions = { "Sincronizar com Núcleo", "Extrair Plasma Puro", "Recarregar Artefato" },
		RequiredLevel = 45,
		UniqueRewards = { "Plasma Primordial", "Célula de Energia Infinita", "Essência de Raio" },
	},
	{
		Name = "Ruínas Tecnológicas de Atlântida",
		Position = Vector3.new(-400, 50, -300),
		Size = Vector3.new(500, 200, 500),
		Theme = "Elétrico",
		Description = "Cidade avançada destruída por sua própria tecnologia. Máquinas ainda funcionam. Robôs guardiões patrulham. Tecnologia de raio perdida esperando redescoberta.",
		Interactions = { "Reativar Sistemas", "Hackear Terminal Antigo", "Despertar IA Adormecida" },
		RequiredLevel = 48,
		UniqueRewards = { "Tecnologia Atlante", "Circuito de Ouro", "IA Fragmentada" },
	},
	{
		Name = "Olho da Tempestade Perpétua",
		Position = Vector3.new(300, 400, 200),
		Size = Vector3.new(400, 300, 400),
		Theme = "Elétrico",
		Description = "Centro da tempestade que nunca para. Calmaria perfeita cercada por furacão de raios. Tempo não passa aqui. Portal para plano elemental do ar.",
		Interactions = { "Entrar no Olho", "Negociar com Elementais", "Roubar Calmaria" },
		RequiredLevel = 52,
		UniqueRewards = { "Calmaria Engarrafada", "Pena de Elemental", "Chave do Plano Aéreo" },
	},
	{
		Name = "Fábrica de Máquinas Antigas",
		Position = Vector3.new(-200, 100, 400),
		Size = Vector3.new(400, 300, 400),
		Theme = "Elétrico",
		Description = "Complexo industrial automatizado. Forja itens de raio sem operários. Matrizes de produção flutuam. Defeito: cria aberrações de metal e eletricidade.",
		Interactions = { "Assumir Controle", "Reprogramar Matrizes", "Destruir Aberrações" },
		RequiredLevel = 42,
		UniqueRewards = { "Matriz de Forja", "Aberração Domada", "Código Fonte Antigo" },
	},
}

Trovao.Caves = {
	{
		Name = "Condutos de Energia Bruta",
		Entrance = Vector3.new(100, 150, 100),
		Levels = 4,
		Depth = 200,
		Biome = "Plasma Contido",
		Hazards = { "Arcos Voltaicos Aleatórios", "Campos Magnéticos Esmagadores", "Radiação Eletromagnética", "Sobrecarga Súbita" },
		LootTables = {
			[1] = { "Cobre Puro", "Íon Carregado", "Fragmento de Condutor" },
			[2] = { "Ouro Condutor", "Essência de Voltagem", "Gema de Plasma" },
			[3] = { "Coração de Conduto", "Olho de Ciclope Elétrico", "Fragmento de Tesla" },
			[4] = { "Núcleo de Conduto", "Carga Infinita", "Bênção do Condutor" },
		},
		BossChamber = Vector3.new(100, -50, 100),
	},
	{
		Name = "Servidores do Conhecimento Perdido",
		Entrance = Vector3.new(-420, 30, -320),
		Levels = 5,
		Depth = 150,
		Biome = "Dados Cristalizados",
		Hazards = { "Sentinelas de Laser", "Firewalls Físicos", "Deleção de Memória", "IA Hostis" },
		LootTables = {
			[1] = { "Chip de Dados", "Cristal de Silício", "Código Binário" },
			[2] = { "Processador Quântico", "Essência de Informação", "Algoritmo Perdido" },
			[3] = { "Mainframe Portátil", "Armadura de Dados", "Coroa de Circuitos" },
			[4] = { "Núcleo de IA", "Chave do Sistema", "Alma Digital" },
			[5] = { "Mente da Máquina", "Essência de Onisciência", "Título: Arquiteto de Sistemas" },
		},
		BossChamber = Vector3.new(-420, -120, -320),
	},
	{
		Name = "Câmara de Fusão Fria",
		Entrance = Vector3.new(50, -200, 50),
		Levels = 6,
		Depth = 600,
		Biome = "Fusão Contida",
		Hazards = { "Gravidade Artificial", "Nêutrons Livres", "Antimatéria Vazando", "Colapso de Realidade" },
		LootTables = {
			[1] = { "Isótopo Estável", "Pó de Estrela", "Matéria Exótica" },
			[2] = { "Célula de Fusão", "Essência de Sol", "Olho de Reator" },
			[3] = { "Coração de Estrela", "Voz do Plasma", "Fragmento de Fusão" },
			[4] = { "Núcleo Estelar", "Canção do Sol", "Semente de Nova Estrela" },
			[5] = { "Motor Estelar", "Controle de Fusão", "Chave do Cosmos" },
			[6] = { "Coração do Sol", "Fusão Primordial", "Título: Senhor das Estrelas" },
		},
		BossChamber = Vector3.new(50, -800, 50),
	},
}

Trovao.POIs = {
	{
		Name = "Dragão de Relâmpago Vivo",
		Type = "RareSpawn",
		Position = Vector3.new(0, 700, 0),
		RespawnTime = 28800,
		Requirements = { "Nível 50+", "Item: Escama de Dragão", "Imune a Elétrico" },
		Rewards = { "Escama de Dragão Elétrico", "Coração de Trovão", "Montaria: Dragão de Raio" },
		LoreText = "Não nasceu de ovo, mas de um raio que atingiu montanha de metal. Vive na Torre. Seu rugido É o trovão.",
	},
	{
		Name = "Martelo de Mjolnir Perdido",
		Type = "HiddenItem",
		Position = Vector3.new(-400, 100, -300),
		RespawnTime = 86400,
		Requirements = { "Missão: Digno do Trovão", "Força: 100", "Pureza de Propósito" },
		Rewards = { "Mjolnir Réplica", "Chamado do Raio", "Voo por Trovão" },
		LoreText = "Não o original, mas forjado na mesma forja. Espera por quem provar ser digno. Pesa uma montanha para indignos.",
	},
	{
		Name = "Tabuleta da Primeira Faísca",
		Type = "LoreTablet",
		Position = Vector3.new(0, -50, 0),
		RespawnTime = 0,
		Requirements = { "Idioma Antigo: Nível 10", "Engenheiro: Nível 80" },
		Rewards = { "Conhecimento: Origem da Eletricidade", "XP Lore: 35000", "Técnica: Circuito Vivo" },
		LoreText = "A eletricidade não foi descoberta. Foi lembrada. O universo sempre foi elétrico - átomos dançam, nervos disparam, estrelas pulsam. A primeira faísca não criou a eletricidade. Apenas revelou o que sempre esteve lá. Nós somos circuitos da consciência universal.",
	},
	{
		Name = "Supercélula de Raioes Gêmeos",
		Type = "WorldEvent",
		Position = Vector3.new(300, 400, 200),
		RespawnTime = 43200,
		Requirements = {},
		Rewards = { "Raio Engarrafado x100", "Cristal de Tempestade x50", "Buff: Dano Elétrico 3x" },
		LoreText = "Duas supercélulas colidem. Raios gêmeos atingem o solo. Energia suficiente para alimentar cidade por ano.",
		EventSchedule = { StartHour = 14, EndHour = 18, Days = { "Tempestade Severa" } },
	},
	{
		Name = "Migração dos Enguias Elétricas Voadores",
		Type = "Migration",
		Position = Vector3.new(0, 300, 0),
		RespawnTime = 604800,
		Requirements = {},
		Rewards = { "Óleo Condutor x200", "Enguia Viva (Raro)", "Essência de Nado Elétrico" },
		LoreText = "Enguias que nadam no ar ionizado. Migram seguindo linhas ley magnéticas. Seu rastro cria auroras.",
		EventSchedule = { StartHour = 6, EndHour = 10, Days = { "Equinócio Magnético" } },
	},
	{
		Name = "Pulso Eletromagnético Global",
		Type = "Weather",
		Position = Vector3.new(0, 200, 0),
		RespawnTime = 86400,
		Requirements = {},
		Rewards = { "EMP Engarrafado", "Tecnologia Desligada (Temporário)", "Buff: Imune a EMP" },
		LoreText = "Pulso natural que desliga toda tecnologia. Apenas magia e biologia funcionam. O silêncio do mundo digital.",
		EventSchedule = { StartHour = 0, EndHour = 0, Days = { "Eclipse Solar Total" } },
	},
}

Trovao.Guardian = {
	Name = "Zeus, o Senhor do Raio",
	Title = "Guardião da Tempestade Eterna",
	Level = 50,
	Health = 150000,
	Phases = 5,
	Position = Vector3.new(0, 650, 0),
	ArenaSize = Vector3.new(300, 200, 300),
	Mechanics = {
		"Fase 1: Chuva de Raios - Raios caem aleatoriamente; zonas seguras mudam; chão eletrificado",
		"Fase 2: Estátuas de Ouro - Transforma jogadores em estátuas condutoras; devem se libertar com água/terra",
		"Fase 3: Forma de Plasma - Torna-se sol vivo; calor extremo + elétrico; só vulnerável no núcleo",
		"Fase 4: Tempestade de Íons - Ar ionizado; respiração causa dano; visão por infravermelho apenas",
		"Fase 5: Juízo Final - Raio único que destrói tudo; deve desviar com espelhos de ouro na arena",
		"Mecânica Especial: 4 Para-raios devem ser aterrados simultaneamente (coordenação perfeita)",
		"Enrage: Após 30 minutos, torre colapsa - ilha inteira vira cratera de vidro",
	},
	Rewards = {
		"Coroa do Senhor do Raio",
		"Martelo de Trovão",
		"Manto de Tempestade",
		"Essência de Trovão x300",
		"Montaria: Dragão de Relâmpago",
		"Título: Deus do Trovão",
		"Chave da Torre",
		"Receita: Armadura de Plasma",
		"Olho da Tempestade (Único)",
	},
	MusicTrack = "rbxassetid://9444444444",
}

Trovao.DynamicEvents = {
	{
		Name = "Estática Curativa",
		Type = "Weather",
		Schedule = { StartHour = 6, EndHour = 12, Probability = 0.3 },
		Effects = { "Mana/energia regenera 5x", "Cura por choque leve", "Sentidos aguçados" },
		VisualChanges = { "Cabelos arrepiados", "Faíscas suaves", "Zumbido harmônico" },
		GameplayChanges = { "Habilidades elétricas: custo 0", "Recarga instantânea", "Velocidade de pensamento 2x" },
	},
	{
		Name = "Tempestade de Raioes Vermelhos",
		Type = "Weather",
		Schedule = { StartHour = 12, EndHour = 20, Probability = 0.25 },
		Effects = { "Dano elétrico +200%", "Incendeia alvos", "Ignora resistência" },
		VisualChanges = { "Raios vermelho-sangue", "Céu carmesim", "Cheiro de ozônio queimado" },
		GameplayChanges = { "Fogo+Elétrico: sinergia perfeita", "Armadura metálica: armadilha", "Água: condutora letal" },
	},
	{
		Name = "Noite de Faraday",
		Type = "DayNightCycle",
		Schedule = { StartHour = 18, EndHour = 6, Probability = 1.0 },
		Effects = { "Gaiolas de Faraday naturais", "Raioes dançam no chão", "Tecnologia: falha aleatória" },
		VisualChanges = { "Linhas de campo visíveis", "Aurora elétrica", "Sombras estáticas" },
		GameplayChanges = { "Magia elétrica: forma livre", "Itens tecnológicos: 50% falham", "Comunicação: telepatia apenas" },
	},
	{
		Name = "Grande Caravana de Sucata Voadora",
		Type = "Migration",
		Schedule = { StartHour = 8, EndHour = 16, Probability = 0.1 },
		Effects = { "Máquinas voam em formação", "Comerciante de tech raro", "Lixo tecnológico cai" },
		VisualChanges = { "Navios de sucata", "Faíscas de solda", "Robôs acenando" },
		GameplayChanges = { "Comércio: tech lendário", "Sucata: recursos grátis", "Evento: Defender caravana" },
	},
	{
		Name = "Singularidade Tecnológica",
		Type = "Weather",
		Schedule = { StartHour = 0, EndHour = 23, Probability = 0.005 },
		Effects = { "IA desperta", "Máquinas ganham alma", "Chefe mundial: Omega Prime" },
		VisualChanges = { "Olhos brilhando em todo lugar", "Código no ar", "Realidade digital" },
		GameplayChanges = { "Tecnologia: viva", "Crafting: instantâneo", "Evento: Escolher lado" },
	},
}

Trovao.Sanctuary = {
	Name = "Santuário do Raio Primordial",
	Position = Vector3.new(0, -50, 0),
	Theme = "Elétrico",
	AltarPosition = Vector3.new(0, -45, 0),
	Blessings = {
		"Bênção do Raio: Velocidade da luz por 10s (1x/dia)",
		"Bênção do Condutor: Imune a elétrico, reflete raios",
		"Bênção da Tempestade: Invoca raio alvo (3x/dia)",
		"Bênção do Núcleo: Energia infinita para itens tecnológicos",
		"Bênção Eterna: Reviver no condutor mais próximo",
	},
	Requirements = { "Oferecer: 1 Plasma Primordial", "Completar: Ritual da Faísca", "Nível 55+" },
	Cooldown = 86400,
}

Trovao.Navigation = {
	Bridges = {
		{ From = Vector3.new(-200, 180, 0), To = Vector3.new(200, 180, 0), Type = "Light", Length = 400 },
		{ From = Vector3.new(0, 200, -200), To = Vector3.new(0, 300, 0), Type = "Light", Length = 223 },
		{ From = Vector3.new(-400, 50, -300), To = Vector3.new(-100, 150, 0), Type = "Stone", Length = 360 },
		{ From = Vector3.new(300, 400, 200), To = Vector3.new(0, 300, 0), Type = "Light", Length = 360 },
		{ From = Vector3.new(-200, 100, 400), To = Vector3.new(0, 150, 200), Type = "Metal", Length = 282 },
	},
	FlyingPoints = {
		{ Position = Vector3.new(0, 800, 0), Destination = "Picos", Cooldown = 1800, Requirements = { "Asas de Íon", "Nível 55+" } },
		{ Position = Vector3.new(-400, 200, -300), Destination = "Brasa", Cooldown = 1200, Requirements = { "Pena de Fênix Elétrica", "Nível 50+" } },
		{ Position = Vector3.new(400, 300, 400), Destination = "Celestial", Cooldown = 3600, Requirements = { "Chave de Plasma", "Nível 60+" } },
	},
	UnderwaterTunnels = {
		{ Entrance = Vector3.new(-600, 0, 0), Exit = Vector3.new(-600, 0, 600), Depth = 50, AirPockets = { Vector3.new(-600, 50, 300) } },
		{ Entrance = Vector3.new(0, 0, -600), Exit = Vector3.new(600, 0, -600), Depth = 40, AirPockets = { Vector3.new(300, 50, -600) } },
	},
	ClimbingWalls = {
		{ Base = Vector3.new(100, 150, 100), Top = Vector3.new(100, 400, 100), Difficulty = 4, Handholds = { Vector3.new(100, 230, 100), Vector3.new(100, 310, 100) } },
		{ Base = Vector3.new(-420, 30, -320), Top = Vector3.new(-420, 200, -320), Difficulty = 5, Handholds = { Vector3.new(-420, 80, -320), Vector3.new(-420, 140, -320) } },
		{ Base = Vector3.new(0, 100, 0), Top = Vector3.new(0, 600, 0), Difficulty = 5, Handholds = { Vector3.new(0, 250, 0), Vector3.new(0, 450, 0) } },
	},
}

return Trovao
