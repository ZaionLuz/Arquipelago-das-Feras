-- Native geometry + event mock for visual controls, without Roblox renderer.
local Loader = require("../loader")
local rb = require("@lune/roblox")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local RS = { Shared = Loader.node("src/shared") }
local game = {
	GetService = function()
		return RS
	end,
}
local load = Loader.new({ game = game })
local T = load("src/shared/ArtTokens.luau")
local Icons = load("src/client/PixelIcons.luau")
local Stage = load("src/client/BattleStage.luau")
assert(#T.Palette == 48)
local unique = {}
for _, c in T.Palette do
	unique[tostring(c)] = true
end
local colors = 0
for _ in unique do
	colors += 1
end
assert(colors == 48)
local iconCounts = {}
local maxRuns = 0
for name, grid in Icons.Grids do
	assert(#grid == 16)
	for _, row in grid do
		assert(#row == 16 and row:match("^[.abcd]+$"))
	end
	local parent = rb.Instance.new("Frame")
	local icon = Icons.draw(parent, name, 32)
	assert(icon.Size.X.Offset == 32 and icon.Size.Y.Offset == 32)
	local count = #icon:GetChildren()
	maxRuns = math.max(maxRuns, count)
	assert(count <= 160)
	iconCounts[name] = count
	parent:Destroy()
end
local scenes = {}
for _, id in { "Alvorecer", "Brasa", "Recife", "Floresta", "Dunas", "Picos", "Pantano" } do
	local world = rb.Instance.new("WorldModel")
	local scene = Stage.build(world, id, rb.Vector3.new(0, 300, 0))
	local count = 0
	for _, p in scene:GetDescendants() do
		if p:IsA("BasePart") then
			count += 1
			assert(p.Anchored and not p.CanCollide and not p.CanQuery and not p.CanTouch)
			assert(p.CFrame.Position.Y > 270)
		end
	end
	assert(count <= Stage.Budget)
	scenes[id] = count
	world:Destroy()
end
local function signal()
	local callbacks = {}
	return {
		Connect = function(_, fn)
			table.insert(callbacks, fn)
			return { Disconnect = function() end }
		end,
		Fire = function(_, ...)
			for _, fn in callbacks do
				fn(...)
			end
		end,
	}
end
local function new(class)
	local properties = { ClassName = class, Active = true, Selectable = true, ZIndex = 1 }
	local attrs = {}
	local children = {}
	local events = {}
	local object
	local methods = {
		FindFirstChild = function(_, name)
			for _, child in children do
				if child.Name == name then
					return child
				end
			end
		end,
		GetAttribute = function(_, key)
			return attrs[key]
		end,
		SetAttribute = function(_, key, value)
			attrs[key] = value
		end,
		GetPropertyChangedSignal = function(_, key)
			events[key] = events[key] or signal()
			return events[key]
		end,
	}
	for _, event in
		{ "MouseEnter", "MouseLeave", "InputBegan", "InputEnded", "SelectionGained", "SelectionLost", "Activated" }
	do
		properties[event] = signal()
	end
	object = setmetatable({}, {
		__index = function(_, key)
			return methods[key] or properties[key]
		end,
		__newindex = function(_, key, value)
			local previous = properties[key]
			properties[key] = value
			if key == "Parent" and value then
				value._append(object)
			end
			if events[key] and previous ~= value then
				events[key]:Fire()
			end
		end,
	})
	methods._append = function(child)
		table.insert(children, child)
	end
	return object
end
local uiLoad = Loader.new({ game = game, Instance = { new = new } })
local Theme = uiLoad("src/client/UITheme.luau")
local parent = new("Frame")
local fired = 0
local button = Theme.button(parent, "Teste", function()
	fired += 1
end)
local normal = button.BackgroundColor3
button.MouseEnter:Fire()
local hover = button.BackgroundColor3
assert(hover ~= normal)
button.InputBegan:Fire({ UserInputType = rb.Enum.UserInputType.Touch })
local pressed = button.BackgroundColor3
assert(pressed ~= hover)
button.InputEnded:Fire({ UserInputType = rb.Enum.UserInputType.Touch })
button.MouseLeave:Fire()
assert(button.BackgroundColor3 == normal)
button.Active = false
assert(button.TextColor3 == Theme.Muted)
button.Active = true
button.Activated:Fire()
assert(fired == 1)
assert(button.Size.Y.Offset >= 44 and button.Font == T.Font)
fs.writeFile(
	"docs/art/ART_METRICS.json",
	serde.encode(
		"json",
		{
			paletteColors = colors,
			icons = iconCounts,
			maxIconRuns = maxRuns,
			battleParts = scenes,
			buttonStates = { normal = true, hover = true, pressed = true, disabled = true },
			callbackUnchanged = true,
			touchTarget = 44,
			rendererExecuted = false,
		},
		true
	)
)
print(
	"PASS art: 48 cores, ícones16px, cenários7≤190, origem de treino, botão hover/pressionado/desativado, callback único"
)
