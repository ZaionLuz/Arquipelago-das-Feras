--!nonstrict
local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local C = require(RS.Shared.Creatures)
local MF = require(RS.Shared.ModelFactory)
local Animator = require(script.Parent.CreatureAnimator)
local Theme = require(script.Parent.UITheme)
local Icons = require(script.Parent.PixelIcons)
local UI = { rebuilds = 0 }
local function rect(object)
	local available, size, pos = pcall(function()
		return object.AbsoluteSize, object.AbsolutePosition
	end)
	if available and size and pos and size.X > 0 and size.Y > 0 then
		return pos.X, pos.Y, pos.X + size.X, pos.Y + size.Y
	end
	return nil
end
function UI.visible(object)
	local left, top, right, bottom
	if object and object:IsA("GuiObject") then
		left, top, right, bottom = rect(object)
	end
	while object do
		if object:IsA("GuiObject") then
			if not object.Visible then
				return false
			end
			if left and object.ClipsDescendants then
				local clipLeft, clipTop, clipRight, clipBottom = rect(object)
				if clipLeft then
					left, top = math.max(left, clipLeft), math.max(top, clipTop)
					right, bottom = math.min(right, clipRight), math.min(bottom, clipBottom)
					if right <= left or bottom <= top then
						return false
					end
				end
			end
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
	t.Font = Theme.Font
	t.TextSize = 16
	t.TextColor3 = Theme.Ink
	t.Parent = parent
	return t
end
function UI.preview(parent, def, lv, unknown)
	if not parent then
		return nil
	end
	local v = parent:FindFirstChild("CreaturePreview")
	-- A visualização só é montada quando o contêiner está visível.
	if not UI.visible(parent) then
		return v
	end
	local detail = MF.detailKey()
	local key = def.id .. ":" .. C.stage(lv, def.id) .. ":" .. tostring(unknown) .. ":" .. detail
	if v and v:GetAttribute("PreviewKey") == key then
		return v
	end
	if not v then
		v = Instance.new("ViewportFrame")
		v.Name = "CreaturePreview"
		v.Size = UDim2.fromScale(1, 0.65)
		v.BackgroundTransparency = 1
		v.Ambient = Theme.Tokens.Ramps.Metal[3]
		v.LightDirection = Vector3.new(-1, -1, -1)
		v.LightColor = Theme.Tokens.Ink
		v.Parent = parent
	else
		v:ClearAllChildren()
	end
	v:SetAttribute("PreviewKey", key)
	local world = Instance.new("WorldModel")
	world.Parent = v
	local model = MF.build(
		unknown and def.acquisition == "special" and C.ById.cinzelo or def,
		lv,
		{ preview = true, detail = detail }
	)
	UI.rebuilds += 1
	for _, obj in model:GetDescendants() do
		if obj:IsA("BillboardGui") then
			obj:Destroy()
		elseif unknown and obj:IsA("BasePart") then
			obj.Color = Theme.Tokens.Ramps.Veil[1]
			obj.Material = Enum.Material.SmoothPlastic
		end
	end
	model.Parent = world
	local low, high = MF.bounds(model)
	local size = high - low
	local center = (low + high) * 0.5
	local ramp = Theme.Tokens.Elements[def.el] or Theme.Tokens.Ramps.Metal
	local width = math.max(size.X, size.Z) * 0.85
	for index = 1, 2 do
		local floor = Instance.new("Part")
		floor.Name = "SpecimenPlinth" .. index
		floor.Size = Vector3.new(width + (2 - index) * 0.5, 0.18, width * 0.65 + (2 - index) * 0.5)
		floor.CFrame = CFrame.new(center.X, low.Y - 0.4 + index * 0.18, center.Z)
		floor.Color = ramp[index == 1 and 1 or 2]
		floor.Material = Enum.Material.SmoothPlastic
		floor.Anchored = true
		floor.CanCollide = false
		floor.CanQuery = false
		floor.CanTouch = false
		floor.CastShadow = false
		floor.Parent = world
	end
	local camera = Instance.new("Camera")
	camera.FieldOfView = 40
	local distance = math.max(size.X, size.Y, size.Z) * 2
	camera.CFrame = CFrame.lookAt(center + Vector3.new(distance * 0.55, distance * 0.25, distance), center)
	camera.Parent = v
	v.CurrentCamera = camera
	Animator.register(model, function()
		return model.Parent ~= nil and v.Parent ~= nil and UI.visible(v)
	end, { camera = camera, center = center, distance = distance })
	return v
end
function UI.card(parent, def, lv, known, order)
	local card = Instance.new("Frame")
	card.Name = "CollectionCard"
	card.LayoutOrder = order
	card.Size = UDim2.new(1, -12, 0, 190)
	card.BackgroundColor3 = known and Theme.Tokens.Elements[def.el][1] or Theme.Panel
	card.Parent = parent
	Theme.panel(card, known and Theme.Tokens.Elements[def.el][3] or Theme.Edge)
	local emblem = Icons.draw(card, def.el, 16, Theme.Tokens.Elements[def.el])
	emblem.Position = UDim2.fromOffset(8, 8)
	local preview
	local function visible()
		if not card.Parent then
			return
		end
		local y = card.AbsolutePosition.Y
		local top = parent.AbsolutePosition.Y
		local shown = UI.visible(card) and y + card.AbsoluteSize.Y >= top and y <= top + parent.AbsoluteSize.Y
		if shown then
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
	overlay.BackgroundColor3 = Theme.Panel
	overlay.BackgroundTransparency = 0.08
	overlay.ZIndex = 30
	overlay.Parent = gui
	local panel = Instance.new("Frame")
	panel.Size = UDim2.fromScale(0.8, 0.8)
	panel.Position = UDim2.fromScale(0.1, 0.1)
	panel.BackgroundColor3 = Theme.Tokens.Elements[def.el][1]
	panel.Parent = overlay
	Theme.panel(panel, Theme.Tokens.Elements[def.el][4])
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
	close.Size = UDim2.new(0.8, 0, 0, 44)
	close.Position = UDim2.new(0.1, 0, 1, -56)
	close.Text = Text.CONTINUAR_AVENTURA_E2F9B1
	close.TextSize = 18
	close.Font = Theme.Font
	close.BackgroundColor3 = Theme.Tokens.Elements[def.el][2]
	close.Parent = panel
	close.Active = true
	close.Selectable = true
	Theme.bind(close)
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
