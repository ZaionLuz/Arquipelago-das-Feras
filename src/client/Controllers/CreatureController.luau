--!strict
-- CreatureController.lua - Controlador de criaturas (party, detalhes, evolução)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")

local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local MathUtil = require(ReplicatedStorage.Shared.Util.Math)
local TableUtil = require(ReplicatedStorage.Shared.Util.Table)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local CreatureController = {}

-- Events
CreatureController.OnPartyChanged = Signal.New()
CreatureController.OnCreatureSelected = Signal.New()
CreatureController.OnCreatureCaptured = Signal.New()
CreatureController.OnCreatureEvolved = Signal.New()
CreatureController.OnCreatureLevelUp = Signal.New()
CreatureController.OnCreatureUpdated = Signal.New()

-- State
local CurrentParty: {Types.CreatureData} = {}
local CurrentStorage: {{Types.CreatureData}} = {}
local SelectedCreature: Types.CreatureData?
local ViewportFrames = {} :: {[string]: ViewportFrame}
local CreatureModels = {} :: {[string]: Model}

-- Initialize
function CreatureController.Initialize(playerData: Types.PlayerData)
	print("[CreatureController] Initializing...")

	-- Load initial party data
	CreatureController.RefreshParty()
	CreatureController.RefreshStorage()

	print("[CreatureController] Initialized")
end

-- Refresh party from server
function CreatureController.RefreshParty()
	-- In real implementation, this would invoke server
	-- For now, using mock data
	task.spawn(function()
		task.wait(0.5)
		CreatureController.OnPartyChanged:Fire(CurrentParty)
	end)
end

function CreatureController.RefreshStorage()
	task.spawn(function()
		task.wait(0.5)
		-- Storage refresh
	end)
end

-- Party management
function CreatureController.OnPartyChanged(partySummary: any)
	CurrentParty = partySummary.Party or {}
	CreatureController.OnPartyChanged:Fire(partySummary)
end

function CreatureController.GetParty(): {Types.CreatureData}
	return CurrentParty
end

function CreatureController.GetStorage(): {{Types.CreatureData}}
	return CurrentStorage
end

function CreatureController.GetCreatureAt(index: number): Types.CreatureData?
	return CurrentParty[index]
end

-- Creature selection
function CreatureController.SelectCreature(creature: Types.CreatureData)
	SelectedCreature = creature
	CreatureController.OnCreatureSelected:Fire(creature)
end

function CreatureController.GetSelectedCreature(): Types.CreatureData?
	return SelectedCreature
end

-- Create creature model for ViewportFrame
function CreatureController.CreateCreatureViewport(creature: Types.CreatureData, parent: Instance): ViewportFrame
	local viewport = Instance.new("ViewportFrame")
	viewport.Name = `Viewport_{creature.Id}`
	viewport.Size = UDim2.new(1, 0, 1, 0)
	viewport.BackgroundTransparency = 1
	viewport.CurrentCamera = nil
	viewport.Parent = parent

	-- Create camera
	local camera = Instance.new("Camera")
	camera.Name = "ViewportCamera"
	camera.Parent = viewport
	viewport.CurrentCamera = camera

	-- Load creature model
	CreatureController.LoadCreatureModel(creature, viewport)

	ViewportFrames[creature.Id] = viewport

	return viewport
end

function CreatureController.LoadCreatureModel(creature: Types.CreatureData, viewport: ViewportFrame)
	-- Get model from ReplicatedStorage or create placeholder
	local modelPath = `ReplicatedStorage.Assets.Creatures.{creature.SpeciesId}`
	local model = ReplicatedStorage:FindFirstChild("Assets")
		and ReplicatedStorage.Assets:FindFirstChild("Creatures")
		and ReplicatedStorage.Assets.Creatures:FindFirstChild(creature.SpeciesId)

	if not model then
		-- Create placeholder
		model = CreatureController.CreatePlaceholderModel(creature)
	end

	local clone = model:Clone()
	clone.Name = creature.Id
	clone.Parent = viewport

	-- Position model
	local primaryPart = clone.PrimaryPart or clone:FindFirstChildWhichIsA("BasePart")
	if primaryPart then
		clone:PivotTo(CFrame.new(0, 0, 0))

		-- Setup camera
		local camera = viewport.CurrentCamera
		if camera then
			local cf, size = clone:GetBoundingBox()
			camera.CFrame = CFrame.new(cf.Position + Vector3.new(0, size.Y * 0.5, size.Z * 2), cf.Position)
			camera.FieldOfView = 30
		end
	end

	-- Apply color variation based on IVs/Shiny
	CreatureController.ApplyCreatureAppearance(clone, creature)

	-- Animate
	CreatureController.PlayIdleAnimation(clone)

	CreatureModels[creature.Id] = clone

	return clone
