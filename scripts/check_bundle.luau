local fs = require("@lune/fs")
local rb = require("@lune/roblox")
local place = rb.deserializePlace(fs.readFile("releases/Feras-V7.rbxlx"))
local scripts = 0
for _, obj in place:GetDescendants() do
	if obj:IsA("LuaSourceContainer") then
		scripts += 1
		assert(#obj.Source > 0, "Script vazio")
	end
end
assert(scripts == 57, "Mapeamento de scripts incorreto: " .. scripts)
assert(place:GetService("Workspace").StreamingEnabled)
print("PASS: bundle Rojo desserializado com 57 scripts/módulos e streaming habilitado")
