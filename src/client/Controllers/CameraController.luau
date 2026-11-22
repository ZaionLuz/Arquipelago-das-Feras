--!strict
-- CameraController.lua - Controlador de câmera (overworld, battle, cutscenes)

local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")

local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local MathUtil = require(ReplicatedStorage.Shared.Util.Math)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local CameraController = {}

-- Events
CameraController.OnCameraModeChanged = Signal.New()
CameraController.OnCameraShake = Signal.New()

-- State
local Camera = Workspace.CurrentCamera
local Player = Players.LocalPlayer
local Character: Model?
local Humanoid: Humanoid?
local RootPart: BasePart?

local CurrentMode = "Follow" :: "Follow" | "Fixed" | "Battle" | "Cutscene" | "Free" | "FirstPerson"
local TargetCFrame: CFrame?
local TargetSubject: Instance?

-- Follow camera settings
local FollowDistance = 15
local FollowHeight = 5
local FollowSmoothness = 0.1
local MinDistance = 5
local MaxDistance = 30
local CurrentDistance = FollowDistance

-- Battle camera settings
local BattleCameraOffset = Vector3.new(0, 8, 25)
local BattleCameraTarget = Vector3.new(0, 0, 0)
local BattleTransitionTime = 1

-- Cutscene
local CutsceneData = nil :: {CFrames: {CFrame}, Duration: number, CurrentIndex: number}?

-- Camera shake
local ShakeIntensity = 0
local ShakeDuration = 0
local ShakeOffset = Vector3.zero

-- Initialize
function CameraController.Initialize()
	print("[CameraController] Initializing...")

	Camera.CameraType = Enum.CameraType.Custom
	Camera.CameraSubject = Player.Character or Player.CharacterAdded:Wait()

	-- Character handling
	Player.CharacterAdded:Connect(CameraController.OnCharacterAdded)
	if Player.Character then
		CameraController.OnCharacterAdded(Player.Character)
	end

	-- Input for camera control
	CameraController.SetupCameraInput()

	-- Render step for custom camera logic
	RunService.RenderStepped:Connect(function(deltaTime)
		CameraController.Update(deltaTime)
	end)

	print("[CameraController] Initialized")
end

function CameraController.OnCharacterAdded(character: Model)
	Character = character
	Humanoid = character:WaitForChild("Humanoid")
	RootPart = character:WaitForChild("HumanoidRootPart")

	Camera.CameraSubject = Humanoid

	-- Reset to follow mode
	CameraController.SetMode("Follow")
end

function CameraController.SetupCameraInput()
	-- Mouse wheel zoom
	UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.UserInputType == Enum.UserInputType.MouseWheel then
			CameraController.Zoom(input.Position.Z > 0 and -1 or 1)
		end
	end)

	-- Right mouse button for camera rotation
	local isRotating = false
	local lastMousePos = Vector2.zero

	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			isRotating = true
			lastMousePos = input.Position
			UserInputService.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		end
	end)

	UserInputService.InputEnded:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseButton2 then
			isRotating = false
			UserInputService.MouseBehavior = Enum.MouseBehavior.Default
		end
	end)

	UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if isRotating and input.UserInputType == Enum.UserInputType.MouseMovement then
			local delta = input.Position - lastMousePos
			CameraController.Rotate(delta.X, delta.Y)
			lastMousePos = input.Position
		end
	end)

	-- Keyboard camera controls
	UserInputService.InputBegan:Connect(function(input, gameProcessed)
		if gameProcessed then return end

		if input.KeyCode == Enum.KeyCode.PageUp then
			CameraController.Zoom(-1)
		elseif input.KeyCode == Enum.KeyCode.PageDown then
			CameraController.Zoom(1)
		elseif input.KeyCode == Enum.KeyCode.Home then
			CameraController.ResetCamera()
		elseif input.KeyCode == Enum.KeyCode.F then
			CameraController.ToggleFirstPerson()
		end
	end)
end

-- Main update loop
function CameraController.Update(deltaTime: number)
	if CurrentMode == "Follow" then
		CameraController.UpdateFollowCamera(deltaTime)
	elseif CurrentMode == "Battle" then
		CameraController.UpdateBattleCamera(deltaTime)
	elseif CurrentMode == "Cutscene" then
		CameraController.UpdateCutscene(deltaTime)
	elseif CurrentMode == "Free" then
		-- Free camera - no auto update
	end

	-- Apply shake
	if ShakeDuration > 0 then
		CameraController.UpdateShake(deltaTime)
	end
end

