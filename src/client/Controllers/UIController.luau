--!strict
-- UIController.lua - Gerenciamento de interface do usuário

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local UIController = {}

-- Events
UIController.OnScreenChanged = Signal.New()

-- UI References
local ScreenGui: ScreenGui?
local Screens = {} :: {[string]: Frame}
local CurrentScreen = "Loading"
local ScreenStack = {} :: {string}

-- Initialize
function UIController.Initialize(playerData: Types.PlayerData)
	local player = Players.LocalPlayer
	local playerGui = player:WaitForChild("PlayerGui")

	-- Create main ScreenGui
	ScreenGui = Instance.new("ScreenGui")
	ScreenGui.Name = "ArquipelagoUI"
	ScreenGui.ResetOnSpawn = false
	ScreenGui.IgnoreGuiInset = true
	ScreenGui.DisplayOrder = 10
	ScreenGui.Parent = playerGui

	-- Create all screens
	UIController.CreateScreens()

	-- Setup UI scaling
	UIController.SetupScaling()

	print("[UIController] Initialized")
end

-- Create all UI screens
function UIController.CreateScreens()
	if not ScreenGui then return end

	-- Loading Screen
	Screens.Loading = UIController.CreateLoadingScreen()

	-- Main Menu
	Screens.MainMenu = UIController.CreateMainMenu()

	-- Gameplay HUD
	Screens.Gameplay = UIController.CreateGameplayHUD()

	-- Party Screen
	Screens.Party = UIController.CreatePartyScreen()

	-- Creature Detail
	Screens.CreatureDetail = UIController.CreateCreatureDetailScreen()

	-- Inventory
	Screens.Inventory = UIController.CreateInventoryScreen()

	-- Battle
	Screens.Battle = UIController.CreateBattleScreen()

	-- World Map
	Screens.WorldMap = UIController.CreateWorldMapScreen()

	-- Settings
	Screens.Settings = UIController.CreateSettingsScreen()

	-- Capture Animation
	Screens.Capture = UIController.CreateCaptureScreen()

	-- Evolution Animation
	Screens.Evolution = UIController.CreateEvolutionScreen()

	-- Level Up Animation
	Screens.LevelUp = UIController.CreateLevelUpScreen()

	-- Shop
	Screens.Shop = UIController.CreateShopScreen()

	-- Default hide all
	for _, screen in pairs(Screens) do
		screen.Visible = false
	end
end

-- Show screen with transition
function UIController.ShowScreen(screenName: string, pushToStack: boolean?)
	if Screens[screenName] then
		-- Hide current screen
		if CurrentScreen ~= "Loading" and Screens[CurrentScreen] then
			UIController.HideScreen(CurrentScreen)
		end

		if pushToStack and CurrentScreen ~= screenName then
			table.insert(ScreenStack, CurrentScreen)
		end

		CurrentScreen = screenName
		Screens[screenName].Visible = true

		-- Animate in
		UIController.AnimateScreenIn(Screens[screenName])

		UIController.OnScreenChanged:Fire(screenName)
	end
end

-- Go back to previous screen
function UIController.GoBack()
	if #ScreenStack > 0 then
		local previous = table.remove(ScreenStack)
		UIController.ShowScreen(previous)
	end
end

-- Hide screen
function UIController.HideScreen(screenName: string)
	if Screens[screenName] then
		UIController.AnimateScreenOut(Screens[screenName], function()
			Screens[screenName].Visible = false
		end)
	end
end

-- Animate screen in
function UIController.AnimateScreenIn(screen: Frame)
	screen.Position = UDim2.new(0.5, 0, 0.5, 0)
	screen.AnchorPoint = Vector2.new(0.5, 0.5)
	screen.Size = UDim2.new(0, 0, 0, 0)
	screen.BackgroundTransparency = 1

	local tween = TweenService:Create(screen, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(1, 0, 1, 0),
		BackgroundTransparency = 0,
	})
	tween:Play()
