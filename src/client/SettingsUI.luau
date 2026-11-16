--!strict
-- SettingsUI.luau - Graphics, controls, accessibility
-- Cassette Beasts pixel UI: 4px grid, 2px borders, selective outlining
-- 120-250ms transitions, easing, hover/pressed/disabled states
-- Mobile: responsive, touch targets ≥44px, portrait/landscape battle UI

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Lighting = game:GetService("Lighting")
local SoundService = game:GetService("SoundService")

local Text = require(ReplicatedStorage.Shared.Strings).Text
local Theme = require(script.Parent.UITheme)
local Icons = require(script.Parent.PixelIcons)

local S = {}
local TWEEN_FAST = TweenInfo.new(0.12, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
local TWEEN_MED = TweenInfo.new(0.2, Enum.EasingStyle.Back, Enum.EasingDirection.Out)

local LocalPlayer = Players.LocalPlayer

export type SettingsData = {
	graphics: "low" | "medium" | "high",
	motionReduced: boolean,
	soundEnabled: boolean,
	musicVolume: number,
	sfxVolume: number,
	uiScale: number,
	showDamageNumbers: boolean,
	showHPBars: boolean,
	autoBattle: boolean,
	battleSpeed: number,
	language: string,
	controlScheme: "touch" | "keyboard" | "gamepad",
	highContrast: boolean,
	dyslexicFont: boolean,
	screenShake: boolean,
	particleQuality: "low" | "medium" | "high",
}

local DEFAULT_SETTINGS: SettingsData = {
	graphics = "medium",
	motionReduced = false,
	soundEnabled = true,
	musicVolume = 0.5,
	sfxVolume = 0.7,
	uiScale = 1.0,
	showDamageNumbers = true,
	showHPBars = true,
	autoBattle = false,
	battleSpeed = 1.0,
	language = "pt-BR",
	controlScheme = "touch",
	highContrast = false,
	dyslexicFont = false,
	screenShake = true,
	particleQuality = "medium",
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

-- Create toggle switch
local function createToggle(parent: Instance, text: string, description: string, initialValue: boolean, onChange: (boolean) -> ()): Frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -16, 0, 56)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	label(frame, text, UDim2.fromOffset(0, 0), UDim2.new(1, -60, 0, 22), 14)
	label(frame, description, UDim2.fromOffset(0, 22), UDim2.new(1, -60, 0, 18), 11, Theme.Muted)

	-- Toggle track
	local track = Instance.new("Frame")
	track.Size = UDim2.fromOffset(48, 24)
	track.Position = UDim2.new(1, -48, 0, 4)
	track.BackgroundColor3 = initialValue and Theme.Accent or Theme.Muted
	track.Parent = frame
	Theme.round(track)

	-- Toggle thumb
	local thumb = Instance.new("Frame")
	thumb.Size = UDim2.fromOffset(20, 20)
	thumb.Position = initialValue and UDim2.fromOffset(28, 2) or UDim2.fromOffset(2, 2)
	thumb.BackgroundColor3 = Theme.Panel
	thumb.Parent = track
	Theme.round(thumb)
	Theme.stroke(thumb)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromScale(1, 1)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = track

	local value = initialValue
	btn.Activated:Connect(function()
		value = not value
		onChange(value)
		TweenService:Create(track, TWEEN_FAST, {BackgroundColor3 = value and Theme.Accent or Theme.Muted}):Play()
		TweenService:Create(thumb, TWEEN_FAST, {Position = value and UDim2.fromOffset(28, 2) or UDim2.fromOffset(2, 2)}):Play()
	end)

	return frame
end

-- Create slider
local function createSlider(parent: Instance, text: string, description: string, min: number, max: number, initialValue: number, onChange: (number) -> ()): Frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -16, 0, 70)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	label(frame, text, UDim2.fromOffset(0, 0), UDim2.new(1, -60, 0, 22), 14)
	label(frame, description, UDim2.fromOffset(0, 22), UDim2.new(1, -60, 0, 18), 11, Theme.Muted)

	local track = Instance.new("Frame")
	track.Size = UDim2.new(1, 0, 0, 8)
	track.Position = UDim2.fromOffset(0, 48)
	track.BackgroundColor3 = Theme.Panel
	track.Parent = frame
	Theme.round(track)
	Theme.stroke(track)

	local fill = Instance.new("Frame")
	fill.Size = UDim2.fromScale((initialValue - min) / (max - min), 1)
	fill.BackgroundColor3 = Theme.Accent
	fill.Parent = track
	Theme.round(fill)

	local thumb = Instance.new("Frame")
	thumb.Size = UDim2.fromOffset(16, 16)
	thumb.Position = UDim2.fromScale((initialValue - min) / (max - min), 0.5)
	thumb.AnchorPoint = Vector2.new(0.5, 0.5)
	thumb.BackgroundColor3 = Theme.Ink
	thumb.Parent = track
	Theme.round(thumb)
	Theme.stroke(thumb)

	local valueLabel = label(frame, string.format("%.1f", initialValue), UDim2.new(1, -50, 0, 0), UDim2.fromOffset(50, 22), 12, Theme.Accent)
	valueLabel.TextXAlignment = Enum.TextXAlignment.Right

	local dragging = false
	local function updateFromInput(inputPos: number)
		local rel = math.clamp((inputPos - track.AbsolutePosition.X) / track.AbsoluteSize.X, 0, 1)
		local value = min + rel * (max - min)
		value = math.floor(value * 10) / 10
		onChange(value)
		fill.Size = UDim2.fromScale(rel, 1)
		thumb.Position = UDim2.fromScale(rel, 0.5)
		valueLabel.Text = string.format("%.1f", value)
	end

	track.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			updateFromInput(input.Position.X)
		end
	end)

	UserInputService.InputChanged:Connect(function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			updateFromInput(input.Position.X)
		end
	end)

	UserInputService.InputEnded:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)

	return frame
