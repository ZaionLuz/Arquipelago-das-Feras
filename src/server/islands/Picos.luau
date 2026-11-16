--!strict
-- PICOS (Ar) - Cidadela dos Ventos, pico da aurora, templo das nuvens, ilhas flutuantes, correntes de jato
-- The Peaks Isle - Wind citadel, floating islands, jet streams

export type PicosLandmark = {
	Name: string,
	Position: Vector3,
	Size: Vector3,
	Theme: "Ar",
	Description: string,
	Interactions: { string },
	RequiredLevel: number,
	UniqueRewards: { string },
}

export type PicosCave = {
	Name: string,
	Entrance: Vector3,
	Levels: number,
	Depth: number,
	Biome: string,
	Hazards: { string },
	LootTables: { [number]: { string } },
	BossChamber: Vector3?,
}

export type PicosPOI = {
	Name: string,
	Type: "RareSpawn" | "HiddenItem" | "LoreTablet" | "WorldEvent",
	Position: Vector3,
	RespawnTime: number,
	Requirements: { string }?,
	Rewards: { string },
	LoreText: string?,
	EventSchedule: { StartHour: number, EndHour: number, Days: { string } }?,
}

export type PicosGuardian = {
	Name: "Aeolus, Senhor dos Ventos",
	Title: "Guardião dos Céus Infinitos",
	Level: 45,
	Health: 120000,
	Phases: 5,
	Position: Vector3,
	ArenaSize: Vector3,
	Mechanics: { string },
	Rewards: { string },
	MusicTrack: string,
}

export type PicosDynamicEvent = {
	Name: string,
	Type: "Weather" | "Migration" | "DayNightCycle",
	Schedule: { StartHour: number, EndHour: number, Probability: number },
	Effects: { string },
	VisualChanges: { string },
	GameplayChanges: { string },
}

export type PicosSanctuary = {
	Name: "Santuário do Vento Eterno",
	Position: Vector3,
	Theme: "Ar",
	AltarPosition: Vector3,
	Blessings: { string },
	Requirements: { string },
	Cooldown: number,
}

export type PicosNavigation = {
	Bridges: { { From: Vector3, To: Vector3, Type: "Wood" | "Stone" | "Living" | "Light", Length: number } },
	FlyingPoints: { { Position: Vector3, Destination: string, Cooldown: number, Requirements: { string } } },
	UnderwaterTunnels: { { Entrance: Vector3, Exit: Vector3, Depth: number, AirPockets: { Vector3 } } },
	ClimbingWalls: { { Base: Vector3, Top: Vector3, Difficulty: number, Handholds: { Vector3 } } },
}

local Picos = {}

Picos.Name = "Picos"
Picos.DisplayName = "Picos - A Ilha dos Ventos Eternos"
Picos.Element = "Ar"
Picos.RecommendedLevel = 35
Picos.MaxLevel = 65
Picos.Size = Vector3.new(2000, 1500, 2000)
Picos.SpawnPoint = Vector3.new(0, 500, 0)
Picos.Skybox = {
	Day = "rbxassetid://6000000001",
	Dawn = "rbxassetid://6000000002",
	Night = "rbxassetid://6000000003",
}
Picos.AmbientSound = "rbxassetid://6111111111"
Picos.MusicTracks = {
	Exploration = "rbxassetid://6222222222",
	Combat = "rbxassetid://6333333333",
	Boss = "rbxassetid://6444444444",
	Sanctuary = "rbxassetid://6555555555",
}