end

function CreatureController.CreatePlaceholderModel(creature: Types.CreatureData): Model
	local model = Instance.new("Model")
	model.Name = creature.SpeciesId

	-- Create a simple colored part based on creature type
	local part = Instance.new("Part")
	part.Name = "Body"
	part.Size = Vector3.new(3, 3, 3)
	part.Shape = Enum.PartType.Ball
	part.Anchored = true
	part.CanCollide = false
	part.Material = Enum.Material.Neon
	part.Color = CreatureController.GetElementColor(creature.Element1)
	part.Parent = model

	model.PrimaryPart = part

	-- Add element indicator
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ElementIndicator"
	billboard.Size = UDim2.new(0, 100, 0, 30)
	billboard.StudsOffset = Vector3.new(0, 3, 0)
	billboard.Adornee = part
	billboard.Parent = model

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = Types.ElementDisplayNames[creature.Element1] or creature.Element1
	label.TextColor3 = CreatureController.GetElementColor(creature.Element1)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = billboard

	return model
end

function CreatureController.GetElementColor(element: Types.ElementType): Color3
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

function CreatureController.ApplyCreatureAppearance(model: Model, creature: Types.CreatureData)
	-- Apply shiny effect
	if creature.IsShiny then
		for _, part in ipairs(model:GetDescendants()) do
			if part:IsA("BasePart") then
				part.Material = Enum.Material.Neon
				local sparkles = Instance.new("ParticleEmitter")
				sparkles.Name = "ShinySparkles"
				sparkles.Color = ColorSequence.new(Color3.fromRGB(255, 255, 200))
				sparkles.Size = NumberSequence.new(0.2)
				sparkles.Lifetime = NumberRange.new(0.5, 1)
				sparkles.Rate = 20
				sparkles.Speed = NumberRange.new(1, 3)
				sparkles.SpreadAngle = Vector2.new(180, 180)
				sparkles.Parent = part
			end
		end
	end

	-- Apply size based on stage
	local sizeMultiplier = 1
	if creature.GrowthStage == "Filhote" then
		sizeMultiplier = 0.5
	elseif creature.GrowthStage == "Juvenil" then
		sizeMultiplier = 0.75
	elseif creature.GrowthStage == "Adulto" then
		sizeMultiplier = 1.0
	elseif creature.GrowthStage == "Lendário" then
		sizeMultiplier = 1.3
	end

	model:ScaleTo(model:GetScale() * sizeMultiplier)
end

function CreatureController.PlayIdleAnimation(model: Model)
	-- Simple bobbing animation
	local primaryPart = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	if not primaryPart then return end

	local originalPos = primaryPart.Position

	task.spawn(function()
		while model.Parent do
			local t = tick() * 2
			local offset = math.sin(t) * 0.3
			if model.PrimaryPart then
				model:PivotTo(CFrame.new(originalPos + Vector3.new(0, offset, 0)))
			else
				primaryPart.CFrame = CFrame.new(originalPos + Vector3.new(0, offset, 0))
			end
			task.wait(0.03)
		end
	end)
end

-- Creature stats calculation display
function CreatureController.GetDisplayStats(creature: Types.CreatureData): {[string]: number}
	local baseStats = Config.SpeciesList[creature.SpeciesId]?.BaseStats or {}

	return {
		HP = MathUtil.CalculateHP(baseStats.HP or 50, creature.IVs.HP, creature.EVs.HP, creature.Level, creature.Nature),
		Attack = MathUtil.CalculateStat(baseStats.Attack or 50, creature.IVs.Attack, creature.EVs.Attack, creature.Level, creature.Nature, "Attack"),
		Defense = MathUtil.CalculateStat(baseStats.Defense or 50, creature.IVs.Defense, creature.EVs.Defense, creature.Level, creature.Nature, "Defense"),
		SpAttack = MathUtil.CalculateStat(baseStats.SpAttack or 50, creature.IVs.SpAttack, creature.EVs.SpAttack, creature.Level, creature.Nature, "SpAttack"),
		SpDefense = MathUtil.CalculateStat(baseStats.SpDefense or 50, creature.IVs.SpDefense, creature.EVs.SpDefense, creature.Level, creature.Nature, "SpDefense"),
		Speed = MathUtil.CalculateStat(baseStats.Speed or 50, creature.IVs.Speed, creature.EVs.Speed, creature.Level, creature.Nature, "Speed"),
	}
end

