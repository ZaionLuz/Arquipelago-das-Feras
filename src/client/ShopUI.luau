--!strict
-- ShopUI.luau - Items, evolution stones, cosmetics
-- Cassette Beasts pixel UI: 4px grid, 2px borders, selective outlining
-- 120-250ms transitions, easing, hover/pressed/disabled states
-- Mobile: responsive, touch targets ≥44px, portrait/landscape battle UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Text = require(ReplicatedStorage.Shared.Strings).Text
local C = require(ReplicatedStorage.Shared.Creatures)
local Economy = require(ReplicatedStorage.Shared.Economy)
local EvolutionItems = require(ReplicatedStorage.Shared.EvolutionItems)
local Theme = require(script.Parent.UITheme)
local Icons = require(script.Parent.PixelIcons)

local S = {}
local TWEEN_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)
local TWEEN_SLOW = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

export type ShopCategory = "items" | "stones" | "cosmetics" | "eggs"
export type ShopItem = {
	id: string,
	name: string,
	description: string,
	price: number,
	currency: "gold" | "gems" | "seals",
	category: ShopCategory,
	icon: string,
	stock: number?, -- nil = unlimited
	requirement: string?, -- e.g. "level_10", "island_unlocked"
	effect: string?, -- description of effect
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

-- Shop items database
local SHOP_ITEMS: {ShopItem} = {
	-- Items
	{id = "seal_basic", name = "Selo Básico", description = "Captura feras comuns (Nv. 1-15)", price = 50, currency = "gold", category = "items", icon = "Seal", stock = nil, effect = "Taxa base de captura"},
	{id = "seal_great", name = "Selo Superior", description = "Captura feras raras (Nv. 16-40)", price = 200, currency = "gold", category = "items", icon = "Seal", stock = nil, requirement = "level_15", effect = "Taxa de captura 1.5x"},
	{id = "seal_ultra", name = "Selo Ultra", description = "Captura feras épicas (Nv. 41-70)", price = 500, currency = "gold", category = "items", icon = "Seal", stock = nil, requirement = "level_35", effect = "Taxa de captura 2x"},
	{id = "seal_master", name = "Selo Mestre", description = "Captura feras lendárias (Nv. 71+)", price = 1500, currency = "gold", category = "items", icon = "Seal", stock = nil, requirement = "level_60", effect = "Taxa de captura 3x"},

	{id = "potion_small", name = "Poção Pequena", description = "Restaura 20 HP", price = 30, currency = "gold", category = "items", icon = "Heart", stock = nil, effect = "Cura 20 HP"},
	{id = "potion_medium", name = "Poção Média", description = "Restaura 50 HP", price = 80, currency = "gold", category = "items", icon = "Heart", stock = nil, requirement = "level_10", effect = "Cura 50 HP"},
	{id = "potion_large", name = "Poção Grande", description = "Restaura 120 HP", price = 200, currency = "gold", category = "items", icon = "Heart", stock = nil, requirement = "level_25", effect = "Cura 120 HP"},
	{id = "potion_full", name = "Poção Total", description = "Restaura todo HP", price = 500, currency = "gold", category = "items", icon = "Heart", stock = nil, requirement = "level_50", effect = "Cura HP total"},

	{id = "ether_small", name = "Éter Pequeno", description = "Restaura 10 PP de um movimento", price = 50, currency = "gold", category = "items", icon = "Gem", stock = nil, effect = "Restaura 10 PP"},
	{id = "ether_large", name = "Éter Grande", description = "Restaura todo PP de um movimento", price = 150, currency = "gold", category = "items", icon = "Gem", stock = nil, requirement = "level_20", effect = "Restaura PP total"},

	{id = "revive", name = "Reviver", description = "Revive fera exausta com 50% HP", price = 1000, currency = "gold", category = "items", icon = "Heart", stock = nil, requirement = "level_30", effect = "Revive com 50% HP"},

	-- Evolution Stones
	{id = "stone_fire", name = "Pedra de Fogo", description = "Evolui feras de Fogo compatíveis", price = 800, currency = "gold", category = "stones", icon = "Fogo", stock = nil, requirement = "level_15", effect = "Evolução: Fogo"},
	{id = "stone_water", name = "Pedra de Água", description = "Evolui feras de Água compatíveis", price = 800, currency = "gold", category = "stones", icon = "Água", stock = nil, requirement = "level_15", effect = "Evolução: Água"},
	{id = "stone_nature", name = "Pedra de Natureza", description = "Evolui feras de Natureza compatíveis", price = 800, currency = "gold", category = "stones", icon = "Natureza", stock = nil, requirement = "level_15", effect = "Evolução: Natureza"},
	{id = "stone_earth", name = "Pedra de Terra", description = "Evolui feras de Terra compatíveis", price = 800, currency = "gold", category = "stones", icon = "Terra", stock = nil, requirement = "level_15", effect = "Evolução: Terra"},
	{id = "stone_air", name = "Pedra de Ar", description = "Evolui feras de Ar compatíveis", price = 800, currency = "gold", category = "stones", icon = "Ar", stock = nil, requirement = "level_15", effect = "Evolução: Ar"},
	{id = "stone_shadow", name = "Pedra de Sombra", description = "Evolui feras de Sombra compatíveis", price = 800, currency = "gold", category = "stones", icon = "Sombra", stock = nil, requirement = "level_15", effect = "Evolução: Sombra"},
	{id = "stone_ice", name = "Pedra de Gelo", description = "Evolui feras de Gelo compatíveis", price = 1200, currency = "gold", category = "stones", icon = "Gelo", stock = nil, requirement = "level_25", effect = "Evolução: Gelo"},
	{id = "stone_electric", name = "Pedra Elétrica", description = "Evolui feras Elétricas compatíveis", price = 1200, currency = "gold", category = "stones", icon = "Elétrico", stock = nil, requirement = "level_25", effect = "Evolução: Elétrico"},
	{id = "stone_light", name = "Pedra de Luz", description = "Evolui feras de Luz compatíveis", price = 1200, currency = "gold", category = "stones", icon = "Luz", stock = nil, requirement = "level_25", effect = "Evolução: Luz"},
	{id = "stone_metal", name = "Pedra de Metal", description = "Evolui feras de Metal compatíveis", price = 1200, currency = "gold", category = "stones", icon = "Metal", stock = nil, requirement = "level_25", effect = "Evolução: Metal"},
	{id = "stone_crystal", name = "Pedra de Cristal", description = "Evolui feras de Cristal compatíveis", price = 1500, currency = "gold", category = "stones", icon = "Cristal", stock = nil, requirement = "level_30", effect = "Evolução: Cristal"},
	{id = "stone_arcane", name = "Pedra Arcana", description = "Evolui feras Arcanas compatíveis", price = 1500, currency = "gold", category = "stones", icon = "Arcano", stock = nil, requirement = "level_30", effect = "Evolução: Arcano"},

	-- Special evolution items
	{id = "link_cable", name = "Cabo de Ligação", description = "Necessário para evoluções por troca", price = 2000, currency = "gold", category = "stones", icon = "Map", stock = nil, requirement = "level_40", effect = "Evolução por troca"},
	{id = "kings_rock", name = "Rocha do Rei", description = "Item de evolução especial", price = 3000, currency = "gold", category = "stones", icon = "Trophy", stock = nil, requirement = "level_50", effect = "Evolução especial"},
	{id = "metal_coat", name = "Capa Metálica", description = "Evolui feras de Metal por troca", price = 2500, currency = "gold", category = "stones", icon = "Metal", stock = nil, requirement = "level_40", effect = "Evolução: Metal (troca)"},
	{id = "dragon_scale", name = "Escama de Dragão", description = "Evolui feras Dragão por troca", price = 2500, currency = "gold", category = "stones", icon = "Fogo", stock = nil, requirement = "level_40", effect = "Evolução: Dragão (troca)"},
	{id = "up_grade", name = "Up-Grade", description = "Evolui feras tecnológicas", price = 3000, currency = "gold", category = "stones", icon = "Metal", stock = nil, requirement = "level_45", effect = "Evolução: Metal/Cristal"},
	{id = "dubious_disc", name = "Disco Duvidoso", description = "Evolução misteriosa", price = 5000, currency = "gold", category = "stones", icon = "Arcano", stock = nil, requirement = "level_55", effect = "Evolução: Arcano/Sombra"},

	-- Cosmetics
	{id = "skin_shiny", name = "Pele Brilhante", description = "Efeito visual brilhante para uma fera", price = 500, currency = "gems", category = "cosmetics", icon = "Gem", stock = nil, effect = "Visual: Brilho"},
	{id = "skin_golden", name = "Pele Dourada", description = "Efeito visual dourado para uma fera", price = 1000, currency = "gems", category = "cosmetics", icon = "Coin", stock = nil, effect = "Visual: Dourado"},
	{id = "skin_rainbow", name = "Pele Arco-íris", description = "Efeito visual arco-íris animado", price = 2000, currency = "gems", category = "cosmetics", icon = "Luz", stock = nil, effect = "Visual: Arco-íris animado"},
	{id = "particle_sparkle", name = "Partículas Cintilantes", description = "Partículas ao redor da fera", price = 300, currency = "gems", category = "cosmetics", icon = "Sparkle", stock = nil, effect = "VFX: Cintilante"},
	{id = "particle_flame", name = "Aura de Chamas", description = "Aura de fogo ao redor da fera", price = 400, currency = "gems", category = "cosmetics", icon = "Fogo", stock = nil, effect = "VFX: Fogo"},
	{id = "particle_mist", name = "Névoa Mística", description = "Névoa ao redor da fera", price = 400, currency = "gems", category = "cosmetics", icon = "Sombra", stock = nil, effect = "VFX: Névoa"},
	{id = "trail_stars", name = "Rastro de Estrelas", description = "Rastro ao mover", price = 500, currency = "gems", category = "cosmetics", icon = "Luz", stock = nil, effect = "VFX: Estrelas"},
	{id = "trail_leaves", name = "Rastro de Folhas", description = "Rastro ao mover", price = 300, currency = "gems", category = "cosmetics", icon = "Natureza", stock = nil, effect = "VFX: Folhas"},

	-- Eggs (available based on unlocked islands)
	{id = "egg_alvorecer", name = "Ovo do Alvorecer", description = "Fera do tipo Natureza (Nv. 1-5)", price = 80, currency = "gold", category = "eggs", icon = "Egg", stock = nil, requirement = "island_Alvorecer", effect = "Natureza • Comum/Raro"},
	{id = "egg_brasa", name = "Ovo da Brasa", description = "Fera do tipo Fogo (Nv. 1-5)", price = 80, currency = "gold", category = "eggs", icon = "Egg", stock = nil, requirement = "island_Brasa", effect = "Fogo • Comum/Raro"},
	{id = "egg_recife", name = "Ovo do Recife", description = "Fera do tipo Água (Nv. 5-15)", price = 200, currency = "gold", category = "eggs", icon = "Egg", stock = nil, requirement = "island_Recife", effect = "Água • Comum/Raro/Épico"},
	{id = "egg_floresta", name = "Ovo da Floresta", description = "Fera do tipo Natureza (Nv. 10-25)", price = 500, currency = "gold", category = "eggs", icon = "Egg", stock = nil, requirement = "island_Floresta", effect = "Natureza • Raro/Épico"},
	{id = "egg_dunas", name = "Ovo das Dunas", description = "Fera do tipo Terra (Nv. 20-40)", price = 1200, currency = "gold", category = "eggs", icon = "Egg", stock = nil, requirement = "island_Dunas", effect = "Terra • Raro/Épico/Lendário"},
	{id = "egg_picos", name = "Ovo dos Picos", description = "Fera do tipo Ar (Nv. 30-55)", price = 3000, currency = "gold", category = "eggs", icon = "Egg", stock = nil, requirement = "island_Picos", effect = "Ar • Épico/Lendário"},
	{id = "egg_pantano", name = "Ovo do Pântano", description = "Fera do tipo Sombra (Nv. 45-70)", price = 8000, currency = "gold", category = "eggs", icon = "Egg", stock = nil, requirement = "island_Pantano", effect = "Sombra • Épico/Lendário"},
}

-- Category definitions
local CATEGORIES: {ShopCategory} = {"items", "stones", "cosmetics", "eggs"}
local CATEGORY_LABELS = {
	items = "📦 ITENS",
	stones = "💎 PEDRAS EVOLUTIVAS",
	cosmetics = "✨ COSMÉTICOS",
	eggs = "🥚 OVOS",
}
local CATEGORY_ICONS = {
	items = "Book",
	stones = "Gem",
	cosmetics = "Trophy",
	eggs = "Egg",
}

-- Check if player meets requirement
local function checkRequirement(req: string?, playerData: any): boolean
	if not req then return true end
	if req:sub(1, 6) == "level_" then
		local lvl = tonumber(req:sub(7))
		return (playerData.playerLevel or 1) >= lvl
	elseif req:sub(1, 7) == "island_" then
		local island = req:sub(8)
		return playerData.unlocked and playerData.unlocked[island] == true
	end
	return true
end

-- Create shop item card
local function createItemCard(parent: Instance, item: ShopItem, playerData: any, onBuy: (string) -> (), canAfford: boolean): Frame
	local card = Instance.new("Frame")
	card.Name = "ShopItem_" .. item.id
	card.Size = UDim2.fromScale(1, 0)
	card.AutomaticSize = Enum.AutomaticSize.Y
	card.BackgroundColor3 = Theme.Card
	card.Parent = parent
	Theme.panel(card, canAfford and Theme.Tokens.Elements.Fogo[3] or Theme.Edge)

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Padding = UDim.new(0, 12)
	layout.Parent = card

	local padding = Instance.new("UIPadding")
	padding.PaddingLeft = UDim.new(0, 12)
	padding.PaddingRight = UDim.new(0, 12)
	padding.PaddingTop = UDim.new(0, 10)
	padding.PaddingBottom = UDim.new(0, 10)
	padding.Parent = card

	-- Icon
	local iconFrame = Instance.new("Frame")
	iconFrame.Size = UDim2.fromOffset(56, 56)
	iconFrame.BackgroundTransparency = 1
	iconFrame.Parent = card

	local icon = Icons.draw(iconFrame, item.icon, 24, Theme.Tokens.Ramps.Sand)
	icon.Position = UDim2.fromScale(0.5, 0.5)
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Size = UDim2.fromScale(1, 1)

	-- Info
	local info = Instance.new("Frame")
	info.Size = UDim2.new(1, -120, 1, 0)
	info.BackgroundTransparency = 1
	info.Parent = card

	local infoLayout = Instance.new("UIListLayout")
	infoLayout.Padding = UDim.new(0, 4)
	infoLayout.Parent = info

	local nameLabel = label(info, item.name, UDim2.new(), UDim2.new(1, 0, 0, 20), 15)

	local descLabel = label(info, item.description, UDim2.new(), UDim2.new(1, 0, 0, 18), 11, Theme.Muted)

	-- Category badge
	local catBadge = Instance.new("Frame")
	catBadge.Size = UDim2.fromOffset(80, 18)
	catBadge.BackgroundColor3 = Theme.Tokens.Ramps.Sand[2]
	catBadge.Parent = info
	Theme.round(catBadge)
	label(catBadge, CATEGORY_LABELS[item.category], UDim2.new(), UDim2.fromScale(1, 1), 9, Theme.Tokens.Ramps.Sand[4]).TextXAlignment = Enum.TextXAlignment.Center

	-- Price & Buy
	local buyFrame = Instance.new("Frame")
	buyFrame.Size = UDim2.fromOffset(100, 56)
	buyFrame.BackgroundTransparency = 1
	buyFrame.Parent = card

	local priceColor = canAfford and Theme.Ink or Theme.Tokens.Ramps.Fogo[4]
	local currencyIcon = item.currency == "gold" and "Coin" or item.currency == "gems" and "Gem" or "Seal"
	local currencyColor = item.currency == "gold" and Theme.Tokens.Ramps.Sand[4] or item.currency == "gems" and Theme.Tokens.Ramps.Gelo[4] or Theme.Tokens.Ramps.Luz[4]

	local priceText = label(buyFrame, item.price .. " ", UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 22), 14, priceColor)
	priceText.TextXAlignment = Enum.TextXAlignment.Right

	local currencyIconFrame = Icons.draw(buyFrame, currencyIcon, 16, {currencyColor})
	currencyIconFrame.Position = UDim2.new(1, -20, 0, 2)
	currencyIconFrame.Size = UDim2.fromOffset(18, 18)

	local buyBtn = Instance.new("TextButton")
	buyBtn.Size = UDim2.fromScale(1, 0)
	buyBtn.Position = UDim2.fromOffset(0, 26)
	buyBtn.Text = canAfford and "COMPRAR" or "INDISPONÍVEL"
	buyBtn.TextSize = 12
	buyBtn.Font = Theme.Font
	buyBtn.TextColor3 = Theme.Panel
	buyBtn.BackgroundColor3 = canAfford and Theme.Accent or Theme.Muted
	buyBtn.Active = canAfford
	buyBtn.Selectable = canAfford
	buyBtn.Parent = buyFrame
	Theme.panel(buyBtn)
	Theme.bind(buyBtn)

	if canAfford then
		buyBtn.Activated:Connect(function()
			onBuy(item.id)
		end)
	end

	-- Stock indicator
	if item.stock and item.stock > 0 then
		local stock = label(buyFrame, "Estoque: " .. item.stock, UDim2.fromOffset(0, 46), UDim2.new(1, 0, 0, 14), 10, Theme.Muted)
		stock.TextXAlignment = Enum.TextXAlignment.Right
	end

	-- Requirement not met
	if not checkRequirement(item.requirement, playerData) then
		local reqText = item.requirement:sub(1, 6) == "level_" and ("Necessário Nv. " .. item.requirement:sub(7)) or ("Necessário: " .. item.requirement:sub(8))
		local reqLabel = label(info, "🔒 " .. reqText, UDim2.new(), UDim2.new(1, 0, 0, 16), 10, Theme.Tokens.Ramps.Fogo[4])
	end

	return card
