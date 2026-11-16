--!strict
-- RECIFE (Água) - Oceano: palácio de coral, abismo cristalino, jardim das pérolas, cidade afundada, caverna de bolhas
-- The Reef Isle - Ocean depths, coral palaces, crystal abyss

export type RecifeLandmark = {
	Name: string,
	Position: Vector3,
	Size: Vector3,
	Theme: "Água",
	Description: string,
	Interactions: { string },
	RequiredLevel: number,
	UniqueRewards: { string },
}

export type RecifeCave = {
	Name: string,
	Entrance: Vector3,
	Levels: number,
	Depth: number,
	Biome: string,
	Hazards: { string },
	LootTables: { [number]: { string } },
	BossChamber: Vector3?,
}

export type RecifePOI = {
	Name: string,
	Type: "RareSpawn" | "HiddenItem" | "LoreTablet" | "WorldEvent",
	Position: Vector3,
	RespawnTime: number,
	Requirements: { string }?,
	Rewards: { string },
	LoreText: string?,
	EventSchedule: { StartHour: number, EndHour: number, Days: { string } }?,
}

export type RecifeGuardian = {
	Name: "Thalassa, Rainha dos Mares",
	Title: "Guardião das Profundezas",
	Level: 35,
	Health: 75000,
	Phases: 4,
	Position: Vector3,
	ArenaSize: Vector3,
	Mechanics: { string },
	Rewards: { string },
	MusicTrack: string,
}

export type RecifeDynamicEvent = {
	Name: string,
	Type: "Weather" | "Migration" | "DayNightCycle",
	Schedule: { StartHour: number, EndHour: number, Probability: number },
	Effects: { string },
	VisualChanges: { string },
	GameplayChanges: { string },
}

export type RecifeSanctuary = {
	Name: "Santuário das Marés",
	Position: Vector3,
	Theme: "Água",
	AltarPosition: Vector3,
	Blessings: { string },
	Requirements: { string },
	Cooldown: number,
}

export type RecifeNavigation = {
	Bridges: { { From: Vector3, To: Vector3, Type: "Wood" | "Stone" | "Living" | "Light", Length: number } },
	FlyingPoints: { { Position: Vector3, Destination: string, Cooldown: number, Requirements: { string } } },
	UnderwaterTunnels: { { Entrance: Vector3, Exit: Vector3, Depth: number, AirPockets: { Vector3 } } },
	ClimbingWalls: { { Base: Vector3, Top: Vector3, Difficulty: number, Handholds: { Vector3 } } },
}

local Recife = {}

Recife.Name = "Recife"
Recife.DisplayName = "Recife - A Ilha do Oceano Eterno"
Recife.Element = "Água"
Recife.RecommendedLevel = 20
Recife.MaxLevel = 50
Recife.Size = Vector3.new(2000, 1000, 2000)
Recife.SpawnPoint = Vector3.new(0, 30, 0)
Recife.Skybox = {
	Day = "rbxassetid://3000000001",
	Dawn = "rbxassetid://3000000002",
	Night = "rbxassetid://3000000003",
}
Recife.AmbientSound = "rbxassetid://3111111111"
Recife.MusicTracks = {
	Exploration = "rbxassetid://3222222222",
	Combat = "rbxassetid://3333333333",
	Boss = "rbxassetid://3444444444",
	Sanctuary = "rbxassetid://3555555555",
}

