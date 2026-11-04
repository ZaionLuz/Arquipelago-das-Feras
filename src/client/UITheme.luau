--!nonstrict
local Tokens = require(game:GetService("ReplicatedStorage").Shared.ArtTokens)
local T = {
	Ink = Tokens.Ink,
	Muted = Tokens.Muted,
	Panel = Tokens.Panel,
	Card = Tokens.Card,
	Accent = Tokens.Accent,
	Mint = Tokens.Mint,
	Edge = Tokens.Edge,
	Shadow = Tokens.Shadow,
	Font = Tokens.Font,
	Tokens = Tokens,
}
function T.round(o, _radius)
	local existing = o:FindFirstChild("PixelCorner")
	if existing then
		return existing
	end
	local corner = Instance.new("UICorner")
	corner.Name = "PixelCorner"
	corner.CornerRadius = UDim.new(0, 2)
	corner.Parent = o
	o.BorderSizePixel = 0
	return corner
end
function T.stroke(o)
	local existing = o:FindFirstChild("PixelEdge")
	if existing then
		return existing
	end
	local stroke = Instance.new("UIStroke")
	stroke.Name = "PixelEdge"
	stroke.Color = T.Edge
	stroke.Transparency = 0
	stroke.Thickness = Tokens.Border
	stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	stroke.Parent = o
	return stroke
end
function T.panel(o, accent)
	T.round(o)
	local stroke = T.stroke(o)
	stroke.Color = accent or T.Edge
	return o
end
function T.bind(button)
	if button:GetAttribute("ArtButton") then
		return
	end
	button:SetAttribute("ArtButton", true)
	button.AutoButtonColor = false
	button.Selectable = true
	button.Font = T.Font
	local edge = T.stroke(button)
	T.round(button)
	local normal = button.BackgroundColor3
	local normalText = button.TextColor3
	local hover, pressed, updating = false, false, false
	local function refresh()
		updating = true
		local disabled = not button.Active or not button.Selectable
		button.BackgroundColor3 = disabled and T.Panel
			or pressed and T.Edge
			or hover and Tokens.nearest(normal:Lerp(T.Mint, 0.3))
			or normal
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
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
			pressed = true
			refresh()
		end
	end)
	button.InputEnded:Connect(function(input)
		if
			input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch
		then
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
			normal = button.BackgroundColor3
			refresh()
		end
	end)
	refresh()
end
function T.label(parent, text, size)
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
function T.button(parent, text, callback)
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
return T
