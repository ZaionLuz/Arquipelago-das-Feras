--!strict
-- Moves.luau - All moves: power, accuracy, PP, effects, animation refs
-- Pure data module, no services or instances

local Moves = {}

export type MoveEffect = {
	type: "status" | "stat" | "heal" | "drain" | "multiHit" | "recharge" | "flinch" | "critBoost" | "protect",
	status: string?,          -- For status effects: "burn", "freeze", "paralyze", "poison", "sleep", "confuse", "fear", "curse", "bless"
	duration: number?,        -- Duration in turns
	chance: number?,          -- 0-1 probability
	stat: string?,            -- For stat changes: "atk", "def", "speed", "spAtk", "spDef", "accuracy", "evasion"
	stages: number?,          -- Number of stages (-6 to +6)
	amount: number?,          -- For heal/drain: ratio of max HP
	drainRatio: number?,      -- For drain moves: ratio of damage healed
	turns: number?,           -- For recharge: turns to wait
}

export type MoveData = {
	id: string,
	name: string,
	element: string,
	category: "physical" | "special" | "status",
	power: number,            -- Base power (0 for status moves)
	accuracy: number,         -- 0-1 (1 = never misses)
	pp: number,               -- Base PP
	priority: number,         -- Move priority (higher = acts first)
	effect: MoveEffect?,      -- Additional effect
	animation: string,        -- Animation reference
	description: string,
	target: "enemy" | "self" | "allies" | "all",
	flags: { string },        -- "contact", "sound", "punch", "bite", "powder", "pulse", "ball", "dance", etc.
}

-- Shape-based signature moves (from Skills)
local ShapeMoves = {
	Blob = { id = "vital_pulse", name = "Pulso Vital", element = "Natureza", power = 60, effect = { type = "heal", amount = 0.125 } },
	Beast = { id = "fierce_charge", name = "Investida Feroz", element = "Terra", power = 90 },
	Bird = { id = "evasive_gust", name = "Rajada Evasiva", element = "Ar", power = 70, effect = { type = "stat", stat = "evasion", stages = 1, chance = 1 } },
	Dragon = { id = "ancestral_breath", name = "Sopro Ancestral", element = "Fogo", power = 100 },
	Serpent = { id = "weakening_coil", name = "Maré Debilitante", element = "Água", power = 65, effect = { type = "stat", stat = "atk", stages = -1, chance = 0.3 } },
	Insect = { id = "sticky_web", name = "Trama Aderente", element = "Natureza", power = 65, effect = { type = "stat", stat = "speed", stages = -1, chance = 0.3 } },
	Quadruped = { id = "tackle", name = "Investida", element = "Normal", power = 50 },
	Winged = { id = "wing_attack", name = "Ataque de Asa", element = "Ar", power = 60 },
	Aquatic = { id = "water_gun", name = "Jato d'Água", element = "Água", power = 45 },
	Arthropod = { id = "bug_bite", name = "Picada", element = "Natureza", power = 55 },
	Mineral = { id = "rock_throw", name = "Lançamento de Rocha", element = "Terra", power = 50 },
	Spectral = { id = "shadow_sneak", name = "Golpe Sombrio", element = "Sombra", power = 50, priority = 1 },
	Vegetal = { id = "vine_whip", name = "Chicote de Vinha", element = "Natureza", power = 50 },
	Draconic = { id = "dragon_rage", name = "Fúria Draconica", element = "Fogo", power = 80 },
}

