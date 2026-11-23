--!strict
-- QuestController.lua - Controller de missões/quests no cliente

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local RemoteClient = require(script.Parent.RemoteClient)
local UIController = require(script.Parent.UIController)
local Config = require(ReplicatedStorage.Shared.Config)
local Types = require(ReplicatedStorage.Shared.Types)

local QuestController = {}

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

-- State
local ActiveQuests = {} :: {Types.QuestData}
local AvailableQuests = {} :: {Types.QuestData}
local CurrentNPCId = ""
local QuestUIs = {} :: {[string]: ScreenGui}

-- Initialize
function QuestController.Initialize()
	print("[QuestController] Initializing...")

	-- Listen for quest progress updates
	RemoteClient.OnQuestProgress(function(quest, objective)
		QuestController.OnQuestProgress(quest, objective)
	end)

	-- Create quest UI
	QuestController.CreateQuestUI()

	print("[QuestController] Initialized")
end

-- Create main quest UI
function QuestController.CreateQuestUI()
	local screenGui = Instance.new("ScreenGui")
	screenGui.Name = "QuestUI"
	screenGui.ResetOnSpawn = false
	screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
	screenGui.Parent = PlayerGui

	-- Quest Tracker (lado direito da tela)
	local trackerFrame = Instance.new("Frame")
	trackerFrame.Name = "QuestTracker"
	trackerFrame.Size = UDim2.new(0, 300, 0, 400)
	trackerFrame.Position = UDim2.new(1, -320, 0.5, -200)
	trackerFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	trackerFrame.BackgroundTransparency = 0.1
	trackerFrame.BorderSizePixel = 0
	trackerFrame.Visible = false
	trackerFrame.Parent = screenGui

	local trackerCorner = Instance.new("UICorner")
	trackerCorner.CornerRadius = UDim.new(0, 12)
	trackerCorner.Parent = trackerFrame

	local trackerStroke = Instance.new("UIStroke")
	trackerStroke.Color = Color3.fromRGB(100, 150, 255)
	trackerStroke.Transparency = 0.5
	trackerStroke.Thickness = 2
	trackerStroke.Parent = trackerFrame

	-- Title
	local titleLabel = Instance.new("TextLabel")
	titleLabel.Name = "Title"
	titleLabel.Size = UDim2.new(1, -20, 0, 40)
	titleLabel.Position = UDim2.new(0, 10, 0, 10)
	titleLabel.BackgroundTransparency = 1
	titleLabel.Text = "MISSÕES ATIVAS"
	titleLabel.TextColor3 = Color3.fromRGB(100, 200, 255)
	titleLabel.TextScaled = true
	titleLabel.Font = Enum.Font.GothamBold
	titleLabel.TextXAlignment = Enum.TextXAlignment.Left
	titleLabel.Parent = trackerFrame

	-- Quest list
	local questList = Instance.new("ScrollingFrame")
	questList.Name = "QuestList"
	questList.Size = UDim2.new(1, -20, 1, -60)
	questList.Position = UDim2.new(0, 10, 0, 50)
	questList.BackgroundTransparency = 1
	questList.ScrollBarThickness = 6
	questList.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
	questList.CanvasSize = UDim2.new(0, 0, 0, 0)
	questList.Parent = trackerFrame

	local listLayout = Instance.new("UIListLayout")
	listLayout.Padding = UDim.new(0, 10)
	listLayout.SortOrder = Enum.SortOrder.LayoutOrder
	listLayout.Parent = questList

	QuestUIs.Tracker = screenGui
	QuestUIs.TrackerFrame = trackerFrame
	QuestUIs.QuestList = questList

	-- Quest Detail Modal
	QuestController.CreateQuestDetailUI(screenGui)

	-- Quest NPC Dialog UI
	QuestController.CreateNPCDialogUI(screenGui)
end

