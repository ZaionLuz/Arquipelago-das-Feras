--!strict
-- NurseryUI.luau - Egg incubation with countdown, breeding preview with outcome probabilities, inheritance preview
-- Cassette Beasts pixel UI: 4px grid, 2px borders, selective outlining
-- 120-250ms transitions with easing, hover/pressed/disabled states
-- Mobile: responsive, touch targets >=44px, portrait/landscape battle UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")

local Text = require(ReplicatedStorage.Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local C = require(RS.Shared.Creatures)
local Balance = require(RS.Shared.Economy)
local Breeding = require(RS.Shared.Breeding)
local Preview = require(script.Parent.CollectionUI)
local Theme = require(script.Parent.UITheme)
local Icons = require(script.Parent.PixelIcons)

local N = {}

local TWEEN_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

export type EggData = {
	id: string,
	left: number,
	parents: {string}?,
	hybrid: boolean?,
}

export type NurseryState = {
	eggs: {EggData},
	creatures: {[string]: {id: string, lv: number}},
	gold: number,
}

export type NurseryCallbacks = {
	Hatch: (index: number) -> (),
	Speed: (index: number) -> (),
	Breed: (parentA: string, parentB: string) -> (),
}

local function frame(parent: Instance, height: number): Frame
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -12, 0, height)
	f.BackgroundColor3 = Theme.Card
	f.Parent = parent
	Theme.panel(f)
	return f
end

local function text(parent: Instance, name: string, value: string, pos: UDim2, size: UDim2, textSize: number?, color: Color3?): TextLabel
	local t = Instance.new("TextLabel")
	t.Name = name
	t.Text = value
	t.Position = pos
	t.Size = size
	t.BackgroundTransparency = 1
	t.TextColor3 = color or Theme.Ink
	t.TextSize = textSize or 14
	t.TextWrapped = true
	t.Font = Theme.Font
	t.Parent = parent
	return t
end

local function button(parent: Instance, name: string, value: string, pos: UDim2, size: UDim2, callback: () -> (), color: Color3?): TextButton
	local b = Instance.new("TextButton")
	b.Name = name
	b.Text = value
	b.Position = pos
	b.Size = size
	b.BackgroundColor3 = color or Theme.Tokens.Ramps.Sand[2]
	b.TextColor3 = Theme.Ink
	b.Font = Theme.Font
	b.TextSize = 14
	b.Parent = parent
	b.Active = true
	b.Selectable = true
	Theme.panel(b)
	Theme.bind(b)
	b.Activated:Connect(callback)
	return b
end

local function setEnabled(btn: TextButton, enabled: boolean)
	btn.Active = enabled
	btn.Selectable = enabled
	btn.AutoButtonColor = enabled
	btn.BackgroundTransparency = enabled and 0 or 0.65
	btn.TextColor3 = enabled and Theme.Ink or Theme.Muted
end

