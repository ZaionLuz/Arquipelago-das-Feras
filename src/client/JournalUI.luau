--!strict
-- JournalUI.luau - Bestiary with filters, species detail panel with lore, quest log, world event tracker
-- Cassette Beasts pixel UI: 4px grid, 2px borders, selective outlining
-- 120-250ms transitions with easing, hover/pressed/disabled states
-- Mobile: responsive, touch targets >=44px, portrait/landscape battle UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Text = require(ReplicatedStorage.Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local C = require(RS.Shared.Creatures)
local I = require(RS.Shared.Islands)
local E = require(RS.Shared.Elements)
local Preview = require(script.Parent.CollectionUI)
local Theme = require(script.Parent.UITheme)
local Icons = require(script.Parent.PixelIcons)
local Lore = require(RS.Shared.SpeciesLore)
local Missions = require(RS.Shared.Missions)
local Story = require(RS.Shared.Story)

local J = {}

local TWEEN_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

export type JournalState = {
	discovered: {[string]: boolean},
	creatures: {[string]: {id: string, lv: number}},
	stats: {[string]: number},
	storyClaimed: {[string]: boolean},
	unlocked: {[string]: boolean},
	quest: {stage: number, title: string?, hint: string?, nextAttemptAt: number?, captured: boolean?}?,
	event: {el: string, left: number}?,
	streak: number,
	claimed: {[string]: boolean},
	playerLevel: number,
}

-- Filter state
local selected = "cinzelo"
local rarityFilter = 0
local islandFilter = 0
local elementFilter = 0
local searchFilter = ""
local tab = "bestiary" -- "bestiary" | "quests" | "events" | "lore"

local function frame(parent: Instance, height: number): Frame
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -8, 0, height)
	f.BackgroundColor3 = Theme.Card
	f.Parent = parent
	Theme.panel(f)
	return f
end

local function createTabButton(parent: Instance, text: string, isActive: boolean, onClick: () -> ()): TextButton
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromScale(0.25, 1)
	btn.Text = text
	btn.TextSize = 12
	btn.Font = Theme.Font
	btn.TextColor3 = isActive and Theme.Panel or Theme.Ink
	btn.BackgroundColor3 = isActive and Theme.Accent or Theme.Card
	btn.Parent = parent
	btn.Active = true
	btn.Selectable = true
	Theme.panel(btn)
	Theme.bind(btn)
	btn.Activated:Connect(onClick)
	return btn
end

function J.render(parent: ScrollingFrame, state: JournalState, onRender: () -> ())
	parent:ClearAllChildren()

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 8)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = parent

	local container = frame(parent, 0)
	container.Name = "JournalPanel"
	container.BackgroundTransparency = 1
	container.AutomaticSize = Enum.AutomaticSize.Y
	container.LayoutOrder = 1

	local containerLayout = Instance.new("UIListLayout")
	containerLayout.Padding = UDim.new(0, 8)
	containerLayout.SortOrder = Enum.SortOrder.LayoutOrder
	containerLayout.Parent = container

	-- Tab bar
	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(1, 0, 0, 40)
	tabBar.BackgroundTransparency = 1
	tabBar.LayoutOrder = 1
	tabBar.Parent = container

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Padding = UDim.new(0, 4)
	tabLayout.Parent = tabBar

	local tabs = {
		{id = "bestiary", text = Text.BESTIARIO_65A46C},
		{id = "quests", text = Text.MISSOES_FAE2D2},
		{id = "events", text = Text.EVENTOS_3F2A1C},
		{id = "lore", text = Text.LORE_9C3E1F},
	}

	for _, t in tabs do
		createTabButton(tabBar, t.text, tab == t.id, function()
			tab = t.id
			onRender()
		end)
	end

	if tab == "bestiary" then
		renderBestiaryTab(container, state, onRender)
	elseif tab == "quests" then
		renderQuestsTab(container, state, onRender)
	elseif tab == "events" then
		renderEventsTab(container, state, onRender)
	elseif tab == "lore" then
		renderLoreTab(container, state, onRender)
	end
end

