--!strict
-- Progressão de nível (1-100), curvas de XP, growth de stats e prestígio para lendários
local Bands = require(script.Parent.LevelBands)
local Creatures = require(script.Parent.Creatures)

local P = {
	MaxLevel = 100,
	PrestigeMaxLevel = 100, -- Prestígio vai até 100 (nível efetivo 200)
	EncountersPerHour = 50,
	CreatureXpPerLevel = 15, -- XP base por nível de criatura
}

-- Curva suave de XP para jogador: logarítmica com escalonamento por faixa
-- Fórmula: baseXP * (level ^ 1.35) com ajustes por checkpoints
local CHECKPOINTS = {
	{ level = 1,   baseXp = 60,   mult = 1.00 },
	{ level = 10,  baseXp = 60,   mult = 1.00 },
	{ level = 18,  baseXp = 70,   mult = 1.10 },
	{ level = 26,  baseXp = 80,   mult = 1.20 },
	{ level = 34,  baseXp = 90,   mult = 1.30 },
	{ level = 42,  baseXp = 100,  mult = 1.40 },
	{ level = 50,  baseXp = 110,  mult = 1.50 },
	{ level = 60,  baseXp = 125,  mult = 1.65 },
	{ level = 70,  baseXp = 140,  mult = 1.80 },
	{ level = 80,  baseXp = 160,  mult = 2.00 },
	{ level = 90,  baseXp = 185,  mult = 2.25 },
	{ level = 100, baseXp = 220,  mult = 2.50 },
}

-- XP necessário para próximo nível do jogador
function P.playerCost(level: number): number
	if level >= P.MaxLevel then
		return 1e9 -- Máximo atingido
	end

	-- Encontrar faixa
	local idx = 1
	for i = 1, #CHECKPOINTS - 1 do
		if level >= CHECKPOINTS[i].level and level < CHECKPOINTS[i + 1].level then
			idx = i
			break
		end
	end

	local a = CHECKPOINTS[idx]
	local b = CHECKPOINTS[idx + 1]
	local progress = (level - a.level) / (b.level - a.level)
	local baseXp = a.baseXp + (b.baseXp - a.baseXp) * progress
	local mult = a.mult + (b.mult - a.mult) * progress

	-- Fórmula: baseXP * level^1.35 * mult
	return math.floor(baseXp * (level ^ 1.35) * mult + 0.5)
end

-- XP total acumulado até um nível (para cálculos de progresso)
function P.totalPlayerXpTo(level: number): number
	local total = 0
	for l = 1, level - 1 do
		total += P.playerCost(l)
	end
	return total
end

-- Recompensas de encontro baseadas na região, nível do inimigo, raridade e nível da equipe
function P.rewards(region: string, foeLevel: number, rarity: number, teamLevel: number)
	local band = assert(Bands.ById[region], "Região de recompensa desconhecida: " .. region)
	local gap = teamLevel - foeLevel

	-- Penalidade de nível: se muito forte, ganha menos
	local penalty = gap >= 15 and 0.1 or gap >= 8 and 0.5 or 1

	local rarityMult = 1 + (rarity - 1) * 0.15
	local bandMult = 1 + band.index * 0.08

	return {
		gold = math.floor(25 * bandMult * rarityMult + foeLevel * 1.5 + rarity * 2),
		xp = math.max(1, math.floor((55 + band.index * 8 + (rarity - 1) * 4) * penalty * bandMult * rarityMult)),
		creatureXp = math.max(1, math.floor((40 + band.index * 6 + (rarity - 1) * 3) * penalty * bandMult * rarityMult)),
		penalty = penalty,
	}
end

-- XP necessário para próximo nível da criatura (curva similar mas mais suave)
function P.creatureCost(level: number): number
	if level >= P.MaxLevel then
		return 1e9
	end
	-- 35 + level * 15 + level^1.2 * 2
	return math.floor(35 + level * 15 + (level ^ 1.2) * 2 + 0.5)
end

-- XP total acumulado da criatura até um nível
function P.totalCreatureXpTo(level: number): number
	local total = 0
	for l = 1, level - 1 do
		total += P.creatureCost(l)
	end
	return total
end

-- Growth de stats por nível (base stats * growth factor ^ level)
-- HP: base 30 + rar * 25, growth 1.08 per level
-- ATK: base 6 + rar * 5, growth 1.06 per level
function P.statGrowth(base: number, growth: number, level: number): number
	return math.floor(base * (growth ^ (level - 1)) + 0.5)
end

