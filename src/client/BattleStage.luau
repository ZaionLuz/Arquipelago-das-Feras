--!strict
-- BattleStage.luau - Dynamic battle backgrounds per island with Blender model support
-- Client-side only for WorldModel rendering

local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Art = require(RS.Shared.ArtTokens)
local BlenderModels = require(RS.Shared.BlenderModels)
local Elements = require(RS.Shared.Elements)

local S = { Budget = 200 }
local V = Vector3.new

-- Island to biome mapping (extended for all 12 elements)
local ISLAND_BIOME = {
	Alvorecer = "Natureza",
	Brasa = "Fogo",
	Recife = "Água",
	Floresta = "Natureza",
	Dunas = "Terra",
	Picos = "Ar",
	Pantano = "Sombra",
	Inverno = "Gelo",
	Trovao = "Elétrico",
	Celestial = "Luz",
	Forja = "Metal",
	Geoda = "Cristal",
	Vazio = "Arcano",
}

-- Element to biome fallback
local ELEMENT_BIOME = {
	Fogo = "Brasa",
	Água = "Recife",
	Natureza = "Floresta",
	Terra = "Dunas",
	Ar = "Picos",
	Sombra = "Pantano",
	Gelo = "Inverno",
	Elétrico = "Trovao",
	Luz = "Celestial",
	Metal = "Forja",
	Cristal = "Geoda",
	Arcano = "Vazio",
}

