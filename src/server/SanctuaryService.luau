--!nonstrict
-- SANCTUARY SERVICE - Personal sanctuaries per island theme, 9 plots per player
-- Habitat themes match island element

local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local Data = require(script.Parent.DataService)
local I = require(RS.Shared.Islands)
local Rules = require(RS.Shared.SanctuaryRules)
local Art = require(script.Parent.WorldArt)
local Tokens = require(RS.Shared.ArtTokens)
local Transport = require(script.Parent.Transport)
local Region = require(script.Parent.RegionService)
local S = {}

local plots = {}
local used = {}
local V = Vector3.new

-- Sanctuary themes per island element
S.SanctuaryThemes = {
	Alvorecer = { -- Natureza
		name = "Bosque do Alvorecer",
		groundColor = Color3.fromRGB(85, 132, 106),
		groundMaterial = Enum.Material.Grass,
		accentColor = Color3.fromRGB(183, 232, 139),
		skyColor = Color3.fromRGB(134, 163, 137),
		ambient = Color3.fromRGB(100, 150, 100),
		features = { "arvores", "flores", "fonte", "bancos" },
		habitatStyle = "Leaf",
	},
	Brasa = { -- Fogo
		name = "Caldeirao das Brasas",
		groundColor = Color3.fromRGB(60, 38, 36),
		groundMaterial = Enum.Material.Basalt,
		accentColor = Color3.fromRGB(255, 96, 32),
		skyColor = Color3.fromRGB(150, 80, 50),
		ambient = Color3.fromRGB(150, 50, 30),
		features = { "lava", "basalto", "cristais_fogo", "forja" },
		habitatStyle = "Ember",
	},
	Recife = { -- Agua
		name = "Jardim Coralino",
		groundColor = Color3.fromRGB(70, 150, 190),
		groundMaterial = Enum.Material.Slate,
		accentColor = Color3.fromRGB(120, 255, 235),
		skyColor = Color3.fromRGB(90, 150, 190),
		ambient = Color3.fromRGB(80, 130, 180),
		features = { "corais", "conchas", "agua_cristalina", "bolhas" },
		habitatStyle = "Tidal",
	},
	Floresta = { -- Natureza
		name = "Clareira Sussurrante",
		groundColor = Color3.fromRGB(60, 130, 70),
		groundMaterial = Enum.Material.Grass,
		accentColor = Color3.fromRGB(150, 230, 90),
		skyColor = Color3.fromRGB(80, 140, 90),
		ambient = Color3.fromRGB(70, 130, 80),
		features = { "arvores_antigas", "cogumelos", "luz_filtrada", "vinhas" },
		habitatStyle = "Leaf",
	},
	Dunas = { -- Terra
		name = "Oasis das Dunas",
		groundColor = Color3.fromRGB(210, 170, 100),
		groundMaterial = Enum.Material.Sandstone,
		accentColor = Color3.fromRGB(150, 100, 60),
		skyColor = Color3.fromRGB(200, 160, 100),
		ambient = Color3.fromRGB(180, 140, 80),
		features = { "palmeiras", "agua_oasis", "ruinas", "areia_dourada" },
		habitatStyle = "Sand",
	},
	Picos = { -- Ar
		name = "Ninho das Nuvens",
		groundColor = Color3.fromRGB(190, 210, 235),
		groundMaterial = Enum.Material.SmoothPlastic,
		accentColor = Color3.fromRGB(255, 255, 255),
		skyColor = Color3.fromRGB(180, 200, 230),
		ambient = Color3.fromRGB(170, 190, 220),
		features = { "nuvens_solidas", "cristais_ceu", "ventos", "altares" },
		habitatStyle = "Sky",
	},
	Pantano = { -- Sombra
		name = "Pantano Umbral",
		groundColor = Color3.fromRGB(45, 40, 70),
		groundMaterial = Enum.Material.Slate,
		accentColor = Color3.fromRGB(190, 90, 255),
		skyColor = Color3.fromRGB(70, 50, 110),
		ambient = Color3.fromRGB(50, 40, 90),
		features = { "nevoa", "luzes_enganosas", "arvores_torcidas", "portais" },
		habitatStyle = "Veil",
	},
	Inverno = { -- Gelo
		name = "Cidadela de Gelo",
		groundColor = Color3.fromRGB(170, 210, 255),
		groundMaterial = Enum.Material.Ice,
		accentColor = Color3.fromRGB(100, 200, 255),
		skyColor = Color3.fromRGB(150, 190, 240),
		ambient = Color3.fromRGB(140, 180, 230),
		features = { "gelo_eterno", "cristais_gelo", "aurora", "estatuas_gelo" },
		habitatStyle = "Sky",
	},
	Trovao = { -- Eletrico
		name = "Pico da Tempestade",
		groundColor = Color3.fromRGB(80, 80, 120),
		groundMaterial = Enum.Material.Metal,
		accentColor = Color3.fromRGB(255, 255, 100),
		skyColor = Color3.fromRGB(100, 100, 150),
		ambient = Color3.fromRGB(80, 80, 130),
		features = { "condutores", "raios", "estatica", "bobinas" },
		habitatStyle = "Ember",
	},
	Celestial = { -- Luz
		name = "Jardim das Estrelas",
		groundColor = Color3.fromRGB(220, 230, 255),
		groundMaterial = Enum.Material.SmoothPlastic,
		accentColor = Color3.fromRGB(255, 255, 200),
		skyColor = Color3.fromRGB(200, 210, 255),
		ambient = Color3.fromRGB(190, 200, 255),
		features = { "luz_pura", "estrelas", "cristais_luz", "fontes_cura" },
		habitatStyle = "Sky",
	},
	Forja = { -- Metal
		name = "Coracao da Forja",
		groundColor = Color3.fromRGB(90, 80, 70),
		groundMaterial = Enum.Material.Metal,
		accentColor = Color3.fromRGB(255, 150, 50),
		skyColor = Color3.fromRGB(120, 100, 80),
		ambient = Color3.fromRGB(100, 80, 60),
		features = { "bigornas", "metal_derretido", "ferramentas", "chamas_azuis" },
		habitatStyle = "Ember",
	},
	Geoda = { -- Cristal
		name = "Camara Cristalina",
		groundColor = Color3.fromRGB(150, 130, 180),
		groundMaterial = Enum.Material.Glass,
		accentColor = Color3.fromRGB(200, 150, 255),
		skyColor = Color3.fromRGB(160, 140, 200),
		ambient = Color3.fromRGB(140, 120, 180),
		features = { "cristais_grandes", "reflexos", "geodas", "luz_refratada" },
		habitatStyle = "Tidal",
	},
	Vazio = { -- Arcano
		name = "Limite do Vazio",
		groundColor = Color3.fromRGB(30, 20, 50),
		groundMaterial = Enum.Material.Glass,
		accentColor = Color3.fromRGB(150, 50, 255),
		skyColor = Color3.fromRGB(50, 30, 90),
		ambient = Color3.fromRGB(40, 20, 80),
		features = { "vazio", "estrelas_mortas", "energia_negra", "silencio" },
		habitatStyle = "Veil",
	},
}

