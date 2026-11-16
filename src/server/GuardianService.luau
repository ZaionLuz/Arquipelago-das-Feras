--!nonstrict
-- GUARDIAN SERVICE - Guardian bosses, mechanics, rewards, rare boss spawning

local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local I = require(RS.Shared.Islands)
local C = require(RS.Shared.Creatures)
local MF = require(RS.Shared.ModelFactory)
local Data = require(script.Parent.DataService)
local Encounters = require(script.Parent.EncounterService)
local Species = require(RS.Shared.SpeciesRules)
local Bands = require(RS.Shared.LevelBands)
local Region = require(script.Parent.RegionService)
local World = require(script.Parent.WorldService)
local G = {}

-- Guardian configurations per island
G.GuardianConfig = {
	Alvorecer = {
		name = "Guardiao do Alvorecer",
		creatureId = "ancestral_natureza",
		baseLevel = 12,
		phases = 2,
		mechanics = { "heal", "summon", "buff" },
		rewards = { gold = 500, xp = 1000, materials = { Natureza = 20, Terra = 10 }, items = { "selo_guardiao_natureza" } },
		unlocks = { "Brasa", "Floresta" },
	},
	Brasa = {
		name = "Senhor das Brasas",
		creatureId = "piromante_lendario",
		baseLevel = 20,
		phases = 3,
		mechanics = { "burn", "explosion", "lava_wave", "summon_minions" },
		rewards = { gold = 1200, xp = 2500, materials = { Fogo = 30, Metal = 15, Cristal = 10 }, items = { "selo_guardiao_fogo", "essencia_puro_fogo" } },
		unlocks = { "Dunas", "Forja" },
	},
	Recife = {
		name = "Rainha dos Corais",
		creatureId = "sereia_profunda",
		baseLevel = 28,
		phases = 3,
		mechanics = { "heal_tide", "water_prison", "coral_barrier", "summon_school" },
		rewards = { gold = 2000, xp = 4000, materials = { Agua = 30, Cristal = 20, Luz = 10 }, items = { "selo_guardiao_agua", "coral_antigo" } },
		unlocks = { "Pantano", "Geoda" },
	},
	Floresta = {
		name = "Ancestral da Floresta",
		creatureId = "druida_ancestral",
		baseLevel = 36,
		phases = 3,
		mechanics = { "root", "thorns", "nature_wrath", "spirit_summon" },
		rewards = { gold = 3500, xp = 7000, materials = { Natureza = 40, Terra = 20, Sombra = 15 }, items = { "selo_guardiao_natureza", "semente_mundial" } },
		unlocks = { "Picos", "Celestial" },
	},
	Dunas = {
		name = "Farao das Areias",
		creatureId = "esfinge_dourada",
		baseLevel = 44,
		phases = 4,
		mechanics = { "sandstorm", "time_slow", "mummy_summon", "obelisk_beam" },
		rewards = { gold = 5500, xp = 11000, materials = { Terra = 40, Metal = 25, Luz = 20 }, items = { "selo_guardiao_terra", "relogio_areia" } },
		unlocks = { "Picos", "Forja" },
	},
	Picos = {
		name = "Senhor dos Ventos",
		creatureId = "aguia_celestial",
		baseLevel = 52,
		phases = 4,
		mechanics = { "wind_push", "lightning_strike", "tornado", "sky_dive" },
		rewards = { gold = 8500, xp = 17000, materials = { Ar = 50, Gelo = 25, Eletrico = 20, Luz = 15 }, items = { "selo_guardiao_ar", "pena_celestial" } },
		unlocks = { "Inverno", "Trovao" },
	},
	Pantano = {
		name = "Mestre do Vazio",
		creatureId = "fantasma_umbral",
		baseLevel = 60,
		phases = 4,
		mechanics = { "void_rift", "shadow_clone", "fear", "soul_drain", "void_touch" },
		rewards = { gold = 13000, xp = 26000, materials = { Sombra = 50, Agua = 30, Arcano = 25 }, items = { "selo_guardiao_sombra", "essencia_vazio" } },
		unlocks = { "Vazio" },
	},
	Inverno = {
		name = "Imperador do Gelo",
		creatureId = "dragao_gelo_eterno",
		baseLevel = 68,
		phases = 5,
		mechanics = { "freeze", "blizzard", "ice_shards", "frozen_throne", "absolute_zero" },
		rewards = { gold = 20000, xp = 40000, materials = { Gelo = 60, Cristal = 30, Metal = 25 }, items = { "selo_guardiao_gelo", "coracao_gelo" } },
		unlocks = { "Celestial", "Geoda" },
	},
	Trovao = {
		name = "Avatar da Tempestade",
		creatureId = "elemental_raio_supremo",
		baseLevel = 76,
		phases = 5,
		mechanics = { "chain_lightning", "thunder_clap", "storm_eye", "overcharge", "judgment_bolt" },
		rewards = { gold = 30000, xp = 60000, materials = { Eletrico = 60, Metal = 35, Ar = 30 }, items = { "selo_guardiao_eletrico", "nucleo_raio" } },
		unlocks = { "Forja", "Vazio" },
	},
	Celestial = {
		name = "Serafim da Luz",
		creatureId = "serafim_radiante",
		baseLevel = 84,
		phases = 5,
		mechanics = { "holy_nova", "light_beam", "divine_shield", "starfall", "ascension" },
		rewards = { gold = 45000, xp = 90000, materials = { Luz = 70, Cristal = 40, Arcano = 35 }, items = { "selo_guardiao_luz", "fragmento_estrela" } },
		unlocks = { "Geoda" },
	},
	Forja = {
		name = "Mestre Forjador",
		creatureId = "golem_primordial",
		baseLevel = 92,
		phases = 6,
		mechanics = { "hammer_strike", "molten_wave", "forge_armor", "weapon_summon", "core_overload", "primordial_flame" },
		rewards = { gold = 65000, xp = 130000, materials = { Metal = 80, Fogo = 50, Terra = 40, Cristal = 30 }, items = { "selo_guardiao_metal", "martelo_primordial" } },
		unlocks = { "Geoda" },
	},
	Geoda = {
		name = "Guardiao Cristalino",
		creatureId = "dragao_cristal_mestre",
		baseLevel = 96,
		phases = 6,
		mechanics = { "crystal_reflect", "prism_beam", "shard_storm", "mirror_image", "resonance", "perfect_crystal" },
		rewards = { gold = 100000, xp = 200000, materials = { Cristal = 100, Luz = 60, Arcano = 50 }, items = { "selo_guardiao_cristal", "cristal_puro" } },
		unlocks = { "Vazio" },
	},
	Vazio = {
		name = "Entidade do Vazio",
		creatureId = "void_avatar",
		baseLevel = 100,
		phases = 7,
		mechanics = { "void_erase", "reality_tear", "null_zone", "entropy", "silence", "absolute_void", "end_of_all" },
		rewards = { gold = 200000, xp = 500000, materials = { Arcano = 100, Sombra = 80, Vazio = 50 }, items = { "selo_guardiao_arcano", "chave_vazio" } },
		unlocks = {},
	},
}

