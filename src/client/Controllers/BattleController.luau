--!strict
-- BattleController.lua - Controlador de batalhas

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")

local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local MathUtil = require(ReplicatedStorage.Shared.Util.Math)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local BattleController = {}

-- Events
BattleController.OnBattleStarted = Signal.New()
BattleController.OnBattleEnded = Signal.New()
BattleController.OnTurnChanged = Signal.New()
BattleController.OnMoveUsed = Signal.New()
BattleController.OnCreatureFainted = Signal.New()
BattleController.OnStatusChanged = Signal.New()
BattleController.OnStatStageChanged = Signal.New()
BattleController.OnWeatherChanged = Signal.New()

-- State
local CurrentBattle: Types.BattleData?
local LocalPlayer = Players.LocalPlayer
local IsPlayerTurn = false
local TurnTimer = 0
local SelectedAction: Types.BattleAction?
local BattleUI = {} :: {[string]: Instance}

-- Animation state
local BattleAnimations = {} :: {thread}

-- Initialize
function BattleController.Initialize()
	print("[BattleController] Initializing...")
	print("[BattleController] Initialized")
end

-- Start battle
function BattleController.StartBattle(battleData: Types.BattleData)
	CurrentBattle = battleData
	IsPlayerTurn = battleData.CurrentTurn == 1 -- Player is usually turn 1
	TurnTimer = Config.Battle.TurnTime or 30

	print("[BattleController] Battle started:", battleData.Id)

	-- Create battle UI
	BattleController.CreateBattleUI(battleData)

	-- Start turn timer
	BattleController.StartTurnTimer()

	BattleController.OnBattleStarted:Fire(battleData)
end

-- End battle
function BattleController.EndBattle(result: string)
	print("[BattleController] Battle ended:", result)

	-- Clean up UI
	BattleController.DestroyBattleUI()

	-- Clear state
	CurrentBattle = nil
	IsPlayerTurn = false
	SelectedAction = nil

	BattleController.OnBattleEnded:Fire(result)
end

-- Update battle state from server
function BattleController.UpdateBattle(battleData: Types.BattleData)
	if not CurrentBattle then return end

	local oldTurn = CurrentBattle.CurrentTurn
	CurrentBattle = battleData
	IsPlayerTurn = battleData.CurrentTurn == 1

	-- Update UI
	BattleController.UpdateBattleUI(battleData)

	-- Check for turn change
	if battleData.CurrentTurn ~= oldTurn then
		TurnTimer = Config.Battle.TurnTime or 30
		BattleController.StartTurnTimer()
		BattleController.OnTurnChanged:Fire(battleData.CurrentTurn, IsPlayerTurn)
	end
end

-- Create battle UI
function BattleController.CreateBattleUI(battleData: Types.BattleData)
	local playerGui = LocalPlayer:WaitForChild("PlayerGui")
	local screenGui = playerGui:FindFirstChild("ArquipelagoUI")

	if not screenGui then return end

	-- Main battle frame
	local battleFrame = Instance.new("Frame")
	battleFrame.Name = "BattleFrame"
	battleFrame.Size = UDim2.new(1, 0, 1, 0)
	battleFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
	battleFrame.BorderSizePixel = 0
	battleFrame.Parent = screenGui
	BattleUI.Main = battleFrame

	-- Background
	local bg = Instance.new("ImageLabel")
	bg.Name = "BattleBg"
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundTransparency = 1
	bg.Image = "rbxassetid://0" -- Battle background
	bg.ImageTransparency = 0.5
	bg.Parent = battleFrame

	-- Weather indicator
	if battleData.Weather then
		BattleController.CreateWeatherIndicator(battleFrame, battleData.Weather)
	end

	-- Player side (bottom)
	local playerSide = BattleController.CreateSideUI(battleFrame, "Player", battleData.PlayerCreature, true)
	BattleUI.PlayerSide = playerSide

	-- Enemy side (top)
	local enemySide = BattleController.CreateSideUI(battleFrame, "Enemy", battleData.EnemyCreature, false)
	BattleUI.EnemySide = enemySide

	-- Action menu (bottom)
	local actionMenu = BattleController.CreateActionMenu(battleFrame)
	BattleUI.ActionMenu = actionMenu

	-- Move selection
	local moveMenu = BattleController.CreateMoveMenu(battleFrame)
	moveMenu.Visible = false
	BattleUI.MoveMenu = moveMenu

	-- Battle log
	local battleLog = BattleController.CreateBattleLog(battleFrame)
	BattleUI.BattleLog = battleLog

	-- Turn timer
	local timerFrame = BattleController.CreateTurnTimer(battleFrame)
	BattleUI.Timer = timerFrame

	-- Creature viewports
	BattleController.CreateBattleViewports(battleFrame, battleData)
end

