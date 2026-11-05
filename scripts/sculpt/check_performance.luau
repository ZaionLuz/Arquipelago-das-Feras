-- Scheduler and adaptive decisions with simulated services/native maths; no FPS benchmark.
local Loader = require("../loader")
local rb = require("@lune/roblox")
local P = Loader.load("src/shared/CreaturePerformance.luau")
local V = rb.Vector3.new
local function clone(value)
	if type(value) ~= "table" then
		return value
	end
	local result = {}
	for key, entry in value do
		result[key] = clone(entry)
	end
	return result
end
local function equal(a, b)
	if type(a) ~= type(b) then
		return false
	end
	if type(a) ~= "table" then
		return a == b
	end
	for k, v in a do
		if not equal(v, b[k]) then
			return false
		end
	end
	for k in b do
		if a[k] == nil then
			return false
		end
	end
	return true
end
local function feed(state, seconds, dt, quality, changes)
	for _ = 1, math.floor(seconds / dt + 0.5) do
		local changed = P.step(state, dt, quality)
		if changed ~= nil then
			table.insert(changes, changed)
		end
	end
end
local function triggered()
	local state, changes = P.new(), {}
	feed(state, 15, 1 / 60, "Médio", changes)
	assert(#changes == 0, "Warmup changed detail")
	feed(state, 9, 1 / 20, "Médio", changes)
	assert(#changes == 1 and changes[1] == true, "Sustained slow frames did not reduce detail")
	return state, changes
end
local state, changes = triggered()
feed(state, 12, 1 / 60, "Médio", changes)
assert(#changes == 1, "Detail restored before cooldown")
feed(state, 26, 1 / 60, "Médio", changes)
assert(#changes == 2 and changes[2] == false, "Stable fast frames did not restore detail")
feed(state, 40, 1 / 42, "Médio", changes)
assert(#changes == 2, "Normal frame variance caused oscillation")
local jitter, jitterChanges = P.new(), {}
feed(jitter, 16, 1 / 60, "Médio", jitterChanges)
for _ = 1, 8 do
	feed(jitter, 2, 1 / 20, "Médio", jitterChanges)
	feed(jitter, 6, 1 / 60, "Médio", jitterChanges)
end
assert(#jitterChanges == 0, "Brief frame spikes caused a downgrade")
local invalid = P.new()
for _, dt in { false, {}, "0.02", 0, -1, 0 / 0, math.huge, -math.huge, 0.6, 5 } do
	local before = clone(invalid)
	assert(P.step(invalid, dt, "Médio") == nil and equal(before, invalid), "Invalid sample mutated policy")
end
local before = clone(invalid)
assert(P.step(invalid, nil, "Médio") == nil and equal(before, invalid))
for _, quality in { "Alto", "Baixo" } do
	local manual, manualChanges = triggered()
	assert(P.step(manual, 1 / 60, quality) == false, "Manual choice did not override adaptive state")
	feed(manual, 80, 1 / 20, quality, manualChanges)
	assert(#manualChanges == 1, "Manual mode was automatically changed")
end
local low = P.settings("Baixo", false)
assert(low.detailLow and low.animateLimit == 6 and low.nearRate == 15 and low.farRate == 8 and low.hideDistance == 180)
assert(P.settings("Médio", true).detailLow)
assert(not P.settings("Alto", true).detailLow and P.settings("Alto", true).animateLimit == 24)
assert(P.settings("Médio", false).animateLimit == 16)
print("PASS policy: warmup, sustained slowdown/recovery, hysteresis, manual modes and 11 invalid samples")

local function harness(quality)
	local time, heartbeat, connections = 0, nil, 0
	local attributes = { GraphicsQuality = quality }
	local attributeWrites = 0
	local player = {
		GetAttribute = function(_, key)
			return attributes[key]
		end,
		SetAttribute = function(_, key, value)
			attributeWrites += 1
			attributes[key] = value
		end,
	}
	local Run = {
		IsStudio = function()
			return false
		end,
		Heartbeat = {
			Connect = function(_, callback)
				heartbeat = callback
				connections += 1
			end,
		},
	}
	local RS = { Shared = Loader.node("src/shared") }
	local world = {
		CurrentCamera = { CFrame = rb.CFrame.new() },
		FindFirstChild = function()
			return nil
		end,
	}
	local game = {
		GetService = function(_, name)
			return ({ RunService = Run, Players = { LocalPlayer = player }, ReplicatedStorage = RS })[name]
		end,
	}
	local load = Loader.new({ game = game, workspace = world, os = {
		clock = function()
			return time
		end,
	} })
	local A = load("src/client/CreatureAnimator.luau")
	A.start()
	A.start()
	assert(connections == 1, "Animator created more than one scheduler")
	local function object(class, props, attrs)
		local writes = {}
		attrs = attrs or {}
		local methods = {
			IsA = function(_, name)
				return name == class or name == "BasePart" and class == "Part"
			end,
			GetAttribute = function(_, key)
				return attrs[key]
			end,
		}
		local obj = setmetatable({}, {
			__index = function(_, key)
				return methods[key] or props[key]
			end,
			__newindex = function(_, key, value)
				writes[key] = (writes[key] or 0) + 1
				props[key] = value
			end,
		})
		return obj, writes
	end
	local function model(distance, visible)
		local modelProps = { Parent = world }
		local m = object("Model", modelProps, { Family = "quadruped", Species = "cinzelo", Moving = true })
		local parts, partWrites, motors, motorWrites = {}, {}, {}, {}
		for _, name in { "Root", "Body", "Head", "SmallPattern" } do
			local part, writes = object("Part", {
				Name = name,
				Parent = m,
				Position = V(distance, 0, 0),
				Size = V(1, 1, 1),
				Color = rb.Color3.fromRGB(128, 100, 82),
				LocalTransparencyModifier = 0,
			}, { LODDetail = name == "SmallPattern" })
			parts[name], partWrites[name] = part, writes
		end
		for _, role in { "Body", "Head", "EyeL" } do
			local joint, writes = object("Motor6D", {
				Name = "J_" .. role,
				Parent = m,
				C0 = rb.CFrame.new(),
				Transform = rb.CFrame.identity,
			}, { Role = role, Phase = 0 })
			motors[role], motorWrites[role] = joint, writes
		end
		local effect, effectWrites = object("ParticleEmitter", { Parent = m, Enabled = true })
		modelProps.PrimaryPart, modelProps.Body = parts.Root, parts.Body
		modelProps.FindFirstChild = function(_, name)
			return parts[name]
		end
		modelProps.GetDescendants = function()
			return {
				parts.Root,
				parts.Body,
				parts.Head,
				parts.SmallPattern,
				motors.Body,
				motors.Head,
				motors.EyeL,
				effect,
			}
		end
		A.register(m, visible)
		A.register(m, visible)
		return {
			model = m,
			parts = parts,
			partWrites = partWrites,
			motors = motors,
			motorWrites = motorWrites,
			effect = effect,
			effectWrites = effectWrites,
		}
	end
	local function frames(seconds, dt)
		for _ = 1, math.floor(seconds / dt + 0.5) do
			time += dt
			heartbeat(dt)
		end
	end
	return {
		A = A,
		model = model,
		frames = frames,
		attributes = attributes,
		attributeWrites = function()
			return attributeWrites
		end,
		pulse = function(dt)
			heartbeat(dt)
		end,
	}
end
local function animated(models)
	local count = 0
	for _, m in models do
		if (m.motorWrites.Body.Transform or 0) > 0 then
			count += 1
		end
	end
	return count
end
local run = harness("Baixo")
local models = {}
for i = 1, 30 do
	table.insert(models, run.model(i))
end
run.frames(10, 1 / 60)
assert(animated(models) == 6, "Low mode exceeded six animated models")
local nearCount = models[1].motorWrites.Body.Transform or 0
assert(nearCount > 70 and nearCount <= 151, "Low near update cadence exceeded 15 Hz")
for _, m in models do
	for _, motor in m.motors do
		for _, number in { motor.Transform:GetComponents() } do
			assert(number == number and math.abs(number) < 1e6)
		end
	end
end
local far = harness("Baixo")
local distant = far.model(90)
far.frames(10, 1 / 60)
local farCount = distant.motorWrites.Body.Transform or 0
assert(farCount > 50 and farCount <= 81, "Low far update cadence exceeded 8 Hz")
for _, case in { { quality = "Médio", limit = 16 }, { quality = "Alto", limit = 24 } } do
	local full, group = harness(case.quality), {}
	for i = 1, 30 do
		table.insert(group, full.model(i))
	end
	full.frames(2, 1 / 60)
	assert(animated(group) == case.limit, "Full-mode animation budget changed")
end
local culling = harness("Baixo")
local nearby, background, offscreen = culling.model(5), culling.model(170), culling.model(181)
culling.frames(0.2, 1 / 60)
assert(nearby.parts.Body.LocalTransparencyModifier == 0 and nearby.parts.SmallPattern.LocalTransparencyModifier == 1)
assert(not nearby.effect.Enabled)
assert(
	background.parts.Body.LocalTransparencyModifier == 0
		and background.parts.SmallPattern.LocalTransparencyModifier == 1
)
assert((background.motorWrites.Body.Transform or 0) == 0)
assert(offscreen.parts.Body.LocalTransparencyModifier == 1 and (offscreen.motorWrites.Body.Transform or 0) == 0)
local writes = nearby.partWrites.SmallPattern.LocalTransparencyModifier
culling.frames(3, 1 / 60)
assert(
	nearby.partWrites.SmallPattern.LocalTransparencyModifier == writes,
	"Stable LOD rewrote transparency every frame"
)
culling.attributes.GraphicsQuality = "Alto"
culling.frames(0.2, 1 / 60)
assert(nearby.parts.SmallPattern.LocalTransparencyModifier == 0 and nearby.effect.Enabled)
assert(
	offscreen.parts.Body.LocalTransparencyModifier == 0 and offscreen.parts.SmallPattern.LocalTransparencyModifier == 0
)
local showing = false
local viewports = harness("Baixo")
local closed = viewports.model(0, function()
	return showing
end)
viewports.frames(1, 1 / 60)
assert(closed.parts.Body.LocalTransparencyModifier == 1 and (closed.motorWrites.Body.Transform or 0) == 0)
showing = true
viewports.frames(1, 1 / 60)
assert(closed.parts.Body.LocalTransparencyModifier == 0 and (closed.motorWrites.Body.Transform or 0) > 0)
showing = false
local oldUpdates = closed.motorWrites.Body.Transform
viewports.frames(1, 1 / 60)
assert(closed.motorWrites.Body.Transform == oldUpdates and closed.parts.Body.LocalTransparencyModifier == 1)
local priority = harness("Baixo")
local crowd = {}
for i = 1, 30 do
	table.insert(crowd, priority.model(10 + i))
end
local battlePreview = priority.model(400, function()
	return true
end)
priority.frames(2, 1 / 60)
assert(
	(battlePreview.motorWrites.Body.Transform or 0) > 0 and battlePreview.parts.Body.LocalTransparencyModifier == 0,
	"Visible viewport lost its priority to field creatures"
)
assert(animated(crowd) <= 5, "Viewport priority exceeded the six-model budget")
local removed = harness("Baixo")
local disappearing = removed.model(5)
removed.frames(1, 1 / 60)
local last = disappearing.motorWrites.Body.Transform
local transparency = disappearing.partWrites.SmallPattern.LocalTransparencyModifier
disappearing.model.Parent = nil
removed.frames(1, 1 / 60)
assert(disappearing.motorWrites.Body.Transform == last, "Removed model kept animating")
for _, dt in { false, {}, "0.02", 0, -1, 0 / 0, math.huge, 0.6 } do
	removed.pulse(dt)
end
removed.pulse(nil)
assert(
	disappearing.motorWrites.Body.Transform == last
		and disappearing.partWrites.SmallPattern.LocalTransparencyModifier == transparency
)
local automatic = harness("Médio")
local adaptive = automatic.model(5)
automatic.frames(15, 1 / 60)
automatic.frames(9, 1 / 20)
assert(automatic.attributes.AdaptiveDetailLow == true and adaptive.parts.SmallPattern.LocalTransparencyModifier == 1)
automatic.attributes.GraphicsQuality = "Alto"
automatic.frames(0.2, 1 / 60)
assert(automatic.attributes.AdaptiveDetailLow == false and adaptive.parts.SmallPattern.LocalTransparencyModifier == 0)
assert(automatic.attributeWrites() == 2, "Adaptive state was written without transitions")
print(
	"PASS animator: one scheduler, low six/full16–24 models, near",
	nearCount,
	"/ far",
	farCount,
	"updates in 10 simulated seconds"
)
print(
	"PASS culling: closed/distant creatures paused, ornament visibility restored, no repeated transparency writes; no FPS benchmark"
)
