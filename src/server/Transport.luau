--!nonstrict
local Data=require(script.Parent.DataService)
local T={}
local busy=setmetatable({},{__mode="k"})
function T.go(player,position)
 if busy[player] or not Data.get(player) or require(script.Parent.EncounterService).active(player) then return false end
 local character=player.Character;local root=character and character:FindFirstChild("HumanoidRootPart")
 if not root then return false end
 busy[player]=true
 local ready=pcall(function() player:RequestStreamAroundAsync(position,3) end)
 busy[player]=nil
 if not ready or player.Character~=character or not root.Parent or not Data.get(player) or require(script.Parent.EncounterService).active(player) then return false end
 local wasAnchored=root.Anchored;root.Anchored=true
 character:PivotTo(CFrame.new(position))
 task.delay(1,function() if root.Parent then root.Anchored=wasAnchored end end)
 return true
end
return T