-- Active guardians
G.ActiveGuardians = {}
G.RareBosses = {}

function G.start()
	local folder = Instance.new("Folder")
	folder.Name = "Guardioes"
	folder.Parent = workspace

	for _, island in I.List do
		G.spawnGuardian(island.id, folder)
	end

	print("[GuardianService] All guardians spawned")
end

function G.spawnGuardian(islandId, parent)
	local config = G.GuardianConfig[islandId]
	if not config then return end

	local islandDef = I.ById[islandId]
	if not islandDef then return end

	-- Find suitable creature
	local chosen = nil
	for _, def in C.List do
		if def.id == config.creatureId then
			chosen = def
			break
		end
	end

	if not chosen then
		-- Fallback: find any legendary creature of matching element
		for _, def in C.List do
			if def.el == islandDef.el and def.rar >= 4 and Species.isGeneral(def.id) then
				chosen = def
				break
			end
		end
	end

	if not chosen then return end

	local level = config.baseLevel
	local model = MF.build(chosen, level)

	-- Scale up for guardian
	local scale = 1.5 + (level / 100) * 0.5
	model:ScaleTo(scale)

	-- Position
	local pos = I.pos(islandDef.idx) + Vector3.new(-20, 4, 8)
	local box, size = model:GetBoundingBox()
	local lift = model:GetPivot().Position.Y - (box.Position.Y - size.Y / 2)
	model:PivotTo(CFrame.new(pos + Vector3.new(0, lift, 0)))

	model.Parent = parent

	-- Add guardian attributes
	model:SetAttribute("GuardianIsland", islandId)
	model:SetAttribute("GuardianLevel", level)
	model:SetAttribute("GuardianConfig", config.name)
	model:SetAttribute("GuardianPhases", config.phases)
	model:SetAttribute("GuardianCurrentPhase", 1)
	model:SetAttribute("GuardianMaxHealth", model:GetAttribute("MaxHealth") or 1000)

	-- Add guardian aura
	G.addGuardianAura(model, islandDef.el)

	-- Proximity prompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = Text.DESAFIAR_GUARDIAO_C2DC77
	prompt.ObjectText = config.name .. " \194\183 Nv." .. level
	prompt.HoldDuration = 0.8
	prompt.MaxActivationDistance = 11
	prompt.Parent = model.PrimaryPart

	prompt.Triggered:Connect(function(p)
		G.onGuardianChallenged(p, islandId, model, config)
	end)

	G.ActiveGuardians[islandId] = {
		model = model,
		config = config,
		currentPhase = 1,
		health = model:GetAttribute("MaxHealth") or 1000,
		maxHealth = model:GetAttribute("MaxHealth") or 1000,
		lastChallenge = 0,
	}

	return model
