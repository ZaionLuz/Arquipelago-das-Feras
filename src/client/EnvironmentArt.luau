--!nonstrict
-- ENVIRONMENT ART - Client-side visual effects, LOD, streaming, weather, day/night
-- Micro-animations, biome transitions, particle effects, visual polish

local Run = game:GetService("RunService")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local T = require(ReplicatedStorage.Shared.ArtTokens)
local I = require(ReplicatedStorage.Shared.Islands)
local B = require(ReplicatedStorage.Shared.Biomes)
local E = {}

local started = false
local records = setmetatable({}, { __mode = "k" })
local weatherEffects = {}
local biomeTransitionTween = nil
local currentBiome = nil
local lodUpdateCounter = 0
local LocalPlayer = Players.LocalPlayer

-- Quality settings
E.QualityPresets = {
	Baixo = {
		maxParticles = 24,
		maxAnimatedParts = 16,
		particleDistance = 80,
		animationDistance = 60,
		weatherEnabled = false,
		shadowsEnabled = false,
		bloomEnabled = false,
		atmosphereEnabled = false,
	},
	Medio = {
		maxParticles = 48,
		maxAnimatedParts = 32,
		particleDistance = 120,
		animationDistance = 100,
		weatherEnabled = true,
		shadowsEnabled = true,
		bloomEnabled = true,
		atmosphereEnabled = true,
	},
	Alto = {
		maxParticles = 96,
		maxAnimatedParts = 64,
		particleDistance = 200,
		animationDistance = 170,
		weatherEnabled = true,
		shadowsEnabled = true,
		bloomEnabled = true,
		atmosphereEnabled = true,
	},
}

function E.getQuality()
	local quality = LocalPlayer:GetAttribute("GraphicsQuality") or "Medio"
	return E.QualityPresets[quality] or E.QualityPresets.Medio
end

function E.isMotionReduced()
	return LocalPlayer:GetAttribute("MotionReduced") == true
end

-- Initialize client environment
function E.start()
	if started then return end
	started = true

	-- Setup character dressing
	E.setupCharacterDressing()

	-- Start render loop
	Run.Heartbeat:Connect(E.onRenderStep)

	-- Setup biome detection and transitions
	E.setupBiomeDetection()

	-- Setup weather listener
	E.setupWeatherListener()

	-- Setup day/night cycle sync
	E.setupDayNightSync()

	-- Setup LOD system
	E.setupLOD()

	-- Initial scan
	task.defer(E.scanForArtObjects)

	print("[EnvironmentArt] Client environment initialized")
end

function E.setupCharacterDressing()
	local function dress(character)
		local torso = character:FindFirstChild("UpperTorso")
			or character:FindFirstChild("Torso")
			or character:WaitForChild("UpperTorso", 2)
		if not torso then return end

		local old = character:FindFirstChild("ArteExplorador")
		if old then old:Destroy() end

		local model = Instance.new("Model")
		model.Name = "ArteExplorador"
		model.Parent = character

		local function cloth(name, size, offset, color)
			local p = Instance.new("Part")
			p.Name = name
			p.Size = size
			p.CFrame = torso.CFrame * CFrame.new(offset)
			p.Color = color
			p.Material = Enum.Material.SmoothPlastic
			p.Anchored = false
			p.Massless = true
			p.CanCollide = false
			p.CanTouch = false
			p.CanQuery = false
			p.CastShadow = false
			p.Parent = model
			local weld = Instance.new("WeldConstraint")
			weld.Part0 = torso
			weld.Part1 = p
			weld.Parent = p
		end

		local front = -torso.Size.Z * 0.5 - 0.06
		cloth("Lenco", Vector3.new(torso.Size.X * 0.9, 0.18, 0.1), Vector3.new(0, torso.Size.Y * 0.35, front), T.Ramps.Tidal[3])
		cloth("PontaDoLenco", Vector3.new(0.3, 0.5, 0.1), Vector3.new(torso.Size.X * 0.26, torso.Size.Y * 0.1, front - 0.02), T.Ramps.Tidal[4])
		cloth("BaseDaBussola", Vector3.new(0.32, 0.32, 0.08), Vector3.new(-torso.Size.X * 0.24, 0, front - 0.01), T.Ramps.Sand[2])
		cloth("AgulhaDaBussola", Vector3.new(0.08, 0.22, 0.05), Vector3.new(-torso.Size.X * 0.24, 0, front - 0.07), T.Ramps.Sand[5])
	end

	LocalPlayer.CharacterAdded:Connect(function(character)
		task.defer(function()
			character:WaitForChild("HumanoidRootPart", 10)
			if character.Parent then dress(character) end
		end)
	end)

	if LocalPlayer.Character then
		task.defer(dress, LocalPlayer.Character)
	end
