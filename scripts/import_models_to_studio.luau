--!strict
-- import_models_to_studio.luau - Importa modelos FBX/GLB para o Roblox Studio
-- Execute este script no Command Bar do Roblox Studio após abrir o projeto com Rojo

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetService = game:GetService("AssetService")
local InsertService = game:GetService("InsertService")
local RunService = game:GetService("RunService")

-- Configuração dos modelos
local modelsPath = "assets/models/" -- Caminho relativo ao projeto
local creaturesList = {
	-- Fire
	"CINZELO", "MAGMARAU", "FENIXFULIGEM", "VULCANODRAGO",
	-- Water
	"HIDROSONDA", "VAPORAL", "LEVIATHAN", "ABYSSALIS",
	-- Nature
	"VERDANTIS", "DRYADUS", "YGGDRASIL", "GAIA_HEART",
	-- Earth
	"GRAOZINHO", "ESCORPIODRA", "ESFINGEOLITO", "COLOSSODUNE",
	-- Air
	"PENUGEM", "VENTANIL", "TROVORAPTOR", "AERONIMBO",
	-- Shadow
	"LODINHO", "CAUDALUME", "VAGALUMORTE", "REINEVOENTO",
	-- Hybrids
	"PIROHIDRO", "TERRAVENTO", "LUZSOMBRA",
}

-- Criar pasta de assets se não existir
local assetsFolder = ReplicatedStorage:FindFirstChild("Assets")
if not assetsFolder then
	assetsFolder = Instance.new("Folder")
	assetsFolder.Name = "Assets"
	assetsFolder.Parent = ReplicatedStorage
end

local creaturesFolder = assetsFolder:FindFirstChild("Creatures")
if not creaturesFolder then
	creaturesFolder = Instance.new("Folder")
	creaturesFolder.Name = "Creatures"
	creaturesFolder.Parent = assetsFolder
end

-- Função para importar modelo via Game:GetObjects (requer asset ID publicado)
local function importFromFile(fileName: string, speciesId: string)
	-- No Roblox Studio, você pode usar:
	-- 1. Game:GetObjects("rbxasset://...") para arquivos locais (não funciona bem)
	-- 2. InsertService:LoadAsset(assetId) para assets publicados
	-- 3. Arrastar e soltar no Studio (manual)
	-- 4. Plugin "Rojo" para sincronizar arquivos

	print(`[Import] Para importar {speciesId}:`)
	print(`  1. No Roblox Studio: View > Asset Manager`)
	print(`  2. Clique em "Import" > "Import FBX/GLB"`)
	print(`  3. Selecione: {fileName}`)
	print(`  4. Configure: Scale 1.0, Import Animations, Import Materials`)
	print(`  5. Arraste o modelo importado para ReplicatedStorage.Assets.Creatures`)
	print(`  6. Renomeie para: {speciesId}`)
	print(`  7. Defina PrimaryPart (geralmente "Root" ou "Body")`)
	print(`  8. Adicione AnimationController + Animator se tiver animações`)
	print("")
end

-- Instruções para importação manual
print("=== IMPORTAÇÃO DE MODELOS PARA ROBLOX STUDIO ===")
print("")
print("MÉTODO RECOMENDADO (via Asset Manager):")
print("1. Abra o Roblox Studio com o projeto (rojo serve)")
print("2. View > Asset Manager (ou Ctrl+Shift+A)")
print("3. Botão 'Import' > 'Import 3D'")
print("4. Selecione os arquivos .glb ou .fbx da pasta assets/models/")
print("5. Para cada modelo:")
print("   - Scale: 1.0 (já estão na escala correta ~5-10k tris)")
print("   - Import Materials: ON (cria SurfaceAppearances)")
print("   - Import Animations: ON (se houver shape keys)")
print("   - Generate Collision: OFF (usaremos hitbox separada)")
print("6. Após importar, arraste para ReplicatedStorage > Assets > Creatures")
print("7. Renomeie para o SpeciesId (ex: CINZELO, MAGMARAU, etc.)")
print("8. Certifique-se de ter PrimaryPart definido")
print("")

-- Listar arquivos disponíveis
print("Arquivos disponíveis em assets/models/:")
for _, speciesId in ipairs(creaturesList) do
	local fbxFile = speciesId .. "_Roblox.fbx"
	local glbFile = speciesId .. "_Roblox.glb"
	print(`  {speciesId}: {fbxFile} + {glbFile}`)
end

print("")
print("=== NOTAS IMPORTANTES ===")
print("- Modelos já têm UVs unwrapped (Smart UV Project)")
print("- Materiais PBR: BaseColor, Normal, ORM, Emissive (2048x2048 atlas)")
print("- Rigging: R15-compatible (20-50 bones), já skinned")
print("- Shape Keys: 3 estágios (Filhote 50%, Juvenil 75%, Adulto 100%)")
print("- ORM = R:Occlusion, G:Roughness, B:Metallic")
print("")
print("APÓS IMPORTAR, execute o script 'setup_creature_assets.luau' para configurar:")
print("- SurfaceAppearances com mapas PBR")
print("- AnimationControllers para shape keys")
print("- Hitboxes e attachments para batalha")

