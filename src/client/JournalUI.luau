--!nonstrict
local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local C = require(RS.Shared.Creatures)
local I = require(RS.Shared.Islands)
local E = require(RS.Shared.Elements)
local Preview = require(script.Parent.CollectionUI)
local Theme = require(script.Parent.UITheme)
local Lore = require(RS.Shared.SpeciesLore)
local J = {}
local selected = "cinzelo"
local rarity = 0
local island = 0
local element = 0
local search = ""
function J.select(id)
	if not C.ById[id] then
		return false
	end
	selected = id
	rarity = 0
	island = 0
	element = 0
	search = ""
	return true
end
local function frame(parent, height)
	local f = Instance.new("Frame")
	f.Size = UDim2.new(1, -8, 0, height)
	f.BackgroundColor3 = Theme.Card
	f.Parent = parent
	Theme.panel(f)
	return f
end
function J.render(parent, s, render)
	local container = parent:FindFirstChild("BestiaryPanel")
	if not container then
		container = frame(parent, 500)
		container.Name = "BestiaryPanel"
		container.BackgroundTransparency = 1
		local layout = Instance.new("UIListLayout")
		layout.Padding = UDim.new(0, 8)
		layout.SortOrder = Enum.SortOrder.LayoutOrder
		layout.Parent = container
	end
	for _, child in container:GetChildren() do
		if child:IsA("Frame") and child.Name ~= "MainPreview" then
			child:Destroy()
		end
	end
	local filters = frame(container, 100)
	filters.LayoutOrder = 1
	filters.BackgroundTransparency = 1
	local choices = {
		{
			Text.RARIDADE_9F174D .. (C.Rarity[rarity] or "Todas"),
			function()
				rarity = (rarity + 1) % 5
				render()
			end,
		},
		{
			Text.BIOMA_94C907 .. (island == 0 and "Todos" or I.List[island].name),
			function()
				island = (island + 1) % (#I.List + 1)
				render()
			end,
		},
		{
			Text.ELEMENTO_BB6BA8 .. (E.List[element] or "Todos"),
			function()
				element = (element + 1) % 7
				render()
			end,
		},
	}
	for index, entry in choices do
		local b = Theme.button(filters, entry[1], entry[2])
		b.Position = UDim2.new((index - 1) % 2 * 0.5, 2, 0, math.floor((index - 1) / 2) * 50)
		b.Size = UDim2.new(0.5, -4, 0, 46)
	end
	local box = Instance.new("TextBox")
	box.PlaceholderText = Text.BUSCAR_ESPECIE_09F339
	box.Text = search
	box.TextSize = 16
	box.Font = Theme.Font
	box.ClearTextOnFocus = false
	box.Size = UDim2.new(0.5, -4, 0, 46)
	box.Position = UDim2.new(0.5, 2, 0, 50)
	box.BackgroundColor3 = Theme.Card
	box.TextColor3 = Theme.Ink
	box.PlaceholderColor3 = Theme.Muted
	box.Parent = filters
	Theme.round(box)
	box.FocusLost:Connect(function()
		search = string.sub(box.Text, 1, 40)
		render()
	end)
	local def = C.ById[selected]
	local known = s.discovered[selected]
	local lv, count = 1, 0
	for _, cr in s.creatures do
		if cr.id == selected then
			count += 1
			lv = math.max(lv, cr.lv)
		end
	end
	local card = container:FindFirstChild("MainPreview") or frame(container, 360)
	card.Name = "MainPreview"
	card.LayoutOrder = 2
	for _, child in card:GetChildren() do
		if child:IsA("TextLabel") then
			child:Destroy()
		end
	end
	Preview.preview(card, def, lv, not known)
	local info = Theme.label(card, "", 14)
	info.Position = UDim2.fromScale(0.03, 0.66)
	info.Size = UDim2.fromScale(0.94, 0.33)
	info.TextXAlignment = Enum.TextXAlignment.Left
	info.TextYAlignment = Enum.TextYAlignment.Top
	info.Text = known
			and (def.name .. " • " .. def.el .. " • " .. C.Rarity[def.rar] .. "\n" .. (I.ById[def.island] and I.ById[def.island].name or Text.HIBRIDO_9CB40A) .. Text.COLECAO_57798D .. count .. Text.NV_AE0838 .. lv .. Text.ESTAGIO_D2FEE2 .. C.stage(
				lv,
				def.id
			) .. (def.id == "fenix" and Text.RENASCIMENTO_FUTURO_9236DA or Text.EVOLUI_EM_7_15_75E2ED))
		or (
			def.acquisition == "special" and Text.VESTIGIOS_DE_UMA_ESPECIE_DESCONHECIDA_B8DB43
			or Text.ESPECIE_MISTERIOSA_EXPLORE_CAPTURE_OU_CRUZE_FERA_6D0C6C
		)
	if known and Lore[def.id] then
		info.Text ..= "\n" .. Lore[def.id].description .. " • " .. Lore[def.id].personality
	end
	local matches = {}
	for _, entry in C.List do
		local found = s.discovered[entry.id]
		if
			(rarity == 0 or entry.rar == rarity)
			and (island == 0 or entry.island == I.List[island].id)
			and (element == 0 or entry.el == E.List[element])
			and (search == "" or (found and string.find(string.lower(entry.name), string.lower(search), 1, true)))
		then
			table.insert(matches, entry)
		end
	end
	if #matches == 0 then
		local f = frame(container, 50)
		container.Size = UDim2.new(1, -8, 0, 540)
		local l = Theme.label(f, Text.NENHUMA_ESPECIE_CORRESPONDE_AOS_FILTROS_7AC10E, 14)
		l.Size = UDim2.fromScale(1, 1)
		return
	end
	local columns = parent.AbsoluteSize.X >= 390 and 3 or 2
	container.Size = UDim2.new(1, -8, 0, 480 + math.ceil(#matches / columns) * 148)
	local grid = frame(container, math.ceil(#matches / columns) * 148)
	grid.LayoutOrder = 3
	grid.BackgroundTransparency = 1
	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(1 / columns, -7, 0, 140)
	layout.CellPadding = UDim2.fromOffset(7, 8)
	layout.SortOrder = Enum.SortOrder.LayoutOrder
	layout.Parent = grid
	for index, entry in matches do
		local found = s.discovered[entry.id]
		local tile = Instance.new("Frame")
		tile.LayoutOrder = index
		tile.BackgroundColor3 = entry.id == selected and Theme.Tokens.Elements[entry.el][1] or Theme.Card
		tile.Parent = grid
		Theme.panel(tile, entry.id == selected and Theme.Tokens.Elements[entry.el][4] or Theme.Edge)
		local mini
		local function visibility()
			if not tile.Parent then
				return
			end
			local top = parent.AbsolutePosition.Y
			local y = tile.AbsolutePosition.Y
			local visible = parent.Visible and y + 140 >= top and y < top + parent.AbsoluteSize.Y
			if visible and not mini then
				mini = Preview.preview(tile, entry, 1, not found)
				mini.Size = UDim2.fromScale(1, 0.72)
			elseif not visible and mini then
				mini:Destroy()
				mini = nil
			end
		end
		local scroll = parent:GetPropertyChangedSignal("CanvasPosition"):Connect(visibility)
		local visible = parent:GetPropertyChangedSignal("Visible"):Connect(visibility)
		local pos = tile:GetPropertyChangedSignal("AbsolutePosition"):Connect(visibility)
		tile.Destroying:Connect(function()
			scroll:Disconnect()
			visible:Disconnect()
			pos:Disconnect()
		end)
		task.defer(visibility)
		local choose = Theme.button(tile, found and entry.name or "???", function()
			selected = entry.id
			render()
		end)
		choose.Position = UDim2.new(0, 0, 1, -44)
		choose.Size = UDim2.new(1, 0, 0, 44)
		choose.TextSize = 12
	end
end
return J