end

function E.setupBiomeDetection()
	task.spawn(function()
		while true do
			task.wait(0.5)
			local character = LocalPlayer.Character
			local hrp = character and character:FindFirstChild("HumanoidRootPart")
			if hrp then
				local best, bd = nil, math.huge
				for _, def in I.List do
					local center = I.pos(def.idx)
					local dist = (Vector3.new(center.X, 0, center.Z) - Vector3.new(hrp.Position.X, 0, hrp.Position.Z)).Magnitude
					if dist < bd then
						best, bd = def, dist
					end
				end
				if best and best ~= currentBiome then
					E.onBiomeChanged(currentBiome, best)
					currentBiome = best
				end
			end
		end
	end)
end

function E.onBiomeChanged(oldBiome, newBiome)
	if not newBiome then return end

	-- Smooth lighting transition
	local quality = E.getQuality()
	if quality.atmosphereEnabled then
		if biomeTransitionTween then biomeTransitionTween:Cancel() end

		biomeTransitionTween = TweenService:Create(
			Lighting,
			TweenInfo.new(3, Enum.EasingStyle.Quad, Enum.EasingDirection.InOut),
			{
				Ambient = newBiome.ambient,
				OutdoorAmbient = newBiome.ambient,
				ClockTime = newBiome.clock,
			}
		)
		biomeTransitionTween:Play()
	end

	-- Update sky/atmosphere
	E.updateAtmosphere(newBiome)

	-- Notify other systems
	local event = ReplicatedStorage:FindFirstChild("BiomeChanged")
	if event then
		event:Fire(newBiome.id, oldBiome and oldBiome.id)
	end
end

function E.updateAtmosphere(biome)
	local atmosphere = Lighting:FindFirstChild("Atmosphere")
	if not atmosphere then
		atmosphere = Instance.new("Atmosphere")
		atmosphere.Parent = Lighting
	end

	-- Adjust atmosphere based on biome element
	local element = biome.el
	if element == "Natureza" then
		atmosphere.Density = 0.15
		atmosphere.Haze = 0.8
		atmosphere.Color = Color3.fromRGB(120, 160, 130)
		atmosphere.Decay = Color3.fromRGB(100, 140, 110)
		atmosphere.Glare = 0.1
	elseif element == "Fogo" then
		atmosphere.Density = 0.25
		atmosphere.Haze = 0.9
		atmosphere.Color = Color3.fromRGB(180, 100, 60)
		atmosphere.Decay = Color3.fromRGB(150, 70, 40)
		atmosphere.Glare = 0.3
	elseif element == "Agua" then
		atmosphere.Density = 0.18
		atmosphere.Haze = 0.85
		atmosphere.Color = Color3.fromRGB(100, 160, 200)
		atmosphere.Decay = Color3.fromRGB(80, 130, 180)
		atmosphere.Glare = 0.2
	elseif element == "Sombra" then
		atmosphere.Density = 0.3
		atmosphere.Haze = 0.95
		atmosphere.Color = Color3.fromRGB(80, 60, 120)
		atmosphere.Decay = Color3.fromRGB(50, 40, 90)
		atmosphere.Glare = 0.05
	elseif element == "Gelo" then
		atmosphere.Density = 0.12
		atmosphere.Haze = 0.7
		atmosphere.Color = Color3.fromRGB(160, 200, 255)
		atmosphere.Decay = Color3.fromRGB(140, 180, 240)
		atmosphere.Glare = 0.15
	elseif element == "Eletrico" then
		atmosphere.Density = 0.2
		atmosphere.Haze = 0.9
		atmosphere.Color = Color3.fromRGB(150, 150, 200)
		atmosphere.Decay = Color3.fromRGB(120, 120, 180)
		atmosphere.Glare = 0.25
	elseif element == "Luz" then
		atmosphere.Density = 0.1
		atmosphere.Haze = 0.6
		atmosphere.Color = Color3.fromRGB(230, 240, 255)
		atmosphere.Decay = Color3.fromRGB(210, 220, 255)
		atmosphere.Glare = 0.3
	else
		atmosphere.Density = 0.18
		atmosphere.Haze = 0.9
		atmosphere.Color = T.Ramps.Sky[4]
		atmosphere.Decay = T.Ramps.Metal[3]
		atmosphere.Glare = 0.1
	end
