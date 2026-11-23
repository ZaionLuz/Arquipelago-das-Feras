--[[
	Import Islands to Roblox Studio
	================================

	Este script deve ser executado DENTRO do Roblox Studio (Command Bar ou Plugin)
	após os arquivos FBX das ilhas estarem em assets/islands/

	PASSOS:
	1. Copie a pasta assets/islands/ para o projeto Roblox
	2. No Studio, use Asset Manager (View > Asset Manager) para importar os FBX
	3. Ou use este script via Command Bar após colocar os FBX em ReplicatedStorage
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetService = game:GetService("AssetService")

-- Configuração das ilhas
local ISLAND_CONFIG = {
	StarterTown = {
		Name = "Vila Inicial",
		Position = Vector3.new(0, 0, 0),
		Scale = Vector3.new(1, 1, 1),
		Biome = "Nature",
		IsStarter = true,
	},
	FireForest = {
		Name = "Floresta de Brasas",
		Position = Vector3.new(300, 0, 0),
		Scale = Vector3.new(1, 1, 1),
		Biome = "Fire",
	},
	WaterCaves = {
		Name = "Cavernas Aquáticas",
		Position = Vector3.new(0, -20, 300),
		Scale = Vector3.new(1, 1, 1),
		Biome = "Water",
	},
	NaturePlains = {
		Name = "Planícies Verdentes",
		Position = Vector3.new(-300, 0, 0),
		Scale = Vector3.new(1, 1, 1),
		Biome = "Nature",
	},
	EarthDesert = {
		Name = "Deserto de Dunas",
		Position = Vector3.new(0, 0, -300),
		Scale = Vector3.new(1, 1, 1),
		Biome = "Earth",
	},
	AirPeaks = {
		Name = "Picos Ventosos",
		Position = Vector3.new(200, 150, 200),
		Scale = Vector3.new(1, 1, 1),
		Biome = "Air",
	},
	ShadowRuins = {
		Name = "Ruínas Sombrias",
		Position = Vector3.new(-200, -20, -200),
		Scale = Vector3.new(1, 1, 1),
		Biome = "Shadow",
	},
	VolcanoIsle = {
		Name = "Ilha Vulcânica",
		Position = Vector3.new(350, 0, 350),
		Scale = Vector3.new(1, 1, 1),
		Biome = "Fire",
	},
}

-- Função principal para configurar as ilhas no Workspace
local function SetupIslandsInWorkspace()
	local Workspace = game:GetService("Workspace")

	-- Criar pasta Islands no Workspace
	local islandsFolder = Instance.new("Folder")
	islandsFolder.Name = "Islands"
	islandsFolder.Parent = Workspace

	-- Para cada ilha, criar referência (modelos reais virão de ReplicatedStorage.Assets.Islands)
	for islandId, config in pairs(ISLAND_CONFIG) do
		local islandRef = Instance.new("Model")
		islandRef.Name = islandId
		islandRef.Parent = islandsFolder

		-- Adicionar atributos para identificação
		islandRef:SetAttribute("IslandId", islandId)
		islandRef:SetAttribute("DisplayName", config.Name)
		islandRef:SetAttribute("Biome", config.Biome)
		islandRef:SetAttribute("IsStarter", config.IsStarter or false)

		-- Part principal para posicionamento
		local primaryPart = Instance.new("Part")
		primaryPart.Name = "IslandCenter"
		primaryPart.Size = Vector3.new(1, 1, 1)
		primaryPart.Transparency = 1
		primaryPart.Anchored = true
		primaryPart.CanCollide = false
		primaryPart.CFrame = CFrame.new(config.Position)
		primaryPart.Parent = islandRef

		islandRef.PrimaryPart = primaryPart

		-- Adicionar spawn points para criaturas
		local spawnsFolder = Instance.new("Folder")
		spawnsFolder.Name = "CreatureSpawns"
		spawnsFolder.Parent = islandRef

		-- Gerar pontos de spawn ao redor da ilha
		for i = 1, 15 do
			local angle = (i / 15) * math.pi * 2
			local distance = math.random(20, 60)
			local spawnPos = config.Position + Vector3.new(math.cos(angle), 0, math.sin(angle)) * distance
			spawnPos = spawnPos + Vector3.new(0, math.random(0, 10), 0)

			local spawnPoint = Instance.new("Part")
			spawnPoint.Name = "Spawn_" .. i
			spawnPoint.Size = Vector3.new(4, 1, 4)
			spawnPoint.Transparency = 0.8
			spawnPoint.Anchored = true
			spawnPoint.CanCollide = false
			spawnPoint.Material = Enum.Material.Neon
			spawnPoint.BrickColor = BrickColor.new("Bright green")
			spawnPoint.CFrame = CFrame.new(spawnPos)
			spawnPoint.Parent = spawnsFolder

			spawnPoint:SetAttribute("Biome", config.Biome)
			spawnPoint:SetAttribute("LevelMin", 1)
			spawnPoint:SetAttribute("LevelMax", 5)
		end

		-- Adicionar NPCs points
		local npcFolder = Instance.new("Folder")
		npcFolder.Name = "NPCSpawns"
		npcFolder.Parent = islandRef

		-- Healer
		local healerPos = config.Position + Vector3.new(20, 5, 0)
		local healerPart = Instance.new("Part")
		healerPart.Name = "Healer"
		healerPart.Size = Vector3.new(4, 6, 4)
		healerPart.Transparency = 0.5
		healerPart.Anchored = true
		healerPart.CanCollide = false
		healerPart.CFrame = CFrame.new(healerPos)
		healerPart.Parent = npcFolder
		healerPart:SetAttribute("NPCType", "Healer")

		-- Shop
		local shopPos = config.Position + Vector3.new(-20, 5, 0)
		local shopPart = Instance.new("Part")
		shopPart.Name = "Shopkeeper"
		shopPart.Size = Vector3.new(4, 6, 4)
		shopPart.Transparency = 0.5
		shopPart.Anchored = true
		shopPart.CanCollide = false
		shopPart.CFrame = CFrame.new(shopPos)
		shopPart.Parent = npcFolder
		shopPart:SetAttribute("NPCType", "Shopkeeper")

		-- Quest Giver
		local questPos = config.Position + Vector3.new(0, 5, 30)
		local questPart = Instance.new("Part")
		questPart.Name = "QuestGiver"
		questPart.Size = Vector3.new(4, 6, 4)
		questPart.Transparency = 0.5
		questPart.Anchored = true
		questPart.CanCollide = false
		questPart.CFrame = CFrame.new(questPos)
		questPart.Parent = npcFolder
		questPart:SetAttribute("NPCType", "QuestGiver")

		print(`Configurada ilha: {islandId} - {config.Name}`)
	end

	-- Criar pontes entre ilhas
	local bridgesFolder = Instance.new("Folder")
	bridgesFolder.Name = "Bridges"
	bridgesFolder.Parent = islandsFolder

	local connections = {
		{"StarterTown", "FireForest"},
		{"StarterTown", "WaterCaves"},
		{"StarterTown", "NaturePlains"},
		{"StarterTown", "EarthDesert"},
		{"FireForest", "VolcanoIsle"},
		{"WaterCaves", "AirPeaks"},
		{"NaturePlains", "AirPeaks"},
		{"EarthDesert", "ShadowRuins"},
	}

	for i, conn in ipairs(connections) do
		local fromConfig = ISLAND_CONFIG[conn[1]]
		local toConfig = ISLAND_CONFIG[conn[2]]

		if fromConfig and toConfig then
			local mid = (fromConfig.Position + toConfig.Position) / 2
			local dist = (fromConfig.Position - toConfig.Position).Magnitude

			local bridge = Instance.new("Part")
			bridge.Name = `Bridge_{conn[1]}_to_{conn[2]}`
			bridge.Size = Vector3.new(dist, 10, 8)
			bridge.Anchored = true
			bridge.CanCollide = true
			bridge.Material = Enum.Material.Wood
			bridge.Color = Color3.fromRGB(139, 115, 85)
			bridge.CFrame = CFrame.new(mid) * CFrame.Angles(0, math.atan2(toConfig.Position.Z - fromConfig.Position.Z, toConfig.Position.X - fromConfig.Position.X), 0)
			bridge.Position = Vector3.new(mid.X, math.min(fromConfig.Position.Y, toConfig.Position.Y) + 5, mid.Z)
			bridge.Parent = bridgesFolder

			bridge:SetAttribute("FromIsland", conn[1])
			bridge:SetAttribute("ToIsland", conn[2])
		end
	end

	print("=== TODAS AS ILHAS CONFIGURADAS NO WORKSPACE ===")
end

-- Função para importar modelos FBX via AssetManager (precisa ser feito manualmente no Studio)
local function PrintImportInstructions()
	print([[
========================================
INSTRUÇÕES PARA IMPORTAR ILHAS NO STUDIO
========================================

MÉTODO 1: Asset Manager (Recomendado)
1. Abra View > Asset Manager
2. Clique em "Import" > "Import 3D"
3. Selecione todos os .fbx da pasta assets/islands/
4. Aguarde importação
5. Os modelos aparecerão em ReplicatedStorage > Assets > Islands

MÉTODO 2: Game Explorer
1. Botão direito em ReplicatedStorage > Insert > Folder > Nome: "Assets"
2. Botão direito em Assets > Insert > Folder > Nome: "Islands"
3. Arraste os .fbx para a pasta Islands no Game Explorer

MÉTODO 3: Via Script (após importar FBX)
- Execute SetupIslandsInWorkspace() no Command Bar
- Isso criará a estrutura de ilhas, spawns, NPCs e pontes

ESTRUTURA ESPERADA APÓS IMPORTAÇÃO:
ReplicatedStorage/
  Assets/
    Islands/
      Island_StarterTown/ (Model)
      Island_FireForest/ (Model)
      Island_WaterCaves/ (Model)
      Island_NaturePlains/ (Model)
      Island_EarthDesert/ (Model)
      Island_AirPeaks/ (Model)
      Island_ShadowRuins/ (Model)
      Island_VolcanoIsle/ (Model)

Workspace/
  Islands/
    StarterTown/ (Model com IslandCenter, CreatureSpawns, NPCSpawns)
    FireForest/
    WaterCaves/
    NaturePlains/
    EarthDesert/
    AirPeaks/
    ShadowRuins/
    VolcanoIsle/
    Bridges/
      Bridge_StarterTown_to_FireForest/
      ...

CONFIGURAÇÃO DOS MODELOS IMPORTADOS:
Para cada modelo de ilha importado:
1. Selecione o Model raiz
2. Defina PrimaryPart como a parte central (IslandCenter ou similar)
3. Certifique-se de que todas as partes estão Anchored = true
4. Para partes de colisão (chão, rochas): CanCollide = true
5. Para partes decorativas: CanCollide = false
6. Aplique Materials apropriados (Grass, Rock, Sand, etc.)
7. Configure texturas/PBR se tiverem sido exportadas

BIOME COLORS PARA REFERÊNCIA:
- Nature: Verde floresta (Grass, Forest)
- Fire: Vermelho/laranja/preto (Basalt, Slate, Neon laranja)
- Water: Azul/teal (Sand, SmoothPlastic azul)
- Earth: Marrom/bege (Sandstone, Slate, Basalt)
- Air: Branco/azul claro (SmoothPlastic, Neon azul, ForceField)
- Shadow: Roxo escuro/preto (Slate, Basalt, Neon roxo)

=== EXECUTE SetupIslandsInWorkspace() AGORA ===
]])
end

-- Executar instruções
PrintImportInstructions()

-- Descomente a linha abaixo para executar a configuração automática
-- SetupIslandsInWorkspace()

return {
	SetupIslandsInWorkspace = SetupIslandsInWorkspace,
	ISLAND_CONFIG = ISLAND_CONFIG,
}