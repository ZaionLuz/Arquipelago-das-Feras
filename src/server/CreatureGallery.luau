--!nonstrict
-- Ferramenta explícita de revisão; nunca construída em servidor publicado.
local Run = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local C = require(RS.Shared.Creatures)
local Factory = require(RS.Shared.ModelFactory)
local Gallery = {}
function Gallery.build()
	assert(Run:IsStudio(), "A galeria só funciona no Studio")
	local previous = workspace:FindFirstChild("GaleriaV7")
	if previous then
		previous:Destroy()
	end
	local folder = Instance.new("Folder")
	folder.Name = "GaleriaV7"
	folder.Parent = workspace
	local function display(def, lv, index)
		local point = Vector3.new((index - 1) % 9 * 28, 110, math.floor((index - 1) / 9) * 28)
		local stand = Instance.new("Part")
		stand.Size = Vector3.new(22, 1, 22)
		stand.Position = point
		stand.Anchored = true
		stand.Color = Color3.fromRGB(40, 49, 59)
		stand.Parent = folder
		local model
		local function replace(level)
			if model then
				model:Destroy()
			end
			model = Factory.build(def, level, { preview = true })
			local cf, size = model:GetBoundingBox()
			local lift = model:GetPivot().Position.Y - (cf.Position.Y - size.Y / 2)
			model:PivotTo(CFrame.new(point + Vector3.new(0, lift + 0.5, 0)))
			model:SetAttribute("Gallery", true)
			model.Parent = folder
		end
		replace(lv)
		local label = Instance.new("BillboardGui")
		label.Size = UDim2.fromOffset(210, 54)
		label.StudsOffset = Vector3.new(0, 10, 0)
		label.MaxDistance = 160
		label.Parent = stand
		local text = Instance.new("TextLabel")
		text.Size = UDim2.fromScale(1, 1)
		text.BackgroundTransparency = 1
		text.Text = def.name .. " · Nv." .. lv .. " · estágio " .. C.stage(lv, def.id)
		text.TextColor3 = Color3.new(1, 1, 1)
		text.TextSize = 15
		text.Font = Enum.Font.GothamBold
		text.Parent = label
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = "Alternar estágio"
		prompt.ObjectText = def.name
		prompt.MaxActivationDistance = 14
		prompt.Parent = stand
		local choice = table.find({ 1, 7, 15 }, lv) or 3
		prompt.Triggered:Connect(function()
			choice = choice % 3 + 1
			local level = ({ 1, 7, 15 })[choice]
			replace(level)
			text.Text = def.name .. " · Nv." .. level .. " · estágio " .. C.stage(level, def.id)
		end)
	end
	local index = 0
	for _, def in C.List do
		for _, lv in { 1, 7, 15 } do
			index += 1
			display(def, lv, index)
		end
	end
	display(C.ById.fenix, 60, 91)
	return folder
end
return Gallery
