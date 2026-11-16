--!strict
-- UITheme.luau - Pixel grid system, Arcade font, ArtTokens colors
-- Cassette Beasts pixel UI: 4px grid, 2px borders, selective outlining
-- Centralized theme system for consistent UI across all screens

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Tokens = require(ReplicatedStorage.Shared.ArtTokens)

local T = {}

-- Export tokens for convenience
T.Ink = Tokens.Ink
T.Muted = Tokens.Muted
T.Panel = Tokens.Panel
T.Card = Tokens.Card
T.Accent = Tokens.Accent
T.Mint = Tokens.Mint
T.Edge = Tokens.Edge
T.Shadow = Tokens.Shadow
T.Font = Tokens.Font
T.Tokens = Tokens

-- Grid system constants
T.BaseGrid = Tokens.BaseGrid -- 4px
T.IconGrid = Tokens.IconGrid -- 16px
T.Border = Tokens.Border -- 2px
T.Touch = Tokens.Touch -- 44px minimum touch target
T.Spacing = Tokens.Spacing

-- Animation constants
T.Tween = {
	Fast = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Med = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
	Slow = TweenInfo.new(0.25, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
	Spring = TweenInfo.new(0.35, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
}

-- Z-index layers
T.Layers = {
	Background = 1,
	Content = 10,
	Overlay = 50,
	Modal = 100,
	Tooltip = 200,
	Notification = 300,
}

-- Apply pixel-perfect corner (2px radius)
function T.round(o: GuiObject, radius: number?): UICorner
	local existing = o:FindFirstChild("PixelCorner")
	if existing then
		return existing :: UICorner
	end
	local corner = Instance.new("UICorner")
	corner.Name = "PixelCorner"
	corner.CornerRadius = UDim.new(0, radius or 2)
	corner.Parent = o
	o.BorderSizePixel = 0
	return corner
end

-- Apply pixel border (2px stroke)
function T.stroke(o: GuiObject, color: Color3?, thickness: number?): UIStroke
	local existing = o:FindFirstChild("PixelEdge")
	if existing then
		if color then (existing :: UIStroke).Color = color end
		if thickness then (existing :: UIStroke).Thickness = thickness end
		return existing :: UIStroke
	end
	local stroke = Instance.new("UIStroke")
	stroke.Name = "PixelEdge"
	stroke.Color = color or T.Edge
	stroke.Transparency = 0
	stroke.Thickness = thickness or Tokens.Border
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = o
	return stroke
end

-- Apply panel styling (rounded + bordered)
function T.panel(o: GuiObject, accent: Color3?): GuiObject
	T.round(o)
	local stroke = T.stroke(o)
	stroke.Color = accent or T.Edge
	return o
end

-- Apply card styling (elevated panel)
function T.card(o: GuiObject, elementColor: Color3?): GuiObject
	T.round(o)
	local stroke = T.stroke(o, elementColor or T.Edge)
	stroke.Thickness = 2
	-- Subtle shadow via background
	o.BackgroundColor3 = elementColor and elementColor:Lerp(T.Panel, 0.3) or T.Card
	return o
end

-- Bind button states (hover/pressed/disabled)
function T.bind(button: TextButton): ()
	if button:GetAttribute("ArtButton") then
		return
	end
	button:SetAttribute("ArtButton", true)
	button.AutoButtonColor = false
	button.Selectable = true
	button.Font = T.Font

	local edge = T.stroke(button)
	T.round(button)

	local normalBg = button.BackgroundColor3
	local normalText = button.TextColor3
	local hover = false
	local pressed = false
	local updating = false

	local function refresh()
		updating = true
		local disabled = not button.Active or not button.Selectable
		button.BackgroundColor3 = disabled and T.Panel
			or pressed and T.Edge
			or hover and Tokens.nearest(normalBg:Lerp(T.Mint, 0.3))
			or normalBg
		button.TextColor3 = disabled and T.Muted or pressed and T.Ink or normalText
		edge.Color = disabled and T.Card or pressed and T.Mint or hover and T.Accent or T.Edge
		updating = false
	end

	button.MouseEnter:Connect(function()
		hover = true
		refresh()
	end)
	button.MouseLeave:Connect(function()
		hover = false
		pressed = false
		refresh()
	end)
	button.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			pressed = true
			refresh()
		end
	end)
	button.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			pressed = false
			refresh()
		end
	end)
	button.SelectionGained:Connect(function()
		hover = true
		refresh()
	end)
	button.SelectionLost:Connect(function()
		hover = false
		pressed = false
		refresh()
	end)
	button:GetPropertyChangedSignal("Active"):Connect(refresh)
	button:GetPropertyChangedSignal("Selectable"):Connect(refresh)
	button:GetPropertyChangedSignal("BackgroundColor3"):Connect(function()
		if not updating then
			normalBg = button.BackgroundColor3
			refresh()
		end
	end)
	refresh()
