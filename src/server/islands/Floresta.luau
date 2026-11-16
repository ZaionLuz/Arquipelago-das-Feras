--!strict
-- FLORESTA (Natureza) - Árvore Mãe, clareira sagrada, ruínas élficas, copas navegáveis, troncos ocos
-- The Forest Isle - Ancient trees, elven ruins, canopy highways

export type FlorestaLandmark = {
	Name: string,
	Position: Vector3,
	Size: Vector3,
	Theme: "Natureza",
	Description: string,
	Interactions: { string },
	RequiredLevel: number,
	UniqueRewards: { string },
}

export type FlorestaCave = {
	Name: string,
	Entrance: Vector3,
	Levels: number,
	Depth: number,
	Biome: string,
	Hazards: { string },
	LootTables: { [number]: { string } },
	BossChamber: Vector3?,
}

export type FlorestaPOI = {
	Name: string,
	Type: "RareSpawn" | "HiddenItem" | "LoreTablet" | "WorldEvent",
	Position: Vector3,
	RespawnTime: number,
	Requirements: { string }?,
	Rewards: { string },
	LoreText: string?,
	EventSchedule: { StartHour: number, EndHour: number, Days: { string } }?,
}

export type FlorestaGuardian = {
	Name: "Yggdrasil, a Árvore Mãe",
	Title: "Guardião da Floresta Primordial",
	Level: 40,
	Health: 100000,
	Phases: 4,
	Position: Vector3,
	ArenaSize: Vector3,
	Mechanics: { string },
	Rewards: { string },
	MusicTrack: string,
}

export type FlorestaDynamicEvent = {
	Name: string,
	Type: "Weather" | "Migration" | "DayNightCycle",
	Schedule: { StartHour: number, EndHour: number, Probability: number },
	Effects: { string },
	VisualChanges: { string },
	GameplayChanges: { string },
}

export type FlorestaSanctuary = {
	Name: "Santuário do Coração Verde",
	Position: Vector3,
	Theme: "Natureza",
	AltarPosition: Vector3,
	Blessings: { string },
	Requirements: { string },
	Cooldown: number,
}

export type FlorestaNavigation = {
	Bridges: { { From: Vector3, To: Vector3, Type: "Wood" | "Stone" | "Living" | "Light", Length: number } },
	FlyingPoints: { { Position: Vector3, Destination: string, Cooldown: number, Requirements: { string } } },
	UnderwaterTunnels: { { Entrance: Vector3, Exit: Vector3, Depth: number, AirPockets: { Vector3 } } },
	ClimbingWalls: { { Base: Vector3, Top: Vector3, Difficulty: number, Handholds: { Vector3 } } },
}

local Floresta = {}

Floresta.Name = "Floresta"
Floresta.DisplayName = "Floresta - A Ilha da Árvore Mãe"
Floresta.Element = "Natureza"
Floresta.RecommendedLevel = 25
Floresta.MaxLevel = 55
Floresta.Size = Vector3.new(2200, 800, 2200)
Floresta.SpawnPoint = Vector3.new(0, 100, 0)
Floresta.Skybox = {
	Day = "rbxassetid://4000000001",
	Dawn = "rbxassetid://4000000002",
	Night = "rbxassetid://4000000003",
}
Floresta.AmbientSound = "rbxassetid://4111111111"
Floresta.MusicTracks = {
	Exploration = "rbxassetid://4222222222",
	Combat = "rbxassetid://4333333333",
	Boss = "rbxassetid://4444444444",
	Sanctuary = "rbxassetid://4555555555",
}

