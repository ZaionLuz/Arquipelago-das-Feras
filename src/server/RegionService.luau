--!nonstrict
local RS = game:GetService("ReplicatedStorage")
local I = require(RS.Shared.Islands)
local Layout = require(RS.Shared.WorldLayout)
local Access = require(RS.Shared.Access)
local Data = require(script.Parent.DataService)
local R = {}
function R.detect(position)
	local index, kind = Layout.detect(position)
	return index and I.List[index].id or nil, kind
end
function R.note(p, id, kind)
	local d = Data.get(p)
	local s = Data.session(p)
	if not d or not s then
		return
	end
	s.region = id
	if kind ~= "route" then
		s.lastSafe = id
		d.navigation = d.navigation or { visited = { Alvorecer = true }, checkpoint = "Alvorecer" }
		d.navigation.visited[id] = true
		d.navigation.checkpoint = id
		local count = 0
		for _, v in d.navigation.visited do
			if v then
				count += 1
			end
		end
		d.stats = d.stats or {}
		d.stats.regionVisit = math.max(d.stats.regionVisit or 0, count)
	end
	if p.SetAttribute then
		p:SetAttribute("RegionId", id)
	end
end
function R.current(p, purpose)
	local d = Data.get(p)
	local session = Data.session(p)
	local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
	if not d or not session or not root or session.transporting then
		return nil
	end
	local id, kind = R.detect(root.Position)
	if id and Access.check(d, id, purpose or "encounter").ok then
		R.note(p, id, kind)
		return id
	end
	if session.region == "sanctuary" and require(script.Parent.SanctuaryService).contains(p, root.Position) then
		return "sanctuary"
	end
	return nil
end
function R.requireCurrent(p, id, purpose)
	local result = Access.check(Data.get(p), id, purpose)
	if not result.ok then
		return result
	end
	if R.current(p, purpose) ~= id then
		return { ok = false, reason = "WRONG_REGION" }
	end
	return result
end
function R.requireContext(p, id, purpose, allowHome)
	local result = Access.check(Data.get(p), id, purpose)
	if not result.ok then
		return result
	end
	if allowHome and R.current(p, purpose) == "sanctuary" then
		return result
	end
	return R.requireCurrent(p, id, purpose)
end
function R.safePoint(id)
	return Layout.safePoint((I.ById[id] or I.ById.Alvorecer).idx)
end
return R
