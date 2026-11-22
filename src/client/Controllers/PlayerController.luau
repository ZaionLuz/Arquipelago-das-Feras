--!strict
-- PlayerController.lua - Controle do personagem do jogador

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local MathUtil = require(ReplicatedStorage.Shared.Util.Math)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local PlayerController = {}

-- Events
PlayerController.OnCharacterLoaded = Signal.New()
PlayerController.OnStateChanged = Signal.New()
PlayerController.OnMovementChanged = Signal.New()

-- State
local Player = Players.LocalPlayer
local Character: Model?
local Humanoid: Humanoid?
local RootPart: BasePart?
local Animator: Animator?

local CurrentState = "Idle" :: "Idle" | "Walking" | "Running" | "Jumping" | "Falling" | "Swimming" | "Flying"
local MoveDirection = Vector3.zero
local MoveSpeed = 16
local IsMoving = false
local IsSprinting = false
local InputVector = Vector2.zero

-- Animation tracks
local AnimationTracks = {} :: {[string]: AnimationTrack}

-- Initialize
function PlayerController.Initialize(playerData: Types.PlayerData)
	print("[PlayerController] Initializing...")

	-- Setup character handling
	if Player.Character then
		PlayerController.OnCharacterAdded(Player.Character)
	end

	Player.CharacterAdded:Connect(PlayerController.OnCharacterAdded)

	-- Setup movement input
	PlayerController.SetupMovement()

	-- Setup actions
	PlayerController.SetupActions()

	print("[PlayerController] Initialized")
end

function PlayerController.OnCharacterAdded(character: Model)
	Character = character
	Humanoid = character:WaitForChild("Humanoid") :: Humanoid
	RootPart = character:WaitForChild("HumanoidRootPart") :: BasePart

	-- Configure humanoid
	Humanoid.WalkSpeed = Config.Game.BaseWalkSpeed
	Humanoid.JumpPower = Config.Game.BaseJumpPower
	Humanoid.AutoRotate = true

	-- Get or create animator
	Animator = character:FindFirstChild("Animator") :: Animator?
	if not Animator then
		Animator = Instance.new("Animator")
		Animator.Parent = Humanoid
	end

	-- Load animations
	PlayerController.LoadAnimations()

	-- State change handler
	Humanoid.StateChanged:Connect(function(_, newState)
		PlayerController.OnHumanoidStateChanged(newState)
	end)

	-- Movement direction tracking
	RunService.RenderStepped:Connect(function()
		if RootPart and Humanoid then
			PlayerController.UpdateMovement()
		end
	end)

	PlayerController.OnCharacterLoaded:Fire(character)
	print("[PlayerController] Character loaded")
end

function PlayerController.LoadAnimations()
	if not Animator then return end

	local animIds = {
		Idle = "rbxassetid://507766666",
		Walk = "rbxassetid://507777826",
		Run = "rbxassetid://507767714",
		Jump = "rbxassetid://507765000",
		Fall = "rbxassetid://507767968",
		Swim = "rbxassetid://507784542",
		Fly = "rbxassetid://507784542",
	}

	for name, id in pairs(animIds) do
		local anim = Instance.new("Animation")
		anim.AnimationId = id
		AnimationTracks[name] = Animator:LoadAnimation(anim)
	end

	-- Play idle by default
	if AnimationTracks.Idle then
		AnimationTracks.Idle:Play()
	end
end

function PlayerController.OnHumanoidStateChanged(newState: Enum.HumanoidStateType)
	local stateMap = {
		[Enum.HumanoidStateType.Running] = "Walking",
		[Enum.HumanoidStateType.RunningNoPhysics] = "Walking",
		[Enum.HumanoidStateType.Jumping] = "Jumping",
		[Enum.HumanoidStateType.Freefall] = "Falling",
		[Enum.HumanoidStateType.Landed] = "Idle",
		[Enum.HumanoidStateType.Swimming] = "Swimming",
		[Enum.HumanoidStateType.Flying] = "Flying",
	}

	local newStateStr = stateMap[newState] or "Idle"

	if newStateStr ~= CurrentState then
		local oldState = CurrentState
		CurrentState = newStateStr

		-- Handle animation transitions
		PlayerController.UpdateAnimation(newStateStr, oldState)

		PlayerController.OnStateChanged:Fire(CurrentState, oldState)
	end
