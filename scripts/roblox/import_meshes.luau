--!strict
--[[
	Blender → Roblox Pipeline: Import FBX as MeshParts and create Motor6D rigs

	Usage in Roblox Studio:
	1. Place this script in ServerScriptService
	2. Ensure FBX files are uploaded as MeshParts (or use AssetManager)
	3. Run: require(script).ImportAll()

	Requirements:
	- FBX files exported from Blender with naming: {species}_{stage}_{part}
	- Rig template with bones: Root, J_Body, J_Head, J_Neck, J_Leg1-4, J_WingL/R, J_Tail1-4
	- Materials: SmoothPlastic (base), Neon (elemental accents), Glass (crystals)
	- LODs: _LOD0 (full), _LOD1 (50%), _LOD2 (25%)
	- Scale: 1 Blender unit = 1 stud
]]

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local AssetService = game:GetService("AssetService")
local RunService = game:GetService("RunService")

local BlenderModels = require(ReplicatedStorage.Shared.BlenderModels)

local IMPORT_ROOT = "rbxassetid://" -- Base asset ID for uploaded FBX meshes
local MESH_PART_FOLDER = "ImportedMeshes"
local RIG_FOLDER = "ImportedRigs"

-- Material mapping from Blender export names to Roblox Enum.Material
local MATERIAL_MAP = {
	SmoothPlastic = Enum.Material.SmoothPlastic,
	Neon = Enum.Material.Neon,
	Glass = Enum.Material.Glass,
	Slate = Enum.Material.Slate,
	Fabric = Enum.Material.Fabric,
	Plastic = Enum.Material.Plastic,
	Metal = Enum.Material.Metal,
	Wood = Enum.Material.Wood,
}

-- Motor6D joint naming convention (must match Blender rig)
local JOINT_NAMES = {
	Root = "Root",
	Body = "J_Body",
	Head = "J_Head",
	Neck = "J_Neck",
	Leg1 = "J_Leg1",
	Leg2 = "J_Leg2",
	Leg3 = "J_Leg3",
	Leg4 = "J_Leg4",
	WingL = "J_WingL",
	WingR = "J_WingR",
	Tail1 = "J_Tail1",
	Tail2 = "J_Tail2",
	Tail3 = "J_Tail3",
	Tail4 = "J_Tail4",
}

-- Part name to joint mapping
local PART_TO_JOINT = {
	Body = "Body",
	Head = "Head",
	Neck = "Neck",
	Leg1 = "Leg1",
	Leg2 = "Leg2",
	Leg3 = "Leg3",
	Leg4 = "Leg4",
	WingL = "WingL",
	WingR = "WingR",
	Tail1 = "Tail1",
	Tail2 = "Tail2",
	Tail3 = "Tail3",
	Tail4 = "Tail4",
}

local function getMaterial(materialName: string): Enum.Material
	return MATERIAL_MAP[materialName] or Enum.Material.SmoothPlastic
end

local function createMeshPart(
	name: string,
	meshId: string,
	size: Vector3,
	cframe: CFrame,
	color: Color3,
	material: Enum.Material,
	transparency: number,
	parent: Instance
): MeshPart
	local part = Instance.new("MeshPart")
	part.Name = name
	part.MeshId = meshId
	part.Size = size
	part.CFrame = cframe
	part.Color = color
	part.Material = material
	part.Transparency = transparency
	part.CanCollide = false
	part.CanTouch = false
	part.CanQuery = false
	part.Massless = true
	part.Anchored = false
	part.CastShadow = size.Magnitude > 2
	part.CollisionGroup = "Creatures"
	part.Parent = parent
	return part
end

local function createMotor6D(
	name: string,
	part0: BasePart,
	part1: BasePart,
	c0: CFrame,
	c1: CFrame,
	parent: BasePart
): Motor6D
	local motor = Instance.new("Motor6D")
	motor.Name = name
	motor.Part0 = part0
	motor.Part1 = part1
	motor.C0 = c0
	motor.C1 = c1
	motor.Parent = part1 -- Roblox convention: Motor6D parented to Part1
	return motor
end

local function applyLODs(model: Model, lodFolder: Folder)
	-- Create LOD folders
	local lod0 = Instance.new("Folder")
	lod0.Name = "LOD0"
	lod0.Parent = lodFolder

	local lod1 = Instance.new("Folder")
	lod1.Name = "LOD1"
	lod1.Parent = lodFolder

	local lod2 = Instance.new("Folder")
	lod2.Name = "LOD2"
	lod2.Parent = lodFolder

	-- Move parts to appropriate LOD folders based on name suffix
	for _, obj in model:GetDescendants() do
		if obj:IsA("MeshPart") then
			local name = obj.Name
			if name:match("_LOD1$") then
				obj.Parent = lod1
			elseif name:match("_LOD2$") then
				obj.Parent = lod2
			else
				obj.Parent = lod0
			end
		end
	end

	-- Set up LOD streaming
	model.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
