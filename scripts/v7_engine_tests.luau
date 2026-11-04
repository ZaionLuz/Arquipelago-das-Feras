local Loader = require("./loader")
local rb = require("@lune/roblox")
local V = rb.Vector3
local profile = { playerLevel = 1, unlocked = { Alvorecer = true }, gold = 0 }
local session = { region = "Alvorecer", lastSafe = "Alvorecer" }
local player = { Character = {
	FindFirstChild = function()
		return { Position = V.new(150, 10, 0) }
	end,
} }
local Data = {
	get = function()
		return profile
	end,
	session = function()
		return session
	end,
}
local RS = { Shared = Loader.node("src/shared") }
local Players = { PlayerRemoving = { Connect = function() end } }
local game = {
	GetService = function(_, name)
		return ({ ReplicatedStorage = RS, Players = Players })[name]
	end,
}
local load = Loader.new({ game = game }, { ["src/server/DataService.luau"] = Data })
local Region = load("src/server/RegionService.luau")
local Guard = load("src/server/RegionGuard.luau")
local I = load("src/shared/Islands.luau")
assert(Region.current(player, "battle") == "Alvorecer")
for _, id in { "Brasa", "Recife", "Floresta", "Dunas", "Picos", "Pantano" } do
	local result = Guard.inspect(profile, session, I.pos(I.ById[id].idx))
	assert(not result.ok and result.safe == "Alvorecer")
	for _, purpose in { "encounter", "capture", "battle", "shop", "hatch" } do
		assert(not Region.requireCurrent(player, id, purpose).ok)
	end
end
profile.unlocked.Brasa = true
profile.playerLevel = 10
assert(not Region.requireCurrent(player, "Brasa", "battle").ok) -- Intenção remota não altera a sessão.
assert(session.region == "Alvorecer" and Guard.best(profile) == "Brasa")
profile.playerLevel = 1
profile.legacyGrandfathered = { Brasa = true }
assert(Guard.best(profile) == "Brasa")
local bad = Guard.inspect(profile, session, I.pos(2))
assert(not bad.ok and bad.reason == "WRONG_REGION")
print("PASS V7.03: volumes, região de sessão, remote de região falsificada, destino de respawn e legado")
local calls = 0
local connections = {}
local Animator = {
	register = function()
		calls += 1
	end,
}
local loadUI = Loader.new({ game = game }, { ["src/client/CreatureAnimator.luau"] = Animator })
local UI = loadUI("src/client/CollectionUI.luau")
local C = loadUI("src/shared/Creatures.luau")
local parent = rb.Instance.new("Frame")
parent.Visible = true
local first = UI.preview(parent, C.ById.cinzelo, 1, false)
for _ = 1, 100 do
	assert(UI.preview(parent, C.ById.cinzelo, 2, false) == first)