-- Universal moves available to many creatures
local UniversalMoves: { [string]: MoveData } = {
	-- Physical moves
	tackle = {
		id = "tackle", name = "Investida", element = "Normal", category = "physical",
		power = 40, accuracy = 1, pp = 35, priority = 0,
		animation = "tackle", description = "Uma investida física básica.", target = "enemy", flags = { "contact" }
	},
	scratch = {
		id = "scratch", name = "Arranhão", element = "Normal", category = "physical",
		power = 40, accuracy = 1, pp = 35, priority = 0,
		animation = "scratch", description = "Arranha o inimigo com garras afiadas.", target = "enemy", flags = { "contact" }
	},
	quick_attack = {
		id = "quick_attack", name = "Ataque Rápido", element = "Normal", category = "physical",
		power = 40, accuracy = 1, pp = 30, priority = 1,
		animation = "quick_attack", description = "Ataca primeiro. Sempre acerta.", target = "enemy", flags = { "contact" }
	},
	-- Fire moves
	ember = {
		id = "ember", name = "Brasa", element = "Fogo", category = "special",
		power = 40, accuracy = 1, pp = 25, priority = 0,
		effect = { type = "status", status = "burn", chance = 0.1, duration = 3 },
		animation = "ember", description = "Pequena chance de queimar.", target = "enemy", flags = {}
	},
	flamethrower = {
		id = "flamethrower", name = "Lança-Chamas", element = "Fogo", category = "special",
		power = 90, accuracy = 1, pp = 15, priority = 0,
		effect = { type = "status", status = "burn", chance = 0.1, duration = 3 },
		animation = "flamethrower", description = "Chamas intensas que podem queimar.", target = "enemy", flags = {}
	},
	fire_blast = {
		id = "fire_blast", name = "Explosão de Fogo", element = "Fogo", category = "special",
		power = 110, accuracy = 0.85, pp = 5, priority = 0,
		effect = { type = "status", status = "burn", chance = 0.1, duration = 3 },
		animation = "fire_blast", description = "Poderoso, mas impreciso.", target = "enemy", flags = {}
	},
	flare_blitz = {
		id = "flare_blitz", name = "Ímpeto de Chamas", element = "Fogo", category = "physical",
		power = 120, accuracy = 1, pp = 15, priority = 0,
		effect = { type = "status", status = "burn", chance = 0.1, duration = 3 },
		animation = "flare_blitz", description = "Usuário recebe dano de recuo.", target = "enemy", flags = { "contact", "recoil" }
	},
	-- Water moves
	water_gun = {
		id = "water_gun", name = "Jato d'Água", element = "Água", category = "special",
		power = 40, accuracy = 1, pp = 25, priority = 0,
		animation = "water_gun", description = "Jato de água pressurizada.", target = "enemy", flags = {}
	},
	bubble = {
		id = "bubble", name = "Bolha", element = "Água", category = "special",
		power = 40, accuracy = 1, pp = 30, priority = 0,
		effect = { type = "stat", stat = "speed", stages = -1, chance = 0.1 },
		animation = "bubble", description = "Pode reduzir velocidade.", target = "enemy", flags = {}
	},
	hydro_pump = {
		id = "hydro_pump", name = "Hidro Bomba", element = "Água", category = "special",
		power = 110, accuracy = 0.8, pp = 5, priority = 0,
		animation = "hydro_pump", description = "Poderoso, mas impreciso.", target = "enemy", flags = {}
	},
	surf = {
		id = "surf", name = "Surfar", element = "Água", category = "special",
		power = 90, accuracy = 1, pp = 15, priority = 0,
		animation = "surf", description = "Onda massiva atinge o alvo.", target = "enemy", flags = {}
	},
	aquajet = {
		id = "aquajet", name = "Jato Aquático", element = "Água", category = "physical",
		power = 40, accuracy = 1, pp = 20, priority = 1,
		animation = "aquajet", description = "Ataca primeiro.", target = "enemy", flags = { "contact" }
	},
	-- Nature/Grass moves
	vine_whip = {
		id = "vine_whip", name = "Chicote de Vinha", element = "Natureza", category = "physical",
		power = 45, accuracy = 1, pp = 25, priority = 0,
		animation = "vine_whip", description = "Chicoteia com vinhas.", target = "enemy", flags = { "contact" }
	},
	razor_leaf = {
		id = "razor_leaf", name = "Folha Navalha", element = "Natureza", category = "special",
		power = 55, accuracy = 0.95, pp = 25, priority = 0,
		animation = "razor_leaf", description = "Alta taxa de crítico.", target = "enemy", flags = {}
	},
	seed_bomb = {
		id = "seed_bomb", name = "Bomba de Sementes", element = "Natureza", category = "physical",
		power = 80, accuracy = 1, pp = 15, priority = 0,
		animation = "seed_bomb", description = "Explosão de sementes duras.", target = "enemy", flags = { "bullet" }
	},
	petal_dance = {
		id = "petal_dance", name = "Dança de Pétalas", element = "Natureza", category = "special",
		power = 120, accuracy = 1, pp = 10, priority = 0,
		effect = { type = "recharge", turns = 1 },
		animation = "petal_dance", description = "Ataca por 2-3 turnos, então confunde.", target = "enemy", flags = {}
	},
	-- Earth/Ground moves
	rock_throw = {
		id = "rock_throw", name = "Lançamento de Rocha", element = "Terra", category = "physical",
		power = 50, accuracy = 0.9, pp = 15, priority = 0,
		animation = "rock_throw", description = "Arremessa pedras.", target = "enemy", flags = {}
	},
	mud_shot = {
		id = "mud_shot", name = "Tiro de Lama", element = "Terra", category = "special",
		power = 55, accuracy = 0.95, pp = 15, priority = 0,
		effect = { type = "stat", stat = "speed", stages = -1, chance = 1 },
		animation = "mud_shot", description = "Sempre reduz velocidade.", target = "enemy", flags = {}
	},
	earthquake = {
		id = "earthquake", name = "Terremoto", element = "Terra", category = "physical",
		power = 100, accuracy = 1, pp = 10, priority = 0,
		animation = "earthquake", description = "Atinge todos adjacentes.", target = "all", flags = {}
	},
	drill_run = {
		id = "drill_run", name = "Perfuradora", element = "Terra", category = "physical",
		power = 80, accuracy = 0.95, pp = 10, priority = 0,
		animation = "drill_run", description = "Alta taxa de crítico.", target = "enemy", flags = { "contact" }
	},
	-- Air/Flying moves
	wing_attack = {
		id = "wing_attack", name = "Ataque de Asa", element = "Ar", category = "physical",
		power = 60, accuracy = 1, pp = 35, priority = 0,
		animation = "wing_attack", description = "Bate as asas com força.", target = "enemy", flags = { "contact" }
	},
	gust = {
		id = "gust", name = "Rajada", element = "Ar", category = "special",
		power = 40, accuracy = 1, pp = 35, priority = 0,
		animation = "gust", description = "Vento forte.", target = "enemy", flags = {}
	},
	air_slash = {
		id = "air_slash", name = "Corte de Ar", element = "Ar", category = "special",
		power = 75, accuracy = 0.95, pp = 15, priority = 0,
		effect = { type = "flinch", chance = 0.3 },
		animation = "air_slash", description = "Pode fazer o alvo recuar.", target = "enemy", flags = {}
	},
	hurricane = {
		id = "hurricane", name = "Furacão", element = "Ar", category = "special",
		power = 110, accuracy = 0.7, pp = 10, priority = 0,
		effect = { type = "status", status = "confuse", chance = 0.3, duration = 2 },
		animation = "hurricane", description = "Pode confundir.", target = "enemy", flags = {}
	},
	-- Shadow/Dark moves
	shadow_sneak = {
		id = "shadow_sneak", name = "Golpe Sombrio", element = "Sombra", category = "physical",
		power = 40, accuracy = 1, pp = 30, priority = 1,
		animation = "shadow_sneak", description = "Ataca primeiro.", target = "enemy", flags = { "contact" }
	},
	dark_pulse = {
		id = "dark_pulse", name = "Pulso Sombrio", element = "Sombra", category = "special",
		power = 80, accuracy = 1, pp = 15, priority = 0,
		effect = { type = "flinch", chance = 0.2 },
		animation = "dark_pulse", description = "Onda de energia sombria.", target = "enemy", flags = {}
	},
	night_slash = {
		id = "night_slash", name = "Golpe Noturno", element = "Sombra", category = "physical",
		power = 70, accuracy = 1, pp = 15, priority = 0,
		animation = "night_slash", description = "Alta taxa de crítico.", target = "enemy", flags = { "contact" }
	},
	-- Ice moves
	ice_shard = {
		id = "ice_shard", name = "Estilhaço de Gelo", element = "Gelo", category = "physical",
		power = 40, accuracy = 1, pp = 30, priority = 1,
		animation = "ice_shard", description = "Ataca primeiro.", target = "enemy", flags = { "contact" }
	},
	ice_beam = {
		id = "ice_beam", name = "Raio de Gelo", element = "Gelo", category = "special",
		power = 90, accuracy = 1, pp = 10, priority = 0,
		effect = { type = "status", status = "freeze", chance = 0.1, duration = 3 },
		animation = "ice_beam", description = "Pode congelar.", target = "enemy", flags = {}
	},
	blizzard = {
		id = "blizzard", name = "Nevasca", element = "Gelo", category = "special",
		power = 110, accuracy = 0.7, pp = 5, priority = 0,
		effect = { type = "status", status = "freeze", chance = 0.1, duration = 3 },
		animation = "blizzard", description = "Pode congelar. Impreciso.", target = "enemy", flags = {}
	},
	-- Electric moves
	thunder_shock = {
		id = "thunder_shock", name = "Choque do Trovão", element = "Elétrico", category = "special",
		power = 40, accuracy = 1, pp = 30, priority = 0,
		effect = { type = "status", status = "paralyze", chance = 0.1, duration = 3 },
		animation = "thunder_shock", description = "Pode paralisar.", target = "enemy", flags = {}
	},
	thunderbolt = {
		id = "thunderbolt", name = "Raio", element = "Elétrico", category = "special",
		power = 90, accuracy = 1, pp = 15, priority = 0,
		effect = { type = "status", status = "paralyze", chance = 0.1, duration = 3 },
		animation = "thunderbolt", description = "Pode paralisar.", target = "enemy", flags = {}
	},
	thunder = {
		id = "thunder", name = "Trovão", element = "Elétrico", category = "special",
		power = 110, accuracy = 0.7, pp = 10, priority = 0,
		effect = { type = "status", status = "paralyze", chance = 0.3, duration = 3 },
		animation = "thunder", description = "Pode paralisar. Impreciso.", target = "enemy", flags = {}
	},
	volt_tackle = {
		id = "volt_tackle", name = "Investida Elétrica", element = "Elétrico", category = "physical",
		power = 120, accuracy = 1, pp = 15, priority = 0,
		effect = { type = "status", status = "paralyze", chance = 0.1, duration = 3 },
		animation = "volt_tackle", description = "Recuo forte. Pode paralisar.", target = "enemy", flags = { "contact", "recoil" }
	},
	-- Light moves
	flash = {
		id = "flash", name = "Flash", element = "Luz", category = "status",
		power = 0, accuracy = 1, pp = 20, priority = 0,
		effect = { type = "stat", stat = "accuracy", stages = -1, chance = 1 },
		animation = "flash", description = "Reduz precisão do inimigo.", target = "enemy", flags = {}
	},
	dazzling_gleam = {
		id = "dazzling_gleam", name = "Brilho Ofuscante", element = "Luz", category = "special",
		power = 80, accuracy = 1, pp = 10, priority = 0,
		animation = "dazzling_gleam", description = "Luz mágica atinge o alvo.", target = "enemy", flags = {}
	},
	morning_sun = {
		id = "morning_sun", name = "Sol da Manhã", element = "Luz", category = "status",
		power = 0, accuracy = 1, pp = 5, priority = 0,
		effect = { type = "heal", amount = 0.5 },
		animation = "morning_sun", description = "Recupera 50% do HP máximo.", target = "self", flags = {}
	},
	-- Metal/Steel moves
	metal_claw = {
		id = "metal_claw", name = "Garra Metálica", element = "Metal", category = "physical",
		power = 50, accuracy = 0.95, pp = 35, priority = 0,
		effect = { type = "stat", stat = "atk", stages = 1, chance = 0.1 },
		animation = "metal_claw", description = "Pode aumentar ataque.", target = "enemy", flags = { "contact" }
	},
	iron_head = {
		id = "iron_head", name = "Cabeçada de Ferro", element = "Metal", category = "physical",
		power = 80, accuracy = 1, pp = 15, priority = 0,
		effect = { type = "flinch", chance = 0.3 },
		animation = "iron_head", description = "Pode fazer recuar.", target = "enemy", flags = { "contact" }
	},
	flash_cannon = {
		id = "flash_cannon", name = "Canhão de Luz", element = "Metal", category = "special",
		power = 80, accuracy = 1, pp = 10, priority = 0,
		effect = { type = "stat", stat = "spDef", stages = -1, chance = 0.1 },
		animation = "flash_cannon", description = "Pode reduzir def. especial.", target = "enemy", flags = {}
	},
	-- Crystal moves
	power_gem = {
		id = "power_gem", name = "Joia de Poder", element = "Cristal", category = "special",
		power = 80, accuracy = 1, pp = 20, priority = 0,
		animation = "power_gem", description = "Dispara joias afiadas.", target = "enemy", flags = {}
	},
	diamond_storm = {
		id = "diamond_storm", name = "Tempestade de Diamantes", element = "Cristal", category = "physical",
		power = 100, accuracy = 0.95, pp = 5, priority = 0,
		effect = { type = "stat", stat = "def", stages = 2, chance = 0.5 },
		animation = "diamond_storm", description = "Pode aumentar defesa drasticamente.", target = "enemy", flags = {}
	},
	-- Arcane/Psychic moves
	confusion = {
		id = "confusion", name = "Confusão", element = "Arcano", category = "special",
		power = 50, accuracy = 1, pp = 25, priority = 0,
		effect = { type = "status", status = "confuse", chance = 0.1, duration = 2 },
		animation = "confusion", description = "Pode confundir.", target = "enemy", flags = {}
	},
	psychic = {
		id = "psychic", name = "Psíquico", element = "Arcano", category = "special",
		power = 90, accuracy = 1, pp = 10, priority = 0,
		effect = { type = "stat", stat = "spDef", stages = -1, chance = 0.1 },
		animation = "psychic", description = "Pode reduzir def. especial.", target = "enemy", flags = {}
	},
	future_sight = {
		id = "future_sight", name = "Previsão Futura", element = "Arcano", category = "special",
		power = 120, accuracy = 1, pp = 10, priority = 0,
		effect = { type = "recharge", turns = 2 },
		animation = "future_sight", description = "Acerta 2 turnos depois.", target = "enemy", flags = {}
	},
	-- Status moves
	growl = {
		id = "growl", name = "Rosnado", element = "Normal", category = "status",
		power = 0, accuracy = 1, pp = 40, priority = 0,
		effect = { type = "stat", stat = "atk", stages = -1, chance = 1 },
		animation = "growl", description = "Reduz ataque do inimigo.", target = "enemy", flags = { "sound" }
	},
	tail_whip = {
		id = "tail_whip", name = "Chicote de Cauda", element = "Normal", category = "status",
		power = 0, accuracy = 1, pp = 30, priority = 0,
		effect = { type = "stat", stat = "def", stages = -1, chance = 1 },
		animation = "tail_whip", description = "Reduz defesa do inimigo.", target = "enemy", flags = {}
	},
	harden = {
		id = "harden", name = "Endurecer", element = "Normal", category = "status",
		power = 0, accuracy = 1, pp = 30, priority = 0,
		effect = { type = "stat", stat = "def", stages = 1, chance = 1 },
		animation = "harden", description = "Aumenta própria defesa.", target = "self", flags = {}
	},
	recover = {
		id = "recover", name = "Recuperação", element = "Normal", category = "status",
		power = 0, accuracy = 1, pp = 10, priority = 0,
		effect = { type = "heal", amount = 0.5 },
		animation = "recover", description = "Recupera 50% do HP.", target = "self", flags = {}
	},
	protect = {
		id = "protect", name = "Proteção", element = "Normal", category = "status",
		power = 0, accuracy = 1, pp = 10, priority = 4,
		effect = { type = "protect" },
		animation = "protect", description = "Evita todos os efeitos do turno.", target = "self", flags = {}
	},
	rest = {
		id = "rest", name = "Descanso", element = "Normal", category = "status",
		power = 0, accuracy = 1, pp = 5, priority = 0,
		effect = { type = "heal", amount = 1, status = "sleep", duration = 2 },
		animation = "rest", description = "Cura tudo, mas dorme 2 turnos.", target = "self", flags = {}
	},
	calm_mind = {
		id = "calm_mind", name = "Mente Calma", element = "Arcano", category = "status",
		power = 0, accuracy = 1, pp = 20, priority = 0,
		effect = { type = "stat", stat = "spAtk", stages = 1, chance = 1 },
		animation = "calm_mind", description = "Aumenta atq. e def. especial.", target = "self", flags = {}
	},
	swords_dance = {
		id = "swords_dance", name = "Dança de Espadas", element = "Normal", category = "status",
		power = 0, accuracy = 1, pp = 20, priority = 0,
		effect = { type = "stat", stat = "atk", stages = 2, chance = 1 },
		animation = "swords_dance", description = "Aumenta ataque drasticamente.", target = "self", flags = { "dance" }
	},
	-- Signature moves for legendaries
	solar_flare = {
		id = "solar_flare", name = "Erupção Solar", element = "Fogo", category = "special",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "status", status = "burn", chance = 0.3, duration = 4 },
		animation = "solar_flare", description = "Chamas solares devastadoras.", target = "enemy", flags = {}
	},
	abyssal_depths = {
		id = "abyssal_depths", name = "Profundezas Abissais", element = "Água", category = "special",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "stat", stat = "spDef", stages = -2, chance = 0.3 },
		animation = "abyssal_depths", description = "Pressão das profundezas.", target = "enemy", flags = {}
	},
	primordial_force = {
		id = "primordial_force", name = "Força Primordial", element = "Natureza", category = "physical",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "heal", amount = 0.25, drainRatio = 0.5 },
		animation = "primordial_force", description = "Cura 25% do dano causado.", target = "enemy", flags = { "contact" }
	},
	tectonic_upheaval = {
		id = "tectonic_upheaval", name = "Reviravolta Tectônica", element = "Terra", category = "physical",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "stat", stat = "speed", stages = -1, chance = 1 },
		animation = "tectonic_upheaval", description = "Sempre reduz velocidade.", target = "all", flags = {}
	},
	celestial_winds = {
		id = "celestial_winds", name = "Ventos Celestiais", element = "Ar", category = "special",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "flinch", chance = 0.3 },
		animation = "celestial_winds", description = "Ventos divinos.", target = "enemy", flags = {}
	},
	shadow_realm = {
		id = "shadow_realm", name = "Reino das Sombras", element = "Sombra", category = "special",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "status", status = "fear", chance = 0.3, duration = 3 },
		animation = "shadow_realm", description = "Mergulha o alvo no medo.", target = "enemy", flags = {}
	},
	absolute_zero = {
		id = "absolute_zero", name = "Zero Absoluto", element = "Gelo", category = "special",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "status", status = "freeze", chance = 0.3, duration = 4 },
		animation = "absolute_zero", description = "Frio impossível.", target = "enemy", flags = {}
	},
	bolt_strike = {
		id = "bolt_strike", name = "Golpe do Raio", element = "Elétrico", category = "physical",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "status", status = "paralyze", chance = 0.3, duration = 4 },
		animation = "bolt_strike", description = "Raio concentrado.", target = "enemy", flags = { "contact" }
	},
	holy_nova = {
		id = "holy_nova", name = "Nova Sagrada", element = "Luz", category = "special",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "heal", amount = 0.25 },
		animation = "holy_nova", description = "Luz purificadora cura o usuário.", target = "enemy", flags = {}
	},
	metal_burst = {
		id = "metal_burst", name = "Explosão Metálica", element = "Metal", category = "physical",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "stat", stat = "def", stages = 2, chance = 0.5 },
		animation = "metal_burst", description = "Fragmentos metálicos.", target = "enemy", flags = {}
	},
	crystal_prison = {
		id = "crystal_prison", name = "Prisão de Cristal", element = "Cristal", category = "special",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "status", status = "confuse", chance = 0.3, duration = 3 },
		animation = "crystal_prison", description = "Prende em cristais.", target = "enemy", flags = {}
	},
	void_rend = {
		id = "void_rend", name = "Rasgo do Vazio", element = "Arcano", category = "special",
		power = 130, accuracy = 0.9, pp = 5, priority = 0,
		effect = { type = "stat", stat = "spDef", stages = -2, chance = 0.3 },
		animation = "void_rend", description = "Rasga a realidade.", target = "enemy", flags = {}
	},
}