Floresta.Landmarks = {
	{
		Name = "Árvore Mãe Yggdrasil",
		Position = Vector3.new(0, 300, 0),
		Size = Vector3.new(500, 600, 500),
		Theme = "Natureza",
		Description = "Árvore colossal que sustenta a ilha. Suas raízes vão até o núcleo, suas copas tocam as nuvens. Pulsa com mana pura.",
		Interactions = { "Comungar com a Árvore", "Beber Seiva Divina", "Entrar no Mundo das Raízes" },
		RequiredLevel = 30,
		UniqueRewards = { "Coração de Yggdrasil", "Folha do Mundo", "Seiva da Criação" },
	},
	{
		Name = "Clareira Sagrada dos Anciãos",
		Position = Vector3.new(-400, 80, -300),
		Size = Vector3.new(300, 50, 300),
		Theme = "Natureza",
		Description = "Clareira onde a luz toca o chão perfeitamente. Pedras rúnicas marcam rituais antigos. Espíritos dançam ao luar.",
		Interactions = { "Ritual da Lua Cheia", "Ouvir Sussurros da Floresta", "Receber Bênção dos Anciãos" },
		RequiredLevel = 25,
		UniqueRewards = { "Pedra Rúnica", "Essência de Clareira", "Cajado de Carvalho" },
	},
	{
		Name = "Ruínas Élficas de Sylvaris",
		Position = Vector3.new(350, 120, 200),
		Size = Vector3.new(400, 100, 400),
		Theme = "Natureza",
		Description = "Cidade élfica abandonada, fundida com as árvores. Pontes de cipó conectam plataformas nas copas. Magia residual brilha.",
		Interactions = { "Decifrar Runas Élficas", "Ativar Portal de Cipó", "Despertar Guardiões Adormecidos" },
		RequiredLevel = 28,
		UniqueRewards = { "Arco de Sylvaris", "Manto de Folhas", "Chave das Copas" },
	},
	{
		Name = "Copas Navegáveis - Estrada do Dossel",
		Position = Vector3.new(0, 200, 0),
		Size = Vector3.new(1000, 100, 1000),
		Theme = "Natureza",
		Description = "Rede de pontes, cipós e plataformas nas copas das árvores. Estrada aérea conectando toda a floresta alta.",
		Interactions = { "Corrida nas Copas", "Caça Aérea", "Colheita de Frutos Altos" },
		RequiredLevel = 20,
		UniqueRewards = { "Fruto Estelar", "Pena de Harpia", "Essência do Vento" },
	},
	{
		Name = "Troncos Ocos - Cidade Subterrânea",
		Position = Vector3.new(-200, 50, 400),
		Size = Vector3.new(300, 400, 300),
		Theme = "Natureza",
		Description = "Dentro de troncos gigantes ocos, uma cidade de fungos e musgo. Escadas espirais descem até as raízes profundas.",
		Interactions = { "Comércio com Micélios", "Forja de Fungos", "Túnel das Raízes Profundas" },
		RequiredLevel = 32,
		UniqueRewards = { "Cogumelo Lendário", "Armadura de Micélio", "Mapa das Raízes" },
	},
}