Picos.Landmarks = {
	{
		Name = "Cidadela dos Ventos",
		Position = Vector3.new(0, 600, 0),
		Size = Vector3.new(400, 200, 400),
		Theme = "Ar",
		Description = "Fortaleza flutuante sustentada por ventos constantes. Torres de pedra levitam. Sede do Senhor dos Ventos.",
		Interactions = { "Audiência com Aeolus", "Tocar Sino dos Ventos", "Aprender Voo Verdadeiro" },
		RequiredLevel = 40,
		UniqueRewards = { "Coroa de Vento", "Asas de Aeolus", "Cetro das Correntes" },
	},
	{
		Name = "Pico da Aurora",
		Position = Vector3.new(-400, 800, -300),
		Size = Vector3.new(200, 100, 200),
		Theme = "Ar",
		Description = "Ponto mais alto da ilha. Primeira luz do mundo toca aqui. Neve nunca derrete. Visão de todo arquipélago.",
		Interactions = { "Saudar o Primeiro Sol", "Meditar na Luz Pura", "Ver Todos os Caminhos" },
		RequiredLevel = 35,
		UniqueRewards = { "Luz da Aurora", "Cristal de Prisma", "Visão Panorâmica" },
	},
	{
		Name = "Templo das Nuvens Sagradas",
		Position = Vector3.new(350, 550, 200),
		Size = Vector3.new(300, 150, 300),
		Theme = "Ar",
		Description = "Templo construído sobre nuvens solidificadas. Sacerdotes do vento controlam clima local. Bibliotecas de pergaminhos voadores.",
		Interactions = { "Ler Pergaminhos Voadores", "Ritual de Invocação de Vento", "Batizar em Nuvem" },
		RequiredLevel = 38,
		UniqueRewards = { "Pergaminho de Tempestade", "Nuvem Pessoal", "Manto de Nevoeiro" },
	},
	{
		Name = "Arquipélago Flutuante de Nimbus",
		Position = Vector3.new(0, 700, 0),
		Size = Vector3.new(1000, 300, 1000),
		Theme = "Ar",
		Description = "Dezenas de ilhas flutuantes conectadas por pontes de luz. Cada ilha tem bioma único. Gravidade variável.",
		Interactions = { "Pular entre Ilhas", "Coletar Água de Nuvem", "Domar Raios" },
		RequiredLevel = 30,
		UniqueRewards = { "Pedra Flutuante", "Essência de Levitação", "Semente de Ilha" },
	},
	{
		Name = "Correntes de Jato Primordiais",
		Position = Vector3.new(200, 900, -200),
		Size = Vector3.new(300, 200, 300),
		Theme = "Ar",
		Description = "Correntes de ar tão fortes que criam túneis visíveis no céu. Viajar nelas é instantâneo. Perigo: velocidade extrema.",
		Interactions = { "Entrar na Corrente", "Surfar Vento Supersônico", "Coletar Íons Carregados" },
		RequiredLevel = 45,
		UniqueRewards = { "Íon Primordial", "Asa de Jato", "Mapa das Correntes" },
	},
}

Picos.Caves = {
	{
		Name = "Cavernas de Vento na Rocha",
		Entrance = Vector3.new(100, 500, 100),
		Levels = 4,
		Depth = 200,
		Biome = "Rocha Eoliana",
		Hazards = { "Vento Cortante Interno", "Estalactites Sonoras", "Vácuo Súbito", "Eco Enlouquecedor" },
		LootTables = {
			[1] = { "Pedra Cantante", "Pó de Vento", "Cristal Oco" },
			[2] = { "Minério Leve", "Gema de Ar", "Essência de Brisa" },
			[3] = { "Coração de Rocha Viva", "Flauta de Pedra", "Fragmento de Sílfide" },
			[4] = { "Pulmão da Montanha", "Vento Engarrafado", "Bênção do Ar" },
		},
		BossChamber = Vector3.new(100, 300, 100),
	},
	{
		Name = "Minas de Cristal de Nuvem",
		Entrance = Vector3.new(380, 520, 220),
		Levels = 5,
		Depth = 150,
		Biome = "Cristais Aerados",
		Hazards = { "Cristais Explosivos", "Gravidade Invertida", "Fantasma de Mineiro", "Asfixia por Leveza" },
		LootTables = {
			[1] = { "Cristal de Nuvem", "Pó Estelar", "Fragmento Leve" },
			[2] = { "Diamante Aerado", "Essência de Flutuação", "Olho de Ciclope" },
			[3] = { "Cajado de Nimbus", "Armadura de Neblina", "Coroa de Cirrus" },
			[4] = { "Núcleo de Nuvem", "Chave do Templo", "Alma de Sacerdote" },
			[5] = { "Coração do Céu", "Essência de Liberdade", "Título: Filho das Nuvens" },
		},
		BossChamber = Vector3.new(380, 370, 220),
	},
	{
		Name = "Olho do Furacão Eterno",
		Entrance = Vector3.new(250, 850, -250),
		Levels = 6,
		Depth = 400,
		Biome = "Caos Atmosférico",
		Hazards = { "Vento 500km/h", "Relâmpagos Internos", "Pressão Variável", "Tempo Distorcido" },
		LootTables = {
			[1] = { "Ar Comprimido", "Raio Engarrafado", "Pó de Ozônio" },
			[2] = { "Cristal de Tempestade", "Essência de Caos", "Olho de Furacão" },
			[3] = { "Coração do Vórtice", "Voz do Vento", "Fragmento de Tifão" },
			[4] = { "Núcleo Atmosférico", "Canção do Furacão", "Semente de Ciclone" },
			[5] = { "Motor do Clima", "Controle Local de Tempo", "Chave da Estratosfera" },
			[6] = { "Coração da Atmosfera", "Vento Primordial", "Título: Senhor do Clima" },
		},
		BossChamber = Vector3.new(250, 450, -250),
	},
}

