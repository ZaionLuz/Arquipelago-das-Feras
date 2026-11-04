--!nonstrict
local Data = require(script.Parent.DataService)
local T = {}
local busy = setmetatable({}, { __mode = "k" })
function T.go(player, position, region)
	region = region or "sanctuary"
	if
		typeof(position) ~= "Vector3"
		or position.X ~= position.X
		or position.Y ~= position.Y
		or position.Z ~= position.Z
		or position.Magnitude > 1e6
	then
		return false
	end
	local profile = Data.get(player)
	if
		region ~= "sanctuary"
		and not require(game:GetService("ReplicatedStorage").Shared.Access).check(profile, region, "travel").ok
	then
		return false
	end
	if busy[player] or not profile or require(script.Parent.EncounterService).active(player) then
		return false
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	local humanoid = character and character:FindFirstChildOfClass("Humanoid")
	local session = Data.session(player)
	if not root or not session or not humanoid or humanoid.Health <= 0 then
		return false
	end
	local ticket = { root = root, anchored = root.Anchored, session = session }
	busy[player] = ticket
	session.transporting = true
	local function cleanup()
		if busy[player] ~= ticket then
			return
		end
		if root.Parent then
			root.Anchored = ticket.anchored
		end
		session.transporting = false
		busy[player] = nil
	end
	local ready = pcall(function()
		player:RequestStreamAroundAsync(position, 3)
	end)
	if
		not ready
		or player.Character ~= character
		or not root.Parent
		or not Data.get(player)
		or humanoid.Health <= 0
		or require(script.Parent.EncounterService).active(player)
	then
		cleanup()
		return false
	end
	local moved = pcall(function()
		root.Anchored = true
		character:PivotTo(CFrame.new(position))
	end)
	if not moved then
		cleanup()
		return false
	end
	session.region = region
	if region == "sanctuary" and player.SetAttribute then
		player:SetAttribute("RegionId", region)
	end
	if region ~= "sanctuary" then
		require(script.Parent.RegionService).note(player, region, "region")
	end
	task.delay(1, cleanup) -- manter reserva até restaurar a âncora; segunda viagem não captura Anchored=true.
	return true
end
return T
