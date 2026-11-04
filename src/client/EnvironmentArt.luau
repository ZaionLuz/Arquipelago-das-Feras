--!nonstrict
-- Micro-animação cenográfica e vestuário local: não altera Humanoid, saves ou colisão.
local Run = game:GetService("RunService")
local Players = game:GetService("Players")
local T = require(game:GetService("ReplicatedStorage").Shared.ArtTokens)
local E = {}
local started = false
local records = setmetatable({}, { __mode = "k" })
local function dress(character)
	local torso = character:FindFirstChild("UpperTorso")
		or character:FindFirstChild("Torso")
		or character:WaitForChild("UpperTorso", 2)
	if not torso then
		return
	end
	local old = character:FindFirstChild("ArteExplorador")
	if old then
		old:Destroy()
	end
	local model = Instance.new("Model")
	model.Name = "ArteExplorador"
	model.Parent = character
	local function cloth(name, size, offset, color)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.CFrame = torso.CFrame * CFrame.new(offset)
		p.Color = color
		p.Material = Enum.Material.SmoothPlastic
		p.Anchored = false
		p.Massless = true
		p.CanCollide = false
		p.CanTouch = false
		p.CanQuery = false
		p.CastShadow = false
		p.Parent = model
		local weld = Instance.new("WeldConstraint")
		weld.Part0 = torso
		weld.Part1 = p
		weld.Parent = p
	end
	local front = -torso.Size.Z * 0.5 - 0.06
	cloth(
		"Lenco",
		Vector3.new(torso.Size.X * 0.9, 0.18, 0.1),
		Vector3.new(0, torso.Size.Y * 0.35, front),
		T.Ramps.Tidal[3]
	)
	cloth(
		"PontaDoLenco",
		Vector3.new(0.3, 0.5, 0.1),
		Vector3.new(torso.Size.X * 0.26, torso.Size.Y * 0.1, front - 0.02),
		T.Ramps.Tidal[4]
	)
	cloth(
		"BaseDaBussola",
		Vector3.new(0.32, 0.32, 0.08),
		Vector3.new(-torso.Size.X * 0.24, 0, front - 0.01),
		T.Ramps.Sand[2]
	)
	cloth(
		"AgulhaDaBussola",
		Vector3.new(0.08, 0.22, 0.05),
		Vector3.new(-torso.Size.X * 0.24, 0, front - 0.07),
		T.Ramps.Sand[5]
	)
end
local function watch(player)
	player.CharacterAdded:Connect(function(character)
		task.defer(function()
			character:WaitForChild("HumanoidRootPart", 10)
			if character.Parent then
				dress(character)
			end
		end)
	end)
	if player.Character then
		task.defer(dress, player.Character)
	end
end
-- Público apenas para o construtor e a inspeção headless do figurino cosmético.
E.dress = dress
function E.start()
	if started then
		return
	end
	started = true
	for _, player in Players:GetPlayers() do
		watch(player)
	end
	Players.PlayerAdded:Connect(watch)
	local elapsed, scan = 0, 0
	Run.Heartbeat:Connect(function(dt)
		elapsed += dt
		scan += dt
		if elapsed < 1 / 15 then
			return
		end
		elapsed = 0
		local camera = workspace.CurrentCamera
		if not camera then
			return
		end
		local player = Players.LocalPlayer
		local quality = player:GetAttribute("GraphicsQuality") or "Médio"
		local reduced = player:GetAttribute("MotionReduced") == true
		if scan >= 1 then
			scan = 0
			for _, name in { "Arquipelago", "Santuarios" } do
				local root = workspace:FindFirstChild(name)
				if root then
					for _, obj in root:GetDescendants() do
						if obj:IsA("BasePart") and obj:GetAttribute("ArtMotion") and not records[obj] then
							records[obj] = {
								cf = obj.CFrame,
								transparency = obj.Transparency,
								kind = obj:GetAttribute("ArtMotion"),
								phase = obj:GetAttribute("ArtPhase") or 0,
							}
						end
					end
				end
			end
		end
		local time = math.floor(os.clock() * 6) / 6
		local candidates = {}
		for part, record in records do
			if not part.Parent then
				records[part] = nil
				continue
			end
			local distance = (record.cf.Position - camera.CFrame.Position).Magnitude
			if reduced or quality == "Baixo" or distance > 170 then
				if record.active then
					part.CFrame = record.cf
					part.Transparency = record.transparency
					record.active = false
				end
			else
				table.insert(candidates, { part = part, record = record, distance = distance })
			end
		end
		table.sort(candidates, function(a, b)
			return a.distance < b.distance
		end)
		local limit = quality == "Alto" and 96 or 48
		for index, item in candidates do
			local p, r = item.part, item.record
			if index > limit then
				if r.active then
					p.CFrame = r.cf
					p.Transparency = r.transparency
					r.active = false
				end
				continue
			end
			r.active = true
			local phase = time + r.phase
			if r.kind == "grass" then
				p.CFrame = r.cf * CFrame.Angles(0, 0, math.sin(phase * 2) * 0.1)
			elseif r.kind == "leaf" then
				p.CFrame = r.cf * CFrame.Angles(0.02 * math.sin(phase), 0, 0.025 * math.sin(phase * 1.3))
			elseif r.kind == "cloud" then
				p.CFrame = r.cf * CFrame.new(0, math.sin(phase * 0.7) * 0.15, 0)
			elseif r.kind == "water" then
				p.CFrame = r.cf * CFrame.new(math.sin(phase * 0.6) * 0.3, 0, 0)
				p.Transparency = math.clamp(r.transparency + math.sin(phase) * 0.1, 0, 0.8)
			elseif r.kind == "spark" then
				p.CFrame = r.cf * CFrame.new(0, math.sin(phase * 1.3) * 0.25, 0)
				p.Transparency = 0.12 + math.abs(math.sin(phase)) * 0.25
			end
		end
	end)
end
return E
