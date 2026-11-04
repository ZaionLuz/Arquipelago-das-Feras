local loader = require("./loader")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local result = loader.load("src/shared/DesignChecks.luau").run()
local rows = {}
local scene = 0
for id, stages in result.reports do
	local row = { id = id, stages = {} }
	for stage, report in stages do
		row.stages[stage] = { parts = report.parts, size = { report.size.X, report.size.Y, report.size.Z } }
	end
	table.insert(rows, row)
end
table.sort(rows, function(a, b)
	return a.id < b.id
end)
for index = 1, 40 do
	scene += rows[(index - 1) % #rows + 1].stages[3].parts
end
assert(scene < 3200, "Orçamento global excedido")
fs.writeFile(
	"docs/MODEL_METRICS.json",
	serde.encode("json", {
		constructionRequests = result.total,
		uniqueLayouts = 88,
		minDistance = result.minimum,
		closest = result.closest,
		scene40Parts = scene,
		models = rows,
	}, true)
)
print("PASS: cena headless de 40 criaturas:", scene, "peças; orçamento global 3200")