-- Create quest detail modal
function QuestController.CreateQuestDetailUI(parent: ScreenGui)
	local modal = Instance.new("Frame")
	modal.Name = "QuestDetailModal"
	modal.Size = UDim2.new(0, 500, 0, 500)
	modal.Position = UDim2.new(0.5, -250, 0.5, -250)
	modal.BackgroundColor3 = Color3.fromRGB(15, 15, 25)
	modal.BackgroundTransparency = 0.05
	modal.BorderSizePixel = 0
	modal.Visible = false
	modal.ZIndex = 10
	modal.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = modal

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(100, 150, 255)
	stroke.Thickness = 2
	stroke.Parent = modal

	-- Close button
	local closeBtn = Instance.new("TextButton")
	closeBtn.Name = "CloseBtn"
	closeBtn.Size = UDim2.new(0, 40, 0, 40)
	closeBtn.Position = UDim2.new(1, -50, 0, 10)
	closeBtn.BackgroundColor3 = Color3.fromRGB(255, 60, 60)
	closeBtn.BackgroundTransparency = 0.2
	closeBtn.Text = "✕"
	closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeBtn.TextScaled = true
	closeBtn.Font = Enum.Font.GothamBold
	closeBtn.ZIndex = 11
	closeBtn.Parent = modal

	local closeCorner = Instance.new("UICorner")
	closeCorner.CornerRadius = UDim.new(1, 0)
	closeCorner.Parent = closeBtn

	closeBtn.MouseButton1Click:Connect(function()
		QuestController.HideQuestDetail()
	end)

	-- Content area
	local content = Instance.new("ScrollingFrame")
	content.Name = "Content"
	content.Size = UDim2.new(1, -40, 1, -70)
	content.Position = UDim2.new(0, 20, 0, 50)
	content.BackgroundTransparency = 1
	content.ScrollBarThickness = 6
	content.ScrollBarImageColor3 = Color3.fromRGB(100, 150, 255)
	content.CanvasSize = UDim2.new(0, 0, 0, 0)
	content.ZIndex = 11
	content.Parent = modal

	local contentLayout = Instance.new("UIListLayout")
	contentLayout.Padding = UDim.new(0, 15)
	contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
	contentLayout.Parent = content

	QuestUIs.DetailModal = modal
	QuestUIs.DetailContent = content
end

