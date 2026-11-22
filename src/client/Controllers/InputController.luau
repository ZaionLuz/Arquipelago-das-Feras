--!strict
-- InputController.lua - Gerenciamento de entrada do jogador

local UserInputService = game:GetService("UserInputService")
local ContextActionService = game:GetService("ContextActionService")
local RunService = game:GetService("RunService")

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local InputController = {}

-- Events
InputController.OnInput = Signal.New()
InputController.OnKeyDown = Signal.New()
InputController.OnKeyUp = Signal.New()
InputController.OnMouseMove = Signal.New()
InputController.OnTouch = Signal.New()

-- State
local KeyStates = {} :: {[Enum.KeyCode]: boolean}
local MousePosition = Vector2.zero
local MouseDelta = Vector2.zero
local GamepadConnected = false
local CurrentInputMode = "KeyboardMouse" :: "KeyboardMouse" | "Gamepad" | "Touch"

-- Key bindings (customizable)
local KeyBindings = {
	MoveForward = {Enum.KeyCode.W, Enum.KeyCode.Up},
	MoveBackward = {Enum.KeyCode.S, Enum.KeyCode.Down},
	MoveLeft = {Enum.KeyCode.A, Enum.KeyCode.Left},
	MoveRight = {Enum.KeyCode.D, Enum.KeyCode.Right},
	Jump = {Enum.KeyCode.Space},
	Sprint = {Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift},
	Interact = {Enum.KeyCode.E},
	Party = {Enum.KeyCode.P},
	Inventory = {Enum.KeyCode.I},
	Map = {Enum.KeyCode.M},
	Menu = {Enum.KeyCode.Escape},
	BattleMove1 = {Enum.KeyCode.One},
	BattleMove2 = {Enum.KeyCode.Two},
	BattleMove3 = {Enum.KeyCode.Three},
	BattleMove4 = {Enum.KeyCode.Four},
	BattleBack = {Enum.KeyCode.Backspace},
	CameraRotateLeft = {Enum.KeyCode.Q, Enum.KeyCode.Comma},
	CameraRotateRight = {Enum.KeyCode.E, Enum.KeyCode.Period},
	CameraZoomIn = {Enum.KeyCode.PageUp},
	CameraZoomOut = {Enum.KeyCode.PageDown},
}

-- Initialize
function InputController.Initialize()
	print("[InputController] Initializing...")

	-- Detect input mode
	UserInputService.LastInputTypeChanged:Connect(function(inputType)
		InputController.UpdateInputMode(inputType)
	end)

	InputController.UpdateInputMode(UserInputService:GetLastInputType())

	-- Gamepad detection
	UserInputService.GamepadConnected:Connect(function(gamepad)
		GamepadConnected = true
		CurrentInputMode = "Gamepad"
		print("[InputController] Gamepad connected")
	end)

	UserInputService.GamepadDisconnected:Connect(function(gamepad)
		if #UserInputService:GetConnectedGamepads() == 0 then
			GamepadConnected = false
			CurrentInputMode = "KeyboardMouse"
			print("[InputController] Gamepad disconnected")
		end
	end)

	-- Bind actions
	InputController.BindActions()

	-- Mouse tracking
	UserInputService.InputChanged:Connect(function(input, gameProcessed)
		if input.UserInputType == Enum.UserInputType.MouseMovement then
			MouseDelta = input.Delta
			MousePosition = input.Position
			InputController.OnMouseMove:Fire(MousePosition, MouseDelta)
		end
	end)

	-- Touch handling
	UserInputService.TouchStarted:Connect(function(touch, gameProcessed)
		if not gameProcessed then
			InputController.OnTouch:Fire(touch.Position, "Began")
		end
	end)

	UserInputService.TouchEnded:Connect(function(touch, gameProcessed)
		InputController.OnTouch:Fire(touch.Position, "Ended")
	end)

	print("[InputController] Initialized")
end

function InputController.UpdateInputMode(inputType: Enum.UserInputType)
	if inputType == Enum.UserInputType.Gamepad1 or inputType == Enum.UserInputType.Gamepad2 then
		CurrentInputMode = "Gamepad"
	elseif inputType == Enum.UserInputType.Touch then
		CurrentInputMode = "Touch"
	else
		CurrentInputMode = "KeyboardMouse"
	end
end

function InputController.BindActions()
	-- Movement actions (handled by PlayerController via ContextActionService)
	-- We just track key states here

	for actionName, keys in pairs(KeyBindings) do
		for _, key in ipairs(keys) do
			ContextActionService:BindAction(actionName .. "_" .. key.Name, function(_, state, input)
				InputController.HandleKey(input.KeyCode, state)
			end, false, key)
		end
	end

	-- Mouse buttons
	ContextActionService:BindAction("Mouse1", function(_, state, input)
		InputController.HandleMouseButton(Enum.UserInputType.MouseButton1, state)
	end, false, Enum.UserInputType.MouseButton1)

	ContextActionService:BindAction("Mouse2", function(_, state, input)
		InputController.HandleMouseButton(Enum.UserInputType.MouseButton2, state)
	end, false, Enum.UserInputType.MouseButton2)

	-- Gamepad bindings
	InputController.BindGamepadActions()