end

-- Create styled label
function T.label(parent: Instance, text: string, size: number?): TextLabel
	local l = Instance.new("TextLabel")
	l.BackgroundTransparency = 1
	l.Text = text
	l.TextColor3 = T.Ink
	l.TextSize = size or 16
	l.TextWrapped = true
	l.Font = T.Font
	l.Parent = parent
	return l
end

-- Create styled button
function T.button(parent: Instance, text: string, callback: () -> ()): TextButton
	local b = Instance.new("TextButton")
	b.Text = text
	b.Font = T.Font
	b.TextSize = 16
	b.TextWrapped = true
	b.Size = UDim2.fromOffset(160, 44)
	b.BackgroundColor3 = T.Card
	b.TextColor3 = T.Ink
	b.Active = true
	b.Selectable = true
	b.Parent = parent
	T.bind(b)
	b.Activated:Connect(callback)
	return b
end

-- Create icon button (icon + text)
function T.iconButton(parent: Instance, iconName: string, text: string, callback: () -> (), iconColor: Color3?): TextButton
	local Icons = require(script.Parent.PixelIcons)

	local b = Instance.new("TextButton")
	b.Text = ""
	b.Size = UDim2.fromOffset(160, 44)
	b.BackgroundColor3 = T.Card
	b.Active = true
	b.Selectable = true
	b.Parent = parent
	T.panel(b)
	T.bind(b)

	local icon = Icons.draw(b, iconName, 20, iconColor or T.Tokens.Ramps.Sand)
	icon.Position = UDim2.fromOffset(12, 12)
	icon.Size = UDim2.fromOffset(20, 20)

	local txt = Instance.new("TextLabel")
	txt.BackgroundTransparency = 1
	txt.Position = UDim2.fromOffset(40, 0)
	txt.Size = UDim2.new(1, -48, 1, 0)
	txt.Text = text
	txt.TextSize = 14
	txt.Font = T.Font
	txt.TextColor3 = T.Ink
	txt.TextXAlignment = Enum.TextXAlignment.Left
	txt.Parent = b

	b.Activated:Connect(callback)
	return b
end

-- Create input field
function T.input(parent: Instance, placeholder: string, onChanged: (string) -> ()): TextBox
	local box = Instance.new("TextBox")
	box.PlaceholderText = placeholder
	box.Text = ""
	box.TextSize = 16
	box.Font = T.Font
	box.ClearTextOnFocus = false
	box.Size = UDim2.new(1, -16, 0, 44)
	box.BackgroundColor3 = T.Card
	box.TextColor3 = T.Ink
	box.PlaceholderColor3 = T.Muted
	box.Parent = parent
	T.round(box)
	T.stroke(box)
	box.FocusLost:Connect(function()
		onChanged(box.Text)
	end)
	return box
end