end

-- Main Shop UI
function S.render(parent: ScrollingFrame, playerData: any, onBuy: (string) -> (), onCategoryChange: (ShopCategory) -> ())
	parent:ClearAllChildren()

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 12)
	listLayout.Parent = parent

	-- Header with currency display
	local header = panel(parent, 70)
	header.LayoutOrder = 1
	header.BackgroundTransparency = 1

	label(header, "🏪 LOJA DO ARQUIPÉLAGO", UDim2.fromOffset(12, 0), UDim2.new(1, -200, 0, 30), 18, Theme.Accent)

	-- Currency displays
	local currencies = {
		{name = "Ouro", amount = playerData.gold or 0, icon = "Coin", color = Theme.Tokens.Ramps.Sand[4]},
		{name = "Gemas", amount = playerData.gems or 0, icon = "Gem", color = Theme.Tokens.Ramps.Gelo[4]},
		{name = "Selos", amount = playerData.seals or 0, icon = "Seal", color = Theme.Tokens.Ramps.Luz[4]},
	}

	for i, curr in currencies do
		local currFrame = Instance.new("Frame")
		currFrame.Size = UDim2.fromOffset(100, 30)
		currFrame.Position = UDim2.new(1, -320 + (i - 1) * 110, 0, 36)
		currFrame.BackgroundTransparency = 1
		currFrame.Parent = header

		local icon = Icons.draw(currFrame, curr.icon, 14, {curr.color})
		icon.Position = UDim2.fromOffset(0, 6)
		icon.Size = UDim2.fromOffset(18, 18)

		label(currFrame, curr.amount .. "", UDim2.fromOffset(22, 0), UDim2.new(1, -22, 1, 0), 13, curr.color).TextXAlignment = Enum.TextXAlignment.Left
	end

	-- Category tabs
	local tabFrame = panel(parent, 50)
	tabFrame.LayoutOrder = 2
	tabFrame.BackgroundTransparency = 1

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.Padding = UDim.new(0, 4)
	tabLayout.Parent = tabFrame

	for _, cat in CATEGORIES do
		local isActive = playerData.shopCategory == cat
		local tabBtn = Instance.new("TextButton")
		tabBtn.Size = UDim2.fromOffset(140, 36)
		tabBtn.Text = CATEGORY_LABELS[cat]
		tabBtn.TextSize = 11
		tabBtn.Font = Theme.Font
		tabBtn.TextColor3 = isActive and Theme.Panel or Theme.Ink
		tabBtn.BackgroundColor3 = isActive and Theme.Accent or Theme.Card
		tabBtn.Parent = tabFrame
		Theme.panel(tabBtn)
		Theme.bind(tabBtn)
		tabBtn.Activated:Connect(function()
			onCategoryChange(cat)
		end)
	end

	-- Items grid
	local category = playerData.shopCategory or "items"
	local filteredItems = {}
	for _, item in SHOP_ITEMS do
		if item.category == category then
			table.insert(filteredItems, item)
		end
	end

	if #filteredItems == 0 then
		local empty = panel(parent, 100)
		empty.LayoutOrder = 3
		empty.BackgroundTransparency = 1
		label(empty, "Nenhum item nesta categoria", UDim2.fromScale(0, 0.3), UDim2.fromScale(1, 0.4), 16, Theme.Muted).TextXAlignment = Enum.TextXAlignment.Center
		return
	end

	local gridFrame = Instance.new("Frame")
	gridFrame.Name = "ItemsGrid"
	gridFrame.Size = UDim2.new(1, -8, 0, 0)
	gridFrame.AutomaticSize = Enum.AutomaticSize.Y
	gridFrame.BackgroundTransparency = 1
	gridFrame.Parent = parent
	gridFrame.LayoutOrder = 3

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0.5, -10, 0, 160)
	gridLayout.CellPadding = UDim2.fromOffset(12, 12)
	gridLayout.Parent = gridFrame

	for _, item in filteredItems do
		local canAfford = false
		if item.currency == "gold" then
			canAfford = (playerData.gold or 0) >= item.price
		elseif item.currency == "gems" then
			canAfford = (playerData.gems or 0) >= item.price
		elseif item.currency == "seals" then
			canAfford = (playerData.seals or 0) >= item.price
		end

		createItemCard(gridFrame, item, playerData, onBuy, canAfford)
	end
