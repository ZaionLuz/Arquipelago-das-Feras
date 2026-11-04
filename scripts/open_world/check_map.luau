-- Geometria Roblox nativa; não simula caminhada, streaming ou física do Studio.
local Loader = require("../loader")
local rb = require("@lune/roblox")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local shared = Loader.node("src/shared")
local load = Loader.new({
	game = {
		GetService = function(_, name)
			assert(name == "ReplicatedStorage")
			return { Shared = shared }
		end,
	},
})
local L = load("src/shared/WorldLayout.luau")
local I = load("src/shared/Islands.luau")
local E = load("src/server/ExpeditionWorld.luau")
local V = rb.Vector3.new
local parent = rb.Instance.new("Folder")
local world = E.build(parent)
local count, solid, area = 0, 0, 0
local bases = {}
local routes = {}
for _, obj in world:GetDescendants() do
	if obj:IsA("BasePart") then
		count += 1
		assert(obj.Anchored and obj.Size.X > 0 and obj.Size.Y > 0 and obj.Size.Z > 0)
		if obj.CanCollide then
			solid += 1
			assert(obj.CanQuery)
		end
		if obj.Name == "SoloRegional" then
			local id = obj.Parent:GetAttribute("Region")
			bases[id] = obj
			assert(
				obj.Shape == rb.Enum.PartType.Cylinder
					and obj.Size.Y == L.RegionRadius * 2
					and obj.Size.Z == L.RegionRadius * 2
			)
			assert(math.abs(obj.CFrame.Position.Y + obj.Size.X / 2 - L.SurfaceY) < 0.01)
			area += math.pi * (obj.Size.Y / 2) ^ 2
		end
		if obj:GetAttribute("FromRegion") then
			routes[obj:GetAttribute("FromRegion")] = obj
		end
	end
end
assert(count <= E.Budget and solid > 28)
for _, def in I.List do
	local base = assert(bases[def.id], "Solo ausente: " .. def.id)
	local center = I.pos(def.idx)
	assert((center - L.center(def.idx)).Magnitude < 0.001, "Islands.pos diverge do contrato")
	local model = base.Parent
	local terraces = 0
	local ramps = 0
	for _, part in model:GetDescendants() do
		if part:IsA("BasePart") and part.Name:match("^Mirante%d+$") then
			terraces += 1
			assert(part:GetAttribute("SurfaceY") > L.SurfaceY and part.CanCollide)
			assert((V(part.CFrame.Position.X, 10, part.CFrame.Position.Z) - center).Magnitude + 56 < L.RegionRadius)
		elseif part:IsA("WedgePart") and part.Name:match("^RampaDoMirante") then
			ramps += 1
			assert(part.CanCollide and part.Size.X >= 50 and part.Size.Z >= 128 and part.Size.Y / part.Size.Z < 0.2)
			local low = part.CFrame:PointToWorldSpace(V(0, -part.Size.Y * 0.5, -part.Size.Z * 0.5))
			local high = part.CFrame:PointToWorldSpace(V(0, part.Size.Y * 0.5, part.Size.Z * 0.5))
			assert(math.abs(low.Y - L.SurfaceY) < 0.01 and high.Y > L.SurfaceY)
		end
	end
	assert(terraces == 3 and ramps == 3)
	for slot = 1, 8 do
		local offset = L.wildOffset(slot)
		local point = center + offset
		assert(V(offset.X, 0, offset.Z).Magnitude < L.RegionRadius - 24)
		assert(L.detect(point) == def.idx)
		-- Estes encontros usam o piso principal: nenhum é colocado sob uma plataforma elevada.
		for _, part in model:GetDescendants() do
			if part:IsA("BasePart") and part.Name:match("^Mirante%d+$") then
				assert((V(point.X, 0, point.Z) - V(part.CFrame.Position.X, 0, part.CFrame.Position.Z)).Magnitude > 64)
			end
		end
	end
	local road = L.route(def.idx)
	local floor = assert(routes[def.idx])
	assert(floor.CanCollide and floor.Size.X >= 64)
	local axis = floor.CFrame.LookVector
	local half = floor.Size.Z * 0.5
	local a = floor.CFrame.Position - axis * half
	local b = floor.CFrame.Position + axis * half
	-- Rota sólida alcança os centros de conexão e entra nas duas superfícies circulares.
	assert(math.min((a - road.a).Magnitude, (b - road.a).Magnitude) < 0.01)
	assert(math.min((a - road.b).Magnitude, (b - road.b).Magnitude) < 0.01)
	assert((road.a - L.center(road.from)).Magnitude < L.RegionRadius)
	assert((road.b - L.center(road.to)).Magnitude < L.RegionRadius)
	for step = 0, 100 do
		local point = road.a:Lerp(road.b, step / 100)
		local region = assert(L.detect(point), "Buraco no corredor de detecção")
		assert(region == road.from or region == road.to)
	end
