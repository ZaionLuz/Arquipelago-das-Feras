--!nonstrict
local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local I = require(RS.Shared.Islands)
local Rules = require(RS.Shared.SanctuaryRules)
local Theme = require(script.Parent.UITheme)
local U = {}
local slot = 5
function U.render(parent, d, call, render)
	local function card(height)
		local f = Instance.new("Frame")
		f.Size = UDim2.new(1, -8, 0, height)
		f.BackgroundColor3 = Theme.Card
		f.Parent = parent
		Theme.round(f)
		return f
	end
	local info = card(70)
	local t = Theme.label(info, Text.SEU_SANTUARIO_9_POSICOES_SELECIONE_UMA_POSICAO_E_400064, 14)
	t.Size = UDim2.fromScale(1, 1)
	local travel = card(48)
	local home = Theme.button(travel, Text.VISITAR_MEU_SANTUARIO_A636DA, function()
		call("Home")
	end)
	home.Size = UDim2.fromScale(0.5, 1)
	local pet = Theme.button(travel, Text.ACARICIAR_COMPANHEIRO_6D295C, function()
		call("Pet")
	end)
	pet.Size = UDim2.fromScale(0.5, 1)
	pet.Position = UDim2.fromScale(0.5, 0)
	local grid = card(164)
	grid.BackgroundTransparency = 1
	local layout = Instance.new("UIGridLayout")
	layout.CellSize = UDim2.new(1 / 3, -6, 0, 50)
	layout.CellPadding = UDim2.fromOffset(6, 6)
	layout.Parent = grid
	for index = 1, 9 do
		local occupied
		for id, entry in d.sanctuary do
			if entry.slot == index then
				occupied = I.ById[id].el
			end
		end
		local b = Theme.button(grid, index .. " • " .. (occupied or "Livre"), function()
			slot = index
			render()
		end)
		if slot == index then
			b.BackgroundColor3 = Color3.fromRGB(78, 110, 94)
		end
	end
	for _, def in I.List do
		local entry = d.sanctuary[def.id]
		local f = card(156)
		local label = Theme.label(
			f,
			def.name
				.. " • "
				.. def.el
				.. "\n"
				.. (
					entry
						and Text.NIVEL_2EE2A0 .. entry.level .. Text.POSICAO_26334E .. entry.slot .. " • " .. #(d.habitat[def.id] or {}) .. "/" .. Rules.capacity(
							def,
							entry
						) .. Text.FERAS_C56D89
					or Text.CONSTRUIR_BB999C .. Rules.buildCost(def) .. Text.OURO_6C9D60
				),
			14
		)
		label.Size = UDim2.new(1, -12, 0, 90)
		label.Position = UDim2.fromOffset(6, 0)
		local buttons = entry
				and {
					{
						Text.MOVER_7D5F11 .. slot,
						function()
							call("MoveHabitat", def.id, slot)
						end,
					},
					{
						Text.MELHORAR_5E30CA .. Rules.upgradeCost(entry),
						function()
							call("UpgradeHabitat", def.id)
						end,
					},
					{
						"Remover",
						function()
							call("RemoveHabitat", def.id)
						end,
					},
				}
			or {
				{
					d.unlocked[def.id] and Text.CONSTRUIR_NA_POSICAO_AF4C45 .. slot or Text.DESBLOQUEIE_A_ILHA_CC6976,
					function()
						call("BuildHabitat", def.id, slot)
					end,
				},
			}
		for k, button in buttons do
			local b = Theme.button(f, button[1], button[2])
			b.Size = UDim2.new(1 / #buttons, -6, 0, 48)
			b.Position = UDim2.new((k - 1) / #buttons, 3, 1, -54)
		end
	end
end
return U