Recife.Landmarks = {
	{
		Name = "Palácio de Coral Vivo",
		Position = Vector3.new(0, -50, 0),
		Size = Vector3.new(500, 200, 500),
		Theme = "Água",
		Description = "Palácio magnífico construído de coral vivo que cresce e se repara. A rainha dos mares reside aqui.",
		Interactions = { "Audiência com a Rainha", "Tocar Coral Cantante", "Beber Água da Vida" },
		RequiredLevel = 25,
		UniqueRewards = { "Coroa de Coral", "Pérola da Sabedoria", "Cetro das Marés" },
	},
	{
		Name = "Abismo Cristalino",
		Position = Vector3.new(400, -300, 400),
		Size = Vector3.new(300, 600, 300),
		Theme = "Água",
		Description = "Fenda profunda onde cristais bioluminescentes iluminam o escuro. Criaturas abissais nadam nas sombras.",
		Interactions = { "Mergulho Profundo", "Colher Cristais de Luz", "Comunicar com Abissais" },
		RequiredLevel = 30,
		UniqueRewards = { "Cristal Abissal", "Essência de Profundidade", "Olho do Abismo" },
	},
	{
		Name = "Jardim das Pérolas Negras",
		Position = Vector3.new(-300, -80, -300),
		Size = Vector3.new(400, 100, 400),
		Theme = "Água",
		Description = "Jardim submarino onde ostras gigantes produzem pérolas negras que guardam memórias do oceano.",
		Interactions = { "Colher Pérola de Memória", "Ouvir Canção das Ostras", "Plantar Semente de Pérola" },
		RequiredLevel = 22,
		UniqueRewards = { "Pérola Negra", "Memória do Oceano", "Semente de Nácar" },
	},
	{
		Name = "Cidade Afundada de Atlânea",
		Position = Vector3.new(-500, -150, 200),
		Size = Vector3.new(600, 200, 600),
		Theme = "Água",
		Description = "Ruínas de uma civilização antiga que adorava o mar. Edifícios intactos, guardados por constructos de coral.",
		Interactions = { "Explorar Ruínas", "Decifrar Tabletes de Água", "Despertar Guardiões" },
		RequiredLevel = 28,
		UniqueRewards = { "Tecnologia Atlante", "Tridente Perdido", "Código das Marés" },
	},
	{
		Name = "Caverna das Bolhas Eternas",
		Position = Vector3.new(200, -20, -400),
		Size = Vector3.new(200, 300, 200),
		Theme = "Água",
		Description = "Caverna cheia de bolhas que não estouram. Cada bolha contém um momento congelado no tempo.",
		Interactions = { "Estourar Bolha de Tempo", "Entrar em Bolha Grande", "Coletar Ar Primordial" },
		RequiredLevel = 35,
		UniqueRewards = { "Bolha do Tempo", "Ar dos Primórdios", "Chave do Abismo" },
	},
}

Recife.Caves = {
	{
		Name = "Túneis de Kelp Gigante",
		Entrance = Vector3.new(-100, -40, 100),
		Levels = 4,
		Depth = 150,
		Biome = "Floresta de Kelp",
		Hazards = { "Correntes Fortes", "Kelp Estrangulador", "Predadores Camuflados", "Redemoinhos" },
		LootTables = {
			[1] = { "Kelp Brilhante", "Pérola Comum", "Escama de Peixe" },
			[2] = { "Coral Medicinal", "Essência de Maré", "Gema Azul" },
			[3] = { "Coração de Kelp Ancião", "Pérola Rosa", "Fragmento de Tritão" },
			[4] = { "Raiz do Oceano", "Semente de Coral", "Bênção da Maré" },
		},
		BossChamber = Vector3.new(-100, -190, 100),
	},
	{
		Name = "Catacumbas de Atlânea",
		Entrance = Vector3.new(-550, -140, 250),
		Levels = 5,
		Depth = 250,
		Biome = "Ruínas Submersas",
		Hazards = { "Constructos de Coral", "Armadilhas Hidráulicas", "Maldição do Afogamento", "Fantomas Marinheiros" },
		LootTables = {
			[1] = { "Tijolo de Coral", "Moeda Antiga", "Pergaminho Molhado" },
			[2] = { "Estatueta de Poseidon", "Chave de Coral", "Mapa do Tesouro" },
			[3] = { "Armadura de Escamas", "Tridente de Bronze", "Olho de Kraken" },
			[4] = { "Coração da Cidade", "Cajado das Ondas", "Coroa de Atlânea" },
			[5] = { "Núcleo de Atlânea", "Chave do Abismo", "Título: Herdeiro do Mar" },
		},
		BossChamber = Vector3.new(-550, -390, 250),
	},
	{
		Name = "Fenda do Abismo",
		Entrance = Vector3.new(450, -350, 450),
		Levels = 6,
		Depth = 800,
		Biome = "Zona Hadal",
		Hazards = { "Pressão Esmagadora", "Frio Extremo", "Criaturas Abissais", "Escuridão Total" },
		LootTables = {
			[1] = { "Pedra de Pressão", "Lodo Abissal", "Dente de Tubarão" },
			[2] = { "Cristal de Profundidade", "Olho Gigante", "Essência do Vazio" },
			[3] = { "Coração Abissal", "Fragmento de Leviatã", "Pérola do Fundo" },
			[4] = { "Alma do Oceano", "Chama Azul Fria", "Semente de Vida Profunda" },
			[5] = { "Núcleo do Abismo", "Essência de Thalassa", "Chave do Núcleo Oceânico" },
			[6] = { "Coração do Mar", "Tridente do Rei", "Título: Senhor dos Abismos" },
		},
		BossChamber = Vector3.new(450, -1150, 450),
	},
}