-- Calcula stats finais da criatura no nível atual
function P.computeStats(creatureData: { id: string, lv: number, rarity: number? })
	local species = Creatures.ById[creatureData.id]
	if not species then
		return { hp = 30, atk = 6 }
	end

	local rar = creatureData.rarity or species.rar or 1
	local baseHp = 30 + rar * 25
	local baseAtk = 6 + rar * 5

	return {
		hp = P.statGrowth(baseHp, 1.08, creatureData.lv),
		atk = P.statGrowth(baseAtk, 1.06, creatureData.lv),
		gpm = rar * rar * 2 + 2, -- gold por minuto no santuário
	}
end

-- Adiciona XP ao jogador e processa level up
function P.award(data: any, amount: number)
	data.playerXp = math.min(1e9, (data.playerXp or 0) + math.max(0, math.floor(amount)))
	data.playerLevel = data.playerLevel or 1

	while data.playerLevel < P.MaxLevel and data.playerXp >= P.playerCost(data.playerLevel) do
		data.playerXp -= P.playerCost(data.playerLevel)
		data.playerLevel += 1
	end

	-- Prestígio (pós-100): reseta nível para 1 mas ganha prestígio
	if data.playerLevel >= P.MaxLevel and data.playerXp >= P.playerCost(P.MaxLevel) then
		data.playerLevel = P.MaxLevel
		data.playerXp = P.playerCost(P.MaxLevel) -- Cap no máximo
	end
end

-- Adiciona XP à criatura e processa level up
function P.awardCreature(creature: any, amount: number)
	creature.xp = math.min(1e9, (creature.xp or 0) + math.max(0, math.floor(amount)))
	creature.lv = creature.lv or 1

	while creature.lv < P.MaxLevel and creature.xp >= P.creatureCost(creature.lv) do
		creature.xp -= P.creatureCost(creature.lv)
		creature.lv += 1
	end
end

-- Prestígio para lendárias: após capturar uma lendária e chegar ao nível 100,
-- pode resetar para ganhar "Prestígio" (nível efetivo 101-200)
function P.canPrestige(data: any): boolean
	if data.playerLevel < P.MaxLevel then
		return false
	end
	-- Verifica se tem pelo menos uma lendária capturada
	if not data.creatures then return false end
	for _, c in data.creatures do
		local sp = Creatures.ById[c.id]
		if sp and sp.rar == 4 then
			return true
		end
	end
	return false
end

function P.applyPrestige(data: any)
	if not P.canPrestige(data) then return false end

	data.prestige = (data.prestige or 0) + 1
	data.playerLevel = 1
	data.playerXp = 0

	-- Bonus de prestígio: +5% stats em todas as criaturas
	data.prestigeBonus = (data.prestigeBonus or 0) + 0.05

	return true
end

-- Calcula nível efetivo (incluindo prestígio)
function P.effectiveLevel(data: any): number
	return (data.playerLevel or 1) + (data.prestige or 0) * P.MaxLevel
end

-- Offline progress: calcula produção de santuário e chocagem de ovos
function P.calculateOfflineProgress(data: any, now: number): { gold: number, creatureXp: number, hatchedEggs: { any } }
	local last = data.last or now
	local hoursOffline = math.max(0, (now - last) / 3600)

	if hoursOffline < 0.01 then -- Menos de 36 segundos
		return { gold = 0, creatureXp = 0, hatchedEggs = {} }
	end

	-- Cap em 24 horas de progresso offline
	hoursOffline = math.min(hoursOffline, 24)

	-- Ouro do santuário
	local totalGpm = 0
	if data.sanctuary then
		for islandId, entry in data.sanctuary do
			if data.habitat and data.habitat[islandId] then
				for _, uid in data.habitat[islandId] do
					local creature = data.creatures[uid]
					if creature then
						local stats = P.computeStats(creature)
						totalGpm += stats.gpm
					end
				end
			end
		end
	end

	local offlineGold = math.floor(totalGpm * hoursOffline * 60)

	-- XP de criatura distribuído entre as do santuário
	local totalCreatureXp = math.floor(offlineGold * 0.3) -- 30% do ouro em XP

	-- Chocagem de ovos
	local hatchedEggs = {}
	if data.eggs then
		local remainingEggs = {}
		for _, egg in data.eggs do
			if egg.ready <= now then
				table.insert(hatchedEggs, egg)
			else
				table.insert(remainingEggs, egg)
			end
		end
		-- Nota: a remoção real dos ovos chocados é feita no DataService
	end

	return {
		gold = offlineGold,
		creatureXp = totalCreatureXp,
		hatchedEggs = hatchedEggs,
	}
end

-- Calcula tempo até próximo nível (em encontros)
function P.encountersToNextLevel(data: any): number
	local currentCost = P.playerCost(data.playerLevel or 1)
	local remaining = currentCost - (data.playerXp or 0)
	if remaining <= 0 then return 0 end

	-- XP médio por encontro na região atual
	local avgXp = 60 -- Estimativa conservadora
	return math.ceil(remaining / avgXp)
end

return P