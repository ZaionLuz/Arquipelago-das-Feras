--!strict
-- DUNAS (Terra) - Grande Pirâmide, oásis esquecido, cânion dos ventos, templo enterrado, dunas cantantes
-- The Dunes Isle - Ancient pyramids, singing sands, buried secrets

export type DunasLandmark = {
	Name: string,
	Position: Vector3,
	Size: Vector3,
	Theme: "Terra",
	Description: string,
	Interactions: { string },
	RequiredLevel: number,
	UniqueRewards: { string },
}

export type DunasCave = {
	Name: string,
	Entrance: Vector3,
	Levels: number,
	Depth: number,
	Biome: string,
	Hazards: { string },
	LootTables: { [number]: { string } },
	BossChamber: Vector3?,
}

export type DunasPOI = {
	Name: string,
	Type: "RareSpawn" | "HiddenItem" | "LoreTablet" | "WorldEvent",
	Position: Vector3,
	RespawnTime: number,
	Requirements: { string }?,
	Rewards: { string },
	LoreText: string?,
	EventSchedule: { StartHour: number, EndHour: number, Days: { string } }?,
}

export type DunasGuardian = {
	Name: "Ra, O Escaravelho Solar",
	Title: "Guardião das Areias Eternas",
	Level: 40,
	Health: 100000,
	Phases: 4,
	Position: Vector3,
	ArenaSize: Vector3,
	Mechanics: { string },
	Rewards: { string },
	MusicTrack: string,
}

export type DunasDynamicEvent = {
	Name: string,
	Type: "Weather" | "Migration" | "DayNightCycle",
	Schedule: { StartHour: number, EndHour: number, Probability: number },
	Effects: { string },
	VisualChanges: { string },
	GameplayChanges: { string },
}

export type DunasSanctuary = {
	Name: "Santuário do Sol Oculto",
	Position: Vector3,
	Theme: "Terra",
	AltarPosition: Vector3,
	Blessings: { string },
	Requirements: { string },
	Cooldown: number,
}

export type DunasNavigation = {
	Bridges: { { From: Vector3, To: Vector3, Type: "Wood" | "Stone" | "Living" | "Light", Length: number } },
	FlyingPoints: { { Position: Vector3, Destination: string, Cooldown: number, Requirements: { string } } },
	UnderwaterTunnels: { { Entrance: Vector3, Exit: Vector3, Depth: number, AirPockets: { Vector3 } } },
	ClimbingWalls: { { Base: Vector3, Top: Vector3, Difficulty: number, Handholds: { Vector3 } } },
}

local Dunas = {}

Dunas.Name = "Dunas"
Dunas.DisplayName = "Dunas - A Ilha das Areias Cantantes"
Dunas.Element = "Terra"
Dunas.RecommendedLevel = 30
Dunas.MaxLevel = 60
Dunas.Size = Vector3.new(2500, 400, 2500)
Dunas.SpawnPoint = Vector3.new(0, 60, 0)
Dunas.Skybox = {
	Day = "rbxassetid://5000000001",
	Dawn = "rbxassetid://5000000002",
	Night = "rbxassetid://5000000003",
}
Dunas.AmbientSound = "rbxassetid://5111111111"
Dunas.MusicTracks = {
	Exploration = "rbxassetid://5222222222",
	Combat = "rbxassetid://5333333333",
	Boss = "rbxassetid://5444444444",
	Sanctuary = "rbxassetid://5555555555",
}