function N.egg(parent: ScrollingFrame, def: {id: string, el: string, hybrid: {string}?}, left: number, hatchCallback: () -> (), speedCallback: () -> ())
	local f = frame(parent, 180)
	f.Name = "IncubatingEgg"
	f:SetAttribute("ReadyClock", os.clock() + left)

	-- Egg preview in ViewportFrame
	local v = Instance.new("ViewportFrame")
	v.Size = UDim2.fromScale(0.3, 1)
	v.BackgroundTransparency = 1
	v.Ambient = Theme.Tokens.Ramps.Metal[3]
	v.LightColor = Theme.Ink
	v.LightDirection = Vector3.new(-1, -1, -1)
	v.Parent = f

	local egg = Instance.new("Part")
	egg.Shape = Enum.PartType.Ball
	egg.Size = Vector3.new(3, 4, 3)
	egg.Anchored = true
	egg.CanCollide = false
	egg.Color = Theme.Tokens.Elements[def.el][4]
	egg.Material = Enum.Material.SmoothPlastic
	egg.Parent = v

	-- Egg pattern marks
	for index = 1, 4 do
		local mark = Instance.new("Part")
		mark.Size = Vector3.new(0.32, 0.32, 0.08)
		mark.CFrame = CFrame.new((index % 2 == 0 and 1 or -1) * 0.55, (math.floor((index - 1) / 2) - 0.5) * 1.0, 1.4)
		mark.Anchored = true
		mark.CanCollide = false
		mark.CanQuery = false
		mark.CanTouch = false
		mark.Color = Theme.Tokens.Elements[def.el][2]
		mark.Parent = v
	end

	local icon = Icons.draw(f, "Egg", 16, Theme.Tokens.Elements[def.el])
	icon.Position = UDim2.fromOffset(8, 8)

	-- Hybrid gem indicator
	if def.hybrid then
		local gem = Instance.new("Part")
		gem.Shape = Enum.PartType.Ball
		gem.Size = Vector3.new(0.8, 1, 0.5)
		gem.Position = Vector3.new(0, 0.3, 1.4)
		gem.Anchored = true
		gem.Color = Theme.Tokens.Elements[def.hybrid[2]][3]
		gem.Parent = v
	end

	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.lookAt(Vector3.new(4, 2, 9), Vector3.zero)
	camera.Parent = v
	v.CurrentCamera = camera

	-- Element label
	text(f, "Element", Text.OVO_DE_763A79 .. def.el, UDim2.fromScale(0.32, 0.04), UDim2.fromScale(0.65, 0.22))

	-- Countdown label
	local countdownLabel = text(f, "Countdown", "", UDim2.fromScale(0.32, 0.28), UDim2.fromScale(0.65, 0.36))
	countdownLabel.TextSize = 13
	countdownLabel.TextYAlignment = Enum.TextYAlignment.Top

	-- Hatch button
	local hatchBtn = button(f, "Hatch", Text.CHOCAR_9C3E1F, UDim2.fromScale(0.33, 0.72), UDim2.new(0.31, 0, 0, 44), hatchCallback, Theme.Mint)

	-- Speed up button
	local speedBtn = button(f, "Speed", Text.ACELERAR_9C3E1F .. " " .. math.max(1, math.ceil(left / 30)) .. Text.GEMAS_BEE5F6, UDim2.fromScale(0.66, 0.72), UDim2.new(0.31, 0, 0, 44), speedCallback, Theme.Tokens.Ramps.Luz[2])

	-- Initial tick
	N.updateEgg(f)

	return f
end

function N.updateEgg(f: Frame)
	local readyClock = f:GetAttribute("ReadyClock")
	if not readyClock then return end

	local left = math.max(0, math.ceil(readyClock - os.clock()))
	local countdown = f:FindFirstChild("Countdown")
	local hatchBtn = f:FindFirstChild("Hatch")
	local speedBtn = f:FindFirstChild("Speed")

	if countdown then
		countdown.Text = left == 0 and Text.PRONTO_PARA_ECLODIR_379A20
			or (Text.INCUBANDO_75EABA .. left .. Text.S_ACELERAR_8DABB8 .. math.max(1, math.ceil(left / 30)) .. Text.GEMAS_BEE5F6)
	end

	if hatchBtn then setEnabled(hatchBtn, left == 0) end
	if speedBtn then setEnabled(speedBtn, left > 0) end
end

function N.tick(parent: ScrollingFrame)
	for _, f in parent:GetChildren() do
		if f.Name ~= "IncubatingEgg" then continue end
		N.updateEgg(f)
	end
end