local function part(parent, name, size, position, color, material, collide, shape)
	local p = Instance.new("Part")
	p.Name = name
	p.Size = size
	p.Position = position
	p.Anchored = true
	p.CanCollide = collide == true
	p.CanTouch = false
	p.Material = material or Enum.Material.SmoothPlastic
	p.Color = color
	p.Shape = shape or Enum.PartType.Block
	p.Parent = parent
	return p
end

function S.ensure(player)
	if plots[player] then
		return plots[player]
	end
	local index = 1
	while used[index] do
		index += 1
	end
	used[index] = true
	local center = V(((index - 1) % 4) * 190, 12, 850 + math.floor((index - 1) / 4) * 190)
	local root = workspace:FindFirstChild("Santuarios") or Instance.new("Folder", workspace)
	root.Name = "Santuarios"
	local folder = Instance.new("Folder")
	folder.Name = tostring(player.UserId)
	folder:SetAttribute("OwnerUserId", player.UserId)
	folder.Parent = root

	-- Build base sanctuary (will be customized by theme)
	local _base = part(
		folder,
		Text.ILHA_PESSOAL_498B3B,
		V(144, 4, 144),
		center,
		Color3.fromRGB(85, 132, 106),
		Enum.Material.Grass,
		true
	)
	part(
		folder,
		Text.ROCHA_FLUTUANTE_B3C46F,
		V(142, 35, 142),
		center - V(0, 15, 0),
		Color3.fromRGB(74, 87, 92),
		Enum.Material.Rock,
		false,
		Enum.PartType.Ball
	)
	part(
		folder,
		Text.CAMINHO_CENTRAL_22B87F,
		V(9, 0.2, 125),
		center + V(0, 2.2, 0),
		Color3.fromRGB(202, 194, 165),
		Enum.Material.Cobblestone,
		false
	)
	local sign = part(
		folder,
		Text.PORTAL_DE_RETORNO_18016A,
		V(7, 9, 2),
		center + V(0, 6, 61),
		Color3.fromRGB(80, 146, 166),
		Enum.Material.Neon,
		false
	)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = Text.VOLTAR_A_AVENTURA_D7DC5A
	prompt.ObjectText = Text.PORTAL_DO_SANTUARIO_1F3781
	prompt.HoldDuration = 0.4
	prompt.MaxActivationDistance = 10
	prompt.Parent = sign
	prompt.Triggered:Connect(function(p)
		local d = Data.get(p)
		local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		if p ~= player or not d or not hrp or (hrp.Position - sign.Position).Magnitude > 12 then
			return
		end
		if require(script.Parent.EncounterService).active(p) then
			return
		end
		require(script.Parent.Transport).go(p, I.pos(1) + V(0, 9, 24), "Alvorecer")
	end)

	local plot = { index = index, center = center, folder = folder, signature = "", theme = "Alvorecer" }
	plots[player] = plot
	return plot