Recife.POIs = {
	{
		Name = "Baleia Cantante Anciã",
		Type = "RareSpawn",
		Position = Vector3.new(0, -100, 0),
		RespawnTime = 21600,
		Requirements = { "Nível 30+", "Item: Concha de Chamado", "Música: Canção do Mar" },
		Rewards = { "Dente de Baleia", "Canção Antiga", "Bênção dos Cetáceos" },
		LoreText = "Esta baleia vive há milênios. Seu canto cura os feridos e acalma as tempestades.",
	},
	{
		Name = "Tridente de Poseidon",
		Type = "HiddenItem",
		Position = Vector3.new(-500, -200, 200),
		RespawnTime = 28800,
		Requirements = { "Missão: Herdeiro de Atlânea", "Chave de Coral: 3" },
		Rewards = { "Tridente de Poseidon", "Controle das Marés", "Armadura de Escamas Divinas" },
		LoreText = "Perdido quando Atlânea afundou. Espera por quem provar ser digno do mar.",
	},
	{
		Name = "Tabuleta do Grande Dilúvio",
		Type = "LoreTablet",
		Position = Vector3.new(0, -60, 0),
		RespawnTime = 0,
		Requirements = { "Idioma Antigo: Nível 5", "Respiração Subaquática: Infinita" },
		Rewards = { "Conhecimento: História dos Oceanos", "XP Lore: 10000", "Técnica: Respiração de Sereia" },
		LoreText = "Quando os deuses choraram, o mundo se afogou. Mas o mar não mata - ele preserva. Tudo que foi, ainda é, nas profundezas. O oceano lembra de tudo.",
	},
	{
		Name = "Florescência de Coral",
		Type = "WorldEvent",
		Position = Vector3.new(0, -50, 0),
		RespawnTime = 43200,
		Requirements = {},
		Rewards = { "Coral Raro x50", "Pérola x20", "Buff: Natação +100%" },
		LoreText = "Uma vez por estação, todos os corais liberam gametas simultaneamente. O oceano vira neve rosa.",
		EventSchedule = { StartHour = 6, EndHour = 10, Days = { "Equinócio de Primavera", "Equinócio de Outono" } },
	},
	{
		Name = "Migração das Tartarugas Estelares",
		Type = "Migration",
		Position = Vector3.new(-300, -20, -300),
		RespawnTime = 86400,
		Requirements = {},
		Rewards = { "Escama Estelar x30", "Casco Antigo (Raro)", "Essência de Navegação" },
		LoreText = "Tartarugas que navegam pelas estrelas. Seguem constelações subaquáticas para desovar.",
		EventSchedule = { StartHour = 20, EndHour = 4, Days = { "Lua Cheia" } },
	},
	{
		Name = "Aurora Submarina",
		Type = "Weather",
		Position = Vector3.new(400, -300, 400),
		RespawnTime = 86400,
		Requirements = {},
		Rewards = { "Luz Abissal x100", "Cristal de Aurora (Raro)", "Buff: Visão no Escuro" },
		LoreText = "Partículas carregadas do núcleo da terra criam luzes dançantes nas águas profundas.",
		EventSchedule = { StartHour = 22, EndHour = 2, Days = { "Solstício de Inverno" } },
	},
}