Dunas.Landmarks = {
	{
		Name = "Grande Pirâmide de Areia Viva",
		Position = Vector3.new(0, 150, 0),
		Size = Vector3.new(400, 300, 400),
		Theme = "Terra",
		Description = "Pirâmide colossal feita de areia compactada mais dura que diamante. Interior se rearranja. Câmara do faraó no topo.",
		Interactions = { "Entrar na Câmara Real", "Resolver Enigma das Areias", "Tocar o Capstone Dourado" },
		RequiredLevel = 35,
		UniqueRewards = { "Coroa do Faraó", "Cetro de Areia", "Olho de Ra" },
	},
	{
		Name = "Oásis Esquecido de Siwa",
		Position = Vector3.new(-500, 40, -300),
		Size = Vector3.new(300, 80, 300),
		Theme = "Terra",
		Description = "Oásis escondido por ilusão de areia. Água cura qualquer maldição. Palmeiras dão frutos de cristal.",
		Interactions = { "Beber Água da Vida", "Colher Fruto de Cristal", "Meditar na Sombra" },
		RequiredLevel = 30,
		UniqueRewards = { "Água de Siwa", "Fruto de Cristal", "Essência de Oásis" },
	},
	{
		Name = "Cânion dos Ventos Uivantes",
		Position = Vector3.new(400, 20, 300),
		Size = Vector3.new(200, 300, 800),
		Theme = "Terra",
		Description = "Cânion profundo onde o vento canta através de formações rochosas. Ecoa segredos do passado. Areia flui como água.",
		Interactions = { "Ouvir Canção do Vento", "Surfar Dunas Internas", "Encontrar Câmara do Eco" },
		RequiredLevel = 32,
		UniqueRewards = { "Flauta do Vento", "Areia Cantante", "Mapa dos Ecos" },
	},
	{
		Name = "Templo Enterrado de Anúbis",
		Position = Vector3.new(-200, -50, 400),
		Size = Vector3.new(300, 400, 300),
		Theme = "Terra",
		Description = "Templo completamente submerso na areia. Entrada só abre na hora certa. Guardiães mumificados patrulham corredores.",
		Interactions = { "Entrar na Hora Certa", "Pesar Coração na Balança", "Despertar Guardiães" },
		RequiredLevel = 38,
		UniqueRewards = { "Balança de Anúbis", "Chave da Duat", "Manto de Linho Sagrado" },
	},
	{
		Name = "Dunas Cantantes do Infinito",
		Position = Vector3.new(300, 80, -400),
		Size = Vector3.new(500, 100, 500),
		Theme = "Terra",
		Description = "Vasto mar de dunas que emitem som quando o vento passa. Cada duna tem nota diferente. Juntas formam sinfonia.",
		Interactions = { "Tocar Sinfonia das Dunas", "Encontrar Duna Mestra", "Enterrar Segredo" },
		RequiredLevel = 40,
		UniqueRewards = { "Harpa de Areia", "Grão Mestre", "Canção do Deserto" },
	},
}

Dunas.Caves = {
	{
		Name = "Túneis da Serpente de Areia",
		Entrance = Vector3.new(100, 50, 100),
		Levels = 4,
		Depth = 150,
		Biome = "Túneis Arenosos",
		Hazards = { "Deslizamento de Areia", "Serpentas de Vidro", "Ar Rarefeito", "Ilusões de Miragem" },
		LootTables = {
			[1] = { "Areia Vitrificada", "Escama de Serpente", "Gota de Água" },
			[2] = { "Vidro do Deserto", "Dente de Serpente", "Essência de Areia" },
			[3] = { "Coração de Dunas", "Olho de Vidro", "Fragmento de Sobek" },
			[4] = { "Escama Mestra", "Areia do Tempo", "Bênção do Deserto" },
		},
		BossChamber = Vector3.new(100, -100, 100),
	},
	{
		Name = "Catacumbas Reais",
		Entrance = Vector3.new(-50, 130, -50),
		Levels = 5,
		Depth = 250,
		Biome = "Tumbas Reais",
		Hazards = { "Múmias Reais", "Armadilhas de Sarcofago", "Maldição dos Faraós", "Gás Sagrado" },
		LootTables = {
			[1] = { "Atadura Real", "Ouro de Faraó", "Amuleto Protetor" },
			[2] = { "Espada Khopesh", "Escudo de Escaravelho", "Anel de Selo" },
			[3] = { "Máscara Funerária", "Cajado de Vizier", "Coroa Menor" },
			[4] = { "Coração do Faraó", "Livro dos Mortos", "Chave da Câmara" },
			[5] = { "Alma Real", "Essência de Imortalidade", "Título: Faraó Vivo" },
		},
		BossChamber = Vector3.new(-50, -120, -50),
	},
	{
		Name = "Profundezas do Cânion",
		Entrance = Vector3.new(420, 0, 350),
		Levels = 6,
		Depth = 500,
		Biome = "Rocha Viva",
		Hazards = { "Pedras que Cantam", "Vento Cortante", "Elementais de Areia", "Silêncio Absoluto" },
		LootTables = {
			[1] = { "Rocha Cantante", "Pó de Osso", "Cristal de Vento" },
			[2] = { "Minério Cantante", "Essência de Eco", "Gema de Som" },
			[3] = { "Coração do Cânion", "Voz da Terra", "Fragmento de Gaia" },
			[4] = { "Garganta do Mundo", "Canção Primordial", "Semente de Montanha" },
			[5] = { "Núcleo Rochoso", "Essência de Terra Pura", "Chave do Núcleo Planetário" },
			[6] = { "Coração da Terra", "Voz do Planeta", "Título: Senhor das Rochas" },
		},
		BossChamber = Vector3.new(420, -480, 350),
	},
}

