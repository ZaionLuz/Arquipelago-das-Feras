--!nonstrict
-- Contrato visual único: 48 cores, sem assets externos nem estado de gameplay.
local T = {
	BaseGrid = 4,
	IconGrid = 16,
	Font = Enum.Font.Arcade,
	Spacing = { xs = 4, sm = 8, md = 12, lg = 16, xl = 24 },
	Border = 2,
	Touch = 44,
}
local ramps = {
	Ember = { 0x3D2948, 0x79384B, 0xBD5750, 0xED9765, 0xFFD6A0 },
	Tidal = { 0x253B57, 0x356580, 0x489BBA, 0x80CFCC, 0xC6EBCF },
	Leaf = { 0x293E4B, 0x416358, 0x61966B, 0x9FC477, 0xDDE7AA },
	Sand = { 0x453A54, 0x7C5860, 0xAD8270, 0xD8B482, 0xF4D9A0 },
	Sky = { 0x333B63, 0x576392, 0x849AC3, 0xB1CEE0, 0xEBE9D6 },
	Veil = { 0x302D4F, 0x55446E, 0x866594, 0xB293BC, 0xE3BCD0 },
	Metal = { 0x273746, 0x4C6573, 0x7B969E, 0xB2BFB4, 0xE8DEC3 },
	Rose = { 0x482E4E, 0x824862, 0xB97588, 0xE3A3A1, 0xFAD7BD },
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
for _, hex in { 0x192B36, 0x283C46, 0x3B5159, 0x587078, 0x8C9D9C, 0xB7C5B8, 0xDEDAC0, 0xFFF0CF } do
	table.insert(T.Palette, color(hex))
end
T.Ink = color(0xFFF0CF)
T.Muted = color(0xB7C5B8)
T.Panel = color(0x192B36)
T.Card = color(0x283C46)
T.Edge = color(0x587078)
T.Shadow = color(0x192B36)
T.Accent = T.Ramps.Sand[4]
T.Mint = T.Ramps.Leaf[4]
T.Elements = {
	Fogo = T.Ramps.Ember,
	["Água"] = T.Ramps.Tidal,
	Natureza = T.Ramps.Leaf,
	Terra = T.Ramps.Sand,
	Ar = T.Ramps.Sky,
	Sombra = T.Ramps.Veil,
}
T.Biomes = {
	Alvorecer = "Leaf",
	Brasa = "Ember",
	Recife = "Tidal",
	Floresta = "Leaf",
	Dunas = "Sand",
	Picos = "Sky",
	Pantano = "Veil",
}
function T.ramp(id)
	return T.Ramps[T.Biomes[id] or "Metal"]
end
function T.nearest(c)
	local best, distance = T.Palette[1], math.huge
	for _, candidate in T.Palette do
		local d = (c.R - candidate.R) ^ 2 + (c.G - candidate.G) ^ 2 + (c.B - candidate.B) ^ 2
		if d < distance then
			best, distance = candidate, d
		end
	end
	return best
end
return T