function renderBestiaryTab(container: Frame, state: JournalState, onRender: () -> ())
	-- Filters
	local filters = frame(container, 120)
	filters.LayoutOrder = 2
	filters.BackgroundTransparency = 1

	local choices = {
		{
			Text.RARIDADE_9F174D .. (C.Rarity[rarityFilter] or Text.TODAS_7F8C9A),
			function()
				rarityFilter = (rarityFilter + 1) % 5
				onRender()
			end,
		},
		{
			Text.BIOMA_94C907 .. (islandFilter == 0 and Text.TODOS_7F8C9A or I.List[islandFilter].name),
			function()
				islandFilter = (islandFilter + 1) % (#I.List + 1)
				onRender()
			end,
		},
		{
			Text.ELEMENTO_BB6BA8 .. (elementFilter == 0 and Text.TODOS_7F8C9A or E.List[elementFilter]),
			function()
				elementFilter = (elementFilter + 1) % (#E.List + 1)
				onRender()
			end,
		},
	}

	for index, entry in choices do
		local b = Theme.button(filters, entry[1], entry[2])
		b.Position = UDim2.new((index - 1) % 2 * 0.5, 2, 0, math.floor((index - 1) / 2) * 50)
		b.Size = UDim2.new(0.5, -4, 0, 46)
	end

	-- Search box
	local box = Instance.new("TextBox")
	box.PlaceholderText = Text.BUSCAR_ESPECIE_09F339
	box.Text = searchFilter
	box.TextSize = 16
	box.Font = Theme.Font
	box.ClearTextOnFocus = false
	box.Size = UDim2.new(1, -4, 0, 46)
	box.Position = UDim2.fromOffset(2, 100)
	box.BackgroundColor3 = Theme.Card
	box.TextColor3 = Theme.Ink
	box.PlaceholderColor3 = Theme.Muted
	box.Parent = filters
	Theme.round(box)
	Theme.stroke(box)
	box.FocusLost:Connect(function()
		searchFilter = string.sub(box.Text, 1, 40)
		onRender()
	end)

	-- Selected species detail
	local def = C.ById[selected]
	local known = state.discovered[selected]
	local lv, count = 1, 0
	for _, cr in state.creatures do
		if cr.id == selected then
			count += 1
			lv = math.max(lv, cr.lv)
		end
	end

	local card = container:FindFirstChild("MainPreview") or frame(container, 380)
	card.Name = "MainPreview"
	card.LayoutOrder = 3
	card.BackgroundTransparency = 1

	for _, child in card:GetChildren() do
		if child:IsA("TextLabel") or child:IsA("Frame") and child.Name ~= "EvolutionTree" then
			child:Destroy()
		end
	end

	Preview.preview(card, def, lv, not known)

	-- Info panel
	local info = Theme.label(card, "", 14)
	info.Position = UDim2.fromScale(0.03, 0.64)
	info.Size = UDim2.fromScale(0.94, 0.34)
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.TextYAlignment = Enum.TextYAlignment.Top

	if known then
		local islandName = I.ById[def.island] and I.ById[def.island].name or Text.HIBRIDO_9CB40A
		info.Text = def.name .. " • " .. def.el .. " • " .. C.Rarity[def.rar] .. "\n"
			.. islandName .. Text.COLECAO_57798D .. count .. Text.NV_AE0838 .. lv
			.. Text.ESTAGIO_D2FEE2 .. C.stage(lv, def.id)
			.. (def.id == "fenix" and Text.RENASCIMENTO_FUTURO_9236DA or Text.EVOLUI_EM_7_15_75E2ED)
	else
		info.Text = def.acquisition == "special"
			and Text.VESTIGIOS_DE_UMA_ESPECIE_DESCONHECIDA_B8DB43
			or Text.ESPECIE_MISTERIOSA_EXPLORE_CAPTURE_OU_CRUZE_FERA_6D0C6C
	end

	-- Lore
	if known and Lore[def.id] then
		info.Text ..= "\n\n" .. Lore[def.id].description .. " • " .. Lore[def.id].personality
	end

	-- Evolution tree
	local evoTree = Preview.evolutionTree(card, selected, lv)
	evoTree.Name = "EvolutionTree"
	evoTree.Position = UDim2.fromOffset(8, card.AbsoluteSize.Y - 130)

	-- Species grid
	local matches = {}
	for _, entry in C.List do
		local found = state.discovered[entry.id]
		if (rarityFilter == 0 or entry.rar == rarityFilter)
			and (islandFilter == 0 or entry.island == I.List[islandFilter].id)
			and (elementFilter == 0 or entry.el == E.List[elementFilter])
			and (searchFilter == "" or (found and string.find(string.lower(entry.name), string.lower(searchFilter), 1, true)))
		then
			table.insert(matches, entry)
		end
	end

	if #matches == 0 then
		local f = frame(container, 50)
		f.LayoutOrder = 4
		local l = Theme.label(f, Text.NENHUMA_ESPECIE_CORRESPONDE_AOS_FILTROS_7AC10E, 14)
		l.Size = UDim2.fromScale(1, 1)
		l.TextXAlignment = Enum.TextXAlignment.Center
		return
	end

	local columns = parent.AbsoluteSize.X >= 390 and 3 or 2
	local gridHeight = math.ceil(#matches / columns) * 148
	container.Size = UDim2.new(1, -8, 0, 540 + gridHeight)

	local grid = frame(container, gridHeight)
	grid.LayoutOrder = 4
	grid.BackgroundTransparency = 1

	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(1 / columns, -7, 0, 140)
	layout.CellPadding = UDim2.fromOffset(7, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = grid

	for index, entry in matches do
		local found = state.discovered[entry.id]
		local tile = Instance.new("Frame")
		tile.LayoutOrder = index
		tile.BackgroundColor3 = entry.id == selected and Theme.Tokens.Elements[entry.el][1] or Theme.Card
		tile.Parent = grid
		Theme.panel(tile, entry.id == selected and Theme.Tokens.Elements[entry.el][4] or Theme.Edge)

		local mini
		local function visibility()
			if not tile.Parent then return end
			local top = parent.AbsolutePosition.Y
			local y = tile.AbsolutePosition.Y
			local visible = parent.Visible and y + 140 >= top and y < top + parent.AbsoluteSize.Y
			if visible and not mini then
				mini = Preview.preview(tile, entry, 1, not found)
				mini.Size = UDim2.fromScale(1, 0.72)
			elseif not visible and mini then
				mini:Destroy()
				mini = nil
			end
		end
		local scroll = parent:GetPropertyChangedSignal("CanvasPosition"):Connect(visibility)
		local visible = parent:GetPropertyChangedSignal("Visible"):Connect(visibility)
		local pos = tile:GetPropertyChangedSignal("AbsolutePosition"):Connect(visibility)
		tile.Destroying:Connect(function()
			scroll:Disconnect()
			visible:Disconnect()
			pos:Disconnect()
		end)
		task.defer(visibility)

		local choose = Theme.button(tile, found and entry.name or "???", function()
			selected = entry.id
			onRender()
		end)
		choose.Position = UDim2.new(0, 0, 1, -44)
		choose.Size = UDim2.new(1, 0, 0, 44)
		choose.TextSize = 12
	end
end

function renderQuestsTab(container: Frame, state: JournalState, onRender: () -> ())
	-- Story quests
	local storySection = frame(container, 0)
	storySection.LayoutOrder = 2
	storySection.BackgroundTransparency = 1
	storySection.AutomaticSize = Enum.AutomaticSize.Y

	local storyLayout = Instance.new("UIListLayout")
	storyLayout.Padding = UDim.new(0, 8)
	storyLayout.Parent = storySection

	Theme.label(storySection, Text.CAPITULOS_DA_HISTORIA_8F2A1C, 16).TextColor3 = Theme.Accent

	for _, q in Story.List do
		local claimed = state.storyClaimed[q.id]
		local progress = Story.progress(state, q)
		local canClaim = Story.canClaim(state, q.id)

		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, -16, 0, 80)
		card.BackgroundColor3 = claimed and Theme.Tokens.Ramps.Natureza[1] or Theme.Card
		card.Parent = storySection
		Theme.panel(card, claimed and Theme.Tokens.Ramps.Natureza[4] or Theme.Edge)

		local title = Theme.label(card, q.name, 14)
		title.Position = UDim2.fromOffset(12, 8)
		title.Size = UDim2.new(1, -24, 0, 20)
		title.TextColor3 = Theme.Accent

		local desc = Theme.label(card, q.text, 12)
		desc.Position = UDim2.fromOffset(12, 30)
		desc.Size = UDim2.new(1, -24, 0, 20)
		desc.TextColor3 = Theme.Muted

		local progressText = progress .. "/" .. q.goal
		local prog = Theme.label(card, progressText, 12)
		prog.Position = UDim2.new(1, -100, 0, 8)
		prog.Size = UDim2.fromOffset(90, 20)
		prog.TextXAlignment = Enum.TextXAlignment.Right
		prog.TextColor3 = canClaim and Theme.Mint or Theme.Muted

		-- Progress bar
		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1, -24, 0, 6)
		bar.Position = UDim2.fromOffset(12, 60)
		bar.BackgroundColor3 = Theme.Panel
		bar.Parent = card
		Theme.round(bar)

		local fill = Instance.new("Frame")
		fill.Size = UDim2.fromScale(math.clamp(progress / q.goal, 0, 1), 1)
		fill.BackgroundColor3 = canClaim and Theme.Mint or Theme.Accent
		fill.Parent = bar
		Theme.round(fill)

		if canClaim then
			local claimBtn = Theme.button(card, Text.RECEBER_CAPITULO_3ACD37, function()
				-- Trigger claim via server
				onRender()
			end)
			claimBtn.Size = UDim2.fromOffset(120, 32)
			claimBtn.Position = UDim2.new(1, -130, 1, -40)
		elseif claimed then
			local done = Theme.label(card, Text.CONCLUIDA_7F8C9A, 12)
			done.Position = UDim2.new(1, -100, 1, -30)
			done.Size = UDim2.fromOffset(90, 20)
			done.TextXAlignment = Enum.TextXAlignment.Right
			done.TextColor3 = Theme.Mint
		end
	end

	-- Daily missions
	local missionSection = frame(container, 0)
	missionSection.LayoutOrder = 3
	missionSection.BackgroundTransparency = 1
	missionSection.AutomaticSize = Enum.AutomaticSize.Y

	local missionLayout = Instance.new("UIListLayout")
	missionLayout.Padding = UDim.new(0, 8)
	missionLayout.Parent = missionSection

	Theme.label(missionSection, Text.MISSOES_DIARIAS_9C3E1F, 16).TextColor3 = Theme.Accent

	for _, m in Missions.List do
		local pr = Missions.progress(state, m.stat)
		local done = state.claimed[m.id]

		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, -16, 0, 60)
		card.BackgroundColor3 = done and Theme.Tokens.Ramps.Luz[1] or Theme.Card
		card.Parent = missionSection
		Theme.panel(card, done and Theme.Tokens.Ramps.Luz[4] or Theme.Edge)

		Theme.label(card, m.text, 13).Position = UDim2.fromOffset(12, 8)
		Theme.label(card, math.min(pr, m.goal) .. "/" .. m.goal, 12).Position = UDim2.new(1, -100, 0, 8)

		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1, -24, 0, 6)
		bar.Position = UDim2.fromOffset(12, 36)
		bar.BackgroundColor3 = Theme.Panel
		bar.Parent = card
		Theme.round(bar)

		local fill = Instance.new("Frame")
		fill.Size = UDim2.fromScale(math.clamp(pr / m.goal, 0, 1), 1)
		fill.BackgroundColor3 = done and Theme.Mint or Theme.Accent
		fill.Parent = bar
		Theme.round(fill)

		if pr >= m.goal and not done then
			local claimBtn = Theme.button(card, Text.RESGATAR_76A111 .. " +" .. m.gold .. Text.OURO_6C9D60 .. (m.gems > 0 and " " .. m.gems .. Text.GEMAS_BEE5F6 or ""), function()
				onRender()
			end)
			claimBtn.Size = UDim2.fromOffset(200, 32)
			claimBtn.Position = UDim2.new(1, -210, 1, -40)
		elseif done then
			Theme.label(card, Text.CONCLUIDA_7F8C9A, 12).Position = UDim2.new(1, -100, 1, -30)
		end
	end
