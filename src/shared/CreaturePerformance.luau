--!nonstrict
-- Apenas apresentação. As decisões não alteram combate, posição, inventário ou save.
local P = {
	Warmup = 15,
	Window = 4,
	Cooldown = 20,
	SlowFramesPerSecond = 32,
	FastFramesPerSecond = 52,
}
local function qualityName(value)
	return value == "Alto" and "Alto" or value == "Baixo" and "Baixo" or "Médio"
end
function P.new()
	return {
		elapsed = 0,
		windowTime = 0,
		windowFrames = 0,
		slowWindows = 0,
		fastWindows = 0,
		cooldownUntil = 0,
		low = false,
		quality = "Médio",
	}
end
local function resetWindow(state)
	state.windowTime, state.windowFrames = 0, 0
	state.slowWindows, state.fastWindows = 0, 0
end
function P.step(state, dt, quality)
	quality = qualityName(quality)
	if state.quality ~= quality then
		state.quality = quality
		resetWindow(state)
	end
	-- Uma escolha explícita sempre vence o ajuste automático.
	if quality ~= "Médio" then
		if state.low then
			state.low = false
			resetWindow(state)
			return false
		end
		return nil
	end
	-- Ignora pausas de carregamento e amostras inválidas em vez de tratá-las como FPS estável.
	if type(dt) ~= "number" or dt ~= dt or dt <= 0 or dt > 0.5 then
		return nil
	end
	state.elapsed += dt
	if state.elapsed < P.Warmup then
		return nil
	end
	state.windowTime += dt
	state.windowFrames += 1
	if state.windowTime < P.Window then
		return nil
	end
	local average = state.windowTime / state.windowFrames
	state.windowTime, state.windowFrames = 0, 0
	if state.elapsed < state.cooldownUntil then
		state.slowWindows, state.fastWindows = 0, 0
		return nil
	end
	if average > 1 / P.SlowFramesPerSecond then
		state.slowWindows += 1
		state.fastWindows = 0
	elseif average < 1 / P.FastFramesPerSecond then
		state.fastWindows += 1
		state.slowWindows = 0
	else
		state.slowWindows, state.fastWindows = 0, 0
	end
	local changed = not state.low and state.slowWindows >= 2 or state.low and state.fastWindows >= 3
	if changed then
		state.low = not state.low
		state.cooldownUntil = state.elapsed + P.Cooldown
		state.slowWindows, state.fastWindows = 0, 0
		return state.low
	end
	return nil
end
local low = table.freeze({
	nearRate = 15,
	farRate = 8,
	animateLimit = 6,
	hideDistance = 180,
	animationDistance = 120,
	nearDistance = 70,
	detailLow = true,
})
local medium = table.freeze({
	nearRate = 30,
	farRate = 15,
	animateLimit = 16,
	hideDistance = 300,
	animationDistance = 150,
	nearDistance = 70,
	detailLow = false,
})
local high = table.freeze({
	nearRate = 30,
	farRate = 15,
	animateLimit = 24,
	hideDistance = 300,
	animationDistance = 150,
	nearDistance = 70,
	detailLow = false,
})
function P.settings(quality, adaptive)
	quality = qualityName(quality)
	if quality == "Baixo" or quality ~= "Alto" and adaptive == true then
		return low
	end
	return quality == "Alto" and high or medium
end
return P