end

-- Create dropdown
local function createDropdown(parent: Instance, text: string, description: string, options: {string}, initialValue: string, onChange: (string) -> ()): Frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -16, 0, 56)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	label(frame, text, UDim2.fromOffset(0, 0), UDim2.new(1, -160, 0, 22), 14)
	label(frame, description, UDim2.fromOffset(0, 22), UDim2.new(1, -160, 0, 18), 11, Theme.Muted)

	local btn = Instance.new("TextButton")
	btn.Size = UDim2.fromOffset(150, 32)
	btn.Position = UDim2.new(1, -150, 0, 4)
	btn.Text = initialValue
	btn.TextSize = 12
	btn.Font = Theme.Font
	btn.TextColor3 = Theme.Ink
	btn.BackgroundColor3 = Theme.Card
	btn.Parent = frame
	Theme.panel(btn)
	Theme.bind(btn)

	local open = false
	local dropdown = Instance.new("Frame")
	dropdown.Size = UDim2.fromOffset(150, #options * 32)
	dropdown.Position = UDim2.fromOffset(0, 36)
	dropdown.BackgroundColor3 = Theme.Panel
	dropdown.Visible = false
	dropdown.ZIndex = 10
	dropdown.Parent = btn
	Theme.panel(dropdown, Theme.Accent)

	local dropLayout = Instance.new("UIListLayout")
	dropLayout.Padding = UDim.new(0, 2)
	dropLayout.Parent = dropdown

	for _, opt in options do
		local optBtn = Instance.new("TextButton")
		optBtn.Size = UDim2.new(1, 0, 0, 30)
		optBtn.Text = opt
		optBtn.TextSize = 12
		optBtn.Font = Theme.Font
		optBtn.TextColor3 = Theme.Ink
		optBtn.BackgroundColor3 = opt == initialValue and Theme.Accent or Theme.Card
		optBtn.Parent = dropdown
		Theme.bind(optBtn)
		optBtn.Activated:Connect(function()
			btn.Text = opt
			dropdown.Visible = false
			open = false
			onChange(opt)
		end)
	end

	btn.Activated:Connect(function()
		open = not open
		dropdown.Visible = open
	end)

	return frame
end

-- Create section header
local function createSection(parent: Instance, title: string, iconName: string): Frame
	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, -8, 0, 40)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local icon = Icons.draw(frame, iconName, 20, Theme.Tokens.Ramps.Sand)
	icon.Position = UDim2.fromOffset(4, 10)

	label(frame, title, UDim2.fromOffset(32, 4), UDim2.new(1, -40, 1, 0), 16, Theme.Accent)

	-- Divider
	local div = Instance.new("Frame")
	div.Size = UDim2.new(1, 0, 0, 2)
	div.Position = UDim2.fromOffset(0, 38)
	div.BackgroundColor3 = Theme.Edge
	div.BackgroundTransparency = 0.5
	div.BorderSizePixel = 0
	div.Parent = frame

	return frame
end

