--!strict
-- AudioController.lua - Gerenciamento de áudio (música, SFX, voz)

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local TweenService = game:GetService("TweenService")
local SoundService = game:GetService("SoundService")

local Types = require(ReplicatedStorage.Shared.Types)
local Config = require(ReplicatedStorage.Shared.Config)
local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local AudioController = {}

-- Events
AudioController.OnMusicChanged = Signal.New()
AudioController.OnSFXPlayed = Signal.New()

-- State
local CurrentMusic: Sound?
local CurrentMusicId: string?
local MusicVolume = 0.5
local SFXVolume = 0.7
local MasterVolume = 1.0
local IsMusicMuted = false
local IsSFXMuted = false

-- Sound groups
local MusicGroup = SoundService:FindFirstChild("MusicGroup") or Instance.new("SoundGroup")
local SFXGroup = SoundService:FindFirstChild("SFXGroup") or Instance.new("SoundGroup")
local AmbienceGroup = SoundService:FindFirstChild("AmbienceGroup") or Instance.new("SoundGroup")

MusicGroup.Name = "MusicGroup"
SFXGroup.Name = "SFXGroup"
AmbienceGroup.Name = "AmbienceGroup"

MusicGroup.Parent = SoundService
SFXGroup.Parent = SoundService
AmbienceGroup.Parent = SoundService

-- Music tracks (SoundId -> Config)
local MusicTracks = {
	MainMenu = {Id = "rbxassetid://1837635123", Volume = 0.5, Looped = true},
	Overworld = {Id = "rbxassetid://1837635123", Volume = 0.4, Looped = true},
	BattleWild = {Id = "rbxassetid://1837635123", Volume = 0.6, Looped = true},
	BattleTrainer = {Id = "rbxassetid://1837635123", Volume = 0.7, Looped = true},
	BattleLegendary = {Id = "rbxassetid://1837635123", Volume = 0.8, Looped = true},
	Victory = {Id = "rbxassetid://1837635123", Volume = 0.6, Looped = false},
	Defeat = {Id = "rbxassetid://1837635123", Volume = 0.5, Looped = false},
	Evolution = {Id = "rbxassetid://1837635123", Volume = 0.7, Looped = false},
	Capture = {Id = "rbxassetid://1837635123", Volume = 0.6, Looped = false},
	Healing = {Id = "rbxassetid://1837635123", Volume = 0.4, Looped = false},
	Shop = {Id = "rbxassetid://1837635123", Volume = 0.4, Looped = true},
	Cave = {Id = "rbxassetid://1837635123", Volume = 0.3, Looped = true},
	Night = {Id = "rbxassetid://1837635123", Volume = 0.35, Looped = true},
	Rain = {Id = "rbxassetid://1837635123", Volume = 0.3, Looped = true},
}

-- SFX library
local SFXLibrary = {
	-- UI
	ButtonClick = "rbxassetid://12221967",
	ButtonHover = "rbxassetid://12221976",
	MenuOpen = "rbxassetid://12221988",
	MenuClose = "rbxassetid://12221997",
	Error = "rbxassetid://12222006",
	Success = "rbxassetid://12222015",
	LevelUp = "rbxassetid://12222024",

	-- Battle
	MovePhysical = "rbxassetid://12222033",
	MoveSpecial = "rbxassetid://12222042",
	MoveStatus = "rbxassetid://12222051",
	HitNormal = "rbxassetid://12222060",
	HitSuperEffective = "rbxassetid://12222069",
	HitNotVeryEffective = "rbxassetid://12222078",
	HitImmune = "rbxassetid://12222087",
	CriticalHit = "rbxassetid://12222096",
	Faint = "rbxassetid://12222105",

	-- Creatures
	CaptureThrow = "rbxassetid://12222114",
	CaptureShake = "rbxassetid://12222123",
	CaptureSuccess = "rbxassetid://12222132",
	CaptureFail = "rbxassetid://12222141",
	EvolutionStart = "rbxassetid://12222150",
	EvolutionComplete = "rbxassetid://12222159",

	-- World
	FootstepGrass = "rbxassetid://12222168",
	FootstepWater = "rbxassetid://12222177",
	FootstepCave = "rbxassetid://12222186",
	FootstepSand = "rbxassetid://12222195",
	DoorOpen = "rbxassetid://12222204",
	DoorClose = "rbxassetid://12222213",
	ChestOpen = "rbxassetid://12222222",
	ItemPickup = "rbxassetid://12222231",

	-- Elements
	Fire = "rbxassetid://12222240",
	Water = "rbxassetid://12222249",
	Nature = "rbxassetid://12222258",
	Earth = "rbxassetid://12222267",
	Air = "rbxassetid://12222276",
	Shadow = "rbxassetid://12222285",
	Light = "rbxassetid://12222294",
	Metal = "rbxassetid://12222303",
	Crystal = "rbxassetid://12222312",

	-- Status
	Burn = "rbxassetid://12222321",
	Poison = "rbxassetid://12222330",
	Paralysis = "rbxassetid://12222339",
	Sleep = "rbxassetid://12222348",
	Freeze = "rbxassetid://12222357",
	Heal = "rbxassetid://12222366",
}