end

function PlayerController.UpdateAnimation(newState: string, oldState: string)
	-- Stop old animation
	if AnimationTracks[oldState] then
		AnimationTracks[oldState]:Stop(0.1)
	end

	-- Play new animation
	local animName = newState
	if newState == "Walking" and IsSprinting then
		animName = "Run"
	end

	if AnimationTracks[animName] then
		AnimationTracks[animName]:Play(0.1)
	end
end

-- Setup movement input
function PlayerController.SetupMovement()
	-- WASD / Arrow keys
	ContextActionService:BindAction("MoveForward", function(_, state: Enum.UserInputState)
		if state == Enum.UserInputState.Begin then
			InputVector = Vector2.new(InputVector.X, 1)
		elseif state == Enum.UserInputState.End then
			InputVector = Vector2.new(InputVector.X, 0)
		end
	end, false, Enum.KeyCode.W, Enum.KeyCode.Up)

	ContextActionService:BindAction("MoveBackward", function(_, state: Enum.UserInputState)
		if state == Enum.UserInputState.Begin then
			InputVector = Vector2.new(InputVector.X, -1)
		elseif state == Enum.UserInputState.End then
			InputVector = Vector2.new(InputVector.X, 0)
		end
	end, false, Enum.KeyCode.S, Enum.KeyCode.Down)

	ContextActionService:BindAction("MoveLeft", function(_, state: Enum.UserInputState)
		if state == Enum.UserInputState.Begin then
			InputVector = Vector2.new(-1, InputVector.Y)
		elseif state == Enum.UserInputState.End then
			InputVector = Vector2.new(0, InputVector.Y)
		end
	end, false, Enum.KeyCode.A, Enum.KeyCode.Left)

	ContextActionService:BindAction("MoveRight", function(_, state: Enum.UserInputState)
		if state == Enum.UserInputState.Begin then
			InputVector = Vector2.new(1, InputVector.Y)
		elseif state == Enum.UserInputState.End then
			InputVector = Vector2.new(0, InputVector.Y)
		end
	end, false, Enum.KeyCode.D, Enum.KeyCode.Right)

	-- Sprint
	ContextActionService:BindAction("Sprint", function(_, state: Enum.UserInputState)
		IsSprinting = state == Enum.UserInputState.Begin
		PlayerController.UpdateWalkSpeed()
	end, false, Enum.KeyCode.LeftShift)

	-- Jump
	ContextActionService:BindAction("Jump", function(_, state: Enum.UserInputState)
		if state == Enum.UserInputState.Begin and Humanoid then
			Humanoid.Jump = true
		end
	end, false, Enum.KeyCode.Space)
end

function PlayerController.SetupActions()
	-- Interact (E)
	ContextActionService:BindAction("Interact", function(_, state: Enum.UserInputState)
		if state == Enum.UserInputState.Begin then
			PlayerController.Interact()
		end
	end, false, Enum.KeyCode.E)

	-- Party (P)
	ContextActionService:BindAction("OpenParty", function(_, state: Enum.UserInputState)
		if state == Enum.UserInputState.Begin then
			PlayerController.ToggleParty()
		end
	end, false, Enum.KeyCode.P)

	-- Inventory (I)
	ContextActionService:BindAction("OpenInventory", function(_, state: Enum.UserInputState)
		if state == Enum.UserInputState.Begin then
			PlayerController.ToggleInventory()
		end
	end, false, Enum.KeyCode.I)

	-- Map (M)
	ContextActionService:BindAction("OpenMap", function(_, state: Enum.UserInputState)
		if state == Enum.UserInputState.Begin then
			PlayerController.ToggleMap()
		end
	end, false, Enum.KeyCode.M)

	-- Menu (Escape)
	ContextActionService:BindAction("OpenMenu", function(_, state: Enum.UserInputState)
		if state == Enum.UserInputState.Begin then
			PlayerController.ToggleMenu()
		end
	end, false, Enum.KeyCode.Escape)
