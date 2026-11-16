--!strict
-- TradeUI.luau - Player trading (evolution trades)
-- Cassette Beasts pixel UI: 4px grid, 2px borders, selective outlining
-- 120-250ms transitions, easing, hover/pressed/disabled states
-- Mobile: responsive, touch targets ≥44px, portrait/landscape battle UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Text = require(ReplicatedStorage.Shared.Strings).Text
local C = require(ReplicatedStorage.Shared.Creatures)
local Theme = require(script.Parent.UITheme)
local Icons = require(script.Parent.PixelIcons)
local CollectionUI = require(script.Parent.CollectionUI)

local T = {}
local TWEEN_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TWEEN_SLOW = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

export type TradeState = {
	phase: "idle" | "waiting" | "trading" | "completed" | "cancelled",
	partner: Player?,
	offer: {[string]: {id: string, lv: number}}?,
	partnerOffer: {[string]: {id: string, lv: number}}?,
	accepted: boolean,
	partnerAccepted: boolean,
	timer: number?
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

local function label(parent: Instance, text: string, pos: UDim2, size: UDim2, textSize: number?, color: Color3?): TextLabel
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Position = pos
	t.Size = size
	t.Text = text
	t.TextWrapped = true
	t.Font = Theme.Font
	t.TextSize = textSize or 14
	t.TextColor3 = color or Theme.Ink
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

-- Create trade partner frame
local function createPartnerFrame(parent: Instance, isLocal: boolean, name: string, state: TradeState): Frame
	local frame = Instance.new("Frame")
	frame.Name = isLocal and "LocalOffer" or "PartnerOffer"
	frame.Size = UDim2.new(0.5, -6, 1, -60)
	frame.Position = isLocal and UDim2.fromScale(0, 0) or UDim2.fromScale(0.5, 0)
	frame.BackgroundColor3 = Theme.Panel
	frame.Parent = parent
	Theme.panel(frame, isLocal and Theme.Mint or Theme.Accent)

	-- Partner name
	local nameLabel = label(frame, name .. (isLocal and " (Você)" or ""), UDim2.fromOffset(12, 8), UDim2.new(1, -24, 0, 24), 16, isLocal and Theme.Mint or Theme.Accent)

	-- Status indicator
	local status = Instance.new("Frame")
	status.Size = UDim2.fromOffset(12, 12)
	status.Position = UDim2.new(1, -20, 0, 12)
	status.BackgroundColor3 = Theme.Muted
	status.Parent = frame
	Theme.round(status)

	local statusLabel = label(frame, "Aguardando...", UDim2.fromOffset(12, 36), UDim2.new(1, -24, 0, 20), 12, Theme.Muted)
	statusLabel.Name = "StatusLabel"

	-- Creatures grid
	local grid = Instance.new("ScrollingFrame")
	grid.Name = "CreaturesGrid"
	grid.Size = UDim2.new(1, -16, 1, -120)
	grid.Position = UDim2.fromOffset(8, 60)
	grid.BackgroundTransparency = 1
	grid.CanvasSize = UDim2.new()
	grid.AutomaticCanvasSize = Enum.AutomaticSize.Y
	grid.ScrollBarThickness = 4
	grid.Parent = frame

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0.5, -6, 0, 120)
	gridLayout.CellPadding = UDim2.fromOffset(8, 8)
	gridLayout.Parent = grid

	-- Accept button (local only)
	if isLocal then
		local acceptBtn = Instance.new("TextButton")
		acceptBtn.Name = "AcceptButton"
		acceptBtn.Size = UDim2.new(1, -16, 0, 44)
		acceptBtn.Position = UDim2.fromOffset(8, 1, -52)
		acceptBtn.AnchorPoint = Vector2.new(0, 1)
		acceptBtn.Text = state.accepted and "✓ ACEITO" or "ACEITAR TROCA"
		acceptBtn.TextSize = 14
		acceptBtn.Font = Theme.Font
		acceptBtn.TextColor3 = Theme.Panel
		acceptBtn.BackgroundColor3 = state.accepted and Theme.Mint or Theme.Accent
		acceptBtn.Parent = frame
		Theme.panel(acceptBtn)
		Theme.bind(acceptBtn)

		if state.accepted then
			acceptBtn.Active = false
			acceptBtn.Selectable = false
		end
	end

	return frame
