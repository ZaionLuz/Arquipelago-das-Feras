--!strict
-- PÂNTANO (Sombra) - Portal Umbral, árvore dos espíritos, caverna dos ecos, nevoeiro denso, salgueiros chorões
-- The Swamp Isle - Shadow portal, spirit tree, echo caves, weeping willows

export type PantanoLandmark = {
	Name: string,
	Position: Vector3,
	Size: Vector3,
	Theme: "Sombra",
	Description: string,
	Interactions: { string },
	RequiredLevel: number,
	UniqueRewards: { string },
}

export type PantanoCave = {
	Name: string,
	Entrance: Vector3,
	Levels: number,
	Depth: number,
	Biome: string,
	Hazards: { string },
	LootTables: { [number]: { string } },
	BossChamber: Vector3?,
}

export type PantanoPOI = {
	Name: string,
	Type: "RareSpawn" | "HiddenItem" | "LoreTablet" | "WorldEvent",
	Position: Vector3,
	RespawnTime: number,
	Requirements: { string }?,
	Rewards: { string },
	LoreText: string?,
	EventSchedule: { StartHour: number, EndHour: number, Days: { string } }?,
}

export type PantanoGuardian = {
	Name = "Nyx, a Mãe das Sombras",
	Title: "Guardião do Véu Umbral",
	Level: 45,
	Health: 120000,
	Phases: 5,
	Position: Vector3,
	ArenaSize: Vector3,
	Mechanics: { string },
	Rewards: { string },
	MusicTrack: string,
}

export type PantanoDynamicEvent = {
	Name: string,
	Type: "Weather" | "Migration" | "DayNightCycle",
	Schedule: { StartHour: number, EndHour: number, Probability: number },
	Effects: { string },
	VisualChanges: { string },
	GameplayChanges: { string },
}

export type PantanoSanctuary = {
	Name: "Santuário do Crepúsculo",
	Position: Vector3,
	Theme: "Sombra",
	AltarPosition: Vector3,
	Blessings: { string },
	Requirements: { string },
	Cooldown: number,
}

export type PantanoNavigation = {
	Bridges: { { From: Vector3, To: Vector3, Type: "Wood" | "Stone" | "Living" | "Light", Length: number } },
	FlyingPoints: { { Position: Vector3, Destination: string, Cooldown: number, Requirements: { string } } },
	UnderwaterTunnels: { { Entrance: Vector3, Exit: Vector3, Depth: number, AirPockets: { Vector3 } } },
	ClimbingWalls: { { Base: Vector3, Top: Vector3, Difficulty: number, Handholds: { Vector3 } } },
}

local Pantano = {}

Pantano.Name = "Pantano"
Pantano.DisplayName = "Pântano - A Ilha do Véu Umbral"
Pantano.Element = "Sombra"
Pantano.RecommendedLevel = 35
Pantano.MaxLevel = 65
Pantano.Size = Vector3.new(1800, 300, 1800)
Pantano.SpawnPoint = Vector3.new(0, 20, 0)
Pantano.Skybox = {
	Day = "rbxassetid://7000000001",
	Dawn = "rbxassetid://7000000002",
	Night = "rbxassetid://7000000003",
}
Pantano.AmbientSound = "rbxassetid://7111111111"
Pantano.MusicTracks = {
	Exploration = "rbxassetid://7222222222",
	Combat = "rbxassetid://7333333333",
	Boss = "rbxassetid://7444444444",
	Sanctuary = "rbxassetid://7555555555",
}

