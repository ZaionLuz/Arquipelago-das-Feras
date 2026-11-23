--!strict
-- create_creature_models.luau - Script para criar modelos placeholder das criaturas no Roblox
-- Execute no Command Bar do Roblox Studio ou como Plugin

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerStorage = game:GetService("ServerStorage")

-- Dados das 27 criaturas
local creatures = {
	-- Fire
	CINZELO = {Name = "Cinzelo", Element = "Fire", Color = Color3.fromRGB(255, 100, 50), Size = Vector3.new(2, 2, 2)},
	MAGMARAU = {Name = "Magmarau", Element = "Fire", Color = Color3.fromRGB(255, 80, 30), Size = Vector3.new(3.5, 3.5, 3.5)},
	FENIXFULIGEM = {Name = "Fênix Fuligem", Element = "Fire", Color = Color3.fromRGB(255, 140, 50), Size = Vector3.new(4, 4, 4)},
	VULCANODRAGO = {Name = "Vulcano Draco", Element = "Fire", Color = Color3.fromRGB(255, 60, 20), Size = Vector3.new(6, 6, 6)},

	-- Water
	HIDROSONDA = {Name = "Hidrossonda", Element = "Water", Color = Color3.fromRGB(50, 150, 255), Size = Vector3.new(2, 2, 2)},
	VAPORAL = {Name = "Vaporal", Element = "Water", Color = Color3.fromRGB(70, 170, 255), Size = Vector3.new(3.5, 3.5, 3.5)},
	LEVIATHAN = {Name = "Leviatã", Element = "Water", Color = Color3.fromRGB(40, 130, 255), Size = Vector3.new(5, 5, 5)},
	ABYSSALIS = {Name = "Abissalis", Element = "Water", Color = Color3.fromRGB(30, 100, 220), Size = Vector3.new(6, 6, 6)},

	-- Nature
	VERDANTIS = {Name = "Verdantis", Element = "Nature", Color = Color3.fromRGB(80, 200, 80), Size = Vector3.new(2, 2, 2)},
	DRYADUS = {Name = "Dryadus", Element = "Nature", Color = Color3.fromRGB(60, 180, 60), Size = Vector3.new(3.5, 3.5, 3.5)},
	YGGDRASIL = {Name = "Yggdrasil", Element = "Nature", Color = Color3.fromRGB(50, 160, 50), Size = Vector3.new(5, 5, 5)},
	GAIA_HEART = {Name = "Coração de Gaia", Element = "Nature", Color = Color3.fromRGB(40, 140, 40), Size = Vector3.new(6, 6, 6)},

	-- Earth
	GRAOZINHO = {Name = "Grãozinho", Element = "Earth", Color = Color3.fromRGB(180, 140, 80), Size = Vector3.new(1.5, 1.5, 1.5)},
	ESCORPIODRA = {Name = "Escorpiodra", Element = "Earth", Color = Color3.fromRGB(160, 120, 70), Size = Vector3.new(3, 3, 3)},
	ESFINGEOLITO = {Name = "Esfingeólito", Element = "Earth", Color = Color3.fromRGB(140, 110, 60), Size = Vector3.new(4.5, 4.5, 4.5)},
	COLOSSODUNE = {Name = "Colosso Duna", Element = "Earth", Color = Color3.fromRGB(130, 100, 50), Size = Vector3.new(7, 7, 7)},

	-- Air
	PENUGEM = {Name = "Penugem", Element = "Air", Color = Color3.fromRGB(180, 200, 255), Size = Vector3.new(1.5, 1.5, 1.5)},
	VENTANIL = {Name = "Ventanil", Element = "Air", Color = Color3.fromRGB(160, 190, 255), Size = Vector3.new(3, 3, 3)},
	TROVORAPTOR = {Name = "Trovóraptor", Element = "Air", Color = Color3.fromRGB(140, 170, 255), Size = Vector3.new(4, 4, 4)},
	AERONIMBO = {Name = "Aeronimbo", Element = "Air", Color = Color3.fromRGB(120, 150, 255), Size = Vector3.new(5.5, 5.5, 5.5)},

	-- Shadow
	LODINHO = {Name = "Lodinho", Element = "Shadow", Color = Color3.fromRGB(120, 60, 180), Size = Vector3.new(2, 2, 2)},
	CAUDALUME = {Name = "Caudalume", Element = "Shadow", Color = Color3.fromRGB(100, 50, 160), Size = Vector3.new(3.5, 3.5, 3.5)},
	VAGALUMORTE = {Name = "Vagalumorte", Element = "Shadow", Color = Color3.fromRGB(80, 40, 140), Size = Vector3.new(4.5, 4.5, 4.5)},
	REINEVOENTO = {Name = "Rei Nevoento", Element = "Shadow", Color = Color3.fromRGB(60, 30, 120), Size = Vector3.new(6, 6, 6)},

	-- Hybrids
	PIROHIDRO = {Name = "Pirohidro", Element = "FireWater", Color = Color3.fromRGB(255, 120, 150), Size = Vector3.new(5, 5, 5)},
	TERRAVENTO = {Name = "Terravento", Element = "EarthAir", Color = Color3.fromRGB(170, 170, 220), Size = Vector3.new(5, 5, 5)},
	LUZSOMBRA = {Name = "Luzsombra", Element = "NatureShadow", Color = Color3.fromRGB(180, 120, 180), Size = Vector3.new(5, 5, 5)},
}