end

function S.position(player, island)
	local d = Data.get(player)
	local entry = d and d.sanctuary[island]
	if not entry then
		return nil
	end
	local x, z = Rules.slot(entry.slot)
	return S.ensure(player).center + V(x, 2, z)
end

function S.getTheme(islandId)
	return S.SanctuaryThemes[islandId] or S.SanctuaryThemes.Alvorecer
end

function S.applyTheme(player, islandId)
	local plot = S.ensure(player)
	local theme = S.getTheme(islandId)

	-- Update plot theme
	plot.theme = islandId

	-- Recolor base
	for _, obj in plot.folder:GetChildren() do
		if obj:IsA("BasePart") and obj.Name == Text.ILHA_PESSOAL_498B3B then
			obj.Color = theme.groundColor
			obj.Material = theme.groundMaterial
		elseif obj:IsA("BasePart") and obj.Name == Text.CAMINHO_CENTRAL_22B87F then
			obj.Color = theme.accentColor:Lerp(Color3.fromRGB(200, 190, 160), 0.5)
		elseif obj:IsA("BasePart") and obj.Name == Text.PORTAL_DE_RETORNO_18016A then
			obj.Color = theme.accentColor
		end
	end

	-- Apply habitat styling
	local folder = plot.folder:FindFirstChild("Habitats")
	if folder then
		for _, zone in folder:GetChildren() do
			if zone:IsA("Model") then
				local habitatIsland = zone.Name
				local hTheme = S.getTheme(habitatIsland)
				Art.habitat(zone, zone:GetPivot().Position, habitatIsland)
			end
		end
	end

	return theme
end

