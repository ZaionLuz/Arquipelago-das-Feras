--!strict
-- BattleAnimator.luau - Synchronized battle animations with Blender model support
-- Handles attack, damage, faint, status, and special animations

local RS = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")

local Art = require(RS.Shared.ArtTokens)
local Elements = require(RS.Shared.Elements)
local Moves = require(RS.Shared.Moves)
local BlenderModels = require(RS.Shared.BlenderModels)
local CreatureAnimator = require(script.Parent.CreatureAnimator)

local Animator = {}

export type AnimationTrack = {
	name: string,
	duration: number,
	priority: Enum.AnimationPriority,
	looped: boolean,
	events: { [number]: string }, -- time -> event name
}

export type BattleAnimation = {
	attacker: Model,
	defender: Model?,
	moveId: string,
	moveData: Moves.MoveData,
	hitConfirm: (() -> ())?,
	onComplete: (() -> ())?,
}

-- Animation configurations per move category
local ANIMATION_CONFIGS = {
	physical = {
		windup = 0.15,
		active = 0.1,
		recovery = 0.2,
		approachDistance = 4,
		hitPause = 0.08,
		screenShake = 0.3,
	},
	special = {
		windup = 0.2,
		active = 0.3,
		recovery = 0.25,
		approachDistance = 0, -- Projectile based
		hitPause = 0.1,
		screenShake = 0.15,
	},
	status = {
		windup = 0.1,
		active = 0.15,
		recovery = 0.15,
		approachDistance = 0,
		hitPause = 0.05,
		screenShake = 0,
	},
}

-- Element-specific visual effects
local ELEMENT_EFFECTS = {
	Fogo = { color = Art.Ramps.Fogo[4], particle = "Fire", sound = "rbxassetid://sfx_fire" },
	Água = { color = Art.Ramps.Água[4], particle = "Water", sound = "rbxassetid://sfx_water" },
	Natureza = { color = Art.Ramps.Natureza[4], particle = "Leaves", sound = "rbxassetid://sfx_grass" },
	Terra = { color = Art.Ramps.Terra[4], particle = "Rocks", sound = "rbxassetid://sfx_earth" },
	Ar = { color = Art.Ramps.Ar[4], particle = "Wind", sound = "rbxassetid://sfx_wind" },
	Sombra = { color = Art.Ramps.Sombra[4], particle = "Darkness", sound = "rbxassetid://sfx_shadow" },
	Gelo = { color = Art.Ramps.Gelo[4], particle = "Ice", sound = "rbxassetid://sfx_ice" },
	Elétrico = { color = Art.Ramps.Elétrico[4], particle = "Sparks", sound = "rbxassetid://sfx_electric" },
	Luz = { color = Art.Ramps.Luz[4], particle = "Light", sound = "rbxassetid://sfx_light" },
	Metal = { color = Art.Ramps.Metal[4], particle = "MetalShards", sound = "rbxassetid://sfx_metal" },
	Cristal = { color = Art.Ramps.Cristal[4], particle = "Crystals", sound = "rbxassetid://sfx_crystal" },
	Arcano = { color = Art.Ramps.Arcano[4], particle = "Void", sound = "rbxassetid://sfx_arcane" },
	Normal = { color = Art.Ramps.Metal[3], particle = "Impact", sound = "rbxassetid://sfx_normal" },
}

-- Animation state tracking
local activeAnimations: { [Model]: { [string]: RBXScriptConnection } } = {}
local animationQueue: { BattleAnimation } = {}
local isProcessing = false

function Animator.playBattleAnimation(animData: BattleAnimation)
	table.insert(animationQueue, animData)
	if not isProcessing then
		task.spawn(Animator.processQueue)
	end
end

function Animator.processQueue()
	isProcessing = true
	while #animationQueue > 0 do
		local anim = table.remove(animationQueue, 1)
		Animator.executeAnimation(anim)
		task.wait(0.1) -- Small gap between animations
	end
	isProcessing = false
end