function CameraController.UpdateFollowCamera(deltaTime: number)
	if not RootPart or not Humanoid then return end

	-- Calculate desired camera position
	local characterCFrame = RootPart.CFrame
	local cameraCFrame = Camera.CFrame

	-- Get horizontal rotation from camera
	local _, yRot, _ = cameraCFrame:ToEulerAnglesYXZ()

	-- Desired position behind character
	local desiredPos = characterCFrame.Position
		- Vector3.new(math.sin(yRot), 0, math.cos(yRot)) * CurrentDistance
		+ Vector3.new(0, FollowHeight, 0)

	-- Raycast to avoid clipping through walls
	local rayParams = RaycastParams.new()
	rayParams.FilterDescendantsInstances = {Character}
	rayParams.FilterType = Enum.RaycastFilterType.Exclude

	local ray = Workspace:Raycast(characterCFrame.Position + Vector3.new(0, FollowHeight, 0),
		(desiredPos - (characterCFrame.Position + Vector3.new(0, FollowHeight, 0))), rayParams)

	if ray then
		desiredPos = ray.Position + ray.Normal * 0.5
	end

	-- Smooth camera movement
	local newCFrame = CFrame.new(desiredPos, characterCFrame.Position + Vector3.new(0, 1.5, 0))
	Camera.CFrame = Camera.CFrame:Lerp(newCFrame, FollowSmoothness)
end

function CameraController.UpdateBattleCamera(deltaTime: number)
	-- Battle camera orbits around the battlefield
	if not TargetCFrame then return end

	local time = tick() * 0.3
	local orbitRadius = 20
	local orbitHeight = 10

	local pos = TargetCFrame.Position + Vector3.new(
		math.sin(time) * orbitRadius,
		orbitHeight,
		math.cos(time) * orbitRadius
	)

	Camera.CFrame = CFrame.new(pos, TargetCFrame.Position)
end

function CameraController.UpdateCutscene(deltaTime: number)
	if not CutsceneData then return end

	CutsceneData.CurrentIndex += deltaTime / CutsceneData.Duration * #CutsceneData.CFrames

	local index = math.floor(CutsceneData.CurrentIndex) + 1
	local nextIndex = math.min(index + 1, #CutsceneData.CFrames)
	local alpha = CutsceneData.CurrentIndex - math.floor(CutsceneData.CurrentIndex)

	if index <= #CutsceneData.CFrames and nextIndex <= #CutsceneData.CFrames then
		Camera.CFrame = CutsceneData.CFrames[index]:Lerp(CutsceneData.CFrames[nextIndex], alpha)
	end

	if CutsceneData.CurrentIndex >= #CutsceneData.CFrames then
		CameraController.EndCutscene()
	end
end

function CameraController.UpdateShake(deltaTime: number)
	ShakeDuration -= deltaTime

	if ShakeDuration <= 0 then
		ShakeIntensity = 0
		ShakeOffset = Vector3.zero
		return
	end

	-- Generate shake offset
	local shakeX = (math.random() - 0.5) * ShakeIntensity
	local shakeY = (math.random() - 0.5) * ShakeIntensity
	local shakeZ = (math.random() - 0.5) * ShakeIntensity

	ShakeOffset = Vector3.new(shakeX, shakeY, shakeZ)

	-- Apply to camera
	Camera.CFrame = Camera.CFrame * CFrame.new(ShakeOffset)
end

-- Camera modes
function CameraController.SetMode(mode: string, data: any?)
	if mode == CurrentMode then return end

	local oldMode = CurrentMode
	CurrentMode = mode

	print(`[CameraController] Mode changed: {oldMode} -> {mode}`)

	if mode == "Follow" then
		Camera.CameraType = Enum.CameraType.Custom
		Camera.CameraSubject = Humanoid
		CameraController.ResetCamera()

	elseif mode == "Battle" then
		Camera.CameraType = Enum.CameraType.Scriptable
		TargetCFrame = data and data.TargetCFrame or CFrame.new(0, 0, 0)
		CameraController.TransitionToBattleCamera(data)

	elseif mode == "Cutscene" then
		Camera.CameraType = Enum.CameraType.Scriptable
		CameraController.StartCutscene(data)

	elseif mode == "Fixed" then
		Camera.CameraType = Enum.CameraType.Scriptable
		if data and data.CFrame then
			TargetCFrame = data.CFrame
			Camera.CFrame = data.CFrame
		end

	elseif mode == "Free" then
		Camera.CameraType = Enum.CameraType.Scriptable

	elseif mode == "FirstPerson" then
		Camera.CameraType = Enum.CameraType.Custom
		Camera.CameraSubject = Humanoid
		Player.CameraMinZoomDistance = 0.5
		Player.CameraMaxZoomDistance = 0.5
	end

	CameraController.OnCameraModeChanged:Fire(mode, oldMode)
end

function CameraController.TransitionToBattleCamera(data: any?)
	-- Smooth transition from follow to battle camera
	local startCFrame = Camera.CFrame
	local endCFrame = (data and data.TargetCFrame or CFrame.new(0, 0, 0)) + BattleCameraOffset

	local tween = TweenService:Create(Camera, TweenInfo.new(BattleTransitionTime, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = endCFrame
	})
	tween:Play()

	tween.Completed:Wait()

	TargetCFrame = data and data.TargetCFrame or CFrame.new(0, 0, 0)
end

function CameraController.StartCutscene(data: any)
	if not data or not data.CFrames then return end

	CutsceneData = {
		CFrames = data.CFrames,
		Duration = data.Duration or 5,
		CurrentIndex = 0,
	}

	Camera.CFrame = data.CFrames[1]
end

function CameraController.EndCutscene()
	CutsceneData = nil
	CameraController.SetMode("Follow")
end

-- Camera controls
function CameraController.Zoom(delta: number)
	if CurrentMode == "FirstPerson" then return end

	CurrentDistance = math.clamp(CurrentDistance + delta * 2, MinDistance, MaxDistance)

	if CurrentMode == "Follow" then
		Player.CameraMinZoomDistance = CurrentDistance
		Player.CameraMaxZoomDistance = CurrentDistance
	end
end

function CameraController.Rotate(deltaX: number, deltaY: number)
	if CurrentMode ~= "Follow" and CurrentMode ~= "Free" then return end

	-- Rotation is handled by Roblox's default camera when in Custom mode
	-- For Free mode, we'd manually rotate
end

function CameraController.ResetCamera()
	CurrentDistance = FollowDistance
	Player.CameraMinZoomDistance = 0.5
	Player.CameraMaxZoomDistance = MaxDistance

	if RootPart then
		local targetPos = RootPart.Position + Vector3.new(0, FollowHeight, 0)
		local cameraPos = targetPos - Camera.CFrame.LookVector * FollowDistance
		Camera.CFrame = CFrame.new(cameraPos, targetPos)
	end
end

function CameraController.ToggleFirstPerson()
	if CurrentMode == "FirstPerson" then
		CameraController.SetMode("Follow")
	else
		CameraController.SetMode("FirstPerson")
	end
end

-- Focus on a specific point
function CameraController.FocusOn(position: Vector3, duration: number?)
	duration = duration or 1

	local targetCFrame = CFrame.new(Camera.CFrame.Position, position)
	local tween = TweenService:Create(Camera, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
		CFrame = targetCFrame
	})
	tween:Play()
