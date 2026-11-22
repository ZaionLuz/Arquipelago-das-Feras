--!strict
-- Table.lua - Utilitários para tabelas

local TableUtil = {}

-- Deep copy a table
function TableUtil.DeepCopy<T>(original: T): T
	local copy = {}
	for k, v in pairs(original) do
		if type(v) == "table" then
			copy[k] = TableUtil.DeepCopy(v)
		else
			copy[k] = v
		end
	end
	return copy
end

-- Shallow copy
function TableUtil.ShallowCopy<T>(original: T): T
	local copy = {}
	for k, v in pairs(original) do
		copy[k] = v
	end
	return copy
end

-- Merge tables (later values override earlier)
function TableUtil.Merge(...: {[any]: any}): {[any]: any}
	local result = {}
	for _, t in ipairs({...}) do
		for k, v in pairs(t) do
			result[k] = v
		end
	end
	return result
end

-- Deep merge
function TableUtil.DeepMerge(...: {[any]: any}): {[any]: any}
	local result = {}
	for _, t in ipairs({...}) do
		for k, v in pairs(t) do
			if type(v) == "table" and type(result[k]) == "table" then
				result[k] = TableUtil.DeepMerge(result[k], v)
			else
				result[k] = v
			end
		end
	end
	return result
end

-- Find index of value in array
function TableUtil.FindIndex<T>(array: {T}, predicate: (T) -> boolean): number?
	for i, v in ipairs(array) do
		if predicate(v) then
			return i
		end
	end
	return nil
end

-- Find value in array
function TableUtil.Find<T>(array: {T}, predicate: (T) -> boolean): T?
	for _, v in ipairs(array) do
		if predicate(v) then
			return v
		end
	end
	return nil
end

-- Filter array
function TableUtil.Filter<T>(array: {T}, predicate: (T) -> boolean): {T}
	local result = {}
	for _, v in ipairs(array) do
		if predicate(v) then
			table.insert(result, v)
		end
	end
	return result
end

-- Map array
function TableUtil.Map<T, U>(array: {T}, mapper: (T) -> U): {U}
	local result = {}
	for _, v in ipairs(array) do
		table.insert(result, mapper(v))
	end
	return result
end

-- Reduce array
function TableUtil.Reduce<T, U>(array: {T}, reducer: (U, T) -> U, initial: U): U
	local acc = initial
	for _, v in ipairs(array) do
		acc = reducer(acc, v)
	end
	return acc
end

-- Check if table is empty
function TableUtil.IsEmpty(t: {[any]: any}): boolean
	return next(t) == nil
end

-- Get table length (works for non-array tables)
function TableUtil.Length(t: {[any]: any}): number
	local count = 0
	for _ in pairs(t) do
		count += 1
	end
	return count
end

-- Get keys of table
function TableUtil.Keys<T>(t: {[any]: T}): {any}
	local keys = {}
	for k in pairs(t) do
		table.insert(keys, k)
	end
	return keys
end

-- Get values of table
function TableUtil.Values<T>(t: {[any]: T}): {T}
	local values = {}
	for _, v in pairs(t) do
		table.insert(values, v)
	end
	return values
end

-- Check if table contains key
function TableUtil.HasKey(t: {[any]: any}, key: any): boolean
	return t[key] ~= nil
end

-- Check if array contains value
function TableUtil.Contains<T>(array: {T}, value: T): boolean
	for _, v in ipairs(array) do
		if v == value then
			return true
		end
	end
	return false
end

-- Remove value from array (first occurrence)
function TableUtil.RemoveValue<T>(array: {T}, value: T): boolean
	local index = TableUtil.FindIndex(array, function(v) return v == value end)
	if index then
		table.remove(array, index)
		return true
	end
	return false
end

-- Shuffle array (Fisher-Yates)
function TableUtil.Shuffle<T>(array: {T}): {T}
	local result = TableUtil.ShallowCopy(array)
	for i = #result, 2, -1 do
		local j = math.random(i)
		result[i], result[j] = result[j], result[i]
	end
	return result
end

-- Get random element from array
function TableUtil.RandomElement<T>(array: {T}): T?
	if #array == 0 then return nil end
	return array[math.random(#array)]
end

-- Chunk array into smaller arrays
function TableUtil.Chunk<T>(array: {T}, size: number): {{T}}
	local chunks = {}
	for i = 1, #array, size do
		local chunk = {}
		for j = i, math.min(i + size - 1, #array) do
			table.insert(chunk, array[j])
		end
		table.insert(chunks, chunk)
	end
	return chunks
end

-- Flatten nested arrays
function TableUtil.Flatten<T>(array: {T | {T}}): {T}
	local result = {}
	for _, v in ipairs(array) do
		if type(v) == "table" then
			for _, item in ipairs(TableUtil.Flatten(v)) do
				table.insert(result, item)
			end
		else
			table.insert(result, v)
		end
	end
	return result
end

-- Group by key
function TableUtil.GroupBy<T>(array: {T}, keySelector: (T) -> string): {[string]: {T}}
	local groups = {}
	for _, item in ipairs(array) do
		local key = keySelector(item)
		if not groups[key] then
			groups[key] = {}
		end
		table.insert(groups[key], item)
	end
	return groups
end

return TableUtil