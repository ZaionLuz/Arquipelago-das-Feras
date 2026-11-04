--!nonstrict
local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")
local Lighting = game:GetService("Lighting")
local TS = game:GetService("TweenService")
local Missions = require(RS.Shared.Missions)
local Sounds = require(RS.Shared.Sounds)
local SS = game:GetService("SoundService")
local C = require(RS.Shared.Creatures)
local I = require(RS.Shared.Islands)
local Net = RS:WaitForChild("Net")
local gui = Instance.new("ScreenGui")
gui.ResetOnSpawn = false
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.ScreenInsets = Enum.ScreenInsets.DeviceSafeInsets
gui.Parent = Players.LocalPlayer:WaitForChild("PlayerGui")
local S, tab, isl, pick, snapAt = nil, Text.FERAS_EF033A, "Alvorecer", {}, os.clock()
local render
local tabBtn = {}
local tutorial
local CollectionUI = require(script.Parent.CollectionUI)
local inFlight = false
local Breeding = require(RS.Shared.Breeding)
local Balance = require(RS.Shared.Economy)
local Nursery = require(script.Parent.NurseryUI)
local Journal = require(script.Parent.JournalUI)
local Theme = require(script.Parent.UITheme)
local PixelIcons = require(script.Parent.PixelIcons)
local BattleStage = require(script.Parent.BattleStage)
local ArtOverlay = require(script.Parent.ArtOverlay)
local loading = ArtOverlay.loading(gui)
local SanctuaryUI = require(script.Parent.SanctuaryUI)
local Story = require(RS.Shared.Story)
local Progression = require(RS.Shared.Progression)
local CaptureRules = require(RS.Shared.CaptureRules)
local Strings = require(RS.Shared.Strings)
local Bands = require(RS.Shared.LevelBands)
local LocalPlayer = Players.LocalPlayer
LocalPlayer:SetAttribute("GraphicsQuality", Text.MEDIO_4F48C1)
local function mk(cls, props, parent)
	local o = Instance.new(cls)
	for k, v in props do
		o[k] = v
	end
	if cls == "TextButton" or cls == "Frame" or cls == "ScrollingFrame" then
		Theme.round(o)
		if cls ~= "ScrollingFrame" and props.BackgroundTransparency ~= 1 then
			Theme.stroke(o)
		end
	end
	if (cls == "TextButton" or cls == "TextLabel") and o.TextScaled then
		Instance.new("UITextSizeConstraint", o).MaxTextSize = 28
	end
	if cls == "TextButton" then
		o.Active = true
		o.Selectable = true
		Theme.bind(o)
	end
	if cls == "TextLabel" or cls == "TextButton" then
		o.Font = Theme.Font
	end
	o.Parent = parent
	return o
end
local WHITE = Theme.Ink
local drawerOpen = false
local top = mk(
	"Frame",
	{ Position = UDim2.fromOffset(8, 8), Size = UDim2.new(0.72, -8, 0, 40), BackgroundColor3 = Theme.Panel },
	gui
)
local resourceValues = {}
local function resourceAmount(n)
	if n >= 1e9 then
		return ("%.1fb"):format(n / 1e9)
	elseif n >= 1e6 then
		return ("%.1fm"):format(n / 1e6)
	elseif n >= 1e3 then
		return math.floor(n / 1e3) .. "k"
	end
	return tostring(n)
end
local resourceKinds = { "Fera", "Coin", "Gem", "Seal" }
for index, kind in resourceKinds do
	local holder = mk(
		"Frame",
		{ Position = UDim2.fromScale((index - 1) / 4, 0), Size = UDim2.fromScale(0.25, 1), BackgroundTransparency = 1 },
		top
	)
	local icon = PixelIcons.draw(holder, kind, 1)
	icon.Position = UDim2.fromOffset(4, 12)
	local value = mk("TextLabel", {
		Position = UDim2.fromOffset(24, 0),
		Size = UDim2.new(1, -26, 1, 0),
		BackgroundTransparency = 1,
		Text = "0",
		TextSize = 12,
		TextColor3 = Theme.Ink,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, holder)
	resourceValues[index] = value
end
local msg = mk("TextLabel", {
	Position = UDim2.new(0, 8, 0, 62),
	Size = UDim2.new(1, -16, 0, 28),
	BackgroundTransparency = 1,
	TextColor3 = Theme.Accent,
	TextStrokeTransparency = 0.4,
	TextScaled = true,
	Font = Theme.Font,
}, gui)
local list = mk("ScrollingFrame", {
	Visible = false,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -8, 0.22, 0),
	Size = UDim2.new(0.9, 0, 0.66, -8),
	BackgroundColor3 = Theme.Panel,
	BackgroundTransparency = 0.15,
	CanvasSize = UDim2.new(),
	AutomaticCanvasSize = Enum.AutomaticSize.Y,
}, gui)
mk("UISizeConstraint", { MaxSize = Vector2.new(440, 1000) }, list)
mk("UIListLayout", { Padding = UDim.new(0, 8), SortOrder = Enum.SortOrder.LayoutOrder }, list)
local xpTrack = mk(
	"Frame",
	{ Position = UDim2.fromOffset(8, 52), Size = UDim2.new(0.72, -8, 0, 4), BackgroundColor3 = Theme.Card },
	gui
)
local xpFill = mk("Frame", { Size = UDim2.fromScale(0, 1), BackgroundColor3 = Theme.Mint }, xpTrack)
local objective = mk("TextLabel", {
	Position = UDim2.fromOffset(12, 62),
	Size = UDim2.new(0.7, 0, 0, 36),
	BackgroundTransparency = 1,
	TextColor3 = Theme.Ink,
	TextSize = 12,
	TextWrapped = true,
	Font = Theme.Font,
}, gui)
local muted = false
local function sfx(n)
	if muted or Sounds[n] == "" then
		return
	end
	local s = Instance.new("Sound")
	s.SoundId = Sounds[n]
	s.Volume = 0.6
	s.Parent = SS
	s.Ended:Once(function()
		s:Destroy()
	end)
	s:Play()
