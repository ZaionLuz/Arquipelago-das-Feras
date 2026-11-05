local fs = require("@lune/fs")
local rb = require("@lune/roblox")
local args = require("@lune/process").args
local place = rb.deserializePlace(
	fs.readFile(
		args[1]
			or (
				fs.isFile("releases/Feras-Creature-Sculpt.rbxlx") and "releases/Feras-Creature-Sculpt.rbxlx"
				or fs.isFile("releases/Feras-Open-World.rbxlx") and "releases/Feras-Open-World.rbxlx"
				or fs.isFile("releases/Feras-Art-Overhaul.rbxlx") and "releases/Feras-Art-Overhaul.rbxlx"
				or "releases/Feras-V7.rbxlx"
			)
	)
)
local scripts = 0
for _, obj in place:GetDescendants() do
	if obj:IsA("LuaSourceContainer") then
		scripts += 1
		assert(#obj.Source > 0, "Script vazio")
	end
end
local expected = 0
for _, folder in { "client", "server", "shared" } do
	for _, name in fs.readDir("src/" .. folder) do
		if name:match("%.luau$") then
			expected += 1
		end
	end
end
assert(scripts == expected, "Mapeamento de scripts incorreto: " .. scripts .. " / " .. expected)
assert(place:GetService("Workspace").StreamingEnabled)
print("PASS: bundle Rojo desserializado com " .. scripts .. " scripts/módulos e streaming habilitado")
