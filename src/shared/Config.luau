--!strict
-- Config.lua - Configurações globais do jogo

local Config = {}

-- Configurações de gameplay
Config.Game = {
	MaxPartySize = 6,
	MaxStorageBoxes = 32,
	StorageBoxSize = 30,
	BaseCaptureRate = 0.3,
	ExpCurve = "Medium" :: "Fast" | "Medium" | "Slow" | "Erratic" | "Fluctuating",
	ShinyRate = 1/4096,
	DayNightCycle = 1200, -- 20 minutos em segundos
	WeatherChangeInterval = 300, -- 5 minutos
	MaxLevel = 100,
	BaseExpYield = 100,
}

-- Tabelas de experiência por curva
Config.ExpCurves = {
	Fast = function(level: number): number
		return math.floor((4 * level ^ 3) / 5)
	end,
	Medium = function(level: number): number
		return level ^ 3
	end,
	Slow = function(level: number): number
		return math.floor((5 * level ^ 3) / 4)
	end,
	Erratic = function(level: number): number
		if level < 50 then
			return math.floor((level ^ 3 * (100 - level)) / 50)
		elseif level < 68 then
			return math.floor((level ^ 3 * (150 - level)) / 100)
		elseif level < 98 then
			return math.floor((level ^ 3 * (1911 - 10 * level)) / 500)
		else
			return math.floor((level ^ 3 * (160 - level)) / 100)
		end
	end,
	Fluctuating = function(level: number): number
		if level < 15 then
			return math.floor((level ^ 3 * (level + 1)) / 3)
		elseif level < 36 then
			return math.floor((level ^ 3 * (level + 14)) / 50)
		else
			return math.floor((level ^ 3 * (level / 2 + 32)) / 50)
		end
	end,
}

-- Efetividade de tipos (1.0 = normal, 2.0 = super efetivo, 0.5 = pouco efetivo, 0 = imune)
Config.TypeEffectiveness: {[string]: {[string]: number}} = {
	Fire = {
		Fire = 0.5, Water = 0.5, Nature = 2.0, Earth = 1.0, Air = 1.0, Shadow = 1.0,
		FireWater = 1.0, EarthAir = 1.0, NatureShadow = 1.0,
	},
	Water = {
		Fire = 2.0, Water = 0.5, Nature = 0.5, Earth = 2.0, Air = 1.0, Shadow = 1.0,
		FireWater = 1.0, EarthAir = 1.0, NatureShadow = 1.0,
	},
	Nature = {
		Fire = 0.5, Water = 2.0, Nature = 0.5, Earth = 1.0, Air = 0.5, Shadow = 2.0,
		FireWater = 1.0, EarthAir = 1.0, NatureShadow = 1.0,
	},
	Earth = {
		Fire = 1.0, Water = 1.0, Nature = 1.0, Earth = 0.5, Air = 0.0, Shadow = 1.0,
		FireWater = 1.0, EarthAir = 0.5, NatureShadow = 1.0,
	},
	Air = {
		Fire = 1.0, Water = 1.0, Nature = 2.0, Earth = 2.0, Air = 0.5, Shadow = 1.0,
		FireWater = 1.0, EarthAir = 1.0, NatureShadow = 1.0,
	},
	Shadow = {
		Fire = 1.0, Water = 1.0, Nature = 0.5, Earth = 1.0, Air = 1.0, Shadow = 0.5,
		FireWater = 1.0, EarthAir = 1.0, NatureShadow = 0.5,
	},
	FireWater = {
		Fire = 0.5, Water = 0.5, Nature = 1.0, Earth = 1.0, Air = 1.0, Shadow = 1.0,
		FireWater = 0.5, EarthAir = 1.0, NatureShadow = 1.0,
	},
	EarthAir = {
		Fire = 1.0, Water = 1.0, Nature = 1.0, Earth = 0.5, Air = 0.5, Shadow = 1.0,
		FireWater = 1.0, EarthAir = 0.5, NatureShadow = 1.0,
	},
	NatureShadow = {
		Fire = 1.0, Water = 1.0, Nature = 0.5, Earth = 1.0, Air = 1.0, Shadow = 0.5,
		FireWater = 1.0, EarthAir = 1.0, NatureShadow = 0.5,
	},
}