function BattleController.CreateSideUI(parent: Instance, side: string, creature: Types.CreatureData?, isPlayer: boolean): Frame
	local frame = Instance.new("Frame")
	frame.Name = side .. "Side"
	frame.Size = UDim2.new(0.4, 0, 0.25, 0)
	frame.Position = isPlayer and UDim2.new(0.55, 0, 0.65, 0) or UDim2.new(0.05, 0, 0.1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(20, 20, 35)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	if not creature then return frame end

	-- Creature name and level
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Name = "Name"
	nameLabel.Size = UDim2.new(1, -20, 0, 30)
	nameLabel.Position = UDim2.new(0, 10, 0, 10)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = (creature.Nickname ~= "" and creature.Nickname or creature.SpeciesId) .. `  Lv.{creature.Level}`
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = frame

	-- HP Bar
	local hpBg = Instance.new("Frame")
	hpBg.Name = "HpBg"
	hpBg.Size = UDim2.new(1, -20, 0, 16)
	hpBg.Position = UDim2.new(0, 10, 0, 45)
	hpBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	hpBg.BorderSizePixel = 0
	hpBg.Parent = frame

	local hpCorner = Instance.new("UICorner")
	hpCorner.CornerRadius = UDim.new(1, 0)
	hpCorner.Parent = hpBg

	local hpFill = Instance.new("Frame")
	hpFill.Name = "HpFill"
	hpFill.Size = UDim2.new(creature.CurrentHP / creature.MaxHP, 0, 1, 0)
	hpFill.BackgroundColor3 = BattleController.GetHPColor(creature.CurrentHP / creature.MaxHP)
	hpFill.BorderSizePixel = 0
	hpFill.Parent = hpBg

	local hpFillCorner = Instance.new("UICorner")
	hpFillCorner.CornerRadius = UDim.new(1, 0)
	hpFillCorner.Parent = hpFill

	local hpText = Instance.new("TextLabel")
	hpText.Name = "HpText"
	hpText.Size = UDim2.new(1, -10, 1, 0)
	hpText.Position = UDim2.new(0, 5, 0, 0)
	hpText.BackgroundTransparency = 1
	hpText.Text = `{creature.CurrentHP}/{creature.MaxHP}`
	hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
	hpText.TextScaled = true
	hpText.Font = Enum.Font.GothamBold
	hpText.TextXAlignment = Enum.TextXAlignment.Right
	hpText.Parent = hpBg

	-- Status icons
	local statusFrame = Instance.new("Frame")
	statusFrame.Name = "StatusFrame"
	statusFrame.Size = UDim2.new(1, -20, 0, 25)
	statusFrame.Position = UDim2.new(0, 10, 0, 65)
	statusFrame.BackgroundTransparency = 1
	statusFrame.Parent = frame

	local statusLayout = Instance.new("UIListLayout")
	statusLayout.FillDirection = Enum.FillDirection.Horizontal
	statusLayout.Padding = UDim.new(0, 5)
	statusLayout.Parent = statusFrame

	-- Gender
	if creature.Gender ~= "Genderless" then
		local genderLabel = Instance.new("TextLabel")
		genderLabel.Size = UDim2.new(0, 20, 1, 0)
		genderLabel.BackgroundTransparency = 1
		genderLabel.Text = creature.Gender == "Male" and "♂" or "♀"
		genderLabel.TextColor3 = creature.Gender == "Male" and Color3.fromRGB(100, 150, 255) or Color3.fromRGB(255, 100, 200)
		genderLabel.TextScaled = true
		genderLabel.Font = Enum.Font.GothamBold
		genderLabel.Parent = statusFrame
	end

	-- Shiny
	if creature.IsShiny then
		local shinyLabel = Instance.new("TextLabel")
		shinyLabel.Size = UDim2.new(0, 50, 1, 0)
		shinyLabel.BackgroundTransparency = 1
		shinyLabel.Text = "✨"
		shinyLabel.TextScaled = true
		shinyLabel.Parent = statusFrame
	end

	return frame
end

function BattleController.GetHPColor(ratio: number): Color3
	if ratio > 0.5 then return Color3.fromRGB(60, 200, 100)
	elseif ratio > 0.2 then return Color3.fromRGB(255, 180, 50)
	else return Color3.fromRGB(220, 60, 60) end
end

function BattleController.CreateActionMenu(parent: Instance): Frame
	local frame = Instance.new("Frame")
	frame.Name = "ActionMenu"
	frame.Size = UDim2.new(0.4, 0, 0.2, 0)
	frame.Position = UDim2.new(0.55, 0, 0.78, 0)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	frame.BackgroundTransparency = 0.1
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(0.5, -10, 0.5, -10)
	layout.CellPadding = UDim2.new(0, 10, 0, 10)
	layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
	layout.VerticalAlignment = Enum.VerticalAlignment.Center
	layout.Parent = frame

	local actions = {
		{Name = "Lutar", Icon = "⚔️", Color = Color3.fromRGB(220, 60, 60), Action = {Type = "Move"}},
		{Name = "Mochila", Icon = "🎒", Color = Color3.fromRGB(100, 150, 255), Action = {Type = "Item"}},
		{Name = "Criatura", Icon = "🔄", Color = Color3.fromRGB(255, 150, 50), Action = {Type = "Switch"}},
		{Name = "Fugir", Icon = "🏃", Color = Color3.fromRGB(150, 150, 170), Action = {Type = "Flee"}},
	}

	for _, act in ipairs(actions) do
		local btn = Instance.new("TextButton")
		btn.Name = act.Name
		btn.BackgroundColor3 = act.Color
		btn.BorderSizePixel = 0
		btn.Text = act.Icon .. " " .. act.Name
		btn.TextColor3 = Color3.fromRGB(255, 255, 255)
		btn.TextScaled = true
		btn.Font = Enum.Font.GothamBold
		btn.Parent = frame

		local btnCorner = Instance.new("UICorner")
		btnCorner.CornerRadius = UDim.new(0, 10)
		btnCorner.Parent = btn

		btn.MouseButton1Click:Connect(function()
			BattleController.OnActionSelected(act.Action)
		end)
	end

	return frame
end

function BattleController.CreateMoveMenu(parent: Instance): Frame
	local frame = Instance.new("Frame")
	frame.Name = "MoveMenu"
	frame.Size = UDim2.new(0.4, 0, 0.3, 0)
	frame.Position = UDim2.new(0.55, 0, 0.68, 0)
	frame.BackgroundColor3 = Color3.fromRGB(25, 25, 40)
	frame.BackgroundTransparency = 0.1
	frame.BorderSizePixel = 0
	frame.Visible = false
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = frame

	-- Back button
	local backBtn = Instance.new("TextButton")
	backBtn.Name = "BackButton"
	backBtn.Size = UDim2.new(1, -20, 0, 35)
	backBtn.Position = UDim2.new(0, 10, 1, -45)
	backBtn.BackgroundColor3 = Color3.fromRGB(150, 150, 170)
	backBtn.BorderSizePixel = 0
	backBtn.Text = "← VOLTAR"
	backBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	backBtn.TextScaled = true
	backBtn.Font = Enum.Font.GothamBold
	backBtn.Parent = frame

	local backCorner = Instance.new("UICorner")
	backCorner.CornerRadius = UDim.new(0, 8)
	backCorner.Parent = backBtn

	backBtn.MouseButton1Click:Connect(function()
		frame.Visible = false
		if BattleUI.ActionMenu then
			BattleUI.ActionMenu.Visible = true
		end
	end)

	-- Moves container
	local movesFrame = Instance.new("ScrollingFrame")
	movesFrame.Name = "MovesContainer"
	movesFrame.Size = UDim2.new(1, -20, 1, -90)
	movesFrame.Position = UDim2.new(0, 10, 0, 10)
	movesFrame.BackgroundTransparency = 1
	movesFrame.BorderSizePixel = 0
	movesFrame.ScrollBarThickness = 4
	movesFrame.Parent = frame

	local movesLayout = Instance.new("UIListLayout")
	movesLayout.Padding = UDim.new(0, 8)
	movesLayout.Parent = movesFrame

	BattleUI.MovesContainer = movesFrame

	return frame
end

function BattleController.CreateBattleLog(parent: Instance): Frame
	local frame = Instance.new("Frame")
	frame.Name = "BattleLog"
	frame.Size = UDim2.new(0.9, 0, 0.15, 0)
	frame.Position = UDim2.new(0.05, 0, 0.82, 0)
	frame.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 10)
	corner.Parent = frame

	local logLabel = Instance.new("TextLabel")
	logLabel.Name = "LogText"
	logLabel.Size = UDim2.new(1, -20, 1, -10)
	logLabel.Position = UDim2.new(0, 10, 0, 5)
	logLabel.BackgroundTransparency = 1
	logLabel.Text = "O que " .. (CurrentBattle and CurrentBattle.PlayerCreature.SpeciesId or "?") .. " vai fazer?"
	logLabel.TextColor3 = Color3.fromRGB(220, 220, 240)
	logLabel.TextScaled = true
	logLabel.Font = Enum.Font.Gotham
	logLabel.TextXAlignment = Enum.TextXAlignment.Left
	logLabel.TextYAlignment = Enum.TextYAlignment.Top
	logLabel.Parent = frame

	return frame
