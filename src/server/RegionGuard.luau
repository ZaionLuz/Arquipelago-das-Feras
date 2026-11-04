--!nonstrict
local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local I = require(RS.Shared.Islands)
local Access = require(RS.Shared.Access)
local Data = require(script.Parent.DataService)
local Region = require(script.Parent.RegionService)
local G = {}
local spawns = {}
local lastNotice = {}
function G.best(d)
	local best = "Alvorecer"
	for _, def in I.List do
		if Access.check(d, def.id, "travel").ok then
			best = def.id
		end
	end
	return best
end
function G.inspect(d, s, position)
	local id = Region.detect(position)
	if not id then
		return { ok = true }
	end
	local access = Access.check(d, id, "travel")
	if access.ok and s.region == id then
		return { ok = true, island = id }
	end
	return { ok = false, reason = access.ok and "WRONG_REGION" or access.reason, safe = s.lastSafe or "Alvorecer" }
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
			s.region = s.lastSafe
		end
		s.spawning = false
	end
	p.CharacterAdded:Connect(respawn)
	if p.Character then
		task.spawn(respawn, p.Character)
	end
end
function G.start()
	local root = Instance.new("Folder")
	root.Name = "PontosSeguros"
	root.Parent = workspace
	for _, def in I.List do
		local spawn = Instance.new("SpawnLocation")
		spawn.Name = def.id
		spawn.Size = Vector3.new(8, 1, 8)
		spawn.Anchored = true
		spawn.Neutral = true
		spawn.Transparency = 1
		spawn.CanCollide = false
		spawn.Position = Region.safePoint(def.id)
		spawn.Parent = root
		spawns[def.id] = spawn
	end
	Players.PlayerRemoving:Connect(function(p)
		lastNotice[p] = nil
	end)
	task.spawn(function()
		while true do
			task.wait(1)
			for _, p in Players:GetPlayers() do
				local d = Data.get(p)
				local s = Data.session(p)
				local char = p.Character
				local part = char and char:FindFirstChild("HumanoidRootPart")
				if not d or not s or not part or s.transporting or s.spawning then
					continue
				end
				local inspection = G.inspect(d, s, part.Position)
				local id = inspection.island
				if id or not inspection.ok then
					if inspection.ok then
						s.lastSafe = id
						p.RespawnLocation = spawns[id]
					else
						char:PivotTo(CFrame.new(Region.safePoint(s.lastSafe)))
						s.region = s.lastSafe
						if not lastNotice[p] or os.clock() - lastNotice[p] > 3 then
							local event = RS:FindFirstChild("WildNotice")
							if event then
								event:FireClient(p, Text.REGIAO_BLOQUEADA_47B5A8 .. inspection.reason)
							end
							lastNotice[p] = os.clock()
						end
					end
				end
			end
		end
	end)
end
return G