-- Status conditions
Config.StatusEffects = {
	Burn = {
		DamagePerTurn = 0.0625, -- 1/16 max HP
		AttackReduction = 0.5,
		Duration = {Min = 1, Max = 5},
	},
	Poison = {
		DamagePerTurn = 0.125, -- 1/8 max HP
		Duration = {Min = 1, Max = 8},
	},
	BadlyPoisoned = {
		DamagePerTurn = 0.0625, -- aumenta a cada turno
		DamageIncrease = 0.0625,
		Duration = {Min = 1, Max = 8},
	},
	Paralysis = {
		SpeedReduction = 0.5,
		ChanceToFail = 0.25,
		Duration = {Min = 1, Max = 7},
	},
	Sleep = {
		Duration = {Min = 1, Max = 3},
		ChanceToWake = 0.2,
	},
	Freeze = {
		Duration = {Min = 1, Max = 5},
		ChanceToThaw = 0.2,
		FireThaws = true,
	},
	Confusion = {
		Duration = {Min = 1, Max = 4},
		SelfDamageChance = 0.33,
		SelfDamagePower = 40,
	},
}

-- Naturezas e modificadores de stats
Config.Natures = {
	Hardy = {Atk = 1.0, Def = 1.0, SpA = 1.0, SpD = 1.0, Spe = 1.0},
	Lonely = {Atk = 1.1, Def = 0.9, SpA = 1.0, SpD = 1.0, Spe = 1.0},
	Brave = {Atk = 1.1, Def = 1.0, SpA = 1.0, SpD = 1.0, Spe = 0.9},
	Adamant = {Atk = 1.1, Def = 1.0, SpA = 0.9, SpD = 1.0, Spe = 1.0},
	Naughty = {Atk = 1.1, Def = 1.0, SpA = 1.0, SpD = 0.9, Spe = 1.0},
	Bold = {Atk = 0.9, Def = 1.1, SpA = 1.0, SpD = 1.0, Spe = 1.0},
	Docile = {Atk = 1.0, Def = 1.0, SpA = 1.0, SpD = 1.0, Spe = 1.0},
	Relaxed = {Atk = 1.0, Def = 1.1, SpA = 1.0, SpD = 1.0, Spe = 0.9},
	Impish = {Atk = 1.0, Def = 1.1, SpA = 0.9, SpD = 1.0, Spe = 1.0},
	Lax = {Atk = 1.0, Def = 1.1, SpA = 1.0, SpD = 0.9, Spe = 1.0},
	Timid = {Atk = 0.9, Def = 1.0, SpA = 1.1, SpD = 1.0, Spe = 1.0},
	Hasty = {Atk = 1.0, Def = 0.9, SpA = 1.1, SpD = 1.0, Spe = 1.0},
	Serious = {Atk = 1.0, Def = 1.0, SpA = 1.0, SpD = 1.0, Spe = 1.0},
	Jolly = {Atk = 1.0, Def = 1.0, SpA = 1.0, SpD = 1.0, Spe = 1.1},
	Naive = {Atk = 1.0, Def = 1.0, SpA = 0.9, SpD = 1.0, Spe = 1.1},
	Modest = {Atk = 0.9, Def = 1.0, SpA = 1.1, SpD = 1.0, Spe = 1.0},
	Mild = {Atk = 1.0, Def = 0.9, SpA = 1.1, SpD = 1.0, Spe = 1.0},
	Quiet = {Atk = 1.0, Def = 1.0, SpA = 1.1, SpD = 1.0, Spe = 0.9},
	Bashful = {Atk = 1.0, Def = 1.0, SpA = 1.0, SpD = 1.0, Spe = 1.0},
	Rash = {Atk = 1.0, Def = 1.0, SpA = 1.1, SpD = 0.9, Spe = 1.0},
	Calm = {Atk = 0.9, Def = 1.0, SpA = 1.0, SpD = 1.1, Spe = 1.0},
	Gentle = {Atk = 1.0, Def = 0.9, SpA = 1.0, SpD = 1.1, Spe = 1.0},
	Sassy = {Atk = 1.0, Def = 1.0, SpA = 1.0, SpD = 1.1, Spe = 0.9},
	Careful = {Atk = 1.0, Def = 1.0, SpA = 0.9, SpD = 1.1, Spe = 1.0},
	Quirky = {Atk = 1.0, Def = 1.0, SpA = 1.0, SpD = 1.0, Spe = 1.0},
}