function N.parents(parent: ScrollingFrame, a: {id: string, name: string, el: string, shape: string, hybrid: {string}?}, b: {id: string, name: string, el: string, shape: string, hybrid: {string}?}, outcomes: {[string]: number}, available: boolean, breedCallback: () -> ())
	local f = frame(parent, 420)
	f.Name = "BreedingPreview"

	-- Parent previews
	for index, def in {a, b} do
		local holder = Instance.new("Frame")
		holder.Size = UDim2.fromScale(0.48, 0.45)
		holder.Position = UDim2.fromScale((index - 1) * 0.52, 0)
		holder.BackgroundTransparency = 1
		holder.Parent = f

		Preview.preview(holder, def, 1, false)

		local nameLabel = text(holder, "Name", def.name .. " • " .. def.el .. (def.hybrid and " (Híbrido)" or ""), UDim2.fromScale(0, 0.65), UDim2.fromScale(1, 0.3), 12)
		nameLabel.TextXAlignment = Enum.TextXAlignment.Center

		-- Parent stats preview
		text(holder, "Stats", Text.HP_41EF99 .. C.ById[def.id].hp .. "  " .. Text.ATK_4EE034 .. C.ById[def.id].atk .. "  " .. Text.OURO_MIN_C8313A .. C.ById[def.id].gpm, UDim2.fromScale(0, 0.88), UDim2.fromScale(1, 0.1), 10, Theme.Muted).TextXAlignment = Enum.TextXAlignment.Center
	end

	-- Breeding arrow/icon between parents
	local arrow = Icons.draw(f, "arrow_right", 24, Theme.Tokens.Ramps.Sand)
	arrow.Position = UDim2.fromScale(0.46, 0.15)
	arrow.Size = UDim2.fromOffset(32, 32)
	arrow.AnchorPoint = Vector2.new(0.5, 0.5)

	-- Outcomes
	local outcomeNames = {}
	for _, def in C.List do
		local chance = outcomes[def.id]
		if chance and chance > 0 then
			table.insert(outcomeNames, {name = def.name, el = def.el, rarity = def.rar, chance = chance})
		end
	end

	-- Sort by chance descending
	table.sort(outcomeNames, function(a, b) return a.chance > b.chance end)

	-- Outcome list
	local outcomeFrame = Instance.new("Frame")
	outcomeFrame.Size = UDim2.new(1, -16, 0, 120)
	outcomeFrame.Position = UDim2.fromOffset(8, 190)
	outcomeFrame.BackgroundTransparency = 1
	outcomeFrame.Parent = f

	local outcomeLayout = Instance.new("UIListLayout")
	outcomeLayout.Padding = UDim.new(0, 4)
	outcomeLayout.Parent = outcomeFrame

	Theme.label(outcomeFrame, Text.POSSIVEIS_FILHOTES_9C3E1F, 14, Theme.Accent).LayoutOrder = 0

	for _, outcome in outcomeNames do
		local def = C.ById[outcome.name]
		if not def then continue end

		local row = Instance.new("Frame")
		row.Size = UDim2.new(1, 0, 0, 28)
		row.BackgroundColor3 = Theme.Panel
		row.BackgroundTransparency = 0.5
		row.Parent = outcomeFrame
		Theme.panel(row)

		-- Element icon
		local elIcon = Icons.draw(row, outcome.el, 14, Theme.Tokens.Elements[outcome.el])
		elIcon.Position = UDim2.fromOffset(4, 7)
		elIcon.Size = UDim2.fromOffset(14, 14)

		-- Name
		Theme.label(row, outcome.name, 12).Position = UDim2.fromOffset(22, 4)

		-- Rarity
		local rarityColors = {[1] = Theme.Tokens.Ramps.Metal[3], [2] = Theme.Tokens.Ramps.Cristal[3], [3] = Theme.Tokens.Ramps.Luz[3], [4] = Theme.Tokens.Ramps.Fogo[3]}
		local rarityDot = Instance.new("Frame")
		rarityDot.Size = UDim2.fromOffset(8, 8)
		rarityDot.Position = UDim2.new(1, -80, 0.5, -4)
		rarityDot.BackgroundColor3 = rarityColors[outcome.rarity] or Theme.Muted
		rarityDot.Parent = row
		Theme.round(rarityDot)

		-- Chance
		Theme.label(row, string.format("%.1f%%", outcome.chance * 100), 12, Theme.Accent).Position = UDim2.new(1, -60, 0, 4)
		Theme.label(row, Text.CHANCE_9C3E1F, 10, Theme.Muted).Position = UDim2.new(1, -120, 0, 4)
	end

	-- Inheritance preview
	local inheritFrame = Instance.new("Frame")
	inheritFrame.Size = UDim2.new(1, -16, 0, 80)
	inheritFrame.Position = UDim2.fromOffset(8, 320)
	inheritFrame.BackgroundTransparency = 1
	inheritFrame.Parent = f

	Theme.label(inheritFrame, Text.HERANCA_PREVIA_9C3E1F, 14, Theme.Accent).Position = UDim2.fromOffset(0, 0)

	-- Show what stats/mechanics can be inherited
	local inheritInfo = Text.FILHOTE_HERDA_ELEMENTO_DOS_PAIS
	if a.el ~= b.el then
		inheritInfo = Text.CHANCE_DE_HIBRIDO_9C3E1F .. " " .. string.format("%.0f%%", 25)
	end

	Theme.label(inheritFrame, inheritInfo, 12, Theme.Muted).Position = UDim2.fromOffset(0, 20)
	Theme.label(inheritFrame, Text.NIVEL_INICIAL_1_EVOLUCAO_AOS_7_15_9C3E1F, 11, Theme.Muted).Position = UDim2.fromOffset(0, 40)

	-- Cost and breed button
	local costText = Text.CUSTO_805D21 .. Balance.BreedCost .. Text.OURO_INCUBACAO_30480S_E8C4B8 .. (available and Text.CHOCADEIRA_DISPONIVEL_F42230 or Text.PRECISA_DE_OURO_E_VAGA_NA_CHOCADEIRA_7FC4F9)
	text(f, "Cost", costText, UDim2.fromScale(0.03, 0.88), UDim2.fromScale(0.94, 0.1), 12, available and Theme.Mint or Theme.Tokens.Ramps.Fogo[3])

	local breedBtn = button(f, "Breed", Text.CRUZAR_9C3E1F, UDim2.fromScale(0.15, 0.92), UDim2.new(0.7, 0, 0, 44), breedCallback, Theme.Mint)
	breedBtn.TextSize = 16
	setEnabled(breedBtn, available)

	return f
