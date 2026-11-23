--!strict
-- Animations.luau - IDs e configurações de animações das criaturas

local Animations = {}

-- Animation IDs (substitua pelos seus asset IDs reais após upload)
-- Formato: rbxassetid://1234567890

-- Animações base compartilhadas (usadas por todas as criaturas)
Animations.Base = {
	Idle = "rbxassetid://0",      -- Parado respirando
	Walk = "rbxassetid://0",      -- Andando
	Run = "rbxassetid://0",       -- Correndo
	Jump = "rbxassetid://0",      -- Pulando
	Fall = "rbxassetid://0",      -- Caindo
	Swim = "rbxassetid://0",      -- Nadando
	Fly = "rbxassetid://0",       -- Voando

	-- Batalha
	BattleIdle = "rbxassetid://0",     -- Parado em batalha
	BattleWalk = "rbxassetid://0",     -- Movendo em batalha
	AttackPhysical = "rbxassetid://0", -- Ataque físico (investida)
	AttackSpecial = "rbxassetid://0",  -- Ataque especial (projetil/magia)
	AttackStatus = "rbxassetid://0",   -- Ataque de status (buff/debuff)
	Hit = "rbxassetid://0",            -- Recebendo dano
	Faint = "rbxassetid://0",          -- Desmaiando

	-- Especiais
	Evolve = "rbxassetid://0",         -- Evoluindo
	Capture = "rbxassetid://0",        -- Sendo capturado
	LevelUp = "rbxassetid://0",        -- Subindo de nível
	LearnMove = "rbxassetid://0",      -- Aprendendo move
}

-- Animações específicas por criatura (override das base)
-- Cada criatura pode ter suas próprias animações únicas
Animations.CreatureSpecific = {
	-- Fire
	CINZELO = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Mordida de brasa
		AttackSpecial = "rbxassetid://0",  -- Lança-chamas pequeno
	},
	MAGMARAU = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Garra de magma
		AttackSpecial = "rbxassetid://0",  -- Erupção
	},
	FENIXFULIGEM = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Investida de cinzas
		AttackSpecial = "rbxassetid://0",  -- Renascimento de fogo
		Evolve = "rbxassetid://0",         -- Transformação em fênix
	},
	VULCANODRAGO = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Garra vulcânica
		AttackSpecial = "rbxassetid://0",  -- Meteoros de lava
		Fly = "rbxassetid://0",
	},

	-- Water
	HIDROSONDA = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Jato d'água
		AttackSpecial = "rbxassetid://0",  -- Bolha explosiva
		Swim = "rbxassetid://0",
	},
	VAPORAL = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Chicote de vapor
		AttackSpecial = "rbxassetid://0",  -- Hidro bomba
		Swim = "rbxassetid://0",
	},
	LEVIATHAN = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Esmagamento de maré
		AttackSpecial = "rbxassetid://0",  -- Tsunami
		Swim = "rbxassetid://0",
	},
	ABYSSALIS = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Garras abissais
		AttackSpecial = "rbxassetid://0",  -- Pressão das profundezas
		Swim = "rbxassetid://0",
	},

	-- Nature
	VERDANTIS = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Chicote de videira
		AttackSpecial = "rbxassetid://0",  -- Semente explosiva
	},
	DRYADUS = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Galhada
		AttackSpecial = "rbxassetid://0",  -- Floresta viva
	},
	YGGDRASIL = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Raízes do mundo
		AttackSpecial = "rbxassetid://0",  -- Renascimento natural
	},
	GAIA_HEART = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Pulso da terra
		AttackSpecial = "rbxassetid://0",  -- Cura gaia
	},

	-- Earth
	GRAOZINHO = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Pedrada
		AttackSpecial = "rbxassetid://0",  -- Tempestade de areia
	},
	ESCORPIODRA = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Ferroada terrestre
		AttackSpecial = "rbxassetid://0",  -- Terremoto
	},
	ESFINGEOLITO = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Golpe de rocha
		AttackSpecial = "rbxassetid://0",  -- Enigma mineral
	},
	COLOSSODUNE = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Esmagamento de duna
		AttackSpecial = "rbxassetid://0",  -- Tempestade de sílica
	},

	-- Air
	PENUGEM = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Bicada de vento
		AttackSpecial = "rbxassetid://0",  -- Rajada
		Fly = "rbxassetid://0",
	},
	VENTANIL = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Garra de vendaval
		AttackSpecial = "rbxassetid://0",  -- Furacão
		Fly = "rbxassetid://0",
	},
	TROVORAPTOR = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Garras de trovão
		AttackSpecial = "rbxassetid://0",  -- Raio celestial
		Fly = "rbxassetid://0",
	},
	AERONIMBO = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Asa de tempestades
		AttackSpecial = "rbxassetid://0",  -- Olho do furacão
		Fly = "rbxassetid://0",
	},

	-- Shadow
	LODINHO = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Garra sombria
		AttackSpecial = "rbxassetid://0",  -- Bola de sombra
	},
	CAUDALUME = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Cauda fantasmal
		AttackSpecial = "rbxassetid://0",  -- Pesadelo
	},
	VAGALUMORTE = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Toque da morte
		AttackSpecial = "rbxassetid://0",  -- Vórtice negro
	},
	REINEVOENTO = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Decreto sombrio
		AttackSpecial = "rbxassetid://0",  -- Eclipse eterno
		Fly = "rbxassetid://0",
	},

	-- Hybrids
	PIROHIDRO = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Vapor escaldante
		AttackSpecial = "rbxassetid://0",  -- Geyser de magma
		Evolve = "rbxassetid://0",         -- Fusão fogo/água
	},
	TERRAVENTO = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Tornado de rocha
		AttackSpecial = "rbxassetid://0",  -- Tempestade de areia cortante
		Fly = "rbxassetid://0",
	},
	LUZSOMBRA = {
		Idle = "rbxassetid://0",
		AttackPhysical = "rbxassetid://0", -- Luz crepuscular
		AttackSpecial = "rbxassetid://0",  -- Equilíbrio quebrado
		Fly = "rbxassetid://0",
		Evolve = "rbxassetid://0",         -- Ascensão crepuscular
	},
}