end
-- Efeito de golpe por elemento: projétil com trajetória própria + explosão de partículas + onda de choque.
local FX = {
	Fogo = { shape = "Ball", size = 3, path = "line", n = 45, spd = 34 },
	[Text.AGUA_F11A05] = { shape = "Ball", size = 2.5, path = "arc", n = 35, spd = 22 },
	Natureza = { shape = "Block", size = 2, path = "line", n = 28, spd = 18, spin = true },
	Terra = { shape = "Block", size = 4, path = "drop", n = 30, spd = 26 },
	Ar = { shape = "Cylinder", size = 1.5, path = "line", n = 40, spd = 40, spin = true },
	Sombra = { shape = "Ball", size = 3, path = "arc", n = 40, spd = 14 },
}
local function fx(el, a, b)
	if
		LocalPlayer:GetAttribute("GraphicsQuality") == Text.BAIXO_74FD00 or LocalPlayer:GetAttribute("MotionReduced")
	then
		return
	end
	local d = FX[el]
	local c = Theme.Tokens.Elements[el][4]
	local arena = workspace:FindFirstChild(Text.ARENA_1A4BA8)
	if not arena then
		return
	end
	local p = Instance.new("Part")
	p.Anchored = true
	p.CanCollide = false
	p.Shape = Enum.PartType[d.shape]
	p.Size = Vector3.one * d.size
	p.Material = Enum.Material.Neon
	p.Color = c
	p.Parent = arena
	local e = Instance.new("ParticleEmitter")
	e.Rate = 60
	e.Lifetime = NumberRange.new(0.4)
	e.Speed = NumberRange.new(1, 3)
	e.Color = ColorSequence.new(c)
	e.LightEmission = 1
	e.Size = NumberSequence.new(d.size * 0.6, 0)
	e.Parent = p
	local start = d.path == "drop" and b + Vector3.new(0, 25, 0) or a
	local t0 = os.clock()
	while true do
		local k = (os.clock() - t0) / 0.35
		if k >= 1 then
			break
		end
		local pos = start:Lerp(b, k)
		if d.path == "arc" then
			pos += Vector3.new(0, math.sin(k * math.pi) * 8, 0)
		end
		p.CFrame = CFrame.new(pos) * (d.spin and CFrame.Angles(k * 12, k * 9, 0) or CFrame.identity)
		task.wait()
	end
	p.CFrame = CFrame.new(b)
	p.Transparency = 1
	e.Rate = 0
	e.Speed = NumberRange.new(d.spd * 0.5, d.spd)
	e.Lifetime = NumberRange.new(0.5, 0.9)
	e:Emit(d.n)
	local ring = Instance.new("Part")
	ring.Shape = Enum.PartType.Ball
	ring.Anchored = true
	ring.CanCollide = false
	ring.Material = Enum.Material.Neon
	ring.Color = c
	ring.Size = Vector3.one
	ring.Transparency = 0.3
	ring.Position = b
	ring.Parent = arena
	TS:Create(ring, TweenInfo.new(0.4), { Size = Vector3.one * 14, Transparency = 1 }):Play()
	task.delay(1, function()
		p:Destroy()
		ring:Destroy()
	end)
