--!strict
-- Signal.lua - Sistema de eventos/sinais tipado

export type Connection = {
	Disconnect: (self: Connection) -> (),
	Connected: boolean,
}

export type Signal<T...> = {
	Connect: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
	Once: (self: Signal<T...>, callback: (T...) -> ()) -> Connection,
	Fire: (self: Signal<T...>, T...) -> (),
	Wait: (self: Signal<T...>) -> T...,
	Destroy: (self: Signal<T...>) -> (),
}

local Signal = {}

function Signal.New<T...>(): Signal<T...>
	local self = {
		_connections = {} :: {Connection},
		_waitingThreads = {} :: {thread},
	}

	function self:Connect(callback: (T...) -> ()): Connection
		local connection = {
			_callback = callback,
			_connected = true,
			_signal = self,
		}

		function connection:Disconnect()
			if self._connected then
				self._connected = false
				local index = table.find(self._signal._connections, connection)
				if index then
					table.remove(self._signal._connections, index)
				end
			end
		end

		table.insert(self._connections, connection)
		return connection
	end

	function self:Once(callback: (T...) -> ()): Connection
		local connection: Connection
		connection = self:Connect(function(...)
			connection:Disconnect()
			callback(...)
		end)
		return connection
	end

	function self:Fire(...: T...)
		for _, connection in ipairs(self._connections) do
			if connection._connected then
				task.spawn(connection._callback, ...)
			end
		end

		for _, thread in ipairs(self._waitingThreads) do
			task.spawn(thread, ...)
		end
		table.clear(self._waitingThreads)
	end

	function self:Wait(): T...
		local thread = coroutine.running()
		table.insert(self._waitingThreads, thread)
		return coroutine.yield()
	end

	function self:Destroy()
		for _, connection in ipairs(self._connections) do
			connection._connected = false
		end
		table.clear(self._connections)
		table.clear(self._waitingThreads)
	end

	return self
end

-- Signal that holds the last fired value
function Signal.NewValue<T>(initialValue: T?): {Value: T, Changed: Signal<T>, Get: (self: any) -> T, Set: (self: any, T) -> ()}
	local signal = Signal.New()
	local value = initialValue

	return {
		Value = initialValue,
		Changed = signal,
		Get = function(self)
			return value
		end,
		Set = function(self, newValue: T)
			value = newValue
			self.Value = newValue
			signal:Fire(newValue)
		end,
	}
end

return Signal