-- Creature-specific move pools (learnsets)
local Learnsets: { [string]: { string } } = {}

-- Initialize learnsets based on creature data
local C = require(script.Parent.Creatures)
local Elements = require(script.Parent.Elements)

for id, def in C.ById do
	if def.acquisition == "special" then
		-- Legendary/mythical get signature + powerful moves
		Learnsets[id] = {}
	else
		-- Regular creatures get moves based on element and shape
		Learnsets[id] = {}
		local element = def.el
		local shape = def.shape

		-- Add shape signature move
		if ShapeMoves[shape] then
			table.insert(Learnsets[id], ShapeMoves[shape].id)
		end

		-- Add element-appropriate moves
		local elementMoves = {
			Fogo = { "ember", "flamethrower", "fire_blast", "flare_blitz" },
			Água = { "water_gun", "bubble", "hydro_pump", "surf", "aquajet" },
			Natureza = { "vine_whip", "razor_leaf", "seed_bomb", "petal_dance" },
			Terra = { "rock_throw", "mud_shot", "earthquake", "drill_run" },
			Ar = { "wing_attack", "gust", "air_slash", "hurricane" },
			Sombra = { "shadow_sneak", "dark_pulse", "night_slash" },
			Gelo = { "ice_shard", "ice_beam", "blizzard" },
			Elétrico = { "thunder_shock", "thunderbolt", "thunder", "volt_tackle" },
			Luz = { "flash", "dazzling_gleam", "morning_sun" },
			Metal = { "metal_claw", "iron_head", "flash_cannon" },
			Cristal = { "power_gem", "diamond_storm" },
			Arcano = { "confusion", "psychic", "future_sight", "calm_mind" },
		}

		local moves = elementMoves[element] or {}
		for _, moveId in ipairs(moves) do
			if UniversalMoves[moveId] then
				table.insert(Learnsets[id], moveId)
			end
		end

		-- Add some universal physical moves for variety
		if def.shape == "Beast" or def.shape == "Quadruped" or def.shape == "Draconic" then
			for _, moveId in ipairs({ "tackle", "scratch", "quick_attack" }) do
				if UniversalMoves[moveId] then table.insert(Learnsets[id], moveId) end
			end
		end
	end