-- Create NPC Dialog UI
function QuestController.CreateNPCDialogUI(parent: ScreenGui)
	local dialog = Instance.new("Frame")
	dialog.Name = "NPCDialog"
	dialog.Size = UDim2.new(0, 600, 0, 450)
	dialog.Position = UDim2.new(0.5, -300, 0.5, -225)
	dialog.BackgroundColor3 = Color3.fromRGB(10, 10, 20)
	dialog.BackgroundTransparency = 0.05
	dialog.BorderSizePixel = 0
	dialog.Visible = false
	dialog.ZIndex = 20
	dialog.Parent = parent

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 16)
	corner.Parent = dialog

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 200, 100)
	stroke.Thickness = 3
	stroke.Parent = dialog

	-- NPC Portrait area
	local portraitFrame = Instance.new("Frame")
	portraitFrame.Name = "PortraitFrame"
	portraitFrame.Size = UDim2.new(0, 150, 1, -40)
	portraitFrame.Position = UDim2.new(0, 20, 0, 20)
	portraitFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	portraitFrame.BorderSizePixel = 0
	portraitFrame.ZIndex = 21
	portraitFrame.Parent = dialog

	local portraitCorner = Instance.new("UICorner")
	portraitCorner.CornerRadius = UDim.new(0, 12)
	portraitCorner.Parent = portraitFrame

	local npcIcon = Instance.new("TextLabel")
	npcIcon.Name = "NPCIcon"
	npcIcon.Size = UDim2.new(1, 0, 1, 0)
	npcIcon.BackgroundTransparency = 1
	npcIcon.Text = "👤"
	npcIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
	npcIcon.TextScaled = true
	npcIcon.Font = Enum.Font.GothamBold
	npcIcon.ZIndex = 22
	npcIcon.Parent = portraitFrame

	-- NPC Name
	local npcName = Instance.new("TextLabel")
	npcName.Name = "NPCName"
	npcName.Size = UDim2.new(1, 0, 0, 30)
	npcName.Position = UDim2.new(0, 190, 0, 20)
	npcName.BackgroundTransparency = 1
	npcName.Text = "NPC"
	npcName.TextColor3 = Color3.fromRGB(255, 255, 255)
	npcName.TextScaled = true
	npcName.Font = Enum.Font.GothamBold
	npcName.TextXAlignment = Enum.TextXAlignment.Left
	npcName.ZIndex = 21
	npcName.Parent = dialog

	-- Dialog text
	local dialogText = Instance.new("TextLabel")
	dialogText.Name = "DialogText"
	dialogText.Size = UDim2.new(1, -210, 0, 120)
	dialogText.Position = UDim2.new(0, 190, 0, 60)
	dialogText.BackgroundTransparency = 1
	dialogText.Text = "Olá, viajante!"
	dialogText.TextColor3 = Color3.fromRGB(200, 200, 200)
	dialogText.TextScaled = true
	dialogText.Font = Enum.Font.Gotham
	dialogText.TextWrapped = true
	dialogText.TextXAlignment = Enum.TextXAlignment.Left
	dialogText.TextYAlignment = Enum.TextYAlignment.Top
	dialogText.ZIndex = 21
	dialogText.Parent = dialog

	-- Quest list in dialog
	local questListFrame = Instance.new("ScrollingFrame")
	questListFrame.Name = "QuestListFrame"
	questListFrame.Size = UDim2.new(1, -210, 1, -200)
	questListFrame.Position = UDim2.new(0, 190, 0, 190)
	questListFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 30)
	questListFrame.BackgroundTransparency = 0.5
	questListFrame.BorderSizePixel = 0
	questListFrame.ScrollBarThickness = 6
	questListFrame.ScrollBarImageColor3 = Color3.fromRGB(255, 200, 100)
	questListFrame.CanvasSize = UDim2.new(0, 0, 0, 0)
	questListFrame.ZIndex = 21
	questListFrame.Parent = dialog

	local questListCorner = Instance.new("UICorner")
	questListCorner.CornerRadius = UDim.new(0, 8)
	questListCorner.Parent = questListFrame

	local questListLayout = Instance.new("UIListLayout")
	questListLayout.Padding = UDim.new(0, 8)
	questListLayout.SortOrder = Enum.SortOrder.LayoutOrder
	questListLayout.Parent = questListFrame

	-- Close button
	local closeDialogBtn = Instance.new("TextButton")
	closeDialogBtn.Name = "CloseBtn"
	closeDialogBtn.Size = UDim2.new(0, 120, 0, 40)
	closeDialogBtn.Position = UDim2.new(1, -140, 1, -50)
	closeDialogBtn.BackgroundColor3 = Color3.fromRGB(100, 100, 120)
	closeDialogBtn.Text = "Fechar"
	closeDialogBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	closeDialogBtn.TextScaled = true
	closeDialogBtn.Font = Enum.Font.GothamBold
	closeDialogBtn.ZIndex = 22
	closeDialogBtn.Parent = dialog

	local closeDialogCorner = Instance.new("UICorner")
	closeDialogCorner.CornerRadius = UDim.new(0, 8)
	closeDialogCorner.Parent = closeDialogBtn

	closeDialogBtn.MouseButton1Click:Connect(function()
		QuestController.HideNPCDialog()
	end)

	QuestUIs.Dialog = dialog
	QuestUIs.DialogQuestList = questListFrame
	QuestUIs.DialogNPCName = npcName
	QuestUIs.DialogNPCIcon = npcIcon
	QuestUIs.DialogText = dialogText
end

-- Show quest tracker
function QuestController.ShowTracker()
	if QuestUIs.TrackerFrame then
		QuestUIs.TrackerFrame.Visible = true
		QuestController.RefreshTracker()
	end
end

function QuestController.HideTracker()
	if QuestUIs.TrackerFrame then
		QuestUIs.TrackerFrame.Visible = false
	end
end

-- Refresh quest tracker display
function QuestController.RefreshTracker()
	local questList = QuestUIs.QuestList
	if not questList then return end

	-- Clear existing
	for _, child in ipairs(questList:GetChildren()) do
		if child:IsA("Frame") then child:Destroy() end
	end

	-- Add active quests
	for _, quest in ipairs(ActiveQuests) do
		local questFrame = QuestController.CreateQuestTrackerItem(quest)
		questFrame.Parent = questList
	end

	-- Update canvas size
	task.wait()
	local layout = questList:FindFirstChild("UIListLayout")
	if layout then
		questList.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
	end