Pantano.Landmarks = {
	{
		Name = "Portal Umbral do Vazio",
		Position = Vector3.new(0, 30, 0),
		Size = Vector3.new(200, 100, 200),
		Theme = "Sombra",
		Description = "Portal pulsante para o Plano Umbral. Sombras vazam dele. Quem entra pode não voltar. Chave para outras dimensões.",
		Interactions = { "Entrar no Umbral (Risco)", "Oferecer Sombra Própria", "Fechar Portal Temporariamente" },
		RequiredLevel = 40,
		UniqueRewards = { "Chave Umbral", "Essência de Vazio", "Fragmento de Nyx" },
	},
	{
		Name = "Árvore dos Espíritos Lamentosos",
		Position = Vector3.new(-300, 80, -300),
		Size = Vector3.new(150, 200, 150),
		Theme = "Sombra",
		Description = "Salgueiro gigantesco cujas folhas são almas. Choram à noite. Raízes bebem memórias. Tronco é portal para vida após morte.",
		Interactions = { "Conversar com Mortos", "Oferecer Memória", "Colher Lágrima de Alma" },
		RequiredLevel = 35,
		UniqueRewards = { "Lágrima de Espírito", "Memória Alheia", "Folha de Alma" },
	},
	{
		Name = "Caverna dos Ecos Infinitos",
		Position = Vector3.new(400, -20, 200),
		Size = Vector3.new(300, 200, 300),
		Theme = "Sombra",
		Description = "Caverna onde todo som se repete eternamente. Ecos ganham vida própria. Segredos sussurrados ecoam para sempre.",
		Interactions = { "Sussurrar Segredo", "Ouvir Ecos Passados", "Silenciar Eco Maligno" },
		RequiredLevel = 38,
		UniqueRewards = { "Eco Cristalizado", "Segredo do Passado", "Silêncio Absoluto" },
	},
	{
		Name = "Nevoeiro Denso da Perdição",
		Position = Vector3.new(-200, 10, 400),
		Size = Vector3.new(500, 50, 500),
		Theme = "Sombra",
		Description = "Nevoeiro que não dissipa. Quem entra perde memórias. Criaturas caçam pelo som. Apenas lanternas de alma funcionam.",
		Interactions = { "Navegar por Instinto", "Acender Lanterna de Alma", "Encontrar Núcleo do Nevoeiro" },
		RequiredLevel = 42,
		UniqueRewards = { "Núcleo de Nevoeiro", "Bússola de Alma", "Manto de Ocultação" },
	},
	{
		Name = "Bosque dos Salgueiros Chorões",
		Position = Vector3.new(200, 30, -400),
		Size = Vector3.new(400, 100, 400),
		Theme = "Sombra",
		Description = "Centenas de salgueiros cujas ramas tocam o chão. Cada árvore guarda um arrependimento. Água das raízes cura culpa.",
		Interactions = { "Confessar Arrependimento", "Beber Água de Raiz", "Cortar Ramo (Consequência)" },
		RequiredLevel = 32,
		UniqueRewards = { "Água de Perdão", "Ramo de Salgueiro", "Alívio de Culpa" },
	},
}

Pantano.Caves = {
	{
		Name = "Túneis do Lodo Vivo",
		Entrance = Vector3.new(-100, 15, 100),
		Levels = 4,
		Depth = 100,
		Biome = "Lodo Senciente",
		Hazards = { "Lodo que Engole", "Gás de Putrefação", "Mãos do Fundo", "Doença da Sombra" },
		LootTables = {
			[1] = { "Lodo Brilhante", "Osso Antigo", "Moeda Podre" },
			[2] = { "Gema de Lodo", "Essência de Putrefação", "Dente de Criatura" },
			[3] = { "Coração do Pântano", "Olho no Lodo", "Fragmento de Lama" },
			[4] = { "Núcleo de Lodo", "Vida da Putrefação", "Bênção do Pântano" },
		},
		BossChamber = Vector3.new(-100, -85, 100),
	},
	{
		Name = "Catacumbas dos Afogados",
		Entrance = Vector3.new(-320, 50, -320),
		Levels = 5,
		Depth = 150,
		Biome = "Tumbas Alagadas",
		Hazards = { "Mortos-Vivos Aquáticos", "Armadilhas de Peso", "Água Amaldiçoada", "Sussurros de Afogamento" },
		LootTables = {
			[1] = { "Osso Molhado", "Moeda de Barqueiro", "Teia de Alga" },
			[2] = { "Espada Enferrujada", "Armadura de Couro Podre", "Anel de Noivo Afogado" },
			[3] = { "Cajado de Necromante", "Tomo de Almas", "Coroa de Algas" },
			[4] = { "Coração Afogado", "Chave do Profundo", "Alma de Barqueiro" },
			[5] = { "Senhor dos Afogados", "Essência de Estige", "Título: Mestre dos Mortos" },
		},
		BossChamber = Vector3.new(-320, -100, -320),
	},
	{
		Name = "Abismo do Véu",
		Entrance = Vector3.new(50, 20, 50),
		Levels = 6,
		Depth = 300,
		Biome = "Fronteira Umbral",
		Hazards = { "Realidade Instável", "Sombras Caçadoras", "Tempo Não Linear", "Identidade Dissolvida" },
		LootTables = {
			[1] = { "Fragmento de Realidade", "Poeira de Vazio", "Memória Perdida" },
			[2] = { "Cristal Umbral", "Essência de Não-Ser", "Olho do Vazio" },
			[3] = { "Coração do Véu", "Voz do Abismo", "Fragmento de Nyx" },
			[4] = { "Núcleo Dimensional", "Chave do Umbral", "Semente de Sombra" },
			[5] = { "Motor da Realidade", "Controle de Sombra", "Chave do Plano Interno" },
			[6] = { "Coração do Vazio", "Sombra Primordial", "Título: Andarilho do Véu" },
		},
		BossChamber = Vector3.new(50, -280, 50),
	},
}