end

-- Export functions
function Moves.getMove(speciesId: string, isSkill: boolean): MoveData?
	if isSkill and ShapeMoves[C.ById[speciesId] and C.ById[speciesId].shape or ""] then
		local shapeMove = ShapeMoves[C.ById[speciesId].shape]
		return UniversalMoves[shapeMove.id]
	end
	-- Return first available move for basic strike
	local learnset = Learnsets[speciesId] or {}
	for _, moveId in ipairs(learnset) do
		local move = UniversalMoves[moveId]
		if move and move.category ~= "status" then
			return move
		end
	end
	return UniversalMoves.tackle
end

function Moves.getLearnset(speciesId: string): { MoveData }
	local learnset = Learnsets[speciesId] or {}
	local result = {}
	for _, moveId in ipairs(learnset) do
		if UniversalMoves[moveId] then
			table.insert(result, UniversalMoves[moveId])
		end
	end
	return result
end

function Moves.getMoveById(moveId: string): MoveData?
	return UniversalMoves[moveId]
end

function Moves.getAllMoves(): { MoveData }
	local result = {}
	for _, move in UniversalMoves do
		table.insert(result, move)
	end
	table.sort(result, function(a, b) return a.name < b.name end)
	return result
end

function Moves.getMovesByElement(element: string): { MoveData }
	local result = {}
	for _, move in UniversalMoves do
		if move.element == element then
			table.insert(result, move)
		end
	end
	return result