end

-- Animate screen out
function UIController.AnimateScreenOut(screen: Frame, callback: () -> ())
	local tween = TweenService:Create(screen, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 0, 0, 0),
		BackgroundTransparency = 1,
	})
	tween.Completed:Connect(callback)
	tween:Play()
end

-- Setup UI scaling for different screen sizes
function UIController.SetupScaling()
	if not ScreenGui then return end

	local uiScale = Instance.new("UIScale")
	uiScale.Name = "GlobalScale"
	uiScale.Parent = ScreenGui

	local function updateScale()
		local viewport = workspace.CurrentCamera.ViewportSize
		local baseWidth = 1920
		local scale = viewport.X / baseWidth
		uiScale.Scale = math.clamp(scale, 0.75, 1.5)
	end

	updateScale()
	workspace.CurrentCamera:GetPropertyChangedSignal("ViewportSize"):Connect(updateScale)
end

-- ========== SCREEN CREATORS ==========

function UIController.CreateLoadingScreen(): Frame
	local frame = Instance.new("Frame")
	frame.Name = "LoadingScreen"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	frame.BorderSizePixel = 0
	frame.Parent = ScreenGui

	-- Background gradient
	local gradient = Instance.new("UIGradient")
	gradient.Color = ColorSequence.new({
		ColorSequenceKeypoint.new(0, Color3.fromRGB(15, 15, 25)),
		ColorSequenceKeypoint.new(0.5, Color3.fromRGB(30, 20, 40)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(15, 15, 25)),
	})
	gradient.Rotation = 45
	gradient.Parent = frame

	-- Logo
	local logo = Instance.new("TextLabel")
	logo.Name = "Logo"
	logo.Size = UDim2.new(0, 400, 0, 100)
	logo.Position = UDim2.new(0.5, 0, 0.3, 0)
	logo.AnchorPoint = Vector2.new(0.5, 0.5)
	logo.BackgroundTransparency = 1
	logo.Text = "🏝️ ARQUIPÉLAGO DAS FERAS"
	logo.TextColor3 = Color3.fromRGB(255, 200, 100)
	logo.TextScaled = true
	logo.Font = Enum.Font.GothamBold
	logo.Parent = frame

	-- Subtitle
	local subtitle = Instance.new("TextLabel")
	subtitle.Name = "Subtitle"
	subtitle.Size = UDim2.new(0, 300, 0, 40)
	subtitle.Position = UDim2.new(0.5, 0, 0.45, 0)
	subtitle.AnchorPoint = Vector2.new(0.5, 0.5)
	subtitle.BackgroundTransparency = 1
	subtitle.Text = "Um mundo de criaturas aguarda..."
	subtitle.TextColor3 = Color3.fromRGB(180, 180, 200)
	subtitle.TextScaled = true
	subtitle.Font = Enum.Font.Gotham
	subtitle.Parent = frame

	-- Progress bar
	local progressBg = Instance.new("Frame")
	progressBg.Name = "ProgressBg"
	progressBg.Size = UDim2.new(0, 400, 0, 8)
	progressBg.Position = UDim2.new(0.5, 0, 0.6, 0)
	progressBg.AnchorPoint = Vector2.new(0.5, 0.5)
	progressBg.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
	progressBg.BorderSizePixel = 0
	progressBg.Parent = frame

	local progressCorner = Instance.new("UICorner")
	progressCorner.CornerRadius = UDim.new(1, 0)
	progressCorner.Parent = progressBg

	local progressFill = Instance.new("Frame")
	progressFill.Name = "ProgressFill"
	progressFill.Size = UDim2.new(0, 0, 1, 0)
	progressFill.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
	progressFill.BorderSizePixel = 0
	progressFill.Parent = progressBg

	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = progressFill

	-- Loading text
	local loadingText = Instance.new("TextLabel")
	loadingText.Name = "LoadingText"
	loadingText.Size = UDim2.new(0, 300, 0, 30)
	loadingText.Position = UDim2.new(0.5, 0, 0.7, 0)
	loadingText.AnchorPoint = Vector2.new(0.5, 0.5)
	loadingText.BackgroundTransparency = 1
	loadingText.Text = "Carregando..."
	loadingText.TextColor3 = Color3.fromRGB(150, 150, 170)
	loadingText.TextScaled = true
	loadingText.Font = Enum.Font.Gotham
	loadingText.Parent = frame

	-- Animate progress
	task.spawn(function()
		for i = 0, 100, 2 do
			progressFill.Size = UDim2.new(i / 100, 0, 1, 0)
			task.wait(0.02)
		end
	end)

	return frame