end

function G.addGuardianAura(model, element)
	local Tokens = require(RS.Shared.ArtTokens)
	local auraConfig = Tokens.AuraPresets[element] or Tokens.AuraPresets.Metal

	-- Neon highlight
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.8
	highlight.OutlineColor = auraConfig.NeonColor
	highlight.OutlineTransparency = 0
	highlight.Parent = model

	-- Particle emitter on primary part
	if model.PrimaryPart then
		local emitter = Instance.new("ParticleEmitter")
		emitter.Color = auraConfig.ParticleConfig.Color
		emitter.Size = auraConfig.ParticleConfig.Size
		emitter.Lifetime = auraConfig.ParticleConfig.Lifetime
		emitter.Rate = auraConfig.ParticleConfig.Rate
		emitter.Speed = auraConfig.ParticleConfig.Speed
		emitter.SpreadAngle = auraConfig.ParticleConfig.SpreadAngle
		emitter.Drag = auraConfig.ParticleConfig.Drag
		emitter.LightEmission = 1
		emitter.Parent = model.PrimaryPart
	end

	-- Light
	if model.PrimaryPart then
		local light = Instance.new("PointLight")
		light.Color = auraConfig.LightColor
		light.Brightness = auraConfig.LightBrightness
		light.Range = auraConfig.LightRange
		light.Parent = model.PrimaryPart
	end
end

function G.onGuardianChallenged(player, islandId, model, config)
	local data = Data.get(player)
	if not data then return end

	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root or (root.Position - model.PrimaryPart.Position).Magnitude > 13 then return end

	if not data.unlocked[islandId] then return end

	if Encounters.active(player) then return end

	if data.guardians[islandId] then
		local notice = RS:FindFirstChild("WildNotice")
		if notice then
			notice:FireClient(player, Text.VOCE_JA_CONCLUIU_ESTE_DESAFIO_DE_GUARDIAO_12DC0F)
		end
		return
	end

	if not Region.requireCurrent(player, islandId, "battle").ok then return end

	local guardian = G.ActiveGuardians[islandId]
	if not guardian then return end

	-- Cooldown check
	if os.time() - guardian.lastChallenge < 30 then
		local notice = RS:FindFirstChild("WildNotice")
		if notice then
			notice:FireClient(player, "O guardiao precisa descansar. Tente novamente em " .. (30 - (os.time() - guardian.lastChallenge)) .. "s")
		end
		return
	end

	guardian.lastChallenge = os.time()

	-- Start guardian battle
	Encounters.open(player, {
		id = config.creatureId,
		lv = config.baseLevel,
		position = model.PrimaryPart.Position,
		capturable = false,
		guardianId = islandId,
		region = islandId,
		statMultiplier = 1.17,
		isGuardian = true,
		guardianPhases = config.phases,
		guardianMechanics = config.mechanics,
	}, function(result)
		G.onGuardianBattleEnd(player, islandId, result, config)
	end)
end