-- Biome configurations with Blender model references
local BIOME_CONFIGS = {
	Brasa = {
		skyColor = Color3.fromRGB(60, 20, 10),
		ambient = Color3.fromRGB(120, 40, 20),
		lightDir = Vector3.new(-1, -1, -1),
		fogColor = Color3.fromRGB(80, 30, 15),
		fogStart = 50,
		fogEnd = 200,
		groundMaterial = Enum.Material.Basalt,
		groundColor = Color3.fromRGB(40, 15, 10),
		particlePreset = "Fogo",
		blenderModels = { "environment/battlefield_volcanic", "props/lava_pool", "props/basalt_column" },
		skybox = {
			Sky = { "rbxassetid://sky_volcanic_1", "rbxassetid://sky_volcanic_2", "rbxassetid://sky_volcanic_3", "rbxassetid://sky_volcanic_4", "rbxassetid://sky_volcanic_5", "rbxassetid://sky_volcanic_6" },
		},
	},
	Recife = {
		skyColor = Color3.fromRGB(30, 80, 120),
		ambient = Color3.fromRGB(60, 140, 180),
		lightDir = Vector3.new(-0.5, -1, -0.5),
		fogColor = Color3.fromRGB(40, 100, 140),
		fogStart = 60,
		fogEnd = 250,
		groundMaterial = Enum.Material.Sand,
		groundColor = Color3.fromRGB(200, 180, 140),
		particlePreset = "Água",
		blenderModels = { "environment/battlefield_reef", "props/coral_formation", "props/sea_anemone" },
		skybox = {
			Sky = { "rbxassetid://sky_ocean_1", "rbxassetid://sky_ocean_2", "rbxassetid://sky_ocean_3", "rbxassetid://sky_ocean_4", "rbxassetid://sky_ocean_5", "rbxassetid://sky_ocean_6" },
		},
	},
	Floresta = {
		skyColor = Color3.fromRGB(40, 70, 30),
		ambient = Color3.fromRGB(80, 130, 60),
		lightDir = Vector3.new(-0.3, -1, -0.3),
		fogColor = Color3.fromRGB(50, 90, 40),
		fogStart = 40,
		fogEnd = 180,
		groundMaterial = Enum.Material.Grass,
		groundColor = Color3.fromRGB(50, 80, 30),
		particlePreset = "Natureza",
		blenderModels = { "environment/battlefield_forest", "props/ancient_tree", "props/mushroom_ring" },
		skybox = {
			Sky = { "rbxassetid://sky_forest_1", "rbxassetid://sky_forest_2", "rbxassetid://sky_forest_3", "rbxassetid://sky_forest_4", "rbxassetid://sky_forest_5", "rbxassetid://sky_forest_6" },
		},
	},
	Dunas = {
		skyColor = Color3.fromRGB(100, 80, 50),
		ambient = Color3.fromRGB(160, 130, 90),
		lightDir = Vector3.new(-0.8, -1, -0.2),
		fogColor = Color3.fromRGB(130, 110, 80),
		fogStart = 80,
		fogEnd = 300,
		groundMaterial = Enum.Material.Sand,
		groundColor = Color3.fromRGB(190, 160, 110),
		particlePreset = "Terra",
		blenderModels = { "environment/battlefield_desert", "props/ruin_pillar", "props/sand_dune" },
		skybox = {
			Sky = { "rbxassetid://sky_desert_1", "rbxassetid://sky_desert_2", "rbxassetid://sky_desert_3", "rbxassetid://sky_desert_4", "rbxassetid://sky_desert_5", "rbxassetid://sky_desert_6" },
		},
	},
	Picos = {
		skyColor = Color3.fromRGB(120, 150, 190),
		ambient = Color3.fromRGB(160, 180, 210),
		lightDir = Vector3.new(-0.2, -1, -0.5),
		fogColor = Color3.fromRGB(140, 170, 200),
		fogStart = 100,
		fogEnd = 400,
		groundMaterial = Enum.Material.Rock,
		groundColor = Color3.fromRGB(100, 100, 110),
		particlePreset = "Ar",
		blenderModels = { "environment/battlefield_mountain", "props/rock_spire", "props/cloud_bank" },
		skybox = {
			Sky = { "rbxassetid://sky_mountain_1", "rbxassetid://sky_mountain_2", "rbxassetid://sky_mountain_3", "rbxassetid://sky_mountain_4", "rbxassetid://sky_mountain_5", "rbxassetid://sky_mountain_6" },
		},
	},
	Pantano = {
		skyColor = Color3.fromRGB(40, 30, 50),
		ambient = Color3.fromRGB(80, 60, 90),
		lightDir = Vector3.new(-0.4, -1, -0.4),
		fogColor = Color3.fromRGB(30, 20, 35),
		fogStart = 20,
		fogEnd = 120,
		groundMaterial = Enum.Material.Mud,
		groundColor = Color3.fromRGB(40, 35, 30),
		particlePreset = "Sombra",
		blenderModels = { "environment/battlefield_swamp", "props/mangrove_root", "props/willow_tree" },
		skybox = {
			Sky = { "rbxassetid://sky_swamp_1", "rbxassetid://sky_swamp_2", "rbxassetid://sky_swamp_3", "rbxassetid://sky_swamp_4", "rbxassetid://sky_swamp_5", "rbxassetid://sky_swamp_6" },
		},
	},
	Inverno = {
		skyColor = Color3.fromRGB(160, 200, 230),
		ambient = Color3.fromRGB(180, 210, 240),
		lightDir = Vector3.new(-0.1, -1, -0.3),
		fogColor = Color3.fromRGB(180, 200, 220),
		fogStart = 50,
		fogEnd = 250,
		groundMaterial = Enum.Material.Ice,
		groundColor = Color3.fromRGB(220, 235, 250),
		particlePreset = "Gelo",
		blenderModels = { "environment/battlefield_arctic", "props/ice_berg", "props/frozen_tree" },
		skybox = {
			Sky = { "rbxassetid://sky_arctic_1", "rbxassetid://sky_arctic_2", "rbxassetid://sky_arctic_3", "rbxassetid://sky_arctic_4", "rbxassetid://sky_arctic_5", "rbxassetid://sky_arctic_6" },
		},
	},
	Trovao = {
		skyColor = Color3.fromRGB(50, 40, 60),
		ambient = Color3.fromRGB(100, 80, 120),
		lightDir = Vector3.new(-0.6, -1, -0.2),
		fogColor = Color3.fromRGB(60, 50, 80),
		fogStart = 30,
		fogEnd = 150,
		groundMaterial = Enum.Material.Slate,
		groundColor = Color3.fromRGB(60, 50, 70),
		particlePreset = "Elétrico",
		blenderModels = { "environment/battlefield_storm", "props/lightning_rod", "props/crystal_formation" },
		skybox = {
			Sky = { "rbxassetid://sky_storm_1", "rbxassetid://sky_storm_2", "rbxassetid://sky_storm_3", "rbxassetid://sky_storm_4", "rbxassetid://sky_storm_5", "rbxassetid://sky_storm_6" },
		},
	},
	Celestial = {
		skyColor = Color3.fromRGB(80, 70, 100),
		ambient = Color3.fromRGB(180, 170, 200),
		lightDir = Vector3.new(0, -1, 0),
		fogColor = Color3.fromRGB(200, 190, 220),
		fogStart = 100,
		fogEnd = 500,
		groundMaterial = Enum.Material.Marble,
		groundColor = Color3.fromRGB(230, 225, 240),
		particlePreset = "Luz",
		blenderModels = { "environment/battlefield_celestial", "props/floating_island", "props/light_pillar" },
		skybox = {
			Sky = { "rbxassetid://sky_celestial_1", "rbxassetid://sky_celestial_2", "rbxassetid://sky_celestial_3", "rbxassetid://sky_celestial_4", "rbxassetid://sky_celestial_5", "rbxassetid://sky_celestial_6" },
		},
	},
	Forja = {
		skyColor = Color3.fromRGB(70, 60, 65),
		ambient = Color3.fromRGB(130, 120, 125),
		lightDir = Vector3.new(-0.5, -1, -0.5),
		fogColor = Color3.fromRGB(80, 70, 75),
		fogStart = 40,
		fogEnd = 200,
		groundMaterial = Enum.Material.Metal,
		groundColor = Color3.fromRGB(110, 110, 120),
		particlePreset = "Metal",
		blenderModels = { "environment/battlefield_forge", "props/anvil", "props/gear_mechanism" },
		skybox = {
			Sky = { "rbxassetid://sky_forge_1", "rbxassetid://sky_forge_2", "rbxassetid://sky_forge_3", "rbxassetid://sky_forge_4", "rbxassetid://sky_forge_5", "rbxassetid://sky_forge_6" },
		},
	},
	Geoda = {
		skyColor = Color3.fromRGB(80, 50, 100),
		ambient = Color3.fromRGB(150, 120, 180),
		lightDir = Vector3.new(-0.3, -1, -0.4),
		fogColor = Color3.fromRGB(100, 80, 130),
		fogStart = 50,
		fogEnd = 250,
		groundMaterial = Enum.Material.Glass,
		groundColor = Color3.fromRGB(180, 150, 200),
		particlePreset = "Cristal",
		blenderModels = { "environment/battlefield_geode", "props/crystal_cluster", "props/amethyst_geode" },
		skybox = {
			Sky = { "rbxassetid://sky_geode_1", "rbxassetid://sky_geode_2", "rbxassetid://sky_geode_3", "rbxassetid://sky_geode_4", "rbxassetid://sky_geode_5", "rbxassetid://sky_geode_6" },
		},
	},
	Vazio = {
		skyColor = Color3.fromRGB(30, 15, 45),
		ambient = Color3.fromRGB(80, 50, 110),
		lightDir = Vector3.new(-0.7, -1, -0.7),
		fogColor = Color3.fromRGB(20, 10, 30),
		fogStart = 10,
		fogEnd = 100,
		groundMaterial = Enum.Material.Fabric,
		groundColor = Color3.fromRGB(25, 15, 35),
		particlePreset = "Arcano",
		blenderModels = { "environment/battlefield_void", "props/void_monolith", "props/rift_portal" },
		skybox = {
			Sky = { "rbxassetid://sky_void_1", "rbxassetid://sky_void_2", "rbxassetid://sky_void_3", "rbxassetid://sky_void_4", "rbxassetid://sky_void_5", "rbxassetid://sky_void_6" },
		},
	},
}

