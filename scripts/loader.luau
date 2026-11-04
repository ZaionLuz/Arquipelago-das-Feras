-- Carrega módulos de produção com tipos Roblox nativos; serviços são injetados pelos testes.
local fs = require("@lune/fs")
local luau = require("@lune/luau")
local roblox = require("@lune/roblox")
local Loader = {}
function Loader.node(folder)
	return setmetatable({}, {
		__index = function(_, name)
			if name == "Parent" then
				return Loader.node(folder:match("^(.*)/[^/]+$") or ".")
			end
			return folder .. "/" .. name .. ".luau"
		end,
	})
end
function Loader.new(overrides, replacements)
	local cache, loading = {}, {}
	local load
	load = function(path)
		if replacements and replacements[path] then
			return replacements[path]
		end
		if cache[path] then
			return cache[path]
		end
		assert(not loading[path], "Dependência circular: " .. path)
		loading[path] = true
		local values = { require = load, script = { Parent = Loader.node(path:match("^(.*)/[^/]+$")) } }
		for _, name in
			{
				"Instance",
				"Vector3",
				"CFrame",
				"Color3",
				"Enum",
				"UDim",
				"UDim2",
				"NumberRange",
				"NumberSequence",
				"ColorSequence",
			}
		do
			values[name] = roblox[name]
		end
		for k, v in overrides or {} do
			values[k] = v
		end
		local env = setmetatable(values, { __index = getfenv() })
		local result = luau.load(fs.readFile(path), { debugName = path, environment = env })()
		cache[path] = result
		loading[path] = nil
		return result
	end
	return load
end
Loader.load = Loader.new()
return Loader