end

function E.setupWeatherListener()
	local remote = ReplicatedStorage:FindFirstChild("WeatherUpdate")
	if remote then
		remote.OnClientEvent:Connect(function(biomeId, weatherType)
			E.applyWeatherEffect(biomeId, weatherType)
		end)
	end
end

function E.applyWeatherEffect(biomeId, weatherType)
	-- Only apply if we're in that biome
	if currentBiome and currentBiome.id ~= biomeId then return end

	local quality = E.getQuality()
	if not quality.weatherEnabled then return end

	-- Remove existing weather
	E.clearWeather()

	-- Apply new weather
	if weatherType == "Rain" then
		E.createRain()
	elseif weatherType == "Ash" then
		E.createAsh()
	elseif weatherType == "Snow" then
		E.createSnow()
	elseif weatherType == "Storm" then
		E.createStorm()
	elseif weatherType == "Aurora" then
		E.createAurora()
	elseif weatherType == "VoidFog" then
		E.createVoidFog()
	end
end

function E.clearWeather()
	for _, effect in weatherEffects do
		if effect.Destroy then effect:Destroy() end
	end
	weatherEffects = {}

	-- Remove weather-specific lighting
	for _, child in Lighting:GetChildren() do
		if child:GetAttribute("WeatherEffect") then
			child:Destroy()
		end
	end
end

function E.createRain()
	local camera = Workspace.CurrentCamera
	if not camera then return end

	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "ClientRain"
	emitter.Texture = "rbxassetid://241629423"
	emitter.Color = ColorSequence.new(Color3.fromRGB(150, 180, 220))
	emitter.Size = NumberSequence.new(0.15, 0.03)
	emitter.Lifetime = NumberRange.new(0.5, 1.5)
	emitter.Rate = 300
	emitter.Speed = NumberRange.new(40, 60)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Drag = 0
	emitter.Acceleration = Vector3.new(0, -30, 0)
	emitter.ZOffset = 1
	emitter.Parent = camera
	table.insert(weatherEffects, emitter)

	-- Rain sound
	local sound = Instance.new("Sound")
	sound.Name = "RainSound"
	sound.SoundId = "rbxassetid://100000013"
	sound.Volume = 0.25
	sound.Looped = true
	sound.Parent = camera
	sound:Play()
	table.insert(weatherEffects, sound)

	-- Screen effect
	E.createScreenRain()
end

function E.createScreenRain()
	local gui = LocalPlayer:FindFirstChild("PlayerGui"):FindFirstChild("EnvironmentEffects")
	if not gui then
		gui = Instance.new("ScreenGui")
		gui.Name = "EnvironmentEffects"
		gui.ResetOnSpawn = false
		gui.IgnoreGuiInset = true
		gui.Parent = LocalPlayer.PlayerGui
	end

	-- Remove old drops
	for _, child in gui:GetChildren() do
		if child.Name == "RainDrop" then child:Destroy() end
	end

	-- Create rain drops on screen
	for i = 1, 30 do
		local drop = Instance.new("Frame")
		drop.Name = "RainDrop"
		drop.Size = UDim2.fromOffset(math.random(1, 2), math.random(20, 60))
		drop.Position = UDim2.fromScale(math.random(), math.random())
		drop.BackgroundColor3 = Color3.fromRGB(150, 180, 220)
		drop.BackgroundTransparency = 0.7
		drop.BorderSizePixel = 0
		drop.Parent = gui

		-- Animate
		task.spawn(function()
			while drop.Parent do
				TweenService:Create(drop, TweenInfo.new(math.random(50, 100) / 100), {
					Position = UDim2.fromScale(drop.Position.X.Scale, drop.Position.Y.Scale + 1.2)
				}):Play()
				task.wait(math.random(50, 100) / 100)
				if drop.Parent then
					drop.Position = UDim2.fromScale(math.random(), -0.1)
				end
			end
		end)
	end
end

