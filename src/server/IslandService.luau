--!nonstrict
-- ISLAND SERVICE - Per-island logic, landmarks, caves, unique resources, secret areas

local RS = game:GetService("ReplicatedStorage")
local Run = game:GetService("RunService")
local I = require(RS.Shared.Islands)
local C = require(RS.Shared.Creatures)
local Data = require(script.Parent.DataService)
local Region = require(script.Parent.RegionService)
local B = require(script.Parent.Biomes)
local T = require(RS.Shared.ArtTokens)
local IS = {}

-- Island-specific data
IS.IslandData = {
	Alvorecer = {
		name = "Ilha do Alvorecer",
		theme = "Inicio",
		landmarks = {
			{ name = "Acampamento Base", position = Vector3.new(0, 5, 30), type = "safe" },
			{ name = "Fonte Cristalina", position = Vector3.new(-20, 6, -15), type = "resource", resource = "Natureza" },
			{ name = "Arvore Ancia", position = Vector3.new(0, 15, -26), type = "landmark" },
		},
		caves = {
			{ name = "Caverna das Raizes", depth = 3, entrance = Vector3.new(-24, 5, 0), biome = "Alvorecer", rewards = { "Natureza", "Terra" }, minLevel = 5 },
		},
		secretAreas = {
			{ name = "Clareira Secreta", position = Vector3.new(35, 5, 35), requirement = "explore:10", reward = "brotinho_shiny" },
		},
		uniqueResources = { "Natureza", "Terra" },
		specialSpawns = { "brotinho", "folhuco", "penugem" },
	},
	Brasa = {
		name = "Ilha das Brasas",
		theme = "Vulcao",
		landmarks = {
			{ name = "Ponte de Obsidiana", position = Vector3.new(0, 9, 20), type = "travel" },
			{ name = "Caldeirao de Magma", position = Vector3.new(0, 8, -27), type = "resource", resource = "Fogo" },
			{ name = "Forja Antiga", position = Vector3.new(-15, 10, -30), type = "crafting" },
		},
		caves = {
			{ name = "Tubos de Lava", depth = 5, entrance = Vector3.new(-24, 5, 0), biome = "Brasa", rewards = { "Fogo", "Metal", "Cristal" }, minLevel = 15 },
			{ name = "Coracao do Vulcao", depth = 8, entrance = Vector3.new(0, 15, -27), biome = "Brasa", rewards = { "Fogo", "Metal" }, minLevel = 25, requiresGuardian = true },
		},
		secretAreas = {
			{ name = "Camara do Magma Puro", position = Vector3.new(0, -50, -27), requirement = "guardian:Brasa", reward = "essencia_puro_fogo" },
		},
		uniqueResources = { "Fogo", "Metal", "Cristal" },
		specialSpawns = { "brasa", "magmara", "pirolito" },
	},
	Recife = {
		name = "Recife Cristalino",
		theme = "Oceano",
		landmarks = {
			{ name = "Portal das Mares", position = Vector3.new(0, 9, 25), type = "travel" },
			{ name = "Jardim de Corais", position = Vector3.new(0, 8, -28), type = "resource", resource = "Agua" },
			{ name = "Caverna das Sereias", position = Vector3.new(25, 6, 0), type = "landmark" },
		},
		caves = {
			{ name = "Gruta Submersa", depth = 4, entrance = Vector3.new(-24, 5, 0), biome = "Recife", rewards = { "Agua", "Cristal", "Luz" }, minLevel = 20 },
			{ name = "Abismo Azul", depth = 10, entrance = Vector3.new(0, -10, -30), biome = "Recife", rewards = { "Agua", "Arcano" }, minLevel = 35, requiresItem = "selo_profundezas" },
		},
		secretAreas = {
			{ name = "Palacio de Corais", position = Vector3.new(0, -30, -28), requirement = "explore:50", reward = "coral_antigo" },
		},
		uniqueResources = { "Agua", "Cristal", "Luz" },
		specialSpawns = { "marino", "corala", "perola" },
	},
	Floresta = {
		name = "Floresta Murmurante",
		theme = "Floresta",
		landmarks = {
			{ name = "Clareira dos Sussurros", position = Vector3.new(0, 9, 28), type = "travel" },
			{ name = "Arvore Madre", position = Vector3.new(0, 23, -26), type = "resource", resource = "Natureza" },
			{ name = "Circulo dos Druidas", position = Vector3.new(-20, 6, -20), type = "crafting" },
		},
		caves = {
			{ name = "Raizes Profundas", depth = 6, entrance = Vector3.new(-24, 5, 0), biome = "Floresta", rewards = { "Natureza", "Terra", "Sombra" }, minLevel = 30 },
			{ name = "Vao dos Espiritos", depth = 7, entrance = Vector3.new(20, 8, -25), biome = "Floresta", rewards = { "Natureza", "Arcano" }, minLevel = 40, requiresGuardian = true },
		},
		secretAreas = {
			{ name = "Bosque Ancestral", position = Vector3.new(-35, 5, -35), requirement = "guardian:Floresta", reward = "semente_mundial" },
		},
		uniqueResources = { "Natureza", "Terra", "Sombra" },
		specialSpawns = { "silvico", "musgoso", "drude" },
	},
	Dunas = {
		name = "Dunas Quebradas",
		theme = "Deserto",
		landmarks = {
			{ name = "Ruinas Enterradas", position = Vector3.new(0, 9, 22), type = "travel" },
			{ name = "Obelisco Solar", position = Vector3.new(0, 16, -25), type = "resource", resource = "Luz" },
			{ name = "Tumba do Farao", position = Vector3.new(-25, 10, -25), type = "dungeon" },
		},
		caves = {
			{ name = "Catacumbas de Areia", depth = 7, entrance = Vector3.new(-24, 5, 0), biome = "Dunas", rewards = { "Terra", "Metal", "Luz" }, minLevel = 40 },
			{ name = "Vao do Escorpiao", depth = 9, entrance = Vector3.new(0, 5, 30), biome = "Dunas", rewards = { "Terra", "Veneno" }, minLevel = 50, requiresItem = "chave_areia" },
		},
		secretAreas = {
			{ name = "Cidade Perdida", position = Vector3.new(0, -40, 0), requirement = "explore:100", reward = "relogio_areia" },
		},
		uniqueResources = { "Terra", "Metal", "Luz" },
		specialSpawns = { "arenoso", "escorpiao", "farao" },
	},
	Picos = {
		name = "Picos Celestes",
		theme = "Montanha",
		landmarks = {
			{ name = "Cume Celestial", position = Vector3.new(0, 9, 35), type = "mount" },
			{ name = "Ninho da Aguia", position = Vector3.new(0, 25, -28), type = "resource", resource = "Ar" },
			{ name = "Templo do Vento", position = Vector3.new(20, 15, 20), type = "crafting" },
		},
		caves = {
			{ name = "Caverna do Vento", depth = 8, entrance = Vector3.new(-24, 5, 0), biome = "Picos", rewards = { "Ar", "Gelo", "Luz" }, minLevel = 45 },
			{ name = "Olho da Tempestade", depth = 12, entrance = Vector3.new(0, 30, -28), biome = "Picos", rewards = { "Ar", "Eletrico" }, minLevel = 55, requiresGuardian = true },
		},
		secretAreas = {
			{ name = "Pico Mais Alto", position = Vector3.new(0, 60, 0), requirement = "guardian:Picos", reward = "pena_celestial" },
		},
		uniqueResources = { "Ar", "Gelo", "Luz", "Eletrico" },
		specialSpawns = { "alado", "tempestal", "celestial" },
	},
	Pantano = {
		name = "Pantano Umbral",
		theme = "Pantano",
		landmarks = {
			{ name = "Portal Umbral", position = Vector3.new(0, 9, 24), type = "travel" },
			{ name = "Lagoa dos Espelhos", position = Vector3.new(0, 9, -25), type = "resource", resource = "Sombra" },
			{ name = "Arvore das Almas", position = Vector3.new(-15, 12, 15), type = "landmark" },
		},
		caves = {
			{ name = "Raizes Afogadas", depth = 9, entrance = Vector3.new(-24, 5, 0), biome = "Pantano", rewards = { "Sombra", "Agua", "Arcano" }, minLevel = 50 },
			{ name = "Vao do Vazio", depth = 15, entrance = Vector3.new(0, 9, -25), biome = "Pantano", rewards = { "Sombra", "Arcano", "Vazio" }, minLevel = 65, requiresGuardian = true },
		},
		secretAreas = {
			{ name = "Nucleo Umbral", position = Vector3.new(0, -60, 0), requirement = "guardian:Pantano", reward = "essencia_vazio" },
		},
		uniqueResources = { "Sombra", "Agua", "Arcano" },
		specialSpawns = { "umbral", "nevoento", "fantasma" },
	},
	Inverno = {
		name = "Inverno Eterno",
		theme = "Gelo",
		landmarks = {
			{ name = "Cidadela de Gelo", position = Vector3.new(0, 9, 30), type = "mount" },
			{ name = "Caverna dos Cristais", position = Vector3.new(0, 14, -28), type = "resource", resource = "Gelo" },
			{ name = "Altar do Gelo", position = Vector3.new(-20, 15, -20), type = "crafting" },
		},
		caves = {
			{ name = "Geleira Profunda", depth = 10, entrance = Vector3.new(-24, 5, 0), biome = "Inverno", rewards = { "Gelo", "Cristal", "Metal" }, minLevel = 55 },
			{ name = "Coracao Congelado", depth = 14, entrance = Vector3.new(0, 20, -28), biome = "Inverno", rewards = { "Gelo", "Arcano" }, minLevel = 70, requiresGuardian = true },
		},
		secretAreas = {
			{ name = "Palacio de Gelo", position = Vector3.new(0, -50, -28), requirement = "guardian:Inverno", reward = "coraçao_gelo" },
		},
		uniqueResources = { "Gelo", "Cristal", "Metal" },
		specialSpawns = { "congelado", "gelido", "nevasca" },
	},
	Trovao = {
		name = "Trovao Rugente",
		theme = "Tempestade",
		landmarks = {
			{ name = "Pico da Tempestade", position = Vector3.new(0, 9, 32), type = "mount" },
			{ name = "Condutor Celestial", position = Vector3.new(0, 20, -28), type = "resource", resource = "Eletrico" },
			{ name = "Forja da Tempestade", position = Vector3.new(20, 15, 20), type = "crafting" },
		},
		caves = {
			{ name = "Tunel do Raio", depth = 11, entrance = Vector3.new(-24, 5, 0), biome = "Trovao", rewards = { "Eletrico", "Metal", "Ar" }, minLevel = 60 },
			{ name = "Olho do Furacao", depth = 16, entrance = Vector3.new(0, 25, -28), biome = "Trovao", rewards = { "Eletrico", "Luz" }, minLevel = 75, requiresGuardian = true },
		},
		secretAreas = {
			{ name = "Nucleo Eletrico", position = Vector3.new(0, -40, 0), requirement = "guardian:Trovao", reward = "nucleo_raio" },
		},
		uniqueResources = { "Eletrico", "Metal", "Ar" },
		specialSpawns = { "eletro", "raio", "tempestal" },
	},
	Celestial = {
		name = "Celestial Radiante",
		theme = "Luz",
		landmarks = {
			{ name = "Jardim das Estrelas", position = Vector3.new(0, 9, 28), type = "landmark" },
			{ name = "Fonte de Luz", position = Vector3.new(0, 24, -28), type = "resource", resource = "Luz" },
			{ name = "Observatorio", position = Vector3.new(25, 30, 25), type = "crafting" },
		},
		caves = {
			{ name = "Gruta Estelar", depth = 12, entrance = Vector3.new(-24, 5, 0), biome = "Celestial", rewards = { "Luz", "Cristal", "Arcano" }, minLevel = 70 },
			{ name = "Vao do Cosmos", depth = 18, entrance = Vector3.new(0, 35, -28), biome = "Celestial", rewards = { "Luz", "Arcano" }, minLevel = 85, requiresGuardian = true },
		},
		secretAreas = {
			{ name = "Portao Estelar", position = Vector3.new(0, -30, -28), requirement = "guardian:Celestial", reward = "fragmento_estrela" },
		},
		uniqueResources = { "Luz", "Cristal", "Arcano" },
		specialSpawns = { "estelar", "luminoso", "cosmico" },
	},
	Forja = {
		name = "Forja Primordial",
		theme = "Metal",
		landmarks = {
			{ name = "Coracao da Forja", position = Vector3.new(0, 9, 26), type = "landmark" },
			{ name = "Grande Bigorna", position = Vector3.new(0, 16, -28), type = "crafting" },
			{ name = "Rio de Metal", position = Vector3.new(-20, 8, 20), type = "resource", resource = "Metal" },
		},
		caves = {
			{ name = "Minas Profundas", depth = 13, entrance = Vector3.new(-24, 5, 0), biome = "Forja", rewards = { "Metal", "Fogo", "Terra" }, minLevel = 75 },
			{ name = "Nucleo da Terra", depth = 20, entrance = Vector3.new(0, 20, -28), biome = "Forja", rewards = { "Metal", "Cristal" }, minLevel = 90, requiresGuardian = true },
		},
		secretAreas = {
			{ name = "Camara do Mestre", position = Vector3.new(0, -60, 0), requirement = "guardian:Forja", reward = "martelo_primordial" },
		},
		uniqueResources = { "Metal", "Fogo", "Terra" },
		specialSpawns = { "ferroso", "fundido", "forjado" },
	},
	Geoda = {
		name = "Geoda Cristalina",
		theme = "Cristal",
		landmarks = {
			{ name = "Camara Cristalina", position = Vector3.new(0, 9, 24), type = "underground" },
			{ name = "Coracao de Cristal", position = Vector3.new(0, 10, -28), type = "resource", resource = "Cristal" },
			{ name = "Salao dos Espelhos", position = Vector3.new(20, 12, 20), type = "landmark" },
		},
		caves = {
			{ name = "Veios de Cristal", depth = 14, entrance = Vector3.new(-24, 5, 0), biome = "Geoda", rewards = { "Cristal", "Luz", "Arcano" }, minLevel = 80 },
			{ name = "Geoda Mestra", depth = 22, entrance = Vector3.new(0, 15, -28), biome = "Geoda", rewards = { "Cristal", "Arcano" }, minLevel = 95, requiresGuardian = true },
		},
		secretAreas = {
			{ name = "Nucleo Cristalino", position = Vector3.new(0, -40, -28), requirement = "guardian:Geoda", reward = "cristal_puro" },
		},
		uniqueResources = { "Cristal", "Luz", "Arcano" },
		specialSpawns = { "cristalino", "prismatico", "geodico" },
	},
	Vazio = {
		name = "Vazio Absoluto",
		theme = "Arcano",
		landmarks = {
			{ name = "Limite do Vazio", position = Vector3.new(0, 9, 30), type = "mount" },
			{ name = "Portal Final", position = Vector3.new(0, 10, -28), type = "resource", resource = "Arcano" },
			{ name = "Trono do Vazio", position = Vector3.new(30, 25, -30), type = "landmark" },
		},
		caves = {
			{ name = "Abismo Final", depth = 25, entrance = Vector3.new(-24, 5, 0), biome = "Vazio", rewards = { "Arcano", "Sombra", "Vazio" }, minLevel = 90 },
			{ name = "Nucleo do Vazio", depth = 30, entrance = Vector3.new(0, 10, -28), biome = "Vazio", rewards = { "Arcano", "Vazio" }, minLevel = 100, requiresGuardian = true },
		},
		secretAreas = {
			{ name = "Além do Vazio", position = Vector3.new(0, -100, 0), requirement = "guardian:Vazio", reward = "chave_vazio" },
		},
		uniqueResources = { "Arcano", "Sombra", "Vazio" },
		specialSpawns = { "vazio", "abissal", "cosmico" },
	},
}

