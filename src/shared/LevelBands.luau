--!strict
local L = { Order = { "Alvorecer", "Brasa", "Recife", "Floresta", "Dunas", "Picos", "Pantano" }, ById = {} }
for index, id in L.Order do
	local minimum = ({ 1, 10, 18, 26, 34, 42, 50 })[index]
	local maximum = ({ 9, 17, 25, 33, 41, 49, 57 })[index]
	L.ById[id] = {
		id = id,
		index = index,
		min = minimum,
		max = maximum,
		guardian = maximum + 2,
		previous = L.Order[index - 1],
		cost = ({ 0, 1440, 3384, 5112, 6840, 8568, 10296 })[index],
	}
end
return L