function Animator.executeAnimation(anim: BattleAnimation)
	local config = ANIMATION_CONFIGS[anim.moveData.category] or ANIMATION_CONFIGS.physical
	local element = anim.moveData.element
	local effect = ELEMENT_EFFECTS[element] or ELEMENT_EFFECTS.Normal

	-- Phase 1: Windup (attacker prepares)
	Animator.playWindup(anim.attacker, config.windup, element)

	task.wait(config.windup)

	-- Phase 2: Approach (for physical moves)
	if config.approachDistance > 0 and anim.defender then
		Animator.playApproach(anim.attacker, anim.defender, config.approachDistance, config.active)
		task.wait(config.active * 0.5)
	end

	-- Phase 3: Attack execution
	Animator.playAttack(anim.attacker, anim.moveData, element, config.active)

	-- Phase 4: Projectile/Effect travel (for special moves)
	if anim.moveData.category == "special" and anim.defender then
		Animator.playProjectile(anim.attacker, anim.defender, element, effect, config.active)
		task.wait(config.active)
	else
		task.wait(config.active)
	end

	-- Phase 5: Hit confirmation
	if anim.hitConfirm then
		anim.hitConfirm()
	end

	-- Phase 6: Hit reaction on defender
	if anim.defender then
		Animator.playHitReaction(anim.defender, element, config.hitPause, config.screenShake)
		task.wait(config.hitPause)
	end

	-- Phase 7: Recovery
	Animator.playRecovery(anim.attacker, config.recovery)

	task.wait(config.recovery)

	if anim.onComplete then
		anim.onComplete()
	end
end

function Animator.playWindup(model: Model, duration: number, element: string)
	CreatureAnimator.play(model, "attack", duration * 2) -- Anticipation pose

	-- Elemental charge effect
	local effect = ELEMENT_EFFECTS[element] or ELEMENT_EFFECTS.Normal
	Animator.createChargeEffect(model, effect.color, duration)
end

function Animator.createChargeEffect(model: Model, color: Color3, duration: number)
	local root = model.PrimaryPart or model:FindFirstChild("Root")
	if not root then return end

	local attachment = Instance.new("Attachment")
	attachment.Name = "ChargeEffect"
	attachment.Position = Vector3.new(0, 2, 2)
	attachment.Parent = root

	local particles = Instance.new("ParticleEmitter")
	particles.Name = "ChargeParticles"
	particles.Color = ColorSequence.new(color)
	particles.Size = NumberSequence.new(0.5, 0)
	particles.Lifetime = NumberRange.new(0.3, 0.6)
	particles.Rate = 30
	particles.Speed = 2
	particles.SpreadAngle = Vector2.new(45, 45)
	particles.Drag = 0.5
	particles.Parent = attachment

	task.delay(duration, function()
		if attachment.Parent then
			attachment:Destroy()
		end
	end)
end

function Animator.playApproach(attacker: Model, defender: Model, distance: number, duration: number)
	local attackerRoot = attacker.PrimaryPart
	local defenderRoot = defender.PrimaryPart
	if not attackerRoot or not defenderRoot then return end

	local startPos = attackerRoot.Position
	local direction = (defenderRoot.Position - startPos).Unit
	local targetPos = startPos + direction * distance

	local tween = TweenService:Create(attackerRoot, TweenInfo.new(duration * 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		CFrame = CFrame.new(targetPos, defenderRoot.Position)
	})
	tween:Play()

	-- Return tween
	task.delay(duration * 0.5, function()
		local returnTween = TweenService:Create(attackerRoot, TweenInfo.new(duration * 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.In), {
			CFrame = CFrame.new(startPos, defenderRoot.Position)
		})
		returnTween:Play()
	end)
end

function Animator.playAttack(model: Model, moveData: Moves.MoveData, element: string, duration: number)
	CreatureAnimator.play(model, "attack", duration)

	-- Play move-specific animation if available
	local animId = Moves.Animations[moveData.id]
	if animId then
		Animator.playKeyframeAnimation(model, animId, duration)
	end

	-- Elemental slash/projectile effect at attack point
	local effect = ELEMENT_EFFECTS[element] or ELEMENT_EFFECTS.Normal
	Animator.createAttackEffect(model, effect, moveData.category)
end

function Animator.playKeyframeAnimation(model: Model, animationId: string, duration: number)
	local humanoid = model:FindFirstChildOfClass("Humanoid")
	if not humanoid then return end

	local animator = humanoid:FindFirstChildOfClass("Animator")
	if not animator then
		animator = Instance.new("Animator")
		animator.Parent = humanoid
	end

	local animation = Instance.new("Animation")
	animation.AnimationId = animationId
	local track = animator:LoadAnimation(animation)
	track.Priority = Enum.AnimationPriority.Action
	track:Play()
	track:AdjustSpeed(track.Length / duration)
