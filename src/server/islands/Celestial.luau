--!strict
-- CELESTIAL (Luz) - NOVO: Observatório Cósmico, jardim das estrelas, núcleo da criação, ilhas no espaço, constelações vivas
-- The Celestial Isle - Cosmic observatory, star garden, creation core, space islands, living constellations

export type CelestialLandmark = {
	Name: string,
	Position: Vector3,
	Size: Vector3,
	Theme: "Luz",
	Description: string,
	Interactions: { string },
	RequiredLevel: number,
	UniqueRewards: { string },
}

export type CelestialCave = {
	Name: string,
	Entrance: Vector3,
	Levels: number,
	Depth: number,
	Biome: string,
	Hazards: { string },
	LootTables: { [number]: { string } },
	BossChamber: Vector3?,
}

export type CelestialPOI = {
	Name: string,
	Type: "RareSpawn" | "HiddenItem" | "LoreTablet" | "WorldEvent",
	Position: Vector3,
	RespawnTime: number,
	Requirements: { string }?,
	Rewards: { string },
	LoreText: string?,
	EventSchedule: { StartHour: number, EndHour: number, Days: { string } }?,
}

export type CelestialGuardian = {
	Name: "Asteria, a Tecelã do Cosmos",
	Title: "Guardião da Luz Primordial",
	Level: 60,
	Health: 200000,
	Phases: 6,
	Position: Vector3,
	ArenaSize: Vector3,
	Mechanics: { string },
	Rewards: { string },
	MusicTrack: string,
}

export type CelestialDynamicEvent = {
	Name: string,
	Type: "Weather" | "Migration" | "DayNightCycle",
	Schedule: { StartHour: number, EndHour: number, Probability: number },
	Effects: { string },
	VisualChanges: { string },
	GameplayChanges: { string },
}

export type CelestialSanctuary = {
	Name: "Santuário da Criação",
	Position: Vector3,
	Theme: "Luz",
	AltarPosition: Vector3,
	Blessings: { string },
	Requirements: { string },
	Cooldown: number,
}

export type CelestialNavigation = {
	Bridges: { { From: Vector3, To: Vector3, Type: "Wood" | "Stone" | "Living" | "Light", Length: number } },
	FlyingPoints: { { Position: Vector3, Destination: string, Cooldown: number, Requirements: { string } } },
	UnderwaterTunnels: { { Entrance: Vector3, Exit: Vector3, Depth: number, AirPockets: { Vector3 } } },
	ClimbingWalls: { { Base: Vector3, Top: Vector3, Difficulty: number, Handholds: { Vector3 } } },
}

local Celestial = {}

Celestial.Name = "Celestial"
Celestial.DisplayName = "Celestial - A Ilha das Estrelas Vivas"
Celestial.Element = "Luz"
Celestial.RecommendedLevel = 50
Celestial.MaxLevel = 80
Celestial.Size = Vector3.new(3000, 2000, 3000)
Celestial.SpawnPoint = Vector3.new(0, 500, 0)
Celestial.Skybox = {
	Day = "rbxassetid://1000000001",
	Dawn = "rbxassetid://1000000002",
	Night = "rbxassetid://1000000003",
}
Celestial.AmbientSound = "rbxassetid://1011111111"
Celestial.MusicTracks = {
	Exploration = "rbxassetid://1022222222",
	Combat = "rbxassetid://1033333333",
	Boss = "rbxassetid://1044444444",
	Sanctuary = "rbxassetid://1055555555",
}