-- Active cave sessions
IS.ActiveCaves = {}

function IS.getIslandData(islandId)
	return IS.IslandData[islandId]
end

function IS.getLandmarks(islandId)
	local data = IS.IslandData[islandId]
	return data and data.landmarks or {}
end

function IS.getCaves(islandId)
	local data = IS.IslandData[islandId]
	return data and data.caves or {}
end

function IS.getSecretAreas(islandId)
	local data = IS.IslandData[islandId]
	return data and data.secretAreas or {}
end

function IS.enterCave(player, islandId, caveIndex)
	local data = Data.get(player)
	if not data then return { ok = false, reason = "NO_DATA" } end

	local islandData = IS.IslandData[islandId]
	if not islandData then return { ok = false, reason = "INVALID_ISLAND" } end

	caveIndex = caveIndex or 1
	local cave = islandData.caves[caveIndex]
	if not cave then return { ok = false, reason = "INVALID_CAVE" } end

	-- Check level requirement
	if (data.playerLevel or 1) < cave.minLevel then
		return { ok = false, reason = "LEVEL_TOO_LOW", required = cave.minLevel }
	end

	-- Check guardian requirement
	if cave.requiresGuardian and not data.guardians[islandId] then
		return { ok = false, reason = "GUARDIAN_REQUIRED" }
	end

	-- Check item requirement
	if cave.requiresItem then
		-- Check if player has required item (simplified)
		local hasItem = false -- Would check inventory
		if not hasItem then
			return { ok = false, reason = "ITEM_REQUIRED", item = cave.requiresItem }
		end
	end

	-- Check not in encounter
	if require(script.Parent.EncounterService).active(player) then
		return { ok = false, reason = "IN_ENCOUNTER" }
	end

	-- Create cave instance
	local caveInstance = {
		player = player,
		islandId = islandId,
		caveIndex = caveIndex,
		caveData = cave,
		currentDepth = 1,
		startTime = os.time(),
		rewards = {},
		completed = false,
	}

	IS.ActiveCaves[player.UserId] = caveInstance

	-- Teleport to cave entrance
	local Transport = require(script.Parent.Transport)
	local entrancePos = cave.entrance + Vector3.new(0, 5, 0)
	Transport.go(player, entrancePos, islandId)

	-- Notify client
	local notice = RS:FindFirstChild("WildNotice")
	if notice then
		notice:FireClient(player, "Entrando na " .. cave.name .. " (Profundidade: " .. cave.depth .. ")")
	end

	return { ok = true, cave = caveInstance }