end

-- Create creature offer card
local function createOfferCard(parent: Instance, uid: string, cr: {id: string, lv: number}, isLocal: boolean, onRemove: (string) -> ()): Frame
	local def = C.ById[cr.id]
	local card = Instance.new("Frame")
	card.Name = "Offer_" .. uid
	card.BackgroundColor3 = Theme.Card
	card.Parent = parent
	Theme.panel(card, Theme.Tokens.Elements[def.el][3])

	-- Preview
	local preview = CollectionUI.preview(card, def, cr.lv, false)
	preview.Size = UDim2.fromScale(1, 0.6)
	preview.Position = UDim2.fromScale(0, 0)

	-- Info
	label(card, def.name, UDim2.fromScale(0, 0.6), UDim2.fromScale(1, 0.2), 13)
	label(card, "Nv. " .. cr.lv .. "  •  " .. C.Rarity[def.rar], UDim2.fromScale(0, 0.8), UDim2.fromScale(1, 0.2), 11, Theme.Muted)

	-- Remove button (local only)
	if isLocal then
		local removeBtn = Instance.new("TextButton")
		removeBtn.Size = UDim2.fromScale(1, 0.18)
		removeBtn.Position = UDim2.fromScale(0, 1, -0.18)
		removeBtn.AnchorPoint = Vector2.new(0, 1)
		removeBtn.Text = "Remover"
		removeBtn.TextSize = 11
		removeBtn.Font = Theme.Font
		removeBtn.TextColor3 = Theme.Panel
		removeBtn.BackgroundColor3 = Theme.Tokens.Ramps.Fogo[2]
		removeBtn.Parent = card
		Theme.panel(removeBtn)
		Theme.bind(removeBtn)
		removeBtn.Activated:Connect(function()
			onRemove(uid)
		end)
	end

	-- Evolution trade indicator
	if def.acquisition == "special" or C.stage(cr.lv, cr.id) >= 3 then
		local evoBadge = Instance.new("Frame")
		evoBadge.Size = UDim2.fromOffset(80, 20)
		evoBadge.Position = UDim2.fromScale(0.5, 0)
		evoBadge.AnchorPoint = Vector2.new(0.5, 0)
		evoBadge.BackgroundColor3 = Theme.Tokens.Ramps.Luz[4]
		evoBadge.Parent = card
		Theme.round(evoBadge)

		label(evoBadge, "✦ EVOLUÇÃO ✦", UDim2.new(), UDim2.fromScale(1, 1), 9, Theme.Panel).TextXAlignment = Enum.TextXAlignment.Center
	end

	return card
end

