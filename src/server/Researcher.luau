--!nonstrict
local Text = require(game:GetService("ReplicatedStorage").Shared.Strings).Text
local RS = game:GetService("ReplicatedStorage")
local Data = require(script.Parent.DataService)
local Story = require(RS.Shared.Story)
local I = require(RS.Shared.Islands)
local Art = require(script.Parent.WorldArt)
local R = {}
function R.start()
	local event = Instance.new("RemoteEvent")
	event.Name = "StoryNotice"
	event.Parent = RS
	local model = Instance.new("Model")
	model.Name = Text.MAIA_PESQUISADORA_1A62F7
	model.Parent = workspace
	local base = I.pos(1) + Vector3.new(19, 4, 23)
	local function part(name, size, offset, color, shape)
		local p = Instance.new("Part")
		p.Name = name
		p.Size = size
		p.Position = base + offset
		p.Color = color
		p.Shape = shape or Enum.PartType.Block
		p.Anchored = true
		p.CanCollide = false
		p.Parent = model
		return p
	end
	local torso = part("Casaco", Vector3.new(2.2, 2.5, 1), Vector3.new(0, 2.8, 0), Color3.fromRGB(62, 121, 115))
	local _head = part(
		Text.CABECA_D8228B,
		Vector3.new(1.7, 1.7, 1.7),
		Vector3.new(0, 4.7, 0),
		Color3.fromRGB(205, 159, 123),
		Enum.PartType.Ball
	)
	for _, side in { -1, 1 } do
		part("Bota", Vector3.new(0.8, 1.6, 1), Vector3.new(side * 0.6, 0.9, 0), Color3.fromRGB(65, 65, 77))
		part(
			Text.BRACO_DB4D66,
			Vector3.new(0.65, 2.2, 0.7),
			Vector3.new(side * 1.5, 2.7, 0),
			Color3.fromRGB(62, 121, 115)
		)
	end
	Art.researcher(model, base)
	local prompt = Instance.new("ProximityPrompt")
	prompt.ActionText = Text.CONVERSAR_AC3B38
	prompt.ObjectText = Text.MAIA_PESQUISADORA_DO_ARQUIPELAGO_38D949
	prompt.HoldDuration = 0.2
	prompt.MaxActivationDistance = 10
	prompt.Parent = torso
	prompt.Triggered:Connect(function(p)
		local d = Data.get(p)
		local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
		if not d or not root or (root.Position - torso.Position).Magnitude > 12 then
			return
		end
		local q = Story.current(d)
		event:FireClient(
			p,
			q
					and ("Maia: " .. q.text .. " (" .. Story.progress(d, q) .. "/" .. q.goal .. Text.VEJA_MISSOES_PARA_RECEBER_A_RECOMPENSA_8B5929)
				or Text.MAIA_VOCE_CONCLUIU_NOSSOS_PRIMEIROS_ESTUDOS_CONT_FCC227
		)
	end)
end
return R
