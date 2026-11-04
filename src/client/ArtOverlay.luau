--!nonstrict
-- Presentation only: never gates movement, net requests or profile loading.
local Tween = game:GetService("TweenService")
local Players = game:GetService("Players")
local Theme = require(script.Parent.UITheme)
local Icons = require(script.Parent.PixelIcons)
local A = {}
function A.loading(gui)
	local overlay = Instance.new("Frame")
	overlay.Name = "ArtLoading"
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Theme.Panel
	overlay.ZIndex = 100
	overlay.Active = false
	overlay.Parent = gui
	local center = Instance.new("Frame")
	center.AnchorPoint = Vector2.new(0.5, 0.5)
	center.Position = UDim2.fromScale(0.5, 0.5)
	center.Size = UDim2.new(0.92, 0, 0, 320)
	center.BackgroundTransparency = 1
	center.ZIndex = 101
	center.Parent = overlay
	local max = Instance.new("UISizeConstraint")
	max.MaxSize = Vector2.new(640, 320)
	max.Parent = center
	local skyline = Instance.new("Frame")
	skyline.Size = UDim2.fromOffset(176, 70)
	skyline.Position = UDim2.new(0.5, -88, 0, 0)
	skyline.BackgroundTransparency = 1
	skyline.ZIndex = 101
	skyline.Parent = center
	for index, kind in { "Natureza", "Fogo", "Agua", "Sombra", "Ar" } do
		local ramp = ({
			Theme.Tokens.Ramps.Leaf,
			Theme.Tokens.Ramps.Ember,
			Theme.Tokens.Ramps.Tidal,
			Theme.Tokens.Ramps.Veil,
			Theme.Tokens.Ramps.Sky,
		})[index]
		local icon = Icons.draw(skyline, kind, 2, ramp)
		icon.Position = UDim2.fromOffset((index - 1) * 36, index % 2 == 0 and 0 or 16)
		icon.ZIndex = 102
	end
	local title = Theme.label(center, "ARQUIPÉLAGO\nDAS FERAS", 32)
	title.Size = UDim2.new(1, 0, 0, 94)
	title.Position = UDim2.fromOffset(0, 84)
	title.TextColor3 = Theme.Accent
	title.ZIndex = 102
	local subtitle = Theme.label(center, "EXPLORAR  /  DESCOBRIR  /  CUIDAR", 14)
	subtitle.Size = UDim2.new(1, 0, 0, 28)
	subtitle.Position = UDim2.fromOffset(0, 188)
	subtitle.TextColor3 = Theme.Muted
	subtitle.ZIndex = 102
	local status = Theme.label(center, "Preparando sua expedição...", 16)
	status.Size = UDim2.new(1, -24, 0, 64)
	status.Position = UDim2.fromOffset(12, 236)
	status.ZIndex = 102
	local track = Instance.new("Frame")
	track.Size = UDim2.new(0.6, 0, 0, 4)
	track.Position = UDim2.new(0.2, 0, 0, 222)
	track.BackgroundColor3 = Theme.Edge
	track.BorderSizePixel = 0
	track.ZIndex = 102
	track.Parent = center
	for index = 1, 12 do
		local segment = Instance.new("Frame")
		segment.Size = UDim2.new(1 / 12, -3, 1, 0)
		segment.Position = UDim2.fromScale((index - 1) / 12, 0)
		segment.BorderSizePixel = 0
		segment.BackgroundColor3 = index % 3 == 0 and Theme.Mint or Theme.Accent
		segment.ZIndex = 103
		segment.Parent = track
	end
	local closed = false
	local handle = {}
	function handle.message(text)
		if not closed and status.Parent and text ~= "" then
			status.Text = text
		end
	end
	function handle.ready()
		if closed then
			return
		end
		closed = true
		local reduced = Players.LocalPlayer:GetAttribute("MotionReduced")
		if reduced then
			overlay:Destroy()
			return
		end
		Tween:Create(overlay, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
		for _, obj in overlay:GetDescendants() do
			if obj:IsA("TextLabel") then
				Tween:Create(obj, TweenInfo.new(0.25), { TextTransparency = 1 }):Play()
			elseif obj:IsA("Frame") then
				Tween:Create(obj, TweenInfo.new(0.25), { BackgroundTransparency = 1 }):Play()
			end
		end
		task.delay(0.28, function()
			overlay:Destroy()
		end)
	end
	return handle
end
return A
