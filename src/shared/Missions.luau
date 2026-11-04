--!nonstrict
local Text = require(script.Parent.Strings).Text
local L = {}
local function add(id, text, stat, goal, gold, gems)
	table.insert(L, { id = id, text = text, stat = stat, goal = goal, gold = gold, gems = gems or 0 })
end
add("f1", Text.ALIMENTE_UMA_FERA_6CB80D, "feed", 1, 40)
add("f2", Text.ALIMENTE_5_VEZES_C4C1AB, "feed", 5, 120, 1)
add("f3", Text.ALIMENTE_20_VEZES_CA2277, "feed", 20, 400, 3)
add("b1", Text.CRUZE_DUAS_FERAS_539F57, "breed", 1, 60)
add("b2", Text.CRUZE_5_VEZES_E3D7DC, "breed", 5, 200, 2)
add("h1", Text.CHOQUE_UM_OVO_03D8B3, "hatch", 1, 60)
add("h2", Text.CHOQUE_5_OVOS_5ED8F1, "hatch", 5, 250, 2)
add("w1", Text.VENCA_UMA_BATALHA_A43940, "win", 1, 80)
add("w2", Text.VENCA_10_BATALHAS_CCE0E5, "win", 10, 500, 3)
add("w3", Text.VENCA_30_BATALHAS_AC517C, "win", 30, 1500, 8)
add("c1", Text.COLETE_OURO_5_VEZES_A103BB, "collect", 5, 100)
add("d1", Text.DESCUBRA_8_FERAS_F45F2C, "found", 8, 300, 3)
add("d2", Text.DESCUBRA_15_FERAS_B78B13, "found", 15, 1200, 6)
add("i1", Text.TENHA_3_ILHAS_FDA36F, "isles", 3, 400, 3)
add("i2", Text.TENHA_TODAS_AS_ILHAS_D2BB30, "isles", #require(script.Parent.Islands).List, 5000, 15)
add("p1", Text.VENCA_UM_DUELO_ONLINE_2F97C7, "duelwin", 1, 200, 3)
add("a1", Text.CONQUISTA_DESCUBRA_TODAS_AS_FERAS_8AFA2F, "found", #require(script.Parent.Creatures).List, 3000, 20)
add("a2", Text.CONQUISTA_100_VITORIAS_29C94D, "win", 100, 5000, 20)
add("a3", Text.CONQUISTA_ALIMENTE_100_VEZES_9D7566, "feed", 100, 2000, 10)
add("a4", Text.CONQUISTA_CHOQUE_25_OVOS_57A023, "hatch", 25, 2500, 10)
add("a5", Text.CONQUISTA_COLETE_50_VEZES_0CDE21, "collect", 50, 1500, 8)
local M = { List = L, ById = {} }
for _, m in L do
	M.ById[m.id] = m
end
function M.progress(d, stat)
	if stat == "found" or stat == "isles" then
		local n = 0
		for _ in (stat == "found" and d.discovered or d.unlocked) do
			n += 1
		end
		return n
	end
	return d.stats[stat] or 0
end
-- Evento rotativo: a cada 3 dias um elemento rende +50% de ouro.
local EL =
	{ Text.FOGO_F77A3C, Text.AGUA_F11A05, Text.NATUREZA_FB1ED9, Text.TERRA_16D3AE, Text.AR_B623FF, Text.SOMBRA_94B135 }
function M.event(now)
	local per = 3 * 86400
	return EL[(now // per) % 6 + 1], per - now % per
end
return M