-- Active sounds for cleanup
local ActiveSounds = {} :: {Sound}
local AmbienceSounds = {} :: {Sound}

-- Initialize
function AudioController.Initialize()
	print("[AudioController] Initializing...")

	-- Setup sound groups
	MusicGroup.Volume = MusicVolume * MasterVolume
	SFXGroup.Volume = SFXVolume * MasterVolume
	AmbienceGroup.Volume = 0.3 * MasterVolume

	-- Load saved settings
	AudioController.LoadSettings()

	-- Preload common sounds
	AudioController.PreloadSounds()

	print("[AudioController] Initialized")
end

function AudioController.LoadSettings()
	-- Would load from player settings
	-- For now using defaults
end

function AudioController.PreloadSounds()
	-- Preload music
	for _, track in pairs(MusicTracks) do
		local sound = Instance.new("Sound")
		sound.SoundId = track.Id
		sound.Volume = 0
		sound.Looped = track.Looped
		sound.Parent = MusicGroup
		sound:Load()
		sound:Destroy()
	end

	-- Preload SFX
	for _, id in pairs(SFXLibrary) do
		local sound = Instance.new("Sound")
		sound.SoundId = id
		sound.Volume = 0
		sound.Parent = SFXGroup
		sound:Load()
		sound:Destroy()
	end
end

-- Music control
function AudioController.PlayMusic(trackName: string, fadeTime: number?)
	fadeTime = fadeTime or 2

	local track = MusicTracks[trackName]
	if not track then
		warn(`[AudioController] Music track not found: {trackName}`)
		return
	end

	if CurrentMusicId == trackName then return end

	-- Create new music sound
	local newMusic = Instance.new("Sound")
	newMusic.Name = "Music_" .. trackName
	newMusic.SoundId = track.Id
	newMusic.Volume = 0
	newMusic.Looped = track.Looped
	newMusic.SoundGroup = MusicGroup
	newMusic.Parent = SoundService

	-- Fade out current music
	if CurrentMusic then
		local fadeOut = TweenService:Create(CurrentMusic, TweenInfo.new(fadeTime), {Volume = 0})
		fadeOut:Play()

		fadeOut.Completed:Connect(function()
			CurrentMusic:Stop()
			CurrentMusic:Destroy()
		end)
	end

	-- Fade in new music
	newMusic:Play()

	local fadeIn = TweenService:Create(newMusic, TweenInfo.new(fadeTime), {Volume = track.Volume * MusicVolume * MasterVolume})
	fadeIn:Play()

	CurrentMusic = newMusic
	CurrentMusicId = trackName

	AudioController.OnMusicChanged:Fire(trackName)

	print(`[AudioController] Playing music: {trackName}`)
end

function AudioController.StopMusic(fadeTime: number?)
	fadeTime = fadeTime or 1

	if CurrentMusic then
		local fadeOut = TweenService:Create(CurrentMusic, TweenInfo.new(fadeTime), {Volume = 0})
		fadeOut:Play()

		fadeOut.Completed:Connect(function()
			CurrentMusic:Stop()
			CurrentMusic:Destroy()
			CurrentMusic = nil
			CurrentMusicId = nil
		end)
	end
end