end

function UIController.CreateMainMenu(): Frame
	local frame = Instance.new("Frame")
	frame.Name = "MainMenu"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
	frame.BorderSizePixel = 0
	frame.Parent = ScreenGui

	-- Background decoration
	local bgPattern = Instance.new("ImageLabel")
	bgPattern.Name = "BgPattern"
	bgPattern.Size = UDim2.new(1, 0, 1, 0)
	bgPattern.BackgroundTransparency = 1
	bgPattern.Image = "rbxassetid://0" -- Would use a pattern
	bgPattern.ImageTransparency = 0.9
	bgPattern.Parent = frame

	-- Title
	local title = Instance.new("TextLabel")
	title.Name = "Title"
	title.Size = UDim2.new(0, 500, 0, 80)
	title.Position = UDim2.new(0.5, 0, 0.15, 0)
	title.AnchorPoint = Vector2.new(0.5, 0.5)
	title.BackgroundTransparency = 1
	title.Text = "ARQUIPÉLAGO DAS FERAS"
	title.TextColor3 = Color3.fromRGB(255, 210, 100)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.Parent = frame

	-- Version
	local version = Instance.new("TextLabel")
	version.Name = "Version"
	version.Size = UDim2.new(0, 200, 0, 25)
	version.Position = UDim2.new(0.5, 0, 0.22, 0)
	version.AnchorPoint = Vector2.new(0.5, 0.5)
	version.BackgroundTransparency = 1
	version.Text = "v0.1.0 - Alpha"
	version.TextColor3 = Color3.fromRGB(120, 120, 140)
	version.TextScaled = true
	version.Font = Enum.Font.Gotham
	version.Parent = frame

	-- Menu buttons container
	local buttonContainer = Instance.new("Frame")
	buttonContainer.Name = "ButtonContainer"
	buttonContainer.Size = UDim2.new(0, 300, 0, 400)
	buttonContainer.Position = UDim2.new(0.5, 0, 0.55, 0)
	buttonContainer.AnchorPoint = Vector2.new(0.5, 0.5)
	buttonContainer.BackgroundTransparency = 1
	buttonContainer.Parent = frame

	local layout = Instance.new("UIListLayout")
	layout.Padding = UDim.new(0, 15)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Parent = buttonContainer

	-- Buttons
	local buttons = {
		{Name = "Continuar", Text = "🎮 CONTINUAR", Color = Color3.fromRGB(60, 180, 100)},
		{Name = "NovoJogo", Text = "✨ NOVO JOGO", Color = Color3.fromRGB(255, 150, 50)},
		{Name = "Criaturas", Text = "📖 CRIATURÁRIO", Color = Color3.fromRGB(100, 150, 255)},
		{Name = "Configurações", Text = "⚙️ CONFIGURAÇÕES", Color = Color3.fromRGB(150, 150, 170)},
		{Name = "Sair", Text = "🚪 SAIR", Color = Color3.fromRGB(200, 60, 60)},
	}

	for _, btnData in ipairs(buttons) do
		local btn = Instance.new("TextButton")
		btn.Name = btnData.Name
		btn.Size = UDim2.new(1, 0, 0, 60)
		btn.BackgroundColor3 = btnData.Color
		btn.BorderSizePixel = 0
		btn.Text = btnData.Text
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextScaled = true
		btn.Font = Enum.Font.GothamBold
		btn.Parent = buttonContainer

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = btn

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(255, 255, 255)
		stroke.Transparency = 0.8
		stroke.Thickness = 2
		stroke.Parent = btn

		-- Hover effect
		btn.MouseEnter:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0.1, Size = UDim2.new(1.02, 0, 0, 62)}):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(btn, TweenInfo.new(0.15), {BackgroundTransparency = 0, Size = UDim2.new(1, 0, 0, 60)}):Play()
		end)

		-- Click
		btn.MouseButton1Click:Connect(function()
			if btnData.Name == "NovoJogo" or btnData.Name == "Continuar" then
				UIController.ShowScreen("Gameplay")
			elseif btnData.Name == "Criaturas" then
				UIController.ShowScreen("Party")
			elseif btnData.Name == "Configurações" then
				UIController.ShowScreen("Settings")
			elseif btnData.Name == "Sair" then
				game:Shutdown()
			end
		end)
	end

	-- Bottom info
	local info = Instance.new("TextLabel")
	info.Name = "Info"
	info.Size = UDim2.new(1, 0, 0, 30)
	info.Position = UDim2.new(0.5, 0, 0.95, 0)
	info.AnchorPoint = Vector2.new(0.5, 1)
	info.BackgroundTransparency = 1
	info.Text = "Desenvolvido com ❤️ por ZaionLuz | 27 Criaturas | Pipeline Blender → Roblox"
	info.TextColor3 = Color3.fromRGB(80, 80, 100)
	info.TextScaled = true
	info.Font = Enum.Font.Gotham
	info.Parent = frame

	return frame