end

-- Create quest item for tracker
function QuestController.CreateQuestTrackerItem(quest: Types.QuestData): Frame
	local frame = Instance.new("Frame")
	frame.Name = "Quest_" .. quest.Id
	frame.Size = UDim2.new(1, 0, 0, 100)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 45)
	frame.BackgroundTransparency = 0.3
	frame.BorderSizePixel = 0
	frame.LayoutOrder = tick()

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	-- Quest name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, -20, 0, 25)
	nameLabel.Position = UDim2.new(0, 10, 0, 5)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = quest.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.TextTruncate = Enum.TextTruncate.AtEnd
	nameLabel.Parent = frame

	-- Progress bar for first objective
	local firstObj = quest.Objectives[1]
	if firstObj then
		local progressFrame = Instance.new("Frame")
		progressFrame.Size = UDim2.new(1, -20, 0, 20)
		progressFrame.Position = UDim2.new(0, 10, 0, 35)
		progressFrame.BackgroundColor3 = Color3.fromRGB(50, 50, 70)
		progressFrame.BorderSizePixel = 0
		progressFrame.Parent = frame

		local progCorner = Instance.new("UICorner")
		progCorner.CornerRadius = UDim.new(0, 4)
		progCorner.Parent = progressFrame

		local fill = Instance.new("Frame")
		fill.Name = "Fill"
		fill.Size = UDim2.new(firstObj.Current / math.max(firstObj.Count, 1), 0, 1, 0)
		fill.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
		fill.BorderSizePixel = 0
		fill.Parent = progressFrame

		local fillCorner = Instance.new("UICorner")
		fillCorner.CornerRadius = UDim.new(0, 4)
		fillCorner.Parent = fill

		-- Progress text
		local progressText = Instance.new("TextLabel")
		progressText.Size = UDim2.new(1, 0, 1, 0)
		progressText.BackgroundTransparency = 1
		progressText.Text = string.format("%s: %d/%d", firstObj.Type, firstObj.Current, firstObj.Count)
		progressText.TextColor3 = Color3.fromRGB(255, 255, 255)
		progressText.TextScaled = true
		progressText.Font = Enum.Font.Gotham
		progressText.Parent = progressFrame

		-- Other objectives
		if #quest.Objectives > 1 then
			local otherLabel = Instance.new("TextLabel")
			otherLabel.Size = UDim2.new(1, -20, 0, 20)
			otherLabel.Position = UDim2.new(0, 10, 0, 60)
			otherLabel.BackgroundTransparency = 1
			otherLabel.Text = string.format("+ %d objetivos adicionais", #quest.Objectives - 1)
			otherLabel.TextColor3 = Color3.fromRGB(150, 150, 170)
			otherLabel.TextScaled = true
			otherLabel.Font = Enum.Font.Gotham
			otherLabel.TextXAlignment = Enum.TextXAlignment.Left
			otherLabel.Parent = frame
		end
	end

	-- Click to show detail
	frame.InputBegan:Connect(function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1 then
			QuestController.ShowQuestDetail(quest)
		end
	end)

	return frame
end

-- Show quest detail modal
function QuestController.ShowQuestDetail(quest: Types.QuestData)
	local modal = QuestUIs.DetailModal
	local content = QuestUIs.DetailContent
	if not modal or not content then return end

	-- Clear content
	for _, child in ipairs(content:GetChildren()) do
		if child:IsA("Frame") or child:IsA("TextLabel") then child:Destroy() end
	end

	-- Quest name
	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 40)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = quest.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.LayoutOrder = 1
	nameLabel.Parent = content

	-- Description
	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, 0, 0, 60)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = quest.Description
	descLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
	descLabel.TextScaled = true
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextWrapped = true
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.TextYAlignment = Enum.TextYAlignment.Top
	descLabel.LayoutOrder = 2
	descLabel.Parent = content

	-- Objectives
	local objTitle = Instance.new("TextLabel")
	objTitle.Size = UDim2.new(1, 0, 0, 30)
	objTitle.BackgroundTransparency = 1
	objTitle.Text = "OBJETIVOS"
	objTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
	objTitle.TextScaled = true
	objTitle.Font = Enum.Font.GothamBold
	objTitle.TextXAlignment = Enum.TextXAlignment.Left
	objTitle.LayoutOrder = 3
	objTitle.Parent = content

	for i, obj in ipairs(quest.Objectives) do
		local objFrame = Instance.new("Frame")
		objFrame.Size = UDim2.new(1, 0, 0, 40)
		objFrame.BackgroundTransparency = 1
		objFrame.LayoutOrder = 3 + i
		objFrame.Parent = content

		local objLayout = Instance.new("UIListLayout")
		objLayout.FillDirection = Enum.FillDirection.Horizontal
		objLayout.Padding = UDim.new(0, 10)
		objLayout.Parent = objFrame

		-- Checkbox
		local checkbox = Instance.new("Frame")
		checkbox.Size = UDim2.new(0, 30, 0, 30)
		checkbox.BackgroundColor3 = obj.Current >= obj.Count and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(60, 60, 80)
		checkbox.BorderSizePixel = 2
		checkbox.BorderColor3 = obj.Current >= obj.Count and Color3.fromRGB(100, 200, 100) or Color3.fromRGB(100, 150, 255)
		checkbox.Parent = objFrame

		local checkCorner = Instance.new("UICorner")
		checkCorner.CornerRadius = UDim.new(0, 4)
		checkCorner.Parent = checkbox

		if obj.Current >= obj.Count then
			local checkMark = Instance.new("TextLabel")
			checkMark.Size = UDim2.new(1, 0, 1, 0)
			checkMark.BackgroundTransparency = 1
			checkMark.Text = "✓"
			checkMark.TextColor3 = Color3.fromRGB(255, 255, 255)
			checkMark.TextScaled = true
			checkMark.Font = Enum.Font.GothamBold
			checkMark.Parent = checkbox
		end

		-- Objective text
		local objText = Instance.new("TextLabel")
		objText.Size = UDim2.new(1, -40, 1, 0)
		objText.BackgroundTransparency = 1
		objText.Text = string.format("%s: %d/%d", obj.Type .. " " .. obj.Target, obj.Current, obj.Count)
		objText.TextColor3 = obj.Current >= obj.Count and Color3.fromRGB(150, 150, 150) or Color3.fromRGB(255, 255, 255)
		objText.TextScaled = true
		objText.Font = Enum.Font.Gotham
		objText.TextXAlignment = Enum.TextXAlignment.Left
		objText.Parent = objFrame
	end

	-- Rewards
	local rewardTitle = Instance.new("TextLabel")
	rewardTitle.Size = UDim2.new(1, 0, 0, 30)
	rewardTitle.BackgroundTransparency = 1
	rewardTitle.Text = "RECOMPENSAS"
	rewardTitle.TextColor3 = Color3.fromRGB(100, 200, 255)
	rewardTitle.TextScaled = true
	rewardTitle.Font = Enum.Font.GothamBold
	rewardTitle.TextXAlignment = Enum.TextXAlignment.Left
	rewardTitle.LayoutOrder = 10
	rewardTitle.Parent = content

	for i, reward in ipairs(quest.Rewards) do
		local rewardLabel = Instance.new("TextLabel")
		rewardLabel.Size = UDim2.new(1, 0, 0, 25)
		rewardLabel.BackgroundTransparency = 1
		local rewardText = string.format("• %s x%d", reward.Type, reward.Amount or 1)
		if reward.ItemId then rewardText = rewardText .. " (" .. reward.ItemId .. ")" end
		rewardLabel.Text = rewardText
		rewardLabel.TextColor3 = Color3.fromRGB(255, 255, 100)
		rewardLabel.TextScaled = true
		rewardLabel.Font = Enum.Font.Gotham
		rewardLabel.TextXAlignment = Enum.TextXAlignment.Left
		rewardLabel.LayoutOrder = 10 + i
		rewardLabel.Parent = content
	end

	-- Update canvas size
	task.wait()
	local layout = content:FindFirstChild("UIListLayout")
	if layout then
		content.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
	end

	modal.Visible = true

	-- Animate in
	modal.Size = UDim2.new(0, 0, 0, 0)
	modal.Position = UDim2.new(0.5, 0, 0.5, 0)
	local tween = TweenService:Create(modal, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 500, 0, 500),
		Position = UDim2.new(0.5, -250, 0.5, -250)
	})
	tween:Play()
