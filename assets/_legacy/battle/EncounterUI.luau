--!nonstrict
local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local TS = game:GetService("TweenService")
local C = require(RS.Shared.Creatures)
local MF = require(RS.Shared.ModelFactory)
local Elements = require(RS.Shared.Elements)
local Theme = require(script.Parent.UITheme)
local CaptureRules = require(RS.Shared.CaptureRules)
local Skills = require(RS.Shared.Skills)
local CAS = game:GetService("ContextActionService")
local Solar = require(script.Parent.SolarPresentation)
local Animator = require(script.Parent.CreatureAnimator)
local UI = {}
function UI.start(gui, getOwned, onClose, onOpen)
	local net = RS:WaitForChild("EncounterNet")
	local state
	local busy = false
	local presenting = false
	local animation = 0
	local root
	local panel
	local viewport
	local figures
	local foeModel
	local allyModel
	local allyKey
	local actions
	local roster
	local title
	local status
	local hpMine
	local hpFoe
	local chance
	local resize
	local function destroy()
		CAS:UnbindAction("FerasEncounterMovement")
		if resize then
			resize:Disconnect()
			resize = nil
		end
		if root then
			root:Destroy()
			root = nil
		end
		animation += 1
		state = nil
		busy = false
		presenting = false
		onClose()
	end
	gui.Destroying:Once(function()
		CAS:UnbindAction("FerasEncounterMovement")
	end)
	local function pose(model, x)
		local cf, size = model:GetBoundingBox()
		local lift = model:GetPivot().Position.Y - (cf.Position.Y - size.Y / 2)
		model:PivotTo(CFrame.new(x, lift, 0) * CFrame.Angles(0, x < 0 and math.pi / 2 or -math.pi / 2, 0))
	end
	local function impact(element, position)
		if
			game:GetService("Players").LocalPlayer:GetAttribute("MotionReduced")
			or game:GetService("Players").LocalPlayer:GetAttribute("GraphicsQuality") == "Baixo"
		then
			return
		end
		local orb = figures:FindFirstChild("ElementImpact")
		if not orb then
			orb = Instance.new("Part")
			orb.Name = "ElementImpact"
			orb.Shape = Enum.PartType.Ball
			orb.Anchored = true
			orb.CanCollide = false
			orb.CanQuery = false
			orb.CanTouch = false
			orb.Material = Enum.Material.Neon
			orb.Parent = figures
		end
		orb.Color = Elements.Color[element]
		orb.Position = position
		orb.Size = Vector3.one * 0.5
		orb.Transparency = 0.2
		TS:Create(orb, TweenInfo.new(0.35), { Size = Vector3.one * 7, Transparency = 1 }):Play()
	end
	local render
	local function request(action, uid)
		if busy or presenting or not state then
			return
		end
		busy = true
		status.Text = Text.RESOLVENDO_TURNO_8CA931
		task.spawn(function()
			local ok, response = pcall(net.InvokeServer, net, state.token, state.version, action, uid)
			busy = false
			if not root then
				return
			end
			if ok and response then
				local changed = response.version ~= state.version
				state = response
				render(changed)
			else
				status.Text = Text.CONEXAO_INDISPONIVEL_TOQUE_ATUALIZAR_PARA_RECUPE_DAB864
			end
		end)
	end
	local function health(label, unit, name)
		label.Text = name
			.. "\n"
			.. (
				unit and (unit.hp .. " / " .. unit.maxHp .. Text.PV_33D16B)
				or Text.ESCOLHA_UMA_FERA_PARA_BATALHAR_462F3D
			)
		label.TextColor3 = unit and unit.hp <= unit.maxHp * 0.3 and Color3.fromRGB(255, 166, 140) or Theme.Ink
		local track = label:FindFirstChild("Meter")
		if not track then
			track = Instance.new("Frame")
			track.Name = "Meter"
			track.Position = UDim2.new(0.04, 0, 1, -4)
			track.Size = UDim2.new(0.92, 0, 0, 4)
			track.BackgroundColor3 = Theme.Card
			track.Parent = label
			Theme.round(track, 2)
			local fill = Instance.new("Frame")
			fill.Name = "Fill"
			fill.Size = UDim2.fromScale(1, 1)
			fill.BorderSizePixel = 0
			fill.Parent = track
			Theme.round(fill, 2)
		end
		track.Fill.BackgroundColor3 = label.TextColor3 == Theme.Ink and Theme.Mint or Color3.fromRGB(235, 135, 114)
		TS:Create(track.Fill, TweenInfo.new(0.3), { Size = UDim2.fromScale(unit and unit.hp / unit.maxHp or 0, 1) })
			:Play()
	end
	render = function(animate)
		if not root then
			return
		end
		animation += 1
		local job = animation
		presenting = false
		if game:GetService("Players").LocalPlayer:GetAttribute("MotionReduced") then
			animate = false
		end
		title.Text = C.ById[state.foe.id].name
			.. Text.NV_9D89AA
			.. state.foe.lv
			.. " • "
			.. C.Rarity[C.ById[state.foe.id].rar]
		chance.Text = Text.CAPTURA_9BC665
			.. math.floor(state.chance * 100)
			.. Text.SELOS_D7B365
			.. (state.seals or 0)
			.. Text.VINCULO_80DA3F
			.. state.bond
			.. "/3"
		if state.capturable == false then
			chance.Text = Text.DESAFIO_DO_GUARDIAO_NAO_PERMITE_CAPTURA_1198C8
		end
		local pet = state.active and state.party[state.active]
		health(hpFoe, state.foe, Text.SELVAGEM_959EBB)
		health(hpMine, pet, pet and C.ById[pet.id].name or Text.SUA_EQUIPE_C6DEB4)
		if not foeModel or not foeModel.Parent then
			foeModel = MF.build(C.ById[state.foe.id], state.foe.lv, { preview = true })
			foeModel.Parent = figures
			pose(foeModel, 8)
			Animator.register(foeModel, function()
				return root ~= nil
			end)
		end
		local foe = foeModel
		local key = pet and state.active .. ":" .. pet.lv or "none"
		if key ~= allyKey then
			if allyModel then
				allyModel:Destroy()
				allyModel = nil
			end
			if pet then
				allyModel = MF.build(C.ById[pet.id], pet.lv, { preview = true })
				allyModel.Parent = figures
				pose(allyModel, -8)
				Animator.register(allyModel, function()
					return root ~= nil
				end)
			end
			allyKey = key
		end
		local ally = allyModel
		local teamLevel = pet and pet.lv or 1
		for _, owned in getOwned() do
			teamLevel = math.max(teamLevel, owned.lv)
		end
		local delta = state.foe.lv - teamLevel
		title.TextColor3 = delta < 0 and Theme.Mint
			or delta < 4 and Color3.fromRGB(243, 220, 133)
			or delta < 8 and Color3.fromRGB(244, 167, 94)
			or Color3.fromRGB(250, 118, 110)
		if delta >= 8 then
			title.Text ..= Text.PERIGO_DC2EAE .. delta
		end
		if state.intro == "phoenix" then
			title.Text = Text.FENIX_LENDARIA_NV_60_A1FE17
		end
		if animate and #state.log > 0 then
			presenting = true
			task.spawn(function()
				for _, event in state.log do
					if not root or not foe.Parent or animation ~= job then
						break
					end
					status.Text = event.text
					local target = event.kind == "hit" and ally or event.kind == "foe" and foe
					if target then
						Animator.play(target, "attack", 0.4)
						local defender = target == ally and foe or ally
						if defender then
							Animator.play(defender, "damage", 0.4)
							impact(C.ById[target:GetAttribute("Species")].el, defender:GetPivot().Position)
						end
						local start = target:GetPivot()
						local toward = event.kind == "hit" and 2 or -2
						local pivot = Instance.new("CFrameValue")
						pivot.Value = start
						local connection = pivot.Changed:Connect(function(v)
							if target.Parent then
								target:PivotTo(v)
							end
						end)
						local tween = TS:Create(
							pivot,
							TweenInfo.new(0.15, Enum.EasingStyle.Quad, Enum.EasingDirection.Out, 0, true),
							{ Value = start + CFrame.new(toward, 0, 0).Position }
						)
						tween:Play()
						tween.Completed:Wait()
						connection:Disconnect()
						pivot:Destroy()
					elseif event.kind == "faint" and ally then
						Animator.play(ally, "faint", 0.6)
					elseif event.kind == "win" and state.intro ~= "phoenix" then
						if ally then
							Animator.play(ally, "victory", 0.8)
						end
						Animator.play(foe, "faint", 0.6)
					elseif
						(event.kind == "win" or state.status == "escaped")
						and state.intro == "phoenix"
						and foe.Parent
					then
						local start = foe:GetPivot()
						local value = Instance.new("CFrameValue")
						value.Value = start
						local change = value.Changed:Connect(function(cf)
							if foe.Parent then
								foe:PivotTo(cf)
							end
						end)
						local tween = TS:Create(value, TweenInfo.new(0.6), { Value = start + Vector3.new(0, 16, 0) })
						tween:Play()
						tween.Completed:Wait()
						change:Disconnect()
						value:Destroy()
					elseif event.kind == "capture" or event.kind == "miss" or event.kind == "bond" then
						local orb = Instance.new("Part")
						orb.Shape = Enum.PartType.Ball
						orb.Anchored = true
						orb.CanCollide = false
						orb.Material = Enum.Material.Neon
						orb.Color = Theme.Accent
						orb.Size = Vector3.one * 2
						orb.Position = foe:GetPivot().Position
						orb.Parent = figures
						TS:Create(orb, TweenInfo.new(0.4), { Size = Vector3.one * 12, Transparency = 1 }):Play()
						task.wait(0.4)
						orb:Destroy()
					end
					task.wait(0.25)
				end
				if animation == job then
					presenting = false
				end
			end)
		end
		if not animate and #state.log > 0 then
			status.Text = state.log[#state.log].text
		end
		if state.message then
			status.Text = state.message
		elseif #state.log == 0 then
			status.Text = Text.CAPTURE_DIRETAMENTE_OU_ESCOLHA_UMA_FERA_PARA_ENF_DF3AFD
		end
		for _, o in actions:GetChildren() do
			if o:IsA("GuiButton") then
				o:Destroy()
			end
		end
		local buttons = state.status == "active"
				and {
					{ Text.GOLPE_EF9EC5, "Strike" },
					{ pet and Skills[C.ById[pet.id].shape].name or Text.HABILIDADE_8425E4, "Skill" },
					{ Text.PROTEGER_RECUPERAR_0A724A, "Guard" },
					{ Text.CRIAR_VINCULO_A663E9, "Bond" },
					{ Text.LANCAR_SELO_CDEDAC, "Capture" },
					{ Text.SELO_0B67C2 .. CaptureRules.Seals[state.sealType or "Basic"].name, "ChooseSeal" },
					{ Text.FUGIR_2C0D38, "Flee" },
					{ Text.ATUALIZAR_7ED81F, "State" },
				}
			or {
				{
					state.status == "captured" and Text.CAPTUROU_CONTINUAR_7DA1D5
						or state.status == "won" and Text.VITORIA_CONTINUAR_52F863
						or Text.VOLTAR_A_EXPLORACAO_8F4A4A,
					"Close",
				},
			}
		for _, entry in buttons do
			if
				state.capturable == false and (entry[2] == "Capture" or entry[2] == "Bond" or entry[2] == "ChooseSeal")
			then
				continue
			end
			local available = true
			if state.status == "active" then
				if entry[2] == "Strike" or entry[2] == "Guard" or entry[2] == "Skill" then
					available = pet ~= nil and pet.hp > 0
				end
				if entry[2] == "Skill" and pet and state.turn < (pet.nextSkill or 0) then
					available = false
					entry[1] ..= Text.RECARREGANDO_C160E2
				end
				if entry[2] == "Capture" and (state.seals or 0) < 1 then
					available = false
				end
			end
			local b = Theme.button(actions, entry[1], function()
				if entry[2] == "Close" then
					destroy()
				elseif entry[2] == "ChooseSeal" then
					local index = table.find(CaptureRules.SealOrder, state.sealType or "Basic") or 1
					request("ChooseSeal", CaptureRules.SealOrder[index % #CaptureRules.SealOrder + 1])
				else
					request(entry[2])
				end
			end)
			b.Active = available
			b.Selectable = available
			b.BackgroundTransparency = available and 0 or 0.6
		end
		for _, o in roster:GetChildren() do
			if o:IsA("GuiButton") then
				o:Destroy()
			end
		end
		if state.status == "active" then
			local owned = getOwned()
			local ids = {}
			for uid in owned do
				table.insert(ids, uid)
			end
			table.sort(ids)
			for _, uid in ids do
				local creature = owned[uid]
				local unit = state.party[uid]
				local b = Theme.button(
					roster,
					(uid == state.active and "● " or "")
						.. C.ById[creature.id].name
						.. " • "
						.. (unit and unit.hp .. Text.PV_33D16B or "Nv." .. creature.lv),
					function()
						request("Select", uid)
					end
				)
				b.Size = UDim2.fromOffset(155, 44)
			end
		end
	end
	local function show(data)
		if root then
			destroy()
		end
		onOpen()
		state = data
		CAS:BindActionAtPriority("FerasEncounterMovement", function()
			return Enum.ContextActionResult.Sink
		end, false, 3000, table.unpack(Enum.PlayerActions:GetEnumItems()))
		foeModel = nil
		allyModel = nil
		allyKey = nil
		root = Instance.new("Frame")
		root.Size = UDim2.fromScale(1, 1)
		root.BackgroundColor3 = Color3.new(0, 0, 0)
		root.BackgroundTransparency = 0.35
		root.ZIndex = 50
		root.Active = true
		root.Parent = gui
		panel = Instance.new("Frame")
		panel.AnchorPoint = Vector2.new(0.5, 0.5)
		panel.Position = UDim2.fromScale(0.5, 0.5)
		panel.BackgroundColor3 = Theme.Panel
		panel.Parent = root
		Theme.round(panel, 18)
		Theme.stroke(panel)
		local function layout()
			local size = gui.AbsoluteSize
			local w = math.min(860, size.X - 16)
			local h = math.min(720, size.Y - 16)
			panel.Size = UDim2.fromOffset(w, h)
		end
		layout()
		resize = gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(layout)
		title = Theme.label(panel, "", 18)
		title.Position = UDim2.new(0.03, 0, 0, 10)
		title.Size = UDim2.new(0.94, 0, 0, 32)
		viewport = Instance.new("ViewportFrame")
		viewport.Position = UDim2.fromScale(0.02, 0.16)
		viewport.Size = UDim2.fromScale(0.96, 0.36)
		viewport.BackgroundColor3 = Color3.fromRGB(29, 54, 58)
		viewport.Ambient = Color3.fromRGB(185, 202, 210)
		viewport.LightDirection = Vector3.new(-1, -1, -1)
		viewport.Parent = panel
		Theme.round(viewport)
		local world = Instance.new("WorldModel")
		world.Parent = viewport
		figures = Instance.new("Folder")
		figures.Parent = world
		local floor = Instance.new("Part")
		floor.Size = Vector3.new(60, 1, 30)
		floor.Position = Vector3.new(0, -0.5, 0)
		floor.Anchored = true
		floor.Color = Color3.fromRGB(57, 87, 78)
		floor.Material = Enum.Material.Grass
		floor.Parent = world
		local cam = Instance.new("Camera")
		cam.FieldOfView = 48
		cam.CFrame = CFrame.lookAt(Vector3.new(0, 14, 37), Vector3.new(0, 5, 0))
		cam.Parent = viewport
		viewport.CurrentCamera = cam
		hpMine = Theme.label(panel, "", 14)
		hpMine.Position = UDim2.fromScale(0.03, 0.07)
		hpMine.Size = UDim2.fromScale(0.44, 0.09)
		hpFoe = Theme.label(panel, "", 14)
		hpFoe.Position = UDim2.fromScale(0.53, 0.07)
		hpFoe.Size = UDim2.fromScale(0.44, 0.09)
		chance = Theme.label(panel, "", 13)
		chance.Position = UDim2.fromScale(0.03, 0.52)
		chance.Size = UDim2.fromScale(0.94, 0.05)
		status = Theme.label(panel, "", 14)
		status.Position = UDim2.fromScale(0.03, 0.57)
		status.Size = UDim2.fromScale(0.94, 0.08)
		roster = Instance.new("ScrollingFrame")
		roster.BackgroundTransparency = 1
		roster.Position = UDim2.fromScale(0.03, 0.65)
		roster.Size = UDim2.new(0.94, 0, 0, 48)
		roster.AutomaticCanvasSize = Enum.AutomaticSize.X
		roster.CanvasSize = UDim2.new()
		roster.ScrollBarThickness = 3
		roster.Parent = panel
		local rl = Instance.new("UIListLayout")
		rl.FillDirection = Enum.FillDirection.Horizontal
		rl.Padding = UDim.new(0, 8)
		rl.Parent = roster
		actions = Instance.new("ScrollingFrame")
		actions.Position = UDim2.new(0.03, 0, 0.65, 54)
		actions.Size = UDim2.new(0.94, 0, 0.35, -62)
		actions.BackgroundTransparency = 1
		actions.CanvasSize = UDim2.new()
		actions.AutomaticCanvasSize = Enum.AutomaticSize.Y
		actions.ScrollBarThickness = 3
		actions.Parent = panel
		local grid = Instance.new("UIGridLayout")
		grid.CellSize = UDim2.new(0.5, -5, 0, 44)
		grid.CellPadding = UDim2.fromOffset(8, 8)
		grid.Parent = actions
		render(false)
		if state.intro == "phoenix" then
			presenting = true
			local introJob = animation
			task.spawn(function()
				Solar.intro(panel, viewport, foeModel, function()
					return root ~= nil and animation == introJob
				end)
				if animation == introJob then
					presenting = false
				end
			end)
		end
	end
	RS:WaitForChild("EncounterNotice").OnClientEvent:Connect(show)
	task.spawn(function()
		local ok, data = pcall(net.InvokeServer, net, "", 0, "Resume")
		if ok and data and not root then
			show(data)
		end
	end)
end
return UI