-- Configurações de animação por tipo de move
Animations.MoveTypeConfig = {
	Physical = {
		Animation = "AttackPhysical",
		Duration = 1.0,
		HitFrame = 0.4, -- Frame onde o dano é aplicado (0-1)
		Sound = "MovePhysical",
		Effect = "PhysicalHit",
	},
	Special = {
		Animation = "AttackSpecial",
		Duration = 1.5,
		HitFrame = 0.6,
		Sound = "MoveSpecial",
		Effect = "SpecialHit",
	},
	Status = {
		Animation = "AttackStatus",
		Duration = 1.0,
		HitFrame = 0.5,
		Sound = "MoveStatus",
		Effect = "StatusEffect",
	},
}

-- Função para obter animação de uma criatura
function Animations.GetAnimation(speciesId: string, animationName: string): string
	-- Verifica se a criatura tem override específico
	local specific = Animations.CreatureSpecific[speciesId]
	if specific and specific[animationName] then
		return specific[animationName]
	end

	-- Retorna base
	return Animations.Base[animationName] or "rbxassetid://0"
end

-- Função para obter configuração de animação de move
function Animations.GetMoveAnimationConfig(moveCategory: string)
	return Animations.MoveTypeConfig[moveCategory] or Animations.MoveTypeConfig.Physical
end

-- Pré-carregar animações (chamado no cliente)
function Animations.PreloadAnimations()
	local ContentProvider = game:GetService("ContentProvider")
	local assetsToPreload = {}

	-- Coletar todos os IDs únicos
	local allIds = {}

	for _, id in pairs(Animations.Base) do
		if id ~= "rbxassetid://0" then
			table.insert(allIds, id)
		end
	end

	for _, creatureAnims in pairs(Animations.CreatureSpecific) do
		for _, id in pairs(creatureAnims) do
			if id ~= "rbxassetid://0" then
				table.insert(allIds, id)
			end
		end
	end

	-- Remover duplicatas
	local uniqueIds = {}
	local seen = {}
	for _, id in ipairs(allIds) do
		if not seen[id] then
			seen[id] = true
			table.insert(uniqueIds, id)
		end
	end

	-- Pré-carregar
	for _, id in ipairs(uniqueIds) do
		local asset = Instance.new("Animation")
		asset.AnimationId = id
		table.insert(assetsToPreload, asset)
	end

	if #assetsToPreload > 0 then
		ContentProvider:PreloadAsync(assetsToPreload)
		print(`[Animations] Pré-carregadas {#assetsToPreload} animações`)
	end
end