-- Itens base
Config.Items = {
	-- Bolas
	BasicBall = {Id = "BasicBall", Name = "Esfera Básica", CaptureRate = 1.0, Price = 200},
	GreatBall = {Id = "GreatBall", Name = "Esfera Superior", CaptureRate = 1.5, Price = 600},
	UltraBall = {Id = "UltraBall", Name = "Esfera Ultra", CaptureRate = 2.0, Price = 1200},
	MasterBall = {Id = "MasterBall", Name = "Esfera Mestra", CaptureRate = 255, Price = 0},

	-- Medicinas
	Potion = {Id = "Potion", Name = "Poção", HealAmount = 20, Price = 300},
	SuperPotion = {Id = "SuperPotion", Name = "Super Poção", HealAmount = 50, Price = 700},
	HyperPotion = {Id = "HyperPotion", Name = "Hiper Poção", HealAmount = 200, Price = 1200},
	MaxPotion = {Id = "MaxPotion", Name = "Max Poção", HealAmount = -1, Price = 2500}, -- -1 = full heal
	Antidote = {Id = "Antidote", Name = "Antídoto", Cures = "Poison", Price = 100},
	BurnHeal = {Id = "BurnHeal", Name = "Cura Queimadura", Cures = "Burn", Price = 250},
	IceHeal = {Id = "IceHeal", Name = "Cura Congelamento", Cures = "Freeze", Price = 250},
	Awakening = {Id = "Awakening", Name = "Despertar", Cures = "Sleep", Price = 250},
	ParalyzeHeal = {Id = "ParalyzeHeal", Name = "Cura Paralisia", Cures = "Paralysis", Price = 200},
	FullHeal = {Id = "FullHeal", Name = "Cura Total", Cures = "All", Price = 600},
	Revive = {Id = "Revive", Name = "Reviver", RevivesWithHP = 0.5, Price = 1500},
	MaxRevive = {Id = "MaxRevive", Name = "Max Reviver", RevivesWithHP = 1.0, Price = 4000},

	-- PP
	Ether = {Id = "Ether", Name = "Éter", PPRestore = 10, Price = 1200},
	MaxEther = {Id = "MaxEther", Name = "Max Éter", PPRestore = -1, Price = 2000},
	Elixir = {Id = "Elixir", Name = "Elixir", PPRestore = 10, AllMoves = true, Price = 1500},
	MaxElixir = {Id = "MaxElixir", Name = "Max Elixir", PPRestore = -1, AllMoves = true, Price = 2500},

	-- Evolution stones
	FireStone = {Id = "FireStone", Name = "Pedra de Fogo", Evolves = {"Fire"}, Price = 2100},
	WaterStone = {Id = "WaterStone", Name = "Pedra de Água", Evolves = {"Water"}, Price = 2100},
	NatureStone = {Id = "NatureStone", Name = "Pedra da Natureza", Evolves = {"Nature"}, Price = 2100},
	EarthStone = {Id = "EarthStone", Name = "Pedra da Terra", Evolves = {"Earth"}, Price = 2100},
	AirStone = {Id = "AirStone", Name = "Pedra do Ar", Evolves = {"Air"}, Price = 2100},
	ShadowStone = {Id = "ShadowStone", Name = "Pedra da Sombra", Evolves = {"Shadow"}, Price = 2100},
}