Recife.Guardian = {
	Name = "Thalassa, Rainha dos Mares",
	Title = "Guardião das Profundezas",
	Level = 35,
	Health = 75000,
	Phases = 4,
	Position = Vector3.new(0, -80, 0),
	ArenaSize = Vector3.new(200, 200, 200),
	Mechanics = {
		"Fase 1: Maré Crescente - Arena enche de água; plataformas de coral sobem/descem",
		"Fase 2: Invocação Abissal - Chama criaturas do abismo; escuridão total",
		"Fase 3: Forma de Tsunami - Torna-se onda viva; invulnerável exceto no olho da onda",
		"Fase 4: Oceano Interior - Cria bolhas de ar que explodem; drena oxigênio",
		"Mecânica Especial: 'Coral do Coração' deve ser protegido de 3 ondas de corrosão",
		"Enrage: Após 20 minutos, maré sobe cobrindo toda a ilha - afogamento instantâneo",
	},
	Rewards = {
		"Coroa das Marés Eternas",
		"Tridente de Thalassa",
		"Manto de Espuma do Mar",
		"Essência de Recife x150",
		"Montaria: Baleia Cantante",
		"Título: Rainha/Consorte dos Mares",
		"Chave do Abismo Cristalino",
		"Receita: Armadura de Coral Vivo",
	},
	MusicTrack = "rbxassetid://3444444444",
}

Recife.DynamicEvents = {
	{
		Name = "Maré Viva",
		Type = "Weather",
		Schedule = { StartHour = 6, EndHour = 18, Probability = 0.5 },
		Effects = { "Nível da água sobe 20m", "Correntes mudam direção", "Recursos submersos acessíveis" },
		VisualChanges = { "Água cristalina", "Raio de luz penetrando fundo", "Bolhas de ar subindo" },
		GameplayChanges = { "Natação velocidade 2x", "Mergulho: sem limite de ar", "Combate subaquático buffado" },
	},
	{
		Name = "Tempestade de Areia Submarina",
		Type = "Weather",
		Schedule = { StartHour = 12, EndHour = 20, Probability = 0.2 },
		Effects = { "Visibilidade 10%", "Dano de água +50%", "Projéteis desviados" },
		VisualChanges = { "Areia girando", "Redemoinhos visíveis", "Cores dessaturadas" },
		GameplayChanges = { "Furtividade +50%", "Rastreamento impossível", "Magia de água: custo 0" },
	},
	{
		Name = "Noite Bioluminescente",
		Type = "DayNightCycle",
		Schedule = { StartHour = 20, EndHour = 5, Probability = 1.0 },
		Effects = { "Tudo brilha", "Predadores atraídos pela luz", "Plâncton brilhante" },
		VisualChanges = { "Estrelas no mar", "Rastros de luz ao nadar", "Céu espelhado na água" },
		GameplayChanges = { "Visão perfeita subaquática", "Coleta: itens brilham", "Rituais lunares subaquáticos" },
	},
	{
		Name = "Grande Migração dos Cardumes",
		Type = "Migration",
		Schedule = { StartHour = 5, EndHour = 9, Probability = 0.15 },
		Effects = { "Milhões de peixes", "Predadores em frenesi", "Água ferve de vida" },
		VisualChanges = { "Prata viva no mar", "Arco-íris de escamas", "Pássaros mergulhando" },
		GameplayChanges = { "Pesca: lendários possíveis", "Caça: chefes aparecem", "Evento: Surfar cardume" },
	},
	{
		Name = "Ressurgência Nutritiva",
		Type = "Weather",
		Schedule = { StartHour = 0, EndHour = 23, Probability = 0.05 },
		Effects = { "Nutrientes do fundo sobem", "Explosão de vida", "Novos corais nascem" },
		VisualChanges = { "Água verde-esmeralda", "Bolhas de gás", "Crescimento visível" },
		GameplayChanges = { "Todos recursos resetam", "Corais crescem 10x", "Chefe mundial: Kraken Primordial" },
	},
}