end

function Animator.createAttackEffect(model: Model, effect: any, category: string)
	local root = model.PrimaryPart
	if not root then return end

	if category == "physical" then
		-- Slash effect at weapon/limb position
		local slash = Instance.new("Part")
		slash.Name = "SlashEffect"
		slash.Size = Vector3.new(0.1, 4, 4)
		slash.CFrame = root.CFrame * CFrame.new(0, 1, 3) * CFrame.Angles(0, math.rad(90), 0)
		slash.Color = effect.color
		slash.Material = Enum.Material.Neon
		slash.Transparency = 0.2
		slash.Anchored = true
		slash.CanCollide = false
		slash.CanQuery = false
		slash.CanTouch = false
		slash.Parent = workspace

		TweenService:Create(slash, TweenInfo.new(0.2), { Size = Vector3.new(0.1, 8, 8), Transparency = 1 }):Play()
		game:GetService("Debris"):AddItem(slash, 0.3)
	else
		-- Projectile spawn effect
		local orb = Instance.new("Part")
		orb.Name = "ProjectileSpawn"
		orb.Shape = Enum.PartType.Ball
		orb.Size = Vector3.new(1, 1, 1)
		orb.CFrame = root.CFrame * CFrame.new(0, 1.5, 2)
		orb.Color = effect.color
		orb.Material = Enum.Material.Neon
		orb.Anchored = true
		orb.CanCollide = false
		orb.Parent = workspace

		TweenService:Create(orb, TweenInfo.new(0.15), { Size = Vector3.new(0.2, 0.2, 0.2), Transparency = 1 }):Play()
		game:GetService("Debris"):AddItem(orb, 0.2)
	end
end

function Animator.playProjectile(attacker: Model, defender: Model, element: string, effect: any, duration: number)
	local attackerRoot = attacker.PrimaryPart
	local defenderRoot = defender.PrimaryPart
	if not attackerRoot or not defenderRoot then return end

	local startPos = attackerRoot.Position + Vector3.new(0, 2, 2)
	local endPos = defenderRoot.Position + Vector3.new(0, 1, 0)

	local projectile = Instance.new("Part")
	projectile.Name = "Projectile_" .. element
	projectile.Shape = Enum.PartType.Ball
	projectile.Size = Vector3.new(1.5, 1.5, 1.5)
	projectile.CFrame = CFrame.new(startPos, endPos)
	projectile.Color = effect.color
	projectile.Material = Enum.Material.Neon
	projectile.Anchored = true
	projectile.CanCollide = false
	projectile.CanQuery = false
	projectile.CanTouch = false
	projectile.Parent = workspace

	-- Add trail
	local attachment0 = Instance.new("Attachment")
	attachment0.Position = Vector3.new(0, 0.2, 0)
	attachment0.Parent = projectile
	local attachment1 = Instance.new("Attachment")
	attachment1.Position = Vector3.new(0, -0.2, 0)
	attachment1.Parent = projectile

	local trail = Instance.new("Trail")
	trail.Attachment0 = attachment0
	trail.Attachment1 = attachment1
	trail.Color = ColorSequence.new(effect.color)
	trail.Lifetime = 0.3
	trail.MinLength = 0.5
	trail.Parent = projectile

	-- Animate projectile
	local tween = TweenService:Create(projectile, TweenInfo.new(duration, Enum.EasingStyle.Quad), {
		CFrame = CFrame.new(endPos)
	})
	tween:Play()

	tween.Completed:Connect(function()
		-- Impact effect
		Animator.createImpactEffect(endPos, effect)
		projectile:Destroy()
	end)
end

function Animator.createImpactEffect(position: Vector3, effect: any)
	local impact = Instance.new("Part")
	impact.Name = "ImpactEffect"
	impact.Shape = Enum.PartType.Ball
	impact.Size = Vector3.new(0.5, 0.5, 0.5)
	impact.Position = position
	impact.Color = effect.color
	impact.Material = Enum.Material.Neon
	impact.Anchored = true
	impact.CanCollide = false
	impact.Parent = workspace

	TweenService:Create(impact, TweenInfo.new(0.4, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = Vector3.new(6, 6, 6),
		Transparency = 1
	}):Play()

	-- Particle burst
	local attachment = Instance.new("Attachment")
	attachment.Position = position
	attachment.Parent = workspace.Terrain

	local particles = Instance.new("ParticleEmitter")
	particles.Color = ColorSequence.new(effect.color)
	particles.Size = NumberSequence.new(1, 0)
	particles.Lifetime = NumberRange.new(0.3, 0.8)
	particles.Rate = 0
	particles.Speed = 5
	particles.SpreadAngle = Vector2.new(180, 180)
	particles.Drag = 0.5
	particles.Parent = attachment
	particles:Emit(20)

	game:GetService("Debris"):AddItem(attachment, 1)
	game:GetService("Debris"):AddItem(impact, 0.5)
