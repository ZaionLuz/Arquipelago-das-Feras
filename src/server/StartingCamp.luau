--!nonstrict
local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local I = require(game:GetService("ReplicatedStorage").Shared.Islands)
local C = {}
function C.build()
	local parent = Instance.new("Model")
	parent.Name = Text.ACAMPAMENTO_DO_ALVORECER_EBD2E1
	parent.Parent = workspace
	local center = I.pos(1)
	local function part(size, offset, color, material, shape)
		local p = Instance.new("Part")
		p.Size = size
		p.Position = center + offset
		p.Anchored = true
		p.CanCollide = false
		p.CanTouch = false
		p.Color = color
		p.Material = material or Enum.Material.Wood
		p.Shape = shape or Enum.PartType.Block
		p.Parent = parent
		return p
	end
	-- Gazebo de pesquisa e fonte baixa. Centro, spawn e passagem até as pontes livres.
	for _, x in { -1, 1 } do
		for _, z in { -1, 1 } do
			part(Vector3.new(1, 9, 1), Vector3.new(-20 + x * 5, 8, -17 + z * 5), Color3.fromRGB(91, 74, 60))
		end
	end
	local _roof = part(
		Vector3.new(15, 3, 15),
		Vector3.new(-20, 13, -17),
		Color3.fromRGB(81, 136, 130),
		Enum.Material.SmoothPlastic,
		Enum.PartType.Ball
	)
	part(Vector3.new(9, 1, 5), Vector3.new(-20, 6, -17), Color3.fromRGB(159, 128, 89))
	local _bowl = part(
		Vector3.new(8, 2, 8),
		Vector3.new(22, 5, -16),
		Color3.fromRGB(158, 177, 163),
		Enum.Material.Slate,
		Enum.PartType.Ball
	)
	local water = part(
		Vector3.new(6, 0.3, 6),
		Vector3.new(22, 6, -16),
		Color3.fromRGB(109, 199, 217),
		Enum.Material.Glass,
		Enum.PartType.Ball
	)
	water.Transparency = 0.3
	for i = 1, 5 do
		local a = i * math.pi * 2 / 5
		part(
			Vector3.new(2.5, 0.4, 1.6),
			Vector3.new(22 + math.cos(a) * 4, 4.3, -16 + math.sin(a) * 4),
			Color3.fromRGB(229, 174, 191),
			Enum.Material.SmoothPlastic,
			Enum.PartType.Ball
		)
	end
end
return C
