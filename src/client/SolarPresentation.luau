--!nonstrict
local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local Run = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local TS = game:GetService("TweenService")
local I = require(RS.Shared.Islands)
local Config = require(RS.Shared.Config)
local Theme = require(script.Parent.UITheme)
local Art = require(RS.Shared.ArtTokens)
local Solar = {}
local started = false
function Solar.start(getSnapshot)
	if started then
		return
	end
	started = true
	local elapsed = 0
	local correction
	local atmosphere
	local priorAtmosphere
	local priorClock
	local ambientSound
	local center = I.pos(I.ById.Dunas.idx) + Vector3.new(0, 4, -23)
	Run.Heartbeat:Connect(function(dt)
		elapsed += dt
		if elapsed < 0.25 then
			return
		end
		elapsed = 0
		local p = Players.LocalPlayer
		local hrp = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		local snapshot = getSnapshot()
		local discovered = snapshot and snapshot.quest and snapshot.quest.stage >= 3
		local inside = discovered
			and hrp
			and math.abs(hrp.Position.X - center.X) < 16
			and math.abs(hrp.Position.Z - center.Z) < 13
			and math.abs(hrp.Position.Y - center.Y) < 12
		local ruins = workspace:FindFirstChild("RuinasAntigas")
		if ruins then
			local gate = ruins:FindFirstChild("LajeSelada")
			if gate then
				gate.LocalTransparencyModifier = discovered and 1 or 0
			end
			local altar = ruins:FindFirstChild("PedraCentral")
			local prompt = altar and altar:FindFirstChildOfClass("ProximityPrompt")
			if prompt then
				prompt.ActionText = discovered and Text.OFERECER_CHAMA_E43EFE or Text.EXAMINAR_F96563
				local q = snapshot and snapshot.quest
				local left = q and q.nextAttemptAt and math.max(0, q.nextAttemptAt - workspace:GetServerTimeNow()) or 0
				prompt.ObjectText = q and q.captured and Text.ALTAR_EM_REPOUSO_64BE88
					or left > 0 and (Text.REPOUSO_056AEB .. math.ceil(left) .. "s")
					or Text.PEDRA_ANTIGA_ACE013
			end
		end
		local enabled = inside and p:GetAttribute("GraphicsQuality") ~= Text.BAIXO_74FD00
		if enabled and not correction then
			correction = Instance.new("ColorCorrectionEffect")
			correction.Name = "TonalidadeLocal"
			correction.TintColor = Art.Ramps.Sand[5]
			correction.Saturation = 0.1
			correction.Contrast = 0.06
			correction.Parent = Lighting
			priorClock = Lighting.ClockTime
			Lighting.ClockTime = 17.5
			atmosphere = Lighting:FindFirstChildOfClass("Atmosphere") or Instance.new("Atmosphere")
			priorAtmosphere = { Color = atmosphere.Color, Density = atmosphere.Density, Haze = atmosphere.Haze }
			atmosphere.Color = Art.Ramps.Sand[4]
			atmosphere.Density = 0.26
			atmosphere.Haze = 1.8
			atmosphere.Parent = Lighting
			if Config.Assets.SolarAmbience ~= "" then
				ambientSound = Instance.new("Sound")
				ambientSound.SoundId = Config.Assets.SolarAmbience
				ambientSound.Looped = true
				ambientSound.Volume = 0.2
				ambientSound.Parent = game:GetService("SoundService")
				ambientSound:Play()
			end
		elseif not enabled and correction then
			correction:Destroy()
			correction = nil
			for key, value in priorAtmosphere do
				atmosphere[key] = value
			end
			Lighting.ClockTime = priorClock
			atmosphere = nil
			priorAtmosphere = nil
			if ambientSound then
				ambientSound:Destroy()
				ambientSound = nil
			end
		end
	end)
end
-- A câmera usada é a do Viewport: nunca toma o controle da câmera do jogador.
function Solar.intro(panel, viewport, model, alive)
	local cam = viewport.CurrentCamera
	local original = cam.CFrame
	local initial = model:GetPivot()
	local parts = {}
	local card = Theme.label(panel, Text.FENIX_LENDARIA_NV_60_A1FE17, 22)
	card.Size = UDim2.new(0.94, 0, 0, 54)
	card.Position = UDim2.fromScale(0.03, 0.25)
	card.ZIndex = 70
	card.TextColor3 = Theme.Accent
	local motion = not Players.LocalPlayer:GetAttribute("MotionReduced")
	local ok, err = pcall(function()
		if motion then
			model:PivotTo(initial + Vector3.new(0, 20, 0))
			cam.CFrame = original * CFrame.new(0, 1, -5)
			local start = os.clock()
			repeat
				if not alive() or not model.Parent or not viewport.Parent then
					return
				end
				local t = math.clamp((os.clock() - start) / 1.1, 0, 1)
				model:PivotTo(initial + Vector3.new(0, (1 - t) ^ 2 * 20, 0))
				cam.CFrame = original:Lerp(original * CFrame.new(0, 1, -5), math.sin(t * math.pi) * 0.5)
				Run.Heartbeat:Wait()
			until os.clock() - start >= 1.1
			model:PivotTo(initial)
			if Players.LocalPlayer:GetAttribute("GraphicsQuality") ~= Text.BAIXO_74FD00 then
				local ring = Instance.new("Part")
				ring.Name = "OndaLocal"
				ring.Shape = Enum.PartType.Cylinder
				ring.CFrame = initial * CFrame.Angles(0, 0, math.pi / 2)
				ring.Size = Vector3.new(0.1, 3, 3)
				ring.Material = Enum.Material.Neon
				ring.Color = Theme.Accent
				ring.Anchored = true
				ring.CanCollide = false
				ring.CanTouch = false
				ring.CanQuery = false
				ring.Parent = model.Parent
				table.insert(parts, ring)
				local light = Instance.new("PointLight")
				light.Brightness = 1
				light.Range = 16
				light.Color = Theme.Accent
				light.Parent = model.PrimaryPart
				table.insert(parts, light)
				TS:Create(ring, TweenInfo.new(0.6), { Size = Vector3.new(0.1, 25, 25), Transparency = 1 }):Play()
			end
		end
		if Config.Assets.PhoenixIntro ~= "" then
			local sound = Instance.new("Sound")
			sound.SoundId = Config.Assets.PhoenixIntro
			sound.Volume = 0.4
			sound.Parent = panel
			sound:Play()
			table.insert(parts, sound)
		end
		task.wait(0.6)
	end)
	if cam.Parent then
		cam.CFrame = original
	end
	if model.Parent then
		model:PivotTo(initial)
	end
	card:Destroy()
	for _, part in parts do
		part:Destroy()
	end
	if not ok then
		warn(Text.APRESENTACAO_INTERROMPIDA_310A92 .. tostring(err))
	end
end
return Solar