function S.refresh(player)
	local d = Data.get(player)
	if not d then return end

	local plot = S.ensure(player)
	local keys = {}
	for id, entry in d.sanctuary do
		table.insert(keys, id .. ":" .. entry.slot .. ":" .. entry.level .. ":" .. #(d.habitat[id] or {}))
	end
	table.sort(keys)
	local signature = table.concat(keys, "|")
	if plot.signature == signature then
		return
	end
	plot.signature = signature

	local old = plot.folder:FindFirstChild("Habitats")
	if old then
		old:Destroy()
	end

	local folder = Instance.new("Folder")
	folder.Name = "Habitats"
	folder.Parent = plot.folder

	-- Determine primary theme (first unlocked sanctuary or Alvorecer)
	local primaryIsland = "Alvorecer"
	for _, def in I.List do
		if d.unlocked[def.id] and d.sanctuary[def.id] then
			primaryIsland = def.id
			break
		end
	end
	S.applyTheme(player, primaryIsland)

	for id, entry in d.sanctuary do
		local def = I.ById[id]
		local pos = S.position(player, id)
		local zone = Instance.new("Model")
		zone.Name = def.name
		zone:SetAttribute("OwnerUserId", player.UserId)
		zone.Parent = folder

		-- Theme-aware habitat base
		local theme = S.getTheme(id)
		local base = part(zone, "Habitat", V(28, 0.4, 28), pos + V(0, 0.2, 0), theme.groundColor, theme.groundMaterial, true)

		-- Elemental markers
		for _, sx in { -1, 1 } do
			for _, sz in { -1, 1 } do
				part(
					zone,
					Text.MARCO_ELEMENTAL_3DB8E3,
					V(2, 3 + entry.level, 2),
					pos + V(sx * 12, 2, sz * 12),
					theme.accentColor,
					Enum.Material.Neon,
					false
				)
			end
		end

		-- Label
		local label = Instance.new("BillboardGui")
		label.Size = UDim2.fromOffset(190, 45)
		label.StudsOffset = V(0, 5, 0)
		label.MaxDistance = 70
		label.Parent = base
		local text = Instance.new("TextLabel")
		text.Size = UDim2.fromScale(1, 1)
		text.BackgroundTransparency = 1
		text.TextColor3 = Tokens.Ink
		text.TextStrokeTransparency = 0.4
		text.TextSize = 14
		text.Font = Tokens.Font
		text.Text = def.el
			.. " \194\183 Habitat "
			.. entry.level
			.. "\n"
			.. #(d.habitat[id] or {})
			.. " / "
			.. Rules.capacity(def, entry)
		text.Parent = label

		-- Theme-specific habitat decoration
		S.decorateHabitat(zone, pos, id, theme, entry.level)
	end
end

function S.decorateHabitat(zone, position, islandId, theme, level)
	-- Add theme-specific decorations based on habitat style
	if theme.habitatStyle == "Leaf" then
		-- Trees, grass, flowers
		for i = 1, level * 2 do
			local angle = math.random() * math.pi * 2
			local radius = math.random(4, 12)
			local pos = position + V(math.cos(angle) * radius, 0, math.sin(angle) * radius)
			local tree = part(zone, "ArvoreHabitat", V(2, 6, 2), pos + V(0, 3, 0), Color3.fromRGB(80, 60, 40), Enum.Material.Wood)
			part(zone, "Copa", V(6, 4, 5), pos + V(0, 7, 0), theme.groundColor:Lerp(Color3.fromRGB(100, 200, 100), 0.5), Enum.Material.Grass)
		end
	elseif theme.habitatStyle == "Ember" then
		-- Basalt, lava, fire crystals
		for i = 1, level * 2 do
			local angle = math.random() * math.pi * 2
			local radius = math.random(4, 12)
			local pos = position + V(math.cos(angle) * radius, 0, math.sin(angle) * radius)
			part(zone, "Basalto", V(3, 2, 3), pos + V(0, 1, 0), theme.groundColor, Enum.Material.Basalt, nil, "wedge")
			local crystal = part(zone, "CristalFogo", V(0.5, 2, 0.5), pos + V(0, 3, 0), theme.accentColor, Enum.Material.Neon, nil, "wedge")
			crystal:SetAttribute("ArtMotion", "spark")
			crystal:SetAttribute("ArtPhase", math.random() * 10)
		end
	elseif theme.habitatStyle == "Tidal" then
		-- Corals, shells, water
		for i = 1, level * 2 do
			local angle = math.random() * math.pi * 2
			local radius = math.random(4, 12)
			local pos = position + V(math.cos(angle) * radius, 0, math.sin(angle) * radius)
			part(zone, "Coral", V(1, 3, 1), pos + V(0, 1.5, 0), theme.accentColor, Enum.Material.Coral)
			part(zone, "Concha", V(2, 0.5, 1.5), pos + V(0, 0.3, 0), Color3.fromRGB(255, 220, 180), Enum.Material.Sandstone, nil, "wedge")
		end
		-- Water pool in center
		local pool = part(zone, "Piscina", V(10, 0.5, 10), position + V(0, 0.3, 0), theme.accentColor:Lerp(Color3.fromRGB(100, 200, 255), 0.7), Enum.Material.Glass, false)
		pool.Transparency = 0.3
		pool:SetAttribute("ArtMotion", "water")
		pool:SetAttribute("ArtPhase", 0)
	elseif theme.habitatStyle == "Sand" then
		-- Sand dunes, palm trees, ruins
		for i = 1, level * 2 do
			local angle = math.random() * math.pi * 2
			local radius = math.random(4, 12)
			local pos = position + V(math.cos(angle) * radius, 0, math.sin(angle) * radius)
			if math.random() < 0.5 then
				part(zone, "Palmeira", V(1, 8, 1), pos + V(0, 4, 0), Color3.fromRGB(100, 80, 40), Enum.Material.Wood)
				part(zone, "Folhas", V(5, 2, 5), pos + V(0, 9, 0), theme.groundColor:Lerp(Color3.fromRGB(100, 180, 80), 0.5), Enum.Material.Grass)
			else
				part(zone, "Duna", V(4, 1.5, 4), pos + V(0, 0.8, 0), theme.groundColor, Enum.Material.Sandstone)
			end
		end
	elseif theme.habitatStyle == "Sky" then
		-- Clouds, crystals, floating islands
		for i = 1, level * 2 do
			local angle = math.random() * math.pi * 2
			local radius = math.random(4, 12)
			local pos = position + V(math.cos(angle) * radius, math.random(2, 8), math.sin(angle) * radius)
			part(zone, "Nuvem", V(4, 1, 3), pos, Color3.fromRGB(240, 245, 255), Enum.Material.SmoothPlastic, false)
			local crystal = part(zone, "CristalCeu", V(1, 3, 1), pos + V(0, 2, 0), theme.accentColor, Enum.Material.Neon, false, "wedge")
			crystal:SetAttribute("ArtMotion", "cloud")
			crystal:SetAttribute("ArtPhase", math.random() * 10)
		end
	elseif theme.habitatStyle == "Veil" then
		-- Mist, twisted trees, mysterious lights
		for i = 1, level * 2 do
			local angle = math.random() * math.pi * 2
			local radius = math.random(4, 12)
			local pos = position + V(math.cos(angle) * radius, 0, math.sin(angle) * radius)
			local tree = part(zone, "ArvoreTorta", V(1.5, 7, 1.5), pos + V(0, 3.5, 0), Color3.fromRGB(50, 30, 60), Enum.Material.Wood)
			tree.CFrame *= CFrame.Angles(math.random(-0.3, 0.3), 0, math.random(-0.3, 0.3))
			local glow = part(zone, "LuzMisteriosa", V(0.5, 0.5, 0.5), pos + V(math.random(-2,2), 5, math.random(-2,2)), theme.accentColor, Enum.Material.Neon, false)
			glow:SetAttribute("ArtMotion", "spark")
			glow:SetAttribute("ArtPhase", math.random() * 10)
		end
	end

	Art.habitat(zone, position, islandId)
end

function S.home(player)
	local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
	if not root then
		return false
	end
	return Transport.go(player, S.ensure(player).center + V(0, 7, 55))
end

function S.release(player)
	local plot = plots[player]
	if not plot then
		return
	end
	plot.folder:Destroy()
	used[plot.index] = nil
	plots[player] = nil
end

-- Get sanctuary info for client
function S.getSanctuaryInfo(player)
	local d = Data.get(player)
	if not d then return nil end

	local plot = S.ensure(player)
	local theme = S.getTheme(plot.theme)

	local habitats = {}
	for id, entry in d.sanctuary do
		local def = I.ById[id]
		local hTheme = S.getTheme(id)
		habitats[id] = {
			name = def.name,
			element = def.el,
			slot = entry.slot,
			level = entry.level,
			capacity = Rules.capacity(def, entry),
			creatures = #(d.habitat[id] or {}),
			theme = hTheme,
			position = S.position(player, id),
		}
	end

	return {
		center = plot.center,
		theme = theme,
		habitats = habitats,
		owner = player.Name,
	}
end

-- Check if player can build habitat on island
function S.canBuildHabitat(player, islandId, slot)
	local d = Data.get(player)
	if not d then return false, "NO_DATA" end

	if not d.unlocked[islandId] then return false, "ISLAND_LOCKED" end
	if d.sanctuary[islandId] then return false, "ALREADY_BUILT" end
	if not Rules.available(d.sanctuary, slot) then return false, "SLOT_OCCUPIED" end

	local def = I.ById[islandId]
	local cost = Rules.buildCost(def)
	if d.gold < cost then return false, "INSUFFICIENT_GOLD" end

	return true, nil
end

-- Build habitat
function S.buildHabitat(player, islandId, slot)
	local can, reason = S.canBuildHabitat(player, islandId, slot)
	if not can then return { ok = false, reason = reason } end

	local d = Data.get(player)
	local def = I.ById[islandId]
	local cost = Rules.buildCost(def)

	d.gold -= cost
	d.sanctuary[islandId] = { slot = slot, level = 1 }
	d.stats.habitatBuild = (d.stats.habitatBuild or 0) + 1

	S.refresh(player)

	return { ok = true, cost = cost }
end

-- Upgrade habitat
function S.upgradeHabitat(player, islandId)
	local d = Data.get(player)
	if not d then return { ok = false, reason = "NO_DATA" } end

	local entry = d.sanctuary[islandId]
	if not entry then return { ok = false, reason = "NOT_BUILT" } end
	if entry.level >= Rules.MaxLevel then return { ok = false, reason = "MAX_LEVEL" } end

	local cost = Rules.upgradeCost(entry)
	if d.gold < cost then return { ok = false, reason = "INSUFFICIENT_GOLD" } end

	d.gold -= cost
	entry.level += 1
	d.stats.habitatUpgrade = (d.stats.habitatUpgrade or 0) + 1

	S.refresh(player)

	return { ok = true, cost = cost, newLevel = entry.level }
end

-- Move habitat
function S.moveHabitat(player, islandId, slot)
	local d = Data.get(player)
	if not d then return { ok = false, reason = "NO_DATA" } end

	local entry = d.sanctuary[islandId]
	if not entry then return { ok = false, reason = "NOT_BUILT" } end
	if not Rules.available(d.sanctuary, slot, islandId) then return { ok = false, reason = "SLOT_OCCUPIED" } end

	entry.slot = slot
	S.refresh(player)

	return { ok = true }
end

-- Remove habitat
function S.removeHabitat(player, islandId)
	local d = Data.get(player)
	if not d then return { ok = false, reason = "NO_DATA" } end

	if not d.sanctuary[islandId] then return { ok = false, reason = "NOT_BUILT" } end
	if #(d.habitat[islandId] or {}) > 0 then return { ok = false, reason = "HAS_CREATURES" } end

	d.sanctuary[islandId] = nil
	S.refresh(player)

	return { ok = true }
end

-- Place creature in habitat
function S.placeCreature(player, creatureUid, islandId)
	local d = Data.get(player)
	if not d then return { ok = false, reason = "NO_DATA" } end

	local cr = d.creatures[creatureUid]
	if not cr then return { ok = false, reason = "INVALID_CREATURE" } end

	local def = I.ById[islandId]
	if not def then return { ok = false, reason = "INVALID_ISLAND" } end

	if not d.sanctuary[islandId] then return { ok = false, reason = "HABITAT_NOT_BUILT" } end
	if not d.unlocked[islandId] then return { ok = false, reason = "ISLAND_LOCKED" } end

	local creatureDef = C.ById[cr.id]
	if creatureDef.el ~= def.el and not (creatureDef.hybrid and table.find(creatureDef.hybrid, def.el)) then
		return { ok = false, reason = "ELEMENT_MISMATCH" }
	end

	local list = d.habitat[islandId] or {}
	local structure = d.sanctuary[islandId]
	if #list - (table.find(list, creatureUid) and 1 or 0) >= Rules.capacity(def, structure) then
		return { ok = false, reason = "HABITAT_FULL" }
	end

	-- Remove from other habitats
	for _, l in d.habitat do
		local i = table.find(l, creatureUid)
		if i then table.remove(l, i) end
	end

	d.habitat[islandId] = d.habitat[islandId] or {}
	table.insert(d.habitat[islandId], creatureUid)

	S.refresh(player)
	require(script.Parent.World).refresh(player)

	return { ok = true }
end

return S