--!strict
-- BRASA (Fogo) - Vulcão: caldeira, forja anciã, túneis de magma, rio de lava, mina de basalto
-- The Ember Isle - Volcanic fury, ancient forges, rivers of fire

export type BrasaLandmark = {
	Name: string,
	Position: Vector3,
	Size: Vector3,
	Theme: "Fogo",
	Description: string,
	Interactions: { string },
	RequiredLevel: number,
	UniqueRewards: { string },
}

export type BrasaCave = {
	Name: string,
	Entrance: Vector3,
	Levels: number,
	Depth: number,
	Biome: string,
	Hazards: { string },
	LootTables: { [number]: { string } },
	BossChamber: Vector3?,
}

export type BrasaPOI = {
	Name: string,
	Type: "RareSpawn" | "HiddenItem" | "LoreTablet" | "WorldEvent",
	Position: Vector3,
	RespawnTime: number,
	Requirements: { string }?,
	Rewards: { string },
	LoreText: string?,
	EventSchedule: { StartHour: number, EndHour: number, Days: { string } }?,
}

export type BrasaGuardian = {
	Name: "Piroclasto, Senhor das Cinzas",
	Title: "Guardião do Vulcão Eterno",
	Level: 35,
	Health: 75000,
	Phases: 4,
	Position: Vector3,
	ArenaSize: Vector3,
	Mechanics: { string },
	Rewards: { string },
	MusicTrack: string,
}

export type BrasaDynamicEvent = {
	Name: string,
	Type: "Weather" | "Migration" | "DayNightCycle",
	Schedule: { StartHour: number, EndHour: number, Probability: number },
	Effects: { string },
	VisualChanges: { string },
	GameplayChanges: { string },
}

export type BrasaSanctuary = {
	Name: "Santuário da Chama Eterna",
	Position: Vector3,
	Theme: "Fogo",
	AltarPosition: Vector3,
	Blessings: { string },
	Requirements: { string },
	Cooldown: number,
}

export type BrasaNavigation = {
	Bridges: { { From: Vector3, To: Vector3, Type: "Wood" | "Stone" | "Living" | "Light", Length: number } },
	FlyingPoints: { { Position: Vector3, Destination: string, Cooldown: number, Requirements: { string } } },
	UnderwaterTunnels: { { Entrance: Vector3, Exit: Vector3, Depth: number, AirPockets: { Vector3 } } },
	ClimbingWalls: { { Base: Vector3, Top: Vector3, Difficulty: number, Handholds: { Vector3 } } },
}

local Brasa = {}

Brasa.Name = "Brasa"
Brasa.DisplayName = "Brasa - A Ilha do Vulcão Eterno"
Brasa.Element = "Fogo"
Brasa.RecommendedLevel = 20
Brasa.MaxLevel = 50
Brasa.Size = Vector3.new(1800, 800, 1800)
Brasa.SpawnPoint = Vector3.new(0, 120, 0)
Brasa.Skybox = {
	Day = "rbxassetid://2000000001",
	Dawn = "rbxassetid://2000000002",
	Night = "rbxassetid://2000000003",
}
Brasa.AmbientSound = "rbxassetid://2111111111"
Brasa.MusicTracks = {
	Exploration = "rbxassetid://2222222223",
	Combat = "rbxassetid://2333333333",
	Boss = "rbxassetid://2444444444",
	Sanctuary = "rbxassetid://2555555555",
}