end

function BattleController.CreateTurnTimer(parent: Instance): Frame
	local frame = Instance.new("Frame")
	frame.Name = "TurnTimer"
	frame.Size = UDim2.new(0, 60, 0, 60)
	frame.Position = UDim2.new(0.47, 0, 0.45, 0)
	frame.BackgroundTransparency = 1
	frame.Parent = parent

	local bg = Instance.new("Frame")
	bg.Size = UDim2.new(1, 0, 1, 0)
	bg.BackgroundColor3 = Color3.fromRGB(255, 200, 50)
	bg.BackgroundTransparency = 0.3
	bg.BorderSizePixel = 0
	bg.Parent = frame

	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(1, 0)
	bgCorner.Parent = bg

	local timerText = Instance.new("TextLabel")
	timerText.Name = "TimerText"
	timerText.Size = UDim2.new(1, 0, 1, 0)
	timerText.BackgroundTransparency = 1
	timerText.Text = tostring(TurnTimer)
	timerText.TextColor3 = Color3.fromRGB(255, 255, 255)
	timerText.TextScaled = true
	timerText.Font = Enum.Font.GothamBold
	timerText.Parent = frame

	BattleUI.TimerText = timerText

	return frame
end

function BattleController.CreateWeatherIndicator(parent: Instance, weather: Types.WeatherType)
	local frame = Instance.new("Frame")
	frame.Name = "WeatherIndicator"
	frame.Size = UDim2.new(0, 200, 0, 40)
	frame.Position = UDim2.new(0.5, -100, 0, 10)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 50)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 20)
	corner.Parent = frame

	local icons = {
		Sunny = "☀️",
		Rain = "🌧️",
		Sandstorm = "🌪️",
		Hail = "❄️",
		Fog = "🌫️",
		Windy = "💨",
	}

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = (icons[weather] or "") .. " " .. weather
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = frame
end