end

-- Camera shake
function CameraController.Shake(intensity: number, duration: number)
	ShakeIntensity = intensity
	ShakeDuration = duration
	CameraController.OnCameraShake:Fire(intensity, duration)
end

-- Battle camera helpers
function CameraController.SetBattleCamera(targetCFrame: CFrame, playerSide: boolean)
	TargetCFrame = targetCFrame

	if playerSide then
		-- Camera behind player's creature
		Camera.CFrame = targetCFrame * CFrame.new(0, 8, 25)
	else
		-- Camera behind enemy creature
		Camera.CFrame = targetCFrame * CFrame.new(0, 8, -25) * CFrame.Angles(0, math.pi, 0)
	end
end

function CameraController.PlayBattleCameraAnimation(animationType: "Move" | "Hit" | "Faint" | "Win", data: any)
	if animationType == "Hit" then
		CameraController.Shake(2, 0.3)
	elseif animationType == "Faint" then
		CameraController.Shake(3, 0.5)
		-- Pan down
		local tween = TweenService:Create(Camera, TweenInfo.new(1), {
			CFrame = Camera.CFrame * CFrame.Angles(math.rad(-20), 0, 0)
		})
		tween:Play()
	elseif animationType == "Win" then
		-- Victory camera sweep
		CameraController.SetMode("Fixed", {CFrame = Camera.CFrame})
		local tween = TweenService:Create(Camera, TweenInfo.new(3, Enum.EasingStyle.Quad), {
			CFrame = Camera.CFrame * CFrame.Angles(0, math.rad(360), 0)
		})
		tween:Play()
	end
end

-- Getters
function CameraController.GetCurrentMode(): string
	return CurrentMode
end

function CameraController.GetCamera(): Camera
	return Camera
end

function CameraController.GetFollowDistance(): number
	return CurrentDistance
end

return CameraController