end

local function importCreature(
	speciesId: string,
	stage: number,
	meshData: BlenderModels.CreatureMeshData
): Model
	local model = Instance.new("Model")
	model.Name = string.format("%s_Stage%d", speciesId, stage)

	local rig = Instance.new("Model")
	rig.Name = "Rig"
	rig.Parent = model

	-- Create Root part (invisible, anchored)
	local rootPart = Instance.new("Part")
	rootPart.Name = "Root"
	rootPart.Size = Vector3.new(0.1, 0.1, 0.1)
	rootPart.CFrame = CFrame.new(0, 3, 0)
	rootPart.Transparency = 1
	rootPart.Anchored = true
	rootPart.CanCollide = false
	rootPart.CanTouch = false
	rootPart.CanQuery = false
	rootPart.Massless = true
	rootPart.CastShadow = false
	rootPart.Parent = rig
	model.PrimaryPart = rootPart

	-- Create parts from mesh data
	local parts: { [string]: BasePart } = {}

	for partName, data in meshData.Parts do
		local meshId = IMPORT_ROOT .. data.MeshId
		local size = Vector3.new(unpack(data.Size))
		local cframe = CFrame.new(unpack(data.CFrame))
		local color = Color3.new(unpack(data.Color))
		local material = getMaterial(data.Material)
		local transparency = data.Transparency or 0

		local part = createMeshPart(
			string.format("%s_%s_Stage%d", speciesId, partName, stage),
			meshId,
			size,
			cframe,
			color,
			material,
			transparency,
			rig
		)

		-- Add vertex color attribute if present
		if data.VertexColors then
			part:SetAttribute("VertexColors", data.VertexColors)
		end

		parts[partName] = part
	end

	-- Create Motor6D joints
	local joints = {}

	-- Root -> Body
	if parts.Body then
		joints.Body = createMotor6D(
			"J_Body",
			rootPart,
			parts.Body,
			CFrame.new(0, 0, 0), -- C0: Root to Body
			CFrame.new(0, 0, 0), -- C1: Body to Root
			parts.Body
		)
		joints.Body:SetAttribute("Role", "Body")
		joints.Body:SetAttribute("Phase", 0)
	end

	-- Body -> Head
	if parts.Body and parts.Head then
		joints.Head = createMotor6D(
			"J_Head",
			parts.Body,
			parts.Head,
			parts.Body.CFrame:ToObjectSpace(parts.Head.CFrame),
			CFrame.new(0, 0, 0),
			parts.Head
		)
		joints.Head:SetAttribute("Role", "Head")
		joints.Head:SetAttribute("Phase", 0.27)
	end

	-- Body -> Neck (if separate)
	if parts.Body and parts.Neck then
		joints.Neck = createMotor6D(
			"J_Neck",
			parts.Body,
			parts.Neck,
			parts.Body.CFrame:ToObjectSpace(parts.Neck.CFrame),
			CFrame.new(0, 0, 0),
			parts.Neck
		)
		joints.Neck:SetAttribute("Role", "Neck")
		joints.Neck:SetAttribute("Phase", 0.15)
	end

	-- Body -> Legs
	for i = 1, 4 do
		local legName = "Leg" .. i
		if parts.Body and parts[legName] then
			joints[legName] = createMotor6D(
				"J_" .. legName,
				parts.Body,
				parts[legName],
				parts.Body.CFrame:ToObjectSpace(parts[legName].CFrame),
				CFrame.new(0, 0, 0),
				parts[legName]
			)
			joints[legName]:SetAttribute("Role", legName)
			joints[legName]:SetAttribute("Phase", i * 0.27)
		end
	end

	-- Body -> Wings
	for _, wingSide in { "L", "R" } do
		local wingName = "Wing" .. wingSide
		if parts.Body and parts[wingName] then
			joints[wingName] = createMotor6D(
				"J_" .. wingName,
				parts.Body,
				parts[wingName],
				parts.Body.CFrame:ToObjectSpace(parts[wingName].CFrame),
				CFrame.new(0, 0, 0),
				parts[wingName]
			)
			joints[wingName]:SetAttribute("Role", wingName)
			joints[wingName]:SetAttribute("Phase", (wingSide == "L" and 0.5 or 0.77))
		end
	end

	-- Body -> Tail chain
	local prevPart = parts.Body
	local prevJointName = "Body"
	for i = 1, 4 do
		local tailName = "Tail" .. i
		if prevPart and parts[tailName] then
			joints[tailName] = createMotor6D(
				"J_" .. tailName,
				prevPart,
				parts[tailName],
				prevPart.CFrame:ToObjectSpace(parts[tailName].CFrame),
				CFrame.new(0, 0, 0),
				parts[tailName]
			)
			joints[tailName]:SetAttribute("Role", tailName)
			joints[tailName]:SetAttribute("Phase", 0.9 + i * 0.1)
			prevPart = parts[tailName]
		end
	end

	-- Set up LODs
	local lodFolder = Instance.new("Folder")
	lodFolder.Name = "LODs"
	lodFolder.Parent = model
	applyLODs(model, lodFolder)

	-- Add metadata attributes
	model:SetAttribute("Species", speciesId)
	model:SetAttribute("Stage", stage)
	model:SetAttribute("ImportedFromBlender", true)
	model:SetAttribute("RigVersion", 1)

	-- Add animator tag for CreatureAnimator
	local animatorTag = Instance.new("StringValue")
	animatorTag.Name = "AnimatorType"
	animatorTag.Value = meshData.AnimatorType or "Generic"
	animatorTag.Parent = model

	return model