function BattleController.CreateBattleViewports(parent: Instance, battleData: Types.BattleData)
	-- Player creature viewport
	local playerViewport = Instance.new("ViewportFrame")
	playerViewport.Name = "PlayerViewport"
	playerViewport.Size = UDim2.new(0.25, 0, 0.35, 0)
	playerViewport.Position = UDim2.new(0.7, 0, 0.3, 0)
	playerViewport.BackgroundTransparency = 1
	playerViewport.Parent = parent

	local playerCamera = Instance.new("Camera")
	playerCamera.Parent = playerViewport
	playerViewport.CurrentCamera = playerCamera
	BattleUI.PlayerViewport = playerViewport

	-- Enemy creature viewport
	local enemyViewport = Instance.new("ViewportFrame")
	enemyViewport.Name = "EnemyViewport"
	enemyViewport.Size = UDim2.new(0.25, 0, 0.35, 0)
	enemyViewport.Position = UDim2.new(0.05, 0, 0.1, 0)
	enemyViewport.BackgroundTransparency = 1
	enemyViewport.Parent = parent

	local enemyCamera = Instance.new("Camera")
	enemyCamera.Parent = enemyViewport
	enemyViewport.CurrentCamera = enemyCamera
	BattleUI.EnemyViewport = enemyViewport

	-- Load models
	if battleData.PlayerCreature then
		BattleController.LoadBattleModel(battleData.PlayerCreature, playerViewport, true)
	end
	if battleData.EnemyCreature then
		BattleController.LoadBattleModel(battleData.EnemyCreature, enemyViewport, false)
	end
end

function BattleController.LoadBattleModel(creature: Types.CreatureData, viewport: ViewportFrame, isPlayer: boolean)
	-- Load from ReplicatedStorage.Assets.Creatures
	local model = ReplicatedStorage:FindFirstChild("Assets")
		and ReplicatedStorage.Assets:FindFirstChild("Creatures")
		and ReplicatedStorage.Assets.Creatures:FindFirstChild(creature.SpeciesId)

	if not model then
		model = BattleController.CreateBattlePlaceholder(creature)
	end

	local clone = model:Clone()
	clone.Name = "BattleModel"
	clone.Parent = viewport

	-- Position
	local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")
	if primaryPart then
		clone:PivotTo(CFrame.new(0, 0, 0))

		local camera = viewport.CurrentCamera
		if camera then
			local cf, size = clone:GetBoundingBox()
			local distance = size.Z * 2.5
			camera.CFrame = CFrame.new(cf.Position + Vector3.new(0, size.Y * 0.3, distance), cf.Position)
			camera.FieldOfView = 25
		end
	end

	-- Apply appearance
	BattleController.ApplyBattleAppearance(clone, creature)

	-- Play entrance animation
	BattleController.PlayEntranceAnimation(clone, isPlayer)
end

function BattleController.CreateBattlePlaceholder(creature: Types.CreatureData): Model
	local model = Instance.new("Model")
	model.Name = creature.SpeciesId

	local part = Instance.new("Part")
	part.Name = "Body"
	part.Size = Vector3.new(4, 4, 4)
	part.Shape = Enum.PartType.Ball
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = BattleController.GetElementColor(creature.Element1)
	part.Parent = model

	model.PrimaryPart = part

	return model
end

function BattleController.GetElementColor(element: Types.ElementType): Color3
	local colors = {
		Fire = Color3.fromRGB(255, 100, 50),
		Water = Color3.fromRGB(50, 150, 255),
		Nature = Color3.fromRGB(80, 200, 80),
		Earth = Color3.fromRGB(180, 140, 80),
		Air = Color3.fromRGB(180, 200, 255),
		Shadow = Color3.fromRGB(120, 60, 180),
		Light = Color3.fromRGB(255, 240, 180),
		Metal = Color3.fromRGB(180, 180, 200),
		Crystal = Color3.fromRGB(200, 220, 255),
	}
	return colors[element] or Color3.fromRGB(200, 200, 200)