-- Zonas/biomas (posições alinhadas com ilhas exportadas do Blender)
Config.Zones = {
	StarterTown = {
		Id = "StarterTown",
		Name = "Vila Inicial",
		Biome = "Nature",
		LevelRange = {Min = 1, Max = 5},
		SafeZone = true,
		IslandPosition = Vector3.new(0, 0, 0),
		IslandSize = 80,
		NPCs = {
			{
				Id = "Professor",
				Name = "Professor Carvalho",
				Type = "QuestGiver",
				Position = CFrame.new(0, 5, 0),
				Dialogue = {
					Greeting = "Bem-vindo ao Arquipélago das Feras! Escolha seu primeiro parceiro!",
					QuestComplete = "Excelente! Agora você está pronto para sua jornada.",
				},
			},
			{
				Id = "StarterTown_Healer",
				Name = "Enfermeira Joy",
				Type = "Healer",
				Position = CFrame.new(20, 5, 0),
				Dialogue = {
					Greeting = "Suas criaturas precisam de cuidados? Deixe comigo!",
				},
			},
			{
				Id = "StarterTown_Shop",
				Name = "Mercador Local",
				Type = "Shopkeeper",
				Position = CFrame.new(-20, 5, 0),
				Dialogue = {
					Greeting = "Itens essenciais para sua aventura!",
				},
				ShopInventory = {"BasicBall", "Potion", "Antidote"},
			},
			{
				Id = "Rival1",
				Name = "Rival Lucas",
				Type = "Trainer",
				Position = CFrame.new(0, 5, 30),
				Team = {
					{SpeciesId = "CINZELO", Level = 5, Moves = {"Scratch", "Ember"}},
				},
				RewardMoney = 300,
				RewardItems = {"Potion"},
				Dialogue = {
					Greeting = "Vamos batalhar! Meu Cinzelo está ansioso!",
					Win = "Incrível! Você é forte!",
					Lose = "Hmph, da próxima vez eu vencerei!",
				},
				PatrolPoints = {
					CFrame.new(0, 5, 30),
					CFrame.new(10, 5, 30),
					CFrame.new(10, 5, 40),
					CFrame.new(0, 5, 40),
				},
			},
		},
	},
	FireForest = {
		Id = "FireForest",
		Name = "Floresta de Brasas",
		Biome = "Fire",
		LevelRange = {Min = 3, Max = 12},
		Spawns = {"CINZELO", "MAGMARAU"},
		IslandPosition = Vector3.new(300, 0, 0),
		IslandSize = 100,
		NPCs = {
			{
				Id = "FireForest_Healer",
				Name = "Curandeiro do Fogo",
				Type = "Healer",
				Position = CFrame.new(400, 10, 100),
				Dialogue = {
					Greeting = "O calor da floresta cansou suas criaturas? Eu cuido delas.",
				},
			},
			{
				Id = "FireForest_Shop",
				Name = "Mercador das Brasas",
				Type = "Shopkeeper",
				Position = CFrame.new(420, 10, 80),
				Dialogue = {
					Greeting = "Itens resistentes ao calor para exploradores!",
				},
				ShopInventory = {"BasicBall", "GreatBall", "Potion", "SuperPotion", "BurnHeal"},
			},
			{
				Id = "FireTrainer1",
				Name = "Treinador de Fogo Brasa",
				Type = "Trainer",
				Position = CFrame.new(450, 10, 150),
				Team = {
					{SpeciesId = "CINZELO", Level = 8, Moves = {"Scratch", "Ember", "Fire Fang"}},
					{SpeciesId = "MAGMARAU", Level = 10, Moves = {"Ember", "Rock Throw", "Flame Burst"}},
				},
				RewardMoney = 800,
				RewardItems = {"FireStone"},
				Dialogue = {
					Greeting = "Sinta o calor das chamas!",
					Win = "Suas chamas queimam forte!",
					Lose = "O fogo nunca se apaga...",
				},
				PatrolPoints = {
					CFrame.new(450, 10, 150),
					CFrame.new(470, 10, 170),
					CFrame.new(450, 10, 190),
				},
			},
			{
				Id = "FireForest_Quest",
				Name = "Guarda Florestal",
				Type = "QuestGiver",
				Position = CFrame.new(380, 10, 120),
				Dialogue = {
					Greeting = "Preciso de ajuda para estudar as criaturas desta floresta.",
				},
			},
		},
	},
	WaterCaves = {
		Id = "WaterCaves",
		Name = "Cavernas Aquáticas",
		Biome = "Water",
		LevelRange = {Min = 5, Max = 15},
		Spawns = {"HIDROSONDA", "VAPORAL"},
		IslandPosition = Vector3.new(0, -20, 300),
		IslandSize = 90,
		NPCs = {
			{
				Id = "WaterCaves_Healer",
				Name = "Curandeiro das Águas",
				Type = "Healer",
				Position = CFrame.new(-100, -20, 400),
				Dialogue = {
					Greeting = "A água cura todas as feridas. Deixe-me ajudar.",
				},
			},
			{
				Id = "WaterCaves_Shop",
				Name = "Mercador Submerso",
				Type = "Shopkeeper",
				Position = CFrame.new(-80, -20, 420),
				Dialogue = {
					Greeting = "Equipamentos para exploradores aquáticos!",
				},
				ShopInventory = {"BasicBall", "GreatBall", "Potion", "SuperPotion", "Antidote"},
			},
			{
				Id = "WaterTrainer1",
				Name = "Treinador das Marés",
				Type = "Trainer",
				Position = CFrame.new(-150, -20, 450),
				Team = {
					{SpeciesId = "HIDROSONDA", Level = 10, Moves = {"Water Gun", "Bubble", "Aqua Jet"}},
					{SpeciesId = "VAPORAL", Level = 12, Moves = {"Water Gun", "Mist", "Brine"}},
				},
				RewardMoney = 1000,
				RewardItems = {"WaterStone"},
				Dialogue = {
					Greeting = "As marés estão a seu favor?",
					Win = "Você flui como a água!",
					Lose = "A maré virou...",
				},
			},
		},
	},
	NaturePlains = {
		Id = "NaturePlains",
		Name = "Planícies Verdentes",
		Biome = "Nature",
		LevelRange = {Min = 2, Max = 10},
		Spawns = {"VERDANTIS", "DRYADUS"},
		IslandPosition = Vector3.new(-300, 0, 0),
		IslandSize = 110,
		NPCs = {
			{
				Id = "NaturePlains_Healer",
				Name = "Druida Curandeiro",
				Type = "Healer",
				Position = CFrame.new(-200, 5, 100),
				Dialogue = {
					Greeting = "A natureza restaura o que foi perdido.",
				},
			},
			{
				Id = "NaturePlains_Shop",
				Name = "Botânico Viajante",
				Type = "Shopkeeper",
				Position = CFrame.new(-220, 5, 80),
				Dialogue = {
					Greeting = "Sementes, berries e poções naturais!",
				},
				ShopInventory = {"BasicBall", "GreatBall", "Potion", "SuperPotion", "Antidote", "Awakening"},
			},
			{
				Id = "NatureTrainer1",
				Name = "Guardião da Floresta",
				Type = "Trainer",
				Position = CFrame.new(-250, 5, 150),
				Team = {
					{SpeciesId = "VERDANTIS", Level = 8, Moves = {"Vine Whip", "Razor Leaf", "Growth"}},
					{SpeciesId = "DRYADUS", Level = 10, Moves = {"Absorb", "Leech Seed", "Mega Drain"}},
				},
				RewardMoney = 900,
				RewardItems = {"NatureStone"},
				Dialogue = {
					Greeting = "Respeite a floresta e ela o respeitará.",
					Win = "A natureza reconhece sua força.",
					Lose = "A floresta vai crescer sobre sua derrota...",
				},
			},
		},
	},
	EarthDesert = {
		Id = "EarthDesert",
		Name = "Deserto de Dunas",
		Biome = "Earth",
		LevelRange = {Min = 8, Max = 18},
		Spawns = {"GRAOZINHO", "ESCORPIODRA"},
		IslandPosition = Vector3.new(0, 0, -300),
		IslandSize = 100,
		NPCs = {
			{
				Id = "EarthDesert_Healer",
				Name = "Xamã da Areia",
				Type = "Healer",
				Position = CFrame.new(-100, 5, -400),
				Dialogue = {
					Greeting = "A areia do tempo cura todas as feridas.",
				},
			},
			{
				Id = "EarthDesert_Shop",
				Name = "Comerciante Nômade",
				Type = "Shopkeeper",
				Position = CFrame.new(-80, 5, -420),
				Dialogue = {
					Greeting = "Proteção contra tempestades de areia!",
				},
				ShopInventory = {"GreatBall", "UltraBall", "SuperPotion", "HyperPotion", "ParalyzeHeal"},
			},
			{
				Id = "EarthTrainer1",
				Name = "Mestre das Dunas",
				Type = "Trainer",
				Position = CFrame.new(-150, 5, -450),
				Team = {
					{SpeciesId = "GRAOZINHO", Level = 12, Moves = {"Rock Throw", "Harden", "Rock Tomb"}},
					{SpeciesId = "ESCORPIODRA", Level = 15, Moves = {"Poison Sting", "Rock Slide", "Earthquake"}},
				},
				RewardMoney = 1500,
				RewardItems = {"EarthStone"},
				Dialogue = {
					Greeting = "Minhas criaturas são duras como rocha!",
					Win = "Você tem a solidez da terra!",
					Lose = "Até as montanhas se erodem...",
				},
			},
		},
	},
	AirPeaks = {
		Id = "AirPeaks",
		Name = "Picos Ventosos",
		Biome = "Air",
		LevelRange = {Min = 10, Max = 20},
		Spawns = {"PENUGEM", "VENTANIL"},
		IslandPosition = Vector3.new(200, 150, 200),
		IslandSize = 80,
		NPCs = {
			{
				Id = "AirPeaks_Healer",
				Name = "Sacerdote dos Ventos",
				Type = "Healer",
				Position = CFrame.new(200, 200, 300),
				Dialogue = {
					Greeting = "Os ventos levam embora a dor e o cansaço.",
				},
			},
			{
				Id = "AirPeaks_Shop",
				Name = "Mercador Alado",
				Type = "Shopkeeper",
				Position = CFrame.new(220, 200, 320),
				Dialogue = {
					Greeting = "Leve como uma pena, forte como uma tempestade!",
				},
				ShopInventory = {"GreatBall", "UltraBall", "SuperPotion", "HyperPotion", "Awakening"},
			},
			{
				Id = "AirTrainer1",
				Name = "Mestre dos Céus",
				Type = "Trainer",
				Position = CFrame.new(250, 210, 350),
				Team = {
					{SpeciesId = "PENUGEM", Level = 15, Moves = {"Peck", "Gust", "Wing Attack"}},
					{SpeciesId = "VENTANIL", Level = 18, Moves = {"Air Slash", "Tailwind", "Hurricane"}},
				},
				RewardMoney = 2000,
				RewardItems = {"AirStone"},
				Dialogue = {
					Greeting = "Alcance os céus se puder!",
					Win = "Você voa alto!",
					Lose = "O vento sempre volta...",
				},
			},
		},
	},
	ShadowRuins = {
		Id = "ShadowRuins",
		Name = "Ruínas Sombrias",
		Biome = "Shadow",
		LevelRange = {Min = 12, Max = 22},
		Spawns = {"LODINHO", "CAUDALUME"},
		IslandPosition = Vector3.new(-200, -20, -200),
		IslandSize = 85,
		NPCs = {
			{
				Id = "ShadowRuins_Healer",
				Name = "Curandeiro do Vazio",
				Type = "Healer",
				Position = CFrame.new(-300, -20, -300),
				Dialogue = {
					Greeting = "Mesmo nas sombras mais profundas, há luz.",
				},
			},
			{
				Id = "ShadowRuins_Shop",
				Name = "Mercador das Trevas",
				Type = "Shopkeeper",
				Position = CFrame.new(-280, -20, -320),
				Dialogue = {
					Greeting = "Itens para quem não teme a escuridão.",
				},
				ShopInventory = {"UltraBall", "HyperPotion", "MaxPotion", "FullHeal", "Revive"},
			},
			{
				Id = "ShadowTrainer1",
				Name = "Mestre das Sombras",
				Type = "Trainer",
				Position = CFrame.new(-350, -20, -350),
				Team = {
					{SpeciesId = "LODINHO", Level = 18, Moves = {"Shadow Claw", "Night Shade", "Spite"}},
					{SpeciesId = "CAUDALUME", Level = 20, Moves = {"Dark Pulse", "Phantom Force", "Nasty Plot"}},
				},
				RewardMoney = 2500,
				RewardItems = {"ShadowStone"},
				Dialogue = {
					Greeting = "As sombras sussurram seu nome...",
					Win = "Você brilha mesmo na escuridão.",
					Lose = "A escuridão o engoliu por completo...",
				},
			},
		},
	},
	VolcanoIsle = {
		Id = "VolcanoIsle",
		Name = "Ilha Vulcânica",
		Biome = "Fire",
		LevelRange = {Min = 20, Max = 35},
		Spawns = {"CINZELO", "MAGMARAU", "FENIXFULIGEM", "VULCANODRAGO"},
		IslandPosition = Vector3.new(350, 0, 350),
		IslandSize = 60,
		NPCs = {
			{
				Id = "VolcanoIsle_Healer",
				Name = "Guardião do Vulcão",
				Type = "Healer",
				Position = CFrame.new(400, 10, 400),
				Dialogue = {
					Greeting = "O fogo purifica tudo. Suas criaturas renascerão das cinzas.",
				},
			},
			{
				Id = "VolcanoIsle_Shop",
				Name = "Ferreira do Núcleo",
				Type = "Shopkeeper",
				Position = CFrame.new(380, 10, 380),
				Dialogue = {
					Greeting = "Forjados no fogo, para quem domina as chamas!",
				},
				ShopInventory = {"UltraBall", "MasterBall", "MaxPotion", "FullHeal", "Revive", "FireStone"},
			},
			{
				Id = "VolcanoTrainer1",
				Name = "Mestre Vulcânico",
				Type = "Trainer",
				Position = CFrame.new(420, 15, 420),
				Team = {
					{SpeciesId = "FENIXFULIGEM", Level = 30, Moves = {"Flare Blitz", "Brave Bird", "Sacred Fire", "Roost"}},
					{SpeciesId = "MAGMARAU", Level = 28, Moves = {"Flare Blitz", "Earthquake", "Stone Edge", "Fire Blast"}},
				},
				RewardMoney = 5000,
				RewardItems = {"FireStone", "MaxRevive"},
				Dialogue = {
					Greeting = "Apenas os fortes sobrevivem ao vulcão!",
					Win = "Suas chamas rivalizam com o núcleo da terra!",
					Lose = "A lava consome tudo...",
				},
			},
		},
	},
}