Floresta.Caves = {
	{
		Name = "Raízes do Mundo Superior",
		Entrance = Vector3.new(-100, 250, -100),
		Levels = 4,
		Depth = 200,
		Biome = "Raízes Aéreas",
		Hazards = { "Seiva Corrosiva", "Raízes Vivas", "Insetos Gigantes", "Queda Livre" },
		LootTables = {
			[1] = { "Raiz Flexível", "Seiva Doce", "Inseto Brilhante" },
			[2] = { "Cipó de Aço", "Flor de Raiz", "Gema Verde Escuro" },
			[3] = { "Coração de Raiz", "Essência de Crescimento", "Fragmento de Dryade" },
			[4] = { "Raiz Mestra", "Semente de Yggdrasil", "Bênção da Árvore Mãe" },
		},
		BossChamber = Vector3.new(-100, 50, -100),
	},
	{
		Name = "Catacumbas de Sylvaris",
		Entrance = Vector3.new(380, 100, 220),
		Levels = 5,
		Depth = 150,
		Biome = "Ruínas Subterrâneas",
		Hazards = { "Guardianas de Madeira", "Armadilhas de Cipó", "Gás de Esporos", "Maldição do Esquecimento" },
		LootTables = {
			[1] = { "Madeira Élfica", "Pó de Fada", "Runa Desbotada" },
			[2] = { "Espada de Videira", "Escudo de Casca", "Anel da Floresta" },
			[3] = { "Cajado do Arquidruida", "Tomo de Sylvaris", "Coroa de Folhas" },
			[4] = { "Coração da Cidade", "Chave do Portal", "Alma de Sylvaris" },
			[5] = { "Núcleo Élfico", "Essência de Eternidade", "Título: Herdeiro de Sylvaris" },
		},
		BossChamber = Vector3.new(380, -50, 220),
	},
	{
		Name = "Caverna do Micélio Infinito",
		Entrance = Vector3.new(-250, 30, 420),
		Levels = 6,
		Depth = 400,
		Biome = "Rede Fúngica",
		Hazards = { "Esporos Alucinógenos", "Fungos Parasitas", "Ácido Micelial", "Consciência Coletiva" },
		LootTables = {
			[1] = { "Esporo Brilhante", "Cogumelo Comum", "Lodo Curativo" },
			[2] = { "Fungo Metálico", "Corda de Micélio", "Olho Composto" },
			[3] = { "Cogumelo Ancião", "Núcleo de Fungo", "Fragmento de Myconid" },
			[4] = { "Cérebro Micelial", "Semente de Hifa", "Essência de Rede" },
			[5] = { "Coração da Rede", "Chave do Solo Profundo", "Consciência Compartilhada" },
			[6] = { "Micélio Primordial", "Esporo da Criação", "Título: Senhor dos Fungos" },
		},
		BossChamber = Vector3.new(-250, -370, 420),
	},
}

Floresta.POIs = {
	{
		Name = "Cervo Branco dos Nove Mundos",
		Type = "RareSpawn",
		Position = Vector3.new(-400, 80, -300),
		RespawnTime = 14400,
		Requirements = { "Nível 35+", "Item: Sino de Prata", "Pureza de Coração" },
		Rewards = { "Chifre do Mundo", "Pele Estelar", "Bênção dos Nove Mundos" },
		LoreText = "Dizem que este cervo carrega as almas de todos os druidas que já viveram. Seus chifres são portais.",
	},
	{
		Name = "Semente Estelar de Yggdrasil",
		Type = "HiddenItem",
		Position = Vector3.new(0, 350, 0),
		RespawnTime = 86400,
		Requirements = { "Missão: Herdeiro da Árvore", "Todas Bênçãos da Floresta" },
		Rewards = { "Semente Estelar", "Acesso: Mundo das Raízes", "Imortalidade Temporária" },
		LoreText = "Uma semente que caiu de Yggdrasil antes do tempo. Quem a plantar crescerá uma nova Árvore Mãe.",
	},
	{
		Name = "Tabuleta do Primeiro Broto",
		Type = "LoreTablet",
		Position = Vector3.new(-400, 90, -300),
		RespawnTime = 0,
		Requirements = { "Idioma Antigo: Nível 6", "Druida: Nível 50" },
		Rewards = { "Conhecimento: Origem da Vida Vegetal", "XP Lore: 15000", "Técnica: Falar com Plantas" },
		LoreText = "Antes dos animais, antes dos deuses, havia o Verde. O Verde não fala, não pensa, não quer. Apenas É. E ao Ser, torna tudo possível. Nós somos o sonho do Verde.",
	},
	{
		Name = "Florescência Noturna",
		Type = "WorldEvent",
		Position = Vector3.new(0, 200, 0),
		RespawnTime = 43200,
		Requirements = {},
		Rewards = { "Flor Noturna x100", "Pólen Mágico x50", "Buff: Fotossíntese" },
		LoreText = "Uma noite por mês, todas as flores abrem simultaneamente. A floresta brilha como céu estrelado.",
		EventSchedule = { StartHour = 22, EndHour = 4, Days = { "Lua Nova" } },
	},
	{
		Name = "Migração das Fadas da Luz",
		Type = "Migration",
		Position = Vector3.new(0, 250, 0),
		RespawnTime = 604800,
		Requirements = {},
		Rewards = { "Pó de Fada x500", "Asa de Fada (Raro)", "Bênção: Voo Natural" },
		LoreText = "A cada 7 anos, fadas migram da Árvore Mãe para as copas. Elas carregam a luz da criação.",
		EventSchedule = { StartHour = 5, EndHour = 7, Days = { "Solstício de Verão" } },
	},
	{
		Name = "Chuva de Seiva Dourada",
		Type = "Weather",
		Position = Vector3.new(0, 300, 0),
		RespawnTime = 86400,
		Requirements = {},
		Rewards = { "Seiva Dourada x100", "Ambar Vivo (Raro)", "Buff: Regeneração Total" },
		LoreText = "Quando Yggdrasil chora, suas lágrimas são ouro líquido. Curam qualquer ferida.",
		EventSchedule = { StartHour = 10, EndHour = 14, Days = { "Equinócio" } },
	},
}