Dunas.POIs = {
	{
		Name = "Fênix de Areia",
		Type = "RareSpawn",
		Position = Vector3.new(0, 200, 0),
		RespawnTime = 18000,
		Requirements = { "Nível 40+", "Item: Pena de Fênix", "Resistência a Calor: 100%" },
		Rewards = { "Pena de Fênix de Areia", "Cinza Dourada", "Bênção do Renascimento Seco" },
		LoreText = "Não nasce do fogo, mas do calor extremo da areia. Suas asas são dunas vivas.",
	},
	{
		Name = "Olho de Horus Perdido",
		Type = "HiddenItem",
		Position = Vector3.new(-200, -100, 400),
		RespawnTime = 43200,
		Requirements = { "Missão: Olho que Tudo Vê", "Chave da Duat", "Coração Puro" },
		Rewards = { "Olho de Horus", "Visão Verdadeira", "Poder: Ver através de Ilusões" },
		LoreText = "Perdido quando Set arrancou o olho de Horus. Enterrado nas areias do tempo, esperando o escolhido.",
	},
	{
		Name = "Tabuleta da Primeira Areia",
		Type = "LoreTablet",
		Position = Vector3.new(0, 180, 0),
		RespawnTime = 0,
		Requirements = { "Idioma Antigo: Nível 7", "Erudito: Nível 60" },
		Rewards = { "Conhecimento: Origem do Deserto", "XP Lore: 20000", "Técnica: Andar na Areia" },
		LoreText = "No início, tudo era rocha. O vento soprou por milênios, e a rocha virou areia. A areia lembra de ser rocha. O deserto não é vazio - é memória condensada. Cada grão guarda uma história.",
	},
	{
		Name = "Tempestade de Areia Sagrada",
		Type = "WorldEvent",
		Position = Vector3.new(0, 100, 0),
		RespawnTime = 86400,
		Requirements = {},
		Rewards = { "Areia Sagrada x200", "Cristal de Tempestade x50", "Buff: Imune a Areia" },
		LoreText = "Uma vez por ano, a areia brilha como ouro. A tempestade limpa o pecado do deserto.",
		EventSchedule = { StartHour = 12, EndHour = 18, Days = { "Ano Novo Egípcio" } },
	},
	{
		Name = "Migração dos Escaravelhos Solares",
		Type = "Migration",
		Position = Vector3.new(300, 80, -400),
		RespawnTime = 259200,
		Requirements = {},
		Rewards = { "Casco Dourado x100", "Escaravelho Vivo (Raro)", "Essência de Ra" },
		LoreText = "Milhões de escaravelhos rolam bolas de areia dourada. Seguem o caminho do sol através do céu.",
		EventSchedule = { StartHour = 6, EndHour = 18, Days = { "Solstício de Verão" } },
	},
	{
		Name = "Miragem da Cidade Perdida",
		Type = "Weather",
		Position = Vector3.new(-500, 50, -300),
		RespawnTime = 86400,
		Requirements = {},
		Rewards = { "Mapa de Miragem", "Tesouro Ilusório (Torna-se Real)", "Buff: Ver Verdade" },
		LoreText = "Quando o sol atinge ângulo perfeito, a miragem de Siwa se torna real por uma hora.",
		EventSchedule = { StartHour = 11, EndHour = 12, Days = { "Equinócio" } },
	},
}