end

function Animator.playHitReaction(model: Model, element: string, hitPause: number, screenShake: number)
	CreatureAnimator.play(model, "damage", hitPause * 2)

	-- Flash effect
	local body = model:FindFirstChild("Body")
	if body and body:IsA("BasePart") then
		local originalColor = body.Color
		local flashColor = ELEMENT_EFFECTS[element] and ELEMENT_EFFECTS[element].color or Color3.new(1, 1, 1)

		local tween = TweenService:Create(body, TweenInfo.new(hitPause, Enum.EasingStyle.Quad), { Color = flashColor })
		tween:Play()
		tween.Completed:Connect(function()
			TweenService:Create(body, TweenInfo.new(hitPause), { Color = originalColor }):Play()
		end)
	end

	-- Screen shake (client-side only)
	if screenShake > 0 then
		Animator.screenShake(screenShake)
	end

	-- Damage number popup
	Animator.showDamageNumber(model, "-", element)
end

function Animator.playRecovery(model: Model, duration: number)
	CreatureAnimator.play(model, "idle", duration)
end

function Animator.playFaint(model: Model, duration: number)
	CreatureAnimator.play(model, "faint", duration)

	-- Fade out effect
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") then
			TweenService:Create(part, TweenInfo.new(duration), { Transparency = 1 }):Play()
		end
	end

	-- Soul particle effect
	local root = model.PrimaryPart
	if root then
		local attachment = Instance.new("Attachment")
		attachment.Parent = root

		local particles = Instance.new("ParticleEmitter")
		particles.Color = ColorSequence.new(Color3.fromRGB(200, 200, 255))
		particles.Size = NumberSequence.new(0.5, 0)
		particles.Lifetime = NumberRange.new(1, 2)
		particles.Rate = 10
		particles.Speed = 2
		particles.SpreadAngle = Vector2.new(180, 180)
		particles.Drag = 0.2
		particles.Parent = attachment

		task.delay(duration, function()
			attachment:Destroy()
		end)
	end
end

function Animator.playVictory(model: Model, duration: number)
	CreatureAnimator.play(model, "victory", duration)
end

function Animator.playStatusEffect(model: Model, status: string, duration: number)
	local effectConfig = {
		burn = { color = Art.Ramps.Fogo[4], particles = "Fire" },
		freeze = { color = Art.Ramps.Gelo[4], particles = "Ice" },
		paralyze = { color = Art.Ramps.Elétrico[4], particles = "Sparks" },
		poison = { color = Art.Ramps.Natureza[4], particles = "Poison" },
		sleep = { color = Art.Ramps.Arcano[4], particles = "Sleep" },
		confuse = { color = Art.Ramps.Sombra[4], particles = "Confuse" },
		fear = { color = Art.Ramps.Sombra[3], particles = "Fear" },
		curse = { color = Art.Ramps.Arcano[3], particles = "Curse" },
		bless = { color = Art.Ramps.Luz[4], particles = "Bless" },
	}

	local config = effectConfig[status]
	if not config then return end

	local root = model.PrimaryPart
	if not root then return end

	local attachment = Instance.new("Attachment")
	attachment.Name = "StatusEffect_" .. status
	attachment.Parent = root

	local particles = Instance.new("ParticleEmitter")
	particles.Name = "StatusParticles"
	particles.Color = ColorSequence.new(config.color)
	particles.Size = NumberSequence.new(0.3, 0)
	particles.Lifetime = NumberRange.new(0.5, 1)
	particles.Rate = 5
	particles.Speed = 1
	particles.SpreadAngle = Vector2.new(90, 90)
	particles.Drag = 0.3
	particles.Parent = attachment

	-- Status icon above head
	local billboard = Instance.new("BillboardGui")
	billboard.Name = "StatusIcon_" .. status
	billboard.Size = UDim2.fromOffset(32, 32)
	billboard.StudsOffset = Vector3.new(0, 4, 0)
	billboard.MaxDistance = 100
	billboard.Parent = root

	local icon = Instance.new("ImageLabel")
	icon.Size = UDim2.fromScale(1, 1)
	icon.BackgroundTransparency = 1
	icon.Image = "rbxassetid://status_" .. status -- Placeholder
	icon.Parent = billboard

	if duration > 0 then
		task.delay(duration, function()
			if attachment.Parent then attachment:Destroy() end
			if billboard.Parent then billboard:Destroy() end
		end)
	end
