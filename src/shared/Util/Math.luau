--!strict
-- Math.lua - Utilitários matemáticos

local MathUtil = {}

-- Clamp value between min and max
function MathUtil.Clamp(value: number, min: number, max: number): number
	return math.max(min, math.min(max, value))
end

-- Lerp between two values
function MathUtil.Lerp(a: number, b: number, t: number): number
	return a + (b - a) * MathUtil.Clamp(t, 0, 1)
end

-- Lerp for Vector3
function MathUtil.LerpVector3(a: Vector3, b: Vector3, t: number): Vector3
	return a:Lerp(b, MathUtil.Clamp(t, 0, 1))
end

-- Round to decimal places
function MathUtil.Round(value: number, decimals: number?): number
	local mult = 10 ^ (decimals or 0)
	return math.floor(value * mult + 0.5) / mult
end

-- Random float between min and max
function MathUtil.RandomFloat(min: number, max: number): number
	return min + math.random() * (max - min)
end

-- Random integer between min and max (inclusive)
function MathUtil.RandomInt(min: number, max: number): number
	return math.random(min, max)
end

-- Weighted random selection
function MathUtil.WeightedRandom<T>(items: {{Item: T, Weight: number}}): T?
	local totalWeight = 0
	for _, item in items do
		totalWeight += item.Weight
	end

	if totalWeight <= 0 then
		return nil
	end

	local roll = math.random() * totalWeight
	local current = 0

	for _, item in items do
		current += item.Weight
		if roll <= current then
			return item.Item
		end
	end

	return items[#items].Item
end

-- Distance between two Vector3
function MathUtil.Distance(a: Vector3, b: Vector3): number
	return (a - b).Magnitude
end

-- Check if point is in radius
function MathUtil.InRadius(point: Vector3, center: Vector3, radius: number): boolean
	return MathUtil.Distance(point, center) <= radius
end

-- Get random point in circle
function MathUtil.RandomPointInCircle(center: Vector2, radius: number): Vector2
	local angle = math.random() * 2 * math.pi
	local r = math.sqrt(math.random()) * radius
	return Vector2.new(center.X + r * math.cos(angle), center.Y + r * math.sin(angle))
end

-- Get random point in sphere
function MathUtil.RandomPointInSphere(center: Vector3, radius: number): Vector3
	local u = math.random()
	local v = math.random()
	local theta = 2 * math.pi * u
	local phi = math.acos(2 * v - 1)
	local r = radius * (math.random() ^ (1/3))

	local x = r * math.sin(phi) * math.cos(theta)
	local y = r * math.sin(phi) * math.sin(theta)
	local z = r * math.cos(phi)

	return center + Vector3.new(x, y, z)
end

-- Sign function
function MathUtil.Sign(value: number): number
	if value > 0 then return 1
	elseif value < 0 then return -1
	else return 0
	end
end

-- Clamp angle to -180 to 180
function MathUtil.ClampAngle(angle: number): number
	while angle > 180 do angle -= 360 end
	while angle < -180 do angle += 360 end
	return angle
end

-- Smooth step
function MathUtil.SmoothStep(t: number): number
	t = MathUtil.Clamp(t, 0, 1)
	return t * t * (3 - 2 * t)
end

-- Smoother step
function MathUtil.SmootherStep(t: number): number
	t = MathUtil.Clamp(t, 0, 1)
	return t * t * t * (t * (t * 6 - 15) + 10)
end

return MathUtil