Pantano.POIs = {
	{
		Name = "Banshee da Meia-Noite",
		Type = "RareSpawn",
		Position = Vector3.new(-300, 100, -300),
		RespawnTime = 14400,
		Requirements = { "Nível 40+", "Item: Sino de Prata", "Coragem Inabalável" },
		Rewards = { "Grito de Banshee", "Véu de Luto", "Bênção: Presságio de Morte" },
		LoreText = "Seu choro prediz a morte. Quem ouve e sobrevive ganha visão do fim. Aparece só em noites sem lua.",
	},
	{
		Name = "Espelho da Alma Verdadeira",
		Type = "HiddenItem",
		Position = Vector3.new(400, 50, 200),
		RespawnTime = 86400,
		Requirements = { "Missão: Refletir a Sombra", "Sem Pecados Graves", "Olho de Vidro" },
		Rewards = { "Espelho da Verdade", "Ver Natureza Real", "Poder: Revelar Disfarces" },
		LoreText = "Mostra não o rosto, mas a alma. Monstros veem sua humanidade. Humanos veem seus monstros internos.",
	},
	{
		Name = "Tabuleta do Primeiro Crepúsculo",
		Type = "LoreTablet",
		Position = Vector3.new(0, 50, 0),
		RespawnTime = 0,
		Requirements = { "Idioma Antigo: Nível 8", "Necromante: Nível 60" },
		Rewards = { "Conhecimento: Origem da Sombra", "XP Lore: 25000", "Técnica: Andar nas Sombras" },
		LoreText = "A sombra não é ausência de luz. É a presença do que foi bloqueado. Cada objeto projeta sua negação. O mundo das sombras é o mundo das negações. Nele, tudo que foi recusado existe.",
	},
	{
		Name = "Noite dos Mortos-Vivos",
		Type = "WorldEvent",
		Position = Vector3.new(0, 20, 0),
		RespawnTime = 86400,
		Requirements = {},
		Rewards = { "Essência de Alma x200", "Osso Sagrado x50", "Buff: Comando Mortos-Vivos" },
		LoreText = "Uma noite por ano, o véu se rasga. Todos os mortos do pântano acordam. Dançam até o amanhecer.",
		EventSchedule = { StartHour = 0, EndHour = 6, Days = { "Dia dos Mortos" } },
	},
	{
		Name = "Migração dos Vaga-Lumes de Almas",
		Type = "Migration",
		Position = Vector3.new(200, 30, -400),
		RespawnTime = 604800,
		Requirements = {},
		Rewards = { "Luz de Alma x500", "Frasco de Vaga-Lume (Raro)", "Essência de Guia" },
		LoreText = "Vaga-lumes que são almas guiando perdidos. Migram do Portal Umbral para a Árvore dos Espíritos.",
		EventSchedule = { StartHour = 20, EndHour = 23, Days = { "Lua Nova" } },
	},
	{
		Name = "Nevoeiro da Verdade",
		Type = "Weather",
		Position = Vector3.new(-200, 10, 400),
		RespawnTime = 86400,
		Requirements = {},
		Rewards = { "Névoa Engarrafada", "Visão Verdadeira Temporária", "Buff: Imune a Ilusão" },
		LoreText = "Nevoeiro raro que revela a verdade. Ilusões quebram. Disfarces caem. Mentiras ecoam alto.",
		EventSchedule = { StartHour = 3, EndHour = 5, Days = { "Eclipse Lunar" } },
	},
}