-- Element icons
local elementIcons = {
	Fire = "🔥", Water = "💧", Nature = "🌿", Earth = "🪨",
	Air = "💨", Shadow = "🌑", FireWater = "🔥💧",
	EarthAir = "🪨💨", NatureShadow = "🌿🌑"
}

-- Create assets folder
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

-- Clear existing
for _, child in ipairs(creaturesFolder:GetChildren()) do
	child:Destroy()
end

-- Helper: Create element tag
local function createElementTag(parent: Instance, element: string)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "ElementTag"
	billboard.Size = UDim2.new(0, 60, 0, 30)
	billboard.StudsOffset = Vector3.new(0, 4, 3)
	billboard.Adornee = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")
	billboard.AlwaysOnTop = true
	billboard.Parent = parent

	local frame = Instance.new("Frame")
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
	frame.BackgroundTransparency = 0.2
	frame.BorderSizePixel = 0
	frame.Parent = billboard

	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(0, 8)
	corner.Parent = frame

	local label = Instance.new("TextLabel")
	label.Size = UDim2.new(1, 0, 1, 0)
	label.BackgroundTransparency = 1
	label.Text = elementIcons[element] or element
	label.TextColor3 = Color3.fromRGB(255, 255, 255)
	label.TextScaled = true
	label.Font = Enum.Font.GothamBold
	label.Parent = frame

	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.fromRGB(255, 255, 255)
	stroke.Transparency = 0.5
	stroke.Thickness = 1
	stroke.Parent = frame
end

-- Helper: Create name tag
local function createNameTag(parent: Instance, name: string, level: number?)
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "NameTag"
	billboard.Size = UDim2.new(0, 200, 0, 50)
	billboard.StudsOffset = Vector3.new(0, 5, 0)
	billboard.Adornee = parent.PrimaryPart or parent:FindFirstChildWhichIsA("BasePart")
	billboard.AlwaysOnTop = true
	billboard.Parent = parent

	local nameLabel = Instance.new("TextLabel")
	nameLabel.Size = UDim2.new(1, 0, 0.6, 0)
	nameLabel.BackgroundTransparency = 1
	nameLabel.Text = name
	nameLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
	nameLabel.TextScaled = true
	nameLabel.Font = Enum.Font.GothamBold
	nameLabel.TextStrokeTransparency = 0
	nameLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
	nameLabel.Parent = billboard

	if level then
		local levelLabel = Instance.new("TextLabel")
		levelLabel.Size = UDim2.new(1, 0, 0.4, 0)
		levelLabel.Position = UDim2.new(0, 0, 0.6, 0)
		levelLabel.BackgroundTransparency = 1
		levelLabel.Text = "Lv." .. level
		levelLabel.TextColor3 = Color3.fromRGB(255, 215, 0)
		levelLabel.TextScaled = true
		levelLabel.Font = Enum.Font.GothamBold
		levelLabel.TextStrokeTransparency = 0
		levelLabel.TextStrokeColor3 = Color3.fromRGB(0, 0, 0)
		levelLabel.Parent = billboard
	end
end

-- Helper: Add idle animation (bobbing)
local function addIdleAnimation(model: Model)
	local primaryPart = model.PrimaryPart
	if not primaryPart then return end

	local originalPos = primaryPart.Position
	local connection

	connection = game:GetService("RunService").Heartbeat:Connect(function()
		if not model.Parent then
			connection:Disconnect()
			return
		end
		local t = tick() * 1.5
		local offset = math.sin(t) * 0.3
		if model.PrimaryPart then
			model:PivotTo(CFrame.new(originalPos + Vector3.new(0, offset, 0)))
		end
	end)
end