-- Main Settings UI
function S.render(parent: ScrollingFrame, settings: SettingsData, onChange: (string, any) -> ())
	parent:ClearAllChildren()

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 8)
	listLayout.Parent = parent

	-- Header
	local header = panel(parent, 50)
	header.LayoutOrder = 1
	header.BackgroundTransparency = 1

	label(header, "⚙ CONFIGURAÇÕES", UDim2.fromOffset(12, 0), UDim2.new(1, -24, 1, 0), 18, Theme.Accent)

	-- GRAPHICS SECTION
	createSection(parent, "GRÁFICOS", "Home")

	local graphicsFrame = panel(parent, 0)
	graphicsFrame.AutomaticSize = Enum.AutomaticSize.Y
	graphicsFrame.BackgroundTransparency = 1

	local gLayout = Instance.new("UIListLayout")
	gLayout.Padding = UDim.new(0, 8)
	gLayout.Parent = graphicsFrame

	-- Graphics Quality
	createDropdown(graphicsFrame, "Qualidade Gráfica", "Ajusta detalhes visuais e performance", {"Baixo", "Médio", "Alto"},
		settings.graphics:sub(1,1):upper() .. settings.graphics:sub(2),
		function(v) onChange("graphics", v:lower()) end)

	-- Particle Quality
	createDropdown(graphicsFrame, "Qualidade de Partículas", "Efeitos visuais de habilidades e ambiente", {"Baixo", "Médio", "Alto"},
		settings.particleQuality:sub(1,1):upper() .. settings.particleQuality:sub(2),
		function(v) onChange("particleQuality", v:lower()) end)

	-- UI Scale
	createSlider(graphicsFrame, "Escala da Interface", "Tamanho dos elementos da UI", 0.8, 1.5, settings.uiScale,
		function(v) onChange("uiScale", v) end)

	-- Screen Shake
	createToggle(graphicsFrame, "Tremor de Tela", "Efeito de tremor em golpes fortes", settings.screenShake,
		function(v) onChange("screenShake", v) end)

	-- ACCESSIBILITY SECTION
	createSection(parent, "ACESSIBILIDADE", "Heart")

	local accessFrame = panel(parent, 0)
	accessFrame.AutomaticSize = Enum.AutomaticSize.Y
	accessFrame.BackgroundTransparency = 1

	local aLayout = Instance.new("UIListLayout")
	aLayout.Padding = UDim.new(0, 8)
	aLayout.Parent = accessFrame

	-- Reduced Motion
	createToggle(accessFrame, "Movimento Reduzido", "Desativa animações e transições", settings.motionReduced,
		function(v)
			onChange("motionReduced", v)
			LocalPlayer:SetAttribute("MotionReduced", v)
		end)

	-- High Contrast
	createToggle(accessFrame, "Alto Contraste", "Aumenta contraste para melhor legibilidade", settings.highContrast,
		function(v)
			onChange("highContrast", v)
			-- Apply high contrast theme
			if v then
				Theme.Ink = Color3.fromRGB(255, 255, 255)
				Theme.Panel = Color3.fromRGB(0, 0, 0)
				Theme.Card = Color3.fromRGB(30, 30, 30)
			else
				-- Reset to defaults
				Theme.Ink = Color3.fromRGB(255, 240, 207)
				Theme.Panel = Color3.fromRGB(25, 43, 54)
				Theme.Card = Color3.fromRGB(40, 60, 70)
			end
		end)

	-- Dyslexic Font
	createToggle(accessFrame, "Fonte Disléxica", "Usa fonte mais legível (OpenDyslexic)", settings.dyslexicFont,
		function(v)
			onChange("dyslexicFont", v)
			if v then
				Theme.Font = Enum.Font.Gotham -- Would need actual dyslexic font
			else
				Theme.Font = Enum.Font.Arcade
			end
		end)

	-- Show Damage Numbers
	createToggle(accessFrame, "Números de Dano", "Exibe dano causado/recebido", settings.showDamageNumbers,
		function(v) onChange("showDamageNumbers", v) end)

	-- Show HP Bars
	createToggle(accessFrame, "Barras de HP", "Mostra HP das feras em batalha", settings.showHPBars,
		function(v) onChange("showHPBars", v) end)

	-- AUDIO SECTION
	createSection(parent, "ÁUDIO", "Sound")

	local audioFrame = panel(parent, 0)
	audioFrame.AutomaticSize = Enum.AutomaticSize.Y
	audioFrame.BackgroundTransparency = 1

	local auLayout = Instance.new("UIListLayout")
	auLayout.Padding = UDim.new(0, 8)
	auLayout.Parent = audioFrame

	-- Master Sound
	createToggle(audioFrame, "Som Ativado", "Liga/desliga todos os sons", settings.soundEnabled,
		function(v)
			onChange("soundEnabled", v)
			SoundService.Volume = v and 1 or 0
		end)

	-- Music Volume
	createSlider(audioFrame, "Volume da Música", "Volume da trilha sonora", 0, 1, settings.musicVolume,
		function(v)
			onChange("musicVolume", v)
			-- Apply to music
		end)

	-- SFX Volume
	createSlider(audioFrame, "Volume de Efeitos", "Volume de sons de batalha/UI", 0, 1, settings.sfxVolume,
		function(v)
			onChange("sfxVolume", v)
			-- Apply to SFX
		end)

	-- GAMEPLAY SECTION
	createSection(parent, "JOGABILIDADE", "Fera")

	local gameplayFrame = panel(parent, 0)
	gameplayFrame.AutomaticSize = Enum.AutomaticSize.Y
	gameplayFrame.BackgroundTransparency = 1

	local gpLayout = Instance.new("UIListLayout")
	gpLayout.Padding = UDim.new(0, 8)
	gpLayout.Parent = gameplayFrame

	-- Auto Battle
	createToggle(gameplayFrame, "Auto-Batalha", "IA controla suas feras automaticamente", settings.autoBattle,
		function(v) onChange("autoBattle", v) end)

	-- Battle Speed
	createDropdown(gameplayFrame, "Velocidade de Batalha", "Velocidade das animações de combate", {"0.5x", "1x", "1.5x", "2x", "3x"},
		settings.battleSpeed .. "x",
		function(v) onChange("battleSpeed", tonumber(v:sub(1, -2))) end)

	-- Control Scheme
	createDropdown(gameplayFrame, "Esquema de Controle", "Modo de entrada preferido", {"Toque", "Teclado", "Gamepad"},
		settings.controlScheme:sub(1,1):upper() .. settings.controlScheme:sub(2),
		function(v) onChange("controlScheme", v:lower()) end)

	-- Language
	createDropdown(gameplayFrame, "Idioma", "Idioma do jogo", {"Português (BR)", "English", "Español"},
		settings.language == "pt-BR" and "Português (BR)" or settings.language == "en" and "English" or "Español",
		function(v)
			local lang = v == "Português (BR)" and "pt-BR" or v == "English" and "en" or "es"
			onChange("language", lang)
		end)

	-- DATA SECTION
	createSection(parent, "DADOS", "Book")

	local dataFrame = panel(parent, 0)
	dataFrame.AutomaticSize = Enum.AutomaticSize.Y
	dataFrame.BackgroundTransparency = 1

	local dLayout = Instance.new("UIListLayout")
	dLayout.Padding = UDim.new(0, 8)
	dLayout.Parent = dataFrame

	-- Save button
	local saveBtn = Instance.new("TextButton")
	saveBtn.Size = UDim2.new(1, -16, 0, 44)
	saveBtn.Position = UDim2.fromOffset(8, 4)
	saveBtn.Text = "💾 SALVAR CONFIGURAÇÕES"
	saveBtn.TextSize = 14
	saveBtn.Font = Theme.Font
	saveBtn.TextColor3 = Theme.Panel
	saveBtn.BackgroundColor3 = Theme.Mint
	saveBtn.Parent = dataFrame
	Theme.panel(saveBtn)
	Theme.bind(saveBtn)
	saveBtn.Activated:Connect(function()
		-- Trigger save to server
		onChange("save", true)
	end)

	-- Reset button
	local resetBtn = Instance.new("TextButton")
	resetBtn.Size = UDim2.new(1, -16, 0, 44)
	resetBtn.Position = UDim2.fromOffset(8, 52)
	resetBtn.Text = "🔄 RESTAURAR PADRÕES"
	resetBtn.TextSize = 14
	resetBtn.Font = Theme.Font
	resetBtn.TextColor3 = Theme.Panel
	resetBtn.BackgroundColor3 = Theme.Tokens.Ramps.Fogo[2]
	resetBtn.Parent = dataFrame
	Theme.panel(resetBtn)
	Theme.bind(resetBtn)
	resetBtn.Activated:Connect(function()
		-- Show confirmation
		S.showResetConfirm(parent.Parent, function()
			for k, v in DEFAULT_SETTINGS do
				onChange(k, v)
			end
		end)
	end)

	-- Account info
	local accInfo = Instance.new("Frame")
	accInfo.Size = UDim2.new(1, -16, 0, 60)
	accInfo.Position = UDim2.fromOffset(8, 104)
	accInfo.BackgroundTransparency = 1
	accInfo.Parent = dataFrame

	label(accInfo, "Conta: " .. LocalPlayer.DisplayName, UDim2.fromOffset(0, 0), UDim2.new(1, 0, 0, 20), 12, Theme.Muted)
	label(accInfo, "UserId: " .. LocalPlayer.UserId, UDim2.fromOffset(0, 20), UDim2.new(1, 0, 0, 20), 12, Theme.Muted)
	label(accInfo, "Versão: V7", UDim2.fromOffset(0, 40), UDim2.new(1, 0, 0, 20), 12, Theme.Muted)
