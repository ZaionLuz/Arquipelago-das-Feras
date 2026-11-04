--!nonstrict
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local I = require(RS.Shared.Islands)
local Access = require(RS.Shared.Access)
local Data = require(script.Parent.DataService)
local Region = require(script.Parent.RegionService)
local G = {}
local spawns = {}
local notices = {}
function G.best(d)
	local checkpoint = d.navigation and d.navigation.checkpoint
	if checkpoint and I.ById[checkpoint] and Access.check(d, checkpoint, "travel").ok then
		return checkpoint
	end
	return "Alvorecer"
end
function G.inspect(d, s, position)
	if
		typeof(position) ~= "Vector3"
		or position.X ~= position.X
		or position.Y ~= position.Y
		or position.Z ~= position.Z
		or math.abs(position.X) > 100000
		or math.abs(position.Z) > 100000
		or position.Y < -65
	then
		return { ok = false, reason = "RETURN_TO_CAMP", safe = s.lastSafe or "Alvorecer" }
	end
	local id, kind = Region.detect(position)
	if not id then
		return { ok = true }
	end
	local access = Access.check(d, id, "travel")
	if not access.ok then
		return { ok = false, reason = access.reason, safe = s.lastSafe or "Alvorecer" }
	end
	return { ok = true, island = id, kind = kind }
end
function G.initialize(p)
	local d = Data.get(p)
	local s = Data.session(p)
	if not d or not s then
		return
	end
	local best = G.best(d)
	p.RespawnLocation = spawns[best]
	s.lastSafe = best
	local function respawn(character)
		s.spawning = true
		local root = character:WaitForChild("HumanoidRootPart", 10)
		if root and Data.get(p) and p.Character == character then
			character:PivotTo(CFrame.new(Region.safePoint(s.lastSafe)))
			Region.note(p, s.lastSafe, "region")
		end
		s.spawning = false
	end
	p.CharacterAdded:Connect(respawn)
	if p.Character then
		task.spawn(respawn, p.Character)
	end
end
function G.tick(p)
	local d = Data.get(p)
	local s = Data.session(p)
	local char = p.Character
	local part = char and char:FindFirstChild("HumanoidRootPart")
	if not d or not s or not part or s.transporting or s.spawning then
		return
	end
	local result = G.inspect(d, s, part.Position)
	if not result.ok then
		char:PivotTo(CFrame.new(Region.safePoint(result.safe)))
		Region.note(p, result.safe, "region")
		if not notices[p] or os.clock() - notices[p] > 3 then
			local event = RS:FindFirstChild("WildNotice")
			if event then
				event:FireClient(p, "Você retornou ao último acampamento seguro.")
			end
			notices[p] = os.clock()
		end
	elseif result.island then
		Region.note(p, result.island, result.kind)
		if result.kind ~= "route" then
			p.RespawnLocation = spawns[result.island]
		end
	end
end
function G.start()
	local folder = Instance.new("Folder")
	folder.Name = "PontosSeguros"
	folder.Parent = workspace
	for _, def in I.List do
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = def.id
		spawn.Size = Vector3.new(8, 1, 8)
		spawn.Anchored = true
		spawn.Neutral = true
		spawn.Transparency = 1
		spawn.CanCollide = false
		spawn.Position = Region.safePoint(def.id)
		spawn.Parent = folder
		spawns[def.id] = spawn
	end
	Players.PlayerRemoving:Connect(function(p)
		notices[p] = nil
	end)
	task.spawn(function()
		while true do
			task.wait(1)
			for _, p in Players:GetPlayers() do
				G.tick(p)
			end
		end
	end)
end
return G