end

function Animator.removeStatusEffect(model: Model, status: string)
	local root = model.PrimaryPart
	if not root then return end

	local attachment = root:FindFirstChild("StatusEffect_" .. status)
	if attachment then attachment:Destroy() end

	local billboard = root:FindFirstChild("StatusIcon_" .. status)
	if billboard then billboard:Destroy() end
end

function Animator.playAscension(model: Model, duration: number)
	-- Legendary Ascension (Mega Evolution equivalent) animation
	local root = model.PrimaryPart
	if not root then return end

	-- Intense light buildup
	local light = Instance.new("PointLight")
	light.Name = "AscensionLight"
	light.Color = Color3.fromRGB(255, 255, 200)
	light.Range = 0
	light.Brightness = 0
	light.Parent = root

	TweenService:Create(light, TweenInfo.new(duration * 0.5), { Range = 30, Brightness = 5 }):Play()

	-- Particle vortex
	local attachment = Instance.new("Attachment")
	attachment.Parent = root

	local particles = Instance.new("ParticleEmitter")
	particles.Color = ColorSequence.new(Color3.fromRGB(255, 255, 200), Color3.fromRGB(255, 150, 50))
	particles.Size = NumberSequence.new(1, 0)
	particles.Lifetime = NumberRange.new(1, 2)
	particles.Rate = 50
	particles.Speed = 10
	particles.SpreadAngle = Vector2.new(180, 180)
	particles.Drag = 0.5
	particles.Parent = attachment

	-- Model scale up
	local originalScale = model:GetScale()
	TweenService:Create(model, TweenInfo.new(duration, Enum.EasingStyle.Back, Enum.EasingDirection.Out), {
		Scale = originalScale * 1.3
	}):Play()

	-- Rotation
	local spinTween = TweenService:Create(root, TweenInfo.new(duration, Enum.EasingStyle.Linear), {
		CFrame = root.CFrame * CFrame.Angles(0, math.pi * 4, 0)
	})
	spinTween:Play()

	-- Shockwave
	task.delay(duration * 0.5, function()
		local wave = Instance.new("Part")
		wave.Name = "AscensionWave"
		wave.Shape = Enum.PartType.Cylinder
		wave.Size = Vector3.new(0.2, 1, 1)
		wave.CFrame = root.CFrame * CFrame.Angles(math.pi/2, 0, 0)
		wave.Color = Color3.fromRGB(255, 255, 200)
		wave.Material = Enum.Material.Neon
		wave.Transparency = 0.3
		wave.Anchored = true
		wave.CanCollide = false
		wave.Parent = workspace

		TweenService:Create(wave, TweenInfo.new(duration * 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
			Size = Vector3.new(0.2, 30, 30),
			Transparency = 1
		}):Play()

		game:GetService("Debris"):AddItem(wave, duration * 0.5)
	end)

	task.delay(duration, function()
		if light.Parent then light:Destroy() end
		if attachment.Parent then attachment:Destroy() end
	end)
end

function Animator.playCapture(model: Model, success: boolean, duration: number)
	if success then
		-- Successful capture - beam up effect
		local root = model.PrimaryPart
		if root then
			local beam = Instance.new("Beam")
			beam.Color = ColorSequence.new(Color3.fromRGB(100, 200, 255))
			beam.Width0 = 2
			beam.Width1 = 0.5
			beam.LightEmission = 1
			beam.LightInfluence = 0

			local attachment0 = Instance.new("Attachment")
			attachment0.Position = Vector3.new(0, 2, 0)
			attachment0.Parent = root

			local attachment1 = Instance.new("Attachment")
			attachment1.Position = Vector3.new(0, 20, 0)
			attachment1.Parent = workspace.Terrain

			beam.Attachment0 = attachment0
			beam.Attachment1 = attachment1
			beam.Parent = attachment0

			TweenService:Create(model, TweenInfo.new(duration), { CFrame = root.CFrame + Vector3.new(0, 20, 0) }):Play()

			task.delay(duration, function()
				attachment0:Destroy()
				attachment1:Destroy()
			end)
		end
	else
		-- Failed capture - seal breaks
		Animator.createSealBreakEffect(model)
	end
