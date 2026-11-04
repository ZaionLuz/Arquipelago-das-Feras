--!nonstrict
local Run = game:GetService("RunService")
local Players = game:GetService("Players")
local A = {}
local records = setmetatable({}, { __mode = "k" })
local started = false
function A.register(model, visible, orbit)
	if not records[model] then
		local record = {
			base = model:GetAttribute("Gallery") and model:GetPivot() or nil,
			joints = {},
			parts = {},
			effects = {},
			visible = visible,
			orbit = orbit,
			last = 0,
		}
		for _, obj in model:GetDescendants() do
			if obj:IsA("Motor6D") then
				table.insert(record.joints, obj)
			elseif obj:IsA("BasePart") then
				table.insert(record.parts, obj)
			elseif obj:IsA("ParticleEmitter") or obj:IsA("Light") then
				table.insert(record.effects, obj)
			end
		end
		records[model] = record
	elseif visible then
		records[model].visible = visible
	end
end
function A.play(model, pose, duration)
	A.register(model)
	local record = records[model]
	record.poseStart = os.clock()
	record.poseDuration = duration or 0.5
	record.pose = pose
	record.untilTime = os.clock() + (duration or 0.5)
end
local function apply(model, record, time, full, reduced)
	if record.base and not reduced then
		model:PivotTo(record.base * CFrame.Angles(0, time * 0.25, 0))
	end
	if record.orbit and record.orbit.camera.Parent and not reduced then
		local orbit = record.orbit
		local angle = time * 0.25
		orbit.camera.CFrame = CFrame.lookAt(
			orbit.center
				+ Vector3.new(math.sin(angle) * orbit.distance, orbit.distance * 0.3, math.cos(angle) * orbit.distance),
			orbit.center
		)
	end
	local family = model:GetAttribute("Family")
	local moving = full and model:GetAttribute("Moving") == true
	local pose = record.untilTime and time < record.untilTime and record.pose or "idle"
	local lift = math.sin(time * 2) * (family == "spectral" and 0.2 or family == "mineral" and 0.015 or 0.035)
	local progress = record.poseStart and math.clamp((time - record.poseStart) / record.poseDuration, 0, 1) or 0
	for _, joint in record.joints do
		if not joint.Parent then
			continue
		end
		local role = joint:GetAttribute("Role") or joint.Name
		local phase = joint:GetAttribute("Phase") or 0
		local transform = CFrame.identity
		if not reduced then
			if role == "Body" then
				transform = CFrame.new(0, lift, 0) * CFrame.Angles(0, math.sin(time * 0.6) * 0.04, 0)
				if pose == "attack" then
					transform *= CFrame.Angles(math.sin(progress * math.pi) * 0.25, 0, 0)
				elseif pose == "damage" then
					transform *= CFrame.Angles(0, 0, math.sin(time * 30) * 0.08)
				elseif pose == "faint" then
					transform *= CFrame.Angles(0, 0, progress * 1.2)
				elseif pose == "victory" then
					transform *= CFrame.new(0, math.abs(math.sin(time * 7)) * 0.3, 0)
				end
				if moving and (family == "serpentine" or family == "aquatic") then
					transform *= CFrame.Angles(0, math.sin(time * 4) * 0.1, 0)
				end
				if family == "vegetal" then
					transform *= CFrame.Angles(0, 0, math.sin(time) * 0.06)
				end
			elseif role == "Head" then
				transform = CFrame.Angles(0, math.sin(time * 0.8 + phase) * 0.08, 0)
			elseif role:find("Eye") then
				transform = CFrame.Angles((time + phase) % 5 < 0.12 and 1.35 or 0, 0, 0)
			elseif role:find("Wing") then
				local side = joint.C0.Position.X < 0 and -1 or 1
				local pivot = CFrame.new(side * 0.5, 0, 0)
				local flap = CFrame.Angles(
					0,
					0,
					side * math.sin(time * (pose == "attack" and 6 or 2) + phase * 0.4) * (full and 0.35 or 0.12)
				)
				transform = joint.C0:Inverse() * pivot * flap * pivot:Inverse() * joint.C0
			elseif role:find("Tail") or role:find("Coil") or role:find("Veil") then
				transform = CFrame.Angles(0, math.sin(time * 2 + phase) * 0.12, math.sin(time + phase) * 0.04)
			elseif role:find("Leg") and moving then
				transform = CFrame.Angles(math.sin(time * (family == "arthropod" and 8 or 5) + phase) * 0.3, 0, 0)
			elseif role:find("Halo") then
				local scale = model.PrimaryPart.Size.Y / 0.1
				local center = CFrame.new(0, 1.3 * scale, -0.6 * scale)
				transform = joint.C0:Inverse() * center * CFrame.Angles(0, 0, time * 0.18) * center:Inverse() * joint.C0
			end
		end
		joint.Transform = transform
	end
end
function A.start()
	if started then
		return
	end
	started = true
	local accumulated, scan = 0, 0
	Run.Heartbeat:Connect(function(dt)
		accumulated += dt
		scan += dt
		if accumulated < 1 / 30 then
			return
		end
		accumulated = 0
		local camera = workspace.CurrentCamera
		if not camera then
			return
		end
		if scan > 0.5 then
			scan = 0
			for _, name in
				{ "Criaturas", "Selvagens", "Companheiros", "Guardioes", Run:IsStudio() and "GaleriaV7" or "" }
			do
				local folder = workspace:FindFirstChild(name)
				if folder then
					for _, obj in folder:GetDescendants() do
						if obj:IsA("Model") and obj.PrimaryPart and obj:GetAttribute("Species") then
							A.register(obj)
						end
					end
				end
			end
		end
		local quality = Players.LocalPlayer:GetAttribute("GraphicsQuality") or "Médio"
		local reduced = Players.LocalPlayer:GetAttribute("MotionReduced")
		local candidates = {}
		local time = os.clock()
		for model, record in records do
			if not model.Parent or not model.PrimaryPart then
				records[model] = nil
				continue
			end
			local distance = record.visible and 0 or (model.PrimaryPart.Position - camera.CFrame.Position).Magnitude
			local shown = not record.visible or record.visible()
			local hidden = distance > 300 or not shown
			if record.hidden ~= hidden then
				record.hidden = hidden
				for _, part in record.parts do
					if part.Parent then
						part.LocalTransparencyModifier = hidden and 1 or 0
					end
				end
			end
			local effectsOn = quality ~= "Baixo" and distance < 70 and shown
			if record.effectsOn ~= effectsOn then
				record.effectsOn = effectsOn
				for _, effect in record.effects do
					if effect.Parent then
						effect.Enabled = effectsOn
					end
				end
			end
			if shown and distance < (quality == "Baixo" and 70 or 150) then
				table.insert(candidates, { model = model, record = record, distance = distance })
			end
		end
		table.sort(candidates, function(a, b)
			return a.distance < b.distance
		end)
		for index = 1, math.min(quality == "Baixo" and 8 or quality == "Alto" and 24 or 16, #candidates) do
			local item = candidates[index]
			local interval = item.distance < 70 and 1 / 30 or 1 / 15
			if time - item.record.last >= interval then
				item.record.last = time
				apply(item.model, item.record, time, item.distance < 70, reduced)
			end
		end
	end)
end
return A
