-- Política de navegação/viagem REAL com tipos Roblox nativos e plataforma simulada.
-- Não executa física, streaming real, CharacterAdded do Roblox ou multiplayer.
local Loader = require("../loader")
local rb = require("@lune/roblox")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local V = rb.Vector3.new
local function signal()
	local callbacks = {}
	return {
		Connect = function(_, callback)
			table.insert(callbacks, callback)
			return { Disconnect = function() end }
		end,
		Fire = function(_, ...)
			for _, callback in callbacks do
				callback(...)
			end
		end,
	}
end
local Players = {
	PlayerRemoving = signal(),
	GetPlayers = function()
		return {}
	end,
}
local RS = {
	Shared = Loader.node("src/shared"),
	FindFirstChild = function()
		return nil
	end,
}
local game = {
	GetService = function(_, name)
		return ({ Players = Players, ReplicatedStorage = RS })[name]
	end,
}
local profiles, sessions, active = {}, {}, {}
local delays = {}
local task = {
	delay = function(seconds, callback)
		assert(seconds == 1, "Janela de restauração de âncora alterada")
		table.insert(delays, callback)
	end,
	spawn = function(fn, ...)
		-- initialize usa spawn(respawn,character); o laço periódico de start não é executado.
		if select("#", ...) > 0 then
			fn(...)
		end
	end,
}
local Data = {
	get = function(p)
		return profiles[p]
	end,
	session = function(p)
		return sessions[p]
	end,
}
local native = {
	new = function(class, parent)
		if class == "ProximityPrompt" then
			return { Triggered = signal() }
		end
		local object = rb.Instance.new(class)
		if parent then
			object.Parent = parent
		end
		return object
	end,
}
local world = rb.Instance.new("Folder")
local load = Loader.new({ game = game, task = task, workspace = world, Instance = native }, {
	["src/server/DataService.luau"] = Data,
	["src/server/EncounterService.luau"] = {
		active = function(p)
			return active[p] == true
		end,
	},
})
local L = load("src/shared/WorldLayout.luau")
local I = load("src/shared/Islands.luau")
local Region = load("src/server/RegionService.luau")
local Guard = load("src/server/RegionGuard.luau")
local Transport = load("src/server/Transport.luau")
local Sanctuary = load("src/server/SanctuaryService.luau")
local function character(position)
	local char = { pivots = 0 }
	local root = { Parent = char, Anchored = false, Position = position }
	local humanoid = { Health = 100 }
	char.root, char.humanoid = root, humanoid
	function char:FindFirstChild(name)
		return name == "HumanoidRootPart" and root or nil
	end
	function char:FindFirstChildOfClass(name)
		return name == "Humanoid" and humanoid or nil
	end
	function char:WaitForChild(name)
		return self:FindFirstChild(name)
	end
	function char:PivotTo(cf)
		if self.pivotError then
			error("Falha de PivotTo injetada")
		end
		self.pivots += 1
		root.Position = cf.Position
	end
	return char
end
local serial = 0
local function player()
	serial += 1
	local p =
		{ UserId = serial, Name = "NavegaçãoTeste", Parent = Players, CharacterAdded = signal(), attributes = {} }
	p.Character = character(L.safePoint(1))
	function p:SetAttribute(key, value)
		self.attributes[key] = value
	end
	function p:RequestStreamAroundAsync(position, timeout)
		assert(typeof(position) == "Vector3" and timeout == 3)
		if self.streamHook then
			self.streamHook()
		end
	end
	profiles[p] = {
		playerLevel = 1,
		gold = 0,
		unlocked = { Alvorecer = true },
		stats = {},
		navigation = { visited = { Alvorecer = true }, checkpoint = "Alvorecer" },
	}
	sessions[p] = { region = "Alvorecer", lastSafe = "Alvorecer" }
	return p
end
local function flush()
	local callbacks = delays
	delays = {}
	for _, fn in callbacks do
		fn()
	end
end
local function move(p, position)
	p.Character.root.Position = position
end
local function countVisits(p)
	local count = 0
	for _, value in profiles[p].navigation.visited do
		if value then
			count += 1
		end
	end
	return count
