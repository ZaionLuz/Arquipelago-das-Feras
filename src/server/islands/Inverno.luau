--!strict
-- INVERNO (Gelo) - NOVO: Cidadela de Gelo, caverna dos cristais, pico eterno, aurora boreal, ruínas de gelo
-- The Winter Isle - Ice citadel, crystal caves, eternal peak, aurora, frozen ruins

export type InvernoLandmark = {
	Name: string,
	Position: Vector3,
	Size: Vector3,
	Theme: "Gelo",
	Description: string,
	Interactions: { string },
	RequiredLevel: number,
	UniqueRewards: { string },
}

export type InvernoCave = {
	Name: string,
	Entrance: Vector3,
	Levels: number,
	Depth: number,
	Biome: string,
	Hazards: { string },
	LootTables: { [number]: { string } },
	BossChamber: Vector3?,
}

export type InvernoPOI = {
	Name: string,
	Type: "RareSpawn" | "HiddenItem" | "LoreTablet" | "WorldEvent",
	Position: Vector3,
	RespawnTime: number,
	Requirements: { string }?,
	Rewards: { string },
	LoreText: string?,
	EventSchedule: { StartHour: number, EndHour: number, Days: { string } }?,
}

export type InvernoGuardian = {
	Name: "Boreas, o Rei do Inverno Eterno",
	Title: "Guardião do Gelo Primordial",
	Level: 50,
	Health: 150000,
	Phases: 5,
	Position: Vector3,
	ArenaSize: Vector3,
	Mechanics: { string },
	Rewards: { string },
	MusicTrack: string,
}

export type InvernoDynamicEvent = {
	Name: string,
	Type: "Weather" | "Migration" | "DayNightCycle",
	Schedule: { StartHour: number, EndHour: number, Probability: number },
	Effects: { string },
	VisualChanges: { string },
	GameplayChanges: { string },
}

export type InvernoSanctuary = {
	Name: "Santuário do Zero Absoluto",
	Position: Vector3,
	Theme: "Gelo",
	AltarPosition: Vector3,
	Blessings: { string },
	Requirements: { string },
	Cooldown: number,
}

export type InvernoNavigation = {
	Bridges: { { From: Vector3, To: Vector3, Type: "Wood" | "Stone" | "Living" | "Light", Length: number } },
	FlyingPoints: { { Position: Vector3, Destination: string, Cooldown: number, Requirements: { string } } },
	UnderwaterTunnels: { { Entrance: Vector3, Exit: Vector3, Depth: number, AirPockets: { Vector3 } } },
	ClimbingWalls: { { Base: Vector3, Top: Vector3, Difficulty: number, Handholds: { Vector3 } } },
}

local Inverno = {}

Inverno.Name = "Inverno"
Inverno.DisplayName = "Inverno - A Ilha do Gelo Eterno"
Inverno.Element = "Gelo"
Inverno.RecommendedLevel = 40
Inverno.MaxLevel = 70
Inverno.Size = Vector3.new(2200, 1000, 2200)
Inverno.SpawnPoint = Vector3.new(0, 100, 0)
Inverno.Skybox = {
	Day = "rbxassetid://8000000001",
	Dawn = "rbxassetid://8000000002",
	Night = "rbxassetid://8000000003",
}
Inverno.AmbientSound = "rbxassetid://8111111111"
Inverno.MusicTracks = {
	Exploration = "rbxassetid://8222222222",
	Combat = "rbxassetid://8333333333",
	Boss = "rbxassetid://8444444444",
	Sanctuary = "rbxassetid://8555555555",
}

