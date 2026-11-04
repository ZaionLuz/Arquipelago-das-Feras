local Loader = require("./loader")
local fs = require("@lune/fs")
local serde = require("@lune/serde")
local old = Loader.load("/tmp/feras-v6-progression.luau")
local rows = {}
local time = 0
local creature = 0
for level = 1, 59 do
	if level <= 49 then
		time += old.playerCost(level) / (50 * 60)
	end
	creature += old.creatureCost(level) / (50 * 30)
	if table.find({ 10, 18, 26, 34, 42, 50 }, level + 1) then
		table.insert(rows, { level = level + 1, hours = time })
	end
end
fs.writeFile(
	"docs/BASELINE_PACING.json",
	serde.encode("json", {
		application = "V6",
		formulaSource = "a35b1ea src/shared/Progression.luau",
		assumptions = "50 vitórias comuns/h, 60 XP explorador e 30 XP criatura/vitória",
		explorer = rows,
		creature60Hours = creature,
	}, true)
)
print("PASS: auditoria quantitativa das curvas V6 exportada")
