--!nonstrict
-- Cenografia apenas local para WorldModel; não conhece serviços, jogadores nem estado de batalha.
local RS = game:GetService("ReplicatedStorage")
local Art = require(RS.Shared.ArtTokens)
local S = { Budget = 190 }
local V = Vector3.new
function S.resolve(def)
	if Art.Biomes[def.island] then
		return def.island
	end
	return ({
		Fogo = "Brasa",
		["Água"] = "Recife",
		Natureza = "Floresta",
		Terra = "Dunas",
		Ar = "Picos",
		Sombra = "Pantano",
	})[def.el] or "Alvorecer"
end
function S.build(world, id, origin)
	origin = origin or V(0, 0, 0)
	local folder = Instance.new("Model")
	folder.Name = "BattleScenery"
	folder.Parent = world
	local ramp = Art.ramp(id)
	local leaf = Art.Ramps.Leaf
	local stone = Art.Ramps.Metal
	local function part(name, size, pos, color, kind, rotation)
		local p = Instance.new(kind == "wedge" and "WedgePart" or "Part")
		p.Name = name
		p.Size = size
		p.CFrame = CFrame.new(pos + origin) * (rotation or CFrame.identity)
		p.Color = color
		p.Material = Enum.Material.SmoothPlastic
		p.Anchored = true
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.CastShadow = false
		p.Parent = folder
		if kind == "cylinder" then
			p.Shape = Enum.PartType.Cylinder
		end
		return p
	end
	part("Sky", V(100, 50, 1), V(0, 18, -24), Art.Ramps.Sky[2])
	for layer = 1, 3 do
		for i = 1, 6 do
			local h = 4 + (i * 7 + layer * 3) % 9
			part(
				"DistantContour",
				V(2, h, 13),
				V((i - 3.5) * 13, h * 0.5 + 4 - layer, -21 + layer * 3),
				ramp[layer],
				"wedge",
				CFrame.Angles(0, math.pi / 2, 0)
			)
		end
	end
	part("Ground", V(70, 1, 40), V(0, -0.55, 0), ramp[2])
	for i = 1, 14 do
		part("GroundTile", V(2 + (i % 3), 0.06, 1), V((i % 7 - 3) * 8, 0.01, math.floor(i / 7) * 8 - 6), ramp[3])
	end
	for _, x in { -8, 8 } do
		part("ContactShadow", V(0.12, 10, 7), V(x, 0.04, 0), ramp[1], "cylinder", CFrame.Angles(0, 0, math.pi / 2))
		part("PlatformEdge", V(0.3, 9, 6.5), V(x, 0.08, 0), stone[2], "cylinder", CFrame.Angles(0, 0, math.pi / 2))
		part("PlatformLight", V(0.12, 8.4, 6), V(x, 0.26, 0), ramp[4], "cylinder", CFrame.Angles(0, 0, math.pi / 2))
		part("PlatformSurface", V(0.12, 7.8, 5.4), V(x, 0.34, 0), ramp[3], "cylinder", CFrame.Angles(0, 0, math.pi / 2))
	end
	for i = 1, 8 do
		local x = (i - 4.5) * 7
		local z = -10 - (i % 2) * 3
		if id == "Alvorecer" or id == "Floresta" or id == "Pantano" then
			part(
				"Trunk",
				V(1.4, 5 + i % 3, 1.4),
				V(x, 3, z),
				id == "Pantano" and Art.Ramps.Veil[1] or Art.Ramps.Sand[2]
			)
			for tier = 1, 3 do
				part(
					"Canopy",
					V(6 - tier, 2, 4),
					V(x + (tier % 2) * 0.7, 5 + tier * 1.2, z),
					id == "Pantano" and Art.Ramps.Veil[tier + 1] or leaf[tier + 1],
					"wedge",
					CFrame.Angles(0, tier % 2 * math.pi, 0)
				)
			end
		elseif id == "Brasa" then
			part("Basalt", V(4, 5 + i % 4, 4), V(x, 2, z), ramp[1], "wedge", CFrame.Angles(0, i * 0.7, 0))
			part("Ember", V(0.35, 3, 0.3), V(x + 0.8, 3, z + 2), ramp[4])
		elseif id == "Recife" then
			for branch = 1, 3 do
				part(
					"Coral",
					V(0.5, 2 + branch, 0.6),
					V(x + branch * 0.5, 1.5, z),
					Art.Ramps.Rose[branch + 1],
					nil,
					CFrame.Angles(0, 0, (branch - 2) * 0.3)
				)
			end
			part("Tide", V(5, 0.08, 2), V(x, 0.05, z + 4), ramp[4])
		elseif id == "Dunas" then
			part("RuinColumn", V(2, 4 + i % 4, 2), V(x, 2, z), ramp[3])
			part("RuinCap", V(3, 1, 3), V(x, 4 + i % 4 * 0.5, z), ramp[4])
			part("Inscription", V(0.2, 1, 0.1), V(x, 0.5 + i % 4, z + 1.05), ramp[1])
		else
			part("SkySpire", V(3, 7 + i % 3, 3), V(x, 3, z), ramp[2], "wedge", CFrame.Angles(0, i * 0.8, 0))
			part("SnowCap", V(3.2, 1.2, 3.2), V(x, 6 + i % 3 * 0.5, z), ramp[5], "wedge")
		end
	end
	for i = 1, 9 do
		part(
			"ForegroundGrass",
			V(0.25, 0.4 + (i % 3) * 0.3, 0.4),
			V((i - 5) * 7, 0.2, 8 + i % 2),
			ramp[i % 2 + 2],
			"wedge",
			CFrame.Angles(0, 0, i % 2 * 0.4)
		)
	end
	local count = 0
	for _, obj in folder:GetDescendants() do
		if obj:IsA("BasePart") then
			count += 1
		end
	end
	assert(count <= S.Budget, "Cenário excede orçamento gráfico")
	folder:SetAttribute("PartBudget", S.Budget)
	folder:SetAttribute("PartCount", count)
	folder:SetAttribute("Biome", id)
	return folder
end
return S