Brasa.Landmarks = {
	{
		Name = "Caldeira do Coração Ardente",
		Position = Vector3.new(0, 200, 0),
		Size = Vector3.new(600, 300, 600),
		Theme = "Fogo",
		Description = "Uma cratera vulcânica massiva onde lava borbulha eternamente. O calor é intenso o suficiente para derreter adamantita.",
		Interactions = { "Banho de Lava (Imune a Fogo)", "Forjar com Magma Puro", "Oferenda ao Vulcão" },
		RequiredLevel = 25,
		UniqueRewards = { "Coração de Magma", "Essência de Piroclasto", "Cinzas Sagradas" },
	},
	{
		Name = "Forja Anciã dos Titãs",
		Position = Vector3.new(-400, 150, -200),
		Size = Vector3.new(300, 100, 300),
		Theme = "Fogo",
		Description = "Forja lendária onde os Titãs forjaram as armas dos deuses. Martelos flutuam, batendo em bigornas invisíveis.",
		Interactions = { "Forjar Arma Lendária", "Temperar Alma", "Aprender Técnica Perdida" },
		RequiredLevel = 30,
		UniqueRewards = { "Martelo dos Titãs", "Bigorna Estelar", "Técnica: Haveira Solar" },
	},
	{
		Name = "Rio de Lava Viva",
		Position = Vector3.new(300, 100, 300),
		Size = Vector3.new(800, 50, 200),
		Theme = "Fogo",
		Description = "Rio de lava que flui como água, mas queima com a fúria de mil sóis. Criaturas de fogo nadam nele.",
		Interactions = { "Nadar na Lava (Requer Imunidade)", "Pescar Peixes de Magma", "Coletar Ouro Derretido" },
		RequiredLevel = 20,
		UniqueRewards = { "Escama de Peixe de Lava", "Pepita de Ouro Puro", "Essência de Rio Ígneo" },
	},
	{
		Name = "Mina de Basalto Negro",
		Position = Vector3.new(-200, 50, 400),
		Size = Vector3.new(400, 300, 400),
		Theme = "Fogo",
		Description = "Minas profundas onde basalto negro é extraído. Veios de obsidiana brilham nas paredes.",
		Interactions = { "Minerar Basalto", "Extrair Obsidiana", "Despertar Golem de Pedra" },
		RequiredLevel = 22,
		UniqueRewards = { "Basalto Primordial", "Obsidiana Estelar", "Núcleo de Golem" },
	},
	{
		Name = "Túneis de Magma Primordial",
		Position = Vector3.new(100, 0, -300),
		Size = Vector3.new(200, 500, 200),
		Theme = "Fogo",
		Description = "Túneis escavados pelo magma mais antigo do mundo. Paredes pulsam com calor vivo.",
		Interactions = { "Comungar com Magma", "Absorver Calor Primordial", "Encontrar Núcleo da Terra" },
		RequiredLevel = 35,
		UniqueRewards = { "Sangue da Terra", "Cristal de Magma", "Chave do Coração Vulcânico" },
	},
}

Brasa.Caves = {
	{
		Name = "Fendas Incandescentes",
		Entrance = Vector3.new(-150, 130, -100),
		Levels = 4,
		Depth = 200,
		Biome = "Fissuras Vulcânicas",
		Hazards = { "Erupções Súbitas", "Gás Tóxico", "Piso Instável", "Choque Térmico" },
		LootTables = {
			[1] = { "Carvão Eterno", "Enxofre Puro", "Pedra de Fogo" },
			[2] = { "Minério de Mithral", "Gema Ígnea", "Cinza Abençoada" },
			[3] = { "Língua de Dragão", "Cristal de Caldeira", "Essência de Vulcão" },
			[4] = { "Coração de Fênix", "Chama que Não Apaga", "Fragmento de Ifrit" },
		},
		BossChamber = Vector3.new(-150, -70, -100),
	},
	{
		Name = "Catacumbas da Forja Perdida",
		Entrance = Vector3.new(-450, 140, -250),
		Levels = 5,
		Depth = 300,
		Biome = "Ruínas Metalúrgicas",
		Hazards = { "Constructos de Ferro", "Armadilhas de Indução", "Vapor Superaquecido", "Maldição da Ganância" },
		LootTables = {
			[1] = { "Sucata Anciã", "Óleo de Forja", "Desenho Desgastado" },
			[2] = { "Liga de Titã", "Martelo Rúnico", "Perícia de Ferreiro" },
			[3] = { "Alma de Arma", "Bigorna Portátil", "Fogo de Forja Eterno" },
			[4] = { "Espírito do Ferreiro", "Técnica: Dobra Estelar", "Coração de Forja" },
			[5] = { "Martelo da Criação", "Bigorna do Destino", "Chave da Forja Suprema" },
		},
		BossChamber = Vector3.new(-450, -160, -250),
	},
	{
		Name = "Núcleo do Vulcão",
		Entrance = Vector3.new(50, 180, 50),
		Levels = 6,
		Depth = 500,
		Biome = "Coração Ígneo",
		Hazards = { "Pressão Extrema", "Magma Vivo", "Elementais Primordiais", "Distorsão Temporal" },
		LootTables = {
			[1] = { "Basalto Fundido", "Gema do Núcleo", "Cinza Primordial" },
			[2] = { "Cristal de Pressão", "Sangue de Vulcão", "Essência de Caldeira" },
			[3] = { "Núcleo Menor", "Olho de Magma", "Fragmento de Criação" },
			[4] = { "Coração Vulcânico", "Chama Primordial", "Semente de Estrela" },
			[5] = { "Núcleo Maior", "Essência de Ifrit", "Chave do Mundo Inferior" },
			[6] = { "Coração do Mundo", "Chama Eterna", "Título: Senhor dos Vulcões" },
		},
		BossChamber = Vector3.new(50, -320, 50),
	},
}