end

function InputController.BindGamepadActions()
	local gamepadActions = {
		Move = Enum.KeyCode.Thumbstick1,
		Camera = Enum.KeyCode.Thumbstick2,
		Jump = Enum.KeyCode.ButtonA,
		Sprint = Enum.KeyCode.ButtonL3,
		Interact = Enum.KeyCode.ButtonX,
		Menu = Enum.KeyCode.ButtonStart,
		Party = Enum.KeyCode.ButtonY,
		Inventory = Enum.KeyCode.ButtonSelect,
		BattleMove1 = Enum.KeyCode.ButtonR1,
		BattleMove2 = Enum.KeyCode.ButtonR2,
		BattleMove3 = Enum.KeyCode.ButtonL1,
		BattleMove4 = Enum.KeyCode.ButtonL2,
		DpadUp = Enum.KeyCode.DPadUp,
		DpadDown = Enum.KeyCode.DPadDown,
		DpadLeft = Enum.KeyCode.DPadLeft,
		DpadRight = Enum.KeyCode.DPadRight,
	}

	for actionName, keyCode in pairs(gamepadActions) do
		ContextActionService:BindAction("Gamepad_" .. actionName, function(_, state, input)
			InputController.HandleGamepadInput(keyCode, state, input)
		end, false, keyCode)
	end
end

function InputController.HandleKey(keyCode: Enum.KeyCode, state: Enum.UserInputState)
	local isDown = state == Enum.UserInputState.Begin
	KeyStates[keyCode] = isDown

	if isDown then
		InputController.OnKeyDown:Fire(keyCode)
	else
		InputController.OnKeyUp:Fire(keyCode)
	end

	InputController.OnInput:Fire({
		Type = "Key",
		KeyCode = keyCode,
		State = state,
	})
end

function InputController.HandleMouseButton(mouseButton: Enum.UserInputType, state: Enum.UserInputState)
	InputController.OnInput:Fire({
		Type = "MouseButton",
		Button = mouseButton,
		State = state,
		Position = MousePosition,
	})
end

function InputController.HandleGamepadInput(keyCode: Enum.KeyCode, state: Enum.UserInputState, input: InputObject)
	InputController.OnInput:Fire({
		Type = "Gamepad",
		KeyCode = keyCode,
		State = state,
		Position = input.Position,
		Delta = input.Delta,
	})

	-- Handle thumbsticks
	if keyCode == Enum.KeyCode.Thumbstick1 then
		InputController.OnInput:Fire({
			Type = "Thumbstick1",
			Position = input.Position,
		})
	elseif keyCode == Enum.KeyCode.Thumbstick2 then
		InputController.OnInput:Fire({
			Type = "Thumbstick2",
			Position = input.Position,
		})
	end
end

-- Handle input from init.client.luau
function InputController.HandleInput(input: InputObject, phase: "Began" | "Ended")
	if input.UserInputType == Enum.UserInputType.Keyboard then
		local state = phase == "Began" and Enum.UserInputState.Begin or Enum.UserInputState.End
		InputController.HandleKey(input.KeyCode, state)
	elseif input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.MouseButton2 then
		local state = phase == "Began" and Enum.UserInputState.Begin or Enum.UserInputState.End
		InputController.HandleMouseButton(input.UserInputType, state)
	elseif input.UserInputType == Enum.UserInputType.Gamepad1 then
		local state = phase == "Began" and Enum.UserInputState.Begin or Enum.UserInputState.End
		InputController.HandleGamepadInput(input.KeyCode, state, input)
	end
end

-- Getters
function InputController.IsKeyDown(keyCode: Enum.KeyCode): boolean
	return KeyStates[keyCode] == true
end

function InputController.GetMousePosition(): Vector2
	return MousePosition
end

function InputController.GetMouseDelta(): Vector2
	return MouseDelta
end

function InputController.GetInputMode(): string
	return CurrentInputMode
end

function InputController.IsGamepadConnected(): boolean
	return GamepadConnected
end