-- Procedural geometry generation (fallback when Blender models not loaded)
local function part(name: string, size: Vector3, pos: Vector3, color: Color3, kind: string?, rotation: CFrame?, parent: Instance): BasePart
	local p = Instance.new(kind == "wedge" and "WedgePart" or kind == "corner" and "CornerWedgePart" or kind == "cylinder" and "Part" or "Part")
	p.Name = name
	p.Size = size
	p.CFrame = CFrame.new(pos) * (rotation or CFrame.identity)
	p.Color = color
	p.Material = Enum.Material.SmoothPlastic
	p.Anchored = true
	p.CanCollide = false
	p.CanTouch = false
	p.CanQuery = false
	p.CastShadow = false
	p.Parent = parent
	if kind == "cylinder" then
		p.Shape = Enum.PartType.Cylinder
	end
	return p
end

function S.resolve(def: { island: string?, el: string }): string
	if def.island and BIOME_CONFIGS[def.island] then
		return def.island
	end
	if def.el and ELEMENT_BIOME[def.el] then
		return ELEMENT_BIOME[def.el]
	end
	return "Alvorecer"
end

function S.build(world: Instance, biomeId: string, origin: Vector3?): Model
	origin = origin or V(0, 0, 0)
	local config = BIOME_CONFIGS[biomeId] or BIOME_CONFIGS.Alvorecer
	local ramp = Art.ramp(biomeId)
	local leaf = Art.Ramps.Leaf
	local stone = Art.Ramps.Metal

	local folder = Instance.new("Model")
	folder.Name = "BattleScenery_" .. biomeId
	folder.Parent = world
	folder:SetAttribute("Biome", biomeId)
	folder:SetAttribute("PartBudget", S.Budget)

	-- Load Blender models if available
	local blenderLoaded = S.loadBlenderModels(folder, config, origin)

	if not blenderLoaded then
		-- Fallback to procedural generation
		S.buildProcedural(folder, biomeId, config, ramp, leaf, stone, origin)
	end

	-- Apply atmosphere
	S.applyAtmosphere(world, config)

	-- Add particle effects
	S.addParticleEffects(folder, config, origin)

	-- Count parts for budget validation
	local count = 0
	for _, obj in folder:GetDescendants() do
		if obj:IsA("BasePart") then count += 1 end
	end
	folder:SetAttribute("PartCount", count)

	return folder