Dunas.Guardian = {
	Name = "Ra, O Escaravelho Solar",
	Title = "Guardião das Areias Eternas",
	Level = 40,
	Health = 100000,
	Phases = 4,
	Position = Vector3.new(0, 180, 0),
	ArenaSize = Vector3.new(200, 100, 200),
	Mechanics = {
		"Fase 1: Rolando o Sol - Empurra bola de fogo gigante; jogadores devem desviar/empurrar de volta",
		"Fase 2: Enxame de Escaravelhos - Milhares de pequenos escaravelhos; dano em área; roubam recursos",
		"Fase 3: Forma de Areia Viva - Torna-se duna móvel; invulnerável exceto no olho (núcleo)",
		"Fase 4: Eclipse Solar - Escurece arena; raios solares aleatórios; deve ficar na luz",
		"Mecânica Especial: 3 Obeliscos devem ser ativados na ordem do sol (nascente, zênite, poente)",
		"Enrage: Após 25 minutos, sol cai - dano massivo em toda a ilha",
	},
	Rewards = {
		"Coroa do Escaravelho Solar",
		"Khopesh de Ra",
		"Manto de Areia Viva",
		"Essência de Dunas x200",
		"Montaria: Fênix de Areia",
		"Título: Faraó das Areias",
		"Chave da Grande Pirâmide",
		"Receita: Armadura de Escaravelho",
		"Olho de Ra (Único)",
	},
	MusicTrack = "rbxassetid://5444444444",
}

Dunas.DynamicEvents = {
	{
		Name = "Vento do Khamsin",
		Type = "Weather",
		Schedule = { StartHour = 10, EndHour = 18, Probability = 0.3 },
		Effects = { "Areia quente: queima", "Visibilidade 20%", "Stamina drena 3x" },
		VisualChanges = { "Areia voando horizontal", "Céu vermelho", "Ondas de calor" },
		GameplayChanges = { "Fogo/Terra: poder 2x", "Água evapora instantaneamente", "Voo impossível" },
	},
	{
		Name = "Noite Estrelada do Deserto",
		Type = "DayNightCycle",
		Schedule = { StartHour = 20, EndHour = 5, Probability = 1.0 },
		Effects = { "Frio extremo", "Estrelas brilhantes", "Areia brilha fracamente" },
		VisualChanges = { "Via Láctea visível", "Areia bioluminescente", "Sombras nítidas" },
		GameplayChanges = { "Gelo/Água: poder 2x", "Furtividade +50%", "Rituais noturnos: poder 3x" },
	},
	{
		Name = "Canto das Dunas",
		Type = "Weather",
		Schedule = { StartHour = 6, EndHour = 10, Probability = 0.2 },
		Effects = { "Dunas emitem notas", "Cura quem ouve", "Revela segredos enterrados" },
		VisualChanges = { "Dunas vibrando", "Partículas de som visíveis", "Luz rítmica" },
		GameplayChanges = { "Regeneração 5x", "Detecção de tesouros", "Bardos: poder 10x" },
	},
	{
		Name = "Grande Migração dos Camelos Celestiais",
		Type = "Migration",
		Schedule = { StartHour = 5, EndHour = 9, Probability = 0.05 },
		Effects = { "Camelos voam baixo", "Carregam tesouros", "Deixam rastros de luz" },
		VisualChanges = { "Camelos alados", "Pó de estrela caindo", "Arco-íris no rastro" },
		GameplayChanges = { "Montaria temporária", "Loot lendário no rastro", "Evento: Escoltar caravana" },
	},
	{
		Name = "Despertar da Pirâmide",
		Type = "Weather",
		Schedule = { StartHour = 0, EndHour = 23, Probability = 0.02 },
		Effects = { "Pirâmide gira", "Câmaras se rearranjam", "Chefe mundial: Faraó Ressuscitado" },
		VisualChanges = { "Luz dourada no topo", "Areia flutuando", "Hieróglifos brilhando" },
		GameplayChanges = { "Interior novo", "Tesouros revelados", "Portais para Duat abertos" },
	},
}

