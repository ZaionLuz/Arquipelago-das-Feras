--!nonstrict
-- Geometria compartilhada; servidor continua autoridade de posição/contexto.
local L = {
	RingRadius = 1400,
	RegionRadius = 420,
	SurfaceY = 14,
	RouteWidth = 64,
	Count = 7,
	SanctuaryOrigin = Vector3.new(5000, 12, 5000),
}
local V = Vector3.new
function L.center(index)
	local a = (index - 1) / L.Count * math.pi * 2
	return V(math.cos(a) * L.RingRadius, 10, math.sin(a) * L.RingRadius)
end
function L.route(index)
	local a, b = L.center(index), L.center(index % L.Count + 1)
	local direction = (b - a).Unit
	return {
		a = a + direction * (L.RegionRadius - 24),
		b = b - direction * (L.RegionRadius - 24),
		from = index,
		to = index % L.Count + 1,
		width = L.RouteWidth,
	}
end
function L.distanceToSegment(p, a, b)
	local delta = b - a
	local length = delta:Dot(delta)
	if length == 0 then
		return (p - a).Magnitude, 0
	end
	local t = math.clamp((p - a):Dot(delta) / length, 0, 1)
	return (p - (a + delta * t)).Magnitude, t
end
function L.detect(position)
	if
		typeof(position) ~= "Vector3"
		or position.X ~= position.X
		or position.Y ~= position.Y
		or position.Z ~= position.Z
	then
		return nil
	end
	if math.abs(position.Y - 10) > 180 then
		return nil
	end
	local flat = V(position.X, 10, position.Z)
	for index = 1, L.Count do
		if (flat - L.center(index)).Magnitude <= L.RegionRadius then
			return index, "region"
		end
	end
	for index = 1, L.Count do
		local road = L.route(index)
		local distance, t = L.distanceToSegment(flat, road.a, road.b)
		if distance <= L.RouteWidth * 0.5 then
			return t < 0.5 and road.from or road.to, "route"
		end
	end
	return nil
end
function L.safePoint(index)
	return L.center(index) + V(0, 9, 24)
end
function L.wildOffset(slot)
	local positions = {
		V(-100, 4, 70),
		V(100, 4, 80),
		V(-215, 4, -90),
		V(210, 4, -150),
		V(-70, 4, -310),
		V(290, 4, 180),
		V(-300, 4, 170),
		V(75, 4, 290),
	}
	return positions[(slot - 1) % #positions + 1]
end
function L.campOffset(index)
	local road = L.route(index)
	return (road.a - L.center(index)) * 0.68 + V(0, 4, 0)
end
function L.plotCenter(index)
	return L.SanctuaryOrigin + V(((index - 1) % 4) * 190, 0, math.floor((index - 1) / 4) * 190)
end
return L