Brasa.POIs = {
	{
		Name = "Fênix Cinzenta",
		Type = "RareSpawn",
		Position = Vector3.new(0, 250, 0),
		RespawnTime = 10800,
		Requirements = { "Nível 30+", "Item: Pena de Fênix", "Missão: Cinzas Renascidas" },
		Rewards = { "Pena de Fênix Cinzenta", "Lágrima de Fogo", "Bênção da Reencarnação" },
		LoreText = "Diferente de suas irmãs douradas, esta Fênix renasce das cinzas frias, não do fogo.",
	},
	{
		Name = "Coração de Obsidiana",
		Type = "HiddenItem",
		Position = Vector3.new(-300, 20, 350),
		RespawnTime = 14400,
		Requirements = { "Ferramenta: Picareta de Diamante", "Nível de Mineração 50+" },
		Rewards = { "Coração de Obsidiana", "Essência de Terra/Fogo", "Receita: Armadura de Obsidiana" },
		LoreText = "Um pedaço de obsidiana que pulsa como um coração. Dizem ser o olho de um deus adormecido.",
	},
	{
		Name = "Tabuleta do Primeiro Fogo",
		Type = "LoreTablet",
		Position = Vector3.new(-380, 180, -180),
		RespawnTime = 0,
		Requirements = { "Idioma Antigo: Nível 5", "Resistência a Fogo: 100%" },
		Rewards = { "Conhecimento: Origem do Fogo", "XP Lore: 10000", "Técnica: Respiração de Dragão" },
		LoreText = "O fogo não nasceu da madeira, nem da pedra. Nasceu da vontade. O primeiro a querer, a desejar, a arder - esse foi o primeiro fogo. E ele ainda queima aqui, esperando quem ouse tocá-lo.",
	},
	{
		Name = "Erupção Sincronizada",
		Type = "WorldEvent",
		Position = Vector3.new(0, 200, 0),
		RespawnTime = 21600,
		Requirements = {},
		Rewards = { "Cinza Vulcânica x100", "Minério Raro x20", "Buff: Poder de Fogo +100%" },
		LoreText = "A cada 6 horas, o vulcão entra em ressonância com o núcleo do planeta.",
		EventSchedule = { StartHour = 0, EndHour = 0, Days = { "Todos" } },
	},
	{
		Name = "Migração dos Salamandros de Magma",
		Type = "Migration",
		Position = Vector3.new(300, 100, 300),
		RespawnTime = 43200,
		Requirements = {},
		Rewards = { "Escama de Salamandro x50", "Essência de Fogo Puro", "Ovo de Salamandro (Raro)" },
		LoreText = "Salamandros nadam contra a corrente do rio de lava para desovar nas nascentes.",
		EventSchedule = { StartHour = 14, EndHour = 18, Days = { "Solstício", "Equinócio" } },
	},
	{
		Name = "Chuva de Meteoros de Ferro",
		Type = "Weather",
		Position = Vector3.new(-200, 100, 400),
		RespawnTime = 86400,
		Requirements = {},
		Rewards = { "Ferro Estelar x100", "Meteoro Intacto (Raro)", "Buff: Forja Mestre" },
		LoreText = "A mina atrai meteoros ricos em metal. O céu chora ferro puro.",
		EventSchedule = { StartHour = 22, EndHour = 4, Days = { "Lua Nova" } },
	},
}