end

function PlayerController.UpdateWalkSpeed()
	if not Humanoid then return end

	local baseSpeed = Config.Game.BaseWalkSpeed
	if IsSprinting then
		Humanoid.WalkSpeed = baseSpeed * Config.Game.SprintMultiplier
	else
		Humanoid.WalkSpeed = baseSpeed
	end
end

function PlayerController.UpdateMovement()
	if not RootPart or not Humanoid then return end

	-- Get camera direction
	local camera = workspace.CurrentCamera
	if not camera then return end

	local cameraCFrame = camera.CFrame
	local forward = Vector3.new(cameraCFrame.LookVector.X, 0, cameraCFrame.LookVector.Z).Unit
	local right = Vector3.new(cameraCFrame.RightVector.X, 0, cameraCFrame.RightVector.Z).Unit

	-- Calculate move direction
	MoveDirection = (forward * InputVector.Y + right * InputVector.X)

	if MoveDirection.Magnitude > 0 then
		MoveDirection = MoveDirection.Unit
		IsMoving = true

		-- Apply movement
		Humanoid:Move(MoveDirection, false)
	else
		IsMoving = false
		Humanoid:Move(Vector3.zero, false)
	end

	PlayerController.OnMovementChanged:Fire(MoveDirection, IsMoving, IsSprinting)
end

function PlayerController.Interact()
	-- Raycast in front of player to find interactables
	if not RootPart then return end

	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {Character}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local ray = workspace:Raycast(RootPart.Position, RootPart.CFrame.LookVector * 5, rayParams)

	if ray and ray.Instance then
		-- Check for interactable objects
		local interactable = ray.Instance:FindFirstAncestorWhichIsA("Model")
		if interactable and interactable:GetAttribute("Interactable") then
			local interactionType = interactable:GetAttribute("InteractionType")

			if interactionType == "NPC" then
				-- Talk to NPC
				PlayerController.TalkToNPC(interactable)
			elseif interactionType == "HealingStation" then
				-- Heal party
				PlayerController.UseHealingStation(interactable)
			elseif interactionType == "Shop" then
				-- Open shop
				PlayerController.OpenShop(interactable)
			elseif interactionType == "Portal" then
				-- Teleport
				PlayerController.UsePortal(interactable)
			end
		end
	end
end

function PlayerController.TalkToNPC(npc: Model)
	-- Fire remote to start dialogue
	print("[PlayerController] Talking to NPC:", npc.Name)
end

function PlayerController.UseHealingStation(station: Model)
	print("[PlayerController] Using healing station")
end

function PlayerController.OpenShop(shop: Model)
	print("[PlayerController] Opening shop")
end

function PlayerController.UsePortal(portal: Model)
	print("[PlayerController] Using portal")
end

function PlayerController.ToggleParty()
	-- Handled by UIController
end

function PlayerController.ToggleInventory()
	-- Handled by UIController
end

function PlayerController.ToggleMap()
	-- Handled by UIController
end

function PlayerController.ToggleMenu()
	-- Handled by UIController
end

-- Getters
function PlayerController.GetCharacter(): Model?
	return Character
end

function PlayerController.GetHumanoid(): Humanoid?
	return Humanoid
end

function PlayerController.GetRootPart(): BasePart?
	return RootPart
end

function PlayerController.GetCurrentState(): string
	return CurrentState
end

function PlayerController.GetMoveDirection(): Vector3
	return MoveDirection
end

function PlayerController.IsMoving(): boolean
	return IsMoving
end

function PlayerController.IsSprinting(): boolean
	return IsSprinting
end

-- Teleport player
function PlayerController.TeleportTo(position: Vector3)
	if RootPart then
		RootPart.CFrame = CFrame.new(position)
	end
end

-- Set walk speed (for effects like speed boost, slow, etc.)
function PlayerController.SetWalkSpeedMultiplier(multiplier: number)
	if Humanoid then
		Humanoid.WalkSpeed = Config.Game.BaseWalkSpeed * multiplier
	end
end

return PlayerController