end
assert(UI.rebuilds == 1 and calls == 1)
assert(UI.preview(parent, C.ById.cinzelo, 7, false) == first and UI.rebuilds == 2)
assert(UI.preview(parent, C.ById.magmarau, 7, false) == first and UI.rebuilds == 3)
assert(#parent:GetChildren() == 1)
parent:Destroy()
print("PASS V7.12: 100 atualizações mesmo estágio = 1 construção; troca de espécie/estágio reutiliza Viewport")
local F = Loader.load("src/shared/ModelFactory.luau")
local native = F.build(C.ById.magmarau, 15, { preview = true })
local clone = F.build(C.ById.magmarau, 15, { preview = true })
for _, joint in clone:GetDescendants() do
	if joint:IsA("Motor6D") then
		assert(joint.Part0:IsDescendantOf(clone) and joint.Part1:IsDescendantOf(clone))
	end
end
local empty = rb.Instance.new("Model")
assert(not pcall(F.validate, empty))
empty:Destroy()
local limb = clone:FindFirstChild("Head")
limb.CanCollide = true
assert(not pcall(F.validate, clone))
limb.CanCollide = false
local script = rb.Instance.new("Script")
script.Parent = clone
assert(not pcall(F.validate, clone))
script:Destroy()
native:Destroy()
clone:Destroy()
print("PASS V7.11: clone com referências locais e validação negativa de Root, colisão e scripts")
-- Ações e remote principal REAIS com serviços de plataforma simulados.
local clock = 100
local registry = {}
local transports = 0
profile = {
	playerLevel = 1,
	playerXp = 0,
	unlocked = { Alvorecer = true },
	gold = 1e6,
	creatures = { u1 = { id = "brotinho", lv = 1, xp = 0 } },
	habitat = {},
	sanctuary = {},
	stats = {},
}
session = { region = "Alvorecer", lastSafe = "Alvorecer" }
Data.snapshot = function()
	return profile
end
local signal = { Connect = function() end }
Players.PlayerAdded = signal
Players.PlayerRemoving = signal
Players.GetPlayers = function()
	return {}
end
local physics = { RegisterCollisionGroup = function() end, CollisionGroupSetCollidable = function() end }
game.GetService = function(_, name)
	return ({
		ReplicatedStorage = RS,
		Players = Players,
		HttpService = {
			GenerateGUID = function()
				return "nonce"
			end,
		},
		PhysicsService = physics,
	})[name]
end
game.BindToClose = function() end
local Instance = {
	new = function()
		return setmetatable({}, {
			__newindex = function(t, k, v)
				rawset(t, k, v)
				if k == "Name" then
					registry[v] = t
				end
			end,
		})
	end,
}
local noop = {
	build = function() end,
	start = function() end,
	refresh = function() end,
	release = function() end,
	initialize = function() end,
}
local replacements = {
	["src/server/DataService.luau"] = Data,
	["src/server/World.luau"] = noop,
	["src/server/MonetizationService.luau"] = noop,
	["src/server/EncounterService.luau"] = {
		start = function() end,
		active = function()
			return false
		end,
	},
	["src/server/Transport.luau"] = {
		go = function()
			transports += 1
			return true
		end,
	},
	["src/server/SanctuaryService.luau"] = noop,
}
for _, name in { "RegionGuard", "StartingCamp", "Researcher", "Wildlife", "Guardians", "SanctuaryBuilder" } do
	replacements["src/server/" .. name .. ".luau"] = noop
end
local netLoad = Loader.new({
	game = game,
	Instance = Instance,
	workspace = {},
	os = {
		clock = function()
			return clock
		end,
		time = os.time,
	},
	task = { spawn = function() end },
	Random = {
		new = function()
			return {
				NextNumber = function()
					return 0.5
				end,
				NextInteger = function(_, a)
					return a
				end,
			}
		end,
	},
}, replacements)
-- Main retorna nil; o loader não exige resultado. O callback remoto é capturado no registro.
netLoad("src/server/Main.server.luau")
local remote = registry.Net
for _, action in { "Travel", "Unlock", "BuildHabitat", "MoveHabitat", "UpgradeHabitat", "RemoveHabitat", "BuyEgg" } do
	for _, bad in { {}, 0 / 0, "inexistente", "Pantano", "Brasa" } do
		clock += 1
		local result = remote.OnServerInvoke(player, action, bad, 100)
		assert(result == nil or result.ok == false, action .. " aceitou argumento forjado")
	end
end
clock += 1
local fakeLevel = remote.OnServerInvoke(player, "Travel", "Pantano", 100)
assert(fakeLevel.ok == false and profile.playerLevel == 1)
clock += 1
assert(remote.OnServerInvoke(player, "Battle", "u1", "Brasa").ok == false)
assert(transports == 0 and session.region == "Alvorecer")
clock += 1
assert(remote.OnServerInvoke(player, "Get").ok)
print(
	"PASS V7.02: Main.Net real rejeita tabela/NaN/ilha inexistente, remotes travados e nível forjado; zero transportes"
)
-- Builder real com instâncias Roblox nativas; somente sinais ProximityPrompt são simulados.
local prompts = {}
local container = rb.Instance.new("Folder")
local nativeInstance = {
	new = function(class)
		if class == "ProximityPrompt" then
			local prompt = {}
			prompt.Triggered = {
				Connect = function(_, callback)
					table.insert(prompts, { prompt = prompt, callback = callback })
				end,
			}
			return prompt
		end
		return rb.Instance.new(class)
	end,
}
RS.FindFirstChild = function()
	return nil
end
local builderLoad = Loader.new(
	{ game = game, workspace = container, Instance = nativeInstance },
	{ ["src/server/DataService.luau"] = Data }
)
local builder = builderLoad("src/server/SanctuaryBuilder.luau")
builder.build()
local parts = 0
for _, obj in container:GetDescendants() do
	if obj:IsA("BasePart") then
		parts += 1
		assert(obj.Anchored and obj.Size.X > 0 and obj.Size.Y > 0 and obj.Size.Z > 0)
	end
end
assert(parts <= 400 and #prompts == 4)
local position = V.new(150, 10, 0)
player.Character.FindFirstChild = function()
	return { Position = position }
end
profile = { playerLevel = 50, unlocked = { Alvorecer = true, Dunas = true, Picos = true }, phoenix = { glyphs = {} } }
session = { region = "Dunas", lastSafe = "Dunas" }
for index = 2, 4 do
	local prompt = prompts[index]
	position = prompt.prompt.Parent.Position + V.new(0, 0, 30)
	local quest = builderLoad("src/shared/PhoenixQuest.luau")
	local before = quest.stage(profile)
	prompt.callback(player)
	assert(quest.stage(profile) == before)
	position = prompt.prompt.Parent.Position
	session.region = index == 4 and "Picos" or "Dunas"
	prompt.callback(player)
end
assert(
	profile.phoenix.sanctuaryOpen
		and profile.phoenix.glyphs.duneHidden
		and profile.phoenix.glyphs.duneRuin
		and profile.phoenix.glyphs.skyPeak
)
local fs = require("@lune/fs")
local serde = require("@lune/serde")
fs.writeFile(
	"docs/SANCTUARY_METRICS.json",
	serde.encode(
		"json",
		{ parts = parts, budget = 400, prompts = #prompts, signalMock = true, physicsExecuted = false },
		true
	)
)
print(
	"PASS V7: ruínas",
	parts,
	"peças ancoradas, 4 prompts; coleta exige distância/região e abre após três flags"
)