Floresta.Guardian = {
	Name = "Yggdrasil, a Árvore Mãe",
	Title = "Guardião da Floresta Primordial",
	Level = 40,
	Health = 100000,
	Phases = 4,
	Position = Vector3.new(0, 320, 0),
	ArenaSize = Vector3.new(300, 300, 300),
	Mechanics = {
		"Fase 1: Raízes Emergentes - Raízes brotam do chão, prendendo jogadores; seiva cura a árvore",
		"Fase 2: Copa Viva - Galhos atacam do alto; frutos explosivos; pássaros invocados",
		"Fase 3: Forma de Floresta - Torna-se a floresta inteira; dano distribuído; clones de árvore",
		"Fase 4: Mundo das Raízes - Teleporta jogadores para dimensão radicular; quebra-cabeça de raízes",
		"Mecânica Especial: 3 'Corações de Raiz' devem ser destruídos simultaneamente nas 3 dimensões",
		"Enrage: Após 25 minutos, Yggdrasil absorve toda a ilha - jogo acaba se não derrotado",
	},
	Rewards = {
		"Coroa da Árvore Mãe",
		"Galho de Yggdrasil (Cajado)",
		"Manto de Folhas Eternas",
		"Essência de Floresta x200",
		"Montaria: Cervo dos Nove Mundos",
		"Título: Guardião do Verde",
		"Chave do Mundo das Raízes",
		"Receita: Armadura de Madeira Viva",
		"Semente de Yggdrasil (Única)",
	},
	MusicTrack = "rbxassetid://4444444444",
}

Floresta.DynamicEvents = {
	{
		Name = "Névoa da Manhã",
		Type = "Weather",
		Schedule = { StartHour = 5, EndHour = 9, Probability = 0.6 },
		Effects = { "Visibilidade reduzida", "Cura passiva +15%/s", "Sons amplificados" },
		VisualChanges = { "Névoa verde-dourada", "Gotas em teias", "Luz difusa mágica" },
		GameplayChanges = { "Furtividade +40%", "Rastreamento por som +50%", "Coleta: rendimento 2x" },
	},
	{
		Name = "Tempestade de Polen",
		Type = "Weather",
		Schedule = { StartHour = 10, EndHour = 16, Probability = 0.25 },
		Effects = { "Alergia: stamina -20%", "Mana regenera 3x", "Inimigos confusos" },
		VisualChanges = { "Ar dourado/verde", "Partículas brilhantes", "Cores vivas" },
		GameplayChanges = { "Magia natureza: custo 0", "Voo assistido por vento", "Polinização: plantas crescem" },
	},
	{
		Name = "Noite dos Espíritos",
		Type = "DayNightCycle",
		Schedule = { StartHour = 20, EndHour = 5, Probability = 1.0 },
		Effects = { "Espíritos visíveis", "Magia lunar +100%", "Árvores sussurram" },
		VisualChanges = { "Luzes flutuantes", "Runas brilhando na casca", "Céu espelhado nas folhas" },
		GameplayChanges = { "Comunicação com mortos", "Rituais druídicos: poder 3x", "Portais para Outromundo abertos" },
	},
	{
		Name = "Grande Migração dos Herbívoros Sagrados",
		Type = "Migration",
		Schedule = { StartHour = 6, EndHour = 10, Probability = 0.1 },
		Effects = { "Manadas de cervos/alces/mooses", "Predadores seguem", "Caminho sagrado pisado" },
		VisualChanges = { "Centenas de animais", "Poeira dourada", "Grama cresce onde passam" },
		GameplayChanges = { "Caça: drops lendários", "Rastreamento: caminho abençoado", "Evento: Proteger manada" },
	},
	{
		Name = "Despertar da Floresta",
		Type = "Weather",
		Schedule = { StartHour = 0, EndHour = 23, Probability = 0.03 },
		Effects = { "Árvores andam", "Novas clareiras abrem", "Chefe mundial: Dryade Primordial" },
		VisualChanges = { "Raízes se movendo", "Copa mudando forma", "Luz verde pulsante" },
		GameplayChanges = { "Mapa muda", "Novos recursos", "Caminhos novos nas copas" },
	},
}