end

function BattleController.ApplyBattleAppearance(model: Model, creature: Types.CreatureData)
	if creature.IsShiny then
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Material = Enum.Material.Neon
				local sparkles = Instance.new("ParticleEmitter")
				sparkles.Name = "ShinySparkles"
				sparkles.Color = ColorSequence.new(Color3.fromRGB(255, 255, 200))
				sparkles.Size = NumberSequence.new(0.3)
				sparkles.Lifetime = NumberRange.new(0.5, 1.5)
				sparkles.Rate = 30
				sparkles.Speed = NumberRange.new(2, 5)
				sparkles.SpreadAngle = Vector2.new(180, 180)
				sparkles.Parent = part
			end
		end
	end

	-- Status effect visuals
	if creature.StatusCondition ~= "None" then
		BattleController.ApplyStatusVisual(model, creature.StatusCondition)
	end
end

function BattleController.ApplyStatusVisual(model: Model, status: string)
	local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not primaryPart then return end

	local effects = {
		Burn = {Color = Color3.fromRGB(255, 80, 30), Particles = "Fire"},
		Poison = {Color = Color3.fromRGB(150, 50, 200), Particles = "Smoke"},
		Paralysis = {Color = Color3.fromRGB(255, 255, 100), Particles = "Sparkles"},
		Sleep = {Color = Color3.fromRGB(100, 100, 200), Particles = nil},
		Freeze = {Color = Color3.fromRGB(100, 200, 255), Particles = "Ice"},
	}

	local effect = effects[status]
	if not effect then return end

	-- Tint model
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Color = part.Color:Lerp(effect.Color, 0.3)
		end
	end

	-- Add particles
	if effect.Particles then
		local emitter = Instance.new("ParticleEmitter")
		emitter.Name = "StatusEffect"
		emitter.Color = ColorSequence.new(effect.Color)
		emitter.Size = NumberSequence.new(0.5)
		emitter.Lifetime = NumberRange.new(0.5, 1)
		emitter.Rate = 15
		emitter.Speed = NumberRange.new(1, 3)
		emitter.SpreadAngle = Vector2.new(180, 180)
		emitter.Parent = primaryPart
	end
end

function BattleController.PlayEntranceAnimation(model: Model, isPlayer: boolean)
	local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not primaryPart then return end

	local startPos = primaryPart.Position
	local endPos = startPos

	if isPlayer then
		startPos = startPos + Vector3.new(-20, 0, 0)
	else
		startPos = startPos + Vector3.new(20, 0, 0)
	end

	model:PivotTo(CFrame.new(startPos))

	local tween = TweenService:Create(primaryPart, TweenInfo.new(0.5, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		CFrame = CFrame.new(endPos)
	})
	tween:Play()
end

function BattleController.OnActionSelected(action: Types.BattleAction)
	if not IsPlayerTurn then return end

	if action.Type == "Move" then
		BattleController.ShowMoveMenu()
	elseif action.Type == "Item" then
		BattleController.OpenItemMenu()
	elseif action.Type == "Switch" then
		BattleController.OpenSwitchMenu()
	elseif action.Type == "Flee" then
		BattleController.AttemptFlee()
	end
end

function BattleController.ShowMoveMenu()
	if not CurrentBattle or not CurrentBattle.PlayerCreature then return end

	if BattleUI.ActionMenu then
		BattleUI.ActionMenu.Visible = false
	end

	if BattleUI.MoveMenu then
		BattleUI.MoveMenu.Visible = true
		BattleController.PopulateMoveMenu(CurrentBattle.PlayerCreature)
	end
end

