--!strict
-- Bandas de nível por ilha (10 ilhas, 12 capítulos)
-- Cada banda define: nível mínimo/máximo, guardião, custo de desbloqueio

local L = {
	Order = { "Alvorecer", "Brasa", "Recife", "Floresta", "Dunas", "Picos", "Pantano", "Inverno", "Trovao", "Celestial" },
	ById = {}
}

-- Configuração por ilha: minLevel, maxLevel, guardianLevel, unlockCost, chapter
local BAND_DATA = {
	Alvorecer  = { min = 1,   max = 9,   guardian = 11, cost = 0,      chapter = 1,  name = "Capítulo 1: O Despertar" },
	Brasa      = { min = 10,  max = 17,  guardian = 19, cost = 1440,   chapter = 2,  name = "Capítulo 2: Brasas Eternas" },
	Recife     = { min = 18,  max = 25,  guardian = 27, cost = 3384,   chapter = 3,  name = "Capítulo 3: Marés de Cristal" },
	Floresta   = { min = 26,  max = 33,  guardian = 35, cost = 5112,   chapter = 4,  name = "Capítulo 4: Sussurros da Floresta" },
	Dunas      = { min = 34,  max = 41,  guardian = 43, cost = 6840,   chapter = 5,  name = "Capítulo 5: Ruínas da Areia" },
	Picos      = { min = 42,  max = 49,  guardian = 51, cost = 8568,   chapter = 6,  name = "Capítulo 6: Ventos Celestes" },
	Pantano    = { min = 50,  max = 57,  guardian = 59, cost = 10296,  chapter = 7,  name = "Capítulo 7: Sombras do Pântano" },
	Inverno    = { min = 58,  max = 67,  guardian = 69, cost = 15000,  chapter = 8,  name = "Capítulo 8: Gelo Eterno" },
	Trovao     = { min = 68,  max = 77,  guardian = 79, cost = 22000,  chapter = 9,  name = "Capítulo 9: Tempestade Perpétua" },
	Celestial  = { min = 78,  max = 89,  guardian = 91, cost = 35000,  chapter = 10, name = "Capítulo 10: Observatório Cósmico" },
}

-- Ilhas pós-jogo (prestígio/lendárias) - capítulos 11-12
local POSTGAME_BANDS = {
	Prestigio  = { min = 90,  max = 100, guardian = 105, cost = 50000, chapter = 11, name = "Capítulo 11: Caminho do Prestígio" },
	Lendarias  = { min = 100, max = 200, guardian = 210, cost = 100000, chapter = 12, name = "Capítulo 12: Ascensão Lendária" },
}

for index, id in L.Order do
	local data = BAND_DATA[id]
	local previous = L.Order[index - 1]

	L.ById[id] = {
		id = id,
		index = index,
		min = data.min,
		max = data.max,
		guardian = data.guardian,
		previous = previous,
		cost = data.cost,
		chapter = data.chapter,
		chapterName = data.name,
	}
end

-- Adiciona bandas de pós-jogo
L.ById.Prestigio = {
	id = "Prestigio",
	index = 11,
	min = POSTGAME_BANDS.Prestigio.min,
	max = POSTGAME_BANDS.Prestigio.max,
	guardian = POSTGAME_BANDS.Prestigio.guardian,
	previous = "Celestial",
	cost = POSTGAME_BANDS.Prestigio.cost,
	chapter = POSTGAME_BANDS.Prestigio.chapter,
	chapterName = POSTGAME_BANDS.Prestigio.name,
	isPostgame = true,
}

L.ById.Lendarias = {
	id = "Lendarias",
	index = 12,
	min = POSTGAME_BANDS.Lendarias.min,
	max = POSTGAME_BANDS.Lendarias.max,
	guardian = POSTGAME_BANDS.Lendarias.guardian,
	previous = "Prestigio",
	cost = POSTGAME_BANDS.Lendarias.cost,
	chapter = POSTGAME_BANDS.Lendarias.chapter,
	chapterName = POSTGAME_BANDS.Lendarias.name,
	isPostgame = true,
}

-- Retorna a banda para um nível de jogador
function L.bandForLevel(level: number)
	for _, id in L.Order do
		local b = L.ById[id]
		if level >= b.min and level <= b.max then
			return b
		end
	end
	-- Pós-jogo
	if level >= L.ById.Prestigio.min and level <= L.ById.Prestigio.max then
		return L.ById.Prestigio
	end
	if level >= L.ById.Lendarias.min then
		return L.ById.Lendarias
	end
	return L.ById.Alvorecer
end

-- Próxima banda desbloqueável
function L.nextUnlocked(profile)
	for _, id in L.Order do
		if not (profile.unlocked and profile.unlocked[id]) then
			return L.ById[id]
		end
	end
	if profile.prestige and profile.prestige > 0 and not profile.unlocked.Prestigio then
		return L.ById.Prestigio
	end
	return nil
end

-- Verifica se uma banda está disponível para desbloqueio
function L.canUnlock(profile, bandId: string)
	local band = L.ById[bandId]
	if not band then return false, "UNKNOWN_BAND" end

	if profile.unlocked and profile.unlocked[bandId] then
		return false, "ALREADY_UNLOCKED"
	end

	if band.previous and not (profile.unlocked and profile.unlocked[band.previous]) then
		return false, "PREVIOUS_LOCKED"
	end

	if (profile.playerLevel or 1) < band.min then
		return false, "LEVEL_TOO_LOW"
	end

	if (profile.gold or 0) < band.cost then
		return false, "NOT_ENOUGH_GOLD"
	end

	return true, "OK"
end

return L