end

function N.render(parent: ScrollingFrame, state: NurseryState, callbacks: NurseryCallbacks, onRender: () -> ())
	parent:ClearAllChildren()

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 8)
	listLayout.Parent = parent

	-- Header
	local header = frame(parent, 60)
	header.LayoutOrder = 1
	header.BackgroundTransparency = 1

	Theme.label(header, Text.CHOCADEIRA_D1AF5D .. #state.eggs .. "/" .. Balance.IncubatorSlots, 18, Theme.Accent).Position = UDim2.fromOffset(12, 0)

	-- Slots indicator
	local slotsFrame = Instance.new("Frame")
	slotsFrame.Size = UDim2.new(1, -24, 0, 20)
	slotsFrame.Position = UDim2.fromOffset(12, 32)
	slotsFrame.BackgroundTransparency = 1
	slotsFrame.Parent = header

	for i = 1, Balance.IncubatorSlots do
		local slot = Instance.new("Frame")
		slot.Size = UDim2.fromOffset(16, 16)
		slot.Position = UDim2.fromOffset((i - 1) * 20, 0)
		slot.BackgroundColor3 = i <= #state.eggs and Theme.Mint or Theme.Panel
		slot.Parent = slotsFrame
		Theme.panel(slot, Theme.Edge)
	end

	-- Incubating eggs
	for i, egg in state.eggs do
		local def = C.ById[egg.id]
		if def then
			N.egg(parent, def, egg.left, function() callbacks.Hatch(i) end, function() callbacks.Speed(i) end)
		end
	end

	-- Breeding section
	if #state.eggs < Balance.IncubatorSlots then
		local breedHeader = frame(parent, 50)
		breedHeader.LayoutOrder = 100
		breedHeader.BackgroundTransparency = 1

		Theme.label(breedHeader, Text.CRUZAMENTO_9C3E1F, 18, Theme.Accent).Position = UDim2.fromOffset(12, 0)
		Theme.label(breedHeader, Text.ESCOLHA_DOIS_PROGENITORES_C7CD31, 12, Theme.Muted).Position = UDim2.fromOffset(12, 24)

		-- Parent selection would go here - for now show note
	end
end

return N