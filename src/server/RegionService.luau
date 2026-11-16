--!nonstrict
-- REGION SERVICE - Region unlocking, travel, progression, fast travel

local RS = game:GetService("ReplicatedStorage")
local I = require(RS.Shared.Islands)
local Access = require(RS.Shared.Access)
local Data = require(script.Parent.DataService)
local Transport = require(script.Parent.Transport)
local B = require(script.Parent.Biomes)
local R = {}

-- Fast travel network: unlocked landmarks, winged mount points, underwater tunnels
R.FastTravelNodes = {
	Alvorecer = {
		name = "Acampamento Base",
		position = I.pos(1) + Vector3.new(0, 9, 30),
		type = "landmark",
		connections = { "Brasa", "Floresta" },
		cost = 0,
	},
	Brasa = {
		name = "Ponte de Obsidiana",
		position = I.pos(2) + Vector3.new(0, 9, 20),
		type = "landmark",
		connections = { "Alvorecer", "Dunas", "Forja" },
		cost = 50,
	},
	Recife = {
		name = "Recife Cristalino",
		position = I.pos(3) + Vector3.new(0, 9, 25),
		type = "landmark",
		connections = { "Floresta", "Pantano", "Geoda" },
		cost = 100,
	},
	Floresta = {
		name = "Clareira dos Sussurros",
		position = I.pos(4) + Vector3.new(0, 9, 28),
		type = "landmark",
		connections = { "Alvorecer", "Recife", "Picos", "Celestial" },
		cost = 150,
	},
	Dunas = {
		name = "Ruinas Enterradas",
		position = I.pos(5) + Vector3.new(0, 9, 22),
		type = "landmark",
		connections = { "Brasa", "Picos", "Forja" },
		cost = 200,
	},
	Picos = {
		name = "Cume Celestial",
		position = I.pos(6) + Vector3.new(0, 9, 35),
		type = "mount",
		connections = { "Floresta", "Dunas", "Pantano", "Inverno", "Trovao" },
		cost = 300,
	},
	Pantano = {
		name = "Portal Umbral",
		position = I.pos(7) + Vector3.new(0, 9, 24),
		type = "landmark",
		connections = { "Recife", "Picos", "Vazio" },
		cost = 400,
	},
	Inverno = {
		name = "Cidadela de Gelo",
		position = I.pos(8) + Vector3.new(0, 9, 30),
		type = "mount",
		connections = { "Picos", "Celestial", "Geoda" },
		cost = 500,
	},
	Trovao = {
		name = "Pico da Tempestade",
		position = I.pos(9) + Vector3.new(0, 9, 32),
		type = "mount",
		connections = { "Picos", "Forja", "Vazio" },
		cost = 600,
	},
	Celestial = {
		name = "Jardim das Estrelas",
		position = I.pos(10) + Vector3.new(0, 9, 28),
		type = "landmark",
		connections = { "Floresta", "Inverno", "Geoda" },
		cost = 700,
	},
	Forja = {
		name = "Coracao da Forja",
		position = I.pos(11) + Vector3.new(0, 9, 26),
		type = "landmark",
		connections = { "Brasa", "Dunas", "Trovao", "Geoda" },
		cost = 800,
	},
	Geoda = {
		name = "Camara Cristalina",
		position = I.pos(12) + Vector3.new(0, 9, 24),
		type = "underground",
		connections = { "Recife", "Inverno", "Celestial", "Forja", "Vazio" },
		cost = 900,
	},
	Vazio = {
		name = "Limite do Vazio",
		position = I.pos(13) + Vector3.new(0, 9, 30),
		type = "mount",
		connections = { "Pantano", "Trovao", "Geoda" },
		cost = 1000,
	},
}