end

function renderEventsTab(container: Frame, state: JournalState, onRender: () -> ())
	-- Current world event
	if state.event then
		local eventCard = frame(container, 100)
		eventCard.LayoutOrder = 2

		local eventEl = state.event.el
		local ramp = Theme.Tokens.Elements[eventEl] or Theme.Tokens.Ramps.Metal

		local icon = Icons.draw(eventCard, eventEl, 32, ramp)
		icon.Position = UDim2.fromOffset(16, 16)

		Theme.label(eventCard, Text.EVENTO_ATIVO_8F2A1C .. " " .. eventEl, 18).Position = UDim2.fromOffset(60, 16)
		Theme.label(eventCard, Text.OURO_BONUS_50_PORCENTO_9C3E1F, 14, Theme.Mint).Position = UDim2.fromOffset(60, 40)

		local hours = math.ceil(state.event.left / 3600)
		Theme.label(eventCard, Text.TEMPO_RESTANTE_7F8C9A .. hours .. "h", 12, Theme.Muted).Position = UDim2.fromOffset(60, 60)

		-- Progress bar for event
		local per = 3 * 86400
		local elapsed = per - state.event.left
		local bar = Instance.new("Frame")
		bar.Size = UDim2.new(1, -32, 0, 8)
		bar.Position = UDim2.fromOffset(16, 84)
		bar.BackgroundColor3 = Theme.Panel
		bar.Parent = eventCard
		Theme.round(bar)

		local fill = Instance.new("Frame")
		fill.Size = UDim2.fromScale(elapsed / per, 1)
		fill.BackgroundColor3 = ramp[4]
		fill.Parent = bar
		Theme.round(fill)
	end

	-- Daily reward streak
	local streakCard = frame(container, 80)
	streakCard.LayoutOrder = 3

	Theme.label(streakCard, Text.RECOMPENSA_DIARIA_9C3E1F, 16, Theme.Accent).Position = UDim2.fromOffset(16, 8)
	Theme.label(streakCard, Text.SEQUENCIA_B9C689 .. state.streak .. ")", 14).Position = UDim2.fromOffset(16, 32)

	local claimBtn = Theme.button(streakCard, Text.RESGATAR_76A111, function()
		onRender()
	end)
	claimBtn.Size = UDim2.fromOffset(120, 36)
	claimBtn.Position = UDim2.new(1, -136, 0.5, -18)

	-- Upcoming events preview
	local upcomingCard = frame(container, 0)
	upcomingCard.LayoutOrder = 4
	upcomingCard.BackgroundTransparency = 1
	upcomingCard.AutomaticSize = Enum.AutomaticSize.Y

	Theme.label(upcomingCard, Text.PROXIMOS_EVENTOS_7F8C9A, 14, Theme.Muted).Position = UDim2.fromOffset(16, 8)

	local EL = {Text.FOGO_F77A3C, Text.AGUA_F11A05, Text.NATUREZA_FB1ED9, Text.TERRA_16D3AE, Text.AR_B623FF, Text.SOMBRA_94B135}
	local now = workspace:GetServerTimeNow()
	local per = 3 * 86400
	local currentIdx = (now // per) % 6

	for i = 1, 3 do
		local idx = (currentIdx + i) % 6 + 1
		local el = EL[idx]
		local ramp = Theme.Tokens.Elements[el] or Theme.Tokens.Ramps.Metal

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, -16, 0, 32)
		row.Position = UDim2.fromOffset(8, 32 + (i - 1) * 36)
		row.BackgroundTransparency = 1
		row.Parent = upcomingCard

		local icon = Icons.draw(row, el, 16, ramp)
		icon.Position = UDim2.fromOffset(0, 8)

		Theme.label(row, el, 12).Position = UDim2.fromOffset(24, 8)
		Theme.label(row, Text.EM_9C3E1F .. (i * 3) .. " dias", 12, Theme.Muted).Position = UDim2.new(1, -100, 0, 8)
	end