Picos.POIs = {
	{
		Name = "Roc, Rei dos Céus",
		Type = "RareSpawn",
		Position = Vector3.new(0, 1000, 0),
		RespawnTime = 21600,
		Requirements = { "Nível 45+", "Item: Pena de Roc", "Montaria Voadora" },
		Rewards = { "Pena de Roc", "Garra de Trovão", "Bênção: Voo Supersônico" },
		LoreText = "Pássaro lendário que carrega elefantes. Sua envergadura tapa o sol. Ovo eclode a cada milênio.",
	},
	{
		Name = "Harpa dos Ventos Eólios",
		Type = "HiddenItem",
		Position = Vector3.new(-400, 820, -300),
		RespawnTime = 43200,
		Requirements = { "Missão: Música das Esferas", "Bardo: Nível 50", "Ouvido Absoluto" },
		Rewards = { "Harpa de Aeolus", "Controle de Vento Total", "Canção: Calmaria" },
		LoreText = "Harpa tocada pelo próprio Aeolus. Suas cordas são raios de sol. Quem a toca comanda o ar.",
	},
	{
		Name = "Tabuleta do Primeiro Sopro",
		Type = "LoreTablet",
		Position = Vector3.new(0, 620, 0),
		RespawnTime = 0,
		Requirements = { "Idioma Antigo: Nível 8", "Monge do Vento: Nível 60" },
		Rewards = { "Conhecimento: Origem da Atmosfera", "XP Lore: 25000", "Técnica: Respiração Infinita" },
		LoreText = "Antes do ar, havia o Vazio. O Primeiro Sopro não veio de pulmão - veio de Vontade. O universo inspirou. E na expiração nasceram os ventos, as nuvens, a vida. Nós somos a expiração ainda em curso.",
	},
	{
		Name = "Festival dos Ventos",
		Type = "WorldEvent",
		Position = Vector3.new(0, 700, 0),
		RespawnTime = 604800,
		Requirements = {},
		Rewards = { "Essência de Vento x500", "Pena de Todas Aves", "Buff: Velocidade 3x" },
		LoreText = "Uma vez por semana, todos os ventos do mundo se encontram nos Picos. Dança aérea espetacular.",
		EventSchedule = { StartHour = 10, EndHour = 16, Days = { "Quarta-feira" } },
	},
	{
		Name = "Migração das Baleias Celestes",
		Type = "Migration",
		Position = Vector3.new(0, 900, 0),
		RespawnTime = 2592000,
		Requirements = {},
		Rewards = { "Óleo Estelar x100", "Barbatana Celestial (Raro)", "Essência do Vazio" },
		LoreText = "Baleias que nadam no ar, não no mar. Migram entre mundos. Seu canto é a música das esferas.",
		EventSchedule = { StartHour = 0, EndHour = 23, Days = { "Eclipse Solar" } },
	},
	{
		Name = "Aurora Boreal nos Trópicos",
		Type = "Weather",
		Position = Vector3.new(-400, 800, -300),
		RespawnTime = 86400,
		Requirements = {},
		Rewards = { "Luz Polar x200", "Cristal de Aurora (Raro)", "Buff: Imune a Frio/Vento" },
		LoreText = "Quando partículas solares atingem as correntes de jato, o céu dança em cores impossíveis.",
		EventSchedule = { StartHour = 22, EndHour = 2, Days = { "Tempestade Solar" } },
	},
}