function AudioController.PauseMusic()
	if CurrentMusic then
		CurrentMusic.Paused = true
	end
end

function AudioController.ResumeMusic()
	if CurrentMusic then
		CurrentMusic.Paused = false
	end
end

function AudioController.SetMusicVolume(volume: number)
	MusicVolume = math.clamp(volume, 0, 1)
	MusicGroup.Volume = MusicVolume * MasterVolume

	if CurrentMusic then
		local track = MusicTracks[CurrentMusicId]
		if track then
			CurrentMusic.Volume = track.Volume * MusicVolume * MasterVolume
		end
	end
end

function AudioController.GetMusicVolume(): number
	return MusicVolume
end

-- SFX control
function AudioController.PlaySFX(sfxName: string, position: Vector3?, volume: number?, pitch: number?): Sound?
	local soundId = SFXLibrary[sfxName]
	if not soundId then
		warn(`[AudioController] SFX not found: {sfxName}`)
		return nil
	end

	volume = volume or 1
	pitch = pitch or 1

	local sound = Instance.new("Sound")
	sound.Name = "SFX_" .. sfxName
	sound.SoundId = soundId
	sound.Volume = volume * SFXVolume * MasterVolume
	sound.Pitch = pitch
	sound.SoundGroup = SFXGroup
	sound.PlayOnRemove = false

	if position then
		-- 3D sound at position
		local part = Instance.new("Part")
		part.Name = "SFXEmitter"
		part.Size = Vector3.new(0.1, 0.1, 0.1)
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.CFrame = CFrame.new(position)
		part.Parent = workspace

		sound.Parent = part
		sound.RollOffMode = Enum.RollOffMode.Linear
		sound.MaxDistance = 100
		sound.MinDistance = 10

		sound:Play()

		task.delay(sound.TimeLength + 1, function()
			part:Destroy()
		end)
	else
		-- 2D sound
		sound.Parent = SoundService
		sound:Play()

		task.delay(sound.TimeLength + 1, function()
			sound:Destroy()
		end)
	end

	table.insert(ActiveSounds, sound)
	AudioController.OnSFXPlayed:Fire(sfxName, sound)

	-- Cleanup finished sounds
	task.spawn(function()
		task.wait(sound.TimeLength + 1)
		local index = table.find(ActiveSounds, sound)
		if index then table.remove(ActiveSounds, index) end
	end)

	return sound
end

function AudioController.PlaySFXAtPart(sfxName: string, part: BasePart, volume: number?, pitch: number?): Sound?
	local soundId = SFXLibrary[sfxName]
	if not soundId then return nil end

	volume = volume or 1
	pitch = pitch or 1

	local sound = Instance.new("Sound")
	sound.Name = "SFX_" .. sfxName
	sound.SoundId = soundId
	sound.Volume = volume * SFXVolume * MasterVolume
	sound.Pitch = pitch
	sound.SoundGroup = SFXGroup
	sound.RollOffMode = Enum.RollOffMode.Linear
	sound.MaxDistance = 100
	sound.MinDistance = 10
	sound.Parent = part
	sound:Play()

	table.insert(ActiveSounds, sound)

	task.delay(sound.TimeLength + 1, function()
		sound:Destroy()
		local index = table.find(ActiveSounds, sound)
		if index then table.remove(ActiveSounds, index) end
	end)

	return sound
end

function AudioController.PlayCreatureCry(speciesId: string, pitch: number?)
	-- Would play creature-specific cry
	-- For now use a generic sound based on element
	local speciesConfig = Config.SpeciesList[speciesId]
	if not speciesConfig then return end

	local elementSounds = {
		Fire = "Fire",
		Water = "Water",
		Nature = "Nature",
		Earth = "Earth",
		Air = "Air",
		Shadow = "Shadow",
		Light = "Light",
		Metal = "Metal",
		Crystal = "Crystal",
	}

	local soundName = elementSounds[speciesConfig.Element1] or "HitNormal"
	AudioController.PlaySFX(soundName, nil, 0.5, pitch or (1 + math.random() * 0.2 - 0.1))
end

function AudioController.SetSFXVolume(volume: number)
	SFXVolume = math.clamp(volume, 0, 1)
	SFXGroup.Volume = SFXVolume * MasterVolume