-- Main Trade UI
function T.render(parent: ScrollingFrame, state: TradeState, creatures: {[string]: {id: string, lv: number}}, onAddOffer: (string) -> (), onRemoveOffer: (string) -> (), onAccept: () -> (), onCancel: () -> (), onConfirm: () -> ())
	parent:ClearAllChildren()

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 12)
	listLayout.Parent = parent

	-- Header
	local header = panel(parent, 60)
	header.LayoutOrder = 1
	header.BackgroundTransparency = 1

	label(header, "⚖ TROCA DE FERAS", UDim2.fromOffset(12, 0), UDim2.new(1, -100, 1, 0), 20, Theme.Accent).TextXAlignment = Enum.TextXAlignment.Left

	-- Timer
	if state.timer and state.timer > 0 then
		local timerLabel = label(header, state.timer .. "s", UDim2.new(1, -80, 0, 0), UDim2.fromOffset(70, 40), 18, Theme.Tokens.Ramps.Fogo[4])
		timerLabel.Name = "TimerLabel"
		timerLabel.TextXAlignment = Enum.TextXAlignment.Right
	end

	-- Cancel button
	local cancelBtn = Instance.new("TextButton")
	cancelBtn.Size = UDim2.fromOffset(80, 36)
	cancelBtn.Position = UDim2.new(1, -88, 0, 12)
	cancelBtn.Text = "CANCELAR"
	cancelBtn.TextSize = 12
	cancelBtn.Font = Theme.Font
	cancelBtn.TextColor3 = Theme.Panel
	cancelBtn.BackgroundColor3 = Theme.Tokens.Ramps.Fogo[2]
	cancelBtn.Parent = header
	Theme.panel(cancelBtn)
	Theme.bind(cancelBtn)
	cancelBtn.Activated:Connect(onCancel)

	if state.phase == "idle" or state.phase == "waiting" then
		-- Waiting for partner
		local waitFrame = panel(parent, 200)
		waitFrame.LayoutOrder = 2

		local waitIcon = Icons.draw(waitFrame, "Fera", 48, Theme.Tokens.Ramps.Luz)
		waitIcon.Position = UDim2.fromScale(0.5, 0.3)
		waitIcon.AnchorPoint = Vector2.new(0.5, 0.5)

		label(waitFrame, state.partner and ("Aguardando " .. state.partner.DisplayName .. "...") or "Procurando parceiro...", UDim2.fromScale(0, 0.6), UDim2.fromScale(1, 0.3), 16).TextColor3 = Theme.Muted

		if not state.partner then
			local findBtn = Instance.new("TextButton")
			findBtn.Size = UDim2.fromOffset(200, 44)
			findBtn.Position = UDim2.fromScale(0.5, 0.85)
			findBtn.AnchorPoint = Vector2.new(0.5, 0.5)
			findBtn.Text = "BUSCAR PARCEIRO"
			findBtn.TextSize = 14
			findBtn.Font = Theme.Font
			findBtn.TextColor3 = Theme.Panel
			findBtn.BackgroundColor3 = Theme.Accent
			findBtn.Parent = waitFrame
			Theme.panel(findBtn)
			Theme.bind(findBtn)
			findBtn.Activated:Connect(function()
				-- Trigger server to find trade partner
			end)
		end

	elseif state.phase == "trading" then
		-- Active trade view
		local tradeFrame = Instance.new("Frame")
		tradeFrame.Name = "TradeFrame"
		tradeFrame.Size = UDim2.new(1, -8, 0, 420)
		tradeFrame.BackgroundTransparency = 1
		tradeFrame.Parent = parent
		tradeFrame.LayoutOrder = 2

		-- Partner frames side by side
		local offersContainer = Instance.new("Frame")
		offersContainer.Size = UDim2.new(1, 0, 1, -60)
		offersContainer.BackgroundTransparency = 1
		offersContainer.Parent = tradeFrame

		-- Local offer
		local localFrame = createPartnerFrame(offersContainer, true, Players.LocalPlayer.DisplayName, state)
		localFrame.Name = "LocalOffer"

		-- Partner offer
		local partnerFrame = createPartnerFrame(offersContainer, false, state.partner and state.partner.DisplayName or "???", state)
		partnerFrame.Name = "PartnerOffer"

		-- Populate local creatures
		local localGrid = localFrame.CreaturesGrid
		if state.offer then
			for uid, cr in state.offer do
				createOfferCard(localGrid, uid, cr, true, onRemoveOffer)
			end
		end

		-- Add creature button (local)
		if not state.accepted then
			local addBtn = Instance.new("TextButton")
			addBtn.Size = UDim2.fromScale(0.5, 0)
			addBtn.BackgroundColor3 = Theme.Card
			addBtn.Text = "+ ADICIONAR"
			addBtn.TextSize = 14
			addBtn.Font = Theme.Font
			addBtn.TextColor3 = Theme.Accent
			addBtn.Parent = localGrid
			Theme.panel(addBtn, Theme.Accent)
			Theme.bind(addBtn)
			addBtn.Activated:Connect(function()
				-- Open creature picker
				T.showCreaturePicker(parent, creatures, state, onAddOffer)
			end)
		end

		-- Populate partner creatures (read-only)
		local partnerGrid = partnerFrame.CreaturesGrid
		if state.partnerOffer then
			for uid, cr in state.partnerOffer do
				createOfferCard(partnerGrid, uid, cr, false, function() end)
			end
		end

		-- Update status labels
		local localStatus = localFrame:FindFirstChild("StatusLabel")
		if localStatus then
			localStatus.Text = state.accepted and "✓ VOCÊ ACEITOU" or "Escolha suas feras e aceite"
			localStatus.TextColor3 = state.accepted and Theme.Mint or Theme.Muted
		end

		local partnerStatus = partnerFrame:FindFirstChild("StatusLabel")
		if partnerStatus then
			partnerStatus.Text = state.partnerAccepted and "✓ PARCEIRO ACEITOU" or "Aguardando parceiro..."
			partnerStatus.TextColor3 = state.partnerAccepted and Theme.Mint or Theme.Muted
		end

		-- Update accept button
		local acceptBtn = localFrame:FindFirstChild("AcceptButton")
		if acceptBtn and not state.accepted then
			acceptBtn.Activated:Connect(onAccept)
		end

		-- Both accepted - show confirm
		if state.accepted and state.partnerAccepted then
			local confirmFrame = panel(parent, 80)
			confirmFrame.LayoutOrder = 3
			confirmFrame.BackgroundColor3 = Theme.Tokens.Ramps.Luz[1]
			Theme.panel(confirmFrame, Theme.Tokens.Ramps.Luz[4])

			label(confirmFrame, "AMBOS ACEITARAM! Confirme para finalizar.", UDim2.fromOffset(12, 8), UDim2.new(1, -140, 0, 30), 14, Theme.Tokens.Ramps.Luz[4])

			local confirmBtn = Instance.new("TextButton")
			confirmBtn.Size = UDim2.fromOffset(120, 44)
			confirmBtn.Position = UDim2.new(1, -130, 0.5, -22)
			confirmBtn.AnchorPoint = Vector2.new(0, 0.5)
			confirmBtn.Text = "CONFIRMAR"
			confirmBtn.TextSize = 14
			confirmBtn.Font = Theme.Font
			confirmBtn.TextColor3 = Theme.Panel
			confirmBtn.BackgroundColor3 = Theme.Tokens.Ramps.Luz[4]
			confirmBtn.Parent = confirmFrame
			Theme.panel(confirmBtn)
			Theme.bind(confirmBtn)
			confirmBtn.Activated:Connect(onConfirm)
		end

	elseif state.phase == "completed" then
		-- Trade completed animation
		local completeFrame = panel(parent, 300)
		completeFrame.LayoutOrder = 2
		completeFrame.BackgroundColor3 = Theme.Tokens.Ramps.Natureza[1]
		Theme.panel(completeFrame, Theme.Tokens.Ramps.Natureza[4])

		local checkIcon = Instance.new("TextLabel")
		checkIcon.Size = UDim2.fromOffset(80, 80)
		checkIcon.Position = UDim2.fromScale(0.5, 0.3)
		checkIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		checkIcon.BackgroundTransparency = 1
		checkIcon.Text = "✓"
		checkIcon.TextSize = 64
		checkIcon.Font = Theme.Font
		checkIcon.TextColor3 = Theme.Tokens.Ramps.Natureza[4]
		checkIcon.Parent = completeFrame

		-- Animate checkmark
		checkIcon.Size = UDim2.fromOffset(0, 0)
		TweenService:Create(checkIcon, TWEEN_MED, {Size = UDim2.fromOffset(80, 80)}):Play()

		label(completeFrame, "TROCA CONCLUÍDA!", UDim2.fromScale(0, 0.55), UDim2.fromScale(1, 0.2), 22, Theme.Tokens.Ramps.Natureza[4]).TextXAlignment = Enum.TextXAlignment.Center

		-- Show traded creatures
		local results = Instance.new("Frame")
		results.Size = UDim2.new(1, -24, 0, 80)
		results.Position = UDim2.fromOffset(12, 0.7)
		results.BackgroundTransparency = 1
		results.Parent = completeFrame

		local resultsLayout = Instance.new("UIListLayout")
		resultsLayout.FillDirection = Enum.FillDirection.Horizontal
		resultsLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
		resultsLayout.Padding = UDim.new(0, 16)
		resultsLayout.Parent = results

		if state.offer then
			for _, cr in state.offer do
				local def = C.ById[cr.id]
				local card = Instance.new("Frame")
				card.Size = UDim2.fromOffset(100, 80)
				card.BackgroundTransparency = 1
				card.Parent = results

				local icon = Icons.draw(card, def.el, 32, Theme.Tokens.Elements[def.el])
				icon.Position = UDim2.fromScale(0.5, 0.2)
				icon.AnchorPoint = Vector2.new(0.5, 0.5)

				label(card, def.name, UDim2.fromScale(0, 0.6), UDim2.fromScale(1, 0.4), 11).TextXAlignment = Enum.TextXAlignment.Center
			end
		end

		task.delay(3, function()
			if parent.Parent then
				parent:ClearAllChildren()
				T.render(parent, {phase = "idle"}, creatures, onAddOffer, onRemoveOffer, onAccept, onCancel, onConfirm)
			end
		end)

	elseif state.phase == "cancelled" then
		local cancelFrame = panel(parent, 150)
		cancelFrame.LayoutOrder = 2
		cancelFrame.BackgroundColor3 = Theme.Tokens.Ramps.Fogo[1]
		Theme.panel(cancelFrame, Theme.Tokens.Ramps.Fogo[4])

		local xIcon = Instance.new("TextLabel")
		xIcon.Size = UDim2.fromOffset(60, 60)
		xIcon.Position = UDim2.fromScale(0.5, 0.3)
		xIcon.AnchorPoint = Vector2.new(0.5, 0.5)
		xIcon.BackgroundTransparency = 1
		xIcon.Text = "✕"
		xIcon.TextSize = 48
		xIcon.Font = Theme.Font
		xIcon.TextColor3 = Theme.Tokens.Ramps.Fogo[4]
		xIcon.Parent = cancelFrame

		label(cancelFrame, "TROCA CANCELADA", UDim2.fromScale(0, 0.55), UDim2.fromScale(1, 0.2), 20, Theme.Tokens.Ramps.Fogo[4]).TextXAlignment = Enum.TextXAlignment.Center
		label(cancelFrame, "A troca foi cancelada por um dos jogadores.", UDim2.fromScale(0, 0.7), UDim2.fromScale(1, 0.3), 13, Theme.Muted).TextXAlignment = Enum.TextXAlignment.Center

		task.delay(2, function()
			if parent.Parent then
				parent:ClearAllChildren()
				T.render(parent, {phase = "idle"}, creatures, onAddOffer, onRemoveOffer, onAccept, onCancel, onConfirm)
			end
		end)
	end