Celestial.Landmarks = {
	{
		Name = "Observatório Cósmico Infinito",
		Position = Vector3.new(0, 1000, 0),
		Size = Vector3.new(400, 500, 400),
		Theme = "Luz",
		Description = "Torre que alcança além da atmosfera. Telescópios veem outros universos. Biblioteca de todo conhecimento cósmico. Onde deuses vêm aprender.",
		Interactions = { "Observar Multiverso", "Ler Akashicos Cósmicos", "Comunicar com Estrelas" },
		RequiredLevel = 55,
		UniqueRewards = { "Olho do Cosmo", "Tomo Infinito", "Chave do Multiverso" },
	},
	{
		Name = "Jardim das Estrelas Nascidas",
		Position = Vector3.new(-500, 400, -400),
		Size = Vector3.new(600, 300, 600),
		Theme = "Luz",
		Description = "Onde estrelas nascem antes de subir ao céu. Nebulosas em vasos. Proto-estrelas brincam. Jardineiros estelares cuidam. Luz pura cresce como flores.",
		Interactions = { "Adotar Proto-Estrela", "Colher Luz Estelar", "Plantar Semente de Sol" },
		RequiredLevel = 50,
		UniqueRewards = { "Proto-Estrela", "Essência de Nascimento", "Semente de Sistema Solar" },
	},
	{
		Name = "Núcleo da Criação",
		Position = Vector3.new(0, 0, 0),
		Size = Vector3.new(200, 200, 200),
		Theme = "Luz",
		Description = "Ponto zero onde o Big Bang aconteceu. Ainda pulsa com criação. Toque = ver início e fim. Realidade maleável. Fonte de toda magia.",
		Interactions = { "Toque da Criação", "Reescrever Realidade Local", "Nascer Nova Magia" },
		RequiredLevel = 60,
		UniqueRewards = { "Fagulha da Criação", "Pincel da Realidade", "Código Fonte do Universo" },
	},
	{
		Name = "Arquipélago no Vazio",
		Position = Vector3.new(0, 800, 0),
		Size = Vector3.new(1500, 500, 1500),
		Theme = "Luz",
		Description = "Ilhas flutuando no espaço real. Sem atmosfera. Gravidade artificial. Cada ilha = bioma de outro mundo. Conectadas por pontes de luz pura.",
		Interactions = { "Caminhar no Vazio", "Visitar Mundo Alheio", "Coletar Matéria Estelar" },
		RequiredLevel = 52,
		UniqueRewards = { "Pedra do Vazio", "Atmosfera Portátil", "Mapa do Multiverso" },
	},
	{
		Name = "Constelações Vivas - O Zodíaco Desperto",
		Position = Vector3.new(600, 1200, 600),
		Size = Vector3.new(800, 400, 800),
		Theme = "Luz",
		Description = "Doze constelações descidas do céu. Andam como gigantes. Cada uma concede poder único. Juntas formam o Círculo Perfeito. Dançam a Dança das Esferas.",
		Interactions = { "Dançar com Constelação", "Receber Bênção Zodiacal", "Desafiar Guardião Estelar" },
		RequiredLevel = 58,
		UniqueRewards = { "Signo Ascendente", "Armadura Zodiacal", "Chave do Zodíaco" },
	},
}

Celestial.Caves = {
	{
		Name = "Túneis de Luz Sólida",
		Entrance = Vector3.new(100, 800, 100),
		Levels = 4,
		Depth = 200,
		Biome = "Fótons Cristalizados",
		Hazards = { "Luz que Queima Alma", "Reflexos Infinitos", "Cegueira Permanente", "Tempo Luz" },
		LootTables = {
			[1] = { "Fóton Sólido", "Prisma Pequeno", "Raio Engarrafado" },
			[2] = { "Cristal de Luz", "Essência de Brilho", "Gema de Espectro" },
			[3] = { "Coração de Luz", "Olho de Fóton", "Fragmento de Lúmen" },
			[4] = { "Núcleo de Luz", "Luz Engarrafada", "Bênção do Espectro" },
		},
		BossChamber = Vector3.new(100, 600, 100),
	},
	{
		Name = "Arquivo das Linhas Ley Cósmicas",
		Entrance = Vector3.new(-550, 350, -450),
		Levels = 5,
		Depth = 150,
		Biome = "Geometria Sagrada",
		Hazards = { "Padrões que Prendem Mente", "Geometria Viva", "Simetria Forçada", "Conhecimento Proibido" },
		LootTables = {
			[1] = { "Geodésico Básico", "Essência de Padrão", "Fragmento de Flor da Vida" },
			[2] = { "Sólido Platônico", "Chave Geométrica", "Olho de Mandala" },
			[3] = { "Cajado de Ley", "Armadura Geométrica", "Coroa de Padrão" },
			[4] = { "Núcleo de Ley", "Chave do Arquivo", "Alma de Geômetra" },
			[5] = { "Mestre das Linhas", "Essência de Estrutura", "Título: Arquiteto do Cosmos" },
		},
		BossChamber = Vector3.new(-550, 200, -450),
	},
	{
		Name = "Útero do Universo",
		Entrance = Vector3.new(50, -50, 50),
		Levels = 7,
		Depth = 1000,
		Biome = "Matéria Prima",
		Hazards = { "Não-Existência", "Possibilidades Infinitas", "Colapso de Onda", "Criação Espontânea" },
		LootTables = {
			[1] = { "Matéria Prima", "Possibilidade Engarrafada", "Poeira de Estrela" },
			[2] = { "Elemento Zero", "Essência de Potencial", "Átomo Primordial" },
			[3] = { "Molécula da Vida", "Código Genético Universal", "Olho de Criador" },
			[4] = { "Célula Cósmica", "DNA do Universo", "Chave da Biogênese" },
			[5] = { "Órgão do Cosmos", "Função Vital Universal", "Semente de Vida" },
			[6] = { "Sistema Completo", "Ecossistema Engarrafado", "Chave da Panspermia" },
			[7] = { "Universo em Miniatura", "Big Bang Pessoal", "Título: Pai/Mãe de Mundos" },
		},
		BossChamber = Vector3.new(50, -1050, 50),
	},
}