end

function AudioController.GetSFXVolume(): number
	return SFXVolume
end

-- Master volume
function AudioController.SetMasterVolume(volume: number)
	MasterVolume = math.clamp(volume, 0, 1)
	MusicGroup.Volume = MusicVolume * MasterVolume
	SFXGroup.Volume = SFXVolume * MasterVolume
	AmbienceGroup.Volume = 0.3 * MasterVolume
end

function AudioController.GetMasterVolume(): number
	return MasterVolume
end

-- Mute
function AudioController.SetMusicMuted(muted: boolean)
	IsMusicMuted = muted
	MusicGroup.Volume = muted and 0 or (MusicVolume * MasterVolume)
end

function AudioController.SetSFXMuted(muted: boolean)
	IsSFXMuted = muted
	SFXGroup.Volume = muted and 0 or (SFXVolume * MasterVolume)
end

function AudioController.IsMusicMuted(): boolean
	return IsMusicMuted
end

function AudioController.IsSFXMuted(): boolean
	return IsSFXMuted
end

-- Battle music
function AudioController.PlayBattleMusic(battleType: "Wild" | "Trainer" | "Legendary")
	local tracks = {
		Wild = "BattleWild",
		Trainer = "BattleTrainer",
		Legendary = "BattleLegendary",
	}
	AudioController.PlayMusic(tracks[battleType], 1.5)
end

function AudioController.PlayVictoryMusic()
	AudioController.PlayMusic("Victory", 1)

	task.delay(5, function()
		AudioController.PlayMusic("Overworld", 2)
	end)
end

function AudioController.PlayDefeatMusic()
	AudioController.PlayMusic("Defeat", 1)

	task.delay(5, function()
		AudioController.PlayMusic("Overworld", 2)
	end)
end

-- Special events
function AudioController.PlayEvolutionMusic()
	AudioController.PlayMusic("Evolution", 0.5)
	AudioController.PlaySFX("EvolutionStart")

	task.delay(3, function()
		AudioController.PlaySFX("EvolutionComplete")
	end)

	task.delay(8, function()
		AudioController.PlayMusic("Overworld", 2)
	end)
end

function AudioController.PlayCaptureSequence()
	AudioController.PlaySFX("CaptureThrow")

	task.delay(0.5, function()
		AudioController.PlaySFX("CaptureShake")
	end)

	task.delay(1.5, function()
		AudioController.PlaySFX("CaptureShake")
	end)

	task.delay(2.5, function()
		AudioController.PlaySFX("CaptureSuccess")
		AudioController.PlayMusic("Capture", 0.5)
	end)

	task.delay(5, function()
		AudioController.PlayMusic("Overworld", 2)
	end)
end

function AudioController.PlayHealSound()
	AudioController.PlaySFX("Heal")
	AudioController.PlayMusic("Healing", 1)

	task.delay(3, function()
		AudioController.PlayMusic("Overworld", 2)
	end)
end

function AudioController.PlayLevelUpSound()
	AudioController.PlaySFX("LevelUp")
end

-- Ambience
function AudioController.PlayAmbience(ambienceType: string, position: Vector3?)
	local ambienceTracks = {
		Rain = {Id = "rbxassetid://12222375", Volume = 0.3},
		Wind = {Id = "rbxassetid://12222384", Volume = 0.2},
		Cave = {Id = "rbxassetid://12222393", Volume = 0.25},
		Forest = {Id = "rbxassetid://12222402", Volume = 0.2},
		Ocean = {Id = "rbxassetid://12222411", Volume = 0.25},
		City = {Id = "rbxassetid://12222420", Volume = 0.15},
	}

	local track = ambienceTracks[ambienceType]
	if not track then return end

	-- Stop existing ambience of same type
	for _, sound in ipairs(AmbienceSounds) do
		if sound:GetAttribute("AmbienceType") == ambienceType then
			sound:Stop()
			sound:Destroy()
		end
	end

	local sound = Instance.new("Sound")
	sound.Name = "Ambience_" .. ambienceType
	sound.SoundId = track.Id
	sound.Volume = track.Volume * MasterVolume
	sound.Looped = true
	sound.SoundGroup = AmbienceGroup
	sound:SetAttribute("AmbienceType", ambienceType)

	if position then
		local part = Instance.new("Part")
		part.Name = "AmbienceEmitter"
		part.Size = Vector3.new(1, 1, 1)
		part.Transparency = 1
		part.Anchored = true
		part.CanCollide = false
		part.CFrame = CFrame.new(position)
		part.Parent = workspace

		sound.Parent = part
		sound.RollOffMode = Enum.RollOffMode.Linear
		sound.MaxDistance = 200
		sound.MinDistance = 50
	else
		sound.Parent = SoundService
	end

	sound:Play()
	table.insert(AmbienceSounds, sound)