Inverno.Landmarks = {
	{
		Name = "Cidadela de Gelo Imortal",
		Position = Vector3.new(0, 200, 0),
		Size = Vector3.new(500, 400, 500),
		Theme = "Gelo",
		Description = "Fortaleza de gelo que nunca derrete. Torres de gelo azul translúcido. Trono do Rei do Inverno no topo. Guardiães de gelo patrulham.",
		Interactions = { "Audiência com Boreas", "Tocar Chifre do Inverno", "Sentar no Trono de Gelo" },
		RequiredLevel = 45,
		UniqueRewards = { "Coroa de Gelo", "Cetro do Blizzard", "Manto de Neve Eterna" },
	},
	{
		Name = "Caverna dos Cristais Cantantes",
		Position = Vector3.new(-400, 50, -300),
		Size = Vector3.new(300, 300, 300),
		Theme = "Gelo",
		Description = "Caverna onde cristais de gelo crescem como flores. Emitem notas musicais quando o vento passa. Cada cristal guarda uma memória congelada.",
		Interactions = { "Ouvir Canção dos Cristais", "Colher Cristal de Memória", "Tocar Harpa de Gelo" },
		RequiredLevel = 40,
		UniqueRewards = { "Cristal Cantante", "Memória Congelada", "Harpa de Gelo" },
	},
	{
		Name = "Pico Eterno do Zero Absoluto",
		Position = Vector3.new(300, 800, 200),
		Size = Vector3.new(200, 200, 200),
		Theme = "Gelo",
		Description = "Ponto mais alto e frio. Temperatura atinge zero absoluto. Nada vive aqui exceto o próprio frio. Tempo quase para.",
		Interactions = { "Meditar no Zero", "Toque do Congelamento", "Ver Fluxo Temporal" },
		RequiredLevel = 50,
		UniqueRewards = { "Essência de Zero Absoluto", "Cristal de Tempo Parado", "Olho de Boreas" },
	},
	{
		Name = "Aurora Boreal Viva",
		Position = Vector3.new(0, 500, 0),
		Size = Vector3.new(1000, 300, 1000),
		Theme = "Gelo",
		Description = "Aurora que não é apenas luz - é energia viva. Dança com vontade própria. Cura quem banha nela. Concede visões do futuro.",
		Interactions = { "Banhar na Aurora", "Pedir Visão", "Coletar Luz Polar" },
		RequiredLevel = 35,
		UniqueRewards = { "Luz da Aurora", "Visão do Futuro", "Pena de Espírito Polar" },
	},
	{
		Name = "Ruínas de Gelo de Fimbulvetr",
		Position = Vector3.new(-500, -50, 300),
		Size = Vector3.new(400, 200, 400),
		Theme = "Gelo",
		Description = "Cidade antiga congelada no tempo do Grande Inverno. Edifícios de gelo negro. Habitantes preservados em blocos. Tecnologia de gelo perdida.",
		Interactions = { "Despertar Cidadão Antigo", "Aprender Tecnogelo", "Encontrar Núcleo da Cidade" },
		RequiredLevel = 48,
		UniqueRewards = { "Tecnogelo Primordial", "Cidadão Desperto", "Código de Fimbulvetr" },
	},
}

Inverno.Caves = {
	{
		Name = "Túneis de Gelo Azul",
		Entrance = Vector3.new(100, 150, 100),
		Levels = 4,
		Depth = 200,
		Biome = "Gelo Glacial",
		Hazards = { "Escorregadio Mortal", "Gelo que Mord e", "Frio Queima", "Avalanches Internas" },
		LootTables = {
			[1] = { "Gelo Azul", "Neve Compacta", "Cristal Pequeno" },
			[2] = { "Gelo Eterno", "Essência de Glacial", "Gema de Gelo" },
			[3] = { "Coração de Glaciar", "Olho de Yeti", "Fragmento de Gélido" },
			[4] = { "Núcleo de Gelo Azul", "Frio Engarrafado", "Bênção do Glaciar" },
		},
		BossChamber = Vector3.new(100, -50, 100),
	},
	{
		Name = "Minas de Cristais de Tempo",
		Entrance = Vector3.new(-420, 30, -320),
		Levels = 5,
		Depth = 250,
		Biome = "Cristais Cronomânticos",
		Hazards = { "Tempo Acelerado/Desacelerado", "Cristais Explosivos", "Paradoxos Temporais", "Envelhecimento/Rejuvenescimento" },
		LootTables = {
			[1] = { "Areia do Tempo", "Cristal de Hora", "Pó de Cronos" },
			[2] = { "Gema do Futuro", "Essência de Momento", "Relógio Quebrado" },
			[3] = { "Cajado de Cronos", "Armadura Temporal", "Coroa de Eras" },
			[4] = { "Coração do Tempo", "Chave da Caverna", "Alma de Cronomante" },
			[5] = { "Mestre do Tempo", "Essência de Eternidade", "Título: Senhor do Tempo" },
		},
		BossChamber = Vector3.new(-420, -220, -320),
	},
	{
		Name = "Abismo do Fimbulvetr",
		Entrance = Vector3.new(-550, -100, 350),
		Levels = 6,
		Depth = 500,
		Biome = "Gelo Negro Primordial",
		Hazards = { "Gelo que Consome Alma", "Vazio Térmico", "Sussurros do Fim", "Não-Existência" },
		LootTables = {
			[1] = { "Gelo Negro", "Cinza de Fimbul", "Fragmento de Fim" },
			[2] = { "Cristal do Apocalipse", "Essência de Fimbulvetr", "Olho do Fim" },
			[3] = { "Coração do Inverno Final", "Voz do Gelo Primordial", "Fragmento de Ymir" },
			[4] = { "Núcleo de Fimbulvetr", "Canção do Fim", "Semente de Novo Mundo" },
			[5] = { "Motor do Inverno Eterno", "Controle de Era Glacial", "Chave do Ragnarok" },
			[6] = { "Coração do Fim", "Gelo Primordial", "Título: Testemunha do Fim" },
		},
		BossChamber = Vector3.new(-550, -600, 350),
	},
}