Celestial.POIs = {
	{
		Name = "Fênix Cósmica - A Estrela que Renasce",
		Type = "RareSpawn",
		Position = Vector3.new(0, 1500, 0),
		RespawnTime = 86400,
		Requirements = { "Nível 60+", "Item: Cinza Estelar", "Ciclo de Vida Completo" },
		Rewards = { "Pena Cósmica", "Ciclo Eterno", "Imortalidade Verdadeira (1x)" },
		LoreText = "Não renasce de cinzas, mas de supernova. Cada morte cria elementos pesados. Sua cinza É a vida. Voa entre universos.",
	},
	{
		Name = "Espada da Criação - Excalibur Cósmica",
		Type = "HiddenItem",
		Position = Vector3.new(0, 50, 0),
		RespawnTime = 259200,
		Requirements = { "Missão: Herdeiro da Criação", "Todas Bênçãos Celestiais", "Vontade Inquebrável" },
		Rewards = { "Espada da Criação", "Corte Realidade", "Poder: Dizer \"Seja\" e Ser" },
		LoreText = "Forjada no Núcleo da Criação. Não corta matéria - corta possibilidades. Quem a empunha escreve o futuro.",
	},
	{
		Name = "Tabuleta do Verbo Primordial",
		Type = "LoreTablet",
		Position = Vector3.new(0, 1020, 0),
		RespawnTime = 0,
		Requirements = { "Idioma Antigo: Nível 10 (Máximo)", "Sábio: Nível 100" },
		Rewards = { "Conhecimento: A Palavra que Cria", "XP Lore: 50000", "Técnica: Verbo da Criação" },
		LoreText = "No princípio era o Verbo. O Verbo não foi falado - foi PENSADO. O pensamento É a criação. Cada pensamento seu cria uma realidade. O universo é o pensamento de Alguém. Você é o pensamento que pensa a si mesmo. A tabuleta está em branco. O leitor a escreve ao ler.",
	},
	{
		Name = "Alinhamento Planetário Perfeito",
		Type = "WorldEvent",
		Position = Vector3.new(600, 1200, 600),
		RespawnTime = 2592000,
		Requirements = {},
		Rewards = { "Essência Cósmica x1000", "Bênção de Todos Signos", "Portal: Qualquer Mundo" },
		LoreText = "Uma vez por era, todos os planetas alinham. Constelações descem. O Círculo se fecha. Desejos viram realidade.",
		EventSchedule = { StartHour = 0, EndHour = 23, Days = { "Grande Conjunção" } },
	},
	{
		Name = "Migração das Baleias do Vazio Interestelar",
		Type = "Migration",
		Position = Vector3.new(0, 1000, 0),
		RespawnTime = 31536000,
		Requirements = {},
		Rewards = { "Leite Estelar x100", "Barbatana do Vazio (Único)", "Mapa de Buracos de Minhoca" },
		LoreText = "Baleias que nadam no vácuo. Migram entre galáxias. Seu canto É a radiação de fundo. Seguem a música das esferas.",
		EventSchedule = { StartHour = 0, EndHour = 23, Days = { "Ano Galáctico" } },
	},
	{
		Name = "Supernova Controlada",
		Type = "Weather",
		Position = Vector3.new(-500, 400, -400),
		RespawnTime = 86400,
		Requirements = {},
		Rewards = { "Matéria de Supernova x200", "Elementos Pesados (Ouro, Urânio)", "Buff: Criação de Itens Lendários" },
		LoreText = "Jardineiros estelares fazem supernova controlada. Forjam elementos raros. Luz visível em outros mundos.",
		EventSchedule = { StartHour = 12, EndHour = 12, Days = { "Nascimento de Estrela" } },
	},
}