Picos.Guardian = {
	Name = "Aeolus, Senhor dos Ventos",
	Title = "Guardião dos Céus Infinitos",
	Level = 45,
	Health = 120000,
	Phases = 5,
	Position = Vector3.new(0, 650, 0),
	ArenaSize = Vector3.new(300, 300, 300),
	Mechanics = {
		"Fase 1: Ventos Cortantes - Projéteis de ar invisível; apenas som revela trajetória",
		"Fase 2: Tornados Invocados - 4 tornados patrulham arena; sugam jogadores para centro",
		"Fase 3: Forma de Tempestade - Torna-se furacão vivo; olho é único ponto vulnerável",
		"Fase 4: Vácuo Absoluto - Remove todo ar da arena; jogadores sufocam; deve criar bolhas",
		"Fase 5: Corrente de Jato - Velocidade extrema; teleports; clones de vento",
		"Mecânica Especial: 4 Torres de Vento devem ser calibradas (Norte, Sul, Leste, Oeste)",
		"Enrage: Após 30 minutos, atmosfera colapsa - toda ilha cai do céu",
	},
	Rewards = {
		"Coroa do Senhor dos Ventos",
		"Espada de Vácuo",
		"Manto de Corrente de Jato",
		"Essência de Picos x250",
		"Montaria: Roc Juvenil",
		"Título: Imperador dos Céus",
		"Chave da Cidadela",
		"Receita: Armadura de Ar Comprimido",
		"Asas de Aeolus (Únicas)",
	},
	MusicTrack = "rbxassetid://6444444444",
}

Picos.DynamicEvents = {
	{
		Name = "Brisa Curativa",
		Type = "Weather",
		Schedule = { StartHour = 6, EndHour = 10, Probability = 0.4 },
		Effects = { "Cura 5%/s", "Mana regenera 3x", "Status negativos removidos" },
		VisualChanges = { "Partículas verdes no ar", "Luz suave", "Cheiro de ozônio fresco" },
		GameplayChanges = { "Sem consumo de poções", "Magia de cura: custo 0", "Voo: stamina 0" },
	},
	{
		Name = "Tempestade de Areia Voadora",
		Type = "Weather",
		Schedule = { StartHour = 12, EndHour = 18, Probability = 0.2 },
		Effects = { "Dano de ar +100%", "Visibilidade 30%", "Projéteis físicos desviados" },
		VisualChanges = { "Areia no ar", "Vento uivante", "Céu amarelo" },
		GameplayChanges = { "Armas de ar: perfuração 100%", "Voo turbulento", "Escudos físicos inúteis" },
	},
	{
		Name = "Noite das Estrelas Caídas",
		Type = "DayNightCycle",
		Schedule = { StartHour = 20, EndHour = 5, Probability = 1.0 },
		Effects = { "Meteoros lentos", "Estrelas ao nível dos olhos", "Gravidade 50%" },
		VisualChanges = { "Estrelas tocáveis", "Rastros de luz", "Ilhas brilhando" },
		GameplayChanges = { "Pulo triplo", "Coleta de poeira estelar", "Rituais astrais: poder 5x" },
	},
	{
		Name = "Grande Corrente de Jato",
		Type = "Migration",
		Schedule = { StartHour = 8, EndHour = 12, Probability = 0.1 },
		Effects = { "Vento global 2x", "Viagem entre ilhas instantânea", "Pássaros em formação" },
		VisualChanges = { "Linhas de vento visíveis", "Nuvens em fila", "Arco-íris circular" },
		GameplayChanges = { "Transporte grátis", "Entregas: tempo 0", "Corrida aérea disponível" },
	},
	{
		Name = "Olho do Furacão Abre",
		Type = "Weather",
		Schedule = { StartHour = 0, EndHour = 23, Probability = 0.01 },
		Effects = { "Calmaria perfeita no centro", "Acesso ao Núcleo do Vento", "Chefe mundial: Tifão Primordial" },
		VisualChanges = { "Parede de nuvens circular", "Céu limpo no centro", "Luz descendente" },
		GameplayChanges = { "Arena de chefe aberta", "Loot máximo", "Controle de clima temporário" },
	},
}