function BattleController.PopulateMoveMenu(creature: Types.CreatureData)
	if not BattleUI.MovesContainer then return end

	-- Clear existing
	for _, child in ipairs(BattleUI.MovesContainer:GetChildren()) do
		if child:IsA("GuiObject") then child:Destroy() end
	end

	-- Add moves
	for i, moveSlot in ipairs(creature.Moves) do
		local moveConfig = Config.Moves[moveSlot.MoveId]
		if not moveConfig then continue end

		local moveFrame = Instance.new("Frame")
		moveFrame.Name = `Move_{i}`
		moveFrame.Size = UDim2.new(1, 0, 0, 50)
		moveFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
		moveFrame.BorderSizePixel = 0
		moveFrame.Parent = BattleUI.MovesContainer

		local corner = Instance.new("UICorner")
		corner.CornerRadius = UDim.new(0, 8)
		corner.Parent = moveFrame

		-- Move name and type
		local nameLabel = Instance.new("TextLabel")
		nameLabel.Size = UDim2.new(0.5, 0, 1, 0)
		nameLabel.BackgroundTransparency = 1
		nameLabel.Text = moveConfig.Name
		nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
		nameLabel.TextScaled = true
		nameLabel.Font = Enum.Font.GothamBold
		nameLabel.TextXAlignment = Enum.TextXAlignment.Left
		nameLabel.Parent = moveFrame

		-- Type tag
		local typeTag = Instance.new("TextLabel")
		typeTag.Size = UDim2.new(0, 80, 0, 25)
		typeTag.Position = UDim2.new(0.5, 5, 0.5, -12)
		typeTag.BackgroundColor3 = BattleController.GetElementColor(moveConfig.Type)
		typeTag.BorderSizePixel = 0
		typeTag.Text = Types.ElementDisplayNames[moveConfig.Type] or moveConfig.Type
		typeTag.TextColor3 = Color3.fromRGB(255, 255, 255)
		typeTag.TextScaled = true
		typeTag.Font = Enum.Font.GothamBold
		typeTag.Parent = moveFrame

		local tagCorner = Instance.new("UICorner")
		tagCorner.CornerRadius = UDim.new(0, 4)
		tagCorner.Parent = typeTag

		-- Category icon
		local catIcon = Instance.new("TextLabel")
		catIcon.Size = UDim2.new(0, 30, 0, 30)
		catIcon.Position = UDim2.new(0.5, 90, 0.5, -15)
		catIcon.BackgroundTransparency = 1
		catIcon.Text = moveConfig.Category == "Physical" and "👊" or moveConfig.Category == "Special" and "💫" or "🛡️"
		catIcon.TextScaled = true
		catIcon.Parent = moveFrame

		-- PP
		local ppLabel = Instance.new("TextLabel")
		ppLabel.Size = UDim2.new(0, 60, 1, 0)
		ppLabel.Position = UDim2.new(1, -65, 0, 0)
		ppLabel.BackgroundTransparency = 1
		ppLabel.Text = `PP {moveSlot.CurrentPP}/{moveSlot.MaxPP}`
		ppLabel.TextColor3 = moveSlot.CurrentPP > 0 and Color3.fromRGB(200, 200, 220) or Color3.fromRGB(220, 60, 60)
		ppLabel.TextScaled = true
		ppLabel.Font = Enum.Font.Gotham
		ppLabel.TextXAlignment = Enum.TextXAlignment.Right
		ppLabel.Parent = moveFrame

		-- Power/Accuracy
		local infoLabel = Instance.new("TextLabel")
		infoLabel.Size = UDim2.new(0.5, -5, 0, 20)
		infoLabel.Position = UDim2.new(0, 5, 1, -22)
		infoLabel.BackgroundTransparency = 1
		infoLabel.Text = `Poder: {moveConfig.Power or "-"}  Precisão: {moveConfig.Accuracy or "-"}`
		infoLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
		infoLabel.TextScaled = true
		infoLabel.Font = Enum.Font.Gotham
		infoLabel.TextXAlignment = Enum.TextXAlignment.Left
		infoLabel.Parent = moveFrame

		-- Click handler
		local btn = Instance.new("TextButton")
		btn.Size = UDim2.new(1, 0, 1, 0)
		btn.BackgroundTransparency = 1
		btn.Text = ""
		btn.Parent = moveFrame

		btn.MouseButton1Click:Connect(function()
			if moveSlot.CurrentPP > 0 then
				BattleController.SelectMove(i, moveSlot.MoveId)
			end
		end)

		btn.MouseEnter:Connect(function()
			TweenService:Create(moveFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(45, 45, 65)}):Play()
		end)
		btn.MouseLeave:Connect(function()
			TweenService:Create(moveFrame, TweenInfo.new(0.1), {BackgroundColor3 = Color3.fromRGB(35, 35, 55)}):Play()
		end)
	end
end

function BattleController.SelectMove(moveIndex: number, moveId: string)
	SelectedAction = {
		Type = "Move",
		MoveIndex = moveIndex,
		MoveId = moveId,
		Target = 2, -- Enemy
	}

	if BattleUI.MoveMenu then
		BattleUI.MoveMenu.Visible = false
	end

	if BattleUI.ActionMenu then
		BattleUI.ActionMenu.Visible = true
	end

	-- Send to server
	BattleController.SendAction(SelectedAction)
end

function BattleController.OpenItemMenu()
	print("[BattleController] Open item menu")
end

function BattleController.OpenSwitchMenu()
	print("[BattleController] Open switch menu")
end

function BattleController.AttemptFlee()
	if CurrentBattle then
		local remote = ReplicatedStorage:FindFirstChild("Remotes")
		local fleeRemote = remote and remote:FindFirstChild("BattleAction")
		if fleeRemote then
			fleeRemote:InvokeServer(CurrentBattle.Id, {Type = "Flee"})
		end
	end
end

function BattleController.SendAction(action: Types.BattleAction)
	if not CurrentBattle then return end

	local remote = ReplicatedStorage:FindFirstChild("Remotes")
	local battleRemote = remote and remote:FindFirstChild("BattleAction")
	if battleRemote then
		battleRemote:InvokeServer(CurrentBattle.Id, action)
	end
end

