--!strict
-- TeamUI.luau - Party management, moves, evolution preview
-- Cassette Beasts pixel UI: 4px grid, 2px borders, selective outlining
-- 120-250ms transitions, easing, hover/pressed/disabled states
-- Mobile: responsive, touch targets ≥44px, portrait/landscape battle UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Text = require(ReplicatedStorage.Shared.Strings).Text
local C = require(ReplicatedStorage.Shared.Creatures)
local Moves = require(ReplicatedStorage.Shared.Moves)
local Elements = require(ReplicatedStorage.Shared.Elements)
local Theme = require(script.Parent.UITheme)
local Icons = require(script.Parent.PixelIcons)
local CollectionUI = require(script.Parent.CollectionUI)

local T = {}
local TWEEN_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TWEEN_SLOW = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

export type TeamSlot = {
	frame: Frame,
	creatureId: string?,
	level: number,
	preview: ViewportFrame?
}

local function mk(cls: string, props: {[string]: any}, parent: Instance?): Instance
	local o = Instance.new(cls)
	for k, v in props do
		o[k] = v
	end
	if cls == "TextButton" or cls == "Frame" or cls == "ScrollingFrame" then
		Theme.round(o)
		if cls ~= "ScrollingFrame" and props.BackgroundTransparency ~= 1 then
			Theme.stroke(o)
		end
	end
	if (cls == "TextButton" or cls == "TextLabel") and o.TextScaled then
		Instance.new("UITextSizeConstraint", o).MaxTextSize = 28
	end
	if cls == "TextButton" then
		o.Active = true
		o.Selectable = true
		Theme.bind(o)
	end
	if cls == "TextLabel" or cls == "TextButton" then
		o.Font = Theme.Font
	end
	if parent then
		o.Parent = parent
	end
	return o
end

local function label(parent: Instance, text: string, pos: UDim2, size: UDim2, textSize: number?): TextLabel
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Position = pos
	t.Size = size
	t.Text = text
	t.TextWrapped = true
	t.Font = Theme.Font
	t.TextSize = textSize or 14
	t.TextColor3 = Theme.Ink
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.TextYAlignment = Enum.TextYAlignment.Top
	t.Parent = parent
	return t
end

local function panel(parent: Instance, height: number): Frame
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -8, 0, height)
	f.BackgroundColor3 = Theme.Card
	f.Parent = parent
	Theme.panel(f)
	return f
end