Pantano.Guardian = {
	Name = "Nyx, a Mãe das Sombras",
	Title = "Guardião do Véu Umbral",
	Level = 45,
	Health = 120000,
	Phases = 5,
	Position = Vector3.new(0, 50, 0),
	ArenaSize = Vector3.new(200, 100, 200),
	Mechanics = {
		"Fase 1: Maré de Sombras - Sombras sobem do chão; jogadores ficam em plataformas de luz",
		"Fase 2: Espelhos Quebrados - Clones de sombra dos jogadores; devem matar o próprio clone",
		"Fase 3: Forma de Véu - Torna-se nevoeiro; só vulnerável quando ataca; teleports por sombras",
		"Fase 4: Portal Umbral Abre - Inimigos do Umbral invadem; deve fechar portal enquanto luta",
		"Fase 5: Noite Eterna - Escuridão total; apenas som guia; Nyx está em todo lugar",
		"Mecânica Especial: 3 Lanternas de Alma devem ser mantidas acesas (combustível: memórias)",
		"Enrage: Após 30 minutos, Véu se rompe - Umbral consome a ilha inteira",
	},
	Rewards = {
		"Coroa da Mãe das Sombras",
		"Adaga de Vazio",
		"Manto do Véu Umbral",
		"Essência de Pântano x250",
		"Montaria: Cavalo Espectral",
		"Título: Senhor do Crepúsculo",
		"Chave do Portal Umbral",
		"Receita: Armadura de Sombra Viva",
		"Fragmento de Nyx (Único)",
	},
	MusicTrack = "rbxassetid://7444444444",
}

Pantano.DynamicEvents = {
	{
		Name = "Nevoeiro Baixo",
		Type = "Weather",
		Schedule = { StartHour = 5, EndHour = 9, Probability = 0.7 },
		Effects = { "Visibilidade 30%", "Furtividade +50%", "Sons abafados" },
		VisualChanges = { "Nevoeiro rasteiro", "Luzes difusas", "Silêncio pesado" },
		GameplayChanges = { "Inimigos não veem além de 10m", "Rastreamento impossível", "Magia sombra: custo 50%" },
	},
	{
		Name = "Chuva de Sangue",
		Type = "Weather",
		Schedule = { StartHour = 18, EndHour = 23, Probability = 0.1 },
		Effects = { "Vida regenera em água", "Mortos-vivos fortalecidos", "Sangue no chão" },
		VisualChanges = { "Gotículas vermelhas", "Água rosa", "Cheiro metálico" },
		GameplayChanges = { "Vampirismo: cura 3x", "Necromancia: custo 0", "Sacrifício: poder 5x" },
	},
	{
		Name = "Crepúsculo Eterno",
		Type = "DayNightCycle",
		Schedule = { StartHour = 18, EndHour = 6, Probability = 1.0 },
		Effects = { "Sol nunca nasce totalmente", "Sombras alongadas", "Portal Umbral ativo" },
		VisualChanges = { "Céu roxo/preto", "Estrelas visíveis de dia", "Luz difusa" },
		GameplayChanges = { "Sombra: poder 2x", "Luz: poder 50%", "Rituais noturnos: sempre ativos" },
	},
	{
		Name = "Procissão dos Salgueiros",
		Type = "Migration",
		Schedule = { StartHour = 0, EndHour = 4, Probability = 0.05 },
		Effects = { "Árvores andam", "Caminho novo se forma", "Arrependimentos liberados" },
		VisualChanges = { "Raízes se movendo", "Folhas caindo em espiral", "Luz nas copas" },
		GameplayChanges = { "Mapa muda", "Novas clareiras", "Confissão: cura total" },
	},
	{
		Name = "Rasgo no Véu",
		Type = "Weather",
		Schedule = { StartHour = 0, EndHour = 23, Probability = 0.02 },
		Effects = { "Portal Umbral expande", "Criaturas do Vazio vazam", "Chefe mundial: Horror do Vazio" },
		VisualChanges = { "Rachadura no céu", "Estrelas erradas", "Realidade tremendo" },
		GameplayChanges = { "Dimensões se misturam", "Loot de outros mundos", "Perigo existencial" },
	},
}