end

function UIController.CreateGameplayHUD(): Frame
	local frame = Instance.new("Frame")
	frame.Name = "GameplayHUD"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = ScreenGui

	-- Top bar: Money, Location, Time
	local topBar = Instance.new("Frame")
	topBar.Name = "TopBar"
	topBar.Size = UDim2.new(1, 0, 0, 60)
	topBar.Position = UDim2.new(0, 0, 0, 10)
	topBar.BackgroundTransparency = 1
	topBar.Parent = frame

	-- Money
	local moneyFrame = Instance.new("Frame")
	moneyFrame.Name = "Money"
	moneyFrame.Size = UDim2.new(0, 180, 0, 50)
	moneyFrame.Position = UDim2.new(0, 20, 0, 0)
	moneyFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	moneyFrame.BackgroundTransparency = 0.3
	moneyFrame.BorderSizePixel = 0
	moneyFrame.Parent = topBar

	local moneyCorner = Instance.new("UICorner")
	moneyCorner.CornerRadius = UDim.new(0, 25)
	moneyCorner.Parent = moneyFrame

	local moneyIcon = Instance.new("TextLabel")
	moneyIcon.Size = UDim2.new(0, 40, 1, 0)
	moneyIcon.BackgroundTransparency = 1
	moneyIcon.Text = "💰"
	moneyIcon.TextScaled = true
	moneyIcon.Parent = moneyFrame

	local moneyText = Instance.new("TextLabel")
	moneyText.Name = "Amount"
	moneyText.Size = UDim2.new(1, -45, 1, 0)
	moneyText.Position = UDim2.new(0, 40, 0, 0)
	moneyText.BackgroundTransparency = 1
	moneyText.Text = "1,000"
	moneyText.TextColor3 = Color3.fromRGB(255, 220, 100)
	moneyText.TextScaled = true
	moneyText.Font = Enum.Font.GothamBold
	moneyText.TextXAlignment = Enum.TextXAlignment.Left
	moneyText.Parent = moneyFrame

	-- Location
	local locationFrame = Instance.new("Frame")
	locationFrame.Name = "Location"
	locationFrame.Size = UDim2.new(0, 200, 0, 50)
	locationFrame.Position = UDim2.new(0.5, -100, 0, 0)
	locationFrame.AnchorPoint = Vector2.new(0.5, 0)
	locationFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	locationFrame.BackgroundTransparency = 0.3
	locationFrame.BorderSizePixel = 0
	locationFrame.Parent = topBar

	local locCorner = Instance.new("UICorner")
	locCorner.CornerRadius = UDim.new(0, 25)
	locCorner.Parent = locationFrame

	local locationText = Instance.new("TextLabel")
	locationText.Name = "Name"
	locationText.Size = UDim2.new(1, -20, 1, 0)
	locationText.Position = UDim2.new(0, 10, 0, 0)
	locationText.BackgroundTransparency = 1
	locationText.Text = "📍 Vila Inicial"
	locationText.TextColor3 = Color3.fromRGB(200, 200, 220)
	locationText.TextScaled = true
	locationText.Font = Enum.Font.Gotham
	locationText.Parent = locationFrame

	-- Time of day
	local timeFrame = Instance.new("Frame")
	timeFrame.Name = "Time"
	timeFrame.Size = UDim2.new(0, 150, 0, 50)
	timeFrame.Position = UDim2.new(1, -170, 0, 0)
	timeFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	timeFrame.BackgroundTransparency = 0.3
	timeFrame.BorderSizePixel = 0
	timeFrame.Parent = topBar

	local timeCorner = Instance.new("UICorner")
	timeCorner.CornerRadius = UDim.new(0, 25)
	timeCorner.Parent = timeFrame

	local timeText = Instance.new("TextLabel")
	timeText.Name = "Display"
	timeText.Size = UDim2.new(1, -20, 1, 0)
	timeText.Position = UDim2.new(0, 10, 0, 0)
	timeText.BackgroundTransparency = 1
	timeText.Text = "☀️ 12:00"
	timeText.TextColor3 = Color3.fromRGB(200, 200, 220)
	timeText.TextScaled = true
	timeText.Font = Enum.Font.Gotham
	timeText.Parent = timeFrame

	-- Bottom: Party icons
	local partyBar = Instance.new("Frame")
	partyBar.Name = "PartyBar"
	partyBar.Size = UDim2.new(1, -40, 0, 80)
	partyBar.Position = UDim2.new(0, 20, 1, -90)
	partyBar.BackgroundTransparency = 1
	partyBar.Parent = frame

	local partyLayout = Instance.new("UIListLayout")
	partyLayout.FillDirection = Enum.FillDirection.Horizontal
	partyLayout.Padding = UDim.new(0, 10)
	partyLayout.HorizontalAlignment = Enum.HorizontalAlignment.Left
	partyLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	partyLayout.Parent = partyBar

	-- Party slots (6)
	for i = 1, 6 do
		local slot = Instance.new("Frame")
		slot.Name = `PartySlot{i}`
		slot.Size = UDim2.new(0, 70, 0, 70)
		slot.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
		slot.BackgroundTransparency = 0.2
		slot.BorderSizePixel = 0
		slot.Parent = partyBar

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 12)
		corner.Parent = slot

		local stroke = Instance.new("UIStroke")
		stroke.Color = Color3.fromRGB(60, 60, 80)
		stroke.Thickness = 2
		stroke.Parent = slot

		-- Creature icon placeholder
		local icon = Instance.new("ImageLabel")
		icon.Name = "Icon"
		icon.Size = UDim2.new(0.8, 0, 0.8, 0)
		icon.Position = UDim2.new(0.1, 0, 0.1, 0)
		icon.BackgroundTransparency = 1
		icon.Image = ""
		icon.Parent = slot

		-- HP bar
		local hpBg = Instance.new("Frame")
		hpBg.Name = "HpBg"
		hpBg.Size = UDim2.new(1, -8, 0, 4)
		hpBg.Position = UDim2.new(0, 4, 1, -8)
		hpBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
		hpBg.BorderSizePixel = 0
		hpBg.Parent = slot

		local hpCorner = Instance.new("UICorner")
		hpCorner.CornerRadius = UDim.new(1, 0)
		hpCorner.Parent = hpBg

		local hpFill = Instance.new("Frame")
		hpFill.Name = "HpFill"
		hpFill.Size = UDim2.new(1, 0, 1, 0)
		hpFill.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
		hpFill.BorderSizePixel = 0
		hpFill.Parent = hpBg

		local hpFillCorner = Instance.new("UICorner")
		hpFillCorner.CornerRadius = UDim.new(1, 0)
		hpFillCorner.Parent = hpFill

		-- Level badge
		local levelBadge = Instance.new("TextLabel")
		levelBadge.Name = "Level"
		levelBadge.Size = UDim2.new(0, 24, 0, 20)
		levelBadge.Position = UDim2.new(1, -26, 0, 2)
		levelBadge.BackgroundColor3 = Color3.fromRGB(255, 150, 50)
		levelBadge.BorderSizePixel = 0
		levelBadge.Text = "5"
		levelBadge.TextColor3 = Color3.fromRGB(255, 255, 255)
		levelBadge.TextScaled = true
		levelBadge.Font = Enum.Font.GothamBold
		levelBadge.Parent = slot

		local lvlCorner = Instance.new("UICorner")
		lvlCorner.CornerRadius = UDim.new(0, 4)
		lvlCorner.Parent = levelBadge

		-- Click to open party
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.Parent = slot

		btn.MouseButton1Click:Connect(function()
			UIController.ShowScreen("Party")
		end)
	end

	-- Action buttons (right side)
	local actionBar = Instance.new("Frame")
	actionBar.Name = "ActionBar"
	actionBar.Size = UDim2.new(0, 200, 0, 200)
	actionBar.Position = UDim2.new(1, -210, 1, -210)
	actionBar.BackgroundTransparency = 1
	actionBar.Parent = frame

	local actionLayout = Instance.new("UIListLayout")
	actionLayout.Padding = UDim.new(0, 10)
	actionLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	actionLayout.VerticalAlignment = Enum.VerticalAlignment.Bottom
	actionLayout.Parent = actionBar

	local actions = {
		{Name = "Party", Text = "📋 PARTY", Key = "P"},
		{Name = "Inventory", Text = "🎒 ITENS", Key = "I"},
		{Name = "Map", Text = "🗺️ MAPA", Key = "M"},
		{Name = "Menu", Text = "☰ MENU", Key = "ESC"},
	}

	for _, act in ipairs(actions) do
		local btn = Instance.new("TextButton")
		btn.Name = act.Name
		btn.Size = UDim2.new(1, 0, 0, 45)
		btn.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
		btn.BorderSizePixel = 0
		btn.Text = act.Text
		btn.TextColor3 = Color3.fromRGB(220, 220, 240)
		btn.TextScaled = true
		btn.Font = Enum.Font.GothamSemibold
		btn.Parent = actionBar

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 10)
		corner.Parent = btn

		local keyLabel = Instance.new("TextLabel")
		keyLabel.Size = UDim2.new(0, 30, 0, 20)
		keyLabel.Position = UDim2.new(1, -35, 0, 5)
		keyLabel.BackgroundColor3 = Color3.fromRGB(60, 60, 80)
		keyLabel.BorderSizePixel = 0
		keyLabel.Text = act.Key
		keyLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
		keyLabel.TextScaled = true
		keyLabel.Font = Enum.Font.GothamBold
		keyLabel.Parent = btn

		local keyCorner = Instance.new("UICorner")
		keyCorner.CornerRadius = UDim.new(0, 4)
		keyCorner.Parent = keyLabel

		btn.MouseButton1Click:Connect(function()
			if act.Name == "Party" then UIController.ShowScreen("Party")
			elseif act.Name == "Inventory" then UIController.ShowScreen("Inventory")
			elseif act.Name == "Map" then UIController.ShowScreen("WorldMap")
			elseif act.Name == "Menu" then UIController.ShowScreen("MainMenu")
			end
		end)
	end

	return frame