end

-- Purchase confirmation modal
function S.showPurchaseConfirm(parent: Instance, item: ShopItem, playerData: any, onConfirm: () -> (), onCancel: () -> ())
	local overlay = Instance.new("Frame")
	overlay.Name = "PurchaseConfirmOverlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Theme.Shadow
	overlay.BackgroundTransparency = 0.4
	overlay.ZIndex = 100
	overlay.Parent = parent

	local modal = Instance.new("Frame")
	modal.Size = UDim2.fromOffset(320, 220)
	modal.Position = UDim2.fromScale(0.5, 0.5)
	modal.AnchorPoint = Vector2.new(0.5, 0.5)
	modal.BackgroundColor3 = Theme.Panel
	modal.ZIndex = 101
	modal.Parent = overlay
	Theme.panel(modal, Theme.Accent)

	-- Animate in
	modal.Size = UDim2.fromOffset(0, 0)
	TweenService:Create(modal, TWEEN_MED, {Size = UDim2.fromOffset(320, 220)}):Play()

	label(modal, "CONFIRMAR COMPRA", UDim2.fromOffset(16, 12), UDim2.new(1, -32, 0, 24), 16, Theme.Accent).TextXAlignment = Enum.TextXAlignment.Center

	-- Item preview
	local previewFrame = Instance.new("Frame")
	previewFrame.Size = UDim2.fromOffset(80, 80)
	previewFrame.Position = UDim2.fromScale(0.5, 0.4)
	previewFrame.AnchorPoint = Vector2.new(0.5, 0.5)
	previewFrame.BackgroundTransparency = 1
	previewFrame.ZIndex = 102
	previewFrame.Parent = modal

	local icon = Icons.draw(previewFrame, item.icon, 40, Theme.Tokens.Ramps.Sand)
	icon.Position = UDim2.fromScale(0.5, 0.5)
	icon.AnchorPoint = Vector2.new(0.5, 0.5)
	icon.Size = UDim2.fromScale(1, 1)

	label(modal, item.name, UDim2.fromOffset(16, 90), UDim2.new(1, -32, 0, 24), 16, Theme.Ink).TextXAlignment = Enum.TextXAlignment.Center
	label(modal, item.description, UDim2.fromOffset(16, 114), UDim2.new(1, -32, 0, 30), 12, Theme.Muted).TextXAlignment = Enum.TextXAlignment.Center

	-- Price
	local currencyIcon = item.currency == "gold" and "Coin" or item.currency == "gems" and "Gem" or "Seal"
	local currencyColor = item.currency == "gold" and Theme.Tokens.Ramps.Sand[4] or item.currency == "gems" and Theme.Tokens.Ramps.Gelo[4] or Theme.Tokens.Ramps.Luz[4]

	local priceFrame = Instance.new("Frame")
	priceFrame.Size = UDim2.fromOffset(120, 24)
	priceFrame.Position = UDim2.fromScale(0.5, 0.7)
	priceFrame.AnchorPoint = Vector2.new(0.5, 0)
	priceFrame.BackgroundTransparency = 1
	priceFrame.ZIndex = 102
	priceFrame.Parent = modal

	local priceLabel = label(priceFrame, item.price .. " ", UDim2.fromOffset(0, 0), UDim2.new(1, -24, 1, 0), 14, currencyColor)
	priceLabel.TextXAlignment = Enum.TextXAlignment.Right

	local currencyIconFrame = Icons.draw(priceFrame, currencyIcon, 16, {currencyColor})
	currencyIconFrame.Position = UDim2.new(1, -20, 0.5, -8)
	currencyIconFrame.AnchorPoint = Vector2.new(0, 0.5)
	currencyIconFrame.Size = UDim2.fromOffset(18, 18)

	-- Balance check
	local balance = item.currency == "gold" and playerData.gold or item.currency == "gems" and playerData.gems or playerData.seals
	local balanceLabel = label(modal, "Seu saldo: " .. balance, UDim2.fromOffset(16, 148), UDim2.new(1, -32, 0, 18), 12, balance >= item.price and Theme.Mint or Theme.Tokens.Ramps.Fogo[4]).TextXAlignment = Enum.TextXAlignment.Center

	-- Buttons
	local btnFrame = Instance.new("Frame")
	btnFrame.Size = UDim2.new(1, -24, 0, 40)
	btnFrame.Position = UDim2.fromOffset(12, 170)
	btnFrame.BackgroundTransparency = 1
	btnFrame.ZIndex = 102
	btnFrame.Parent = modal

	local btnLayout = Instance.new("UIListLayout")
	btnLayout.FillDirection = Enum.FillDirection.Horizontal
	btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	btnLayout.Padding = UDim.new(0, 12)
	btnLayout.Parent = btnFrame

	local cancelBtn = Instance.new("TextButton")
	cancelBtn.Size = UDim2.fromOffset(100, 40)
	cancelBtn.Text = "CANCELAR"
	cancelBtn.TextSize = 13
	cancelBtn.Font = Theme.Font
	cancelBtn.TextColor3 = Theme.Ink
	cancelBtn.BackgroundColor3 = Theme.Card
	cancelBtn.Parent = btnFrame
	Theme.panel(cancelBtn)
	Theme.bind(cancelBtn)
	cancelBtn.Activated:Connect(function()
		TweenService:Create(modal, TWEEN_FAST, {Size = UDim2.fromOffset(0, 0)}):Play()
		task.delay(0.15, function()
			overlay:Destroy()
		end)
		onCancel()
	end)

	local confirmBtn = Instance.new("TextButton")
	confirmBtn.Size = UDim2.fromOffset(100, 40)
	confirmBtn.Text = "COMPRAR"
	confirmBtn.TextSize = 13
	confirmBtn.Font = Theme.Font
	confirmBtn.TextColor3 = Theme.Panel
	confirmBtn.BackgroundColor3 = balance >= item.price and Theme.Accent or Theme.Muted
	confirmBtn.Active = balance >= item.price
	confirmBtn.Selectable = balance >= item.price
	confirmBtn.Parent = btnFrame
	Theme.panel(confirmBtn)
	Theme.bind(confirmBtn)
	confirmBtn.Activated:Connect(function()
		if balance >= item.price then
			TweenService:Create(modal, TWEEN_FAST, {Size = UDim2.fromOffset(0, 0)}):Play()
			task.delay(0.15, function()
				overlay:Destroy()
			end)
			onConfirm()
		end
	end)
end

return S