-- Create slider (0-1 range)
function T.slider(parent: Instance, label: string, initial: number, onChanged: (number) -> ()): Frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -16, 0, 56)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.fromOffset(0, 0)
	lbl.Size = UDim2.new(1, -50, 0, 22)
	lbl.Text = label
	lbl.TextSize = 14
	lbl.Font = T.Font
	lbl.TextColor3 = T.Ink
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = frame

	local val = Instance.new("TextLabel")
	val.BackgroundTransparency = 1
	val.Position = UDim2.new(1, -50, 0, 0)
	val.Size = UDim2.fromOffset(50, 22)
	val.Text = string.format("%.0f%%", initial * 100)
	val.TextSize = 12
	val.Font = T.Font
	val.TextColor3 = T.Accent
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Parent = frame

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, 0, 0, 8)
	track.Position = UDim2.fromOffset(0, 32)
	track.BackgroundColor3 = T.Panel
	track.Parent = frame
	T.round(track)
	T.stroke(track)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(initial, 1)
	fill.BackgroundColor3 = T.Accent
	fill.Parent = track
	T.round(fill)

	local thumb = Instance.new("Frame")
	thumb.Size = UDim2.fromOffset(16, 16)
	thumb.Position = UDim2.fromScale(initial, 0.5)
	thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	thumb.BackgroundColor3 = T.Ink
	thumb.Parent = track
	T.round(thumb)
	T.stroke(thumb)

	local dragging = false
	local function updateFromInput(inputPos: number)
		local rel = math.clamp((inputPos - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		fill.Size = UDim2.fromScale(rel, 1)
		thumb.Position = UDim2.fromScale(rel, 0.5)
		val.Text = string.format("%.0f%%", rel * 100)
		onChanged(rel)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateFromInput(input.Position.X)
		end
	end)

	game:GetService("UserInputService").InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromInput(input.Position.X)
		end
	end)

	game:GetService("UserInputService").InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return frame
end

-- Create dropdown
function T.dropdown(parent: Instance, label: string, options: {string}, initial: string, onChanged: (string) -> ()): Frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -16, 0, 56)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.fromOffset(0, 0)
	lbl.Size = UDim2.new(1, -160, 0, 22)
	lbl.Text = label
	lbl.TextSize = 14
	lbl.Font = T.Font
	lbl.TextColor3 = T.Ink
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = frame

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(150, 32)
	btn.Position = UDim2.new(1, -150, 0, 4)
	btn.Text = initial
	btn.TextSize = 12
	btn.Font = T.Font
	btn.TextColor3 = T.Ink
	btn.BackgroundColor3 = T.Card
	btn.Parent = frame
	T.panel(btn)
	T.bind(btn)

	local open = false
	local dropdown = Instance.new("Frame")
	dropdown.Size = UDim2.fromOffset(150, #options * 32)
	dropdown.Position = UDim2.fromOffset(0, 36)
	dropdown.BackgroundColor3 = T.Panel
	dropdown.Visible = false
	dropdown.ZIndex = 10
	dropdown.Parent = btn
	T.panel(dropdown, T.Accent)

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 2)
	layout.Parent = dropdown

	for _, opt in options do
		local optBtn = Instance.new("TextButton")
		optBtn.Size = UDim2.new(1, 0, 0, 30)
		optBtn.Text = opt
		optBtn.TextSize = 12
		optBtn.Font = T.Font
		optBtn.TextColor3 = T.Ink
		optBtn.BackgroundColor3 = opt == initial and T.Accent or T.Card
		optBtn.Parent = dropdown
		T.bind(optBtn)
		optBtn.Activated:Connect(function()
			btn.Text = opt
			dropdown.Visible = false
			open = false
			onChanged(opt)
		end)
	end

	btn.Activated:Connect(function()
		open = not open
		dropdown.Visible = open
	end)

	return frame
end

-- Create toggle switch
function T.toggle(parent: Instance, label: string, description: string, initial: boolean, onChanged: (boolean) -> ()): Frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -16, 0, 56)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.fromOffset(0, 0)
	lbl.Size = UDim2.new(1, -60, 0, 22)
	lbl.Text = label
	lbl.TextSize = 14
	lbl.Font = T.Font
	lbl.TextColor3 = T.Ink
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = frame

	local desc = Instance.new("TextLabel")
	desc.BackgroundTransparency = 1
	desc.Position = UDim2.fromOffset(0, 22)
	desc.Size = UDim2.new(1, -60, 0, 18)
	desc.Text = description
	desc.TextSize = 11
	desc.Font = T.Font
	desc.TextColor3 = T.Muted
	desc.TextXAlignment = Enum.TextXAlignment.Left
	desc.Parent = frame

	local track = Instance.new("Frame")
	track.Size = UDim2.fromOffset(48, 24)
	track.Position = UDim2.new(1, -48, 0, 4)
	track.BackgroundColor3 = initial and T.Accent or T.Muted
	track.Parent = frame
	T.round(track)

	local thumb = Instance.new("Frame")
	thumb.Size = UDim2.fromOffset(20, 20)
	thumb.Position = initial and UDim2.fromOffset(28, 2) or UDim2.fromOffset(2, 2)
	thumb.BackgroundColor3 = T.Panel
	thumb.Parent = track
	T.round(thumb)
	T.stroke(thumb)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromScale(1, 1)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = track

	local value = initial
	btn.Activated:Connect(function()
		value = not value
		onChanged(value)
		game:GetService("TweenService"):Create(track, T.Tween.Fast, {BackgroundColor3 = value and T.Accent or T.Muted}):Play()
		game:GetService("TweenService"):Create(thumb, T.Tween.Fast, {Position = value and UDim2.fromOffset(28, 2) or UDim2.fromOffset(2, 2)}):Play()
	end)

	return frame