end

function S.loadBlenderModels(folder: Model, config: any, origin: Vector3): boolean
	if not config.blenderModels or #config.blenderModels == 0 then return false end

	local success = false
	for _, modelPath in config.blenderModels do
		-- Try to load from ReplicatedStorage Assets
		local assetFolder = RS:FindFirstChild("Assets")
		if assetFolder then
			local blenderModel = assetFolder:FindFirstChild(modelPath)
			if blenderModel and blenderModel:IsA("Model") then
				local clone = blenderModel:Clone()
				clone.Parent = folder
				-- Position at origin
				if clone.PrimaryPart then
					clone:PivotTo(CFrame.new(origin) * clone:GetPivot())
				end
				success = true
			end
		end
	end

	-- Also try BlenderModels registry
	for speciesId, creature in BlenderModels.Creatures do
		if creature.Element == config.particlePreset then
			-- Could spawn environmental creatures as decoration
		end
	end

	return success
end

function S.buildProcedural(folder: Model, biomeId: string, config: any, ramp: { Color3 }, leaf: { Color3 }, stone: { Color3 }, origin: Vector3)
	-- Sky dome
	part("SkyDome", V(200, 100, 200), V(0, 50, 0) + origin, config.skyColor, "sphere", nil, folder)
	part("SkyDome", V(200, 100, 200), V(0, 50, 0) + origin, config.skyColor, "sphere", CFrame.Angles(math.pi, 0, 0), folder)

	-- Distant terrain layers
	for layer = 1, 4 do
		for i = 1, 8 do
			local h = 5 + (i * 9 + layer * 4) % 12
			local x = (i - 4.5) * 15
			local z = -25 + layer * 4
			for _, side in { -1, 1 } do
				part(
					"DistantContour_" .. layer .. "_" .. i .. "_" .. (side > 0 and "R" or "L"),
					V(3, h, 8),
					V(x + side * 4, h * 0.5 + 5 - layer, z) + origin,
					ramp[math.min(layer, #ramp)],
					"wedge",
					CFrame.Angles(0, -side * math.pi / 2, 0),
					folder
				)
			end
		end
	end

	-- Sun/Moon disk
	local sunColor = biomeId == "Vazio" and Color3.fromRGB(100, 50, 150) or Art.Ramps.Sand[5]
	part("CelestialBody", V(0.3, 8, 8), V(30, 25, -30) + origin, sunColor, "cylinder", CFrame.Angles(0, math.pi / 2, 0), folder)

	-- Clouds/fog layers
	for cloud = 1, 4 do
		local x = cloud * 22 - 44
		local y = 18 + cloud % 2 * 5
		local cloudColor = config.fogColor:Lerp(Color3.new(1,1,1), 0.3)
		part("CloudLayer_" .. cloud, V(10, 2, 1.5), V(x, y, -22) + origin, cloudColor)
		part("CloudCrown_" .. cloud, V(6, 1.5, 1), V(x - 1, y + 1.5, -22) + origin, cloudColor:Lerp(Color3.new(1,1,1), 0.5))
		part("CloudShadow_" .. cloud, V(8, 0.5, 1.5), V(x + 0.5, y - 1, -22) + origin, config.fogColor)
	end

	-- Ground plane
	part("Ground", V(80, 1, 50), V(0, -0.5, 0) + origin, config.groundColor)

	-- Ground tiles
	for i = 1, 16 do
		part(
			"GroundTile_" .. i,
			V(2 + (i % 4), 0.08, 1.5),
			V((i % 8 - 4) * 9, 0.02, math.floor(i / 8) * 10 - 8) + origin,
			ramp[math.min(3, #ramp)]
		).Parent = folder
	end

	-- Biome-specific features
	if biomeId == "Brasa" then
		S.buildVolcanic(folder, ramp, origin)
	elseif biomeId == "Recife" then
		S.buildReef(folder, ramp, origin)
	elseif biomeId == "Floresta" then
		S.buildForest(folder, leaf, ramp, origin)
	elseif biomeId == "Dunas" then
		S.buildDesert(folder, ramp, stone, origin)
	elseif biomeId == "Picos" then
		S.buildMountain(folder, ramp, origin)
	elseif biomeId == "Pantano" then
		S.buildSwamp(folder, ramp, origin)
	elseif biomeId == "Inverno" then
		S.buildArctic(folder, ramp, origin)
	elseif biomeId == "Trovao" then
		S.buildStorm(folder, ramp, origin)
	elseif biomeId == "Celestial" then
		S.buildCelestial(folder, ramp, origin)
	elseif biomeId == "Forja" then
		S.buildForge(folder, ramp, stone, origin)
	elseif biomeId == "Geoda" then
		S.buildGeode(folder, ramp, origin)
	elseif biomeId == "Vazio" then
		S.buildVoid(folder, ramp, origin)
	end

	-- Platform edges (battle arena markers)
	for _, x in { -10, 10 } do
		part("ArenaEdge", V(0.4, 10, 8), V(x, 0.1, 0) + origin, stone[2], "cylinder", CFrame.Angles(0, 0, math.pi / 2), folder)
		part("ArenaLight", V(0.15, 9, 7), V(x, 0.3, 0) + origin, ramp[4], "cylinder", CFrame.Angles(0, 0, math.pi / 2), folder)
		part("ArenaSurface", V(0.15, 8.5, 6.5), V(x, 0.4, 0) + origin, ramp[3], "cylinder", CFrame.Angles(0, 0, math.pi / 2), folder)
	end

	-- Foreground detail
	for i = 1, 10 do
		local x = (i - 5.5) * 8
		local z = 10 + i % 2 * 2
		part(
			"ForegroundDetail_" .. i,
			V(0.3, 0.5 + (i % 3) * 0.4, 0.5),
			V(x, 0.25, z) + origin,
			ramp[i % 2 + 2],
			"wedge",
			CFrame.Angles(0, 0, i % 2 * 0.5),
			folder
		)
	end
end

-- Biome-specific builders
function S.buildVolcanic(folder: Model, ramp: { Color3 }, origin: Vector3)
	for i = 1, 10 do
		local x = (i - 5.5) * 8
		local z = -8 - (i % 2) * 4
		part("Basalt_" .. i, V(4, 6 + i % 4, 4), V(x, 3, z) + origin, ramp[1], "wedge", CFrame.Angles(0, i * 0.7, 0), folder)
		part("Ember_" .. i, V(0.4, 4, 0.4), V(x + 1, 4, z + 2) + origin, ramp[4], nil, nil, folder)
		part("LavaPool_" .. i, V(3, 0.2, 3), V(x, 0.1, z + 1) + origin, ramp[4], nil, nil, folder)
	end
end

function S.buildReef(folder: Model, ramp: { Color3 }, origin: Vector3)
	for i = 1, 8 do
		local x = (i - 4.5) * 9
		local z = -6 - (i % 2) * 3
		for branch = 1, 4 do
			part("Coral_" .. i .. "_" .. branch, V(0.6, 3 + branch, 0.8), V(x + branch * 0.7, 2, z) + origin, Art.Ramps.Rose[branch + 1], nil, CFrame.Angles(0, 0, (branch - 2) * 0.4), folder)
		end
		part("Tide_" .. i, V(6, 0.1, 3), V(x, 0.1, z + 5) + origin, ramp[4], nil, nil, folder)
	end
end

function S.buildForest(folder: Model, leaf: { Color3 }, ramp: { Color3 }, origin: Vector3)
	for i = 1, 10 do
		local x = (i - 5.5) * 8
		local z = -10 - (i % 2) * 4
		part("Trunk_" .. i, V(1.5, 6 + i % 3, 1.5), V(x, 3.5, z) + origin, Art.Ramps.Sand[2], nil, nil, folder)
		for tier = 1, 4 do
			part("Canopy_" .. i .. "_" .. tier, V(8 - tier * 1.5, 2.5, 5), V(x + tier * 0.5, 6 + tier * 1.5, z) + origin, leaf[tier + 1], "wedge", CFrame.Angles(0, tier * math.pi / 2, 0), folder)
		end
	end
end

function S.buildDesert(folder: Model, ramp: { Color3 }, stone: { Color3 }, origin: Vector3)
	for i = 1, 10 do
		local x = (i - 5.5) * 8
		local z = -8 - (i % 2) * 4
		part("RuinColumn_" .. i, V(2, 5 + i % 4, 2), V(x, 2.5, z) + origin, ramp[3], nil, nil, folder)
		part("RuinCap_" .. i, V(3, 1, 3), V(x, 5 + i % 4 * 0.5, z) + origin, ramp[4], nil, nil, folder)
		part("Inscription_" .. i, V(0.3, 1.5, 0.2), V(x, 1 + i % 4, z + 1.2) + origin, ramp[1], nil, nil, folder)
	end
end

function S.buildMountain(folder: Model, ramp: { Color3 }, origin: Vector3)
	for i = 1, 10 do
		local x = (i - 5.5) * 8
		local z = -10 - (i % 2) * 3
		part("SkySpire_" .. i, V(3, 8 + i % 3, 3), V(x, 4, z) + origin, ramp[2], "wedge", CFrame.Angles(0, i * 0.8, 0), folder)
		part("SnowCap_" .. i, V(3.5, 1.5, 3.5), V(x, 8 + i % 3 * 0.5, z) + origin, ramp[5], "wedge", nil, folder)
	end
end

function S.buildSwamp(folder: Model, ramp: { Color3 }, origin: Vector3)
	for i = 1, 10 do
		local x = (i - 5.5) * 8
		local z = -8 - (i % 2) * 4
		part("MangroveTrunk_" .. i, V(1.2, 5, 1.2), V(x, 2.5, z) + origin, Art.Ramps.Veil[1], nil, nil, folder)
		for tier = 1, 3 do
			part("MangroveCanopy_" .. i .. "_" .. tier, V(6 - tier, 2, 4), V(x + tier * 0.5, 4.5 + tier * 1.2, z) + origin, Art.Ramps.Veil[tier + 1], "wedge", CFrame.Angles(0, tier * math.pi / 1.5, 0), folder)
		end
		part("SwampWater_" .. i, V(4, 0.1, 3), V(x, 0.05, z + 2) + origin, Color3.fromRGB(20, 25, 20), nil, nil, folder)
	end
end

function S.buildArctic(folder: Model, ramp: { Color3 }, origin: Vector3)
	for i = 1, 8 do
		local x = (i - 4.5) * 10
		local z = -8 - (i % 2) * 5
		part("IceBerg_" .. i, V(5, 4 + i % 3, 5), V(x, 2, z) + origin, ramp[4], "wedge", CFrame.Angles(0, i * 0.6, 0), folder)
		part("FrostCrystal_" .. i, V(0.8, 3, 0.8), V(x + 1.5, 3, z + 1.5) + origin, ramp[5], nil, CFrame.Angles(0, i * 0.8, 0), folder)
	end
end

function S.buildStorm(folder: Model, ramp: { Color3 }, origin: Vector3)
	for i = 1, 8 do
		local x = (i - 4.5) * 10
		local z = -6 - (i % 2) * 4
		part("LightningRod_" .. i, V(0.5, 8, 0.5), V(x, 4, z) + origin, Art.Ramps.Metal[3], nil, nil, folder)
		part("StormCloud_" .. i, V(8, 2, 3), V(x, 15, z) + origin, ramp[1], nil, nil, folder)
	end
end

function S.buildCelestial(folder: Model, ramp: { Color3 }, origin: Vector3)
	for i = 1, 6 do
		local angle = i * math.pi / 3
		local x = math.cos(angle) * 15
		local z = math.sin(angle) * 15
		part("FloatingIsle_" .. i, V(6, 1.5, 6), V(x, 5, z) + origin, ramp[3], nil, nil, folder)
		part("LightPillar_" .. i, V(0.8, 12, 0.8), V(x, 6, z) + origin, ramp[5], "cylinder", nil, folder)
	end
end

function S.buildForge(folder: Model, ramp: { Color3 }, stone: { Color3 }, origin: Vector3)
	for i = 1, 8 do
		local x = (i - 4.5) * 9
		local z = -6 - (i % 2) * 3
		part("Anvil_" .. i, V(3, 2, 3), V(x, 1, z) + origin, stone[2], nil, nil, folder)
		part("GearMechanism_" .. i, V(4, 4, 1), V(x, 3, z) + origin, stone[3], nil, CFrame.Angles(0, i * 0.5, 0), folder)
		part("MoltenVein_" .. i, V(0.3, 3, 0.3), V(x + 1, 2, z) + origin, ramp[4], "cylinder", nil, folder)
	end
end

function S.buildGeode(folder: Model, ramp: { Color3 }, origin: Vector3)
	for i = 1, 8 do
		local x = (i - 4.5) * 8
		local z = -8 - (i % 2) * 4
		part("CrystalCluster_" .. i, V(3, 4 + i % 3, 3), V(x, 2, z) + origin, ramp[4], "wedge", CFrame.Angles(0, i * 0.9, 0), folder)
		part("GeodeHollow_" .. i, V(2.5, 3, 2.5), V(x, 2.5, z) + origin, ramp[5], nil, nil, folder)
	end
end

function S.buildVoid(folder: Model, ramp: { Color3 }, origin: Vector3)
	for i = 1, 6 do
		local angle = i * math.pi / 3
		local x = math.cos(angle) * 12
		local z = math.sin(angle) * 12
		part("VoidMonolith_" .. i, V(1.5, 10, 1.5), V(x, 5, z) + origin, ramp[1], "wedge", CFrame.Angles(0, angle, 0), folder)
		part("RiftPortal_" .. i, V(3, 0.2, 3), V(x, 0.1, z) + origin, ramp[4], nil, nil, folder)
	end
	part("VoidCenter", V(1, 15, 1), V(0, 7.5, 0) + origin, ramp[1], "cylinder", nil, folder)
end

function S.applyAtmosphere(world: Instance, config: any)
	-- Atmosphere is handled by Lighting service, but we can set attributes for client scripts
	world:SetAttribute("SkyColor", config.skyColor)
	world:SetAttribute("Ambient", config.ambient)
	world:SetAttribute("LightDirection", config.lightDir)
	world:SetAttribute("FogColor", config.fogColor)
	world:SetAttribute("FogStart", config.fogStart)
	world:SetAttribute("FogEnd", config.fogEnd)
end

function S.addParticleEffects(folder: Model, config: any, origin: Vector3)
	local preset = Art.ParticlePresets[config.particlePreset]
	if not preset then return end

	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "BiomeParticles"
	emitter.Color = preset.Color
	emitter.Size = preset.Size
	emitter.Lifetime = preset.Lifetime
	emitter.Rate = preset.Rate
	emitter.Speed = preset.Speed
	emitter.SpreadAngle = preset.SpreadAngle
	emitter.Drag = preset.Drag
	emitter.EmissionDirection = Enum.NormalId.Top
	emitter.Parent = folder

	-- Attach to a central part
	local centerPart = folder:FindFirstChild("Ground") or Instance.new("Part")
	if not centerPart.Parent then
		centerPart.Name = "ParticleAnchor"
		centerPart.Size = V(1, 1, 1)
		centerPart.Transparency = 1
		centerPart.Anchored = true
		centerPart.CanCollide = false
		centerPart.Parent = folder
		centerPart.Position = origin
	end
	emitter.Parent = centerPart
end

-- Transition effects between biomes
local activeTransitions: { [string]: RBXScriptConnection } = {}

function S.transitionTo(world: Instance, newBiomeId: string, duration: number): ()
	duration = duration or 2
	local currentBiome = world:GetAttribute("CurrentBiome") or "Alvorecer"
	if currentBiome == newBiomeId then return end

	local oldFolder = world:FindFirstChild("BattleScenery_" .. currentBiome)
	local newFolder = S.build(world, newBiomeId)

	newFolder.Name = "BattleScenery_" .. newBiomeId .. "_New"
	newFolder.Parent = world

	-- Cross-fade
	local tweenInfo = TweenInfo.new(duration, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)

	if oldFolder then
		for _, obj in oldFolder:GetDescendants() do
			if obj:IsA("BasePart") then
				game:GetService("TweenService"):Create(obj, tweenInfo, { Transparency = 1 }):Play()
			elseif obj:IsA("ParticleEmitter") then
				game:GetService("TweenService"):Create(obj, tweenInfo, { Rate = 0 }):Play()
			end
		end
		task.delay(duration, function()
			oldFolder:Destroy()
		end)
	end

	for _, obj in newFolder:GetDescendants() do
		if obj:IsA("BasePart") then
			obj.Transparency = 1
			game:GetService("TweenService"):Create(obj, tweenInfo, { Transparency = 0 }):Play()
		elseif obj:IsA("ParticleEmitter") then
			obj.Rate = 0
			game:GetService("TweenService"):Create(obj, tweenInfo, { Rate = Art.ParticlePresets[BIOME_CONFIGS[newBiomeId].particlePreset].Rate }):Play()
		end
	end

	newFolder.Name = "BattleScenery_" .. newBiomeId
	world:SetAttribute("CurrentBiome", newBiomeId)
end

-- Get biome config for external use
function S.getBiomeConfig(biomeId: string): any
	return BIOME_CONFIGS[biomeId] or BIOME_CONFIGS.Alvorecer
end

function S.listBiomes(): { string }
	local biomes = {}
	for id in BIOME_CONFIGS do
		table.insert(biomes, id)
	end
	table.sort(biomes)
	return biomes
end

return S