end

function Animator.createSealBreakEffect(model: Model)
	local root = model.PrimaryPart
	if not root then return end

	for i = 1, 8 do
		local angle = i * math.pi / 4
		local shard = Instance.new("Part")
		shard.Size = Vector3.new(0.5, 1, 0.3)
		shard.CFrame = root.CFrame * CFrame.new(math.cos(angle) * 3, 2, math.sin(angle) * 3) * CFrame.Angles(0, angle, 0)
		shard.Color = Color3.fromRGB(200, 200, 100)
		shard.Material = Enum.Material.Glass
		shard.Anchored = true
		shard.CanCollide = false
		shard.Parent = workspace

		local velocity = Vector3.new(math.cos(angle) * 10, 10, math.sin(angle) * 10)
		local bodyVelocity = Instance.new("BodyVelocity")
		bodyVelocity.Velocity = velocity
		bodyVelocity.MaxForce = Vector3.new(1e5, 1e5, 1e5)
		bodyVelocity.Parent = shard

		game:GetService("Debris"):AddItem(shard, 2)
	end
end

function Animator.showDamageNumber(model: Model, text: string, element: string)
	local root = model.PrimaryPart
	if not root then return end

	local billboard = Instance.new("BillboardGui")
	billboard.Name = "DamageNumber"
	billboard.Size = UDim2.fromOffset(100, 50)
	billboard.StudsOffset = Vector3.new(math.random(-2, 2), 3, 0)
	billboard.MaxDistance = 150
	billboard.Parent = root

	local label = Instance.new("TextLabel")
	label.Size = UDim2.fromScale(1, 1)
	label.BackgroundTransparency = 1
	label.Text = text
	label.TextSize = 28
	label.Font = Art.Font
	label.TextColor3 = ELEMENT_EFFECTS[element] and ELEMENT_EFFECTS[element].color or Color3.new(1, 1, 1)
	label.TextStrokeTransparency = 0
	label.TextStrokeColor3 = Color3.new(0, 0, 0)
	label.Parent = billboard

	TweenService:Create(label, TweenInfo.new(0.8, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Position = UDim2.fromScale(0, -1),
		TextTransparency = 1,
		TextStrokeTransparency = 1
	}):Play()

	game:GetService("Debris"):AddItem(billboard, 1)
end

function Animator.screenShake(intensity: number)
	local camera = workspace.CurrentCamera
	if not camera then return end

	local originalCFrame = camera.CFrame
	local shakeTime = 0.3
	local elapsed = 0

	local connection
	connection = RunService.RenderStepped:Connect(function(dt)
		elapsed += dt
		if elapsed >= shakeTime then
			camera.CFrame = originalCFrame
			connection:Disconnect()
			return
		end

		local progress = elapsed / shakeTime
		local currentIntensity = intensity * (1 - progress)
		local offset = Vector3.new(
			math.random(-currentIntensity, currentIntensity),
			math.random(-currentIntensity, currentIntensity),
			math.random(-currentIntensity, currentIntensity)
		)
		camera.CFrame = originalCFrame * CFrame.new(offset)
	end)
end

-- Preload animations for performance
function Animator.preloadAnimations()
	local animationIds = {}
	for _, id in Moves.Animations do
		if not table.find(animationIds, id) then
			table.insert(animationIds, id)
		end
	end

	for _, animId in animationIds do
		game:GetService("ContentProvider"):PreloadAsync({ animId })
	end
end

-- Batch play for double battles / horde battles
function Animator.playBatchAnimations(animations: { BattleAnimation })
	for _, anim in animations do
		Animator.playBattleAnimation(anim)
	end
end

-- Cancel all animations for a model
function Animator.cancelAnimations(model: Model)
	local connections = activeAnimations[model]
	if connections then
		for _, conn in connections do
			conn:Disconnect()
		end
		activeAnimations[model] = nil
	end

	CreatureAnimator.play(model, "idle", 0.1)
end

return Animator