end

function QuestController.HideQuestDetail()
	local modal = QuestUIs.DetailModal
	if not modal then return end

	local tween = TweenService:Create(modal, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0)
	})
	tween:Play()
	tween.Completed:Connect(function()
		modal.Visible = false
	end)
end

-- Open NPC dialog with quests
function QuestController.OpenNPCDialog(npcId: string)
	CurrentNPCId = npcId

	local result = RemoteClient.InteractNPC(npcId)
	if not result or not result.Success then
		warn("[QuestController] Failed to interact with NPC:", result and result.Error)
		return
	end

	QuestController.ShowNPCDialog(result)
end

function QuestController.ShowNPCDialog(data: any)
	local dialog = QuestUIs.Dialog
	local questList = QuestUIs.DialogQuestList
	local npcName = QuestUIs.DialogNPCName
	local npcIcon = QuestUIs.DialogNPCIcon
	local dialogText = QuestUIs.DialogText

	if not dialog then return end

	-- Clear quest list
	for _, child in ipairs(questList:GetChildren()) do
		if child:IsA("Frame") or child:IsA("TextButton") then child:Destroy() end
	end

	-- Set NPC info
	npcName.Text = data.NPCName or "NPC"
	npcIcon.Text = QuestController.GetNPCIcon(data.NPCType or "QuestGiver")
	dialogText.Text = data.Message or "Olá, viajante! Como posso ajudar?"

	-- Add available quests
	if data.Quests then
		for _, quest in ipairs(data.Quests) do
			local questBtn = QuestController.CreateQuestDialogButton(quest)
			questBtn.Parent = questList
		end
	end

	-- Add active quests that can be turned in
	local activeQuests = RemoteClient.GetQuests()
	if activeQuests then
		for _, quest in ipairs(activeQuests) do
			if quest.Completed then
				local turnInBtn = QuestController.CreateTurnInButton(quest)
				turnInBtn.Parent = questList
			end
		end
	end

	-- Update canvas size
	task.wait()
	local layout = questList:FindFirstChild("UIListLayout")
	if layout then
		questList.CanvasSize = UDim2.new(0, 0, 0, layout.AbsoluteContentSize.Y + 20)
	end

	dialog.Visible = true

	-- Animate in
	dialog.Size = UDim2.new(0, 0, 0, 0)
	dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
	local tween = TweenService:Create(dialog, TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 600, 0, 450),
		Position = UDim2.new(0.5, -300, 0.5, -225)
	})
	tween:Play()
