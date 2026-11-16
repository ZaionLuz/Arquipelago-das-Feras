--!strict
-- CollectionUI.luau - Dex with 3D model viewer via ViewportFrame, evolution tree, discovery overlay
-- Cassette Beasts pixel UI: 4px grid, 2px borders, selective outlining
-- 120-250ms transitions with easing, hover/pressed/disabled states
-- Mobile: responsive, touch targets >=44px, portrait/landscape battle UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Text = require(ReplicatedStorage.Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local C = require(RS.Shared.Creatures)
local MF = require(RS.Shared.ModelFactory)
local Animator = require(script.Parent.CreatureAnimator)
local Theme = require(script.Parent.UITheme)
local Icons = require(script.Parent.PixelIcons)

local UI = { rebuilds = 0 }

local TWEEN_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local LocalPlayer = Players.LocalPlayer

export type CreatureData = {
	id: string,
	name: string,
	el: string,
	rar: number,
	island: string,
	shape: string,
	hybrid: {string}?,
	hp: number,
	atk: number,
	gpm: number,
}

export type CollectionState = {
	creatures: {[string]: {id: string, lv: number}},
	discovered: {[string]: boolean},
}

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

local function visibleCheck(guiObject: GuiObject): boolean
	while guiObject do
		if guiObject:IsA("GuiObject") and not guiObject.Visible then
			return false
		end
		if guiObject:IsA("ScreenGui") and not guiObject.Enabled then
			return false
		end
		guiObject = guiObject.Parent
	end
	return true
end

-- Evolution chain helper
local function getEvolutionChain(speciesId: string): {string}
	local chain = {speciesId}
	local def = C.ById[speciesId]
	if not def then return chain end

	-- Check for future stage (like Fenix)
	if def.futureStage and def.futureStage.target then
		table.insert(chain, def.futureStage.target)
	end

	-- Standard 3-stage evolution based on level
	local normalStage = C.stage(100, speciesId)
	for lv = 1, normalStage - 1 do
		-- This would need proper evolution data; for now return base
	end

	return chain
end

function UI.preview(parent: Instance, def: CreatureData, lv: number, unknown: boolean): ViewportFrame
	local key = def.id .. ":" .. C.stage(lv, def.id) .. ":" .. tostring(unknown)
	local v = parent:FindFirstChild("CreaturePreview")
	if v and v:GetAttribute("PreviewKey") == key then
		return v
	end
	if not v then
		v = Instance.new("ViewportFrame")
		v.Name = "CreaturePreview"
		v.Size = UDim2.fromScale(1, 0.65)
		v.BackgroundTransparency = 1
		v.Ambient = Theme.Tokens.Ramps.Metal[3]
		v.LightDirection = Vector3.new(-1, -1, -1)
		v.LightColor = Theme.Tokens.Ink
		v.Parent = parent
	else
		v:ClearAllChildren()
	end
	v:SetAttribute("PreviewKey", key)
	local world = Instance.new("WorldModel")
	world.Parent = v

	local previewDef = def
	if unknown and def.acquisition == "special" then
		previewDef = C.ById.cinzelo
	end

	local model = MF.build(previewDef, lv, { preview = true })
	UI.rebuilds += 1

	for _, obj in model:GetDescendants() do
		if obj:IsA("BillboardGui") then
			obj:Destroy()
		elseif unknown and obj:IsA("BasePart") then
			obj.Color = Theme.Tokens.Ramps.Veil[1]
			obj.Material = Enum.Material.SmoothPlastic
		end
	end
	model.Parent = world

	local low, high = MF.bounds(model)
	local size = high - low
	local center = (low + high) * 0.5
	local ramp = Theme.Tokens.Elements[def.el] or Theme.Tokens.Ramps.Metal
	local width = math.max(size.X, size.Z) * 0.85

	for index = 1, 2 do
		local floor = Instance.new("Part")
		floor.Name = "SpecimenPlinth" .. index
		floor.Size = Vector3.new(width + (2 - index) * 0.5, 0.18, width * 0.65 + (2 - index) * 0.5)
		floor.CFrame = CFrame.new(center.X, low.Y - 0.4 + index * 0.18, center.Z)
		floor.Color = ramp[index == 1 and 1 or 2]
		floor.Material = Enum.Material.SmoothPlastic
		floor.Anchored = true
		floor.CanCollide = false
		floor.CanQuery = false
		floor.CanTouch = false
		floor.CastShadow = false
		floor.Parent = world
	end

	local camera = Instance.new("Camera")
	camera.FieldOfView = 40
	local distance = math.max(size.X, size.Y, size.Z) * 2
	camera.CFrame = CFrame.lookAt(center + Vector3.new(distance * 0.55, distance * 0.25, distance), center)
	camera.Parent = v
	v.CurrentCamera = camera

	Animator.register(model, function()
		return v.Parent ~= nil and visibleCheck(v)
	end, { camera = camera, center = center, distance = distance })

	return v
end

-- Evolution tree panel
function UI.evolutionTree(parent: Instance, speciesId: string, currentLv: number)
	local chain = getEvolutionChain(speciesId)

	local container = Instance.new("Frame")
	container.Size = UDim2.new(1, -16, 0, 120)
	container.BackgroundTransparency = 1
	container.Parent = parent

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 8)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Parent = container

	for i, evoId in chain do
		local def = C.ById[evoId]
		if not def then continue end

		local stage = C.stage(currentLv, evoId)
		local isCurrent = (i == 1) or (evoId == speciesId)
		local isUnlocked = stage >= i

		local card = Instance.new("Frame")
		card.Size = UDim2.fromOffset(100, 110)
		card.BackgroundColor3 = isUnlocked and Theme.Tokens.Elements[def.el][1] or Theme.Panel
		card.LayoutOrder = i
		card.Parent = container
		Theme.panel(card, isUnlocked and Theme.Tokens.Elements[def.el][4] or Theme.Edge)

		-- Icon/preview
		local previewHolder = Instance.new("Frame")
		previewHolder.Size = UDim2.fromScale(1, 0.6)
		previewHolder.BackgroundTransparency = 1
		previewHolder.Parent = card

		if isUnlocked then
			UI.preview(previewHolder, def, math.max(1, (i == 1 and 1) or (i == 2 and 7) or 15), false)
		else
			local icon = Icons.draw(previewHolder, "Egg", 24, Theme.Tokens.Ramps.Veil)
			icon.Position = UDim2.fromScale(0.5, 0.5)
			icon.AnchorPoint = Vector2.new(0.5, 0.5)
		end

		-- Name
		label(card, isUnlocked and def.name or "???", UDim2.fromScale(0, 0.62), UDim2.fromScale(1, 0.2), 11, Theme.Ink).TextXAlignment = Enum.TextXAlignment.Center

		-- Stage label
		local stageText = i == 1 and Text.ESTAGIO_BASE_8F2A1C or i == 2 and Text.ESTAGIO_2_9D8F2A or Text.ESTAGIO_FINAL_7C3E1F
		label(card, stageText, UDim2.fromScale(0, 0.82), UDim2.fromScale(1, 0.18), 10, Theme.Muted).TextXAlignment = Enum.TextXAlignment.Center

		-- Arrow between stages
		if i < #chain then
			local arrow = Icons.draw(container, "arrow_right", 16, Theme.Tokens.Ramps.Sand)
			arrow.Size = UDim2.fromOffset(24, 24)
			arrow.LayoutOrder = i + 0.5
		end
	end

	return container