end

-- Create section header with divider
function T.section(parent: Instance, title: string, iconName: string?): Frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -8, 0, 40)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	if iconName then
		local Icons = require(script.Parent.PixelIcons)
		local icon = Icons.draw(frame, iconName, 20, T.Tokens.Ramps.Sand)
		icon.Position = UDim2.fromOffset(4, 10)
	end

	local offset = iconName and 32 or 4
	T.label(frame, title, UDim2.fromOffset(offset, 4), UDim2.new(1, -offset - 4, 1, 0), 16).TextColor3 = T.Accent

	local div = Instance.new("Frame")
	div.Size = UDim2.new(1, 0, 0, 2)
	div.Position = UDim2.fromOffset(0, 38)
	div.BackgroundColor3 = T.Edge
	div.BackgroundTransparency = 0.5
	div.BorderSizePixel = 0
	div.Parent = frame

	return frame
end

-- Show toast notification
function T.toast(parent: Instance, message: string, duration: number?, color: Color3?): ()
	local toast = Instance.new("Frame")
	toast.Size = UDim2.new(0, 0, 0, 48)
	toast.Position = UDim2.new(0.5, 0, 1, -60)
	toast.AnchorPoint = Vector2.new(0.5, 1)
	toast.BackgroundColor3 = color or T.Panel
	toast.ZIndex = T.Layers.Notification
	toast.Parent = parent
	T.panel(toast, color or T.Accent)

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Size = UDim2.new(1, -24, 1, 0)
	lbl.Position = UDim2.fromOffset(12, 0)
	lbl.Text = message
	lbl.TextSize = 14
	lbl.Font = T.Font
	lbl.TextColor3 = T.Ink
	lbl.TextWrapped = true
	lbl.Parent = toast

	local TweenService = game:GetService("TweenService")
	TweenService:Create(toast, T.Tween.Med, {Size = UDim2.new(0, math.min(360, #message * 8 + 40), 0, 48)}):Play()

	task.delay(duration or 3, function()
		if toast.Parent then
			TweenService:Create(toast, T.Tween.Fast, {Size = UDim2.new(0, 0, 0, 48)}):Play()
			task.delay(0.15, function()
				toast:Destroy()
			end)
		end
	end)
end

-- Create modal dialog
function T.modal(parent: Instance, title: string, content: string, buttons: {{text: string, callback: () -> (), primary: boolean?}}): Frame
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = T.Shadow
	overlay.BackgroundTransparency = 0.4
	overlay.ZIndex = T.Layers.Modal
	overlay.Parent = parent

	local modal = Instance.new("Frame")
	modal.Size = UDim2.fromOffset(0, 0)
	modal.Position = UDim2.fromScale(0.5, 0.5)
	modal.AnchorPoint = Vector2.new(0.5, 0.5)
	modal.BackgroundColor3 = T.Panel
	modal.ZIndex = T.Layers.Modal + 1
	modal.Parent = overlay
	T.panel(modal, T.Accent)

	-- Animate in
	game:GetService("TweenService"):Create(modal, T.Tween.Med, {Size = UDim2.fromOffset(320, 200)}):Play()

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 12)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Parent = modal

	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, 20)
	padding.PaddingBottom = UDim.new(0, 20)
	padding.PaddingLeft = UDim.new(0, 20)
	padding.PaddingRight = UDim.new(0, 20)
	padding.Parent = modal

	local titleLabel = T.label(modal, title, UDim2.new(), UDim2.new(1, 0, 0, 28), 18)
	titleLabel.TextColor3 = T.Accent
	titleLabel.TextXAlignment = Enum.TextXAlignment.Center
	titleLabel.LayoutOrder = 1

	local contentLabel = T.label(modal, content, UDim2.new(), UDim2.new(1, 0, 0, 60), 14)
	contentLabel.TextColor3 = T.Muted
	contentLabel.TextXAlignment = Enum.TextXAlignment.Center
	contentLabel.LayoutOrder = 2

	local btnFrame = Instance.new("Frame")
	btnFrame.Size = UDim2.new(1, 0, 0, 40)
	btnFrame.BackgroundTransparency = 1
	btnFrame.LayoutOrder = 3
	btnFrame.Parent = modal

	local btnLayout = Instance.new("UIListLayout")
	btnLayout.FillDirection = Enum.FillDirection.Horizontal
	btnLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	btnLayout.Padding = UDim.new(0, 8)
	btnLayout.Parent = btnFrame

	for _, btnData in buttons do
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromOffset(100, 40)
		btn.Text = btnData.text
		btn.TextSize = 13
		btn.Font = T.Font
		btn.TextColor3 = btnData.primary and T.Panel or T.Ink
		btn.BackgroundColor3 = btnData.primary and T.Accent or T.Card
		btn.Parent = btnFrame
		T.panel(btn)
		T.bind(btn)
		btn.Activated:Connect(function()
			game:GetService("TweenService"):Create(modal, T.Tween.Fast, {Size = UDim2.fromOffset(0, 0)}):Play()
			task.delay(0.15, function()
				overlay:Destroy()
			end)
			if btnData.callback then btnData.callback() end
		end)
	end

	return overlay
end

-- Create progress bar
function T.progressBar(parent: Instance, progress: number, color: Color3?, height: number?): Frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -16, 0, height or 8)
	frame.BackgroundColor3 = T.Panel
	frame.Parent = parent
	T.round(frame)
	T.stroke(frame)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(math.clamp(progress, 0, 1), 1)
	fill.BackgroundColor3 = color or T.Accent
	fill.Parent = frame
	T.round(fill)

	return frame
end

-- Create stat bar (label + value + bar)
function T.statBar(parent: Instance, label: string, current: number, max: number, color: Color3?): Frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -16, 0, 32)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local lbl = Instance.new("TextLabel")
	lbl.BackgroundTransparency = 1
	lbl.Position = UDim2.fromOffset(0, 0)
	lbl.Size = UDim2.new(0.3, 0, 1, 0)
	lbl.Text = label
	lbl.TextSize = 12
	lbl.Font = T.Font
	lbl.TextColor3 = T.Muted
	lbl.TextXAlignment = Enum.TextXAlignment.Left
	lbl.Parent = frame

	local val = Instance.new("TextLabel")
	val.BackgroundTransparency = 1
	val.Position = UDim2.new(0.3, 0, 0, 0)
	val.Size = UDim2.new(0.2, 0, 1, 0)
	val.Text = current .. "/" .. max
	val.TextSize = 12
	val.Font = T.Font
	val.TextColor3 = T.Ink
	val.TextXAlignment = Enum.TextXAlignment.Right
	val.Parent = frame

	local bar = Instance.new("Frame")
	bar.Size = UDim2.new(0.45, 0, 0, 6)
	bar.Position = UDim2.new(0.55, 0, 0.5, -3)
	bar.BackgroundColor3 = T.Panel
	bar.Parent = frame
	T.round(bar)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(math.clamp(current / max, 0, 1), 1)
	fill.BackgroundColor3 = color or T.Accent
	fill.Parent = bar
	T.round(fill)

	return frame