end

function QuestController.CreateQuestDialogButton(quest: Types.QuestData): TextButton
	local btn = Instance.new("TextButton")
	btn.Name = "QuestBtn_" .. quest.Id
	btn.Size = UDim2.new(1, -20, 0, 80)
	btn.BackgroundColor3 = Color3.fromRGB(40, 50, 70)
	btn.BackgroundTransparency = 0.3
	btn.BorderSizePixel = 0
	btn.Text = ""
	btn.AutoButtonColor = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	local layout = Instance.new("UIListLayout")
	layout.FillDirection = Enum.FillDirection.Horizontal
	layout.Padding = UDim.new(0, 10)
	layout.Parent = btn

	-- Quest icon
	local icon = Instance.new("TextLabel")
	icon.Size = UDim2.new(0, 60, 1, -10)
	icon.Position = UDim2.new(0, 5, 0, 5)
	icon.BackgroundTransparency = 1
	icon.Text = QuestController.GetQuestTypeIcon(quest.Type)
	icon.TextColor3 = Color3.fromRGB(255, 255, 100)
	icon.TextScaled = true
	icon.Font = Enum.Font.GothamBold
	icon.Parent = btn

	-- Quest info
	local infoFrame = Instance.new("Frame")
	infoFrame.Size = UDim2.new(1, -80, 1, 0)
	infoFrame.BackgroundTransparency = 1
	infoFrame.Parent = btn

	local infoLayout = Instance.new("UIListLayout")
	infoLayout.Padding = UDim.new(0, 2)
	infoLayout.Parent = infoFrame

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0, 30)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = quest.Name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextXAlignment = Enum.TextXAlignment.Left
	nameLabel.Parent = infoFrame

	local descLabel = Instance.new("TextLabel")
	descLabel.Size = UDim2.new(1, 0, 0, 30)
	descLabel.BackgroundTransparency = 1
	descLabel.Text = quest.Description
	descLabel.TextColor3 = Color3.fromRGB(180, 180, 180)
	descLabel.TextScaled = true
	descLabel.Font = Enum.Font.Gotham
	descLabel.TextWrapped = true
	descLabel.TextXAlignment = Enum.TextXAlignment.Left
	descLabel.Parent = infoFrame

	btn.MouseButton1Click:Connect(function()
		QuestController.AcceptQuest(quest.Id)
	end)

	return btn