function G.onGuardianBattleEnd(player, islandId, result, config)
	local data = Data.get(player)
	if not data then return end

	local guardian = G.ActiveGuardians[islandId]
	if not guardian then return end

	if result and result.win then
		-- Victory!
		data.guardians[islandId] = true

		-- Give rewards
		data.gold += config.rewards.gold
		local Progression = require(RS.Shared.Progression)
		Progression.award(data, config.rewards.xp)

		for material, amount in config.rewards.materials do
			data.materials[material] = math.min(10000, (data.materials[material] or 0) + amount)
		end

		-- Unlock new islands
		for _, unlockId in config.unlocks do
			if not data.unlocked[unlockId] then
				data.unlocked[unlockId] = true
			end
		end

		-- Visual feedback
		guardian.model:SetAttribute("LastChallengeEnded", os.time())
		guardian.model:SetAttribute("Defeated", true)

		-- Change appearance to show defeated
		G.setGuardianDefeated(guardian.model)

		-- Notify
		local notice = RS:FindFirstChild("WildNotice")
		if notice then
			notice:FireClient(player, "Voce derrotou " .. config.name .. "! Novas ilhas desbloqueadas: " .. table.concat(config.unlocks, ", "))
		end

		-- Unlock mount point
		Region.MountPoints[islandId] = Region.MountPoints[islandId] or {}
		Region.MountPoints[islandId].unlocked = true

		-- Award trophy
		data.trophies += 1
		data.stats.guardianWins = (data.stats.guardianWins or 0) + 1

	else
		-- Defeat
		local notice = RS:FindFirstChild("WildNotice")
		if notice then
			notice:FireClient(player, "Voce foi derrotado por " .. config.name .. ". Treine mais e tente novamente!")
		end
	end
end

function G.setGuardianDefeated(model)
	-- Visual changes to show defeated
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			part.Material = Enum.Material.Slate
			part.Color = part.Color:Lerp(Color3.fromRGB(100, 100, 100), 0.5)
		end
	end

	-- Remove aura
	for _, child in model:GetChildren() do
		if child:IsA("Highlight") or child:IsA("ParticleEmitter") or child:IsA("PointLight") then
			child:Destroy()
		end
	end

	-- Add defeated marker
	local billboard = Instance.new("BillboardGui")
	billboard.Size = UDim2.fromOffset(200, 50)
	billboard.StudsOffset = Vector3.new(0, 15, 0)
	billboard.MaxDistance = 100
	billboard.Parent = model.PrimaryPart

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = "DERROTADO"
	label.TextColor3 = Color3.fromRGB(100, 255, 100)
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	label.TextScaled = true
	label.Font = Enum.Font.Arcade
	label.Parent = billboard
end

