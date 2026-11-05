-- Native geometry and actual preview implementation; services/animation registration are mocked.
local Loader = require("../loader")
local rb = require("@lune/roblox")
local RS = { Shared = Loader.node("src/shared") }
local mode = "full"
local player = {
	GetAttribute = function(_, key)
		return key == "GraphicsQuality" and (mode == "low" and "Baixo" or "Alto") or false
	end,
}
local game = {
	GetService = function(_, name)
		return ({
			ReplicatedStorage = RS,
			Players = { LocalPlayer = player },
			RunService = {
				IsClient = function()
					return true
				end,
			},
		})[name]
	end,
}
local nativeLoad = Loader.new({ game = game })
local F = nativeLoad("src/shared/ModelFactory.luau")
local builds, registrations = 0, {}
local requested = {}
local factory = {
	detailKey = function()
		return mode
	end,
	build = function(def, level, options)
		builds += 1
		table.insert(requested, options.detail)
		return F.build(def, level, options)
	end,
	bounds = F.bounds,
}
local load = Loader.new({ game = game }, {
	["src/shared/ModelFactory.luau"] = factory,
	["src/client/CreatureAnimator.luau"] = {
		register = function(model, visible)
			local count = 0
			for _, obj in model:GetDescendants() do
				if obj:IsA("BasePart") then
					count += 1
				end
			end
			table.insert(registrations, { model = model, visible = visible, parts = count })
		end,
	},
})
local UI = load("src/client/CollectionUI.luau")
local C = load("src/shared/Creatures.luau")
local function fakeGui(class, parent, x, y, width, height, clips)
	return {
		ClassName = class,
		Parent = parent,
		Visible = true,
		Enabled = true,
		AbsolutePosition = { X = x, Y = y },
		AbsoluteSize = { X = width, Y = height },
		ClipsDescendants = clips,
		IsA = function(self, kind)
			return kind == self.ClassName or (kind == "GuiObject" and self.ClassName ~= "ScreenGui")
		end,
		FindFirstChild = function()
			return nil
		end,
	}
end
local fakeScreen = fakeGui("ScreenGui")
local scroll = fakeGui("ScrollingFrame", fakeScreen, 10, 20, 100, 80, true)
local offscreen = fakeGui("ViewportFrame", scroll, 15, 105, 30, 20)
assert(not UI.visible(offscreen), "Scrolled-out preview remained visible")
assert(UI.preview(offscreen, C.ById.cinzelo, 1, false) == nil and builds == 0, "Clipped preview allocated geometry")
local onePixel = fakeGui("ViewportFrame", scroll, 109, 25, 20, 20)
assert(UI.visible(onePixel), "One pixel of real overlap should remain visible")
onePixel.AbsolutePosition.X = 110
assert(not UI.visible(onePixel), "Touching rectangles have no visible area")
local nested = fakeGui("Frame", scroll, 95, 25, 30, 30, true)
local target = fakeGui("ViewportFrame", nested, 105, 30, 10, 10)
assert(UI.visible(target))
scroll.AbsoluteSize.X = 90
assert(not UI.visible(target), "Nested clipping must use the intersection of all ancestors")
scroll.AbsoluteSize.X = 100
scroll.Visible = false
assert(not UI.visible(target), "Closed scrolling frame remained visible")
scroll.Visible = true
fakeScreen.Enabled = false
assert(not UI.visible(target), "Disabled ScreenGui remained visible")
fakeScreen.Enabled = true
local unclipped = fakeGui("Frame", fakeScreen, 0, 0, 20, 20, false)
assert(UI.visible(fakeGui("ViewportFrame", unclipped, 40, 40, 10, 10)), "Non-clipping ancestor hid its child")
local pendingLayout = fakeGui("ScrollingFrame", fakeScreen, 0, 0, 0, 0, true)
assert(
	UI.visible(fakeGui("ViewportFrame", pendingLayout, 100, 100, 10, 10)),
	"Zero-size ancestor should wait for layout"
)
assert(UI.visible(fakeGui("ViewportFrame", scroll, 0, 0, 0, 0)), "Zero-size target should wait for layout")
local gui = rb.Instance.new("ScreenGui")
local holder = rb.Instance.new("Frame")
holder.Parent = gui
local viewport = UI.preview(holder, C.ById.folhuco, 1, false)
assert(viewport and builds == 1 and requested[1] == "full")
for _ = 1, 100 do
	assert(UI.preview(holder, C.ById.folhuco, 6, false) == viewport)
end
assert(builds == 1 and #registrations == 1, "Repeated stats updates rebuilt a viewport")
mode = "low"
assert(UI.preview(holder, C.ById.folhuco, 6, false) == viewport and builds == 2)
assert(requested[2] == "low" and not registrations[1].visible(), "Removed preview stayed active")
assert(registrations[2].parts < registrations[1].parts, "Low preview did not reduce native geometry")
for _ = 1, 100 do
	UI.preview(holder, C.ById.folhuco, 5, false)
end
assert(builds == 2, "Low-quality updates rebuilt a viewport")
mode = "full"
UI.preview(holder, C.ById.folhuco, 5, false)
assert(builds == 3 and requested[3] == "full")
gui.Enabled = false
mode = "low"
for _ = 1, 100 do
	assert(UI.preview(holder, C.ById.folhuco, 15, false) == viewport)
end
assert(builds == 3 and not registrations[3].visible(), "Hidden previews allocated or animated")
gui.Enabled = true
assert(UI.preview(holder, C.ById.folhuco, 15, false) == viewport and builds == 4)
assert(requested[4] == "low")
holder.Visible = false
UI.preview(holder, C.ById.fenix, 60, true)
assert(builds == 4, "Hidden ancestor created a new species preview")
holder.Visible = true
UI.preview(holder, C.ById.fenix, 60, true)
assert(
	builds == 5 and registrations[5].model:GetAttribute("Species") == "cinzelo",
	"Unknown special preview leaked species"
)
assert(#holder:GetChildren() == 1 and viewport.Parent == holder)
assert(UI.preview(nil, C.ById.cinzelo, 1, false) == nil and builds == 5)
holder:Destroy()
assert(not registrations[5].visible(), "Deleted viewport stayed active")
gui:Destroy()
print(
	"PASS viewport performance: 300 stable/hidden updates, quality transition rebuilds once, viewport reused, deleted views inactive"
)
print(
	"PASS viewport clipping: scrolled-out/closed/disabled/nested/edge rectangles, no allocation outside the clipped area"
)
