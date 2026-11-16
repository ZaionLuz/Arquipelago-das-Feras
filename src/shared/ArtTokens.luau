--!strict
-- Contrato visual único: 64 cores (12 elementos × 4 + UI), sem assets externos nem estado de gameplay.
local T = {
	BaseGrid = 4,
	IconGrid = 16,
	Font = Enum.Font.Arcade,
	Spacing = { xs = 4, sm = 8, md = 12, lg = 16, xl = 24 },
	Border = 2,
	Touch = 44,
}

-- 12 Elementos × 4 tons + 8 neutros = 56 cores de ramps + 8 UI = 64 total
local ramps = {
	-- Originais (6 elementos)
	Fogo      = { 0x3D2948, 0x79384B, 0xBD5750, 0xED9765 },
	["Água"]  = { 0x253B57, 0x356580, 0x489BBA, 0x80CFCC },
	Natureza  = { 0x293E4B, 0x416358, 0x61966B, 0x9FC477 },
	Terra     = { 0x453A54, 0x7C5860, 0xAD8270, 0xD8B482 },
	Ar        = { 0x333B63, 0x576392, 0x849AC3, 0xB1CEE0 },
	Sombra    = { 0x302D4F, 0x55446E, 0x866594, 0xB293BC },
	-- Novos elementos (6 elementos)
	Gelo      = { 0x1E3A5F, 0x3A7BD5, 0x7DD3FC, 0xBAE6FD },
	Elétrico  = { 0x3D2B00, 0x7A5A00, 0xFACC15, 0xFDE047 },
	Luz       = { 0x3D3300, 0x7A6A00, 0xFEF08A, 0xFEF9C3 },
	Metal     = { 0x273746, 0x4C6573, 0x7B969E, 0xB2BFB4 },
	Cristal   = { 0x3B1F5C, 0x6D28D9, 0xA855F7, 0xD8B4FE },
	Arcano    = { 0x2D1B4E, 0x5B21B6, 0x8B5CF6, 0xC4B5FD },
}
T.Ramps = {}
T.Palette = {}
local function color(hex)
	return Color3.fromRGB(math.floor(hex / 65536) % 256, math.floor(hex / 256) % 256, hex % 256)
end
for name, values in ramps do
	T.Ramps[name] = {}
	for _, hex in values do
		local c = color(hex)
		table.insert(T.Ramps[name], c)
		table.insert(T.Palette, c)
	end
end
-- Neutros (UI/Background)
for _, hex in { 0x192B36, 0x283C46, 0x3B5159, 0x587078, 0x8C9D9C, 0xB7C5B8, 0xDEDAC0, 0xFFF0CF } do
	table.insert(T.Palette, color(hex))
end

T.Ink = color(0xFFF0CF)
T.Muted = color(0xB7C5B8)
T.Panel = color(0x192B36)
T.Card = color(0x283C46)
T.Edge = color(0x587078)
T.Shadow = color(0x192B36)
T.Accent = T.Ramps.Terra[4]
T.Mint = T.Ramps.Natureza[4]

-- Mapeamento elemento -> ramp
T.Elements = {
	Fogo      = T.Ramps.Fogo,
	["Água"]  = T.Ramps["Água"],
	Natureza  = T.Ramps.Natureza,
	Terra     = T.Ramps.Terra,
	Ar        = T.Ramps.Ar,
	Sombra    = T.Ramps.Sombra,
	Gelo      = T.Ramps.Gelo,
	Elétrico  = T.Ramps.Elétrico,
	Luz       = T.Ramps.Luz,
	Metal     = T.Ramps.Metal,
	Cristal   = T.Ramps.Cristal,
	Arcano    = T.Ramps.Arcano,
}

T.Biomes = {
	Alvorecer = "Natureza",
	Brasa     = "Fogo",
	Recife    = "Água",
	Floresta  = "Natureza",
	Dunas     = "Terra",
	Picos     = "Ar",
	Pantano   = "Sombra",
	Inverno   = "Gelo",
	Trovao    = "Elétrico",
	Celestial = "Luz",
	Forja     = "Metal",
	Geoda     = "Cristal",
	Vazio     = "Arcano",
}

function T.ramp(id: string)
	return T.Elements[id] or T.Ramps.Metal
end

function T.nearest(c: Color3): Color3
	local best, distance = T.Palette[1], math.huge
	for _, candidate in T.Palette do
		local d = (c.R - candidate.R) ^ 2 + (c.G - candidate.G) ^ 2 + (c.B - candidate.B) ^ 2
		if d < distance then
			best, distance = candidate, d
		end
	end
	return best
end