function BattleController.StartTurnTimer()
	if BattleUI.TimerText then
		BattleUI.TimerText.Text = tostring(TurnTimer)
	end

	task.spawn(function()
		while TurnTimer > 0 and CurrentBattle and IsPlayerTurn do
			task.wait(1)
			TurnTimer -= 1
			if BattleUI.TimerText then
				BattleUI.TimerText.Text = tostring(TurnTimer)
			end
		end

		if TurnTimer <= 0 and IsPlayerTurn and CurrentBattle then
			-- Auto-select first available move
			BattleController.AutoSelectMove()
		end
	end)
end

function BattleController.AutoSelectMove()
	if not CurrentBattle or not CurrentBattle.PlayerCreature then return end

	for i, moveSlot in ipairs(CurrentBattle.PlayerCreature.Moves) do
		if moveSlot.CurrentPP > 0 then
			BattleController.SelectMove(i, moveSlot.MoveId)
			return
		end
	end

	-- Struggle
	BattleController.SelectMove(1, "Struggle")
end

function BattleController.UpdateBattleUI(battleData: Types.BattleData)
	-- Update HP bars
	if BattleUI.PlayerSide and battleData.PlayerCreature then
		BattleController.UpdateCreatureSide(BattleUI.PlayerSide, battleData.PlayerCreature)
	end

	if BattleUI.EnemySide and battleData.EnemyCreature then
		BattleController.UpdateCreatureSide(BattleUI.EnemySide, battleData.EnemyCreature)
	end

	-- Update battle log
	if BattleUI.BattleLog then
		local logText = BattleUI.BattleLog:FindFirstChild("LogText")
		if logText and battleData.BattleLog and #battleData.BattleLog > 0 then
			logText.Text = battleData.BattleLog[#battleData.BattleLog]
		end
	end
end

function BattleController.UpdateCreatureSide(sideFrame: Frame, creature: Types.CreatureData)
	local hpBg = sideFrame:FindFirstChild("HpBg")
	if hpBg then
		local hpFill = hpBg:FindFirstChild("HpFill")
		local hpText = hpBg:FindFirstChild("HpText")

		if hpFill then
			TweenService:Create(hpFill, TweenInfo.new(0.5), {
				Size = UDim2.new(creature.CurrentHP / creature.MaxHP, 0, 1, 0),
				BackgroundColor3 = BattleController.GetHPColor(creature.CurrentHP / creature.MaxHP)
			}):Play()
		end

		if hpText then
			hpText.Text = `{creature.CurrentHP}/{creature.MaxHP}`
		end
	end

	-- Update status
	local statusFrame = sideFrame:FindFirstChild("StatusFrame")
	if statusFrame then
		BattleController.UpdateStatusIcons(statusFrame, creature)
	end
end

function BattleController.UpdateStatusIcons(statusFrame: Frame, creature: Types.CreatureData)
	-- Clear existing status icons (except gender/shiny)
	for _, child in ipairs(statusFrame:GetChildren()) do
		if child:IsA("TextLabel") and not child.Text:match("[♂♀✨]") then
			child:Destroy()
		end
	end

	if creature.StatusCondition ~= "None" then
		local statusIcons = {
			Burn = "🔥",
			Poison = "☠️",
			Paralysis = "⚡",
			Sleep = "💤",
			Freeze = "🧊",
			Confusion = "💫",
		}

		local icon = statusIcons[creature.StatusCondition] or "❓"
		local label = Instance.new("TextLabel")
		label.Size = UDim2.new(0, 30, 1, 0)
		label.BackgroundTransparency = 1
		label.Text = icon
		label.TextScaled = true
		label.Parent = statusFrame
	end
end

function BattleController.DestroyBattleUI()
	for _, ui in pairs(BattleUI) do
		if ui and ui.Destroy then
			ui:Destroy()
		end
	end
	BattleUI = {}
end

-- Animation playback
function BattleController.PlayMoveAnimation(moveId: string, attackerSide: string, targetSide: string)
	local moveConfig = Config.Moves[moveId]
	if not moveConfig then return end

	-- Play move animation based on category
	if moveConfig.Category == "Physical" then
		BattleController.PlayPhysicalMoveAnimation(attackerSide, targetSide)
	elseif moveConfig.Category == "Special" then
		BattleController.PlaySpecialMoveAnimation(moveConfig.Type, attackerSide, targetSide)
	else
		BattleController.PlayStatusMoveAnimation(attackerSide, targetSide)
	end
end

function BattleController.PlayPhysicalMoveAnimation(attackerSide: string, targetSide: string)
	local viewport = attackerSide == "Player" and BattleUI.PlayerViewport or BattleUI.EnemyViewport
	local targetViewport = targetSide == "Player" and BattleUI.PlayerViewport or BattleUI.EnemyViewport

	local attackerModel = viewport and viewport:FindFirstChild("BattleModel")
	local targetModel = targetViewport and targetViewport:FindFirstChild("BattleModel")

	if not attackerModel or not targetModel then return end

	local attackerPart = attackerModel.PrimaryPart
	local targetPart = targetModel.PrimaryPart

	if not attackerPart or not targetPart then return end

	-- Attacker lunge
	local originalPos = attackerPart.Position
	local targetPos = targetPart.Position
	local direction = (targetPos - originalPos).Unit

	local lungeTween = TweenService:Create(attackerPart, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = CFrame.new(originalPos + direction * 5)
	})
	lungeTween:Play()

	lungeTween.Completed:Wait()

	-- Hit effect on target
	BattleController.CreateHitEffect(targetPart, "Physical")

	-- Return
	local returnTween = TweenService:Create(attackerPart, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = CFrame.new(originalPos)
	})
	returnTween:Play()