-- Create a party slot (1-6)
local function createSlot(parent: Instance, index: number, cr: {id: string, lv: number}?): Frame
	local slot = Instance.new("Frame")
	slot.Name = "TeamSlot_" .. index
	slot.Size = UDim2.fromScale(1, 0.15)
	slot.BackgroundColor3 = Theme.Panel
	slot.Parent = parent
	Theme.panel(slot, Theme.Edge)

	-- Selection highlight
	local selectionStroke = Instance.new("UIStroke")
	selectionStroke.Name = "SelectionStroke"
	selectionStroke.Color = Theme.Accent
	selectionStroke.Thickness = 2
	selectionStroke.Transparency = 1
	selectionStroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	selectionStroke.Parent = slot

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 8)
	layout.Parent = slot

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.Parent = slot

	-- Icon + Preview
	local iconHolder = Instance.new("Frame")
	iconHolder.Size = UDim2.fromOffset(64, 64)
	iconHolder.BackgroundTransparency = 1
	iconHolder.Parent = slot

	local preview
	if cr then
		preview = CollectionUI.preview(iconHolder, C.ById[cr.id], cr.lv, false)
		preview.Size = UDim2.fromScale(1, 1)
		preview.Name = "CreaturePreview"
	end

	-- Element badge
	local badge = Instance.new("Frame")
	badge.Size = UDim2.fromOffset(36, 36)
	badge.BackgroundTransparency = 1
	badge.Parent = iconHolder
	if cr then
		local elIcon = Icons.draw(badge, cr.id and C.ById[cr.id].el or "Fera", 16, Theme.Tokens.Elements[C.ById[cr.id].el])
		elIcon.Position = UDim2.fromOffset(0, 0)
		elIcon.Size = UDim2.fromScale(1, 1)
	end

	-- Info panel
	local info = Instance.new("Frame")
	info.Size = UDim2.new(1, -100, 1, -16)
	info.BackgroundTransparency = 1
	info.Parent = slot

	local infoLayout = Instance.new("UIListLayout")
	infoLayout.Padding = UDim.new(0, 2)
	infoLayout.Parent = info

	if cr then
		local def = C.ById[cr.id]
		label(info, def.name .. "  •  " .. C.Rarity[def.rar], UDim2.new(), UDim2.new(1, 0, 0, 22), 16)
		label(info, "Nv. " .. cr.lv .. "  •  " .. def.el .. "  •  Estágio " .. C.stage(cr.lv, cr.id), UDim2.new(), UDim2.new(1, 0, 0, 18), 12).TextColor3 = Theme.Muted

		-- HP/ATK preview
		local stats = Instance.new("Frame")
		stats.Size = UDim2.new(1, 0, 0, 20)
		stats.BackgroundTransparency = 1
		stats.Parent = info

		local hpLabel = label(stats, "❤ " .. def.hp + (cr.lv - 1) * 3, UDim2.fromScale(0, 0), UDim2.fromScale(0.5, 1), 12)
		hpLabel.TextColor3 = Theme.Tokens.Ramps.Fogo[4]
		local atkLabel = label(stats, "⚔ " .. def.atk + (cr.lv - 1) * 2, UDim2.fromScale(0.5, 0), UDim2.fromScale(0.5, 1), 12)
		atkLabel.TextColor3 = Theme.Tokens.Ramps.Terra[4]
	else
		label(info, Text.ESCOLHA_UMA_FERA_SUA_E1857C, UDim2.new(), UDim2.new(1, 0, 0, 22), 14).TextColor3 = Theme.Muted
		local plus = Instance.new("TextButton")
		plus.Size = UDim2.fromOffset(44, 44)
		plus.Position = UDim2.fromScale(0.5, 0.5)
		plus.AnchorPoint = Vector2.new(0.5, 0.5)
		plus.BackgroundColor3 = Theme.Card
		plus.Text = "+"
		plus.TextSize = 28
		plus.Font = Theme.Font
		plus.TextColor3 = Theme.Accent
		plus.Parent = iconHolder
		Theme.panel(plus, Theme.Accent)
		Theme.bind(plus)
		plus.Activated:Connect(function()
			-- Will be connected by parent
		end)
	end

	return slot
end