Brasa.Guardian = {
	Name = "Piroclasto, Senhor das Cinzas",
	Title = "Guardião do Vulcão Eterno",
	Level = 35,
	Health = 75000,
	Phases = 4,
	Position = Vector3.new(0, 220, 0),
	ArenaSize = Vector3.new(150, 100, 150),
	Mechanics = {
		"Fase 1: Chuva de Cinzas - Cinzas quentes caem, criando zonas de dano e visão reduzida",
		"Fase 2: Fluxo de Lava - A arena se enche de lava; plataformas flutuam",
		"Fase 3: Forma de Magma - Torna-se magma puro, imune a físico, vulnerável a água/gelo",
		"Fase 4: Supernova - Explosão final massiva; jogadores devem usar escudos de cinza",
		"Mecânica Especial: 'Coração Vulcânico' no centro deve ser resfriado 3 vezes",
		"Enrage: Após 20 minutos, erupção total - ilha inteira vira zona de dano letal",
	},
	Rewards = {
		"Coroa de Cinzas Eternas",
		"Lâmina de Magma Vivo",
		"Manto do Vulcão",
		"Essência de Brasa x150",
		"Montaria: Fênix Cinzenta",
		"Título: Senhor das Cinzas",
		"Chave do Núcleo Vulcânico",
		"Receita: Armadura de Piroclasto",
	},
	MusicTrack = "rbxassetid://2444444444",
}

Brasa.DynamicEvents = {
	{
		Name = "Névoa de Cinzas",
		Type = "Weather",
		Schedule = { StartHour = 6, EndHour = 10, Probability = 0.4 },
		Effects = { "Visibilidade 50%", "Dano de fogo +25%", "Cura reduzida 50%" },
		VisualChanges = { "Cinzas caindo", "Céu vermelho-alaranjado", "Partículas brilhantes" },
		GameplayChanges = { "Furtividade em cinzas +40%", "Rastreamento prejudicado", "Fogo se espalha mais rápido" },
	},
	{
		Name = "Onda de Calor Extrema",
		Type = "Weather",
		Schedule = { StartHour = 11, EndHour = 16, Probability = 0.3 },
		Effects = { "Stamina drena 2x", "Água evapora", "Metal queima ao toque" },
		VisualChanges = { "Ar distorcendo", "Mirage no horizonte", "Brilho intenso no solo" },
		GameplayChanges = { "Consumo de água 3x", "Armas metálicas causam queimadura", "Armadura pesada: superaquecimento" },
	},
	{
		Name = "Noite de Brasas",
		Type = "DayNightCycle",
		Schedule = { StartHour = 19, EndHour = 5, Probability = 1.0 },
		Effects = { "Lava brilha mais", "Criaturas de fogo +50% poder", "Sombras queimam" },
		VisualChanges = { "Lava iluminando tudo", "Estrelas refletindo na lava", "Aurora vermelha" },
		GameplayChanges = { "Visão noturna térmica", "Forja: sucesso garantido", "Rituais de fogo disponíveis" },
	},
	{
		Name = "Grande Erupção",
		Type = "Weather",
		Schedule = { StartHour = 0, EndHour = 23, Probability = 0.02 },
		Effects = { "Lava sobe 50 metros", "Novas cavernas abrem", "Chefe mundial: Ifrit Primordial" },
		VisualChanges = { "Coluna de cinzas no céu", "Rios de lava novos", "Céu escurecido" },
		GameplayChanges = { "Mapa muda permanentemente", "Novos recursos expostos", "Evacuação necessária" },
	},
	{
		Name = "Ciclo da Forja",
		Type = "DayNightCycle",
		Schedule = { StartHour = 8, EndHour = 20, Probability = 0.2 },
		Effects = { "Forja Anciã ativa", "Martelos batem sozinhos", "Armas ganham alma" },
		VisualChanges = { "Faíscas douradas no ar", "Som de martelada rítmica", "Luz dourada nas janelas" },
		GameplayChanges = { "Forja: custo 50%", "Qualidade +1 tier", "Armas lendárias possíveis" },
	},
}