end

function UIController.CreatePartyScreen(): Frame
	local frame = Instance.new("Frame")
	frame.Name = "PartyScreen"
	frame.Size = UDim2.new(0.9, 0, 0.85, 0)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	frame.BorderSizePixel = 0
	frame.Parent = ScreenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = frame

	-- Header
	local header = Instance.new("Frame")
	header.Name = "Header"
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundTransparency = 1
	header.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 200, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "📋 MINHA PARTY"
	title.TextColor3 = Color3.fromRGB(255, 210, 100)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Size = UDim2.new(0, 50, 0, 50)
	closeBtn.Position = UDim2.new(1, -60, 0, 5)
	closeBtn.BackgroundTransparency = 1
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = Color3.fromRGB(180, 180, 200)
	closeBtn.TextScaled = true
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.Parent = header
	closeBtn.MouseButton1Click:Connect(function() UIController.GoBack() end)

	-- Party grid
	local grid = Instance.new("ScrollingFrame")
	grid.Name = "PartyGrid"
	grid.Size = UDim2.new(1, -40, 1, -80)
	grid.Position = UDim2.new(0, 20, 0, 70)
	grid.BackgroundTransparency = 1
	grid.BorderSizePixel = 0
	grid.ScrollBarThickness = 6
	grid.ScrollBarImageColor3 = Color3.fromRGB(100, 100, 120)
	grid.Parent = frame

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 280, 0, 160)
	gridLayout.CellPadding = UDim2.new(0, 15, 0, 15)
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	gridLayout.Parent = grid

	-- Party slots will be populated dynamically

	return frame