end

-- Create creature card (compact)
function T.creatureCard(parent: Instance, def: {id: string, name: string, el: string, rar: number, lv: number}, onClick: (() -> ())?): Frame
	local card = Instance.new("Frame")
	card.Size = UDim2.fromOffset(140, 160)
	card.BackgroundColor3 = T.Tokens.Elements[def.el][1]
	card.Parent = parent
	T.panel(card, T.Tokens.Elements[def.el][4])

	-- Element icon
	local Icons = require(script.Parent.PixelIcons)
	local icon = Icons.draw(card, def.el, 16, T.Tokens.Elements[def.el])
	icon.Position = UDim2.fromOffset(8, 8)

	-- Rarity indicator
	local rarityColors = {[1] = T.Tokens.Ramps.Metal[3], [2] = T.Tokens.Ramps.Cristal[3], [3] = T.Tokens.Ramps.Luz[3], [4] = T.Tokens.Ramps.Fogo[3]}
	local rarityDot = Instance.new("Frame")
	rarityDot.Size = UDim2.fromOffset(8, 8)
	rarityDot.Position = UDim2.new(1, -16, 0, 8)
	rarityDot.BackgroundColor3 = rarityColors[def.rar] or T.Muted
	rarityDot.Parent = card
	T.round(rarityDot)

	-- Preview area
	local previewHolder = Instance.new("Frame")
	previewHolder.Size = UDim2.new(1, -16, 0, 80)
	previewHolder.Position = UDim2.fromOffset(8, 32)
	previewHolder.BackgroundTransparency = 1
	previewHolder.Parent = card

	-- Use CollectionUI preview
	local Preview = require(script.Parent.CollectionUI)
	Preview.preview(previewHolder, def, def.lv, false)

	-- Name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(8, 116)
	nameLabel.Size = UDim2.new(1, -16, 0, 20)
	nameLabel.Text = def.name
	nameLabel.TextSize = 13
	nameLabel.Font = T.Font
	nameLabel.TextColor3 = T.Ink
	nameLabel.TextXAlignment = Enum.TextXAlignment.Center
	nameLabel.TextWrapped = true
	nameLabel.Parent = card

	-- Level
	Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(8, 136)
	nameLabel.Size = UDim2.new(1, -16, 0, 18)
	nameLabel.Text = "Lv." .. def.lv .. " • " .. def.el
	nameLabel.TextSize = 11
	nameLabel.Font = T.Font
	nameLabel.TextColor3 = T.Muted
	nameLabel.TextXAlignment = Enum.TextXAlignment.Center
	nameLabel.Parent = card

	if onClick then
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromScale(1, 1)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.Parent = card
		T.bind(btn)
		btn.Activated:Connect(onClick)
	end

	return card