end

local function uploadMeshesFromFolder(folder: Instance): { [string]: string }
	-- This would be used in Studio to bulk upload meshes
	-- Returns a mapping of original mesh names to uploaded asset IDs
	local meshIds = {}

	for _, obj in folder:GetDescendants() do
		if obj:IsA("MeshPart") and obj.MeshId ~= "" then
			-- In practice, you'd use AssetService:CreateMeshPartAsync or similar
			-- For now, we assume meshes are pre-uploaded
			local assetId = obj:GetAttribute("UploadedAssetId")
			if assetId then
				meshIds[obj.Name] = assetId
			end
		end
	end

	return meshIds
end

local function importAll()
	local imported = {}

	for speciesId, data in BlenderModels.Creatures do
		for stage, stageData in data.Stages do
			print(string.format("Importing %s Stage %d...", speciesId, stage))
			local model = importCreature(speciesId, stage, stageData)

			-- Parent to workspace or ReplicatedStorage
			local rigsFolder = ReplicatedStorage:FindFirstChild(RIG_FOLDER)
			if not rigsFolder then
				rigsFolder = Instance.new("Folder")
				rigsFolder.Name = RIG_FOLDER
				rigsFolder.Parent = ReplicatedStorage
			end

			model.Parent = rigsFolder
			imported[string.format("%s_Stage%d", speciesId, stage)] = model
		end
	end

	print(string.format("Imported %d creature rigs", #imported))
	return imported
end

local function importSingle(speciesId: string, stage: number)
	local data = BlenderModels.Creatures[speciesId]
	if not data then
		warn("Species not found in BlenderModels:", speciesId)
		return nil
	end

	local stageData = data.Stages[stage]
	if not stageData then
		warn("Stage not found for", speciesId, stage)
		return nil
	end

	return importCreature(speciesId, stage, stageData)
end

local function validateRig(model: Model): boolean
	-- Validate rig structure matches expectations
	local root = model.PrimaryPart
	if not root or root.Name ~= "Root" then
		warn("Invalid rig: missing Root part")
		return false
	end

	local rig = model:FindFirstChild("Rig")
	if not rig then
		warn("Invalid rig: missing Rig folder")
		return false
	end

	-- Check required joints exist
	local requiredJoints = { "J_Body" }
	for _, jointName in requiredJoints do
		local found = false
		for _, obj in rig:GetDescendants() do
			if obj:IsA("Motor6D") and obj.Name == jointName then
				found = true
				break
			end
		end
		if not found then
			warn("Invalid rig: missing required joint", jointName)
			return false
		end
	end

	-- Check all parts have correct properties
	for _, obj in rig:GetDescendants() do
		if obj:IsA("MeshPart") then
			if obj.CanCollide or obj.CanTouch or obj.CanQuery or not obj.Massless or obj.Anchored then
				warn("MeshPart has invalid physics properties:", obj.Name)
				return false
			end
			if obj.MeshId == "" then
				warn("MeshPart missing MeshId:", obj.Name)
				return false
			end
		end
	end

	return true
end

local function createPreviewModel(speciesId: string, stage: number): Model
	-- Create a preview model with just the LOD0 meshes for quick viewing
	local data = BlenderModels.Creatures[speciesId]
	if not data or not data.Stages[stage] then
		return nil
	end

	local model = importCreature(speciesId, stage, data.Stages[stage])

	-- Remove LOD1/LOD2 for preview
	local lods = model:FindFirstChild("LODs")
	if lods then
		lods.LOD1:Destroy()
		lods.LOD2:Destroy()
	end

	model.Name = speciesId .. "_Stage" .. stage .. "_Preview"
	return model
end

return {
	ImportAll = importAll,
	ImportSingle = importSingle,
	ImportCreature = importCreature,
	CreatePreviewModel = createPreviewModel,
	ValidateRig = validateRig,
	UploadMeshesFromFolder = uploadMeshesFromFolder,
	MATERIAL_MAP = MATERIAL_MAP,
	JOINT_NAMES = JOINT_NAMES,
	PART_TO_JOINT = PART_TO_JOINT,
}