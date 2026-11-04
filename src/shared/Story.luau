--!nonstrict
local Text = require(script.Parent.Strings).Text
local S = {
	List = {
		{
			id = "arrival",
			name = Text.O_PRIMEIRO_VINCULO_273E14,
			text = Text.CAPTURE_UMA_FERA_SELVAGEM_E_APRESENTE_SUA_DESCOB_696F7C,
			stat = "capture",
			goal = 1,
			gold = 75,
			xp = 90,
			seals = 2,
		},
		{
			id = "care",
			name = Text.WORLD_PATHS,
			text = Text.WORLD_VISIT_TWO,
			stat = "regionVisit",
			goal = 2,
			gold = 100,
			xp = 100,
			seals = 1,
		},
		{
			id = "explore",
			name = Text.VESTIGIOS_DA_CIVILIZACAO_B8949B,
			text = Text.ENCONTRE_UM_MARCO_DE_EXPLORACAO_E_RECOLHA_SUA_ES_D6C5D0,
			stat = "explore",
			goal = 1,
			gold = 100,
			xp = 100,
			seals = 1,
		},
		{
			id = "birth",
			name = Text.WORLD_COMPANY,
			text = Text.WORLD_CAPTURE_THREE,
			stat = "capture",
			goal = 3,
			gold = 150,
			xp = 120,
			seals = 2,
		},
		{
			id = "challenge",
			name = Text.EXPLORADOR_PREPARADO_3D4C3B,
			text = Text.VENCA_UMA_BATALHA_CONTRA_UMA_FERA_SELVAGEM_C78BC2,
			stat = "win",
			goal = 1,
			gold = 200,
			xp = 160,
			seals = 2,
		},
		{
			id = "home",
			name = Text.WORLD_HORIZON,
			text = Text.WORLD_VISIT_FOUR,
			stat = "regionVisit",
			goal = 4,
			gold = 200,
			xp = 200,
			seals = 3,
		},
		{
			id = "guardian",
			name = Text.O_PRIMEIRO_GUARDIAO_CD87B3,
			text = Text.DERROTE_UM_GUARDIAO_DE_ILHA_PARA_CONCLUIR_SUA_PR_5B283B,
			stat = "guardian",
			goal = 1,
			gold = 300,
			xp = 300,
			seals = 4,
		},
	},
}
S.ById = {}
for _, q in S.List do
	S.ById[q.id] = q
end
function S.current(d)
	for _, q in S.List do
		if not d.storyClaimed[q.id] then
			return q
		end
	end
	return nil
end
function S.progress(d, q)
	return math.min(q.goal, d.stats[q.stat] or 0)
end
function S.canClaim(d, id)
	local q = S.current(d)
	return q and q.id == id and S.progress(d, q) >= q.goal
end
return S