end
local decor = load("src/server/WorldArt.luau")
local decorations = rb.Instance.new("Folder")
decor.build(decorations)
local decoCount = 0
for _, p in decorations:GetDescendants() do
	if p:IsA("BasePart") then
		decoCount += 1
		assert(not p.CanCollide and not p.CanQuery and not p.CanTouch)
	end
end
assert(decoCount < 2600)
local oldArea = 7 * math.pi * 40 ^ 2
local ratio = area / oldArea
assert(ratio >= 100)
fs.writeFile(
	"docs/open_world/MAP_METRICS.json",
	serde.encode("json", {
		regions = 7,
		diameter = L.RegionRadius * 2,
		routeWidth = L.RouteWidth,
		walkableArea = area,
		oldWalkableArea = oldArea,
		areaMultiplier = ratio,
		surfaceParts = count,
		solidParts = solid,
		decorParts = decoCount,
		terraces = 21,
		ramps = 21,
		wildPoints = 56,
		routesSampled = 707,
		physicsExecuted = false,
	}, true)
)
print(
	"PASS mapa aberto: 7 regiões",
	L.RegionRadius * 2,
	"studs, área",
	math.floor(ratio),
	"vezes; 21mirantes/rampas, 56pontos, 707amostras conectadas; peças",
	count,
	"decor",
	decoCount
)

-- Montagem completa de World: sinais de ProximityPrompt simulados, geometrias nativas.
local seed = 29
local Random = {
	new = function()
		return {
			NextNumber = function(_, a, b)
				seed = seed * 16807 % 2147483647
				local n = seed / 2147483647
				if a then
					return a + n * ((b or 1) - a)
				end
				return n
			end,
			NextInteger = function(_, a, b)
				seed = seed * 16807 % 2147483647
				return a + math.floor(seed / 2147483647 * (b - a + 1))
			end,
		}
	end,
}
local registry = {}
local nativeWorkspace = rb.Instance.new("Workspace")
local lighting = rb.Instance.new("Lighting")
local Instance = {
	new = function(class, parent)
		if class == "ProximityPrompt" then
			return { Triggered = { Connect = function() end } }
		end
		local obj = rb.Instance.new(class)
		if parent then
			obj.Parent = parent
		end
		return obj
	end,
}
local full = Loader.new({
	Instance = Instance,
	Random = Random,
	workspace = nativeWorkspace,
	game = {
		GetService = function(_, name)
			if name == "ReplicatedStorage" then
				return { Shared = shared }
			elseif name == "Lighting" then
				return lighting
			end
			return {}
		end,
	},
}, { ["src/server/DataService.luau"] = {} })
full("src/server/World.luau").build()
local worldCount, waterCount = 0, 0
for _, obj in nativeWorkspace:GetDescendants() do
	if obj:IsA("BasePart") then
		worldCount += 1
		assert(obj.Size.X <= 2048 and obj.Size.Y <= 2048 and obj.Size.Z <= 2048, "Peça excede limite Roblox")
		if obj.Name == "Mar" then
			waterCount += 1
			assert(not obj.CanCollide and not obj.CanQuery and not obj.CanTouch)
		end
	end
	assert(not obj.Name:match("^Portao_"), "Portão legado restou no mundo aberto")
end
assert(waterCount == 9 and worldCount < 4500)
print("PASS World.build nativo:", worldCount, "peças, 9 mosaicos de água≤2048, sem portões legados")
local metrics = serde.decode("json", fs.readFile("docs/open_world/MAP_METRICS.json"))
metrics.fullWorldParts = worldCount
metrics.oceanTiles = waterCount
metrics.maxPartDimension = 2048
metrics.legacyGates = 0
fs.writeFile("docs/open_world/MAP_METRICS.json", serde.encode("json", metrics, true))
