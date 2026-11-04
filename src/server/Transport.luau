--!nonstrict
local Data = require(script.Parent.DataService)
local T = {}
local busy = setmetatable({}, { __mode = "k" })
function T.go(player, position, region)
	region = region or "sanctuary"
	local profile = Data.get(player)
	if
		region ~= "sanctuary"
		and not require(game:GetService("ReplicatedStorage").Shared.Access).check(profile, region, "travel").ok
	then
		return false
	end
	if busy[player] or not Data.get(player) or require(script.Parent.EncounterService).active(player) then
		return false
	end
	local character = player.Character
	local root = character and character:FindFirstChild("HumanoidRootPart")
	if not root then
		return false
	end
	busy[player] = true
	local session = Data.session(player)
	if not session then
		busy[player] = nil
		return false
	end
	session.transporting = true
	local ready = pcall(function()
		player:RequestStreamAroundAsync(position, 3)
	end)
	busy[player] = nil
	session.transporting = false
	if
		not ready
		or player.Character ~= character
		or not root.Parent
		or not Data.get(player)
		or require(script.Parent.EncounterService).active(player)
	then
		return false
	end
	session.region = region
	if region ~= "sanctuary" then
		session.lastSafe = region
	end
	local wasAnchored = root.Anchored
	root.Anchored = true
	character:PivotTo(CFrame.new(position))
	task.delay(1, function()
		if root.Parent then
			root.Anchored = wasAnchored
		end
	end)
	return true
end
return T
