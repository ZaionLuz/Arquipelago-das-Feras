--!nonstrict
local RS = game:GetService("ReplicatedStorage")
local I = require(RS.Shared.Islands)
local Access = require(RS.Shared.Access)
local Data = require(script.Parent.DataService)
local R = {}
function R.detect(position)
	for _, def in I.List do
		local center = I.pos(def.idx)
		if
			math.abs(position.Y - center.Y) < 100
			and (Vector3.new(position.X, 0, position.Z) - Vector3.new(center.X, 0, center.Z)).Magnitude <= 40
		then
			return def.id
		end
	end
	return nil
end
function R.current(p, purpose)
	local d = Data.get(p)
	local session = Data.session(p)
	local root = p.Character and p.Character:FindFirstChild("HumanoidRootPart")
	if not d or not session or not root or session.transporting then
		return nil
	end
	local id = R.detect(root.Position)
	if id and id == session.region and Access.check(d, id, purpose or "encounter").ok then
		return id
	end
	return not id and session.region == "sanctuary" and "sanctuary" or nil
end
function R.requireCurrent(p, id, purpose)
	local data = Data.get(p)
	local access = Access.check(data, id, purpose)
	if not access.ok then
		return access
	end
	if R.current(p, purpose) ~= id then
		return { ok = false, reason = "WRONG_REGION" }
	end
	return access
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
	local def = I.ById[id] or I.ById.Alvorecer
	return I.pos(def.idx) + Vector3.new(0, 9, 24)
end
return R