Inverno.POIs = {
	{
		Name = "Yeti Ancião das Neves",
		Type = "RareSpawn",
		Position = Vector3.new(300, 850, 200),
		RespawnTime = 21600,
		Requirements = { "Nível 45+", "Item: Pelo de Yeti", "Paz Interior" },
		Rewards = { "Pelo de Yeti Ancião", "Garra de Gelo Negro", "Bênção: Imune a Frio Total" },
		LoreText = "Guardião do Pico Eterno. Não ataca a menos que provocado. Seu rugido causa avalanches. Carrega sabedoria de mil invernos.",
	},
	{
		Name = "Lágrima de Ymir",
		Type = "HiddenItem",
		Position = Vector3.new(-500, -200, 300),
		RespawnTime = 86400,
		Requirements = { "Missão: Choro do Gigante", "Resistência a Gelo: 100%", "Coração de Gelo" },
		Rewards = { "Lágrima de Ymir", "Água Primordial", "Poder: Criar Gelo Eterno" },
		LoreText = "Ymir, o primeiro gigante de gelo, chorou quando viu o fim do mundo. Suas lágrimas são gelo que nunca derrete.",
	},
	{
		Name = "Tabuleta do Grande Gelo",
		Type = "LoreTablet",
		Position = Vector3.new(0, 220, 0),
		RespawnTime = 0,
		Requirements = { "Idioma Antigo: Nível 9", "Xamã de Gelo: Nível 70" },
		Rewards = { "Conhecimento: Origem do Frio", "XP Lore: 30000", "Técnica: Respiração de Glaciar" },
		LoreText = "O frio não é ausência de calor. É a presença da quietude. O calor é agitação, movimento, vida. O frio é ordem, quietude, morte. Mas na morte há preservação. No gelo, a memória é eterna. O mundo nasceu do fogo, mas será preservado pelo gelo.",
	},
	{
		Name = "Grande Aurora Dançante",
		Type = "WorldEvent",
		Position = Vector3.new(0, 500, 0),
		RespawnTime = 86400,
		Requirements = {},
		Rewards = { "Luz Polar x500", "Cristal de Aurora x100", "Buff: Visão do Futuro 1h" },
		LoreText = "Quando vento solar atinge campo magnético perfeito, a aurora ganha consciência. Dança e concede bênçãos.",
		EventSchedule = { StartHour = 22, EndHour = 2, Days = { "Solstício de Inverno", "Tempestade Solar Forte" } },
	},
	{
		Name = "Migração das Renas Estelares",
		Type = "Migration",
		Position = Vector3.new(0, 150, 0),
		RespawnTime = 2592000,
		Requirements = {},
		Rewards = { "Chifre Estelar x50", "Pelo de Rena (Raro)", "Trenó Voador Temporário" },
		LoreText = "Renas que voam pela aurora. Puxam o trenó do espírito do inverno. Migram entre polos do mundo.",
		EventSchedule = { StartHour = 0, EndHour = 23, Days = { "Natal", "Ano Novo" } },
	},
	{
		Name = "Nevasca de Diamante",
		Type = "Weather",
		Position = Vector3.new(-400, 100, -300),
		RespawnTime = 86400,
		Requirements = {},
		Rewards = { "Neve de Diamante x200", "Cristal Perfeito (Raro)", "Buff: Armadura de Gelo" },
		LoreText = "Neve onde cada floco é micro-cristal. Brilha como diamantes. Acumula-se em joias naturais.",
		EventSchedule = { StartHour = 10, EndHour = 14, Days = { "Lua Cheia de Inverno" } },
	},
}