-- Função auxiliar para ser chamada após importação manual
function SetupImportedModels()
	print("[Setup] Configurando modelos importados...")

	for _, speciesId in ipairs(creaturesList) do
		local model = creaturesFolder:FindFirstChild(speciesId)
		if model then
			print(`[Setup] Configurando {speciesId}...`)
			ConfigureCreatureModel(model, speciesId)
		else
			warn(`[Setup] Modelo não encontrado: {speciesId} - importe primeiro!`)
		end
	end

	print("[Setup] Concluído!")
end

function ConfigureCreatureModel(model: Model, speciesId: string)
	-- 1. Garantir PrimaryPart
	if not model.PrimaryPart then
		local rootPart = model:FindFirstChild("Root") or model:FindFirstChild("Body") or model:FindFirstChildWhichIsA("BasePart")
		if rootPart then
			model.PrimaryPart = rootPart
			print(`  PrimaryPart definido: {rootPart.Name}`)
		end
	end

	-- 2. Configurar SurfaceAppearances (materiais PBR)
	ConfigureSurfaceAppearances(model, speciesId)

	-- 3. Adicionar AnimationController se não tiver
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

	-- 4. Configurar hitbox para batalha
	SetupBattleHitbox(model)

	-- 5. Adicionar attachments para efeitos
	SetupAttachments(model, speciesId)

	-- 6. Configurar LODs se necessário
	SetupLODs(model)
end

function ConfigureSurfaceAppearances(model: Model, speciesId: string)
	-- Os materiais já devem vir com SurfaceAppearances do import FBX/GLB
	-- Mas podemos ajustar propriedades se necessário

	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("SurfaceAppearance") then
			-- Ajustar propriedades PBR
			descendant.Roughness = 0.5 -- Será sobrescrito pelo mapa ORM
			descendant.Metalness = 0.0
			print(`  SurfaceAppearance: {descendant.Name}`)
		elseif descendant:IsA("MeshPart") then
			-- Garantir que MeshParts usem SurfaceAppearance
			descendant.RenderFidelity = Enum.RenderFidelity.Precise
		end
	end
end

function SetupBattleHitbox(model: Model)
	-- Criar hitbox simplificada para colisão de batalha
	local hitbox = Instance.new("Part")
	hitbox.Name = "BattleHitbox"
	hitbox.Size = Vector3.new(4, 4, 4)
	hitbox.Transparency = 1
	hitbox.CanCollide = false
	hitbox.CanTouch = true
	hitbox.CanQuery = false
	hitbox.Anchored = true
	hitbox.Massless = true
	hitbox.Parent = model

	-- Posicionar no centro do modelo
	if model.PrimaryPart then
		hitbox.CFrame = model.PrimaryPart.CFrame
	end

	-- CollectionService tag para batalha
	local CollectionService = game:GetService("CollectionService")
	CollectionService:AddTag(hitbox, "BattleHitbox")
end

function SetupAttachments(model: Model, speciesId: string)
	-- Attachments para efeitos visuais em batalha
	local attachments = {
		Root = {Position = Vector3.new(0, 0, 0), Name = "RootAttachment"},
		Head = {Position = Vector3.new(0, 2, 0), Name = "HeadAttachment"},
		Body = {Position = Vector3.new(0, 0, 0), Name = "BodyAttachment"},
		Front = {Position = Vector3.new(0, 1, 2), Name = "FrontAttachment"},
		Back = {Position = Vector3.new(0, 1, -2), Name = "BackAttachment"},
		Left = {Position = Vector3.new(-2, 1, 0), Name = "LeftAttachment"},
		Right = {Position = Vector3.new(2, 1, 0), Name = "RightAttachment"},
		Top = {Position = Vector3.new(0, 3, 0), Name = "TopAttachment"},
		Bottom = {Position = Vector3.new(0, -1, 0), Name = "BottomAttachment"},
	}

	for _, attachData in pairs(attachments) do
		local attachment = Instance.new("Attachment")
		attachment.Name = attachData.Name
		attachment.Position = attachData.Position
		attachment.Parent = model.PrimaryPart or model:FindFirstChildWhichIsA("BasePart")
	end
end

function SetupLODs(model: Model)
	-- Configurar Level of Detail para performance
	for _, descendant in ipairs(model:GetDescendants()) do
		if descendant:IsA("MeshPart") then
			descendant.RenderFidelity = Enum.RenderFidelity.Precise
			descendant.CollisionFidelity = Enum.CollisionFidelity.Box
		end
	end
end

-- Exportar funções globais para uso no Command Bar
_G.SetupImportedModels = SetupImportedModels
_G.ConfigureCreatureModel = ConfigureCreatureModel

print("")
print("=== FUNÇÕES DISPONÍVEIS NO COMMAND BAR ===")
print("_G.SetupImportedModels()  -- Configura todos os modelos importados")
print("_G.ConfigureCreatureModel(model, speciesId)  -- Configura um modelo específico")
print("")
print("Execute _G.SetupImportedModels() APÓS importar todos os modelos manualmente!")