end

function QuestController.CreateTurnInButton(quest: Types.QuestData): TextButton
	local btn = Instance.new("TextButton")
	btn.Name = "TurnInBtn_" .. quest.Id
	btn.Size = UDim2.new(1, -20, 0, 60)
	btn.BackgroundColor3 = Color3.fromRGB(100, 200, 100)
	btn.BackgroundTransparency = 0.2
	btn.BorderSizePixel = 0
	btn.Text = "✓ ENTREGAR: " .. quest.Name
	btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	btn.TextScaled = true
	btn.Font = Enum.Font.GothamBold
	btn.AutoButtonColor = true

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = btn

	btn.MouseButton1Click:Connect(function()
		QuestController.TurnInQuest(quest.Id)
	end)

	return btn
end

function QuestController.GetQuestTypeIcon(questType: string): string
	local icons = {
		Capture = "🎯",
		Defeat = "⚔️",
		Evolve = "✨",
		Collect = "📦",
		Explore = "🗺️",
	}
	return icons[questType] or "📜"
end

function QuestController.GetNPCIcon(npcType: string): string
	local icons = {
		Trainer = "⚔️",
		Shopkeeper = "🏪",
		Healer = "❤️",
		QuestGiver = "📜",
	}
	return icons[npcType] or "👤"
end

function QuestController.HideNPCDialog()
	local dialog = QuestUIs.Dialog
	if not dialog then return end

	local tween = TweenService:Create(dialog, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
		Size = UDim2.new(0, 0, 0, 0),
		Position = UDim2.new(0.5, 0, 0.5, 0)
	})
	tween:Play()
	tween.Completed:Connect(function()
		dialog.Visible = false
		CurrentNPCId = ""
	end)
end

-- Accept quest
function QuestController.AcceptQuest(questId: string)
	local success, error = RemoteClient.AcceptQuest(questId)
	if success then
		UIController.ShowNotification("Missão aceita!", "Success")
		QuestController.HideNPCDialog()
		QuestController.RefreshQuests()
	else
		UIController.ShowNotification("Erro: " .. (error or "Desconhecido"), "Error")
	end
end

-- Turn in quest
function QuestController.TurnInQuest(questId: string)
	local success, error = RemoteClient.TurnInQuest(questId)
	if success then
		UIController.ShowNotification("Missão completada! Recompensas recebidas.", "Success")
		QuestController.HideNPCDialog()
		QuestController.RefreshQuests()
	else
		UIController.ShowNotification("Erro: " .. (error or "Desconhecido"), "Error")
	end
end

-- Refresh quests from server
function QuestController.RefreshQuests()
	local activeQuests = RemoteClient.GetQuests()
	if activeQuests then
		ActiveQuests = activeQuests
		QuestController.RefreshTracker()
	end
end

-- Handle quest progress update
function QuestController.OnQuestProgress(quest: any, objective: any)
	QuestController.RefreshTracker()
	UIController.ShowNotification(string.format("Progresso: %s %d/%d", objective.Type, objective.Current, objective.Count), "Info")
end

-- Toggle tracker visibility (keybind)
function QuestController.ToggleTracker()
	if QuestUIs.TrackerFrame then
		QuestUIs.TrackerFrame.Visible = not QuestUIs.TrackerFrame.Visible
		if QuestUIs.TrackerFrame.Visible then
			QuestController.RefreshTracker()
		end
	end
end

return QuestController