--!nonstrict
local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local I = require(RS.Shared.Islands)
local Data = require(script.Parent.DataService)
local Quest = require(RS.Shared.PhoenixQuest)
local Region = require(script.Parent.RegionService)
local B = {}
local origin = I.pos(I.ById.Dunas.idx) + Vector3.new(0, 4, -23)
function B.altarPosition()
	return origin + Vector3.new(0, 1, 0)
end
function B.build()
	local root = Instance.new("Model")
	root.Name = "RuinasAntigas"
	root.ModelStreamingMode = Enum.ModelStreamingMode.Atomic
	root.Parent = workspace
	local function part(name, size, pos, color, material, shape)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.Position = pos
		p.Color = color
		p.Material = material or Enum.Material.Sandstone
		p.Shape = shape or Enum.PartType.Block
		p.Anchored = true
		p.CanTouch = false
		p.CanCollide = false
		p.Parent = root
		return p
	end
	local floor = part(
		"Piso",
		Vector3.new(32, 0.8, 26),
		origin - Vector3.new(0, 0.8, 0),
		Color3.fromRGB(91, 72, 63),
		Enum.Material.Basalt
	)
	floor.CanCollide = true
	for _, side in { -1, 1 } do
		local wall =
			part("Muralha", Vector3.new(1, 12, 26), origin + Vector3.new(side * 16, 5, 0), Color3.fromRGB(103, 81, 67))
		wall.CanCollide = true
	end
	local rear = part("Parede", Vector3.new(32, 12, 1), origin + Vector3.new(0, 5, -13), Color3.fromRGB(103, 81, 67))
	rear.CanCollide = true
	local roof = part("Abobada", Vector3.new(32, 1, 26), origin + Vector3.new(0, 11, 0), Color3.fromRGB(72, 60, 58))
	roof.CanCollide = true
	local gate =
		part("LajeSelada", Vector3.new(10, 10, 1), origin + Vector3.new(0, 4, 13), Color3.fromRGB(158, 111, 66))
	gate:SetAttribute("AncientGate", true)
	for _, side in { -1, 1 } do
		local front = part(
			"Entrada",
			Vector3.new(11, 12, 1),
			origin + Vector3.new(side * 10.5, 5, 13),
			Color3.fromRGB(103, 81, 67)
		)
		front.CanCollide = true
	end
	local stone = Color3.fromRGB(113, 93, 79)
	local gold = Color3.fromRGB(240, 179, 66)
	for i = 1, 12 do
		local a = i * math.pi / 6
		local p = part(
			"Fragmento",
			Vector3.new(2, 7 + i % 3, 2),
			origin + Vector3.new(math.cos(a) * 13, 3, math.sin(a) * 10),
			stone
		)
		p.CFrame *= CFrame.Angles(0, a, 0.08)
		if i % 2 == 0 then
			part("Arco", Vector3.new(6, 1.3, 2.5), p.Position + Vector3.new(0, 4, 0), stone)
		end
	end
	for i = 1, 16 do
		local a = i * math.pi / 8
		local p = part(
			Text.INSCRICAO_3A97CD,
			Vector3.new(1.2, 0.12, 2),
			origin + Vector3.new(math.cos(a) * 8, 0.15, math.sin(a) * 8),
			gold,
			Enum.Material.Neon
		)
		p.CFrame *= CFrame.Angles(0, -a, 0)
	end
	local altar = part("PedraCentral", Vector3.new(1, 6, 6), origin, gold, Enum.Material.Slate, Enum.PartType.Cylinder)
	altar.CFrame *= CFrame.Angles(0, 0, math.pi / 2)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ObjectText = Text.PEDRA_ANTIGA_ACE013
	prompt.ActionText = Text.EXAMINAR_F96563
	prompt.HoldDuration = 1
	prompt.MaxActivationDistance = 12
	prompt.Parent = altar
	prompt.Triggered:Connect(function(p)
		local d = Data.get(p)
		local event = RS:FindFirstChild("WildNotice")
		if not d then
			return
		end
		local ok, reason = require(script.Parent.EncounterService).startSpecial(p, "phoenix_solar")
		if not ok and event then
			event:FireClient(
				p,
				reason == "COOLDOWN"
						and (Text.AS_MARCAS_REPOUSAM_POR_F8A177 .. math.max(0, d.phoenix.nextAttemptAt - os.time()) .. "s")
					or Text.AS_MARCAS_AINDA_NAO_RESPONDEM_A_SUA_PRESENCA_12E579
			)
		end
	end)
	for i = 1, 8 do
		local a = i * math.pi / 4
		local rock = part(
			"Rocha",
			Vector3.new(2 + i % 2, 1.5, 2),
			origin + Vector3.new(math.cos(a) * 12, 0, math.sin(a) * 9),
			stone,
			Enum.Material.Basalt
		)
		rock.CFrame *= CFrame.Angles(0.2, a, 0.15)
		local crystal = part(
			"Cristal",
			Vector3.new(0.7, 2 + i % 3, 0.7),
			rock.Position + Vector3.new(0, 1.5, 0),
			gold,
			Enum.Material.Neon
		)
		crystal.CFrame *= CFrame.Angles(0, a, 0.2)
	end
	local glyphs = {
		{ id = "duneHidden", region = "Dunas", offset = Vector3.new(27, 5, -10) },
		{ id = "duneRuin", region = "Dunas", offset = Vector3.new(-26, 15, 10) },
		{ id = "skyPeak", region = "Picos", offset = Vector3.new(20, 16, -20) },
	}
	for _, g in glyphs do
		local p = part(
			Text.VESTIGIO_A22F5D,
			Vector3.new(1.5, 2.5, 1),
			I.pos(I.ById[g.region].idx) + g.offset,
			gold,
			Enum.Material.Neon
		)
		if g.id ~= "duneHidden" then
			for step = 1, 5 do
				local platform = part(
					"Degrau",
					Vector3.new(4, 1, 4),
					p.Position + Vector3.new((step - 5) * 3, step * 2 - 11, 0),
					stone
				)
				platform.CanCollide = true
			end
		else
			for _, side in { -1, 1 } do
				part(
					"Abrigo",
					Vector3.new(2, 5, 4),
					p.Position + Vector3.new(side * 2, -0.5, 0),
					stone,
					Enum.Material.Basalt
				)
			end
		end
		local glyphPrompt = Instance.new("ProximityPrompt")
		glyphPrompt.ObjectText = Text.MARCA_ANTIGA_9C4D11
		glyphPrompt.ActionText = Text.EXAMINAR_F96563
		glyphPrompt.HoldDuration = 0.5
		glyphPrompt.MaxActivationDistance = 10
		glyphPrompt.Parent = p
		glyphPrompt.Triggered:Connect(function(player)
			local d = Data.get(player)
			local hrp = player.Character and player.Character:FindFirstChild("HumanoidRootPart")
			if
				not d
				or not hrp
				or (hrp.Position - p.Position).Magnitude > 12
				or not Region.requireCurrent(player, g.region, "encounter").ok
			then
				return
			end
			if not Quest.Glyphs[g.id] or d.phoenix.glyphs[g.id] then
				return
			end
			d.phoenix.glyphs[g.id] = true
			d.phoenix.sanctuaryOpen = Quest.stage(d) == 3
			local event = RS:FindFirstChild("WildNotice")
			if event then
				event:FireClient(player, Quest.public(d).hint)
			end
		end)
	end
	local parts = 0
	for _, obj in root:GetDescendants() do
		if obj:IsA("BasePart") then
			parts += 1
		end
	end
	assert(parts <= 400, Text.RUINAS_EXCEDEM_ORCAMENTO_6CD117)
end
return B