-- Mapeamento de moves para animações customizadas
Animations.MoveAnimations = {
	-- Fire moves
	Flamethrower = {Animation = "AttackSpecial", Sound = "Fire", Effect = "FireBreath"},
	FireBlast = {Animation = "AttackSpecial", Sound = "Fire", Effect = "Explosion"},
	Ember = {Animation = "AttackSpecial", Sound = "Fire", Effect = "Ember"},
	FirePunch = {Animation = "AttackPhysical", Sound = "Fire", Effect = "FirePunch"},
	FlareBlitz = {Animation = "AttackPhysical", Sound = "Fire", Effect = "FlareBlitz"},
	LavaPlume = {Animation = "AttackSpecial", Sound = "Fire", Effect = "LavaPlume"},

	-- Water moves
	HydroPump = {Animation = "AttackSpecial", Sound = "Water", Effect = "HydroPump"},
	Surf = {Animation = "AttackSpecial", Sound = "Water", Effect = "Surf"},
	WaterPulse = {Animation = "AttackSpecial", Sound = "Water", Effect = "WaterPulse"},
	AquaJet = {Animation = "AttackPhysical", Sound = "Water", Effect = "AquaJet"},
	HydroCannon = {Animation = "AttackSpecial", Sound = "Water", Effect = "HydroCannon"},

	-- Nature moves
	RazorLeaf = {Animation = "AttackSpecial", Sound = "Nature", Effect = "RazorLeaf"},
	SolarBeam = {Animation = "AttackSpecial", Sound = "Nature", Effect = "SolarBeam"},
	SeedBomb = {Animation = "AttackSpecial", Sound = "Nature", Effect = "SeedBomb"},
	PetalDance = {Animation = "AttackPhysical", Sound = "Nature", Effect = "PetalDance"},
	GigaDrain = {Animation = "AttackSpecial", Sound = "Nature", Effect = "GigaDrain"},

	-- Earth moves
	Earthquake = {Animation = "AttackSpecial", Sound = "Earth", Effect = "Earthquake"},
	RockSlide = {Animation = "AttackSpecial", Sound = "Earth", Effect = "RockSlide"},
	EarthPower = {Animation = "AttackSpecial", Sound = "Earth", Effect = "EarthPower"},
	Sandstorm = {Animation = "AttackStatus", Sound = "Earth", Effect = "Sandstorm"},
	StoneEdge = {Animation = "AttackPhysical", Sound = "Earth", Effect = "StoneEdge"},

	-- Air moves
	AirSlash = {Animation = "AttackSpecial", Sound = "Air", Effect = "AirSlash"},
	Hurricane = {Animation = "AttackSpecial", Sound = "Air", Effect = "Hurricane"},
	BraveBird = {Animation = "AttackPhysical", Sound = "Air", Effect = "BraveBird"},
	Gust = {Animation = "AttackSpecial", Sound = "Air", Effect = "Gust"},
	SkyAttack = {Animation = "AttackPhysical", Sound = "Air", Effect = "SkyAttack"},

	-- Shadow moves
	ShadowBall = {Animation = "AttackSpecial", Sound = "Shadow", Effect = "ShadowBall"},
	DarkPulse = {Animation = "AttackSpecial", Sound = "Shadow", Effect = "DarkPulse"},
	NightSlash = {Animation = "AttackPhysical", Sound = "Shadow", Effect = "NightSlash"},
	ShadowClaw = {Animation = "AttackPhysical", Sound = "Shadow", Effect = "ShadowClaw"},
	PhantomForce = {Animation = "AttackPhysical", Sound = "Shadow", Effect = "PhantomForce"},

	-- Status moves
	SwordsDance = {Animation = "AttackStatus", Sound = "Success", Effect = "StatUp"},
	CalmMind = {Animation = "AttackStatus", Sound = "Success", Effect = "StatUp"},
	BulkUp = {Animation = "AttackStatus", Sound = "Success", Effect = "StatUp"},
	NastyPlot = {Animation = "AttackStatus", Sound = "Success", Effect = "StatUp"},
	Protect = {Animation = "AttackStatus", Sound = "Success", Effect = "Protect"},
	Rest = {Animation = "AttackStatus", Sound = "Heal", Effect = "Sleep"},
	Recover = {Animation = "AttackStatus", Sound = "Heal", Effect = "Heal"},
}

-- Obter config de animação para um move específico
function Animations.GetMoveAnimation(moveId: string)
	return Animations.MoveAnimations[moveId] or Animations.MoveTypeConfig.Physical
end

return Animations