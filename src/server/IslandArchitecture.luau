--!nonstrict
-- Silhueta estratificada cenográfica; piso e colisão originais ficam em World.
local T = require(game:GetService("ReplicatedStorage").Shared.ArtTokens)
local A = {}
local V = Vector3.new
function A.build(parent, center, def)
	local group = Instance.new("Folder")
	group.Name = "Geologia_" .. def.id
	group.Parent = parent
	local ramp = T.ramp(def.id)
	local function slab(size, offset, color, rotation, kind)
		local p = Instance.new(kind == "wedge" and "WedgePart" or "Part")
		p.Name = "Estrato"
		p.Size = size
		p.CFrame = CFrame.new(center + offset) * (rotation or CFrame.identity)
		p.Color = color
		p.Material = Enum.Material.SmoothPlastic
		p.Anchored = true
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.Parent = group
		return p
	end
	-- Grandes planos recortados, com bordas quentes em cima e sombras frias abaixo.
	for tier = 1, 3 do
		local radius = 37 - tier * 3.5
		for side = 1, 8 do
			local angle = side * math.pi / 4
			slab(
				V(24, 4.5, 9),
				V(math.cos(angle) * radius, -tier * 4 + 1, math.sin(angle) * radius),
				ramp[math.max(1, 4 - tier)],
				CFrame.Angles(0, -angle + math.pi / 2, 0.06 * (side % 2)),
				tier == 3 and "wedge" or nil
			)
		end
	end
	slab(V(38, 8, 38), V(0, -9, 0), ramp[1], CFrame.Angles(0, math.pi / 4, 0), "wedge")
	-- Veios de cor mantêm o mesmo material fosco e não criam pontos luminosos sem motivo.
	for index = 1, 4 do
		local angle = index * math.pi / 2 + 0.3
		slab(
			V(8, 0.7, 1.4),
			V(math.cos(angle) * 35, -3.2, math.sin(angle) * 35),
			ramp[3],
			CFrame.Angles(0, -angle + math.pi / 2, 0)
		)
	end
	return group
end
return A