Celestial.Guardian = {
	Name = "Asteria, a Tecelã do Cosmos",
	Title = "Guardião da Luz Primordial",
	Level = 60,
	Health = 200000,
	Phases = 6,
	Position = Vector3.new(0, 10, 0),
	ArenaSize = Vector3.new(500, 500, 500),
	Mechanics = {
		"Fase 1: Tecelagem do Destino - Fios de luz prendem jogadores; devem cortar seu próprio fado",
		"Fase 2: Constelações Descidas - 12 guardiões zodiacais atacam em sequência; cada um = mecânica única",
		"Fase 3: Big Bang Local - Explosão de criação; nova matéria nasce; velha destruída; arena se rearranja",
		"Fase 4: Buraco Negro Pessoal - Cada jogador tem singularidade; deve alimentar com memórias para não ser sugado",
		"Fase 5: Forma de Universo - Asteria VIRA o universo; jogadores dentro dela; devem encontrar centro",
		"Fase 6: O Verbo Final - Asteria diz uma palavra; realidade obedece; jogadores devem contradizer com própria vontade",
		"Mecânica Especial: 7 Selos da Criação devem ser abertos na ordem dos dias (Gênesis)",
		"Enrage: Após 45 minutos, Asteria reescreve a ilha - jogadores viram NPCs da nova história",
	},
	Rewards = {
		"Coroa da Tecelã Cósmica",
		"Tesoura do Destino",
		"Manto do Multiverso",
		"Essência de Celestial x500",
		"Montaria: Fênix Cósmica",
		"Título: Co-Criador",
		"Chave do Observatório",
		"Receita: Armadura de Realidade",
		"Espada da Criação (Única - se não pega antes)",
		"Tabuleta em Branco (Escreve Própria Lenda)",
	},
	MusicTrack = "rbxassetid://1044444444",
}

Celestial.DynamicEvents = {
	{
		Name = "Chuva de Luz Curativa",
		Type = "Weather",
		Schedule = { StartHour = 6, EndHour = 18, Probability = 0.4 },
		Effects = { "Cura 10%/s", "Todos status curados", "Nível +1 temporário" },
		VisualChanges = { "Partículas douradas", "Arco-íris no chão", "Música das esferas audível" },
		GameplayChanges = { "Imortalidade temporária", "Todas skills: recarga 0", "XP 10x" },
	},
	{
		Name = "Eclipse de Antimatéria",
		Type = "Weather",
		Schedule = { StartHour = 12, EndHour = 12, Probability = 0.05 },
		Effects = { "Coisas deixam de existir", "Memórias apagadas", "Realidade fina" },
		VisualChanges = { "Buracos na visão", "Silêncio absoluto", "Cores invertidas" },
		GameplayChanges = { "Dano = apagamento", "Cura = restauração", "Magia: risco de falha existencial" },
	},
	{
		Name = "Dia Eterno da Criação",
		Type = "DayNightCycle",
		Schedule = { StartHour = 0, EndHour = 23, Probability = 1.0 },
		Effects = { "Sol nunca se põe", "Estrelas visíveis de dia", "Tempo não passa" },
		VisualChanges = { "Múltiplos sóis", "Céu em camadas", "Luz de todas direções" },
		GameplayChanges = { "Sem ciclo noturno", "Rituais: sempre ativos", "Envelhecimento: pausado" },
	},
	{
		Name = "Grande Dança das Esferas",
		Type = "Migration",
		Schedule = { StartHour = 0, EndHour = 23, Probability = 0.01 },
		Effects = { "Planetários orbitam ilha", "Constelações dançam", "Gravidade flutua" },
		VisualChanges = { "Mundos no céu", "Órbitas visíveis", "Música cósmica física" },
		GameplayChanges = { "Voo: natural", "Teleporte: pensamento", "Acesso: qualquer plano" },
	},
	{
		Name = "Nascimento de Novo Universo",
		Type = "Weather",
		Schedule = { StartHour = 0, EndHour = 23, Probability = 0.001 },
		Effects = { "Big Bang local", "Nova bolha de realidade", "Jogadores = deuses fundadores" },
		VisualChanges = { "Luz branca total", "Depois: escuridão", "Depois: estrelas nascendo" },
		GameplayChanges = { "Criação: livre", "Leis físicas: definidas pelos jogadores", "Evento: Fim de Jogo / Novo Jogo+" },
	},
}