function E.createAsh()
	local camera = Workspace.CurrentCamera
	if not camera then return end

	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "ClientAsh"
	emitter.Texture = "rbxassetid://241629423"
	emitter.Color = ColorSequence.new(Color3.fromRGB(80, 70, 70), Color3.fromRGB(40, 35, 35))
	emitter.Size = NumberSequence.new(0.4, 0.1)
	emitter.Lifetime = NumberRange.new(3, 8)
	emitter.Rate = 80
	emitter.Speed = NumberRange.new(1, 4)
	emitter.SpreadAngle = Vector2.new(360, 360)
	emitter.Drag = 0.5
	emitter.ZOffset = 1
	emitter.Parent = camera
	table.insert(weatherEffects, emitter)
end

function E.createSnow()
	local camera = Workspace.CurrentCamera
	if not camera then return end

	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "ClientSnow"
	emitter.Texture = "rbxassetid://241629423"
	emitter.Color = ColorSequence.new(Color3.fromRGB(255, 255, 255))
	emitter.Size = NumberSequence.new(0.25, 0.08)
	emitter.Lifetime = NumberRange.new(5, 10)
	emitter.Rate = 150
	emitter.Speed = NumberRange.new(0.5, 2)
	emitter.SpreadAngle = Vector2.new(180, 180)
	emitter.Drag = 1
	emitter.Acceleration = Vector3.new(0, -2, 0)
	emitter.ZOffset = 1
	emitter.Parent = camera
	table.insert(weatherEffects, emitter)
end

function E.createStorm()
	local camera = Workspace.CurrentCamera
	if not camera then return end

	-- Heavy rain
	local rain = Instance.new("ParticleEmitter")
	rain.Name = "ClientStormRain"
	rain.Texture = "rbxassetid://241629423"
	rain.Color = ColorSequence.new(Color3.fromRGB(100, 120, 160))
	rain.Size = NumberSequence.new(0.25, 0.08)
	rain.Lifetime = NumberRange.new(0.3, 1)
	rain.Rate = 500
	rain.Speed = NumberRange.new(60, 100)
	rain.SpreadAngle = Vector2.new(180, 180)
	rain.Drag = 0
	rain.Acceleration = Vector3.new(0, -40, 0)
	rain.ZOffset = 1
	rain.Parent = camera
	table.insert(weatherEffects, rain)

	-- Lightning flashes
	task.spawn(function()
		for i = 1, 20 do
			task.wait(math.random(2, 8))
			E.flashLightning()
		end
	end)
end

function E.flashLightning()
	local gui = LocalPlayer.PlayerGui:FindFirstChild("EnvironmentEffects")
	if not gui then return end

	local flash = Instance.new("Frame")
	flash.Name = "LightningFlash"
	flash.Size = UDim2.fromScale(1, 1)
	flash.BackgroundColor3 = Color3.fromRGB(255, 255, 220)
	flash.BackgroundTransparency = 0
	flash.BorderSizePixel = 0
	flash.Parent = gui

	TweenService:Create(flash, TweenInfo.new(0.05), {BackgroundTransparency = 1}):Play()
	task.wait(0.05)
	TweenService:Create(flash, TweenInfo.new(0.1), {BackgroundTransparency = 0}):Play()
	task.wait(0.1)
	TweenService:Create(flash, TweenInfo.new(0.2), {BackgroundTransparency = 1}):Play()
	game:GetService("Debris"):AddItem(flash, 0.5)

	-- Thunder sound
	local sound = Instance.new("Sound")
	sound.SoundId = "rbxassetid://100000014"
	sound.Volume = 0.4
	sound.Parent = Workspace.CurrentCamera
	sound:Play()
	game:GetService("Debris"):AddItem(sound, 2)
end