-- Winged mount points (require Guardian defeat)
R.MountPoints = {
	Alvorecer = { position = I.pos(1) + Vector3.new(15, 20, 15), requires = nil },
	Brasa = { position = I.pos(2) + Vector3.new(-15, 25, -15), requires = "Brasa" },
	Recife = { position = I.pos(3) + Vector3.new(20, 18, 20), requires = "Recife" },
	Floresta = { position = I.pos(4) + Vector3.new(-20, 22, -20), requires = "Floresta" },
	Dunas = { position = I.pos(5) + Vector3.new(18, 20, 18), requires = "Dunas" },
	Picos = { position = I.pos(6) + Vector3.new(0, 40, 0), requires = "Picos" },
	Pantano = { position = I.pos(7) + Vector3.new(-18, 15, 18), requires = "Pantano" },
	Inverno = { position = I.pos(8) + Vector3.new(22, 35, -22), requires = "Inverno" },
	Trovao = { position = I.pos(9) + Vector3.new(-22, 30, 22), requires = "Trovao" },
	Celestial = { position = I.pos(10) + Vector3.new(25, 30, 25), requires = "Celestial" },
	Forja = { position = I.pos(11) + Vector3.new(-20, 28, -20), requires = "Forja" },
	Geoda = { position = I.pos(12) + Vector3.new(0, 10, 0), requires = "Geoda" },
	Vazio = { position = I.pos(13) + Vector3.new(30, 25, -30), requires = "Vazio" },
}

-- Underwater tunnels (connect water biomes)
R.UnderwaterTunnels = {
	{ from = "Recife", to = "Geoda", position = I.pos(3) + Vector3.new(0, -20, 0), cost = 200 },
	{ from = "Recife", to = "Pantano", position = I.pos(3) + Vector3.new(0, -15, 0), cost = 150 },
	{ from = "Geoda", to = "Vazio", position = I.pos(12) + Vector3.new(0, -25, 0), cost = 500 },
}

function R.detect(position)
	for _, def in I.List do
		local center = I.pos(def.idx)
		if
			math.abs(position.Y - center.Y) < 100
			and (Vector3.new(position.X, 0, position.Z) - Vector3.new(center.X, 0, center.Z)).Magnitude <= 40
		then
			return def.id
		end
	end
	return nil
end

function R.current(p, purpose)
	local d = Data.get(p)
	local session = Data.session(p)
	local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
	if not d or not session or not root or session.transporting then
		return nil
	end
	local id = R.detect(root.Position)
	if id and id == session.region and Access.check(d, id, purpose or "encounter").ok then
		return id
	end
	return not id and session.region == "sanctuary" and "sanctuary" or nil
end

function R.requireCurrent(p, id, purpose)
	local data = Data.get(p)
	local access = Access.check(data, id, purpose)
	if not access.ok then
		return access
	end
	if R.current(p, purpose) ~= id then
		return { ok = false, reason = "WRONG_REGION" }
	end
	return access
end

function R.requireContext(p, id, purpose, allowHome)
	local result = Access.check(Data.get(p), id, purpose)
	if not result.ok then
		return result
	end
	if allowHome and R.current(p, purpose) == "sanctuary" then
		return result
	end
	return R.requireCurrent(p, id, purpose)
end

function R.safePoint(id)
	local def = I.ById[id] or I.ById.Alvorecer
	return I.pos(def.idx) + Vector3.new(0, 9, 24)
end

-- Fast Travel System
function R.getFastTravelNodes(player)
	local data = Data.get(player)
	if not data then return {} end

	local available = {}
	for id, node in R.FastTravelNodes do
		if data.unlocked[id] then
			local nodeData = {
				id = id,
				name = node.name,
				position = node.position,
				type = node.type,
				connections = {},
				cost = node.cost,
				unlocked = true,
			}
			for _, connId in node.connections do
				if data.unlocked[connId] then
					table.insert(nodeData.connections, connId)
				end
			end
			table.insert(available, nodeData)
		end
	end
	return available
end