end

function BattleController.PlaySpecialMoveAnimation(elementType: Types.ElementType, attackerSide: string, targetSide: string)
	-- Create projectile/beam effect based on element
	local viewport = attackerSide == "Player" and BattleUI.PlayerViewport or BattleUI.EnemyViewport
	local targetViewport = targetSide == "Player" and BattleUI.PlayerViewport or BattleUI.EnemyViewport

	local targetModel = targetViewport and targetViewport:FindFirstChild("BattleModel")
	if not targetModel then return end

	local targetPart = targetModel.PrimaryPart
	if not targetPart then return end

	-- Element-specific effects
	BattleController.CreateElementalEffect(targetPart, elementType)
end

function BattleController.PlayStatusMoveAnimation(attackerSide: string, targetSide: string)
	-- Simple glow effect
	local targetViewport = targetSide == "Player" and BattleUI.PlayerViewport or BattleUI.EnemyViewport
	local targetModel = targetViewport and targetViewport:FindFirstChild("BattleModel")

	if targetModel then
		local targetPart = targetModel.PrimaryPart
		if targetPart then
			BattleController.CreateHitEffect(targetPart, "Status")
		end
	end
end

function BattleController.CreateHitEffect(targetPart: BasePart, hitType: string)
	local effect = Instance.new("Part")
	effect.Name = "HitEffect"
	effect.Size = Vector3.new(1, 1, 1)
	effect.Transparency = 1
	effect.Anchored = true
	effect.CanCollide = false
	effect.CFrame = targetPart.CFrame
	effect.Parent = targetPart.Parent

	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = hitType == "Physical" and ColorSequence.new(Color3.fromRGB(255, 200, 100))
		or hitType == "Status" and ColorSequence.new(Color3.fromRGB(100, 200, 255))
		or ColorSequence.new(Color3.fromRGB(255, 100, 100))
	emitter.Size = NumberSequence.new(0, 2)
	emitter.Lifetime = NumberRange.new(0.3, 0.6)
	emitter.Rate = 0
	emitter.Speed = NumberRange.new(5, 15)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Parent = effect

	emitter:Emit(20)

	task.delay(1, function()
		effect:Destroy()
	end)
end

function BattleController.CreateElementalEffect(targetPart: BasePart, element: Types.ElementType)
	local colors = {
		Fire = Color3.fromRGB(255, 100, 30),
		Water = Color3.fromRGB(50, 150, 255),
		Nature = Color3.fromRGB(80, 200, 80),
		Earth = Color3.fromRGB(180, 140, 80),
		Air = Color3.fromRGB(180, 220, 255),
		Shadow = Color3.fromRGB(150, 80, 220),
		Light = Color3.fromRGB(255, 240, 180),
		Metal = Color3.fromRGB(200, 200, 220),
		Crystal = Color3.fromRGB(180, 220, 255),
	}

	local color = colors[element] or Color3.fromRGB(255, 255, 255)

	local effect = Instance.new("Part")
	effect.Name = "ElementalEffect"
	effect.Size = Vector3.new(1, 1, 1)
	effect.Transparency = 1
	effect.Anchored = true
	effect.CanCollide = false
	effect.CFrame = targetPart.CFrame
	effect.Parent = targetPart.Parent

	local emitter = Instance.new("ParticleEmitter")
	emitter.Color = ColorSequence.new(color)
	emitter.Size = NumberSequence.new(0.5, 3)
	emitter.Lifetime = NumberRange.new(0.5, 1.5)
	emitter.Rate = 0
	emitter.Speed = NumberRange.new(10, 25)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Parent = effect

	emitter:Emit(30)

	task.delay(1.5, function()
		effect:Destroy()
	end)
end

function BattleController.PlayFaintAnimation(creatureSide: string)
	local viewport = creatureSide == "Player" and BattleUI.PlayerViewport or BattleUI.EnemyViewport
	local model = viewport and viewport:FindFirstChild("BattleModel")

	if model then
		local primaryPart = model.PrimaryPart
		if primaryPart then
			-- Fall over animation
			local tween = TweenService:Create(primaryPart, TweenInfo.new(1, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
				CFrame = primaryPart.CFrame * CFrame.Angles(math.rad(90), 0, 0),
				Transparency = 1
			})
			tween:Play()
		end
	end
end

return BattleController