end

function Moves.getMovesByCategory(category: string): { MoveData }
	local result = {}
	for _, move in UniversalMoves do
		if move.category == category then
			table.insert(result, move)
		end
	end
	return result
end

-- Animation reference mapping
Moves.Animations = {
	tackle = "rbxassetid://anim_tackle",
	scratch = "rbxassetid://anim_scratch",
	quick_attack = "rbxassetid://anim_quick_attack",
	ember = "rbxassetid://anim_ember",
	flamethrower = "rbxassetid://anim_flamethrower",
	fire_blast = "rbxassetid://anim_fire_blast",
	flare_blitz = "rbxassetid://anim_flare_blitz",
	water_gun = "rbxassetid://anim_water_gun",
	bubble = "rbxassetid://anim_bubble",
	hydro_pump = "rbxassetid://anim_hydro_pump",
	surf = "rbxassetid://anim_surf",
	aquajet = "rbxassetid://anim_aquajet",
	vine_whip = "rbxassetid://anim_vine_whip",
	razor_leaf = "rbxassetid://anim_razor_leaf",
	seed_bomb = "rbxassetid://anim_seed_bomb",
	petal_dance = "rbxassetid://anim_petal_dance",
	rock_throw = "rbxassetid://anim_rock_throw",
	mud_shot = "rbxassetid://anim_mud_shot",
	earthquake = "rbxassetid://anim_earthquake",
	drill_run = "rbxassetid://anim_drill_run",
	wing_attack = "rbxassetid://anim_wing_attack",
	gust = "rbxassetid://anim_gust",
	air_slash = "rbxassetid://anim_air_slash",
	hurricane = "rbxassetid://anim_hurricane",
	shadow_sneak = "rbxassetid://anim_shadow_sneak",
	dark_pulse = "rbxassetid://anim_dark_pulse",
	night_slash = "rbxassetid://anim_night_slash",
	ice_shard = "rbxassetid://anim_ice_shard",
	ice_beam = "rbxassetid://anim_ice_beam",
	blizzard = "rbxassetid://anim_blizzard",
	thunder_shock = "rbxassetid://anim_thunder_shock",
	thunderbolt = "rbxassetid://anim_thunderbolt",
	thunder = "rbxassetid://anim_thunder",
	volt_tackle = "rbxassetid://anim_volt_tackle",
	flash = "rbxassetid://anim_flash",
	dazzling_gleam = "rbxassetid://anim_dazzling_gleam",
	morning_sun = "rbxassetid://anim_morning_sun",
	metal_claw = "rbxassetid://anim_metal_claw",
	iron_head = "rbxassetid://anim_iron_head",
	flash_cannon = "rbxassetid://anim_flash_cannon",
	power_gem = "rbxassetid://anim_power_gem",
	diamond_storm = "rbxassetid://anim_diamond_storm",
	confusion = "rbxassetid://anim_confusion",
	psychic = "rbxassetid://anim_psychic",
	future_sight = "rbxassetid://anim_future_sight",
	growl = "rbxassetid://anim_growl",
	tail_whip = "rbxassetid://anim_tail_whip",
	harden = "rbxassetid://anim_harden",
	recover = "rbxassetid://anim_recover",
	protect = "rbxassetid://anim_protect",
	rest = "rbxassetid://anim_rest",
	calm_mind = "rbxassetid://anim_calm_mind",
	swords_dance = "rbxassetid://anim_swords_dance",
	solar_flare = "rbxassetid://anim_solar_flare",
	abyssal_depths = "rbxassetid://anim_abyssal_depths",
	primordial_force = "rbxassetid://anim_primordial_force",
	tectonic_upheaval = "rbxassetid://anim_tectonic_upheaval",
	celestial_winds = "rbxassetid://anim_celestial_winds",
	shadow_realm = "rbxassetid://anim_shadow_realm",
	absolute_zero = "rbxassetid://anim_absolute_zero",
	bolt_strike = "rbxassetid://anim_bolt_strike",
	holy_nova = "rbxassetid://anim_holy_nova",
	metal_burst = "rbxassetid://anim_metal_burst",
	crystal_prison = "rbxassetid://anim_crystal_prison",
	void_rend = "rbxassetid://anim_void_rend",
	vital_pulse = "rbxassetid://anim_vital_pulse",
	fierce_charge = "rbxassetid://anim_fierce_charge",
	evasive_gust = "rbxassetid://anim_evasive_gust",
	ancestral_breath = "rbxassetid://anim_ancestral_breath",
	weakening_coil = "rbxassetid://anim_weakening_coil",
	sticky_web = "rbxassetid://anim_sticky_web",
	investida = "rbxassetid://anim_tackle",
	ataque_de_asa = "rbxassetid://anim_wing_attack",
	jato_dagua = "rbxassetid://anim_water_gun",
	chicote_de_vinha = "rbxassetid://anim_vine_whip",
	lancamento_de_rocha = "rbxassetid://anim_rock_throw",
	golpe_sombrio = "rbxassetid://anim_shadow_sneak",
	estilhaco_de_gelo = "rbxassetid://anim_ice_shard",
	choque_do_trovao = "rbxassetid://anim_thunder_shock",
}

return Moves