-- Helper: Add shiny sparkles
local function addShinyEffect(model: Model, color: Color3)
	for _, part in ipairs(model:GetDescendants()) do
		if part:IsA("BasePart") then
			part.Material = Enum.Material.Neon

			local sparkles = Instance.new("ParticleEmitter")
			sparkles.Name = "ShinySparkles"
			sparkles.Color = ColorSequence.new(Color3.fromRGB(255, 255, 200))
			sparkles.Size = NumberSequence.new(0.2, 0.5)
			sparkles.Lifetime = NumberRange.new(0.5, 1.5)
			sparkles.Rate = 20
			sparkles.Speed = NumberRange.new(1, 4)
			sparkles.SpreadAngle = Vector2.new(180, 180)
			sparkles.Parent = part
		end
	end
end

-- Main creation function
local function createCreatureModel(speciesId: string, data: any): Model
	local model = Instance.new("Model")
	model.Name = speciesId

	-- Main body
	local body = Instance.new("Part")
	body.Name = "Body"
	body.Size = data.Size
	body.Shape = Enum.PartType.Ball
	body.Anchored = true
	body.CanCollide = false
	body.Material = Enum.Material.Neon
	body.Color = data.Color
	body.Parent = model

	model.PrimaryPart = body

	-- Add distinctive features based on element
	if data.Element == "Fire" then
		-- Flame particles
		local fire = Instance.new("ParticleEmitter")
		fire.Name = "Flames"
		fire.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 30)),
			ColorSequenceKeypoint.new(0.5, Color3.fromRGB(255, 200, 50)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 100)),
		})
		fire.Size = NumberSequence.new(0.5, 2)
		fire.Lifetime = NumberRange.new(0.3, 0.8)
		fire.Rate = 30
		fire.Speed = NumberRange.new(2, 6)
		fire.SpreadAngle = Vector2.new(90, 90)
		fire.Acceleration = Vector3.new(0, 10, 0)
		fire.Parent = body

		-- Point light
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(255, 150, 50)
		light.Range = 15
		light.Brightness = 2
		light.Parent = body

	elseif data.Element == "Water" then
		-- Water particles
		local water = Instance.new("ParticleEmitter")
		water.Name = "WaterDrops"
		water.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255))
		water.Size = NumberSequence.new(0.2, 0.5)
		water.Lifetime = NumberRange.new(0.5, 1.5)
		water.Rate = 20
		water.Speed = NumberRange.new(1, 3)
		water.SpreadAngle = Vector2.new(180, 180)
		water.Acceleration = Vector3.new(0, -5, 0)
		water.Transparency = NumberSequence.new(0.3)
		water.Parent = body

		body.Material = Enum.Material.Glass
		body.Transparency = 0.3

	elseif data.Element == "Nature" then
		-- Leaf particles
		local leaves = Instance.new("ParticleEmitter")
		leaves.Name = "Leaves"
		leaves.Color = ColorSequence.new(Color3.fromRGB(80, 200, 80))
		leaves.Size = NumberSequence.new(0.3, 0.8)
		leaves.Lifetime = NumberRange.new(2, 4)
		leaves.Rate = 10
		leaves.Speed = NumberRange.new(0.5, 2)
		leaves.SpreadAngle = Vector2.new(180, 180)
		leaves.Acceleration = Vector3.new(math.random(-5,5), -2, math.random(-5,5))
		leaves.Rotation = NumberRange.new(0, 360)
		leaves.RotSpeed = NumberRange.new(-90, 90)
		leaves.Parent = body

		body.Material = Enum.Material.Grass

	elseif data.Element == "Earth" then
		body.Material = Enum.Material.Rock
		body.Color = data.Color

		-- Dust particles
		local dust = Instance.new("ParticleEmitter")
		dust.Name = "Dust"
		dust.Color = ColorSequence.new(Color3.fromRGB(160, 130, 80))
		dust.Size = NumberSequence.new(0.2, 0.5)
		dust.Lifetime = NumberRange.new(0.5, 1)
		dust.Rate = 5
		dust.Speed = NumberRange.new(1, 3)
		dust.SpreadAngle = Vector2.new(180, 180)
		dust.Parent = body

	elseif data.Element == "Air" then
		body.Material = Enum.Material.ForceField
		body.Transparency = 0.2

		-- Wind particles
		local wind = Instance.new("ParticleEmitter")
		wind.Name = "Wind"
		wind.Color = ColorSequence.new(Color3.fromRGB(200, 220, 255))
		wind.Size = NumberSequence.new(0.3, 1)
		wind.Lifetime = NumberRange.new(1, 2)
		wind.Rate = 15
		wind.Speed = NumberRange.new(5, 15)
		wind.SpreadAngle = Vector2.new(180, 180)
		wind.Acceleration = Vector3.new(math.random(-10,10), 0, math.random(-10,10))
		wind.Parent = body

	elseif data.Element == "Shadow" then
		body.Material = Enum.Material.Neon
		body.Color = data.Color

		-- Shadow particles
		local shadow = Instance.new("ParticleEmitter")
		shadow.Name = "ShadowParticles"
		shadow.Color = ColorSequence.new(Color3.fromRGB(80, 30, 150))
		shadow.Size = NumberSequence.new(0.3, 1)
		shadow.Lifetime = NumberRange.new(1, 2)
		shadow.Rate = 15
		shadow.Speed = NumberRange.new(1, 4)
		shadow.SpreadAngle = Vector2.new(180, 180)
		shadow.Parent = body

		-- Dark aura
		local light = Instance.new("PointLight")
		light.Color = Color3.fromRGB(80, 30, 150)
		light.Range = 10
		light.Brightness = 1
		light.Parent = body

	elseif data.Element == "FireWater" then
		-- Steam particles
		local steam = Instance.new("ParticleEmitter")
		steam.Name = "Steam"
		steam.Color = ColorSequence.new({
			ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 100, 100)),
			ColorSequenceKeypoint.new(1, Color3.fromRGB(100, 200, 255)),
		})
		steam.Size = NumberSequence.new(0.5, 2)
		steam.Lifetime = NumberRange.new(0.5, 1.5)
		steam.Rate = 25
		steam.Speed = NumberRange.new(3, 8)
		steam.SpreadAngle = Vector2.new(120, 120)
		steam.Acceleration = Vector3.new(0, 15, 0)
		steam.Parent = body

	elseif data.Element == "EarthAir" then
		-- Dust tornado
		local tornado = Instance.new("ParticleEmitter")
		tornado.Name = "Tornado"
		tornado.Color = ColorSequence.new(Color3.fromRGB(180, 170, 200))
		tornado.Size = NumberSequence.new(0.3, 1.5)
		tornado.Lifetime = NumberRange.new(1, 3)
		tornado.Rate = 30
		tornado.Speed = NumberRange.new(5, 15)
		tornado.SpreadAngle = Vector2.new(180, 180)
		tornado.Acceleration = Vector3.new(0, 10, 0)
		tornado.Parent = body

		-- Rotation
		local spin = Instance.new("BodyAngularVelocity")
		spin.AngularVelocity = Vector3.new(0, 2, 0)
		spin.MaxTorque = Vector3.new(0, 10000, 0)
		spin.Parent = body

	elseif data.Element == "NatureShadow" then
		-- Dual particles
		local nature = Instance.new("ParticleEmitter")
		nature.Name = "NatureEssence"
		nature.Color = ColorSequence.new(Color3.fromRGB(100, 200, 100))
		nature.Size = NumberSequence.new(0.3, 0.8)
		nature.Lifetime = NumberRange.new(1, 2)
		nature.Rate = 10
		nature.Speed = NumberRange.new(1, 3)
		nature.SpreadAngle = Vector2.new(180, 180)
		nature.Parent = body

		local shadow = Instance.new("ParticleEmitter")
		shadow.Name = "ShadowEssence"
		shadow.Color = ColorSequence.new(Color3.fromRGB(150, 80, 180))
		shadow.Size = NumberSequence.new(0.3, 0.8)
		shadow.Lifetime = NumberRange.new(1, 2)
		shadow.Rate = 10
		shadow.Speed = NumberRange.new(1, 3)
		shadow.SpreadAngle = Vector2.new(180, 180)
		shadow.Parent = body
	end

	-- Add tags
	createElementTag(model, data.Element)
	createNameTag(model, data.Name, 5)

	-- Add idle animation
	addIdleAnimation(model)

	return model
end

-- Create all creatures
print("[CreateModels] Creating creature models...")
local count = 0

for speciesId, data in pairs(creatures) do
	local model = createCreatureModel(speciesId, data)
	model.Parent = creaturesFolder
	count += 1
	print(`[CreateModels] Created: {speciesId} ({data.Name})`)
end

print(`[CreateModels] Done! Created {count} creature models in ReplicatedStorage.Assets.Creatures`)

-- Also create a simple "shiny" variant folder
local shinyFolder = assetsFolder:FindFirstChild("ShinyCreatures")
if not shinyFolder then
	shinyFolder = Instance.new("Folder")
	shinyFolder.Name = "ShinyCreatures"
	shinyFolder.Parent = assetsFolder
end

for _, child in ipairs(shinyFolder:GetChildren()) do
	child:Destroy()
end

for speciesId, data in pairs(creatures) do
	local model = createCreatureModel(speciesId, data)
	model.Name = speciesId .. "_Shiny"
	addShinyEffect(model, data.Color)
	model.Parent = shinyFolder
end

print(`[CreateModels] Created shiny variants in ReplicatedStorage.Assets.ShinyCreatures`)

return creaturesFolder