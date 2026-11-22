--!strict
-- RemoteClient.lua - Cliente para comunicação com servidor

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Players = game:GetService("Players")

local Signal = require(ReplicatedStorage.Shared.Util.Signal)

local RemoteClient = {}

local Remotes = {} :: {[string]: RemoteEvent | RemoteFunction}
local EventConnections = {} :: {[string]: RBXScriptConnection}
local PendingInvokes = {} :: {[number]: {Thread: thread, Resolve: (any?) -> (), Reject: (string) -> ()}}
local InvokeId = 0

-- Initialize
function RemoteClient.Initialize()
	local remoteFolder = ReplicatedStorage:WaitForChild("Remotes", 10)
	if not remoteFolder then
		warn("[RemoteClient] Remotes folder not found!")
		return
	end

	-- Cache remotes
	for _, child in ipairs(remoteFolder:GetChildren()) do
		if child:IsA("RemoteEvent") or child:IsA("RemoteFunction") then
			Remotes[child.Name] = child

			if child:IsA("RemoteEvent") then
				child.OnClientEvent:Connect(function(...)
					RemoteClient._FireEvent(child.Name, ...)
				end)
			end
		end
	end

	print(`[RemoteClient] Initialized with {TableUtil.Length(Remotes)} remotes`)
end

-- Helper
local TableUtil = require(ReplicatedStorage.Shared.Util.Table)

-- Event system
local EventCallbacks = {} :: {[string]: {(...any) -> ()}}

function RemoteClient.On(eventName: string, callback: (...any) -> ())
	if not EventCallbacks[eventName] then
		EventCallbacks[eventName] = {}
	end
	table.insert(EventCallbacks[eventName], callback)

	return function()
		local callbacks = EventCallbacks[eventName]
		if callbacks then
			local index = table.find(callbacks, callback)
			if index then table.remove(callbacks, index) end
		end
	end
end

function RemoteClient.Once(eventName: string, callback: (...any) -> ())
	local disconnect
	disconnect = RemoteClient.On(eventName, function(...)
		disconnect()
		callback(...)
	end)
end

function RemoteClient._FireEvent(eventName: string, ...: any)
	local callbacks = EventCallbacks[eventName]
	if callbacks then
		for _, callback in ipairs(callbacks) do
			task.spawn(callback, ...)
		end
	end
end

-- Fire server event
function RemoteClient.Fire(eventName: string, ...: any)
	local remote = Remotes[eventName]
	if remote and remote:IsA("RemoteEvent") then
		remote:FireServer(...)
	else
		warn(`[RemoteClient] RemoteEvent not found: {eventName}`)
	end
end

-- Invoke server function
function RemoteClient.Invoke(eventName: string, ...: any): any?
	local remote = Remotes[eventName]
	if remote and remote:IsA("RemoteFunction") then
		local success, result = pcall(function()
			return remote:InvokeServer(...)
		end)
		if success then
			return result
		else
			warn(`[RemoteClient] Invoke failed for {eventName}: {result}`)
			return nil
		end
	else
		warn(`[RemoteClient] RemoteFunction not found: {eventName}`)
		return nil
	end
end

-- Invoke server with timeout
function RemoteClient.InvokeWithTimeout(eventName: string, timeout: number, ...: any): (any?, string?)
	local remote = Remotes[eventName]
	if not remote or not remote:IsA("RemoteFunction") then
		return nil, "Remote not found"
	end

	local thread = coroutine.running()
	local completed = false
	local result = {nil}

	task.spawn(function()
		local success, res = pcall(function()
			return remote:InvokeServer(...)
		end)
		if success then
			result = {res}
		else
			result = {nil, res}
		end
		completed = true
		if coroutine.status(thread) == "suspended" then
			task.spawn(thread)
		end
	end)

	if not completed then
		task.wait(timeout)
	end

	if not completed then
		return nil, "Timeout"
	end

	return result[1], result[2]
end

-- Get remote instance
function RemoteClient.GetRemote(name: string): RemoteEvent | RemoteFunction?
	return Remotes[name]
end

-- Check if remote exists
function RemoteClient.HasRemote(name: string): boolean
	return Remotes[name] ~= nil
end

return RemoteClient