end

-- Create move card for battle UI
function T.moveCard(parent: Instance, move: {id: string, name: string, element: string, category: string, power: number, accuracy: number, pp: number}, onClick: (() -> ())?): Frame
	local card = Instance.new("Frame")
	card.Size = UDim2.fromOffset(160, 60)
	card.BackgroundColor3 = T.Tokens.Elements[move.element][1]
	card.Parent = parent
	T.panel(card, T.Tokens.Elements[move.element][4])

	-- Category icon
	local Icons = require(script.Parent.PixelIcons)
	local catIcon = move.category == "physical" and "strike" or move.category == "special" and "skill" or "guard"
	Icons.draw(card, catIcon, 14, T.Tokens.Elements[move.element]).Position = UDim2.fromOffset(8, 8)

	-- Move name
	Instance.new("TextLabel")
	nameLabel.BackgroundTransparency = 1
	nameLabel.Position = UDim2.fromOffset(28, 4)
	nameLabel.Size = UDim2.new(1, -36, 0, 20)
	nameLabel.Text = move.name
	nameLabel.TextSize = 13
	nameLabel.Font = T.Font
	nameLabel.TextColor3 = T.Ink
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = card

	-- Power/Accuracy
	local paText = move.power > 0 and (move.power .. " ⬥ " .. math.floor(move.accuracy * 100) .. "%") or "Status"
	Instance.new("TextLabel")
	paLabel.BackgroundTransparency = 1
	paLabel.Position = UDim2.fromOffset(28, 24)
	paLabel.Size = UDim2.new(1, -36, 0, 16)
	paLabel.Text = paText
	paLabel.TextSize = 11
	paLabel.Font = T.Font
	paLabel.TextColor3 = T.Muted
	paLabel.TextXAlignment = Enum.TextXAlignment.Left
	paLabel.Parent = card

	-- PP
	Instance.new("TextLabel")
	ppLabel.BackgroundTransparency = 1
	ppLabel.Position = UDim2.new(1, -50, 0, 4)
	ppLabel.Size = UDim2.fromOffset(44, 16)
	ppLabel.Text = "PP " .. move.pp
	ppLabel.TextSize = 11
	ppLabel.Font = T.Font
	ppLabel.TextColor3 = T.Accent
	ppLabel.TextXAlignment = Enum.TextXAlignment.Right
	ppLabel.Parent = card

	-- Element badge
	local badge = Instance.new("Frame")
	badge.Size = UDim2.fromOffset(40, 16)
	badge.Position = UDim2.new(1, -48, 1, -20)
	badge.BackgroundColor3 = T.Tokens.Elements[move.element][3]
	badge.Parent = card
	T.round(badge)

	Instance.new("TextLabel")
	badgeLabel.BackgroundTransparency = 1
	badgeLabel.Size = UDim2.fromScale(1, 1)
	badgeLabel.Text = move.element
	badgeLabel.TextSize = 9
	badgeLabel.Font = T.Font
	badgeLabel.TextColor3 = T.Panel
	badgeLabel.TextXAlignment = Enum.TextXAlignment.Center
	badgeLabel.Parent = badge

	if onClick then
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.fromScale(1, 1)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.Parent = card
		T.bind(btn)
		btn.Activated:Connect(onClick)
	end

	return card