function R.fastTravel(player, fromId, toId)
	local data = Data.get(player)
	if not data then return { ok = false, reason = "NO_DATA" } end

	local fromNode = R.FastTravelNodes[fromId]
	local toNode = R.FastTravelNodes[toId]
	if not fromNode or not toNode then
		return { ok = false, reason = "INVALID_NODE" }
	end

	if not data.unlocked[fromId] or not data.unlocked[toId] then
		return { ok = false, reason = "NOT_UNLOCKED" }
	end

	-- Check connection exists
	local connected = false
	for _, connId in fromNode.connections do
		if connId == toId then connected = true break end
	end
	if not connected then
		return { ok = false, reason = "NOT_CONNECTED" }
	end

	-- Check cost
	if data.gold < toNode.cost then
		return { ok = false, reason = "INSUFFICIENT_GOLD", cost = toNode.cost }
	end

	-- Check not in encounter
	if require(script.Parent.EncounterService).active(player) then
		return { ok = false, reason = "IN_ENCOUNTER" }
	end

	data.gold -= toNode.cost
	local success = Transport.go(player, toNode.position, toId)
	if not success then
		data.gold += toNode.cost -- refund
		return { ok = false, reason = "TRANSPORT_FAILED" }
	end

	return { ok = true, cost = toNode.cost }
end

-- Winged Mount Travel (requires Guardian defeat)
function R.useMount(player, targetId)
	local data = Data.get(player)
	if not data then return { ok = false, reason = "NO_DATA" } end

	local mountPoint = R.MountPoints[targetId]
	if not mountPoint then return { ok = false, reason = "INVALID_MOUNT" } end

	if mountPoint.requires and not data.guardians[mountPoint.requires] then
		return { ok = false, reason = "GUARDIAN_NOT_DEFEATED" }
	end

	if require(script.Parent.EncounterService).active(player) then
		return { ok = false, reason = "IN_ENCOUNTER" }
	end

	local success = Transport.go(player, mountPoint.position, targetId)
	if not success then
		return { ok = false, reason = "TRANSPORT_FAILED" }
	end

	return { ok = true }
end

-- Underwater Tunnel Travel
function R.useUnderwaterTunnel(player, tunnelIndex)
	local data = Data.get(player)
	if not data then return { ok = false, reason = "NO_DATA" } end

	local tunnel = R.UnderwaterTunnels[tunnelIndex]
	if not tunnel then return { ok = false, reason = "INVALID_TUNNEL" } end

	if not data.unlocked[tunnel.from] or not data.unlocked[tunnel.to] then
		return { ok = false, reason = "NOT_UNLOCKED" }
	end

	if data.gold < tunnel.cost then
		return { ok = false, reason = "INSUFFICIENT_GOLD", cost = tunnel.cost }
	end

	if require(script.Parent.EncounterService).active(player) then
		return { ok = false, reason = "IN_ENCOUNTER" }
	end

	data.gold -= tunnel.cost
	local success = Transport.go(player, tunnel.position, tunnel.to)
	if not success then
		data.gold += tunnel.cost
		return { ok = false, reason = "TRANSPORT_FAILED" }
	end

	return { ok = true, cost = tunnel.cost }
end

-- Region progression check
function R.getNextRegion(player)
	local data = Data.get(player)
	if not data then return nil end

	for _, def in I.List do
		if not data.unlocked[def.id] then
			return def
		end
	end
	return nil
end

function R.getRegionProgress(player)
	local data = Data.get(player)
	if not data then return {} end

	local progress = {}
	for _, def in I.List do
		progress[def.id] = {
			unlocked = data.unlocked[def.id] or false,
			guardianDefeated = data.guardians[def.id] or false,
			visited = data.visited[def.id] or false,
			materials = data.materials[def.el] or 0,
			level = data.playerLevel or 1,
			minLevel = def.minLevel,
			cost = def.cost,
		}
	end
	return progress
end

-- Seamless island transition (no loading screens)
function R.transitionToRegion(player, targetId, method)
	local data = Data.get(player)
	if not data then return false end

	method = method or "walk"

	if method == "walk" then
		-- Walking across bridges - handled by proximity prompts in World.build()
		return true
	elseif method == "fast_travel" then
		return R.fastTravel(player, R.current(player, "travel") or "Alvorecer", targetId).ok
	elseif method == "mount" then
		return R.useMount(player, targetId).ok
	elseif method == "tunnel" then
		-- Find tunnel index
		for i, tunnel in R.UnderwaterTunnels do
			if tunnel.to == targetId then
				return R.useUnderwaterTunnel(player, i).ok
			end
		end
		return false
	elseif method == "sanctuary" then
		return require(script.Parent.SanctuaryService).home(player)
	end

	return false
end

return R