Floresta.Sanctuary = {
	Name = "Santuário do Coração Verde",
	Position = Vector3.new(0, 310, 0),
	Theme = "Natureza",
	AltarPosition = Vector3.new(0, 315, 0),
	Blessings = {
		"Bênção do Crescimento: Plantas crescem instantaneamente por 1h",
		"Bênção da Fotossíntese: Regeneração total em luz solar",
		"Bênção da Raiz: Imune a knockback/arrastar",
		"Bênção da Copa: Voo/planar livre na floresta",
		"Bênção Eterna: Reviver no tronco mais próximo",
	},
	Requirements = { "Oferecer: 1 Folha do Mundo", "Completar: Ritual do Broto", "Nível 35+" },
	Cooldown = 86400,
}

Floresta.Navigation = {
	Bridges = {
		{ From = Vector3.new(-200, 180, 0), To = Vector3.new(200, 180, 0), Type = "Living", Length = 400 },
		{ From = Vector3.new(0, 220, -200), To = Vector3.new(0, 300, 0), Type = "Living", Length = 282 },
		{ From = Vector3.new(-400, 80, -300), To = Vector3.new(-100, 150, 0), Type = "Wood", Length = 427 },
		{ From = Vector3.new(350, 150, 200), To = Vector3.new(100, 180, -100), Type = "Living", Length = 427 },
		{ From = Vector3.new(-200, 50, 400), To = Vector3.new(-200, 200, 400), Type = "Living", Length = 150 },
	},
	FlyingPoints = {
		{ Position = Vector3.new(0, 400, 0), Destination = "Picos", Cooldown = 1800, Requirements = { "Asas de Águia", "Nível 40+" } },
		{ Position = Vector3.new(-400, 150, -300), Destination = "Alvorecer", Cooldown = 1200, Requirements = { "Pena de Coruja", "Nível 25+" } },
		{ Position = Vector3.new(400, 200, 400), Destination = "Celestial", Cooldown = 3600, Requirements = { "Chave de Folha", "Nível 45+" } },
	},
	UnderwaterTunnels = {
		{ Entrance = Vector3.new(-800, 20, 0), Exit = Vector3.new(-800, 20, 800), Depth = 80, AirPockets = { Vector3.new(-800, 30, 400) } },
		{ Entrance = Vector3.new(0, 20, -800), Exit = Vector3.new(800, 20, -800), Depth = 60, AirPockets = { Vector3.new(400, 30, -800) } },
	},
	ClimbingWalls = {
		{ Base = Vector3.new(380, 100, 220), Top = Vector3.new(380, 250, 220), Difficulty = 3, Handholds = { Vector3.new(380, 150, 220), Vector3.new(380, 200, 220) } },
		{ Base = Vector3.new(-250, 30, 420), Top = Vector3.new(-250, 200, 420), Difficulty = 4, Handholds = { Vector3.new(-250, 80, 420), Vector3.new(-250, 140, 420) } },
		{ Base = Vector3.new(0, 100, 0), Top = Vector3.new(0, 400, 0), Difficulty = 5, Handholds = { Vector3.new(0, 200, 0), Vector3.new(0, 300, 0) } },
	},
}

return Floresta