-- Moves panel for a creature
local function createMovesPanel(parent: Instance, cr: {id: string, lv: number}): Frame
	local movesFrame = Instance.new("Frame")
	movesFrame.Name = "MovesPanel"
	movesFrame.Size = UDim2.new(1, -8, 0, 280)
	movesFrame.BackgroundTransparency = 1
	movesFrame.Parent = parent

	local learnset = Moves.getLearnset(cr.id)
	local def = C.ById[cr.id]
	local availableMoves = {}

	for _, move in learnset do
		if move.category ~= "status" or move.power > 0 then
			local learnedAt = 1 -- Simplified: all moves available at level 1 for now
			if cr.lv >= learnedAt then
				table.insert(availableMoves, move)
			end
		end
	end

	-- Show up to 4 moves
	local displayMoves = {}
	for i = 1, math.min(4, #availableMoves) do
		table.insert(displayMoves, availableMoves[i])
	end

	-- Move slots grid
	local grid = Instance.new("UIGridLayout")
	grid.CellSize = UDim2.new(0.5, -6, 0, 60)
	grid.CellPadding = UDim2.fromOffset(8, 8)
	grid.Parent = movesFrame

	for i, move in displayMoves do
		local moveBtn = Instance.new("TextButton")
		moveBtn.Name = "Move_" .. move.id
		moveBtn.BackgroundColor3 = Theme.Card
		moveBtn.Text = ""
		moveBtn.AutoButtonColor = false
		moveBtn.Selectable = true
		moveBtn.Parent = movesFrame
		Theme.panel(moveBtn, Theme.Tokens.Elements[move.element][3])
		Theme.bind(moveBtn)

		-- Move icon
		local icon = Icons.draw(moveBtn, move.element, 16, Theme.Tokens.Elements[move.element])
		icon.Position = UDim2.fromOffset(8, 8)
		icon.Size = UDim2.fromOffset(24, 24)

		-- Move name
		label(moveBtn, move.name, UDim2.fromOffset(38, 4), UDim2.new(1, -46, 0, 20), 13)

		-- Move info
		local info = Instance.new("Frame")
		info.Size = UDim2.new(1, -16, 0, 30)
		info.Position = UDim2.fromOffset(8, 28)
		info.BackgroundTransparency = 1
		info.Parent = moveBtn

		-- Category icon
		local catIcon = Instance.new("TextLabel")
		catIcon.Size = UDim2.fromOffset(20, 20)
		catIcon.BackgroundTransparency = 1
		catIcon.Text = move.category == "physical" and "⚔" or move.category == "special" and "✨" or "🛡"
		catIcon.TextSize = 14
		catIcon.Font = Theme.Font
		catIcon.TextColor3 = Theme.Muted
		catIcon.Parent = info

		-- Power/Accuracy
		local powAcc = label(info,
			(move.power > 0 and "Poder: " .. move.power or "—") .. "   Precisão: " .. (move.accuracy == 1 and "—" or math.floor(move.accuracy * 100) .. "%"),
			UDim2.fromOffset(24, 0), UDim2.new(1, -24, 0, 18), 11)
		powAcc.TextColor3 = Theme.Muted

		-- PP
		local ppLabel = label(info, "PP: " .. move.pp, UDim2.fromOffset(24, 16), UDim2.new(1, -24, 0, 14), 11)
		ppLabel.TextColor3 = Theme.Tokens.Ramps.Sand[4]

		-- Elemental effectiveness indicator
		local eff = Instance.new("TextLabel")
		eff.Size = UDim2.fromOffset(60, 16)
		eff.Position = UDim2.new(1, -68, 0, 4)
		eff.BackgroundTransparency = 1
		eff.Text = Elements.effectivenessText(2) -- placeholder
		eff.TextSize = 10
		eff.Font = Theme.Font
		eff.TextColor3 = Theme.Accent
		eff.Visible = false
		eff.Parent = moveBtn
	end

	-- Empty slots (up to 4)
	for i = #displayMoves + 1, 4 do
		local empty = Instance.new("Frame")
		empty.Size = UDim2.fromScale(0.5, 0)
		empty.BackgroundColor3 = Theme.Panel
		empty.BackgroundTransparency = 0.5
		empty.Parent = movesFrame
		Theme.panel(empty, Theme.Muted)

		local plus = Instance.new("TextLabel")
		plus.Size = UDim2.fromScale(1, 1)
		plus.BackgroundTransparency = 1
		plus.Text = "+"
		plus.TextSize = 24
		plus.Font = Theme.Font
		plus.TextColor3 = Theme.Muted
		plus.Parent = empty
	end

	return movesFrame
end

-- Evolution preview
local function createEvolutionPreview(parent: Instance, cr: {id: string, lv: number}): Frame
	local evoFrame = Instance.new("Frame")
	evoFrame.Name = "EvolutionPreview"
	evoFrame.Size = UDim2.new(1, -8, 0, 180)
	evoFrame.BackgroundTransparency = 1
	evoFrame.Parent = parent

	local def = C.ById[cr.id]
	local currentStage = C.stage(cr.lv, cr.id)

	label(evoFrame, Text.EVOLUI_EM_7_15_75E2ED, UDim2.new(), UDim2.new(1, 0, 0, 24), 14).TextColor3 = Theme.Accent

	-- Current form
	local current = Instance.new("Frame")
	current.Size = UDim2.fromScale(0.3, 1)
	current.Position = UDim2.fromScale(0, 0)
	current.BackgroundTransparency = 1
	current.Parent = evoFrame

	local currentPreview = CollectionUI.preview(current, def, cr.lv, false)
	currentPreview.Size = UDim2.fromScale(1, 0.7)
	currentPreview.Position = UDim2.fromScale(0, 0.1)

	label(current, def.name .. "\nNv. " .. cr.lv .. " (Estágio " .. currentStage .. ")", UDim2.new(), UDim2.fromScale(1, 0.25), 11)

	-- Arrow
	local arrow = Instance.new("TextLabel")
	arrow.Size = UDim2.fromScale(0.1, 1)
	arrow.Position = UDim2.fromScale(0.3, 0)
	arrow.BackgroundTransparency = 1
	arrow.Text = "→"
	arrow.TextSize = 32
	arrow.Font = Theme.Font
	arrow.TextColor3 = Theme.Accent
	arrow.TextScaled = true
	arrow.Parent = evoFrame

	-- Next evolution
	local nextStage = currentStage + 1
	if nextStage <= 3 and def.acquisition ~= "special" then
		local evoDef = def -- Same species, next stage
		local evoLv = nextStage == 2 and 7 or 15

		local next = Instance.new("Frame")
		next.Size = UDim2.fromScale(0.3, 1)
		next.Position = UDim2.fromScale(0.4, 0)
		next.BackgroundTransparency = 1
		next.Parent = evoFrame

		local nextPreview = CollectionUI.preview(next, evoDef, evoLv, false)
		nextPreview.Size = UDim2.fromScale(1, 0.7)
		nextPreview.Position = UDim2.fromScale(0, 0.1)

		label(next, evoDef.name .. "\nNv. " .. evoLv .. " (Estágio " .. nextStage .. ")", UDim2.new(), UDim2.fromScale(1, 0.25), 11)

		-- Requirement
		local req = Instance.new("Frame")
		req.Size = UDim2.fromScale(0.3, 1)
		req.Position = UDim2.fromScale(0.7, 0)
		req.BackgroundTransparency = 1
		req.Parent = evoFrame

		label(req, Text.ALIMENTE_5_VEZES_C4C1AB .. "\n" .. (cr.lv >= evoLv and Text.PRONTO_PARA_ECLODIR_379A20 or "Faltam " .. (evoLv - cr.lv) .. " níveis"), UDim2.new(), UDim2.fromScale(1, 0.5), 12).TextColor3 = cr.lv >= evoLv and Theme.Mint or Theme.Muted

		-- Progress bar
		local prog = Instance.new("Frame")
		prog.Size = UDim2.new(0.8, 0, 0, 8)
		prog.Position = UDim2.fromScale(0.1, 0.7)
		prog.BackgroundColor3 = Theme.Panel
		req.Parent = req
		Theme.panel(prog)

		local fill = Instance.new("Frame")
		fill.Size = UDim2.fromScale(math.clamp(cr.lv / evoLv, 0, 1), 1)
		fill.BackgroundColor3 = cr.lv >= evoLv and Theme.Mint or Theme.Accent
		fill.Parent = prog
		Theme.round(fill)
	else
		-- Max evolution or special
		local max = Instance.new("Frame")
		max.Size = UDim2.fromScale(0.6, 1)
		max.Position = UDim2.fromScale(0.4, 0)
		max.BackgroundTransparency = 1
		max.Parent = evoFrame

		if def.acquisition == "special" and def.futureStage then
			label(max, Text.RENASCIMENTO_FUTURO_9236DA .. "\n" .. def.futureStage.mechanic, UDim2.new(), UDim2.fromScale(1, 0.5), 12).TextColor3 = Theme.Tokens.Ramps.Luz[4]
		else
			label(max, Text.NIVEL_MAXIMO_8078AA, UDim2.new(), UDim2.fromScale(1, 0.5), 14).TextColor3 = Theme.Muted
		end
	end

	return evoFrame
end

-- Main Team UI render function
function T.render(parent: ScrollingFrame, creatures: {[string]: {id: string, lv: number}}, companionId: string?, onSelect: (string) -> (), onBattle: (string, string) -> (), onCompanion: (string) -> ())
	-- Clear existing
	for _, child in parent:GetChildren() do
		if child:IsA("Frame") then
			child:Destroy()
		end
	end

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 12)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = parent

	-- Party header
	local header = panel(parent, 50)
	header.LayoutOrder = 1
	header.BackgroundTransparency = 1

	label(header, Text.SUA_EQUIPE_C6DEB4 .. " (6/6)", UDim2.fromOffset(12, 0), UDim2.new(1, -24, 1, 0), 18).TextColor3 = Theme.Accent

	-- Party slots (6 slots)
	local partyFrame = Instance.new("Frame")
	partyFrame.Name = "PartyFrame"
	partyFrame.Size = UDim2.new(1, -8, 0, 390)
	partyFrame.BackgroundTransparency = 1
	partyFrame.Parent = parent
	partyFrame.LayoutOrder = 2

	local partyLayout = Instance.new("UIListLayout")
	partyLayout.Padding = UDim.new(0, 8)
	partyLayout.Parent = partyFrame

	-- Get sorted creatures by party order (companion first)
	local sorted = {}
	for uid, cr in creatures do
		table.insert(sorted, {uid = uid, cr = cr, isCompanion = uid == companionId})
	end
	table.sort(sorted, function(a, b)
		if a.isCompanion ~= b.isCompanion then return a.isCompanion end
		return a.cr.lv > b.cr.lv
	end)

	-- Ensure 6 slots
	for i = 1, 6 do
		local data = sorted[i]
		local slot = createSlot(partyFrame, i, data and data.cr or nil)
		slot.LayoutOrder = i

		if data then
			-- Companion indicator
			if data.isCompanion then
				local badge = Instance.new("TextLabel")
				badge.Size = UDim2.fromOffset(60, 20)
				badge.Position = UDim2.new(1, -68, 0, 4)
				badge.BackgroundColor3 = Theme.Accent
				badge.Text = "★ COMPANHEIRO"
				badge.TextSize = 10
				badge.Font = Theme.Font
				badge.TextColor3 = Theme.Panel
				badge.Parent = slot
				Theme.round(badge)
			end

			-- Make slot clickable
			local clickArea = Instance.new("TextButton")
			clickArea.Size = UDim2.fromScale(1, 1)
			clickArea.BackgroundTransparency = 1
			clickArea.Text = ""
			clickArea.ZIndex = 2
			clickArea.Parent = slot

			clickArea.MouseEnter:Connect(function()
				TweenService:Create(slot.SelectionStroke, TWEEN_FAST, {Transparency = 0}):Play()
			end)
			clickArea.MouseLeave:Connect(function()
				TweenService:Create(slot.SelectionStroke, TWEEN_FAST, {Transparency = 1}):Play()
			end)

			clickArea.Activated:Connect(function()
				onSelect(data.uid)
			end)
		else
			-- Empty slot - click to add
			local clickArea = Instance.new("TextButton")
			clickArea.Size = UDim2.fromScale(1, 1)
			clickArea.BackgroundTransparency = 1
			clickArea.Text = ""
			clickArea.ZIndex = 2
			clickArea.Parent = slot
			clickArea.Activated:Connect(function()
				onSelect("add_" .. i)
			end)
		end
	end

	-- Selected creature detail panel
	local detailFrame = Instance.new("Frame")
	detailFrame.Name = "DetailFrame"
	detailFrame.Size = UDim2.new(1, -8, 0, 0)
	detailFrame.BackgroundTransparency = 1
	detailFrame.Visible = false
	detailFrame.Parent = parent
	detailFrame.LayoutOrder = 3

	-- This will be populated when a creature is selected

	-- Return functions to update detail
	function T.showDetail(uid: string, cr: {id: string, lv: number})
		detailFrame.Visible = true
		detailFrame:ClearAllChildren()

		local detailLayout = Instance.new("UIListLayout")
		detailLayout.Padding = UDim.new(0, 12)
		detailLayout.Parent = detailFrame

		-- Header with creature name
		local def = C.ById[cr.id]
		local header = panel(detailFrame, 80)
		header.BackgroundColor3 = Theme.Tokens.Elements[def.el][1]
		Theme.panel(header, Theme.Tokens.Elements[def.el][4])

		local preview = CollectionUI.preview(header, def, cr.lv, false)
		preview.Size = UDim2.fromScale(0.25, 1)
		preview.Position = UDim2.fromScale(0.02, 0)

		label(header, def.name .. "  •  " .. C.Rarity[def.rar], UDim2.fromScale(0.3, 0.1), UDim2.fromScale(0.68, 0.3), 16)
		label(header, "Nv. " .. cr.lv .. "  •  " .. def.el .. "  •  Estágio " .. C.stage(cr.lv, cr.id), UDim2.fromScale(0.3, 0.4), UDim2.fromScale(0.68, 0.3), 13).TextColor3 = Theme.Muted

		-- Stats
		local stats = Instance.new("Frame")
		stats.Size = UDim2.fromScale(0.4, 0.6)
		stats.Position = UDim2.fromScale(0.55, 0.2)
		stats.BackgroundTransparency = 1
		stats.Parent = header

		local statLayout = Instance.new("UIListLayout")
		statLayout.Padding = UDim.new(0, 4)
		statLayout.Parent = stats

		local hp = def.hp + (cr.lv - 1) * 3
		local atk = def.atk + (cr.lv - 1) * 2
		local defStat = math.floor(def.hp * 0.6) + (cr.lv - 1) * 2
		local spd = math.floor(def.atk * 0.8) + (cr.lv - 1)

		for _, stat in {{"HP", hp, Theme.Tokens.Ramps.Fogo[4]}, {"ATK", atk, Theme.Tokens.Ramps.Terra[4]}, {"DEF", defStat, Theme.Tokens.Ramps.Metal[4]}, {"SPD", spd, Theme.Tokens.Ramps.Ar[4]}} do
			local row = Instance.new("Frame")
			row.Size = UDim2.new(1, 0, 0, 20)
			row.BackgroundTransparency = 1
			row.Parent = stats

			label(row, stat[1], UDim2.new(), UDim2.fromScale(0.3, 1), 12)
			label(row, tostring(stat[2]), UDim2.fromScale(0.3, 0), UDim2.fromScale(0.7, 1), 12).TextColor3 = stat[3]
		end

		-- Moves panel
		createMovesPanel(detailFrame, cr)

		-- Evolution preview
		createEvolutionPreview(detailFrame, cr)

		-- Action buttons
		local actions = panel(detailFrame, 60)
		actions.BackgroundTransparency = 1

		local actionLayout = Instance.new("UIListLayout")
		actionLayout.FillDirection = Enum.FillDirection.Horizontal
		actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		actionLayout.Padding = UDim.new(0, 8)
		actionLayout.Parent = actions

		-- Battle button
		local battleBtn = Instance.new("TextButton")
		battleBtn.Size = UDim2.fromOffset(140, 44)
		battleBtn.Text = Text.TREINO_172166
		battleBtn.TextSize = 14
		battleBtn.Font = Theme.Font
		battleBtn.TextColor3 = Theme.Ink
		battleBtn.BackgroundColor3 = Theme.Accent
		battleBtn.Parent = actions
		Theme.panel(battleBtn)
		Theme.bind(battleBtn)
		battleBtn.Activated:Connect(function()
			onBattle(uid, "wild")
		end)

		-- Companion button
		local compBtn = Instance.new("TextButton")
		compBtn.Size = UDim2.fromOffset(140, 44)
		compBtn.Text = companionId == uid and Text.GUARDAR_A0B626 or Text.COMPANHEIRO_FDBCE5
		compBtn.TextSize = 14
		compBtn.Font = Theme.Font
		compBtn.TextColor3 = Theme.Ink
		compBtn.BackgroundColor3 = Theme.Tokens.Ramps.Luz[2]
		compBtn.Parent = actions
		Theme.panel(compBtn)
		Theme.bind(compBtn)
		compBtn.Activated:Connect(function()
			onCompanion(uid)
		end)

		-- Remove button
		local removeBtn = Instance.new("TextButton")
		removeBtn.Size = UDim2.fromOffset(100, 44)
		removeBtn.Text = "Remover"
		removeBtn.TextSize = 14
		removeBtn.Font = Theme.Font
		removeBtn.TextColor3 = Theme.Panel
		removeBtn.BackgroundColor3 = Theme.Tokens.Ramps.Fogo[2]
		removeBtn.Parent = actions
		Theme.panel(removeBtn)
		Theme.bind(removeBtn)
		removeBtn.Activated:Connect(function()
			onSelect("remove_" .. uid)
		end)

		-- Animate in
		detailFrame.Size = UDim2.new(1, -8, 0, 0)
		TweenService:Create(detailFrame, TWEEN_MED, {Size = UDim2.new(1, -8, 0, 600)}):Play()
	end

	function T.hideDetail()
		TweenService:Create(detailFrame, TWEEN_FAST, {Size = UDim2.new(1, -8, 0, 0)}):Play()
		task.delay(0.15, function()
			detailFrame.Visible = false
			detailFrame:ClearAllChildren()
		end)
	end

	function T.refresh()
		-- Re-render party slots
	end

	return T
end

return T