Inverno.Guardian = {
	Name = "Boreas, o Rei do Inverno Eterno",
	Title = "Guardião do Gelo Primordial",
	Level = 50,
	Health = 150000,
	Phases = 5,
	Position = Vector3.new(0, 250, 0),
	ArenaSize = Vector3.new(250, 150, 250),
	Mechanics = {
		"Fase 1: Nevasca Cegante - Visibilidade zero; dano de gelo constante; plataformas de gelo formam/quebram",
		"Fase 2: Exercito de Gelo - Invoca guardiães de gelo; estátuas ganham vida; número infinito enquanto Boreas vive",
		"Fase 3: Toque do Zero Absoluto - Congela tempo local; jogadores parados congelam; deve mover sempre",
		"Fase 4: Forma de Blizzard - Torna-se tempestade; arena inteira é seu corpo; olho no centro vulnerável",
		"Fase 5: Fimbulvetr - Invernos de todos os mundos convergem; realidade congela; fim do mundo simulado",
		"Mecânica Especial: 4 Pilares de Fogo devem ser acesos para contrabalancear (fogo sagrado apenas)",
		"Enrage: Após 35 minutos, Zero Absoluto real - toda ilha congela permanentemente, jogo acaba",
	},
	Rewards = {
		"Coroa do Inverno Eterno",
		"Espada de Gelo Negro",
		"Manto de Fimbulvetr",
		"Essência de Inverno x300",
		"Montaria: Yeti Ancião",
		"Título: Rei/Imperatriz do Gelo",
		"Chave da Cidadela",
		"Receita: Armadura de Zero Absoluto",
		"Lágrima de Ymir (Única)",
	},
	MusicTrack = "rbxassetid://8444444444",
}

Inverno.DynamicEvents = {
	{
		Name = "Neve Suave Curativa",
		Type = "Weather",
		Schedule = { StartHour = 6, EndHour = 12, Probability = 0.4 },
		Effects = { "Cura 3%/s", "Frio não machuca", "Mana regenera 2x" },
		VisualChanges = { "Flocos grandes e lentos", "Luz difusa suave", "Silêncio pacífico" },
		GameplayChanges = { "Sem consumo de calor", "Magia gelo: cura aliados", "Construção de gelo: instantânea" },
	},
	{
		Name = "Vento Cortante Polar",
		Type = "Weather",
		Schedule = { StartHour = 12, EndHour = 20, Probability = 0.3 },
		Effects = { "Dano de gelo +100%", "Movimento 50%", "Equipamento congela" },
		VisualChanges = { "Vento visível (gelo no ar)", "Rastros de geada", "Céu branco brutal" },
		GameplayChanges = { "Armas de gelo: crítico 100%", "Armadura pesada: imobiliza", "Fogo: efetividade 50%" },
	},
	{
		Name = "Noite Polar Estrelada",
		Type = "DayNightCycle",
		Schedule = { StartHour = 16, EndHour = 10, Probability = 1.0 },
		Effects = { "Sol não nasce (inverno)", "Aurora constante", "Estrelas brilhantes" },
		VisualChanges = { "Céu verde/roxo", "Gelo brilha na luz estelar", "Reflexos infinitos" },
		GameplayChanges = { "Gelo: poder 3x", "Visão noturna perfeita", "Rituais de gelo: custo 0" },
	},
	{
		Name = "Grande Caçada do Yeti",
		Type = "Migration",
		Schedule = { StartHour = 8, EndHour = 16, Probability = 0.08 },
		Effects = { "Yetis caçam em banda", "Presas deixam rastros", "Território marcado" },
		VisualChanges = { "Pegadas gigantes", "Sangue na neve", "Rugidos distantes" },
		GameplayChanges = { "Rastreamento: xp 10x", "Caça: drops lendários", "Evento: Sobreviver à caçada" },
	},
	{
		Name = "Despertar de Fimbulvetr",
		Type = "Weather",
		Schedule = { StartHour = 0, EndHour = 23, Probability = 0.005 },
		Effects = { "Temperatura -273°C", "Tempo para", "Chefe mundial: Ymir Desperto" },
		VisualChanges = { "Tudo para", "Luz azul estática", "Silêncio absoluto" },
		GameplayChanges = { "Movimento = dano", "Habilidades: tempo de recarga 0", "Evento final do servidor" },
	},
}

