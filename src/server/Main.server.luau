--!nonstrict
local Players = game:GetService("Players")
local RS = game:GetService("ReplicatedStorage")
local Data = require(script.Parent.DataService)
local World = require(script.Parent.World)
local G = require(script.Parent.GameService)
local Mon = require(script.Parent.MonetizationService)
local Encounters = require(script.Parent.EncounterService)
local physics = game:GetService("PhysicsService")
pcall(function()
	physics:RegisterCollisionGroup("Creatures")
end)
physics:CollisionGroupSetCollidable("Creatures", "Default", false)
physics:CollisionGroupSetCollidable("Creatures", "Creatures", false)
Encounters.start()
World.build()
require(script.Parent.RegionGuard).start()
require(script.Parent.StartingCamp).build()
require(script.Parent.Researcher).start()
require(script.Parent.Wildlife).start()
require(script.Parent.Guardians).start()
require(script.Parent.SanctuaryBuilder).build()
local Net = Instance.new("RemoteFunction")
Net.Name = "Net"
Net.Parent = RS
local last = {}
local busy = {}
local function argument(v)
	return v == nil
		or (typeof(v) == "string" and #v <= 80)
		or (typeof(v) == "number" and v == v and math.abs(v) < 1e12 and v % 1 == 0)
end
Net.OnServerInvoke = function(p, action, a, b)
	if typeof(action) ~= "string" or not argument(a) or not argument(b) then
		return
	end
	local t = os.clock()
	if last[p] and t - last[p] < 0.15 then
		return { ok = false, msg = "Calma!" }
	end
	last[p] = t
	if Encounters.active(p) and action ~= "Get" then
		return { ok = false, msg = "Termine ou abandone o encontro primeiro." }
	end
	local f = G.Actions[action]
	if not f or not Data.get(p) then
		return { ok = false, msg = "Indisponível" }
	end
	if busy[p] then
		return { ok = false, msg = "Aguarde a ação anterior" }
	end
	busy[p] = true
	local s, r = pcall(f, p, a, b)
	busy[p] = nil
	if s then
		return r
	end
	warn(r)
	return { ok = false, msg = "Erro interno" }
end
local function join(p)
	if Data.load(p) then
		if p.Parent ~= Players then
			Data.release(p)
			return
		end
		require(script.Parent.RegionGuard).initialize(p)
		Mon.refresh(p)
		World.refresh(p)
	end
end
Players.PlayerAdded:Connect(join)
for _, p in Players:GetPlayers() do
	task.spawn(join, p)
end
Players.PlayerRemoving:Connect(function(p)
	while busy[p] do
		task.wait()
	end
	require(script.Parent.SanctuaryService).release(p)
	Data.release(p)
	last[p] = nil
	busy[p] = nil
	local f = workspace:FindFirstChild("Criaturas")
	local m = f and f:FindFirstChild(tostring(p.UserId))
	if m then
		m:Destroy()
	end
end)
task.spawn(function()
	while true do
		task.wait(60)
		Data.saveAll()
	end
end)
game:BindToClose(function()
	Data.closeAll()
end)