Dunas.Sanctuary = {
	Name = "Santuário do Sol Oculto",
	Position = Vector3.new(0, 160, 0),
	Theme = "Terra",
	AltarPosition = Vector3.new(0, 165, 0),
	Blessings = {
		"Bênção da Areia: Imune a areia/vento por 1h",
		"Bênção do Sol: Dano de fogo/terra 2x, cura em luz solar",
		"Bênção da Miragem: Cria ilusão de si mesmo",
		"Bênção do Escaravelho: Recursos dobrados ao minerar",
		"Bênção Eterna: Reviver no oásis mais próximo",
	},
	Requirements = { "Oferecer: 1 Grão Mestre", "Completar: Ritual do Sol", "Nível 40+" },
	Cooldown = 86400,
}

Dunas.Navigation = {
	Bridges = {
		{ From = Vector3.new(-200, 50, 0), To = Vector3.new(200, 50, 0), Type = "Stone", Length = 400 },
		{ From = Vector3.new(0, 80, -200), To = Vector3.new(0, 150, 0), Type = "Sand", Length = 250 },
		{ From = Vector3.new(-500, 40, -300), To = Vector3.new(-100, 50, 100), Type = "Stone", Length = 500 },
		{ From = Vector3.new(400, 20, 300), To = Vector3.new(100, 40, 0), Type = "Stone", Length = 424 },
		{ From = Vector3.new(-200, 0, 400), To = Vector3.new(-200, -50, 400), Type = "Stone", Length = 50 },
	},
	FlyingPoints = {
		{ Position = Vector3.new(0, 250, 0), Destination = "Brasa", Cooldown = 1800, Requirements = { "Tapete Voador", "Nível 40+" } },
		{ Position = Vector3.new(-500, 100, -300), Destination = "Pantano", Cooldown = 1200, Requirements = { "Asas de Escaravelho", "Nível 35+" } },
		{ Position = Vector3.new(400, 150, 400), Destination = "Trovao", Cooldown = 3600, Requirements = { "Chave de Areia", "Nível 45+" } },
	},
	UnderwaterTunnels = {
		{ Entrance = Vector3.new(-800, -20, 0), Exit = Vector3.new(-800, -20, 800), Depth = 100, AirPockets = { Vector3.new(-800, 0, 400) } },
		{ Entrance = Vector3.new(0, -20, -800), Exit = Vector3.new(800, -20, -800), Depth = 80, AirPockets = { Vector3.new(400, 0, -800) } },
	},
	ClimbingWalls = {
		{ Base = Vector3.new(-50, 130, -50), Top = Vector3.new(-50, 250, -50), Difficulty = 4, Handholds = { Vector3.new(-50, 170, -50), Vector3.new(-50, 210, -50) } },
		{ Base = Vector3.new(420, 0, 350), Top = Vector3.new(420, 150, 350), Difficulty = 3, Handholds = { Vector3.new(420, 50, 350), Vector3.new(420, 100, 350) } },
		{ Base = Vector3.new(-200, 0, 400), Top = Vector3.new(-200, 150, 400), Difficulty = 5, Handholds = { Vector3.new(-200, 50, 400), Vector3.new(-200, 100, 400) } },
	},
}

return Dunas
