-- Scheduler/proximity/encounter integration with native vectors; platform and models simulated.
local Loader = require("../loader")
local rb = require("@lune/roblox")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local V = rb.Vector3
local F = rb.CFrame
local baseLoad = Loader.load
local layout = baseLoad("src/shared/WorldLayout.luau")
local catalog = baseLoad("src/shared/Creatures.luau")
local islands = baseLoad("src/shared/Islands.luau")
local bands = baseLoad("src/shared/LevelBands.luau")
local function signal()
	local callbacks = {}
	return {
		Connect = function(_, fn)
			table.insert(callbacks, fn)
		end,
		Fire = function(_, ...)
			for _, fn in callbacks do
				fn(...)
			end
		end,
	}
end
local clock = 10
local scheduler
local players = {}
local models = {}
local prompts = {}
local created = {}
local notices = 0
local warnings = 0
local opens = 0
local active = {}
local release
local failOpen
local function player(position)
	local root = { Position = position }
	local p = { root = root, allowed = true, loaded = true }
	p.Character = {
		FindFirstChild = function()
			return root
		end,
	}
	return p
end
local first = player(layout.center(1))
local forest = player(layout.center(4))
players = { first, forest }
local RS = { Shared = Loader.node("src/shared") }
local Players = {
	GetPlayers = function()
		return players
	end,
	PlayerRemoving = signal(),
}
local Instance = {
	new = function(class)
		local obj = { ClassName = class }
		if class == "ProximityPrompt" then
			obj.Triggered = signal()
			table.insert(prompts, obj)
		end
		if class == "RemoteEvent" then
			obj.FireClient = function()
				notices += 1
			end
		end
		table.insert(created, obj)
		return obj
	end,
}
local MF = {
	build = function(def, level)
		local m = { id = def.id, level = level, attributes = {}, cf = F.new(0, 2, 0) }
		m.PrimaryPart = { Position = m.cf.Position, Parent = m }
		function m:GetBoundingBox()
			return F.new(0, 2, 0), V.new(2, 2, 2)
		end
		function m:GetPivot()
			return self.cf
		end
		function m:PivotTo(cf)
			self.cf = cf
			self.PrimaryPart.Position = cf.Position
		end
		function m:SetAttribute(key, value)
			self.attributes[key] = value
		end
		function m:Destroy()
			self.Parent = nil
			self.destroyed = true
		end
		table.insert(models, m)
		return m
	end,
}
local E = {
	active = function(p)
		return active[p] == true
	end,
	open = function(p, specimen, onRelease)
		if failOpen == "throw" then
			error("falha controlada")
		end
		if failOpen == "reject" then
			return false
		end
		opens += 1
		active[p] = true
		release = function(remove)
			active[p] = nil
			onRelease(remove)
		end
		assert(specimen.region and specimen.lv and specimen.position)
		return true
	end,
}
local game = {
	GetService = function(_, name)
		return ({ ReplicatedStorage = RS, Players = Players })[name]
	end,
}
local load = Loader.new({
	game = game,
	workspace = {},
	Instance = Instance,
	Random = {
		new = function()
			return {
				NextNumber = function()
					return 0
				end,
				NextInteger = function(_, a)
					return a
				end,
			}
		end,
	},
	os = {
		clock = function()
			return clock
		end,
	},
	warn = function()
		warnings += 1
	end,
	task = {
		spawn = function(fn)
			scheduler = coroutine.create(fn)
		end,
		wait = function()
			coroutine.yield("PULSE")
		end,
	},
}, {
	["src/shared/ModelFactory.luau"] = MF,
	["src/shared/Islands.luau"] = { List = islands.List, ById = islands.ById, pos = layout.center },
	["src/server/DataService.luau"] = {
		get = function(p)
			return p.loaded and {} or nil
		end,
	},
	["src/server/EncounterService.luau"] = E,
	["src/server/RegionService.luau"] = {
		requireCurrent = function(p)
			return { ok = p.allowed, reason = "WRONG_REGION" }
		end,
	},
})
local W = load("src/server/Wildlife.luau")
W.start()
local schedulerOnce = scheduler
W.start()
assert(scheduler == schedulerOnce)
local function pulse(now)
	clock = now
	local ok, reason = coroutine.resume(scheduler)
	assert(ok, reason)
end
local function alive()
	local list = {}
	for _, m in models do
		if not m.destroyed and m.Parent then
			table.insert(list, m)
		end
	end
	return list