end

-- Create HP bar for battle
function T.hpBar(parent: Instance, current: number, max: number, showText: boolean?): Frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 0, 12)
	frame.BackgroundColor3 = T.Panel
	frame.Parent = parent
	T.round(frame)
	T.stroke(frame)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale(math.clamp(current / max, 0, 1), 1)
	fill.BackgroundColor3 = current / max > 0.5 and T.Mint or (current / max > 0.2 and T.Tokens.Ramps.Luz[3] or T.Tokens.Ramps.Fogo[3])
	fill.Parent = frame
	T.round(fill)

	if showText then
		local text = Instance.new("TextLabel")
		text.BackgroundTransparency = 1
		text.Size = UDim2.fromScale(1, 1)
		text.Text = current .. "/" .. max
		text.TextSize = 10
		text.Font = T.Font
		text.TextColor3 = T.Ink
		text.TextXAlignment = Enum.TextXAlignment.Center
		text.Parent = frame
	end

	return frame
end

-- Create XP bar
function T.xpBar(parent: Instance, current: number, max: number): Frame
	return T.progressBar(parent, current / max, T.Tokens.Ramps.Luz[3], 6)
end

-- Create grid layout helper
function T.createGrid(parent: Instance, columns: number, cellSize: UDim2, padding: UDim2?): UIGridLayout
	local layout = Instance.new("UIGridLayout")
	layout.CellSize = cellSize
	layout.CellPadding = padding or UDim2.fromOffset(8, 8)
	layout.FillDirectionMaxCells = columns
	layout.StartCorner = Enum.StartCorner.TopLeft
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Top
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = parent
	return layout
end

-- Create list layout helper
function T.createList(parent: Instance, padding: UDim?): UIListLayout
	local layout = Instance.new("UIListLayout")
	layout.Padding = padding or UDim.new(0, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.Parent = parent
	return layout
end

-- Responsive grid sizing
function T.responsiveGrid(parent: Instance, minCellWidth: number, maxColumns: number): UIGridLayout
	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.fromOffset(minCellWidth, minCellWidth)
	layout.CellPadding = UDim2.fromOffset(8, 8)
	layout.FillDirectionMaxCells = maxColumns
	layout.StartCorner = Enum.StartCorner.TopLeft
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = parent

	-- Update on resize
	parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(function()
		local width = parent.AbsoluteSize.X
		local cols = math.clamp(math.floor((width + 8) / (minCellWidth + 8)), 1, maxColumns)
		layout.FillDirectionMaxCells = cols
	end)

	return layout
end

-- Safe area padding for mobile
function T.safeAreaPadding(): UIPadding
	local padding = Instance.new("UIPadding")
	padding.PaddingTop = UDim.new(0, T.Spacing.md)
	padding.PaddingBottom = UDim.new(0, T.Spacing.md)
	padding.PaddingLeft = UDim.new(0, T.Spacing.md)
	padding.PaddingRight = UDim.new(0, T.Spacing.md)
	return padding
end

-- Scale UI for different screen sizes
function T.applyScale(gui: ScreenGui, scale: number)
	gui.Scale = scale
end

return T