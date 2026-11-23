--!strict
-- setup_creature_assets.luau - Configura modelos de criaturas após importação no Roblox Studio
-- Execute no Command Bar: require(game.ServerScriptService.SetupCreatures).SetupAll()

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local CollectionService = game:GetService("CollectionService")
local TweenService = game:GetService("TweenService")

local SetupCreatures = {}

-- Mapeamento de SpeciesId para Asset IDs das texturas
-- SUBSTITUA ESTES IDs pelos seus asset IDs reais após upload no Asset Manager
local TextureAssets = {
	-- Fire
	CINZELO = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	MAGMARAU = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	FENIXFULIGEM = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	VULCANODRAGO = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},

	-- Water
	HIDROSONDA = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	VAPORAL = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	LEVIATHAN = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	ABYSSALIS = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},

	-- Nature
	VERDANTIS = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	DRYADUS = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	YGGDRASIL = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	GAIA_HEART = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},

	-- Earth
	GRAOZINHO = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	ESCORPIODRA = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	ESFINGEOLITO = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	COLOSSODUNE = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},

	-- Air
	PENUGEM = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	VENTANIL = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	TROVORAPTOR = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	AERONIMBO = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},

	-- Shadow
	LODINHO = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	CAUDALUME = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	VAGALUMORTE = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	REINEVOENTO = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},

	-- Hybrids
	PIROHIDRO = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	TERRAVENTO = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
	LUZSOMBRA = {
		BaseColor = "rbxassetid://0",
		Normal = "rbxassetid://0",
		ORM = "rbxassetid://0",
		Emissive = "rbxassetid://0",
	},
}

-- Tamanhos de hitbox por criatura (ajuste conforme modelo)
local HitboxSizes = {
	CINZELO = Vector3.new(3, 3, 3),
	MAGMARAU = Vector3.new(4, 4, 4),
	FENIXFULIGEM = Vector3.new(5, 5, 5),
	VULCANODRAGO = Vector3.new(7, 7, 7),
	HIDROSONDA = Vector3.new(3, 3, 3),
	VAPORAL = Vector3.new(4, 4, 4),
	LEVIATHAN = Vector3.new(6, 6, 6),
	ABYSSALIS = Vector3.new(7, 7, 7),
	VERDANTIS = Vector3.new(3, 3, 3),
	DRYADUS = Vector3.new(4, 4, 4),
	YGGDRASIL = Vector3.new(6, 6, 6),
	GAIA_HEART = Vector3.new(7, 7, 7),
	GRAOZINHO = Vector3.new(2, 2, 2),
	ESCORPIODRA = Vector3.new(4, 4, 4),
	ESFINGEOLITO = Vector3.new(5, 5, 5),
	COLOSSODUNE = Vector3.new(8, 8, 8),
	PENUGEM = Vector3.new(2, 2, 2),
	VENTANIL = Vector3.new(3, 3, 3),
	TROVORAPTOR = Vector3.new(5, 5, 5),
	AERONIMBO = Vector3.new(6, 6, 6),
	LODINHO = Vector3.new(3, 3, 3),
	CAUDALUME = Vector3.new(4, 4, 4),
	VAGALUMORTE = Vector3.new(5, 5, 5),
	REINEVOENTO = Vector3.new(7, 7, 7),
	PIROHIDRO = Vector3.new(6, 6, 6),
	TERRAVENTO = Vector3.new(6, 6, 6),
	LUZSOMBRA = Vector3.new(6, 6, 6),
}