end
pulse(10)
local count = {}
local common = {}
local peak = #alive()
for _, m in alive() do
	local region = m.attributes.WildRegion
	count[region] = (count[region] or 0) + 1
	if m.id == "brotinho" then
		common[region] = (common[region] or 0) + 1
	end
	assert(
		m.level >= bands.ById[region].min
			and m.level
				<= bands.ById[region].max + (catalog.ById[m.id].rar == 4 and 3 or catalog.ById[m.id].rar == 3 and 2 or 0)
	)
	assert(m.attributes.WildSlot >= 1 and m.attributes.WildSlot <= 8)
end
assert(
	count.Alvorecer and count.Floresta and common.Alvorecer == 2 and common.Floresta == 2,
	"Densidade vazou entre regiões"
)
for id, n in count do
	assert((id == "Alvorecer" or id == "Floresta") and n <= 8, "Spawn longe de observadores")
end
local prompt
for _, p in prompts do
	if p.Parent.Parent.attributes.WildRegion == "Alvorecer" then
		prompt = p
		break
	end
end
assert(prompt)
local animal = prompt.Parent.Parent
local slot = animal.attributes.WildSlot
first.root.Position = animal.PrimaryPart.Position + V.new(30, 0, 0)
prompt.Triggered:Fire(first)
assert(opens == 0)
first.root.Position = animal.PrimaryPart.Position
first.allowed = false
prompt.Triggered:Fire(first)
assert(opens == 0 and notices == 1)
first.allowed = true
clock = 12
prompt.Triggered:Fire(first)
assert(opens == 1 and prompt.Enabled == false)
for _ = 1, 50 do
	prompt.Triggered:Fire(first)
end
assert(opens == 1, "Reserva duplicada")
first.root.Position = V.new(9000, 20, 9000)
forest.root.Position = V.new(9000, 20, 9000)
pulse(30)
pulse(46)
assert(#alive() == 1 and alive()[1] == animal, "Animal ocupado foi removido ou abandono não foi limpo")
clock = 47
release(true)
assert(animal.destroyed and #alive() == 0)
first.root.Position = layout.center(1)
pulse(48)
for _, m in alive() do
	assert(m.attributes.WildSlot ~= slot, "Respawn ignorou cooldown de captura")
end
pulse(73)
local replacementPrompt
for _, p in prompts do
	local m = p.Parent.Parent
	if not m.destroyed and m.Parent and m.attributes.WildRegion == "Alvorecer" and m.attributes.WildSlot == slot then
		replacementPrompt = p
	end
end
assert(replacementPrompt, "Slot não voltou após cooldown")
local replacement = replacementPrompt.Parent.Parent
first.root.Position = replacement.PrimaryPart.Position
clock = 80
failOpen = "throw"
replacementPrompt.Triggered:Fire(first)
assert(replacementPrompt.Enabled and warnings == 1)
clock = 82
failOpen = "reject"
replacementPrompt.Triggered:Fire(first)
assert(replacementPrompt.Enabled)
clock = 84
failOpen = nil
replacementPrompt.Triggered:Fire(first)
assert(opens == 2 and replacementPrompt.Enabled == false)
release(false)
assert(not replacement.destroyed and replacementPrompt.Enabled)
players = {}
pulse(90)
pulse(106)
assert(#alive() == 0)
-- Uma falha na construção não encerra o scheduler nem provoca tentativas a cada pulso.
local normalBuild = MF.build
local buildFailures = 0
MF.build = function()
	buildFailures += 1
	error("modelo indisponível temporariamente")
end
players = { first }
first.root.Position = layout.center(1)
pulse(107)
local firstFailures = buildFailures
assert(firstFailures > 0 and #alive() == 0)
pulse(108)
assert(buildFailures == firstFailures)
MF.build = normalBuild
pulse(113)
assert(#alive() > 0, "Scheduler não se recuperou de falha de modelo")
fs.writeFile(
	"docs/open_world/WILDLIFE_TESTS.json",
	serde.encode("json", {
		plannedSlots = 7 * W.SlotsPerRegion,
		initialActive = peak,
		regionsObserved = 2,
		perRegionCommon = { Alvorecer = common.Alvorecer, Floresta = common.Floresta },
		spawnDistance = W.SpawnDistance,
		despawnDistance = W.DespawnDistance,
		grace = W.DespawnGrace,
		duplicateTriggers = 50,
		openErrorRecovered = true,
		modelBuildErrorRecovered = true,
		modelBuildBackoff = 5,
		busyCreaturePreserved = true,
		respawnCooldown = true,
		headlessMock = true,
	}, true)
)
print(
	"PASS open world wildlife: 56 spots, region-local density, proximity activation/culling, busy reservation, 50 duplicate prompts, open failures and capture cooldown"
)