Pantano.Sanctuary = {
	Name = "Santuário do Crepúsculo",
	Position = Vector3.new(0, 40, 0),
	Theme = "Sombra",
	AltarPosition = Vector3.new(0, 45, 0),
	Blessings = {
		"Bênção da Sombra: Invisibilidade em sombras por 1h",
		"Bênção do Véu: Passar através de paredes finas",
		"Bênção do Eco: Ouvir pensamentos próximos",
		"Bênção da Névoa: Criar nevoeiro denso instantâneo",
		"Bênção Eterna: Reviver na sombra mais próxima",
	},
	Requirements = { "Oferecer: 1 Lágrima de Espírito", "Completar: Ritual do Crepúsculo", "Nível 40+" },
	Cooldown = 86400,
}

Pantano.Navigation = {
	Bridges = {
		{ From = Vector3.new(-200, 15, 0), To = Vector3.new(200, 15, 0), Type = "Wood", Length = 400 },
		{ From = Vector3.new(0, 25, -200), To = Vector3.new(0, 30, 0), Type = "Living", Length = 200 },
		{ From = Vector3.new(-300, 50, -300), To = Vector3.new(-50, 30, -50), Type = "Wood", Length = 353 },
		{ From = Vector3.new(400, 0, 200), To = Vector3.new(100, 10, 0), Type = "Stone", Length = 360 },
		{ From = Vector3.new(200, 20, -400), To = Vector3.new(0, 25, -200), Type = "Living", Length = 282 },
	},
	FlyingPoints = {
		{ Position = Vector3.new(0, 100, 0), Destination = "Recife", Cooldown = 1800, Requirements = { "Asas de Morcego", "Nível 40+" } },
		{ Position = Vector3.new(-300, 80, -300), Destination = "Inverno", Cooldown = 1200, Requirements = { "Pena de Corvo", "Nível 35+" } },
		{ Position = Vector3.new(400, 50, 400), Destination = "Celestial", Cooldown = 3600, Requirements = { "Chave de Sombra", "Nível 50+" } },
	},
	UnderwaterTunnels = {
		{ Entrance = Vector3.new(-600, -30, 0), Exit = Vector3.new(-600, -30, 600), Depth = 80, AirPockets = { Vector3.new(-600, 0, 300) } },
		{ Entrance = Vector3.new(0, -30, -600), Exit = Vector3.new(600, -30, -600), Depth = 60, AirPockets = { Vector3.new(300, 0, -600) } },
		{ Entrance = Vector3.new(400, 0, 200), Exit = Vector3.new(400, -100, 200), Depth = 100, AirPockets = { Vector3.new(400, -50, 200) } },
	},
	ClimbingWalls = {
		{ Base = Vector3.new(-320, 50, -320), Top = Vector3.new(-320, 150, -320), Difficulty = 3, Handholds = { Vector3.new(-320, 80, -320), Vector3.new(-320, 110, -320) } },
		{ Base = Vector3.new(50, 20, 50), Top = Vector3.new(50, 100, 50), Difficulty = 4, Handholds = { Vector3.new(50, 40, 50), Vector3.new(50, 70, 50) } },
		{ Base = Vector3.new(200, 20, -400), Top = Vector3.new(200, 100, -400), Difficulty = 4, Handholds = { Vector3.new(200, 40, -400), Vector3.new(200, 70, -400) } },
	},
}

return Pantano