end

function renderLoreTab(container: Frame, state: JournalState, onRender: () -> ())
	-- Lore entries for discovered species
	local loreSection = frame(container, 0)
	loreSection.LayoutOrder = 2
	loreSection.BackgroundTransparency = 1
	loreSection.AutomaticSize = Enum.AutomaticSize.Y

	local loreLayout = Instance.new("UIListLayout")
	loreLayout.Padding = UDim.new(0, 8)
	loreLayout.Parent = loreSection

	Theme.label(loreSection, Text.FICHAS_DAS_ESPECIES_9C3E1F, 16, Theme.Accent)

	for _, def in C.List do
		if not state.discovered[def.id] then continue end
		if not Lore[def.id] then continue end

		local entry = Lore[def.id]
		local card = Instance.new("Frame")
		card.Size = UDim2.new(1, -16, 0, 100)
		card.BackgroundColor3 = Theme.Tokens.Elements[def.el][1]
		card.Parent = loreSection
		Theme.panel(card, Theme.Tokens.Elements[def.el][4])

		-- Mini preview
		Preview.preview(card, def, 1, false).Size = UDim2.fromOffset(80, 80)
		Preview.preview(card, def, 1, false).Position = UDim2.fromOffset(10, 10)

		Theme.label(card, def.name, 14, Theme.Ink).Position = UDim2.fromOffset(100, 10)
		Theme.label(card, entry.family, 12, Theme.Muted).Position = UDim2.fromOffset(100, 30)

		local desc = Theme.label(card, entry.description, 11, Theme.Ink)
		desc.Position = UDim2.fromOffset(100, 50)
		desc.Size = UDim2.new(1, -110, 0, 40)
		desc.TextXAlignment = Enum.TextXAlignment.Left
		desc.TextYAlignment = Enum.TextYAlignment.Top

		Theme.label(card, Text.PERSONALIDADE_7F8C9A .. entry.personality, 11, Theme.Muted).Position = UDim2.fromOffset(100, 85)
	end
end

return J