-- Configurar SurfaceAppearance PBR em um MeshPart
local function configureSurfaceAppearance(meshPart: MeshPart, textures: {BaseColor: string, Normal: string, ORM: string, Emissive: string})
	-- Remover SurfaceAppearances antigas
	for _, child in ipairs(meshPart:GetChildren()) do
		if child:IsA("SurfaceAppearance") then
			child:Destroy()
		end
	end

	-- Criar nova SurfaceAppearance
	local surfaceApp = Instance.new("SurfaceAppearance")
	surfaceApp.Name = "PBRMaterial"
	surfaceApp.ColorMap = textures.BaseColor
	surfaceApp.NormalMap = textures.Normal
	surfaceApp.MetalnessMap = textures.ORM  -- Canal B = Metallic
	surfaceApp.RoughnessMap = textures.ORM  -- Canal G = Roughness
	-- Nota: Occlusion (canal R) não tem propriedade direta no SurfaceAppearance
	-- O Roblox usa RoughnessMap para AO indireto
	surfaceApp.Parent = meshPart

	-- Configurar MeshPart para PBR
	meshPart.RenderFidelity = Enum.RenderFidelity.Precise
	meshPart.CollisionFidelity = Enum.CollisionFidelity.Box
	meshPart.CastShadow = true
	meshPart.ReceiveShadow = true

	return surfaceApp
end

-- Configurar modelo individual
local function setupCreatureModel(model: Model, speciesId: string)
	print(`[Setup] Configurando {speciesId}...`)

	local textures = TextureAssets[speciesId]
	if not textures then
		warn(`[Setup] Texturas não encontradas para {speciesId}`)
		return false
	end

	-- 1. Garantir PrimaryPart
	if not model.PrimaryPart then
		local rootPart = model:FindFirstChild("Root")
			or model:FindFirstChild("Body")
			or model:FindFirstChildWhichIsA("BasePart")
		if rootPart then
			model.PrimaryPart = rootPart
			print(`  PrimaryPart: {rootPart.Name}`)
		else
			warn(`  Nenhuma BasePart encontrada para PrimaryPart`)
			return false
		end
	end

	-- 2. Configurar SurfaceAppearances em todas as MeshParts
	local meshParts = {}
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("MeshPart") then
			table.insert(meshParts, descendant)
		end
	end

	for _, meshPart in ipairs(meshParts) do
		configureSurfaceAppearance(meshPart, textures)
	end
	print(`  SurfaceAppearances: {#meshParts} MeshParts configuradas`)

	-- 3. AnimationController + Animator
	if not model:FindFirstChild("AnimationController") then
		local animController = Instance.new("AnimationController")
		animController.Parent = model
		print(`  AnimationController adicionado`)
	end

	if not model:FindFirstChild("Animator") then
		local animator = Instance.new("Animator")
		animator.Parent = model
		print(`  Animator adicionado`)
	end

	-- 4. Battle Hitbox
	local existingHitbox = model:FindFirstChild("BattleHitbox")
	if existingHitbox then
		existingHitbox:Destroy()
	end

	local hitbox = Instance.new("Part")
	hitbox.Name = "BattleHitbox"
	hitbox.Size = HitboxSizes[speciesId] or Vector3.new(4, 4, 4)
	hitbox.Transparency = 1
	hitbox.CanCollide = false
	hitbox.CanTouch = true
	hitbox.CanQuery = false
	hitbox.Anchored = true
	hitbox.Massless = true
	hitbox.Parent = model

	if model.PrimaryPart then
		hitbox.CFrame = model.PrimaryPart.CFrame
	end

	CollectionService:AddTag(hitbox, "BattleHitbox")
	print(`  BattleHitbox criado: {hitbox.Size}`)

	-- 5. Attachments para efeitos
	local attachments = {
		Root = Vector3.new(0, 0, 0),
		Head = Vector3.new(0, 2, 0),
		Body = Vector3.new(0, 0, 0),
		Front = Vector3.new(0, 1, 2),
		Back = Vector3.new(0, 1, -2),
		Left = Vector3.new(-2, 1, 0),
		Right = Vector3.new(2, 1, 0),
		Top = Vector3.new(0, 3, 0),
		Bottom = Vector3.new(0, -1, 0),
	}

	local primaryPart = model.PrimaryPart
	for name, pos in pairs(attachments) do
		local existing = primaryPart:FindFirstChild(name .. "Attachment")
		if existing then existing:Destroy() end

		local attachment = Instance.new("Attachment")
		attachment.Name = name .. "Attachment"
		attachment.Position = pos
		attachment.Parent = primaryPart
	end
	print(`  Attachments: 9 criados`)

	-- 6. Configurar MorphTargets (Shape Keys de evolução)
	if primaryPart:IsA("MeshPart") then
		local morphTargets = primaryPart:GetMorphTargets()
		print(`  MorphTargets encontrados: {#morphTargets}`)
		for _, mt in ipairs(morphTargets) do
			print(`    - {mt.Name}`)
		end
	end

	-- 7. Performance settings
	for _, meshPart in ipairs(meshParts) do
		meshPart.RenderFidelity = Enum.RenderFidelity.Precise
		meshPart.CollisionFidelity = Enum.CollisionFidelity.Box
	end

	-- 8. Tag para identificação
	CollectionService:AddTag(model, "CreatureModel")
	CollectionService:AddTag(model, "Species_" .. speciesId)

	model:SetAttribute("SpeciesId", speciesId)
	model:SetAttribute("ElementType", getElementType(speciesId))

	print(`[Setup] {speciesId} configurado com sucesso!`)
	return true