Recife.Sanctuary = {
	Name = "Santuário das Marés",
	Position = Vector3.new(0, -60, 0),
	Theme = "Água",
	AltarPosition = Vector3.new(0, -55, 0),
	Blessings = {
		"Bênção da Maré: Respiração subaquática infinita por 1h",
		"Bênção do Coral: Regeneração total em água",
		"Bênção da Corrente: Velocidade de natação 3x",
		"Bênção do Abismo: Imune a pressão/frio",
		"Bênção Eterna: Reviver na maré mais próxima",
	},
	Requirements = { "Oferecer: 1 Pérola Negra", "Completar: Ritual das Marés", "Nível 30+" },
	Cooldown = 86400,
}

Recife.Navigation = {
	Bridges = {
		{ From = Vector3.new(-200, 10, 0), To = Vector3.new(200, 10, 0), Type = "Living", Length = 400 },
		{ From = Vector3.new(0, 20, -200), To = Vector3.new(0, -50, 0), Type = "Light", Length = 250 },
		{ From = Vector3.new(-500, 0, 200), To = Vector3.new(-200, 0, -100), Type = "Stone", Length = 424 },
		{ From = Vector3.new(400, -50, 400), To = Vector3.new(100, -50, 100), Type = "Living", Length = 424 },
		{ From = Vector3.new(200, 0, -400), To = Vector3.new(200, -100, -200), Type = "Stone", Length = 223 },
	},
	FlyingPoints = {
		{ Position = Vector3.new(0, 100, 0), Destination = "Pantano", Cooldown = 1800, Requirements = { "Asas de Vapor", "Nível 35+" } },
		{ Position = Vector3.new(-300, 50, -300), Destination = "Alvorecer", Cooldown = 1200, Requirements = { "Pena de Albatroz", "Nível 20+" } },
		{ Position = Vector3.new(400, 80, 400), Destination = "Celestial", Cooldown = 3600, Requirements = { "Chave de Pérola", "Nível 40+" } },
	},
	UnderwaterTunnels = {
		{ Entrance = Vector3.new(-800, -50, 0), Exit = Vector3.new(-800, -50, 800), Depth = 200, AirPockets = { Vector3.new(-800, 0, 400) } },
		{ Entrance = Vector3.new(0, -50, -800), Exit = Vector3.new(800, -50, -800), Depth = 150, AirPockets = { Vector3.new(400, 0, -800) } },
		{ Entrance = Vector3.new(400, -300, 400), Exit = Vector3.new(400, -800, 400), Depth = 500, AirPockets = { Vector3.new(400, -550, 400) } },
	},
	ClimbingWalls = {
		{ Base = Vector3.new(-550, -140, 250), Top = Vector3.new(-550, 50, 250), Difficulty = 3, Handholds = { Vector3.new(-550, -50, 250), Vector3.new(-550, 0, 250) } },
		{ Base = Vector3.new(450, -350, 450), Top = Vector3.new(450, -50, 450), Difficulty = 5, Handholds = { Vector3.new(450, -250, 450), Vector3.new(450, -150, 450) } },
		{ Base = Vector3.new(200, -20, -400), Top = Vector3.new(200, 100, -400), Difficulty = 4, Handholds = { Vector3.new(200, 20, -400), Vector3.new(200, 60, -400) } },
	},
}

return Recife