end

function IS.exitCave(player)
	local caveInstance = IS.ActiveCaves[player.UserId]
	if not caveInstance then return { ok = false, reason = "NOT_IN_CAVE" } end

	local islandId = caveInstance.islandId
	local Transport = require(script.Parent.Transport)
	local safePos = Region.safePoint(islandId)
	Transport.go(player, safePos, islandId)

	-- Give rewards
	local data = Data.get(player)
	if data and caveInstance.rewards then
		for resource, amount in caveInstance.rewards do
			data.materials[resource] = math.min(10000, (data.materials[resource] or 0) + amount)
		end
	end

	IS.ActiveCaves[player.UserId] = nil

	local notice = RS:FindFirstChild("WildNotice")
	if notice then
		notice:FireClient(player, "Saiu da caverna com recompensas!")
	end

	return { ok = true }
end

function IS.progressCave(player)
	local caveInstance = IS.ActiveCaves[player.UserId]
	if not caveInstance then return { ok = false, reason = "NOT_IN_CAVE" } end

	if caveInstance.currentDepth >= caveInstance.caveData.depth then
		return { ok = false, reason = "CAVE_COMPLETED" }
	end

	caveInstance.currentDepth += 1

	-- Generate encounter for this depth
	local EncounterService = require(script.Parent.EncounterService)
	local biomeId = caveInstance.islandId
	local depth = caveInstance.currentDepth

	-- Deeper = harder
	local levelBonus = depth * 2
	local rareChance = math.min(0.05 * depth, 0.3)

	-- Roll for encounter
	if math.random() < 0.7 then -- 70% chance per depth
		local pool = require(script.Parent.EncounterPools).list(biomeId, false)
		if #pool > 0 then
			local rng = Random.new()
			local g = pool[rng:NextInteger(1, #pool)]
			local glv = math.min(
				require(script.Parent.EncounterPools).rollLevel(biomeId, g.rar, rng) + levelBonus,
				100
			)

			-- Start encounter
			EncounterService.open(player, {
				id = g.id,
				lv = glv,
				position = player.Character.HumanoidRootPart.Position,
				capturable = true,
				caveDepth = depth,
				region = biomeId,
				isCave = true,
			}, function(result)
				if result and result.win then
					-- Add cave rewards
					local rewards = caveInstance.caveData.rewards
					for _, resource in rewards do
						caveInstance.rewards[resource] = (caveInstance.rewards[resource] or 0) + math.random(1, 3) * depth
					end

					-- Bonus for depth
					if depth == caveInstance.caveData.depth then
						caveInstance.completed = true
						for _, resource in rewards do
							caveInstance.rewards[resource] = (caveInstance.rewards[resource] or 0) + 10
						end
					end
				end
			end)
		end
	end

	return { ok = true, depth = caveInstance.currentDepth, maxDepth = caveInstance.caveData.depth }
end

function IS.checkSecretArea(player, islandId, areaName)
	local data = Data.get(player)
	if not data then return { ok = false, reason = "NO_DATA" } end

	local islandData = IS.IslandData[islandId]
	if not islandData then return { ok = false, reason = "INVALID_ISLAND" } end

	for _, area in islandData.secretAreas do
		if area.name == areaName then
			-- Check requirement
			local req = area.requirement
			local met = false

			if req:sub(1, 7) == "explore:" then
				local needed = tonumber(req:sub(8))
				met = (data.stats.explore or 0) >= needed
			elseif req:sub(1, 8) == "guardian:" then
				local guardianId = req:sub(9)
				met = data.guardians[guardianId] == true
			end

			if met then
				return { ok = true, reward = area.reward, area = area }
			else
				return { ok = false, reason = "REQUIREMENT_NOT_MET", requirement = req }
			end
		end
	end

	return { ok = false, reason = "AREA_NOT_FOUND" }
end

function IS.getIslandResources(islandId)
	local data = IS.IslandData[islandId]
	return data and data.uniqueResources or {}
end

function IS.getSpecialSpawns(islandId)
	local data = IS.IslandData[islandId]
	return data and data.specialSpawns or {}
end

-- Get cave status for player
function IS.getCaveStatus(player)
	local caveInstance = IS.ActiveCaves[player.UserId]
	if not caveInstance then return nil end

	return {
		islandId = caveInstance.islandId,
		caveName = caveInstance.caveData.name,
		currentDepth = caveInstance.currentDepth,
		maxDepth = caveInstance.caveData.depth,
		rewards = caveInstance.rewards,
		completed = caveInstance.completed,
		timeElapsed = os.time() - caveInstance.startTime,
	}
end

-- Cleanup on player leave
function IS.onPlayerRemoving(player)
	IS.ActiveCaves[player.UserId] = nil
end

game:GetService("Players").PlayerRemoving:Connect(IS.onPlayerRemoving)

return IS