end

function AudioController.StopAmbience(ambienceType: string?)
	if ambienceType then
		for i = #AmbienceSounds, 1, -1 do
			local sound = AmbienceSounds[i]
			if sound:GetAttribute("AmbienceType") == ambienceType then
				sound:Stop()
				sound:Destroy()
				table.remove(AmbienceSounds, i)
			end
		end
	else
		for _, sound in ipairs(AmbienceSounds) do
			sound:Stop()
			sound:Destroy()
		end
		AmbienceSounds = {}
	end
end

-- Weather ambience
function AudioController.SetWeatherAmbience(weather: string)
	AudioController.StopAmbience("Rain")
	AudioController.StopAmbience("Wind")

	if weather == "Rain" then
		AudioController.PlayAmbience("Rain")
	elseif weather == "Sandstorm" or weather == "Windy" then
		AudioController.PlayAmbience("Wind")
	end
end

-- Time of day ambience
function AudioController.SetTimeOfDayAmbience(timeOfDay: string)
	if timeOfDay == "Night" then
		AudioController.PlayMusic("Night", 5)
	elseif timeOfDay == "Day" then
		AudioController.PlayMusic("Overworld", 5)
	end
end

-- Zone music
function AudioController.SetZoneMusic(zoneId: string)
	local zoneMusic = {
		Cave = "Cave",
		Forest = "Overworld",
		Mountain = "Overworld",
		Ocean = "Overworld",
		City = "Overworld",
		Desert = "Overworld",
		Snow = "Overworld",
		Volcano = "BattleLegendary",
		Ruins = "Cave",
		Sky = "Overworld",
		Underground = "Cave",
		Beach = "Overworld",
		Swamp = "Cave",
	}

	local track = zoneMusic[zoneId] or "Overworld"
	AudioController.PlayMusic(track, 3)
end

-- Footstep sounds
local LastFootstepTime = 0
local FootstepInterval = 0.4

function AudioController.PlayFootstep(material: Enum.Material, isRunning: boolean)
	local now = tick()
	if now - LastFootstepTime < (isRunning and FootstepInterval * 0.6 or FootstepInterval) then return end
	LastFootstepTime = now

	local footstepSounds = {
		[Enum.Material.Grass] = "FootstepGrass",
		[Enum.Material.Sand] = "FootstepSand",
		[Enum.Material.Mud] = "FootstepGrass",
		[Enum.Material.Ground] = "FootstepGrass",
		[Enum.Material.Rock] = "FootstepCave",
		[Enum.Material.Brick] = "FootstepCave",
		[Enum.Material.Concrete] = "FootstepCave",
		[Enum.Material.Wood] = "FootstepCave",
		[Enum.Material.Water] = "FootstepWater",
		[Enum.Material.Snow] = "FootstepSand",
		[Enum.Material.Ice] = "FootstepCave",
	}

	local soundName = footstepSounds[material] or "FootstepGrass"
	AudioController.PlaySFX(soundName, nil, isRunning and 0.6 or 0.4)
end

-- Cleanup
function AudioController.Cleanup()
	for _, sound in ipairs(ActiveSounds) do
		sound:Stop()
		sound:Destroy()
	end
	ActiveSounds = {}

	for _, sound in ipairs(AmbienceSounds) do
		sound:Stop()
		sound:Destroy()
	end
	AmbienceSounds = {}

	if CurrentMusic then
		CurrentMusic:Stop()
		CurrentMusic:Destroy()
		CurrentMusic = nil
	end
end

return AudioController