end

-- Obter tipo elementar da criatura
local function getElementType(speciesId: string): string
	local elements = {
		-- Fire
		CINZELO = "Fire", MAGMARAU = "Fire", FENIXFULIGEM = "Fire", VULCANODRAGO = "Fire",
		-- Water
		HIDROSONDA = "Water", VAPORAL = "Water", LEVIATHAN = "Water", ABYSSALIS = "Water",
		-- Nature
		VERDANTIS = "Nature", DRYADUS = "Nature", YGGDRASIL = "Nature", GAIA_HEART = "Nature",
		-- Earth
		GRAOZINHO = "Earth", ESCORPIODRA = "Earth", ESFINGEOLITO = "Earth", COLOSSODUNE = "Earth",
		-- Air
		PENUGEM = "Air", VENTANIL = "Air", TROVORAPTOR = "Air", AERONIMBO = "Air",
		-- Shadow
		LODINHO = "Shadow", CAUDALUME = "Shadow", VAGALUMORTE = "Shadow", REINEVOENTO = "Shadow",
		-- Hybrids
		PIROHIDRO = "FireWater", TERRAVENTO = "EarthAir", LUZSOMBRA = "NatureShadow",
	}
	return elements[speciesId] or "Unknown"
end

-- Configurar todos os modelos
function SetupCreatures.SetupAll()
	print("=== CONFIGURAÇÃO DE CRIATURAS ===")
	print("")

	local creaturesFolder = ReplicatedStorage:FindFirstChild("Assets")
		and ReplicatedStorage.Assets:FindFirstChild("Creatures")

	if not creaturesFolder then
		warn("[Setup] Pasta ReplicatedStorage.Assets.Creatures não encontrada!")
		return
	end

	local creaturesList = {
		"CINZELO", "MAGMARAU", "FENIXFULIGEM", "VULCANODRAGO",
		"HIDROSONDA", "VAPORAL", "LEVIATHAN", "ABYSSALIS",
		"VERDANTIS", "DRYADUS", "YGGDRASIL", "GAIA_HEART",
		"GRAOZINHO", "ESCORPIODRA", "ESFINGEOLITO", "COLOSSODUNE",
		"PENUGEM", "VENTANIL", "TROVORAPTOR", "AERONIMBO",
		"LODINHO", "CAUDALUME", "VAGALUMORTE", "REINEVOENTO",
		"PIROHIDRO", "TERRAVENTO", "LUZSOMBRA",
	}

	local successCount = 0
	local failCount = 0

	for _, speciesId in ipairs(creaturesList) do
		local model = creaturesFolder:FindFirstChild(speciesId)
		if model then
			local success = setupCreatureModel(model, speciesId)
			if success then
				successCount += 1
			else
				failCount += 1
			end
		else
			warn(`[Setup] Modelo não encontrado: {speciesId} - importe primeiro!`)
			failCount += 1
		end
	end

	print("")
	print(`=== RESULTADO: {successCount} sucessos, {failCount} falhas ===`)

	if failCount > 0 then
		print("")
		print("Próximos passos para modelos faltando:")
		print("1. Importe via Asset Manager (View > Asset Manager > Import 3D)")
		print("2. Arraste para ReplicatedStorage.Assets.Creatures")
		print("3. Renomeie para o SpeciesId exato")
		print("4. Execute este script novamente")
	end

	return successCount, failCount