end

function UI.card(parent: Instance, def: CreatureData, lv: number, known: boolean, order: number): Frame
	local card = Instance.new("Frame")
	card.Name = "CollectionCard"
	card.LayoutOrder = order
	card.Size = UDim2.new(1, -12, 0, 190)
	card.BackgroundColor3 = known and Theme.Tokens.Elements[def.el][1] or Theme.Panel
	card.Parent = parent
	Theme.panel(card, known and Theme.Tokens.Elements[def.el][3] or Theme.Edge)

	-- Element emblem
	local emblem = Icons.draw(card, def.el, 16, Theme.Tokens.Elements[def.el])
	emblem.Position = UDim2.fromOffset(8, 8)

	-- Rarity indicator
	if known then
		local rarityColors = {
			[1] = Theme.Tokens.Ramps.Metal[3],
			[2] = Theme.Tokens.Ramps.Cristal[3],
			[3] = Theme.Tokens.Ramps.Luz[3],
			[4] = Theme.Tokens.Ramps.Fogo[3],
		}
		local rarityDot = Instance.new("Frame")
		rarityDot.Size = UDim2.fromOffset(8, 8)
		rarityDot.Position = UDim2.new(1, -16, 0, 8)
		rarityDot.BackgroundColor3 = rarityColors[def.rar] or Theme.Muted
		rarityDot.Parent = card
		Theme.round(rarityDot)
	end

	local preview: ViewportFrame? = nil
	local function checkVisibility()
		if not card.Parent then return end
		local y = card.AbsolutePosition.Y
		local top = parent.AbsolutePosition.Y
		local shown = y + card.AbsoluteSize.Y >= top and y <= top + parent.AbsoluteSize.Y
		if shown and not preview then
			preview = UI.preview(card, def, lv, not known)
		elseif not shown and preview then
			preview:Destroy()
			preview = nil
		end
	end

	local connection = parent:GetPropertyChangedSignal("CanvasPosition"):Connect(checkVisibility)
	local resize = parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(checkVisibility)
	card.Destroying:Connect(function()
		connection:Disconnect()
		resize:Disconnect()
	end)
	task.defer(checkVisibility)

	-- Name
	label(card, known and def.name or Text.ESPECIE_DESCONHECIDA_6C9CF9, UDim2.fromScale(0, 0.65), UDim2.fromScale(1, 0.15), 14)

	-- Details
	label(card, known and (def.el .. " • " .. C.Rarity[def.rar] .. Text.NV_9D89AA .. lv) or Text.DESCUBRA_NOVOS_OVOS_38146F, UDim2.fromScale(0, 0.8), UDim2.fromScale(1, 0.18), 12, Theme.Muted)

	return card