end

function UIController.CreateCreatureDetailScreen(): Frame
	local frame = Instance.new("Frame")
	frame.Name = "CreatureDetail"
	frame.Size = UDim2.new(0.8, 0, 0.8, 0)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = ScreenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = frame

	-- Will be populated dynamically
	return frame
end

function UIController.CreateInventoryScreen(): Frame
	local frame = Instance.new("Frame")
	frame.Name = "InventoryScreen"
	frame.Size = UDim2.new(0.85, 0, 0.8, 0)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	frame.BorderSizePixel = 0
	frame.Parent = ScreenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = frame

	-- Header with tabs
	local header = Instance.new("Frame")
	header.Size = UDim2.new(1, 0, 0, 60)
	header.BackgroundTransparency = 1
	header.Parent = frame

	local title = Instance.new("TextLabel")
	title.Size = UDim2.new(0, 200, 1, 0)
	title.Position = UDim2.new(0, 20, 0, 0)
	title.BackgroundTransparency = 1
	title.Text = "🎒 INVENTÁRIO"
	title.TextColor3 = Color3.fromRGB(255, 210, 100)
	title.TextScaled = true
	title.Font = Enum.Font.GothamBold
	title.TextXAlignment = Enum.TextXAlignment.Left
	title.Parent = header

	-- Category tabs
	local tabBar = Instance.new("Frame")
	tabBar.Size = UDim2.new(0, 400, 0, 40)
	tabBar.Position = UDim2.new(0.5, -200, 1, -45)
	tabBar.AnchorPoint = Vector2.new(0.5, 1)
	tabBar.BackgroundTransparency = 1
	tabBar.Parent = header

	local tabLayout = Instance.new("UIListLayout")
	tabLayout.FillDirection = Enum.FillDirection.Horizontal
	tabLayout.Padding = UDim.new(0, 10)
	tabLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	tabLayout.Parent = tabBar

	local categories = {"Bolas", "Medicinas", "PP", "Evolução", "Berries", "Outros"}
	for _, cat in ipairs(categories) do
		local tab = Instance.new("TextButton")
		tab.Size = UDim2.new(0, 100, 1, 0)
		tab.BackgroundColor3 = Color3.fromRGB(40, 40, 60)
		tab.BorderSizePixel = 0
		tab.Text = cat
		tab.TextColor3 = Color3.fromRGB(180, 180, 200)
		tab.TextScaled = true
		tab.Font = Enum.Font.Gotham
		tab.Parent = tabBar

		local tabCorner = Instance.new("UICorner")
		tabCorner.CornerRadius = UDim.new(0, 8)
		tabCorner.Parent = tab
	end

	-- Grid for items
	local grid = Instance.new("ScrollingFrame")
	grid.Name = "ItemGrid"
	grid.Size = UDim2.new(1, -40, 1, -120)
	grid.Position = UDim2.new(0, 20, 0, 70)
	grid.BackgroundTransparency = 1
	grid.BorderSizePixel = 0
	grid.ScrollBarThickness = 6
	grid.Parent = frame

	local gridLayout = Instance.new("UIGridLayout")
	gridLayout.CellSize = UDim2.new(0, 100, 0, 100)
	gridLayout.CellPadding = UDim2.new(0, 10, 0, 10)
	gridLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	gridLayout.Parent = grid

	return frame
