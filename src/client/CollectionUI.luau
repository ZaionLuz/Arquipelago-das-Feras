--!nonstrict
local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local C = require(RS.Shared.Creatures)
local E = require(RS.Shared.Elements)
local MF = require(RS.Shared.ModelFactory)
local Animator = require(script.Parent.CreatureAnimator)
local UI = { rebuilds = 0 }
function UI.visible(object)
	while object do
		if object:IsA("GuiObject") and not object.Visible then
			return false
		end
		if object:IsA("ScreenGui") and not object.Enabled then
			return false
		end
		object = object.Parent
	end
	return true
end
local function label(parent, text, pos, size)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Position = pos
	t.Size = size
	t.Text = text
	t.TextWrapped = true
	t.Font = Enum.Font.GothamBold
	t.TextSize = 16
	t.TextColor3 = Color3.new(1, 1, 1)
	t.Parent = parent
	return t
end
function UI.preview(parent, def, lv, unknown)
	local key = def.id .. ":" .. C.stage(lv, def.id) .. ":" .. tostring(unknown)
	local v = parent:FindFirstChild("CreaturePreview")
	if v and v:GetAttribute("PreviewKey") == key then
		return v
	end
	if not v then
		v = Instance.new("ViewportFrame")
		v.Name = "CreaturePreview"
		v.Size = UDim2.fromScale(1, 0.65)
		v.BackgroundTransparency = 1
		v.Ambient = Color3.fromRGB(185, 185, 200)
		v.LightColor = Color3.new(1, 1, 1)
		v.Parent = parent
	else
		v:ClearAllChildren()
	end
	v:SetAttribute("PreviewKey", key)
	local world = Instance.new("WorldModel")
	world.Parent = v
	local model = MF.build(unknown and def.acquisition == "special" and C.ById.cinzelo or def, lv, { preview = true })
	UI.rebuilds += 1
	for _, obj in model:GetDescendants() do
		if obj:IsA("BillboardGui") then
			obj:Destroy()
		elseif unknown and obj:IsA("BasePart") then
			obj.Color = Color3.fromRGB(25, 25, 40)
			obj.Material = Enum.Material.SmoothPlastic
		end
	end
	model.Parent = world
	local low, high = MF.bounds(model)
	local size = high - low
	local center = (low + high) * 0.5
	local camera = Instance.new("Camera")
	camera.FieldOfView = 40
	local distance = math.max(size.X, size.Y, size.Z) * 2
	camera.CFrame = CFrame.lookAt(center + Vector3.new(distance * 0.55, distance * 0.25, distance), center)
	camera.Parent = v
	v.CurrentCamera = camera
	Animator.register(model, function()
		return v.Parent ~= nil and UI.visible(v)
	end, { camera = camera, center = center, distance = distance })
	return v
end
function UI.card(parent, def, lv, known, order)
	local card = Instance.new("Frame")
	card.Name = "CollectionCard"
	card.LayoutOrder = order
	card.Size = UDim2.new(1, -12, 0, 190)
	card.BackgroundColor3 = known and E.Color[def.el]:Lerp(Color3.fromRGB(20, 20, 40), 0.65)
		or Color3.fromRGB(35, 35, 50)
	card.Parent = parent
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 12)
	corner.Parent = card
	local preview
	local function visible()
		if not card.Parent then
			return
		end
		local y = card.AbsolutePosition.Y
		local top = parent.AbsolutePosition.Y
		local shown = y + card.AbsoluteSize.Y >= top and y <= top + parent.AbsoluteSize.Y
		if shown and not preview then
			preview = UI.preview(card, def, lv, not known)
		elseif not shown and preview then
			preview:Destroy()
			preview = nil
		end
	end
	local connection = parent:GetPropertyChangedSignal("CanvasPosition"):Connect(visible)
	local resize = parent:GetPropertyChangedSignal("AbsoluteSize"):Connect(visible)
	card.Destroying:Connect(function()
		connection:Disconnect()
		resize:Disconnect()
	end)
	task.defer(visible)
	label(
		card,
		known and def.name or Text.ESPECIE_DESCONHECIDA_6C9CF9,
		UDim2.fromScale(0, 0.65),
		UDim2.fromScale(1, 0.15)
	)
	label(
		card,
		known and (def.el .. " • " .. C.Rarity[def.rar] .. Text.NV_9D89AA .. lv) or Text.DESCUBRA_NOVOS_OVOS_38146F,
		UDim2.fromScale(0, 0.8),
		UDim2.fromScale(1, 0.18)
	).TextSize =
		12
	return card
end
function UI.discovery(gui, def, lv, evolved)
	local overlay = Instance.new("Frame")
	overlay.Size = UDim2.fromScale(1, 1)
	overlay.BackgroundColor3 = Color3.fromRGB(12, 10, 30)
	overlay.BackgroundTransparency = 0.08
	overlay.ZIndex = 30
	overlay.Parent = gui
	local panel = Instance.new("Frame")
	panel.Size = UDim2.fromScale(0.8, 0.8)
	panel.Position = UDim2.fromScale(0.1, 0.1)
	panel.BackgroundColor3 = E.Color[def.el]:Lerp(Color3.fromRGB(20, 20, 40), 0.65)
	panel.Parent = overlay
	Instance.new("UICorner", panel).CornerRadius = UDim.new(0, 20)
	UI.preview(panel, def, lv, false)
	label(
		panel,
		evolved and Text.SUA_FERA_EVOLUIU_0ACEF1
			or (def.rar >= 3 and Text.ECLOSAO_EXTRAORDINARIA_EA7909 or Text.UMA_FERA_NASCEU_A8EB6A),
		UDim2.fromScale(0, 0),
		UDim2.fromScale(1, 0.12)
	)
	label(
		panel,
		def.name .. " • " .. C.Rarity[def.rar] .. Text.NV_9D89AA .. lv,
		UDim2.fromScale(0, 0.68),
		UDim2.fromScale(1, 0.12)
	)
	label(
		panel,
		Text.VIDA_41EF99
			.. def.hp
			.. Text.ATAQUE_4EE034
			.. def.atk
			.. Text.OURO_MIN_BASE_C8313A
			.. def.gpm
			.. Text.ESTAGIO_D2FEE2
			.. C.stage(lv, def.id),
		UDim2.fromScale(0.05, 0.77),
		UDim2.fromScale(0.9, 0.06)
	).TextSize =
		12
	local close = Instance.new("TextButton")
	close.Size = UDim2.fromScale(0.8, 0.13)
	close.Position = UDim2.fromScale(0.1, 0.84)
	close.Text = Text.CONTINUAR_AVENTURA_E2F9B1
	close.TextSize = 18
	close.Font = Enum.Font.GothamBold
	close.BackgroundColor3 = Color3.fromRGB(255, 200, 90)
	close.Parent = panel
	close.Selectable = true
	close.Activated:Connect(function()
		overlay:Destroy()
	end)
	-- Segurança: nunca bloquear permanentemente por menu fechado ou controle perdido.
	task.delay(20, function()
		if overlay.Parent then
			overlay:Destroy()
		end
	end)
	return overlay
end
return UI