end

function UI.discovery(gui: Instance, def: CreatureData, lv: number, evolved: boolean)
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Theme.Shadow
	overlay.BackgroundTransparency = 0.08
	overlay.ZIndex = Theme.Layers.Modal
	overlay.Parent = gui

	local panel = Instance.new("Frame")
	panel.Size = UDim2.fromScale(0.85, 0.85)
	panel.Position = UDim2.fromScale(0.075, 0.075)
	panel.BackgroundColor3 = Theme.Tokens.Elements[def.el][1]
	panel.Parent = overlay
	Theme.panel(panel, Theme.Tokens.Elements[def.el][4])

	-- Animate in
	panel.Size = UDim2.fromScale(0, 0)
	panel.Position = UDim2.fromScale(0.5, 0.5)
	panel.AnchorPoint = Vector2.new(0.5, 0.5)
	TweenService:Create(panel, TWEEN_MED, {Size = UDim2.fromScale(0.85, 0.85), Position = UDim2.fromScale(0.075, 0.075)}):Play()

	UI.preview(panel, def, lv, false)

	local titleText = evolved and Text.SUA_FERA_EVOLUIU_0ACEF1
		or (def.rar >= 3 and Text.ECLOSAO_EXTRAORDINARIA_EA7909 or Text.UMA_FERA_NASCEU_A8EB6A)
	label(panel, titleText, UDim2.fromScale(0, 0.02), UDim2.fromScale(1, 0.12), 18, Theme.Accent).TextXAlignment = Enum.TextXAlignment.Center

	label(panel, def.name .. " • " .. C.Rarity[def.rar] .. Text.NV_9D89AA .. lv, UDim2.fromScale(0, 0.68), UDim2.fromScale(1, 0.12), 16, Theme.Ink).TextXAlignment = Enum.TextXAlignment.Center

	label(panel, Text.VIDA_41EF99 .. def.hp .. Text.ATAQUE_4EE034 .. def.atk .. Text.OURO_MIN_BASE_C8313A .. def.gpm .. Text.ESTAGIO_D2FEE2 .. C.stage(lv, def.id), UDim2.fromScale(0.05, 0.77), UDim2.fromScale(0.9, 0.06), 12, Theme.Muted).TextXAlignment = Enum.TextXAlignment.Center

	local close = Instance.new("TextButton")
	close.Size = UDim2.new(0.8, 0, 0, 44)
	close.Position = UDim2.new(0.1, 0, 1, -56)
	close.Text = Text.CONTINUAR_AVENTURA_E2F9B1
	close.TextSize = 18
	close.Font = Theme.Font
	close.BackgroundColor3 = Theme.Tokens.Elements[def.el][2]
	close.Parent = panel
	close.Active = true
	close.Selectable = true
	Theme.bind(close)
	close.Activated:Connect(function()
		TweenService:Create(panel, TWEEN_FAST, {Size = UDim2.fromScale(0, 0), Position = UDim2.fromScale(0.5, 0.5)}):Play()
		task.delay(0.15, function()
			overlay:Destroy()
		end)
	end)

	-- Safety: never permanently block from closed menu or lost control
	task.delay(20, function()
		if overlay.Parent then
			overlay:Destroy()
		end
	end)

	return overlay