function CreatureController.GetStatBars(creature: Types.CreatureData): {[string]: number}
	local stats = CreatureController.GetDisplayStats(creature)
	local bars = {}

	for stat, value in pairs(stats) do
		bars[stat] = math.clamp(value / 255, 0, 1) -- Normalized for UI bars
	end

	return bars
end

-- Evolution
function CreatureController.OnCreatureEvolved(creature: Types.CreatureData)
	CreatureController.OnCreatureEvolved:Fire(creature)

	-- Refresh viewport if viewing this creature
	if ViewportFrames[creature.Id] then
		local viewport = ViewportFrames[creature.Id]
		local oldModel = CreatureModels[creature.Id]
		if oldModel then oldModel:Destroy() end
		CreatureController.LoadCreatureModel(creature, viewport)
	end
end

function CreatureController.CanEvolve(creature: Types.CreatureData): {CanEvolve: boolean, Method: string?, TargetSpecies: string?, TargetName: string?}
	-- This would call EvolutionSystem on server
	-- For now, return mock
	return {
		CanEvolve = false,
		Method = nil,
		TargetSpecies = nil,
		TargetName = nil,
	}
end

function CreatureController.RequestEvolution(creatureId: string)
	-- Would invoke server remote
	print("[CreatureController] Requesting evolution for:", creatureId)
end

-- Moves
function CreatureController.GetLearnableMoves(creature: Types.CreatureData): {Types.MoveData}
	local speciesData = Config.SpeciesList[creature.SpeciesId]
	if not speciesData or not speciesData.Learnset then return {} end

	local learnable = {}
	for _, moveLearn in ipairs(speciesData.Learnset) do
		if moveLearn.Level <= creature.Level then
			local moveConfig = Config.Moves[moveLearn.MoveId]
			if moveConfig then
				table.insert(learnable, moveConfig)
			end
		end
	end

	return learnable
end

function CreatureController.CanLearnMove(creature: Types.CreatureData, moveId: string): boolean
	local learnable = CreatureController.GetLearnableMoves(creature)
	for _, move in ipairs(learnable) do
		if move.Id == moveId then
			return true
		end
	end
	return false
end

function CreatureController.LearnMove(creatureId: string, moveId: string, replaceIndex: number?)
	-- Would invoke server remote
	print("[CreatureController] Learning move:", moveId, "for:", creatureId)
end

-- Capture animation
function CreatureController.OnCreatureCaptured(creature: Types.CreatureData)
	CreatureController.OnCreatureCaptured:Fire(creature)
end

-- Level up
function CreatureController.OnCreatureLevelUp(creature: Types.CreatureData, oldLevel: number, newLevel: number)
	CreatureController.OnCreatureLevelUp:Fire(creature, oldLevel, newLevel)

	-- Check for new moves
	local newMoves = {}
	local speciesData = Config.SpeciesList[creature.SpeciesId]
	if speciesData and speciesData.Learnset then
		for _, moveLearn in ipairs(speciesData.Learnset) do
			if moveLearn.Level > oldLevel and moveLearn.Level <= newLevel then
				table.insert(newMoves, moveLearn.MoveId)
			end
		end
	end

	if #newMoves > 0 then
		-- Notify UI about new moves
		CreatureController.OnCreatureUpdated:Fire(creature, {NewMoves = newMoves})
	end
end

-- Creature info for detail screen
function CreatureController.GetCreatureDetailInfo(creature: Types.CreatureData): any
	local speciesData = Config.SpeciesList[creature.SpeciesId]
	local displayStats = CreatureController.GetDisplayStats(creature)
	local statBars = CreatureController.GetStatBars(creature)
	local learnableMoves = CreatureController.GetLearnableMoves(creature)
	local evolutionInfo = CreatureController.CanEvolve(creature)

	return {
		Creature = creature,
		SpeciesData = speciesData,
		DisplayStats = displayStats,
		StatBars = statBars,
		LearnableMoves = learnableMoves,
		CurrentMoves = creature.Moves,
		EvolutionInfo = evolutionInfo,
		IVs = creature.IVs,
		EVs = creature.EVs,
		Nature = creature.Nature,
		Friendship = creature.Friendship,
		Experience = creature.Experience,
		NextLevelExp = MathUtil.GetExpForLevel(creature.Level + 1, speciesData?.GrowthRate or "MediumFast"),
	}
end

