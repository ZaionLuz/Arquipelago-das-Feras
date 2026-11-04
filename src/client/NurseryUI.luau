--!nonstrict
local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local C = require(RS.Shared.Creatures)
local Balance = require(RS.Shared.Economy)
local Preview = require(script.Parent.CollectionUI)
local Theme = require(script.Parent.UITheme)
local Icons = require(script.Parent.PixelIcons)
local N = {}
local function frame(parent, height)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -12, 0, height)
	f.BackgroundColor3 = Theme.Card
	f.Parent = parent
	Theme.panel(f)
	return f
end
local function text(parent, name, value, pos, size)
	local t = Instance.new("TextLabel")
	t.Name = name
	t.Text = value
	t.Position = pos
	t.Size = size
	t.BackgroundTransparency = 1
	t.TextColor3 = Theme.Ink
	t.TextSize = 14
	t.TextWrapped = true
	t.Font = Theme.Font
	t.Parent = parent
	return t
end
local function button(parent, name, value, x, callback)
	local b = Instance.new("TextButton")
	b.Name = name
	b.Text = value
	b.Position = UDim2.fromScale(x, 0.72)
	b.Size = UDim2.new(0.31, 0, 0, 44)
	b.BackgroundColor3 = Theme.Tokens.Ramps.Sand[2]
	b.TextColor3 = Theme.Ink
	b.Font = Theme.Font
	b.TextSize = 14
	b.Parent = parent
	b.Activated:Connect(callback)
	b.Active = true
	b.Selectable = true
	Theme.bind(b)
	return b
end
local function enabled(b, yes)
	b.Active = yes
	b.Selectable = yes
	b.AutoButtonColor = yes
	b.BackgroundTransparency = yes and 0 or 0.65
end
function N.egg(parent, def, left, hatch, speed)
	local f = frame(parent, 176)
	f.Name = "IncubatingEgg"
	f:SetAttribute("ReadyClock", os.clock() + left)
	local v = Instance.new("ViewportFrame")
	v.Size = UDim2.fromScale(0.3, 1)
	v.BackgroundTransparency = 1
	v.Ambient = Theme.Tokens.Ramps.Metal[3]
	v.LightColor = Theme.Ink
	v.LightDirection = Vector3.new(-1, -1, -1)
	v.Parent = f
	local egg = Instance.new("Part")
	egg.Shape = Enum.PartType.Ball
	egg.Size = Vector3.new(3, 4, 3)
	egg.Anchored = true
	egg.CanCollide = false
	egg.Color = Theme.Tokens.Elements[def.el][4]
	egg.Material = Enum.Material.SmoothPlastic
	egg.Parent = v
	for index = 1, 4 do
		local mark = Instance.new("Part")
		mark.Size = Vector3.new(0.32, 0.32, 0.08)
		mark.CFrame = CFrame.new((index % 2 == 0 and 1 or -1) * 0.55, (math.floor((index - 1) / 2) - 0.5) * 1.0, 1.4)
		mark.Anchored = true
		mark.CanCollide = false
		mark.CanQuery = false
		mark.CanTouch = false
		mark.Color = Theme.Tokens.Elements[def.el][2]
		mark.Parent = v
	end
	local icon = Icons.draw(f, "Egg", 16, Theme.Tokens.Elements[def.el])
	icon.Position = UDim2.fromOffset(8, 8)
	local gem = Instance.new("Part")
	gem.Shape = Enum.PartType.Ball
	gem.Size = Vector3.new(0.8, 1, 0.5)
	gem.Position = Vector3.new(0, 0.3, 1.4)
	gem.Anchored = true
	gem.Color = def.hybrid and Theme.Tokens.Elements[def.hybrid[2]][3] or Theme.Ink
	gem.Parent = v
	local camera = Instance.new("Camera")
	camera.CFrame = CFrame.lookAt(Vector3.new(4, 2, 9), Vector3.zero)
	camera.Parent = v
	v.CurrentCamera = camera
	text(f, "Element", Text.OVO_DE_763A79 .. def.el, UDim2.fromScale(0.32, 0.04), UDim2.fromScale(0.65, 0.22))
	text(f, "Countdown", "", UDim2.fromScale(0.32, 0.28), UDim2.fromScale(0.65, 0.36))
	button(f, "Hatch", "Chocar", 0.33, function()
		if os.clock() >= f:GetAttribute("ReadyClock") then
			hatch()
		end
	end)
	button(f, "Speed", "Acelerar", 0.66, speed)
	N.tick(parent)
	return f
end
function N.tick(parent)
	for _, f in parent:GetChildren() do
		if f.Name ~= "IncubatingEgg" then
			continue
		end
		local left = math.max(0, math.ceil(f:GetAttribute("ReadyClock") - os.clock()))
		f.Countdown.Text = left == 0 and Text.PRONTO_PARA_ECLODIR_379A20
			or (
				Text.INCUBANDO_75EABA
				.. left
				.. Text.S_ACELERAR_8DABB8
				.. math.max(1, math.ceil(left / 30))
				.. Text.GEMAS_BEE5F6
			)
		enabled(f.Hatch, left == 0)
		enabled(f.Speed, left > 0)
	end
end
function N.parents(parent, a, b, outcomes, available, breed)
	local f = frame(parent, 360)
	f.Name = "BreedingPreview"
	local names = {}
	for index, def in { a, b } do
		local holder = Instance.new("Frame")
		holder.Size = UDim2.fromScale(0.5, 0.52)
		holder.Position = UDim2.fromScale((index - 1) * 0.5, 0)
		holder.BackgroundTransparency = 1
		holder.Parent = f
		Preview.preview(holder, def, 1, false)
		text(holder, "Name", def.name .. " • " .. def.el, UDim2.fromScale(0, 0.65), UDim2.fromScale(1, 0.3))
	end
	for _, def in C.List do
		local chance = outcomes[def.id]
		if chance then
			table.insert(names, def.name .. " " .. string.format("%.1f%%", chance * 100))
		end
	end
	text(f, "Outcomes", table.concat(names, " • "), UDim2.fromScale(0.03, 0.5), UDim2.fromScale(0.94, 0.2)).TextSize =
		12
	text(
		f,
		"Cost",
		Text.CUSTO_805D21
			.. Balance.BreedCost
			.. Text.OURO_INCUBACAO_30480S_E8C4B8
			.. (available and Text.CHOCADEIRA_DISPONIVEL_F42230 or Text.PRECISA_DE_OURO_E_VAGA_NA_CHOCADEIRA_7FC4F9),
		UDim2.fromScale(0.03, 0.7),
		UDim2.fromScale(0.94, 0.14)
	)
	local start = button(f, "Breed", "Cruzar", 0.33, breed)
	start.Position = UDim2.new(0.15, 0, 1, -52)
	start.Size = UDim2.new(0.7, 0, 0, 44)
	enabled(start, available)
	return f
end
return N