Picos.Sanctuary = {
	Name = "Santuário do Vento Eterno",
	Position = Vector3.new(0, 620, 0),
	Theme = "Ar",
	AltarPosition = Vector3.new(0, 625, 0),
	Blessings = {
		"Bênção da Brisa: Voo/planar ilimitado por 1h",
		"Bênção do Vendaval: Velocidade 3x, imune a knockback",
		"Bênção do Tornado: Forma de redemoinho por 5min",
		"Bênção da Calmaria: Cria zona de paz total",
		"Bênção Eterna: Reviver na corrente de jato mais próxima",
	},
	Requirements = { "Oferecer: 1 Íon Primordial", "Completar: Ritual do Sopro", "Nível 45+" },
	Cooldown = 86400,
}

Picos.Navigation = {
	Bridges = {
		{ From = Vector3.new(-200, 550, 0), To = Vector3.new(200, 550, 0), Type = "Light", Length = 400 },
		{ From = Vector3.new(0, 580, -200), To = Vector3.new(0, 600, 0), Type = "Light", Length = 200 },
		{ From = Vector3.new(-400, 800, -300), To = Vector3.new(0, 700, 0), Type = "Light", Length = 500 },
		{ From = Vector3.new(350, 550, 200), To = Vector3.new(100, 600, 0), Type = "Light", Length = 335 },
		{ From = Vector3.new(200, 900, -200), To = Vector3.new(0, 800, 0), Type = "Light", Length = 245 },
	},
	FlyingPoints = {
		{ Position = Vector3.new(0, 1100, 0), Destination = "Celestial", Cooldown = 1800, Requirements = { "Asas Estelares", "Nível 50+" } },
		{ Position = Vector3.new(-400, 850, -300), Destination = "Floresta", Cooldown = 1200, Requirements = { "Pena de Condor", "Nível 40+" } },
		{ Position = Vector3.new(400, 600, 400), Destination = "Trovao", Cooldown = 3600, Requirements = { "Chave de Vento", "Nível 45+" } },
	},
	UnderwaterTunnels = {
		{ Entrance = Vector3.new(-800, 400, 0), Exit = Vector3.new(-800, 400, 800), Depth = 50, AirPockets = { Vector3.new(-800, 450, 400) } },
		{ Entrance = Vector3.new(0, 400, -800), Exit = Vector3.new(800, 400, -800), Depth = 40, AirPockets = { Vector3.new(400, 450, -800) } },
	},
	ClimbingWalls = {
		{ Base = Vector3.new(380, 520, 220), Top = Vector3.new(380, 700, 220), Difficulty = 4, Handholds = { Vector3.new(380, 580, 220), Vector3.new(380, 640, 220) } },
		{ Base = Vector3.new(250, 850, -250), Top = Vector3.new(250, 1000, -250), Difficulty = 5, Handholds = { Vector3.new(250, 900, -250), Vector3.new(250, 950, -250) } },
		{ Base = Vector3.new(100, 500, 100), Top = Vector3.new(100, 700, 100), Difficulty = 3, Handholds = { Vector3.new(100, 570, 100), Vector3.new(100, 640, 100) } },
	},
}

return Picos