end

-- Creature picker for trade
function T.showCreaturePicker(parent: ScrollingFrame, creatures: {[string]: {id: string, lv: number}}, state: TradeState, onSelect: (string) -> ())
	local overlay = Instance.new("Frame")
	overlay.Name = "CreaturePickerOverlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.Position = UDim2.fromScale(0, 0)
	overlay.BackgroundColor3 = Theme.Shadow
	overlay.BackgroundTransparency = 0.3
	overlay.ZIndex = 100
	overlay.Parent = parent.Parent

	local picker = Instance.new("Frame")
	picker.Size = UDim2.fromScale(0.9, 0.8)
	picker.Position = UDim2.fromScale(0.05, 0.1)
	picker.BackgroundColor3 = Theme.Panel
	picker.ZIndex = 101
	picker.Parent = overlay
	Theme.panel(picker, Theme.Accent)

	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 50)
	header.BackgroundColor3 = Theme.Card
	header.Parent = picker
	Theme.panel(header)

	label(header, "ESCOLHA UMA FERA PARA OFERECER", UDim2.fromOffset(12, 0), UDim2.new(1, -100, 1, 0), 16, Theme.Accent)

	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.fromOffset(44, 44)
	closeBtn.Position = UDim2.new(1, -50, 0.5, -22)
	closeBtn.AnchorPoint = Vector2.new(0, 0.5)
	closeBtn.Text = "✕"
	closeBtn.TextSize = 20
	closeBtn.Font = Theme.Font
	closeBtn.TextColor3 = Theme.Muted
	closeBtn.BackgroundTransparency = 1
	closeBtn.Parent = header
	Theme.bind(closeBtn)
	closeBtn.Activated:Connect(function()
		overlay:Destroy()
	end)

	local grid = Instance.new("ScrollingFrame")
	grid.Size = UDim2.new(1, -16, 1, -66)
	grid.Position = UDim2.fromOffset(8, 58)
	grid.BackgroundTransparency = 1
	grid.CanvasSize = UDim2.new()
	grid.AutomaticCanvasSize = Enum.AutomaticSize.Y
	grid.ScrollBarThickness = 4
	grid.ZIndex = 102
	grid.Parent = picker

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0.33, -8, 0, 140)
	gridLayout.CellPadding = UDim2.fromOffset(8, 8)
	gridLayout.Parent = grid

	-- Filter out already offered creatures
	local offeredIds = {}
	if state.offer then
		for uid in state.offer do
			offeredIds[uid] = true
		end
	end

	for uid, cr in creatures do
		if not offeredIds[uid] then
			local def = C.ById[cr.id]
			local card = Instance.new("Frame")
			card.BackgroundColor3 = Theme.Card
			card.ZIndex = 103
			card.Parent = grid
			Theme.panel(card, Theme.Tokens.Elements[def.el][3])

			local preview = CollectionUI.preview(card, def, cr.lv, false)
			preview.Size = UDim2.fromScale(1, 0.6)

			label(card, def.name, UDim2.fromScale(0, 0.6), UDim2.fromScale(1, 0.15), 12)
			label(card, "Nv. " .. cr.lv .. "  •  " .. C.Rarity[def.rar], UDim2.fromScale(0, 0.75), UDim2.fromScale(1, 0.15), 10, Theme.Muted)

			local selectBtn = Instance.new("TextButton")
			selectBtn.Size = UDim2.fromScale(1, 0.2)
			selectBtn.Position = UDim2.fromScale(0, 1, -0.2)
			selectBtn.AnchorPoint = Vector2.new(0, 1)
			selectBtn.Text = "OFERECER"
			selectBtn.TextSize = 11
			selectBtn.Font = Theme.Font
			selectBtn.TextColor3 = Theme.Panel
			selectBtn.BackgroundColor3 = Theme.Accent
			selectBtn.ZIndex = 104
			selectBtn.Parent = card
			Theme.panel(selectBtn)
			Theme.bind(selectBtn)
			selectBtn.Activated:Connect(function()
				onSelect(uid)
				overlay:Destroy()
			end)
		end
	end

	-- Animate in
	picker.Size = UDim2.fromScale(0, 0)
	picker.Position = UDim2.fromScale(0.5, 0.5)
	picker.AnchorPoint = Vector2.new(0.5, 0.5)
	TweenService:Create(picker, TWEEN_MED, {Size = UDim2.fromScale(0.9, 0.8), Position = UDim2.fromScale(0.05, 0.1)}):Play()
end

return T