end

-- Verificar configuração de um modelo
function SetupCreatures.VerifyModel(speciesId: string)
	local model = ReplicatedStorage:FindFirstChild("Assets")
		and ReplicatedStorage.Assets:FindFirstChild("Creatures")
		and ReplicatedStorage.Assets.Creatures:FindFirstChild(speciesId)

	if not model then
		print(`[Verify] {speciesId}: NÃO ENCONTRADO`)
		return false
	end

	print(`[Verify] {speciesId}:`)
	print(`  PrimaryPart: {model.PrimaryPart and model.PrimaryPart.Name or "NENHUM"}`)

	local meshParts = 0
	local surfaceApps = 0
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("MeshPart") then
			meshParts += 1
			for _, child in ipairs(descendant:GetChildren()) do
				if child:IsA("SurfaceAppearance") then
					surfaceApps += 1
				end
			end
		end
	end
	print(`  MeshParts: {meshParts}`)
	print(`  SurfaceAppearances: {surfaceApps}`)
	print(`  AnimationController: {model:FindFirstChild("AnimationController") and "SIM" or "NÃO"}`)
	print(`  Animator: {model:FindFirstChild("Animator") and "SIM" or "NÃO"}`)
	print(`  BattleHitbox: {model:FindFirstChild("BattleHitbox") and "SIM" or "NÃO"}`)

	local attachments = 0
	if model.PrimaryPart then
		for _, child in ipairs(model.PrimaryPart:GetChildren()) do
			if child:IsA("Attachment") then
				attachments += 1
			end
		end
	end
	print(`  Attachments: {attachments}/9`)

	if model.PrimaryPart and model.PrimaryPart:IsA("MeshPart") then
		local morphs = model.PrimaryPart:GetMorphTargets()
		print(`  MorphTargets: {#morphs}`)
		for _, m in ipairs(morphs) do
			print(`    - {m.Name}`)
		end
	end

	return true
end

-- Verificar todos
function SetupCreatures.VerifyAll()
	local creaturesFolder = ReplicatedStorage:FindFirstChild("Assets")
		and ReplicatedStorage.Assets:FindFirstChild("Creatures")

	if not creaturesFolder then return end

	for _, child in ipairs(creaturesFolder:GetChildren()) do
		if child:IsA("Model") then
			SetupCreatures.VerifyModel(child.Name)
			print("")
		end
	end
end

-- Criar pasta de assets se não existir
function SetupCreatures.EnsureFolders()
	local assets = ReplicatedStorage:FindFirstChild("Assets")
	if not assets then
		assets = Instance.new("Folder")
		assets.Name = "Assets"
		assets.Parent = ReplicatedStorage
	end

	local creatures = assets:FindFirstChild("Creatures")
	if not creatures then
		creatures = Instance.new("Folder")
		creatures.Name = "Creatures"
		creatures.Parent = assets
	end

	local shiny = assets:FindFirstChild("ShinyCreatures")
	if not shiny then
		shiny = Instance.new("Folder")
		shiny.Name = "ShinyCreatures"
		shiny.Parent = assets
	end

	print("[Setup] Pastas garantidas: Assets > Creatures, ShinyCreatures")
end

-- Exportar para uso global no Command Bar
_G.SetupCreatures = SetupCreatures

print("")
print("=== SETUP CRIATURAS CARREGADO ===")
print("Funções disponíveis:")
print("  _G.SetupCreatures.SetupAll()        -- Configura todos os modelos")
print("  _G.SetupCreatures.VerifyAll()       -- Verifica todos os modelos")
print("  _G.SetupCreatures.VerifyModel(id)   -- Verifica modelo específico")
print("  _G.SetupCreatures.EnsureFolders()   -- Cria pastas necessárias")
print("")
print("IMPORTANTE: Substitua os TextureAssets no topo do script com seus Asset IDs reais!")

return SetupCreatures