-- Check if movement keys are pressed
function InputController.GetMovementVector(): Vector2
	local x = 0
	local y = 0

	if InputController.IsKeyDown(Enum.KeyCode.W) or InputController.IsKeyDown(Enum.KeyCode.Up) then
		y += 1
	end
	if InputController.IsKeyDown(Enum.KeyCode.S) or InputController.IsKeyDown(Enum.KeyCode.Down) then
		y -= 1
	end
	if InputController.IsKeyDown(Enum.KeyCode.D) or InputController.IsKeyDown(Enum.KeyCode.Right) then
		x += 1
	end
	if InputController.IsKeyDown(Enum.KeyCode.A) or InputController.IsKeyDown(Enum.KeyCode.Left) then
		x -= 1
	end

	-- Gamepad thumbstick
	if CurrentInputMode == "Gamepad" then
		local gamepads = UserInputService:GetConnectedGamepads()
		if #gamepads > 0 then
			local state = UserInputService:GetGamepadState(gamepads[1])
			for _, input in ipairs(state) do
				if input.KeyCode == Enum.KeyCode.Thumbstick1 then
					x = input.Position.X
					y = -input.Position.Y
					break
				end
			end
		end
	end

	return Vector2.new(x, y)
end

function InputController.IsSprinting(): boolean
	if CurrentInputMode == "Gamepad" then
		local gamepads = UserInputService:GetConnectedGamepads()
		if #gamepads > 0 then
			return UserInputService:IsGamepadButtonDown(gamepads[1], Enum.KeyCode.ButtonL3)
		end
		return false
	end
	return InputController.IsKeyDown(Enum.KeyCode.LeftShift) or InputController.IsKeyDown(Enum.KeyCode.RightShift)
end

function InputController.IsJumpPressed(): boolean
	if CurrentInputMode == "Gamepad" then
		local gamepads = UserInputService:GetConnectedGamepads()
		if #gamepads > 0 then
			return UserInputService:IsGamepadButtonDown(gamepads[1], Enum.KeyCode.ButtonA)
		end
		return false
	end
	return InputController.IsKeyDown(Enum.KeyCode.Space)
end

-- Vibration feedback (gamepad)
function InputController.Vibrate(duration: number, intensity: number?)
	local gamepads = UserInputService:GetConnectedGamepads()
	if #gamepads == 0 then return end

	intensity = intensity or 1

	for _, gamepad in ipairs(gamepads) do
		UserInputService:SetGamepadVibration(gamepad, intensity, intensity)
	end

	task.delay(duration, function()
		for _, gamepad in ipairs(gamepads) do
			UserInputService:SetGamepadVibration(gamepad, 0, 0)
		end
	end)
end

-- Custom key binding support
function InputController.SetKeyBinding(action: string, keys: {Enum.KeyCode})
	if KeyBindings[action] then
		-- Unbind old keys
		for _, oldKey in ipairs(KeyBindings[action]) do
			ContextActionService:UnbindAction(action .. "_" .. oldKey.Name)
		end

		KeyBindings[action] = keys

		-- Bind new keys
		for _, key in ipairs(keys) do
			ContextActionService:BindAction(action .. "_" .. key.Name, function(_, state, input)
				InputController.HandleKey(input.KeyCode, state)
			end, false, key)
		end
	end
end

function InputController.GetKeyBinding(action: string): {Enum.KeyCode}?
	return KeyBindings[action]
end

function InputController.ResetKeyBindings()
	for action, keys in pairs(KeyBindings) do
		for _, key in ipairs(keys) do
			ContextActionService:UnbindAction(action .. "_" .. key.Name)
		end
	end

	-- Restore defaults
	KeyBindings = {
		MoveForward = {Enum.KeyCode.W, Enum.KeyCode.Up},
		MoveBackward = {Enum.KeyCode.S, Enum.KeyCode.Down},
		MoveLeft = {Enum.KeyCode.A, Enum.KeyCode.Left},
		MoveRight = {Enum.KeyCode.D, Enum.KeyCode.Right},
		Jump = {Enum.KeyCode.Space},
		Sprint = {Enum.KeyCode.LeftShift, Enum.KeyCode.RightShift},
		Interact = {Enum.KeyCode.E},
		Party = {Enum.KeyCode.P},
		Inventory = {Enum.KeyCode.I},
		Map = {Enum.KeyCode.M},
		Menu = {Enum.KeyCode.Escape},
		BattleMove1 = {Enum.KeyCode.One},
		BattleMove2 = {Enum.KeyCode.Two},
		BattleMove3 = {Enum.KeyCode.Three},
		BattleMove4 = {Enum.KeyCode.Four},
		BattleBack = {Enum.KeyCode.Backspace},
		CameraRotateLeft = {Enum.KeyCode.Q, Enum.KeyCode.Comma},
		CameraRotateRight = {Enum.KeyCode.E, Enum.KeyCode.Period},
		CameraZoomIn = {Enum.KeyCode.PageUp},
		CameraZoomOut = {Enum.KeyCode.PageDown},
	}

	InputController.BindActions()
end

return InputController