function E.createAurora()
	local camera = Workspace.CurrentCamera
	if not camera then return end

	local colors = {
		Color3.fromRGB(100, 255, 150),
		Color3.fromRGB(150, 200, 255),
		Color3.fromRGB(200, 150, 255),
		Color3.fromRGB(100, 255, 255),
	}

	for i = 1, 8 do
		local wave = Instance.new("Part")
		wave.Name = "ClientAurora"
		wave.Size = Vector3.new(500, 50, 1)
		wave.CFrame = camera.CFrame * CFrame.new(0, 30 + i * 10, -100)
		wave.Anchored = true
		wave.CanCollide = false
		wave.CanTouch = false
		wave.CanQuery = false
		wave.Material = Enum.Material.Neon
		wave.Color = colors[math.random(1, #colors)]
		wave.Transparency = 0.8
		wave.Parent = Workspace
		wave:SetAttribute("WeatherEffect", true)
		table.insert(weatherEffects, wave)

		-- Animate
		local startPos = wave.Position
		TweenService:Create(wave, TweenInfo.new(4, Enum.EasingStyle.Sine, Enum.EasingDirection.InOut, -1, true), {
			Position = startPos + Vector3.new(math.sin(i) * 50, 0, math.cos(i) * 50),
			Transparency = 0.4,
		}):Play()
	end
end

function E.createVoidFog()
	local camera = Workspace.CurrentCamera
	if not camera then return end

	local emitter = Instance.new("ParticleEmitter")
	emitter.Name = "ClientVoidFog"
	emitter.Texture = "rbxassetid://241629423"
	emitter.Color = ColorSequence.new(Color3.fromRGB(30, 10, 50), Color3.fromRGB(60, 20, 90))
	emitter.Size = NumberSequence.new(4, 1)
	emitter.Lifetime = NumberRange.new(5, 12)
	emitter.Rate = 30
	emitter.Speed = NumberRange.new(0.3, 1.5)
	emitter.SpreadAngle = Vector2.new(360, 360)
	emitter.Drag = 0.2
	emitter.ZOffset = 1
	emitter.Parent = camera
	table.insert(weatherEffects, emitter)

	-- Color correction
	local cc = Instance.new("ColorCorrectionEffect")
	cc.Name = "VoidCorrection"
	cc.Saturation = -0.5
	cc.Contrast = 0.3
	cc.TintColor = Color3.fromRGB(80, 60, 100)
	cc.Parent = Lighting
	cc:SetAttribute("WeatherEffect", true)
	table.insert(weatherEffects, cc)
end

function E.setupDayNightSync()
	-- Sync with server time
	Run.Heartbeat:Connect(function()
		-- Client just follows server Lighting.ClockTime
		-- But we can add local visual enhancements
		local hour = Lighting.ClockTime

		-- Adjust local effects based on time
		if hour >= 20 or hour < 5 then
			-- Night: enhance lights
			E.enhanceNightLights()
		elseif hour >= 5 and hour < 7 then
			-- Dawn
			E.dawnEffects()
		elseif hour >= 18 and hour < 20 then
			-- Dusk
			E.duskEffects()
		end
	end)
end

function E.enhanceNightLights()
	-- Make neon parts glow more at night
	for _, obj in Workspace:GetDescendants() do
		if obj:IsA("BasePart") and obj.Material == Enum.Material.Neon then
			if not obj:GetAttribute("NightEnhanced") then
				obj:SetAttribute("OriginalBrightness", obj.Color)
				obj:SetAttribute("NightEnhanced", true)
			end
		end
	end
end

function E.dawnEffects()
	-- Morning mist
	if currentBiome and currentBiome.el == "Natureza" then
		local camera = Workspace.CurrentCamera
		if camera then
			local mist = Instance.new("ParticleEmitter")
			mist.Name = "DawnMist"
			mist.Texture = "rbxassetid://241629423"
			mist.Color = ColorSequence.new(Color3.fromRGB(200, 230, 200))
			mist.Size = NumberSequence.new(10, 2)
			mist.Lifetime = NumberRange.new(3, 6)
			mist.Rate = 10
			mist.Speed = NumberRange.new(0.5, 1)
			mist.SpreadAngle = Vector2.new(180, 180)
			mist.Drag = 0.1
			mist.ZOffset = 0.5
			mist.Parent = camera
			table.insert(weatherEffects, mist)
			game:GetService("Debris"):AddItem(mist, 300)
		end
	end
end

function E.duskEffects()
	-- Fireflies in nature biomes
	if currentBiome and currentBiome.el == "Natureza" then
		local camera = Workspace.CurrentCamera
		if camera then
			for i = 1, 20 do
				local fly = Instance.new("Part")
				fly.Name = "Firefly"
				fly.Size = Vector3.new(0.2, 0.2, 0.2)
				fly.Shape = Enum.PartType.Ball
				fly.CFrame = camera.CFrame * CFrame.new(
					math.random(-30, 30),
					math.random(2, 15),
					math.random(-30, 30)
				)
				fly.Anchored = true
				fly.CanCollide = false
				fly.Material = Enum.Material.Neon
				fly.Color = Color3.fromRGB(255, 255, 150)
				fly.Parent = Workspace
				table.insert(weatherEffects, fly)

				-- Animate
				task.spawn(function()
					local phase = math.random() * math.pi * 2
					while fly.Parent do
						fly.CFrame = fly.CFrame * CFrame.new(
							math.sin(phase) * 0.1,
							math.cos(phase * 0.7) * 0.05,
							math.cos(phase) * 0.1
						)
						fly.Transparency = 0.2 + math.abs(math.sin(phase * 2)) * 0.6
						phase += 0.1
						task.wait(0.05)
					end
				end)

				game:GetService("Debris"):AddItem(fly, 600)
			end
		end
	end
end

function E.setupLOD()
	-- Initial scan
	task.defer(E.scanForArtObjects)
end

function E.scanForArtObjects()
	local quality = E.getQuality()

	-- Scan Arquipelago and Santuarios
	for _, name in { "Arquipelago", "Santuarios" } do
		local root = Workspace:FindFirstChild(name)
		if root then
			for _, obj in root:GetDescendants() do
				if obj:IsA("BasePart") and obj:GetAttribute("ArtMotion") and not records[obj] then
					records[obj] = {
						cf = obj.CFrame,
						transparency = obj.Transparency,
						kind = obj:GetAttribute("ArtMotion"),
						phase = obj:GetAttribute("ArtPhase") or 0,
					}
				end
			end
		end
	end
end

local elapsed = 0
local scanTimer = 0

function E.onRenderStep(dt)
	elapsed += dt
	scanTimer += dt

	local quality = E.getQuality()
	local reduced = E.isMotionReduced()

	-- Periodic rescan for new objects
	if scanTimer >= 1 then
		scanTimer = 0
		E.scanForArtObjects()
	end

	-- Throttle updates
	if elapsed < 1 / 15 then return end
	elapsed = 0

	local camera = Workspace.CurrentCamera
	if not camera then return end

	local candidates = {}

	for part, record in records do
		if not part.Parent then
			records[part] = nil
			continue
		end

		local distance = (record.cf.Position - camera.CFrame.Position).Magnitude

		-- Check LOD distance
		local maxDist = record.kind == "water" and quality.particleDistance or quality.animationDistance

		if reduced or quality == "Baixo" or distance > maxDist then
			if record.active then
				part.CFrame = record.cf
				part.Transparency = record.transparency
				record.active = false
			end
		else
			table.insert(candidates, { part = part, record = record, distance = distance })
		end
	end

	-- Sort by distance (closest first)
	table.sort(candidates, function(a, b)
		return a.distance < b.distance
	end)

	-- Limit active animations
	local limit = quality.maxAnimatedParts
	local time = os.clock()

	for index, item in candidates do
		local p, r = item.part, item.record

		if index > limit then
			if r.active then
				p.CFrame = r.cf
				p.Transparency = r.transparency
				r.active = false
			end
			continue
		end

		r.active = true
		local phase = time + r.phase

		if r.kind == "grass" then
			p.CFrame = r.cf * CFrame.Angles(0, 0, math.sin(phase * 2) * 0.1)
		elseif r.kind == "leaf" then
			p.CFrame = r.cf * CFrame.Angles(0.02 * math.sin(phase), 0, 0.025 * math.sin(phase * 1.3))
		elseif r.kind == "cloud" then
			p.CFrame = r.cf * CFrame.new(0, math.sin(phase * 0.7) * 0.15, 0)
		elseif r.kind == "water" then
			p.CFrame = r.cf * CFrame.new(math.sin(phase * 0.6) * 0.3, 0, 0)
			p.Transparency = math.clamp(r.transparency + math.sin(phase) * 0.1, 0, 0.8)
		elseif r.kind == "spark" then
			p.CFrame = r.cf * CFrame.new(0, math.sin(phase * 1.3) * 0.25, 0)
			p.Transparency = 0.12 + math.abs(math.sin(phase)) * 0.25
		end
	end
end

-- Public API
E.dress = function(character)
	-- Exposed for external use
end

-- Quality change handler
LocalPlayer:GetAttributeChangedSignal("GraphicsQuality"):Connect(function()
	-- Re-scan with new quality
	records = setmetatable({}, { __mode = "k" })
	E.scanForArtObjects()
end)

LocalPlayer:GetAttributeChangedSignal("MotionReduced"):Connect(function()
	records = setmetatable({}, { __mode = "k" })
	E.scanForArtObjects()
end)

-- Cleanup on respawn
LocalPlayer.CharacterAdded:Connect(function()
	task.wait(1)
	E.scanForArtObjects()
end)

return E