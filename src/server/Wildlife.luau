--!nonstrict
local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local C = require(RS.Shared.Creatures)
local I = require(RS.Shared.Islands)
local MF = require(RS.Shared.ModelFactory)
local Rules = require(RS.Shared.CaptureRules)
local Data = require(script.Parent.DataService)
local Encounters = require(script.Parent.EncounterService)
local Pools = require(RS.Shared.EncounterPools)
local Region = require(script.Parent.RegionService)
local W = {}
local rng = Random.new()
local cooldown = setmetatable({}, { __mode = "k" })
local started = false
function W.start()
	if started then
		return
	end
	started = true
	local notice = Instance.new("RemoteEvent")
	notice.Name = "WildNotice"
	notice.Parent = RS
	local folder = Instance.new("Folder")
	folder.Name = "Selvagens"
	folder.Parent = workspace
	local slots = {}
	for _, island in I.List do
		for slot = 1, Rules.MaxPerIsland do
			table.insert(slots, { island = island, slot = slot, nextSpawn = 0 })
		end
	end
	local function spawn(s)
		local counts = {}
		for _, other in slots do
			if other.model then
				counts[other.id] = (counts[other.id] or 0) + 1
			end
		end
		local def = Pools.pick(s.island.id, rng, false, counts)
		if not def then
			return
		end
		local level = Pools.rollLevel(s.island.id, def.rar, rng)
		local m = MF.build(def, level)
		local cf, size = m:GetBoundingBox()
		local ground = I.pos(s.island.idx) + Vector3.new(s.slot == 1 and -11 or 11, 4, 6)
		local lift = m:GetPivot().Position.Y - (cf.Position.Y - size.Y / 2)
		s.home = ground + Vector3.new(0, lift, 0)
		s.model = m
		s.id = def.id
		s.level = level
		s.born = os.clock()
		m:PivotTo(CFrame.new(s.home))
		m.Parent = folder
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = Text.ENCONTRAR_FERA_2CE20D
		prompt.ObjectText = def.name .. " • " .. math.floor(Rules.chance(def.rar, level) * 100) .. "%"
		prompt.HoldDuration = 1
		prompt.MaxActivationDistance = 11
		prompt.RequiresLineOfSight = true
		prompt.Parent = m.PrimaryPart
		prompt.Triggered:Connect(function(player)
			local d = Data.get(player)
			local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if
				s.model ~= m
				or s.busy
				or not d
				or not root
				or (root.Position - m.PrimaryPart.Position).Magnitude > Rules.MaxDistance
			then
				return
			end
			if cooldown[player] and os.clock() - cooldown[player] < 1.5 then
				return
			end
			cooldown[player] = os.clock()
			local access = Region.requireCurrent(player, s.island.id, "encounter")
			if not access.ok then
				notice:FireClient(player, access.reason)
				return
			end
			if Encounters.active(player) then
				return
			end
			s.busy = true
			prompt.Enabled = false
			local opened = Encounters.open(
				player,
				{ id = def.id, lv = level, region = s.island.id, position = m.PrimaryPart.Position },
				function(remove)
					if s.model ~= m then
						return
					end
					s.busy = false
					if remove then
						s.model = nil
						m:Destroy()
						s.nextSpawn = os.clock() + Rules.RespawnSeconds
					else
						prompt.Enabled = true
						s.born = os.clock()
					end
				end
			)
			if not opened then
				s.busy = false
				prompt.Enabled = true
			end
		end)
	end
	task.spawn(function()
		while folder.Parent do
			local now = os.clock()
			for _, s in slots do
				if not s.model and now >= s.nextSpawn then
					spawn(s)
				elseif s.model and not s.busy then
					-- Movimento limitado ao trecho plano e seguro de cada ponto de encontro.
					local elapsed = now - s.born
					local pos = s.home + Vector3.new(math.sin(elapsed * 0.45) * 2, 0, math.cos(elapsed * 0.45) * 2)
					if C.ById[s.id].shape == "Bird" then
						pos += Vector3.new(0, math.max(0, math.sin(elapsed * 0.5)) * 2, 0)
					end
					s.model:SetAttribute("Moving", true)
					s.model:PivotTo(
						CFrame.lookAt(pos, pos + Vector3.new(math.cos(elapsed * 0.45), 0, -math.sin(elapsed * 0.45)))
					)
				end
			end
			task.wait(0.5)
		end
	end)
end
return W