Brasa.Sanctuary = {
	Name = "Santuário da Chama Eterna",
	Position = Vector3.new(-380, 180, -180),
	Theme = "Fogo",
	AltarPosition = Vector3.new(-380, 185, -180),
	Blessings = {
		"Bênção da Pirâmide: Imune a fogo/queimadura por 1h",
		"Bênção da Forja: Próxima forja garante tier Lendário",
		"Bênção do Vulcão: Controle de lava temporário",
		"Bênção de Ifrit: Forma de fogo por 5min",
		"Bênção Eterna: Reviver em cinzas uma vez por dia",
	},
	Requirements = { "Oferecer: 1 Coração de Magma", "Completar: Prova do Fogo", "Nível 30+" },
	Cooldown = 86400,
}

Brasa.Navigation = {
	Bridges = {
		{ From = Vector3.new(-200, 120, 0), To = Vector3.new(200, 120, 0), Type = "Stone", Length = 400 },
		{ From = Vector3.new(0, 150, -200), To = Vector3.new(0, 200, 0), Type = "Stone", Length = 250 },
		{ From = Vector3.new(-400, 140, -200), To = Vector3.new(-100, 140, 100), Type = "Stone", Length = 424 },
		{ From = Vector3.new(300, 100, 300), To = Vector3.new(-100, 100, 300), Type = "Stone", Length = 400 },
		{ From = Vector3.new(100, 80, -300), To = Vector3.new(100, 180, -50), Type = "Stone", Length = 269 },
	},
	FlyingPoints = {
		{ Position = Vector3.new(0, 300, 0), Destination = "Picos", Cooldown = 1800, Requirements = { "Asas de Cinza", "Nível 35+" } },
		{ Position = Vector3.new(-400, 200, -200), Destination = "Dunas", Cooldown = 1200, Requirements = { "Tapete Voador", "Nível 25+" } },
		{ Position = Vector3.new(400, 150, 400), Destination = "Trovao", Cooldown = 3600, Requirements = { "Chave Ígnea", "Nível 40+" } },
	},
	UnderwaterTunnels = {
		{ Entrance = Vector3.new(-600, -50, 0), Exit = Vector3.new(-600, -50, 600), Depth = 100, AirPockets = { Vector3.new(-600, 0, 300) } },
		{ Entrance = Vector3.new(0, -50, -600), Exit = Vector3.new(600, -50, -600), Depth = 80, AirPockets = { Vector3.new(300, 0, -600) } },
	},
	ClimbingWalls = {
		{ Base = Vector3.new(-450, 130, -250), Top = Vector3.new(-450, 250, -250), Difficulty = 4, Handholds = { Vector3.new(-450, 170, -250), Vector3.new(-450, 210, -250) } },
		{ Base = Vector3.new(50, 160, 50), Top = Vector3.new(50, 300, 50), Difficulty = 5, Handholds = { Vector3.new(50, 200, 50), Vector3.new(50, 250, 50) } },
		{ Base = Vector3.new(300, 80, 300), Top = Vector3.new(300, 200, 300), Difficulty = 3, Handholds = { Vector3.new(300, 120, 300), Vector3.new(300, 160, 300) } },
	},
}

return Brasa