end
-- Batalha animada: o servidor decide o resultado; aqui só se reproduz o log de golpes.
local function playBattle(b)
	local MF = require(RS.Shared.ModelFactory)
	local cam = workspace.CurrentCamera
	local o = Vector3.new(0, 300, 0)
	local ct = cam.CameraType
	local originalCF, originalFov, originalFocus = cam.CFrame, cam.FieldOfView, cam.Focus
	local stage = Instance.new("Folder")
	stage.Name = Text.ARENA_1A4BA8
	stage.Parent = workspace
	BattleStage.build(stage, BattleStage.resolve(C.ById[b.foe.id]), o)
	local function face(pos, to)
		return CFrame.lookAt(pos, pos + (pos - to))
	end
	local pa, pf = o + Vector3.new(-8, 5, 0), o + Vector3.new(8, 5, 0)
	local a = MF.build(C.ById[b.me.id], b.me.lv)
	local f = MF.build(C.ById[b.foe.id], b.foe.lv)
	local ac, asz = a:GetBoundingBox()
	local fc, fsz = f:GetBoundingBox()
	pa = Vector3.new(pa.X, o.Y + 0.42 + a:GetPivot().Position.Y - (ac.Position.Y - asz.Y * 0.5), pa.Z)
	pf = Vector3.new(pf.X, o.Y + 0.42 + f:GetPivot().Position.Y - (fc.Position.Y - fsz.Y * 0.5), pf.Z)
	a:PivotTo(face(pa, pf))
	f:PivotTo(face(pf, pa))
	a.Parent = stage
	f.Parent = stage
	cam.CameraType = Enum.CameraType.Scriptable
	cam.CFrame = CFrame.lookAt(o + Vector3.new(0, 14, 40), o + Vector3.new(0, 5, 0))
	local barA = mk("Frame", {
		Position = UDim2.fromScale(0.05, 0.12),
		Size = UDim2.fromScale(0.4, 0.03),
		BackgroundColor3 = Theme.Mint,
	}, gui)
	local barF = mk("Frame", {
		Position = UDim2.fromScale(0.55, 0.12),
		Size = UDim2.fromScale(0.4, 0.03),
		BackgroundColor3 = Theme.Tokens.Ramps.Ember[4],
	}, gui)
	pcall(function()
		task.wait(0.6)
		for _, s in b.log do
			local att, tgt, bar = s.me and a or f, s.me and f or a, s.me and barF or barA
			local c0 = att:GetPivot()
			local c1 = c0 + (tgt:GetPivot().Position - c0.Position) * 0.75
			for t = 0, 1, 1 / 8 do
				att:PivotTo(c0:Lerp(c1, math.sin(t * math.pi)))
				task.wait(0.03)
			end
			att:PivotTo(c0)
			fx(C.ById[(s.me and b.me or b.foe).id].el, c0.Position, tgt:GetPivot().Position)
			sfx("Hit")
			TS:Create(bar, TweenInfo.new(0.25), { Size = UDim2.fromScale(0.4 * s.hp, 0.03) }):Play()
			local g = Instance.new("BillboardGui")
			g.Size = UDim2.fromOffset(120, 40)
			g.StudsOffset = Vector3.new(0, 6, 0)
			g.AlwaysOnTop = true
			g.Adornee = tgt.PrimaryPart
			g.Parent = tgt.PrimaryPart
			mk("TextLabel", {
				Size = UDim2.fromScale(1, 1),
				BackgroundTransparency = 1,
				TextScaled = true,
				Font = Theme.Font,
				TextColor3 = s.mult > 1 and Theme.Accent or WHITE,
				Text = "-" .. s.dmg .. (s.mult > 1 and "!" or s.mult < 1 and Text.FRACO_988207 or ""),
			}, g)
			task.delay(1, function()
				g:Destroy()
			end)
			local tc = tgt:GetPivot()
			for i = 1, 4 do
				tgt:PivotTo(tc * CFrame.new((i % 2 * 2 - 1) * 0.6, 0, 0))
				task.wait(0.03)
			end
			tgt:PivotTo(tc)
			task.wait(0.35)
		end
		sfx(b.win and "Win" or "Lose")
		task.wait(0.8)
	end)
	barA:Destroy()
	barF:Destroy()
	stage:Destroy()
	cam.CameraType = ct
	cam.CFrame = originalCF
	cam.FieldOfView = originalFov
	cam.Focus = originalFocus
end
local function call(...)
	if inFlight then
		return
	end
	inFlight = true
	local before = S
	local act = ...
	msg.Text = "Processando..."
	local success, r = pcall(Net.InvokeServer, Net, ...)
	if not success then
		inFlight = false
		msg.Text = Text.CONEXAO_INTERROMPIDA_TENTE_NOVAMENTE_32854B
		return
	end
	if r then
		if r.data then
			S = r.data
			snapAt = os.clock()
			if r.ok and before and (act == "Hatch" or act == "Feed") then
				for uid, cr in S.creatures do
					local old = before.creatures[uid]
					if (act == "Hatch" and not old) or (old and C.stage(cr.lv, cr.id) > C.stage(old.lv, old.id)) then
						CollectionUI.discovery(gui, C.ById[cr.id], cr.lv, old ~= nil)
						break
					end
				end
			end
		end
		sfx(r.ok and (act == "Hatch" and "Hatch" or "Click") or "Lose")
		local m = r.msg or ""
		if r.battle then
			msg.Text = "Batalha!"
			render()
			playBattle(r.battle)
		end
		msg.Text = m
	end
	inFlight = false
	render()
	tutorial()
