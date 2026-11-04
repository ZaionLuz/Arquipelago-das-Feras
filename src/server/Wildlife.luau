--!nonstrict
local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local C = require(RS.Shared.Creatures)
local I = require(RS.Shared.Islands)
local Layout = require(RS.Shared.WorldLayout)
local MF = require(RS.Shared.ModelFactory)
local Rules = require(RS.Shared.CaptureRules)
local Data = require(script.Parent.DataService)
local Encounters = require(script.Parent.EncounterService)
local Pools = require(RS.Shared.EncounterPools)
local Region = require(script.Parent.RegionService)
local W = { SlotsPerRegion = 8, SpawnDistance = 300, DespawnDistance = 440, DespawnGrace = 15 }
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
		for slot = 1, W.SlotsPerRegion do
			table.insert(slots, {
				island = island,
				slot = slot,
				ground = I.pos(island.idx) + Layout.wildOffset(slot),
				nextSpawn = 0,
			})
		end
	end
	local function despawn(s, respawnAt)
		local model = s.model
		s.model = nil
		s.busy = false
		s.awaySince = nil
		s.nextSpawn = respawnAt or 0
		if model then
			model:Destroy()
		end
	end
	local function spawn(s)
		-- A mesma espécie pode povoar regiões diferentes; a densidade é regional.
		local counts = {}
		for _, other in slots do
			if other.model and other.island.id == s.island.id then
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
		local lift = m:GetPivot().Position.Y - (cf.Position.Y - size.Y / 2)
		s.home = s.ground + Vector3.new(0, lift, 0)
		s.model = m
		s.id = def.id
		s.level = level
		s.born = os.clock()
		s.awaySince = nil
		m:PivotTo(CFrame.new(s.home))
		m:SetAttribute("WildRegion", s.island.id)
		m:SetAttribute("WildSlot", s.slot)
		m.Parent = folder
		local prompt = Instance.new("ProximityPrompt")
		prompt.ActionText = Text.ENCONTRAR_FERA_2CE20D
		prompt.ObjectText = def.name .. " • Nv." .. level
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
			-- Reserva antes de chamar o serviço: outra ativação nunca compartilha o animal.
			s.busy = true
			prompt.Enabled = false
			local succeeded, opened = pcall(
				Encounters.open,
				player,
				{ id = def.id, lv = level, region = s.island.id, position = m.PrimaryPart.Position },
				function(remove)
					if s.model ~= m then
						return
					end
					s.busy = false
					s.awaySince = nil
					if remove then
						despawn(s, os.clock() + Rules.RespawnSeconds)
					else
						prompt.Enabled = true
						s.born = os.clock()
					end
				end
			)
			if not succeeded then
				warn("Encontro indisponível: " .. tostring(opened))
			end
			if not succeeded or not opened then
				if s.model == m then
					s.busy = false
					prompt.Enabled = true
				end
			end
		end)
	end
	Players.PlayerRemoving:Connect(function(player)
		cooldown[player] = nil
	end)
	task.spawn(function()
		while folder.Parent do
			local now = os.clock()
			-- Uma busca por pulso para todos os slots, sem thread ou heartbeat por criatura.
			local observers = {}
			for _, player in Players:GetPlayers() do
				local root = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
				if root and Data.get(player) then
					table.insert(observers, root.Position)
				end
			end
			for _, s in slots do
				local distance = math.huge
				for _, position in observers do
					distance = math.min(distance, (position - s.ground).Magnitude)
				end
				if not s.model then
					if distance <= W.SpawnDistance and now >= s.nextSpawn then
						local ok, problem = pcall(spawn, s)
						if not ok then
							if s.model then
								despawn(s, now + 5)
							else
								s.nextSpawn = now + 5
							end
							warn("Não foi possível apresentar a fera: " .. tostring(problem))
						end
					end
				elseif not s.busy then
					if distance > W.DespawnDistance then
						s.awaySince = s.awaySince or now
						if now - s.awaySince >= W.DespawnGrace then
							despawn(s)
						end
					else
						s.awaySince = nil
						local elapsed = now - s.born + s.slot * 0.7
						local pos = s.home + Vector3.new(math.sin(elapsed * 0.35) * 6, 0, math.cos(elapsed * 0.35) * 6)
						if C.ById[s.id].shape == "Bird" then
							pos += Vector3.new(0, math.max(0, math.sin(elapsed * 0.5)) * 2, 0)
						end
						s.model:SetAttribute("Moving", true)
						s.model:PivotTo(
							CFrame.lookAt(
								pos,
								pos + Vector3.new(math.cos(elapsed * 0.35), 0, -math.sin(elapsed * 0.35))
							)
						)
					end
				end
			end
			task.wait(0.5)
		end
	end)
end
return W