end

-- Reset confirmation modal
function S.showResetConfirm(parent: Instance, onConfirm: () -> ())
	local overlay = Instance.new("Frame")
	overlay.Name = "ResetConfirmOverlay"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Theme.Shadow
	overlay.BackgroundTransparency = 0.4
	overlay.ZIndex = 100
	overlay.Parent = parent

	local modal = Instance.new("Frame")
	modal.Size = UDim2.fromOffset(300, 180)
	modal.Position = UDim2.fromScale(0.5, 0.5)
	modal.AnchorPoint = Vector2.new(0.5, 0.5)
	modal.BackgroundColor3 = Theme.Panel
	modal.ZIndex = 101
	modal.Parent = overlay
	Theme.panel(modal, Theme.Tokens.Ramps.Fogo[4])

	modal.Size = UDim2.fromOffset(0, 0)
	TweenService:Create(modal, TWEEN_MED, {Size = UDim2.fromOffset(300, 180)}):Play()

	label(modal, "⚠ RESTAURAR PADRÕES?", UDim2.fromOffset(16, 16), UDim2.new(1, -32, 0, 28), 16, Theme.Tokens.Ramps.Fogo[4]).TextXAlignment = Enum.TextXAlignment.Center

	label(modal, "Todas as configurações voltarão aos valores padrão. Esta ação não pode ser desfeita.", UDim2.fromOffset(20, 50), UDim2.new(1, -40, 0, 50), 13, Theme.Muted).TextXAlignment = Enum.TextXAlignment.Center

	local btnFrame = Instance.new("Frame")
	btnFrame.Size = UDim2.new(1, -24, 0, 40)
	btnFrame.Position = UDim2.fromOffset(12, 120)
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
	end)

	local confirmBtn = Instance.new("TextButton")
	confirmBtn.Size = UDim2.fromOffset(100, 40)
	confirmBtn.Text = "RESTAURAR"
	confirmBtn.TextSize = 13
	confirmBtn.Font = Theme.Font
	confirmBtn.TextColor3 = Theme.Panel
	confirmBtn.BackgroundColor3 = Theme.Tokens.Ramps.Fogo[2]
	confirmBtn.Parent = btnFrame
	Theme.panel(confirmBtn)
	Theme.bind(confirmBtn)
	confirmBtn.Activated:Connect(function()
		TweenService:Create(modal, TWEEN_FAST, {Size = UDim2.fromOffset(0, 0)}):Play()
		task.delay(0.15, function()
			overlay:Destroy()
		end)
		onConfirm()
	end)