Celestial.Sanctuary = {
	Name = "Santuário da Criação",
	Position = Vector3.new(0, 20, 0),
	Theme = "Luz",
	AltarPosition = Vector3.new(0, 25, 0),
	Blessings = {
		"Bênção da Criação: Cria item do nada (1x/dia)",
		"Bênção da Estrela: Teleporte para qualquer ilha instantâneo",
		"Bênção do Cosmo: Vê todas as possibilidades (previsão 10s)",
		"Bênção do Verbo: Fala e realidade obedece (3 palavras/dia)",
		"Bênção Eterna: Reviver em qualquer ponto do multiverso",
	},
	Requirements = { "Oferecer: 1 Fagulha da Criação", "Completar: Ritual do Verbo", "Nível 60+" },
	Cooldown = 86400,
}

Celestial.Navigation = {
	Bridges = {
		{ From = Vector3.new(-200, 800, 0), To = Vector3.new(200, 800, 0), Type = "Light", Length = 400 },
		{ From = Vector3.new(0, 850, -200), To = Vector3.new(0, 1000, 0), Type = "Light", Length = 223 },
		{ From = Vector3.new(-500, 400, -400), To = Vector3.new(0, 600, 0), Type = "Light", Length = 538 },
		{ From = Vector3.new(600, 1200, 600), To = Vector3.new(0, 1000, 0), Type = "Light", Length = 781 },
		{ From = Vector3.new(0, 500, 0), To = Vector3.new(0, 0, 0), Type = "Light", Length = 500 },
	},
	FlyingPoints = {
		{ Position = Vector3.new(0, 2000, 0), Destination = "Alvorecer", Cooldown = 1800, Requirements = { "Asas do Cosmos", "Nível 60+" } },
		{ Position = Vector3.new(-500, 600, -400), Destination = "Recife", Cooldown = 1200, Requirements = { "Pena Estelar", "Nível 55+" } },
		{ Position = Vector3.new(600, 1400, 600), Destination = "Picos", Cooldown = 3600, Requirements = { "Chave da Criação", "Nível 65+" } },
	},
	UnderwaterTunnels = {
		{ Entrance = Vector3.new(-800, 400, 0), Exit = Vector3.new(-800, 400, 800), Depth = 0, AirPockets = { Vector3.new(-800, 500, 400) } },
		{ Entrance = Vector3.new(0, 400, -800), Exit = Vector3.new(800, 400, -800), Depth = 0, AirPockets = { Vector3.new(400, 500, -800) } },
	},
	ClimbingWalls = {
		{ Base = Vector3.new(100, 800, 100), Top = Vector3.new(100, 1200, 100), Difficulty = 5, Handholds = { Vector3.new(100, 950, 100), Vector3.new(100, 1100, 100) } },
		{ Base = Vector3.new(-550, 350, -450), Top = Vector3.new(-550, 800, -450), Difficulty = 5, Handholds = { Vector3.new(-550, 500, -450), Vector3.new(-550, 650, -450) } },
		{ Base = Vector3.new(50, -50, 50), Top = Vector3.new(50, 500, 50), Difficulty = 6, Handholds = { Vector3.new(50, 100, 50), Vector3.new(50, 300, 50) } },
	},
}

return Celestial