end

-- Main render function for Collection tab
export type RenderProps = {
	parent: ScrollingFrame,
	state: CollectionState,
	onSelect: (speciesId: string) -> (),
	selectedId: string?,
}

function UI.render(props: RenderProps)
	props.parent:ClearAllChildren()

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 8)
	listLayout.Parent = props.parent

	-- Header with stats
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, -8, 0, 60)
	header.BackgroundTransparency = 1
	header.LayoutOrder = 1
	header.Parent = props.parent

	local discovered = 0
	for _ in props.state.discovered do discovered += 1 end
	local total = #C.List

	label(header, Text.COLECAO_57798D .. " " .. discovered .. "/" .. total, UDim2.fromOffset(12, 0), UDim2.new(1, -24, 0, 30), 20, Theme.Accent)

	local progressBar = Instance.new("Frame")
	progressBar.Size = UDim2.new(1, -24, 0, 8)
	progressBar.Position = UDim2.fromOffset(12, 34)
	progressBar.BackgroundColor3 = Theme.Panel
	progressBar.Parent = header
	Theme.round(progressBar)
	Theme.stroke(progressBar)

	local progressFill = Instance.new("Frame")
	progressFill.Size = UDim2.fromScale(discovered / total, 1)
	progressFill.BackgroundColor3 = Theme.Mint
	progressFill.Parent = progressBar
	Theme.round(progressFill)

	-- Filter tabs
	local filterFrame = Instance.new("Frame")
	filterFrame.Size = UDim2.new(1, -8, 0, 40)
	filterFrame.BackgroundTransparency = 1
	filterFrame.LayoutOrder = 2
	filterFrame.Parent = props.parent

	local filterLayout = Instance.new("UIListLayout")
	filterLayout.FillDirection = Enum.FillDirection.Horizontal
	filterLayout.Padding = UDim.new(0, 6)
	filterLayout.Parent = filterFrame

	local filters = {Text.TODAS_7F8C9A, Text.FOGO_F77A3C, Text.AGUA_F11A05, Text.NATUREZA_FB1ED9, Text.TERRA_16D3AE, Text.AR_B623FF, Text.SOMBRA_94B135, Text.GELO_4A90D9, Text.ELETRICO_FFD600, Text.LUZ_FFF9C4, Text.METAL_B0BEC5, Text.CRISTAL_E1BEE7, Text.ARCANO_CE93D8}

	-- For now just render all cards
	local grid = Instance.new("Frame")
	grid.Size = UDim2.new(1, -8, 0, 0)
	grid.BackgroundTransparency = 1
	grid.AutomaticSize = Enum.AutomaticSize.Y
	grid.LayoutOrder = 3
	grid.Parent = props.parent

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0.5, -10, 0, 198)
	gridLayout.CellPadding = UDim2.fromOffset(8, 8)
	gridLayout.SortOrder = Enum.SortOrder.LayoutOrder
	gridLayout.Parent = grid

	local order = 0
	for _, def in C.List do
		order += 1
		local known = props.state.discovered[def.id]
		local lv = 1
		for _, cr in props.state.creatures do
			if cr.id == def.id then
				lv = math.max(lv, cr.lv)
			end
		end

		local card = UI.card(grid, def, lv, known, order)

		-- Click to select
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromScale(1, 1)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.Parent = card
		btn.Activated:Connect(function()
			props.onSelect(def.id)
		end)

		-- Highlight selected
		if props.selectedId == def.id then
			local highlight = Instance.new("UIStroke")
			highlight.Color = Theme.Mint
			highlight.Thickness = 3
			highlight.Parent = card
		end
	end
end

return UI