end

-- Load settings from player attributes
function S.loadFromPlayer(): SettingsData
	local s = {}
	for k, v in DEFAULT_SETTINGS do
		local attr = LocalPlayer:GetAttribute("Setting_" .. k)
		if attr ~= nil then
			s[k] = attr
		else
			s[k] = v
		end
	end
	return s
end

-- Save settings to player attributes
function S.saveToPlayer(settings: SettingsData)
	for k, v in settings do
		LocalPlayer:SetAttribute("Setting_" .. k, v)
	end

	-- Apply immediately
	if settings.motionReduced then
		LocalPlayer:SetAttribute("MotionReduced", true)
	end
	if settings.soundEnabled then
		SoundService.Volume = 1
	else
		SoundService.Volume = 0
	end
	if settings.graphics == "low" then
		LocalPlayer:SetAttribute("GraphicsQuality", "Baixo")
	elseif settings.graphics == "high" then
		LocalPlayer:SetAttribute("GraphicsQuality", "Alto")
	else
		LocalPlayer:SetAttribute("GraphicsQuality", "Médio")
	end

	-- Bloom for high graphics
	for _, effect in Lighting:GetChildren() do
		if effect:IsA("BloomEffect") then
			effect.Enabled = settings.graphics == "high"
		end
	end
end

return S