end
Guard.start()
local beginner = player()
move(beginner, L.safePoint(7))
assert(Guard.best(profiles[beginner]) == "Alvorecer", "Novo jogador não pode nascer na última área acessível")
Guard.initialize(beginner)
assert(beginner.RespawnLocation.Name == "Alvorecer")
assert((beginner.Character.root.Position - L.safePoint(1)).Magnitude < 0.01)
assert(not profiles[beginner].navigation.visited.Pantano)
assert(Guard.best({ playerLevel = 1, navigation = { checkpoint = "inexistente" } }) == "Alvorecer")
local p = player()
local denied = Region.requireCurrent(p, "Pantano", "battle")
assert(not denied.ok and sessions[p].region == "Alvorecer")
assert(countVisits(p) == 1 and not profiles[p].navigation.visited.Pantano, "ID remoto não pode descobrir uma região")
assert(not Region.requireCurrent(p, {}, "capture").ok)
-- Uma estrada atualiza o contexto da travessia, sem conceder visita/checkpoint antes da área real.
local firstRoute = L.route(1)
move(p, firstRoute.a:Lerp(firstRoute.b, 0.75) + V(0, 7, 0))
local routeId, routeKind = Region.detect(p.Character.root.Position)
assert(routeId == "Brasa" and routeKind == "route")
assert(Region.current(p, "battle") == "Brasa")
assert(not profiles[p].navigation.visited.Brasa and profiles[p].navigation.checkpoint == "Alvorecer")
assert(sessions[p].lastSafe == "Alvorecer")
local pivotsBeforeWalk = p.Character.pivots
local samples = 0
for index = 1, #I.List do
	local start = L.center(index)
	local finish = L.center(index % #I.List + 1)
	for step = 0, 100 do
		move(p, start:Lerp(finish, step / 100) + V(0, 7, 0))
		local inspection = Guard.inspect(profiles[p], sessions[p], p.Character.root.Position)
		assert(inspection.ok and inspection.island, "Buraco de política entre áreas/corredores")
		Guard.tick(p)
		assert(Region.current(p, "encounter") == inspection.island)
		samples += 1
	end
end
local walkingTeleports = p.Character.pivots - pivotsBeforeWalk
assert(walkingTeleports == 0, "Caminhada autorizada não deve disparar teleporte")
assert(countVisits(p) == 7, "Todas as sete áreas precisam ser descobertas a pé")
move(p, L.safePoint(5))
Guard.tick(p)
assert(profiles[p].navigation.checkpoint == "Dunas" and profiles[p].navigation.visited.Dunas)
assert(Guard.best(profiles[p]) == "Dunas")
assert(p.RespawnLocation.Name == "Dunas")
Guard.initialize(p)
local respawned = character(V(0, 50, 0))
p.Character = respawned
p.CharacterAdded:Fire(respawned)
assert((respawned.root.Position - L.safePoint(5)).Magnitude < 0.01)
assert(sessions[p].region == "Dunas")
for _, invalid in { V(0, -66, 0), V(100001, 10, 0), V(0 / 0, 10, 0), {} } do
	local result = Guard.inspect(profiles[p], sessions[p], invalid)
	assert(not result.ok and result.safe == "Dunas")
end
move(p, V(0, -70, 0))
Guard.tick(p)
assert((p.Character.root.Position - L.safePoint(5)).Magnitude < 0.01)
print(
	"PASS navigation: spawn inicial/checkpoint, "
		.. samples
		.. " amostras de caminhada sem teleporte, sete visitas, corredores e retorno do vazio"
)
-- Casa real: S.ensure/contains são os módulos de produção, apenas ProximityPrompt é simulado.
local owner, neighbour = player(), player()
local ownPlot = Sanctuary.ensure(owner)
local otherPlot = Sanctuary.ensure(neighbour)
assert((ownPlot.center - L.plotCenter(1)).Magnitude < 0.01 and ownPlot.center.X >= 5000)
assert((otherPlot.center - L.plotCenter(2)).Magnitude < 0.01)
sessions[owner].region = "sanctuary"
move(owner, V(9999, 12, 9999))
assert(Region.current(owner, "shop") == nil)
assert(not Region.requireContext(owner, "Brasa", "shop", true).ok)
move(owner, otherPlot.center + V(0, 7, 0))
assert(not Sanctuary.contains(owner, owner.Character.root.Position))
assert(not Region.requireContext(owner, "Brasa", "hatch", true).ok)
move(owner, ownPlot.center + V(0, 7, 0))
assert(Sanctuary.contains(owner, owner.Character.root.Position))
assert(Region.current(owner, "shop") == "sanctuary")
assert(Region.requireContext(owner, "Brasa", "shop", true).ok)
assert(Region.requireContext(owner, "Pantano", "hatch", true).ok)
Sanctuary.release(owner)
assert(not Sanctuary.contains(owner, ownPlot.center))
assert(Region.current(owner, "shop") == nil)
print(
	"PASS navigation: contexto de casa exige terreno próprio; terreno alheio, vazio e terreno liberado são recusados"
)
-- Exclusão de viagens cobre tanto o yield de streaming quanto a janela ancorada.
local traveller = player()
traveller.streamHook = function()
	coroutine.yield("STREAM_PENDING")
end
local pending = coroutine.create(function()
	return Transport.go(traveller, L.safePoint(2), "Brasa")
end)
local ok, result = coroutine.resume(pending)
assert(ok and result == "STREAM_PENDING" and sessions[traveller].transporting)
assert(Region.current(traveller, "battle") == nil)
assert(not Transport.go(traveller, L.safePoint(3), "Recife"))
traveller.streamHook = nil
ok, result = coroutine.resume(pending)
assert(ok and result == true)
assert(traveller.Character.root.Anchored and sessions[traveller].transporting)
assert(not Transport.go(traveller, L.safePoint(4), "Floresta"))
flush()
assert(not traveller.Character.root.Anchored and not sessions[traveller].transporting)
assert(Transport.go(traveller, L.safePoint(4), "Floresta"))
flush()
assert(not traveller.Character.root.Anchored)
local originallyAnchored = player()
originallyAnchored.Character.root.Anchored = true
assert(Transport.go(originallyAnchored, L.safePoint(2), "Brasa"))
flush()
assert(originallyAnchored.Character.root.Anchored and not sessions[originallyAnchored].transporting)
local failureCases = 0
local function failedTrip(hook, setup)
	local subject = player()
	if setup then
		setup(subject)
	end
	subject.streamHook = function()
		hook(subject)
	end
	local root = subject.Character.root
	local session = sessions[subject]
	assert(not Transport.go(subject, L.safePoint(7), "Pantano"), "Viagem inválida foi aceita")
	assert(not session.transporting and not root.Anchored)
	assert(session.region == "Alvorecer" and session.lastSafe == "Alvorecer")
	assert(not profiles[subject].navigation.visited.Pantano)
	subject.streamHook = nil
	if not root.Parent then
		root.Parent = subject.Character
	end
	subject.Character.humanoid.Health = 100
	subject.Character.pivotError = nil
	active[subject] = nil
	assert(Transport.go(subject, L.safePoint(2), "Brasa"), "Reserva não foi liberada após falha")
	flush()
	assert(not sessions[subject].transporting and not subject.Character.root.Anchored)
	failureCases += 1
end
failedTrip(function()
	error("Streaming indisponível")
end)
failedTrip(function(subject)
	subject.Character = character(L.safePoint(1))
end)
failedTrip(function(subject)
	subject.Character.humanoid.Health = 0
end)
failedTrip(function(subject)
	subject.Character.root.Parent = nil
end)
failedTrip(function(subject)
	active[subject] = true
end)
failedTrip(function() end, function(subject)
	subject.Character.pivotError = true
end)
-- A morte ocorre fora da viagem, enquanto a chamada de streaming está suspensa.
local dying = player()
dying.streamHook = function()
	coroutine.yield("STREAM_PENDING")
end
local dyingTrip = coroutine.create(function()
	return Transport.go(dying, L.safePoint(7), "Pantano")
end)
ok, result = coroutine.resume(dyingTrip)
assert(ok and result == "STREAM_PENDING" and sessions[dying].transporting)
dying.Character.humanoid.Health = 0
ok, result = coroutine.resume(dyingTrip)
assert(ok and result == false and coroutine.status(dyingTrip) == "dead")
assert(not sessions[dying].transporting and not dying.Character.root.Anchored)
assert(sessions[dying].region == "Alvorecer" and not profiles[dying].navigation.visited.Pantano)
dying.streamHook = nil
dying.Character.humanoid.Health = 100
assert(Transport.go(dying, L.safePoint(2), "Brasa"))
flush()
assert(not sessions[dying].transporting and not dying.Character.root.Anchored)
failureCases += 1
local dead = player()
dead.Character.humanoid.Health = 0
assert(not Transport.go(dead, L.safePoint(2), "Brasa"))
assert(not sessions[dead].transporting and not dead.Character.root.Anchored)
local invalidDestinations = { {}, "Pantano", V(0 / 0, 0, 0), V(math.huge, 0, 0), V(2000000, 0, 0) }
for _, destination in invalidDestinations do
	local subject = player()
	assert(not Transport.go(subject, destination, "Brasa"))
	assert(not sessions[subject].transporting and subject.Character.pivots == 0)
end
assert(#delays == 0)
print(
	"PASS navigation: viagens concorrentes, âncora original, "
		.. failureCases
		.. " falhas recuperáveis, morte e destinos inválidos"
)
fs.writeFile(
	"docs/OPEN_WORLD_NAVIGATION_METRICS.json",
	serde.encode("json", {
		walkingSamples = samples,
		regionsVisited = countVisits(p),
		walkingTeleports = walkingTeleports,
		ownSanctuaryOnly = true,
		concurrentTravelRejected = true,
		preservesOriginalAnchor = true,
		recoveryCases = failureCases,
		invalidDestinationCases = #invalidDestinations,
		platformMock = true,
		physicsExecuted = false,
	}, true)
)