-- Criaturas base (referência para geração)
Config.SpeciesList = {
	-- Fire
	CINZELO = {Id = "CINZELO", Name = "Cinzelo", Element = "Fire", Rarity = "Common", BaseStats = {HP = 45, Attack = 50, Defense = 40, SpecialAttack = 55, SpecialDefense = 40, Speed = 50}, EvolutionLevel = 16},
	MAGMARAU = {Id = "MAGMARAU", Name = "Magmarau", Element = "Fire", Rarity = "Rare", BaseStats = {HP = 60, Attack = 70, Defense = 55, SpecialAttack = 75, SpecialDefense = 55, Speed = 60}, EvolutionLevel = 36},
	FENIXFULIGEM = {Id = "FENIXFULIGEM", Name = "Fênix Fuligem", Element = "Fire", Rarity = "Epic", BaseStats = {HP = 75, Attack = 85, Defense = 70, SpecialAttack = 95, SpecialDefense = 70, Speed = 90}, EvolutionLevel = 50},
	VULCANODRAGO = {Id = "VULCANODRAGO", Name = "Vulcano Draco", Element = "Fire", Rarity = "Legendary", BaseStats = {HP = 95, Attack = 110, Defense = 90, SpecialAttack = 120, SpecialDefense = 90, Speed = 85}},

	-- Water
	HIDROSONDA = {Id = "HIDROSONDA", Name = "Hidrossonda", Element = "Water", Rarity = "Common", BaseStats = {HP = 50, Attack = 40, Defense = 45, SpecialAttack = 50, SpecialDefense = 55, Speed = 45}, EvolutionLevel = 18},
	VAPORAL = {Id = "VAPORAL", Name = "Vaporal", Element = "Water", Rarity = "Rare", BaseStats = {HP = 65, Attack = 55, Defense = 60, SpecialAttack = 70, SpecialDefense = 70, Speed = 60}, EvolutionLevel = 38},
	LEVIATHAN = {Id = "LEVIATHAN", Name = "Leviatã", Element = "Water", Rarity = "Epic", BaseStats = {HP = 100, Attack = 75, Defense = 85, SpecialAttack = 90, SpecialDefense = 95, Speed = 70}, EvolutionLevel = 55},
	ABYSSALIS = {Id = "ABYSSALIS", Name = "Abissalis", Element = "Water", Rarity = "Legendary", BaseStats = {HP = 110, Attack = 90, Defense = 100, SpecialAttack = 110, SpecialDefense = 110, Speed = 80}},

	-- Nature
	VERDANTIS = {Id = "VERDANTIS", Name = "Verdantis", Element = "Nature", Rarity = "Common", BaseStats = {HP = 55, Attack = 55, Defense = 50, SpecialAttack = 50, SpecialDefense = 50, Speed = 45}, EvolutionLevel = 16},
	DRYADUS = {Id = "DRYADUS", Name = "Dryadus", Element = "Nature", Rarity = "Rare", BaseStats = {HP = 70, Attack = 75, Defense = 65, SpecialAttack = 70, SpecialDefense = 65, Speed = 60}, EvolutionLevel = 36},
	YGGDRASIL = {Id = "YGGDRASIL", Name = "Yggdrasil", Element = "Nature", Rarity = "Epic", BaseStats = {HP = 95, Attack = 90, Defense = 85, SpecialAttack = 95, SpecialDefense = 85, Speed = 70}, EvolutionLevel = 50},
	GAIA_HEART = {Id = "GAIA_HEART", Name = "Coração de Gaia", Element = "Nature", Rarity = "Legendary", BaseStats = {HP = 115, Attack = 100, Defense = 95, SpecialAttack = 105, SpecialDefense = 95, Speed = 80}},

	-- Earth
	GRAOZINHO = {Id = "GRAOZINHO", Name = "Grãozinho", Element = "Earth", Rarity = "Common", BaseStats = {HP = 40, Attack = 60, Defense = 70, SpecialAttack = 30, SpecialDefense = 40, Speed = 30}, EvolutionLevel = 18},
	ESCORPIODRA = {Id = "ESCORPIODRA", Name = "Escorpiodra", Element = "Earth", Rarity = "Rare", BaseStats = {HP = 60, Attack = 85, Defense = 90, SpecialAttack = 45, SpecialDefense = 60, Speed = 55}, EvolutionLevel = 38},
	ESFINGEOLITO = {Id = "ESFINGEOLITO", Name = "Esfingeólito", Element = "Earth", Rarity = "Epic", BaseStats = {HP = 80, Attack = 100, Defense = 110, SpecialAttack = 60, SpecialDefense = 80, Speed = 65}, EvolutionLevel = 52},
	COLOSSODUNE = {Id = "COLOSSODUNE", Name = "Colosso Duna", Element = "Earth", Rarity = "Legendary", BaseStats = {HP = 120, Attack = 115, Defense = 120, SpecialAttack = 70, SpecialDefense = 95, Speed = 60}},

	-- Air
	PENUGEM = {Id = "PENUGEM", Name = "Penugem", Element = "Air", Rarity = "Common", BaseStats = {HP = 35, Attack = 40, Defense = 30, SpecialAttack = 45, SpecialDefense = 35, Speed = 75}, EvolutionLevel = 16},
	VENTANIL = {Id = "VENTANIL", Name = "Ventanil", Element = "Air", Rarity = "Rare", BaseStats = {HP = 55, Attack = 60, Defense = 50, SpecialAttack = 65, SpecialDefense = 55, Speed = 95}, EvolutionLevel = 36},
	TROVORAPTOR = {Id = "TROVORAPTOR", Name = "Trovóraptor", Element = "Air", Rarity = "Epic", BaseStats = {HP = 75, Attack = 90, Defense = 65, SpecialAttack = 95, SpecialDefense = 65, Speed = 115}, EvolutionLevel = 50},
	AERONIMBO = {Id = "AERONIMBO", Name = "Aeronimbo", Element = "Air", Rarity = "Legendary", BaseStats = {HP = 90, Attack = 85, Defense = 80, SpecialAttack = 110, SpecialDefense = 90, Speed = 125}},

	-- Shadow
	LODINHO = {Id = "LODINHO", Name = "Lodinho", Element = "Shadow", Rarity = "Common", BaseStats = {HP = 45, Attack = 35, Defense = 40, SpecialAttack = 50, SpecialDefense = 45, Speed = 50}, EvolutionLevel = 18},
	CAUDALUME = {Id = "CAUDALUME", Name = "Caudalume", Element = "Shadow", Rarity = "Rare", BaseStats = {HP = 60, Attack = 50, Defense = 55, SpecialAttack = 70, SpecialDefense = 65, Speed = 70}, EvolutionLevel = 38},
	VAGALUMORTE = {Id = "VAGALUMORTE", Name = "Vagalumorte", Element = "Shadow", Rarity = "Epic", BaseStats = {HP = 75, Attack = 65, Defense = 70, SpecialAttack = 90, SpecialDefense = 85, Speed = 85}, EvolutionLevel = 50},
	REINEVOENTO = {Id = "REINEVOENTO", Name = "Rei Nevoento", Element = "Shadow", Rarity = "Legendary", BaseStats = {HP = 95, Attack = 80, Defense = 85, SpecialAttack = 105, SpecialDefense = 100, Speed = 95}},

	-- Hybrids
	PIROHIDRO = {Id = "PIROHIDRO", Name = "Pirohidro", Element = "FireWater", Rarity = "Legendary", BaseStats = {HP = 100, Attack = 100, Defense = 90, SpecialAttack = 110, SpecialDefense = 90, Speed = 85}},
	TERRAVENTO = {Id = "TERRAVENTO", Name = "Terravento", Element = "EarthAir", Rarity = "Legendary", BaseStats = {HP = 95, Attack = 110, Defense = 100, SpecialAttack = 80, SpecialDefense = 90, Speed = 100}},
	LUZSOMBRA = {Id = "LUZSOMBRA", Name = "Luzsombra", Element = "NatureShadow", Rarity = "Legendary", BaseStats = {HP = 100, Attack = 90, Defense = 95, SpecialAttack = 105, SpecialDefense = 100, Speed = 85}},
}

return Config