end

function UIController.CreateBattleScreen(): Frame
	local frame = Instance.new("Frame")
	frame.Name = "BattleScreen"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
	frame.BorderSizePixel = 0
	frame.Parent = ScreenGui

	-- Battle UI will be built dynamically
	return frame
end

function UIController.CreateWorldMapScreen(): Frame
	local frame = Instance.new("Frame")
	frame.Name = "WorldMap"
	frame.Size = UDim2.new(0.9, 0, 0.85, 0)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = Color3.fromRGB(20, 25, 35)
	frame.BorderSizePixel = 0
	frame.Parent = ScreenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = frame

	return frame
end

function UIController.CreateSettingsScreen(): Frame
	local frame = Instance.new("Frame")
	frame.Name = "SettingsScreen"
	frame.Size = UDim2.new(0.7, 0, 0.7, 0)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	frame.BorderSizePixel = 0
	frame.Parent = ScreenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = frame

	return frame
end

function UIController.CreateCaptureScreen(): Frame
	local frame = Instance.new("Frame")
	frame.Name = "CaptureScreen"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.Parent = ScreenGui
	return frame
end

function UIController.CreateEvolutionScreen(): Frame
	local frame = Instance.new("Frame")
	frame.Name = "EvolutionScreen"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.Parent = ScreenGui
	return frame
end

function UIController.CreateLevelUpScreen(): Frame
	local frame = Instance.new("Frame")
	frame.Name = "LevelUpScreen"
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundTransparency = 1
	frame.Visible = false
	frame.Parent = ScreenGui
	return frame
end

function UIController.CreateShopScreen(): Frame
	local frame = Instance.new("Frame")
	frame.Name = "ShopScreen"
	frame.Size = UDim2.new(0.85, 0, 0.8, 0)
	frame.Position = UDim2.new(0.5, 0, 0.5, 0)
	frame.AnchorPoint = Vector2.new(0.5, 0.5)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	frame.BorderSizePixel = 0
	frame.Parent = ScreenGui

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = frame

	return frame
end

-- Update functions
function UIController.UpdatePartyUI(partySummary: any)
	-- Update party slots in GameplayHUD and PartyScreen
end

function UIController.ShowCaptureAnimation(creature: Types.CreatureData)
	-- Play capture animation
end

function UIController.ShowEvolutionAnimation(oldSpecies: string, newSpecies: string, creature: Types.CreatureData)
	-- Play evolution animation
end

function UIController.ShowLevelUpAnimation(creature: Types.CreatureData, oldLevel: number, newLevel: number)
	-- Play level up animation
end

return UIController