-- Create creature card for party UI
function CreatureController.CreateCreatureCard(creature: Types.CreatureData, parent: Instance, onClick: (Types.CreatureData) -> ()): Frame
	local card = Instance.new("Frame")
	card.Name = `Card_{creature.Id}`
	card.Size = UDim2.new(0, 280, 0, 160)
	card.BackgroundColor3 = Color3.fromRGB(35, 35, 55)
	card.BorderSizePixel = 0
	card.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = card

	local stroke = Instance.new("UIStroke")
	stroke.Color = CreatureController.GetElementColor(creature.Element1)
	stroke.Transparency = 0.5
	stroke.Thickness = 2
	stroke.Parent = card

	-- Viewport for 3D model
	local viewport = CreatureController.CreateCreatureViewport(creature, card)
	viewport.Size = UDim2.new(0.4, 0, 1, -20)
	viewport.Position = UDim2.new(0, 10, 0, 10)

	-- Info panel
	local infoPanel = Instance.new("Frame")
	infoPanel.Name = "InfoPanel"
	infoPanel.Size = UDim2.new(0.55, 0, 1, -20)
	infoPanel.Position = UDim2.new(0.42, 0, 0, 10)
	infoPanel.BackgroundTransparency = 1
	infoPanel.Parent = card

	-- Name and level
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 30)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = (creature.Nickname ~= "" and creature.Nickname or speciesData?.Name or creature.SpeciesId) .. `  Lv.{creature.Level}`
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = infoPanel

	-- Species name if nicknamed
	if creature.Nickname ~= "" and speciesData then
		local speciesLabel = Instance.new("TextLabel")
		speciesLabel.Size = UDim2.new(1, 0, 0, 20)
		speciesLabel.Position = UDim2.new(0, 0, 0, 30)
		speciesLabel.BackgroundTransparency = 1
		speciesLabel.Text = speciesData.Name
		speciesLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
		speciesLabel.TextScaled = true
		speciesLabel.Font = Enum.Font.Gotham
		speciesLabel.TextXAlignment = Enum.TextXAlignment.Left
		speciesLabel.Parent = infoPanel
	end

	-- Elements
	local elementFrame = Instance.new("Frame")
	elementFrame.Size = UDim2.new(1, 0, 0, 25)
	elementFrame.Position = UDim2.new(0, 0, 0, 55)
	elementFrame.BackgroundTransparency = 1
	elementFrame.Parent = infoPanel

	local elementLayout = Instance.new("UIListLayout")
	elementLayout.FillDirection = Enum.FillDirection.Horizontal
	elementLayout.Padding = UDim.new(0, 5)
	elementLayout.Parent = elementFrame

	for _, element in ipairs({creature.Element1, creature.Element2}) do
		if element then
			local elementTag = Instance.new("TextLabel")
			elementTag.Size = UDim2.new(0, 60, 1, 0)
			elementTag.BackgroundColor3 = CreatureController.GetElementColor(element)
			elementTag.BorderSizePixel = 0
			elementTag.Text = Types.ElementDisplayNames[element] or element
			elementTag.TextColor3 = Color3.fromRGB(255, 255, 255)
			elementTag.TextScaled = true
			elementTag.Font = Enum.Font.GothamBold
			elementTag.Parent = elementFrame

			local tagCorner = Instance.new("UICorner")
			tagCorner.CornerRadius = UDim.new(0, 4)
			tagCorner.Parent = elementTag
		end
	end

	-- HP Bar
	local hpFrame = Instance.new("Frame")
	hpFrame.Size = UDim2.new(1, 0, 0, 20)
	hpFrame.Position = UDim2.new(0, 0, 1, -45)
	hpFrame.BackgroundTransparency = 1
	hpFrame.Parent = infoPanel

	local hpLabel = Instance.new("TextLabel")
	hpLabel.Size = UDim2.new(0, 30, 1, 0)
	hpLabel.BackgroundTransparency = 1
	hpLabel.Text = "HP"
	hpLabel.TextColor3 = Color3.fromRGB(200, 200, 220)
	hpLabel.TextScaled = true
	hpLabel.Font = Enum.Font.Gotham
	hpLabel.TextXAlignment = Enum.TextXAlignment.Left
	hpLabel.Parent = hpFrame

	local hpBarBg = Instance.new("Frame")
	hpBarBg.Size = UDim2.new(1, -35, 0, 12)
	hpBarBg.Position = UDim2.new(0, 35, 0, 4)
	hpBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	hpBarBg.BorderSizePixel = 0
	hpBarBg.Parent = hpFrame

	local hpBarCorner = Instance.new("UICorner")
	hpBarCorner.CornerRadius = UDim.new(1, 0)
	hpBarCorner.Parent = hpBarBg

	local hpBarFill = Instance.new("Frame")
	hpBarFill.Name = "Fill"
	hpBarFill.Size = UDim2.new(creature.CurrentHP / creature.MaxHP, 0, 1, 0)
	hpBarFill.BackgroundColor3 = Color3.fromRGB(60, 200, 100)
	hpBarFill.BorderSizePixel = 0
	hpBarFill.Parent = hpBarBg

	local hpFillCorner = Instance.new("UICorner")
	hpFillCorner.CornerRadius = UDim.new(1, 0)
	hpFillCorner.Parent = hpBarFill

	local hpText = Instance.new("TextLabel")
	hpText.Size = UDim2.new(1, -35, 1, 0)
	hpText.Position = UDim2.new(0, 35, 0, 0)
	hpText.BackgroundTransparency = 1
	hpText.Text = `{creature.CurrentHP}/{creature.MaxHP}`
	hpText.TextColor3 = Color3.fromRGB(255, 255, 255)
	hpText.TextScaled = true
	hpText.Font = Enum.Font.GothamBold
	hpText.TextXAlignment = Enum.TextXAlignment.Right
	hpText.Parent = hpFrame

	-- XP Bar
	local xpFrame = Instance.new("Frame")
	xpFrame.Size = UDim2.new(1, 0, 0, 15)
	xpFrame.Position = UDim2.new(0, 0, 1, -25)
	xpFrame.BackgroundTransparency = 1
	xpFrame.Parent = infoPanel

	local xpBarBg = Instance.new("Frame")
	xpBarBg.Size = UDim2.new(1, 0, 0, 6)
	xpBarBg.Position = UDim2.new(0, 0, 0, 5)
	xpBarBg.BackgroundColor3 = Color3.fromRGB(50, 50, 60)
	xpBarBg.BorderSizePixel = 0
	xpBarBg.Parent = xpFrame

	local xpBarCorner = Instance.new("UICorner")
	xpBarCorner.CornerRadius = UDim.new(1, 0)
	xpBarCorner.Parent = xpBarBg

	local speciesData = Config.SpeciesList[creature.SpeciesId]
	local currentLevelExp = MathUtil.GetExpForLevel(creature.Level, speciesData?.GrowthRate or "MediumFast")
	local nextLevelExp = MathUtil.GetExpForLevel(creature.Level + 1, speciesData?.GrowthRate or "MediumFast")
	local expProgress = (creature.Experience - currentLevelExp) / (nextLevelExp - currentLevelExp)

	local xpBarFill = Instance.new("Frame")
	xpBarFill.Size = UDim2.new(math.clamp(expProgress, 0, 1), 0, 1, 0)
	xpBarFill.BackgroundColor3 = Color3.fromRGB(100, 150, 255)
	xpBarFill.BorderSizePixel = 0
	xpBarFill.Parent = xpBarBg

	local xpFillCorner = Instance.new("UICorner")
	xpFillCorner.CornerRadius = UDim.new(1, 0)
	xpFillCorner.Parent = xpBarFill

	-- Shiny indicator
	if creature.IsShiny then
		local shinyTag = Instance.new("TextLabel")
		shinyTag.Size = UDim2.new(0, 60, 0, 20)
		shinyTag.Position = UDim2.new(1, -65, 0, 5)
		shinyTag.BackgroundColor3 = Color3.fromRGB(255, 215, 0)
		shinyTag.BorderSizePixel = 0
		shinyTag.Text = "✨ SHINY"
		shinyTag.TextColor3 = Color3.fromRGB(50, 40, 0)
		shinyTag.TextScaled = true
		shinyTag.Font = Enum.Font.GothamBold
		shinyTag.Parent = card

		local shinyCorner = Instance.new("UICorner")
		shinyCorner.CornerRadius = UDim.new(0, 4)
		shinyCorner.Parent = shinyTag
	end

	-- Click handler
	local btn = Instance.new("TextButton")
	btn.Size = UDim2.new(1, 0, 1, 0)
	btn.BackgroundTransparency = 1
	btn.Text = ""
	btn.Parent = card

	btn.MouseButton1Click:Connect(function()
		onClick(creature)
	end)

	btn.MouseEnter:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(45, 45, 65)}):Play()
	end)

	btn.MouseLeave:Connect(function()
		TweenService:Create(card, TweenInfo.new(0.15), {BackgroundColor3 = Color3.fromRGB(35, 35, 55)}):Play()
	end)

	return card
end

-- Cleanup
function CreatureController.Cleanup()
	for _, viewport in pairs(ViewportFrames) do
		viewport:Destroy()
	end
	for _, model in pairs(CreatureModels) do
		model:Destroy()
	end
	ViewportFrames = {}
	CreatureModels = {}
end

return CreatureController