end
local function row(text, acts, creature)
	local f = mk("Frame", {
		LayoutOrder = 0,
		Size = UDim2.new(1, -8, 0, #acts > 2 and 178 or #acts > 0 and 124 or 64),
		BackgroundColor3 = Theme.Card,
	}, list)
	mk("TextLabel", {
		Position = UDim2.fromOffset(creature and 96 or 10, 4),
		Size = UDim2.new(1, creature and -106 or -20, 0, #acts > 0 and 62 or 56),
		BackgroundTransparency = 1,
		Text = text,
		TextScaled = true,
		TextColor3 = WHITE,
		Font = Theme.Font,
	}, f)
	if creature then
		local holder = mk(
			"Frame",
			{ Position = UDim2.fromOffset(4, 4), Size = UDim2.fromOffset(88, 68), BackgroundTransparency = 1 },
			f
		)
		local preview
		local function showSpecimen()
			if not f.Parent then
				return
			end
			local scrollTop = list.AbsolutePosition.Y
			local y = f.AbsolutePosition.Y
			local visible = list.Visible and y + f.AbsoluteSize.Y >= scrollTop and y <= scrollTop + list.AbsoluteSize.Y
			if visible and not preview then
				preview = CollectionUI.preview(holder, C.ById[creature.id], creature.lv, false)
				preview.Size = UDim2.fromScale(1, 1)
			elseif not visible and preview then
				preview:Destroy()
				preview = nil
			end
		end
		local scroll = list:GetPropertyChangedSignal("CanvasPosition"):Connect(showSpecimen)
		local visibility = list:GetPropertyChangedSignal("Visible"):Connect(showSpecimen)
		local layout = f:GetPropertyChangedSignal("AbsolutePosition"):Connect(showSpecimen)
		f.Destroying:Connect(function()
			scroll:Disconnect()
			visibility:Disconnect()
			layout:Disconnect()
		end)
		task.defer(showSpecimen)
	end
	local columns = math.min(2, math.max(1, #acts))
	local w = 1 / columns
	local rows = math.ceil(#acts / columns)
	for i, a in acts do
		local b = mk("TextButton", {
			Position = UDim2.new((i - 1) % columns * w, 4, 1, -rows * 52 + (math.floor((i - 1) / columns)) * 52),
			Size = UDim2.new(w, -8, 0, 44),
			Text = a[1],
			TextScaled = true,
			Font = Theme.Font,
			BackgroundColor3 = Theme.Card,
			TextColor3 = WHITE,
		}, f)
		b.Activated:Connect(a[2])
	end
	return f
end
local function crText(cr)
	local d = C.ById[cr.id]
	return (Text.S_NV_D_S_S_10A567):format(d.name, cr.lv, d.el, C.Rarity[d.rar])
end
render = function()
	for n, b in tabBtn do
		b.BackgroundColor3 = n == tab and Theme.Tokens.Ramps.Leaf[2] or Theme.Card
	end
	for _, c in list:GetChildren() do
		if c:IsA("Frame") and not (tab == Text.BESTIARIO_65A46C and c.Name == "BestiaryPanel") then
			c:Destroy()
		end
	end
	if not S then
		return
	end
	local n = 0
	for _ in S.discovered do
		n += 1
	end
	resourceValues[1].Text = tostring(S.playerLevel or 1)
	resourceValues[2].Text = resourceAmount(S.gold)
	resourceValues[3].Text = resourceAmount(S.gems)
	resourceValues[4].Text = resourceAmount(S.seals or 0)
	loading.ready()
	xpFill.Size = UDim2.fromScale(math.clamp((S.playerXp or 0) / Progression.playerCost(S.playerLevel or 1), 0, 1), 1)
	local objectiveChapter = Story.current(S)
	objective.Text = objectiveChapter
			and (objectiveChapter.name .. " • " .. Story.progress(S, objectiveChapter) .. "/" .. objectiveChapter.goal)
		or Text.PRIMEIRA_EXPEDICAO_CONCLUIDA_CONTINUE_EXPLORANDO_04DB58
	local nextIsland
	for _, id in Bands.Order do
		if not S.unlocked[id] then
			nextIsland = I.ById[id]
			break
		end
	end
	if nextIsland then
		objective.Text = nextIsland.name
			.. Text.FALTAM_1A9B57
			.. math.max(0, nextIsland.minLevel - S.playerLevel)
			.. Text.NIVEIS_769F71
			.. nextIsland.cost
			.. Text.OURO_6C9D60
	end
	objective.Visible = not drawerOpen and msg.Text == ""
	if tab == Text.FERAS_EF033A then
		for uid, cr in S.creatures do
			row(crText(cr), {
				{
					Text.ALIMENTAR_14F041,
					function()
						call("Feed", uid)
					end,
				},
				{
					S.companion == uid and Text.GUARDAR_A0B626 or Text.COMPANHEIRO_FDBCE5,
					function()
						call("Companion", uid)
					end,
				},
				{
					Text.POR_944529 .. isl,
					function()
						call("Place", uid, isl)
					end,
				},
				{
					Text.TREINO_172166,
					function()
						call("Battle", uid, isl)
					end,
				},
			}, cr)
		end
	elseif tab == Text.BESTIARIO_65A46C then
		Journal.render(list, S, function()
			render()
		end)
	elseif tab == Text.ARENA_1A4BA8 then
		row(Text.TROFEUS_F30057 .. S.trophies .. Text.AMBOS_DEVEM_TOCAR_DESAFIAR_EM_ATE_30S_DE8B6F, {})
		local rivalCount = 0
		for _, pl in Players:GetPlayers() do
			if pl ~= Players.LocalPlayer then
				rivalCount += 1
				row(
					pl.DisplayName,
					{ {
						Text.DESAFIAR_59C639,
						function()
							call("Duel", pl.UserId)
						end,
					} }
				)
			end
		end
		if rivalCount == 0 then
			row(Text.NENHUM_OUTRO_JOGADOR_AGORA_CONVIDE_AMIGOS_C96A34, {})
		end
	elseif tab == Text.SANTUARIO_D50F02 then
		SanctuaryUI.render(list, S, call, render)
	elseif tab == Text.OPCOES_4C8DF5 then
		for element, count in S.materials do
			row(Text.ESSENCIA_DE_3D63D1 .. element .. ": " .. count, {})
		end
		for _, quality in { Text.BAIXO_74FD00, Text.MEDIO_4F48C1, Text.ALTO_F46EDD } do
			row(Text.QUALIDADE_BE9B02 .. quality, {
				{
					LocalPlayer:GetAttribute("GraphicsQuality") == quality and "Ativa" or Text.SELECIONAR_4EDC0B,
					function()
						LocalPlayer:SetAttribute("GraphicsQuality", quality)
						for _, effect in Lighting:GetChildren() do
							if effect:IsA("BloomEffect") then
								effect.Enabled = quality == Text.ALTO_F46EDD
							end
						end
						render()
					end,
				},
			})
		end
		row(Text.MOVIMENTOS_REDUZIDOS_285637, {
			{
				LocalPlayer:GetAttribute("MotionReduced") and "Ativado" or "Desativado",
				function()
					LocalPlayer:SetAttribute("MotionReduced", not LocalPlayer:GetAttribute("MotionReduced"))
					render()
				end,
			},
		})
	elseif tab == Text.MISSOES_FAE2D2 then
		if S.quest and S.quest.stage > 0 then
			local q = S.quest
			local text = (q.title or Text.VESTIGIOS_513BA0) .. " · " .. q.stage .. "/3\n" .. q.hint
			if q.nextAttemptAt then
				text ..= "\n" .. (q.captured and Text.ALTAR_EM_REPOUSO_64BE88 or Text.NOVA_TENTATIVA_EM_CA2FA0 .. math.max(
					0,
					math.ceil(q.nextAttemptAt - workspace:GetServerTimeNow())
				) .. "s")
			end
			row(text, {})
		end
		local quest = Story.current(S)
		if quest then
			row(Text.MAIA_2FE34E .. quest.name .. " — " .. Story.progress(S, quest) .. "/" .. quest.goal, {
				{
					Story.canClaim(S, quest.id) and Text.RECEBER_CAPITULO_3ACD37 or Text.EM_ANDAMENTO_5CA373,
					function()
						call("ClaimStory", quest.id)
					end,
				},
			})
		end
		local ev = S.event
		row((Text.EVENTO_50_OURO_DE_S_DH_853264):format(ev.el, math.ceil(ev.left / 3600)), {})
		row(
			Text.RECOMPENSA_DIARIA_SEQUENCIA_B9C689 .. S.streak .. ")",
			{ {
				Text.RESGATAR_76A111,
				function()
					call("Daily")
				end,
			} }
		)
		for _, m in Missions.List do
			local pr = Missions.progress(S, m.stat)
			local done = S.claimed[m.id]
			row((Text.S_D_D_A1F15E):format(m.text, math.min(pr, m.goal), m.goal), {
				{
					done and "Concluída"
						or (pr >= m.goal and Text.RESGATAR_76A111 or "+" .. m.gold .. Text.OURO_6C9D60),
					function()
						if not done and pr >= m.goal then
							call("Claim", m.id)
						end
					end,
				},
			})
		end
	elseif tab == Text.LOJA_B9614D then
		for _, kind in CaptureRules.SealOrder do
			local recipe = CaptureRules.Seals[kind]
			local count = kind == "Basic" and S.seals or S.sealStock[kind] or 0
			row(
				Text.SELO_8CBE0B
					.. recipe.name
					.. " • "
					.. count
					.. Text.NIVEL_002242
					.. recipe.level
					.. (recipe.material and " • " .. recipe.amount .. Text.ESSENCIA_2D0983 .. recipe.material or ""),
				{
					{
						Text.CRIAR_BD03AE .. recipe.cost .. Text.OURO_6C9D60,
						function()
							call("CraftSeal", kind)
						end,
					},
				}
			)
		end
		row(Text.MERCADO_DE_OVOS_COMPRAS_COM_OURO_DO_JOGO_7CDE97, {})
		for _, def in I.List do
			if S.unlocked[def.id] then
				row(
					Text.OVO_DE_763A79 .. def.name .. " — " .. (80 * def.idx) .. Text.OURO_6C9D60,
					{ {
						Text.COMPRAR_F8AAD3,
						function()
							call("BuyEgg", def.id)
						end,
					} }
				)
			end
		end
	elseif tab == Text.ILHAS_577072 then
		for _, def in I.List do
			local band = Bands.ById[def.id]
			local state = S.access and S.access[def.id]
				or { ok = false, reason = "NOT_UNLOCKED", unlockReason = "NOT_UNLOCKED" }
			local text = def.name
				.. Text.NV_MIN_EC7398
				.. def.minLevel
				.. Text.VOCE_3A71A4
				.. S.playerLevel
				.. Text.SELVAGENS_492B94
				.. band.min
				.. "–"
				.. band.max
				.. Text.GUARDIAO_6B7FE6
				.. band.guardian
				.. " · "
				.. def.cost
				.. Text.OURO_028C29
				.. Strings.reason(S.unlocked[def.id] and state.reason or state.unlockReason)
			local acts = {}
			if state.ok then
				acts = {
					{
						Text.SELECIONAR_4EDC0B,
						function()
							isl = def.id
							render()
						end,
					},
					{
						Text.VIAJAR_AF3BD5,
						function()
							call("Travel", def.id)
						end,
					},
				}
			elseif not S.unlocked[def.id] then
				acts = { {
					Text.DESBLOQUEAR_539711,
					function()
						call("Unlock", def.id)
					end,
				} }
			end
			local card = row(text, acts)
			local track = mk(
				"Frame",
				{ Size = UDim2.new(1, -20, 0, 4), Position = UDim2.fromOffset(10, 58), BackgroundColor3 = Theme.Panel },
				card
			)
			mk("Frame", {
				Size = UDim2.fromScale(math.clamp(S.playerLevel / def.minLevel, 0, 1), 1),
				BackgroundColor3 = state.ok and Theme.Mint or Theme.Accent,
			}, track)
		end
	else
		row(
			Text.CHOCADEIRA_D1AF5D .. #S.eggs .. "/" .. Balance.IncubatorSlots .. Text.ESCOLHA_DOIS_PROGENITORES_C7CD31,
			{}
		)
		for i, e in S.eggs do
			local left = math.max(0, math.ceil(e.left - (os.clock() - snapAt)))
			Nursery.egg(list, C.ById[e.id], left, function()
				call("Hatch", i)
			end, function()
				call("Speed", i)
			end)
		end
		if #pick == 2 and S.creatures[pick[1]] and S.creatures[pick[2]] then
			local a, b = S.creatures[pick[1]], S.creatures[pick[2]]
			Nursery.parents(
				list,
				C.ById[a.id],
				C.ById[b.id],
				Breeding.outcomes(a.id, b.id),
				#S.eggs < Balance.IncubatorSlots and S.gold >= Balance.BreedCost,
				function()
					call("Breed", pick[1], pick[2])
				end
			)
		end
		for uid, cr in S.creatures do
			local on = table.find(pick, uid)
			row((on and "Selecionada · " or "") .. crText(cr), {
				{
					on and Text.TIRAR_F409BD or Text.ESCOLHER_D7B72C,
					function()
						if on then
							table.remove(pick, on)
						elseif #pick < 2 then
							table.insert(pick, uid)
						end
						render()
					end,
				},
			})
		end
	end
end
local tabs = {
	Text.FERAS_EF033A,
	Text.SANTUARIO_D50F02,
	Text.ILHAS_577072,
	Text.OVOS_99289F,
	Text.BESTIARIO_65A46C,
	Text.ARENA_1A4BA8,
	Text.MISSOES_FAE2D2,
	Text.LOJA_B9614D,
	Text.OPCOES_4C8DF5,
}
local bar = mk("Frame", {
	Visible = false,
	AnchorPoint = Vector2.new(1, 0),
	Position = UDim2.new(1, -8, 0.1, 0),
	Size = UDim2.new(0.9, 0, 0.12, -4),
	BackgroundTransparency = 1,
}, gui)
mk("UISizeConstraint", { MaxSize = Vector2.new(440, 160) }, bar)
local toggle = mk("TextButton", {
	Position = UDim2.new(1, -94, 0, 60),
	Size = UDim2.fromOffset(86, 44),
	Text = Text.MENU_57F5F5,
	TextSize = 12,
	Font = Theme.Font,
	TextColor3 = WHITE,
	BackgroundColor3 = Theme.Card,
}, gui)
local function setDrawer(open)
	drawerOpen = open
	list.Visible = open
	if not open then
		for _, child in list:GetChildren() do
			if child:IsA("Frame") then
				child:Destroy()
			end
		end
	end
	bar.Visible = open
	toggle.Text = open and Text.FECHAR_7B2006 or Text.MENU_57F5F5
	objective.Visible = not open and msg.Text == ""
	if tutorial then
		tutorial()
	end
	if open then
		render()
		list.BackgroundTransparency = 0.5
		TS:Create(list, TweenInfo.new(0.15), { BackgroundTransparency = 0.12 }):Play()
	end
end
local function layoutDrawer()
	local size = gui.AbsoluteSize
	local w = math.min(460, size.X - 16)
	local header = math.ceil(#tabs / 4) * 50
	bar.Size = UDim2.fromOffset(w, header)
	bar.Position = UDim2.new(1, -8, 0, 94)
	list.Size = UDim2.fromOffset(w, math.max(70, size.Y - header - 108))
	list.Position = UDim2.new(1, -8, 0, header + 100)
end
layoutDrawer()
gui:GetPropertyChangedSignal("AbsoluteSize"):Connect(layoutDrawer)
toggle.Activated:Connect(function()
	setDrawer(not drawerOpen)
end)
game:GetService("UserInputService").InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.Escape then
		setDrawer(false)
	end
end)
for i, name in tabs do
	local b = mk("TextButton", {
		Position = UDim2.fromScale(((i - 1) % 4) / 4, math.floor((i - 1) / 4) / math.ceil(#tabs / 4)),
		Size = UDim2.fromScale(1 / 4, 1 / math.ceil(#tabs / 4)),
		Text = name,
		TextScaled = true,
		Font = Theme.Font,
		BackgroundColor3 = Theme.Card,
		TextColor3 = WHITE,
	}, bar)
	tabBtn[name] = b
	b.Activated:Connect(function()
		tab = name
		render()
	end)
end
local collect = mk("TextButton", {
	Position = UDim2.new(1, -94, 0, 8),
	Size = UDim2.fromOffset(86, 44),
	Text = Text.COLETAR_199B16,
	TextScaled = true,
	Font = Theme.Font,
	BackgroundColor3 = Theme.Accent,
	TextColor3 = Theme.Panel,
}, gui)
collect.Activated:Connect(function()
	call("Collect")
end)
task.spawn(function()
	while true do
		task.wait(1)
		if tab == Text.OVOS_99289F then
			Nursery.tick(list)
		end
	end
end)
local music
if Sounds.Music ~= "" then
	music = Instance.new("Sound")
	music.SoundId = Sounds.Music
	music.Looped = true
	music.Volume = 0.25
	music.Parent = SS
	music:Play()
end
local notifications = RS:WaitForChild("WildNotice")
notifications.OnClientEvent:Connect(function(message, position, success)
	if typeof(position) == "Vector3" then
		local ring = Instance.new("Part")
		ring.Shape = Enum.PartType.Ball
		ring.Size = Vector3.one * 2
		ring.Position = position
		ring.Anchored = true
		ring.CanCollide = false
		ring.CanTouch = false
		ring.CanQuery = false
		ring.Material = Enum.Material.Neon
		ring.Color = success and Theme.Accent or Theme.Tokens.Ramps.Veil[4]
		ring.Transparency = 0.4
		ring.Parent = workspace
		TS:Create(ring, TweenInfo.new(0.6), { Size = Vector3.one * 8, Transparency = 1 }):Play()
		game:GetService("Debris"):AddItem(ring, 0.7)
		sfx(success and "Win" or "Lose")
	end
	msg.Text = message
	if S then
		task.delay(0.2, function()
			if not inFlight then
				call("Get")
			end
		end)
	end
end)
local lastMessage = ""
task.spawn(function()
	while true do
		task.wait(4)
		if msg.Text == lastMessage then
			msg.Text = ""
		end
		lastMessage = msg.Text
	end
end)
local mb = mk("TextButton", {
	Position = UDim2.new(1, -96, 1, -52),
	Size = UDim2.fromOffset(88, 44),
	Text = Text.SOM_ON_ACD88F,
	TextScaled = true,
	Font = Theme.Font,
	BackgroundColor3 = Theme.Card,
	TextColor3 = WHITE,
}, gui)
mb.Activated:Connect(function()
	muted = not muted
	mb.Text = muted and Text.SOM_OFF_D3D9A2 or Text.SOM_ON_ACD88F
	if music then
		music.Volume = muted and 0 or 0.25
	end
end)
-- Feras respiram e se viram devagar (animação local, só visual).
require(script.Parent.CreatureAnimator).start()
require(script.Parent.CompanionClient).start()
require(script.Parent.EnvironmentArt).start()
require(script.Parent.SolarPresentation).start(function()
	return S
end)
RS:WaitForChild("StoryNotice").OnClientEvent:Connect(function(message)
	msg.Text = message
	tab = Text.MISSOES_FAE2D2
	setDrawer(true)
end)
msg:GetPropertyChangedSignal("Text"):Connect(function()
	loading.message(msg.Text)
	objective.Visible = not drawerOpen and msg.Text == ""
end)
-- Clima e hora do dia mudam conforme a ilha mais próxima.
local cur
task.spawn(function()
	while true do
		task.wait(1)
		local ch = Players.LocalPlayer.Character
		local hrp = ch and ch:FindFirstChild("HumanoidRootPart")
		if hrp then
			local best, bd = nil, 1e9
			for _, d in I.List do
				local dist = (I.pos(d.idx) - hrp.Position).Magnitude
				if dist < bd then
					best, bd = d, dist
				end
			end
			if best and best ~= cur then
				cur = best
				TS:Create(
					Lighting,
					TweenInfo.new(3),
					{ Ambient = best.ambient, OutdoorAmbient = best.ambient, ClockTime = best.clock }
				):Play()
			end
		end
	end
end)
-- Tutorial guiado: cada passo some quando o objetivo é cumprido; o progresso vem dos stats salvos.
local TUT = {
	{
		Text.COLETE_OURO_OU_ENCONTRE_UMA_FERA_SELVAGEM_ABRA_M_40C94E,
		function()
			return collect
		end,
		function(s)
			return (s.stats.collect or 0) >= 1
		end,
	},
	{
		Text.NA_ABA_FERAS_TOQUE_EM_ALIMENTAR_PARA_EVOLUIR_UMA_2E587F,
		function()
			return tabBtn.Feras
		end,
		function(s)
			return (s.stats.feed or 0) >= 1
		end,
	},
	{
		Text.NA_ABA_OVOS_ESCOLHA_2_FERAS_E_TOQUE_CRUZAR_518B3E,
		function()
			return tabBtn.Ovos
		end,
		function(s)
			return (s.stats.breed or 0) >= 1
		end,
	},
	{
		Text.APROXIME_SE_DE_UMA_FERA_SELVAGEM_ESCOLHA_LUTAR_C_CD5B93,
		function()
			return toggle
		end,
		function(s)
			return (s.stats.fight or 0) >= 1
		end,
	},
	{
		Text.EM_MISSOES_RESGATE_SUA_PRIMEIRA_RECOMPENSA_AB00E0,
		function()
			return tabBtn[Text.MISSOES_FAE2D2]
		end,
		function(s)
			return next(s.claimed) ~= nil
		end,
	},
}
local panel = mk("Frame", {
	Position = UDim2.new(0.02, 0, 0, 132),
	Size = UDim2.new(0.72, 0, 0, 66),
	BackgroundColor3 = Theme.Card,
	Visible = false,
}, gui)
local ptxt = mk("TextLabel", {
	Size = UDim2.new(1, -90, 1, 0),
	Position = UDim2.fromOffset(8, 0),
	BackgroundTransparency = 1,
	TextScaled = true,
	Font = Theme.Font,
	TextColor3 = Theme.Ink,
	TextXAlignment = Enum.TextXAlignment.Left,
}, panel)
local skip = mk("TextButton", {
	Size = UDim2.fromOffset(76, 44),
	Position = UDim2.new(1, -80, 0.5, -22),
	Text = Text.PULAR_6EC317,
	TextScaled = true,
	Font = Theme.Font,
	BackgroundColor3 = Theme.Tokens.Ramps.Ember[2],
	TextColor3 = WHITE,
}, panel)
local stroke = Instance.new("UIStroke")
stroke.Color = Theme.Accent
stroke.Thickness = 2
stroke.ApplyStrokeMode = Enum.ApplyStrokeMode.Border
stroke.Thickness = 2
local finishing = false
local function finish()
	if not finishing then
		finishing = true
		task.spawn(call, "Tut")
	end
end
skip.Activated:Connect(finish)
tutorial = function()
	if drawerOpen or not S or S.tut then
		panel.Visible = false
		stroke.Parent = nil
		return
	end
	local step
	for _, t in TUT do
		if not t[3](S) then
			step = t
			break
		end
	end
	if not step then
		finish()
		return
	end
	panel.Visible = true
	ptxt.Text = step[1]
	stroke.Parent = step[2]()
end
-- Entrada pode preceder o término de UpdateAsync/consulta de passes.
task.spawn(function()
	for _ = 1, 20 do
		call("Get")
		if S then
			return
		end
		msg.Text = Text.CARREGANDO_SEU_SANTUARIO_53DAC6
		task.wait(0.75)
	end
	msg.Text = Text.NAO_FOI_POSSIVEL_OBTER_O_PERFIL_RECONECTE_PARA_T_9B595C
end)

require(script.Parent.EncounterUI).start(gui, function()
	return S and S.creatures or {}
end, function()
	task.defer(function()
		if not inFlight then
			call("Get")
		end
	end)
end, function()
	setDrawer(false)
	panel.Visible = false
	stroke.Parent = nil
end)