Inverno.Sanctuary = {
	Name = "Santuário do Zero Absoluto",
	Position = Vector3.new(0, 230, 0),
	Theme = "Gelo",
	AltarPosition = Vector3.new(0, 235, 0),
	Blessings = {
		"Bênção do Gelo: Imune a frio/congelamento por 1h",
		"Bênção da Preservação: Itens não degradam, comida não estraga",
		"Bênção do Tempo: Acelera/desacelera tempo local por 5min",
		"Bênção da Aurora: Visão do futuro próximo (30s)",
		"Bênção Eterna: Reviver no cristal mais próximo",
	},
	Requirements = { "Oferecer: 1 Cristal Cantante", "Completar: Ritual do Zero", "Nível 50+" },
	Cooldown = 86400,
}

Inverno.Navigation = {
	Bridges = {
		{ From = Vector3.new(-200, 150, 0), To = Vector3.new(200, 150, 0), Type = "Ice", Length = 400 },
		{ From = Vector3.new(0, 180, -200), To = Vector3.new(0, 200, 0), Type = "Ice", Length = 200 },
		{ From = Vector3.new(-400, 50, -300), To = Vector3.new(-100, 100, 0), Type = "Ice", Length = 360 },
		{ From = Vector3.new(300, 300, 200), To = Vector3.new(0, 300, 0), Type = "Light", Length = 360 },
		{ From = Vector3.new(-500, 0, 300), To = Vector3.new(-200, 50, 100), Type = "Stone", Length = 360 },
	},
	FlyingPoints = {
		{ Position = Vector3.new(0, 900, 0), Destination = "Picos", Cooldown = 1800, Requirements = { "Asas de Neve", "Nível 50+" } },
		{ Position = Vector3.new(-400, 150, -300), Destination = "Pantano", Cooldown = 1200, Requirements = { "Pena de Coruja Polar", "Nível 45+" } },
		{ Position = Vector3.new(400, 400, 400), Destination = "Celestial", Cooldown = 3600, Requirements = { "Chave de Gelo", "Nível 55+" } },
	},
	UnderwaterTunnels = {
		{ Entrance = Vector3.new(-600, -50, 0), Exit = Vector3.new(-600, -50, 600), Depth = 150, AirPockets = { Vector3.new(-600, 0, 300) } },
		{ Entrance = Vector3.new(0, -50, -600), Exit = Vector3.new(600, -50, -600), Depth = 120, AirPockets = { Vector3.new(300, 0, -600) } },
		{ Entrance = Vector3.new(300, 100, 200), Exit = Vector3.new(300, -200, 200), Depth = 300, AirPockets = { Vector3.new(300, -50, 200) } },
	},
	ClimbingWalls = {
		{ Base = Vector3.new(100, 150, 100), Top = Vector3.new(100, 350, 100), Difficulty = 4, Handholds = { Vector3.new(100, 220, 100), Vector3.new(100, 290, 100) } },
		{ Base = Vector3.new(-420, 30, -320), Top = Vector3.new(-420, 250, -320), Difficulty = 5, Handholds = { Vector3.new(-420, 100, -320), Vector3.new(-420, 170, -320) } },
		{ Base = Vector3.new(-550, -100, 350), Top = Vector3.new(-550, 100, 350), Difficulty = 5, Handholds = { Vector3.new(-550, 0, 350), Vector3.new(-550, 50, 350) } },
	},
}

return Inverno