-- Efeitos de partículas por elemento (Neon + ParticleEmitter)
T.ParticlePresets = {
	Fogo = {
		Color = ColorSequence.new(T.Ramps.Fogo[3], T.Ramps.Fogo[4]),
		Size = NumberSequence.new(0.5, 0),
		Lifetime = NumberRange.new(0.3, 0.8),
		Rate = 20,
		Speed = 2,
		SpreadAngle = Vector2.new(45, 45),
		Drag = 0.5,
	},
	["Água"] = {
		Color = ColorSequence.new(T.Ramps["Água"][3], T.Ramps["Água"][4]),
		Size = NumberSequence.new(0.3, 0),
		Lifetime = NumberRange.new(0.4, 1),
		Rate = 15,
		Speed = 3,
		SpreadAngle = Vector2.new(30, 30),
		Drag = 0.3,
	},
	Natureza = {
		Color = ColorSequence.new(T.Ramps.Natureza[3], T.Ramps.Natureza[4]),
		Size = NumberSequence.new(0.4, 0),
		Lifetime = NumberRange.new(0.5, 1.2),
		Rate = 12,
		Speed = 1.5,
		SpreadAngle = Vector2.new(60, 60),
		Drag = 0.4,
	},
	Terra = {
		Color = ColorSequence.new(T.Ramps.Terra[3], T.Ramps.Terra[4]),
		Size = NumberSequence.new(0.6, 0),
		Lifetime = NumberRange.new(0.6, 1.5),
		Rate = 10,
		Speed = 1,
		SpreadAngle = Vector2.new(20, 20),
		Drag = 0.8,
	},
	Ar = {
		Color = ColorSequence.new(T.Ramps.Ar[3], T.Ramps.Ar[4]),
		Size = NumberSequence.new(0.3, 0),
		Lifetime = NumberRange.new(0.3, 0.8),
		Rate = 25,
		Speed = 4,
		SpreadAngle = Vector2.new(90, 90),
		Drag = 0.1,
	},
	Sombra = {
		Color = ColorSequence.new(T.Ramps.Sombra[3], T.Ramps.Sombra[4]),
		Size = NumberSequence.new(0.5, 0),
		Lifetime = NumberRange.new(0.8, 2),
		Rate = 8,
		Speed = 1.5,
		SpreadAngle = Vector2.new(45, 45),
		Drag = 0.2,
	},
	Gelo = {
		Color = ColorSequence.new(T.Ramps.Gelo[3], T.Ramps.Gelo[4]),
		Size = NumberSequence.new(0.4, 0),
		Lifetime = NumberRange.new(0.5, 1.5),
		Rate = 15,
		Speed = 2,
		SpreadAngle = Vector2.new(30, 30),
		Drag = 0.6,
	},
	Elétrico = {
		Color = ColorSequence.new(T.Ramps.Elétrico[3], T.Ramps.Elétrico[4]),
		Size = NumberSequence.new(0.2, 0),
		Lifetime = NumberRange.new(0.1, 0.4),
		Rate = 30,
		Speed = 8,
		SpreadAngle = Vector2.new(120, 120),
		Drag = 0,
	},
	Luz = {
		Color = ColorSequence.new(T.Ramps.Luz[3], T.Ramps.Luz[4]),
		Size = NumberSequence.new(0.6, 0),
		Lifetime = NumberRange.new(1, 3),
		Rate = 5,
		Speed = 1,
		SpreadAngle = Vector2.new(180, 180),
		Drag = 0.1,
	},
	Metal = {
		Color = ColorSequence.new(T.Ramps.Metal[3], T.Ramps.Metal[4]),
		Size = NumberSequence.new(0.3, 0),
		Lifetime = NumberRange.new(0.4, 1),
		Rate = 12,
		Speed = 2,
		SpreadAngle = Vector2.new(30, 30),
		Drag = 0.5,
	},
	Cristal = {
		Color = ColorSequence.new(T.Ramps.Cristal[3], T.Ramps.Cristal[4]),
		Size = NumberSequence.new(0.4, 0),
		Lifetime = NumberRange.new(0.5, 2),
		Rate = 8,
		Speed = 1.5,
		SpreadAngle = Vector2.new(45, 45),
		Drag = 0.3,
	},
	Arcano = {
		Color = ColorSequence.new(T.Ramps.Arcano[3], T.Ramps.Arcano[4]),
		Size = NumberSequence.new(0.5, 0),
		Lifetime = NumberRange.new(1, 3),
		Rate = 6,
		Speed = 1,
		SpreadAngle = Vector2.new(180, 180),
		Drag = 0.1,
	},
}

-- SoundId placeholders para cries (substituir por assets reais)
T.CrySounds = {
	Fogo      = "rbxassetid://100000001",
	["Água"]  = "rbxassetid://100000002",
	Natureza  = "rbxassetid://100000003",
	Terra     = "rbxassetid://100000004",
	Ar        = "rbxassetid://100000005",
	Sombra    = "rbxassetid://100000006",
	Gelo      = "rbxassetid://100000007",
	Elétrico  = "rbxassetid://100000008",
	Luz       = "rbxassetid://100000009",
	Metal     = "rbxassetid://100000010",
	Cristal   = "rbxassetid://100000011",
	Arcano    = "rbxassetid://100000012",
}

return T