-- Rare Boss System
function G.spawnRareBoss(biomeId, levelBonus, rewardMultiplier)
	local islandDef = I.ById[biomeId]
	if not islandDef then return end

	-- Pick a rare creature for this biome
	local candidates = {}
	for _, def in C.List do
		if def.island == biomeId and def.rar >= 3 and Species.isGeneral(def.id) then
			table.insert(candidates, def)
		end
	end

	if #candidates == 0 then return end

	local chosen = candidates[math.random(1, #candidates)]
	local level = math.min((Bands.ById[biomeId].max or 50) + levelBonus, 100)

	local model = MF.build(chosen, level)
	model:ScaleTo(2.0) -- Rare bosses are huge

	local pos = I.pos(islandDef.idx) + Vector3.new(math.random(-30, 30), 10, math.random(-30, 30))
	local box, size = model:GetBoundingBox()
	local lift = model:GetPivot().Position.Y - (box.Position.Y - size.Y / 2)
	model:PivotTo(CFrame.new(pos + Vector3.new(0, lift, 0)))

	model.Parent = workspace

	-- Rare boss attributes
	model:SetAttribute("RareBoss", true)
	model:SetAttribute("BossBiome", biomeId)
	model:SetAttribute("BossLevel", level)
	model:SetAttribute("BossCreature", chosen.id)
	model:SetAttribute("BossRewardMultiplier", rewardMultiplier)
	model:SetAttribute("BossMaxHealth", model:GetAttribute("MaxHealth") or 2000)

	-- Special rare boss aura (golden)
	local highlight = Instance.new("Highlight")
	highlight.FillTransparency = 0.5
	highlight.OutlineColor = Color3.fromRGB(255, 215, 0)
	highlight.OutlineTransparency = 0
	highlight.Parent = model

	-- Particles
	if model.PrimaryPart then
		local emitter = Instance.new("ParticleEmitter")
		emitter.Color = ColorSequence.new(Color3.fromRGB(255, 215, 0), Color3.fromRGB(255, 100, 0))
		emitter.Size = NumberSequence.new(1, 0)
		emitter.Lifetime = NumberRange.new(1, 2)
		emitter.Rate = 30
		emitter.Speed = NumberRange.new(5, 10)
		emitter.SpreadAngle = Vector2.new(180, 180)
		emitter.LightEmission = 1
		emitter.Parent = model.PrimaryPart
	end

	-- Prompt
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = "Desafiar Chefe Raro"
	prompt.ObjectText = chosen.name .. " \194\183 Nv." .. level .. " \194\183 RARO"
	prompt.HoldDuration = 1
	prompt.MaxActivationDistance = 15
	prompt.Parent = model.PrimaryPart

	prompt.Triggered:Connect(function(p)
		G.onRareBossChallenged(p, model, biomeId, chosen, level, rewardMultiplier)
	end)

	-- Despawn after 10 minutes
	game:GetService("Debris"):AddItem(model, 600)

	G.RareBosses[model] = {
		biomeId = biomeId,
		creatureId = chosen.id,
		level = level,
		rewardMultiplier = rewardMultiplier,
		spawnTime = os.time(),
	}

	-- Announce to nearby players
	local notice = RS:FindFirstChild("WildNotice")
	if notice then
		for _, player in game:GetService("Players"):GetPlayers() do
			local region = Region.current(player, "encounter")
			if region == biomeId then
				notice:FireClient(player, "UM CHEFE RARO APARECEU EM " .. string.upper(islandDef.name) .. "! " .. chosen.name .. " Nv." .. level)
			end
		end
	end
end

function G.onRareBossChallenged(player, model, biomeId, creatureDef, level, rewardMultiplier)
	local data = Data.get(player)
	if not data then return end

	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root or (root.Position - model.PrimaryPart.Position).Magnitude > 18 then return end

	if Encounters.active(player) then return end

	if not Region.requireCurrent(player, biomeId, "battle").ok then return end

	Encounters.open(player, {
		id = creatureDef.id,
		lv = level,
		position = model.PrimaryPart.Position,
		capturable = true, -- Rare bosses can be captured!
		region = biomeId,
		statMultiplier = 1.25,
		isRareBoss = true,
		rewardMultiplier = rewardMultiplier,
	}, function(result)
		G.onRareBossBattleEnd(player, model, result, rewardMultiplier)
	end)
end

function G.onRareBossBattleEnd(player, model, result, rewardMultiplier)
	local data = Data.get(player)
	if not data then return end

	if result and result.win then
		-- Give enhanced rewards
		local baseGold = 5000 * rewardMultiplier
		local baseXp = 10000 * rewardMultiplier

		data.gold += math.floor(baseGold)
		local Progression = require(RS.Shared.Progression)
		Progression.award(data, math.floor(baseXp))

		-- Bonus materials
		local biomeData = require(script.Parent.IslandService).getIslandResources(model:GetAttribute("BossBiome"))
		for _, material in biomeData do
			data.materials[material] = math.min(10000, (data.materials[material] or 0) + math.floor(20 * rewardMultiplier))
		end

		-- Rare boss trophy
		data.trophies += 5
		data.stats.rareBossWins = (data.stats.rareBossWins or 0) + 1

		local notice = RS:FindFirstChild("WildNotice")
		if notice then
			notice:FireClient(player, "CHEFE RARO DERROTADO! Recompensas aumentadas: +" .. math.floor(baseGold) .. " ouro, +" .. math.floor(baseXp) .. " XP")
		end

		-- Visual
		model:SetAttribute("Defeated", true)
		G.setGuardianDefeated(model)
	else
		local notice = RS:FindFirstChild("WildNotice")
		if notice then
			notice:FireClient(player, "O chefe raro foi muito forte... Tente novamente com uma equipe melhor!")
		end
	end

	G.RareBosses[model] = nil
end

function G.despawnRareBosses()
	for model, _ in G.RareBosses do
		if model and model.Parent then
			model:Destroy()
		end
	end
	G.RareBosses = {}
end

-- Get guardian status for player
function G.getGuardianStatus(player)
	local data = Data.get(player)
	if not data then return {} end

	local status = {}
	for _, island in I.List do
		status[island.id] = {
			defeated = data.guardians[island.id] or false,
			level = G.GuardianConfig[island.id] and G.GuardianConfig[island.id].baseLevel or 0,
			unlocked = data.unlocked[island.id] or false,
		}
	end
	return status
end

-- Check if all guardians defeated
function G.allGuardiansDefeated(player)
	local data = Data.get(player)
	if not data then return false end

	for _, island in I.List do
		if not data.guardians[island.id] then
			return false
		end
	end
	return true
end

-- Phoenix Guardian (ultimate challenge)
G.PhoenixConfig = {
	name = "Fenix Primordial",
	creatureId = "fenix_primordial",
	level = 100,
	phases = 7,
	mechanics = { "rebirth", "solar_flare", "ash_cloud", "immortal_flame", "cycle_of_life", "eternal_return", "genesis" },
	rewards = { gold = 500000, xp = 1000000, materials = { Fogo = 200, Luz = 200, Arcano = 200, Cristal = 100 }, items = { "selo_fenix", "penna_fenix", "cinza_eterna" } },
	requirements = { allGuardians = true, phoenixGlyphs = 9 },
}

function G.canChallengePhoenix(player)
	local data = Data.get(player)
	if not data then return { ok = false, reason = "NO_DATA" } end

	if not G.allGuardiansDefeated(player) then
		return { ok = false, reason = "NOT_ALL_GUARDIANS" }
	end

	local glyphs = 0
	for _, v in data.phoenix.glyphs do
		if v then glyphs += 1 end
	end

	if glyphs < G.PhoenixConfig.requirements.phoenixGlyphs then
		return { ok = false, reason = "NOT_ENOUGH_GLYPHS", glyphs = glyphs, needed = G.PhoenixConfig.requirements.phoenixGlyphs }
	end

	if data.phoenix.captured then
		return { ok = false, reason = "ALREADY_CAPTURED" }
	end

	if (data.phoenix.nextAttemptAt or 0) > os.time() then
		return { ok = false, reason = "ON_COOLDOWN", retryAt = data.phoenix.nextAttemptAt }
	end

	return { ok = true }
end

function G.startPhoenixBattle(player)
	local check = G.canChallengePhoenix(player)
	if not check.ok then return check end

	local data = Data.get(player)
	data.phoenix.attempts = (data.phoenix.attempts or 0) + 1

	-- Spawn phoenix at central location
	local center = Vector3.new(0, 50, 0)

	Encounters.open(player, {
		id = G.PhoenixConfig.creatureId,
		lv = G.PhoenixConfig.level,
		position = center,
		capturable = true,
		guardianId = "Phoenix",
		region = "Phoenix",
		statMultiplier = 1.5,
		isPhoenix = true,
		phoenixPhases = G.PhoenixConfig.phases,
		phoenixMechanics = G.PhoenixConfig.mechanics,
	}, function(result)
		G.onPhoenixBattleEnd(player, result)
	end)

	return { ok = true }
end

function G.onPhoenixBattleEnd(player, result)
	local data = Data.get(player)
	if not data then return end

	if result and result.win then
		-- CAPTURED THE PHOENIX!
		data.phoenix.captured = true
		data.phoenix.captureTime = os.time()

		-- Ultimate rewards
		data.gold += G.PhoenixConfig.rewards.gold
		local Progression = require(RS.Shared.Progression)
		Progression.award(data, G.PhoenixConfig.rewards.xp)

		for material, amount in G.PhoenixConfig.rewards.materials do
			data.materials[material] = math.min(10000, (data.materials[material] or 0) + amount)
		end

		-- Grant phoenix as creature
		local Grant = require(RS.Shared.CreatureGrant)
		Grant.grant(data, "fenix_primordial", "phoenix", "phoenix:victory")

		-- Unlock sanctuary
		data.phoenix.sanctuaryOpen = true

		-- Trophy
		data.trophies += 100

		local notice = RS:FindFirstChild("WildNotice")
		if notice then
			notice:FireClient(player, "VOCE CAPTUROU A FENIX PRIMORDIAL! A maior conquista de Arquipelago!")
		end

		-- Global announcement
		for _, p in game:GetService("Players"):GetPlayers() do
			if p ~= player then
				notice:FireClient(p, player.DisplayName .. " CAPTUROU A FENIX PRIMORDIAL! Uma lenda nasceu hoje!")
			end
		end
	else
		-- Failed attempt
		data.phoenix.nextAttemptAt = os.time() + require(RS.Shared.Config).PhoenixRetrySeconds

		local notice = RS:FindFirstChild("WildNotice")
		if notice then
			notice:FireClient(player, "A Fenix renasceu das cinzas... Voce pode tentar novamente em 20 minutos.")
		end
	end
end

return G