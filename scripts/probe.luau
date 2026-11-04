local loader = require("./loader")
local C = loader.load("src/shared/Creatures.luau")
print("species", #C.List)
local factory = loader.load("src/shared/ModelFactory.luau")
for _, def in C.List do
	for _, level in { 1, 7, 15 } do
		local ok, result = pcall(factory.build, def, level, { preview = true })
		if not ok then
			print("FAIL", def.id, level, result)
			error("Modelo inválido")
		end
		print(def.id, level, factory.validate(result).parts)
	end
end
