--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 10-06-17
-- Time: 17:00
--
local Events = {};
Events.__index = Events;

local EngineUtil = require('lib.EngineUtils.EngineUtil');

function Events:new(engine)
    local obj = {};
    setmetatable(obj, Events);

    obj.listeners = {};

    return obj;
end

--- Adds The listener to the end of the listeners array for the event named eventName.
-- No checks are made to see if the listener has already been added.
-- Multiple calls passing the same combination of eventName and listener will result in the listener being added,
--   and called multiple times.
-- @param eventName string The name of the event.
-- @param listener Function The callback function.
-- @return string The id of the generated event listener.
function Events:addListener(eventName, listener, unshift)
    unshift = unshift or false;

    if (self.listeners[eventName] == nil) then
        self.listeners[eventName] = {};

        script.on_event(eventName, function(evt)
            if (self.listeners[eventName] and #self.listeners[eventName] > 0) then
                if (evt) then
                    self:emit(eventName, evt);
                else
                    self:emit(eventName, {});
                end
            end
        end)
    end

    local keys = {};
    for k,_ in ipairs(self.listeners) do
        table.insert(keys, k);
    end

    local id = EngineUtil.GenerateUniqueID(keys);
    if (unshift) then
        table.insert(self.listeners[eventName], 1, {id=id, listener=listener});
    else
        table.insert(self.listeners[eventName], {id=id, listener=listener});
    end

    return id;
end

--- Alias of addListener.
-- @param eventName string The name of the event.
-- @param listener Function The callback function.
-- @return string The id of the generated event listener
function Events:on(eventName, listener)
    return self:addListener(eventName, listener);
end

--- Adds a one time listener function to the event named eventName.
-- The next time eventName is triggered, this listener is removed and then invoked.
-- @param eventName string The name of the event.
-- @param listener Function The callback function.
-- @return string The id of the generated event listener.
function Events:once(eventName, listener, unshift)
    unshift = unshift or false;

    if (self.listeners[eventName] == nil) then
        self.listeners[eventName] = {};

        script.on_event(eventName, function(evt)
            if (self.listeners[eventName] and #self.listeners[eventName] > 0) then
                if (evt) then
                    self:emit(eventName, evt);
                else
                    self:emit(eventName, {});
                end
            end
        end)
    end

    local keys = {};
    for k,_ in ipairs(self.listeners) do
        table.insert(keys, k);
    end

    local id = EngineUtil.GenerateUniqueID(keys);

    local d = function(evt)
        local data;
        if evt then
            data = listener(evt);
        else
            data = listener();
        end
        for i=#self.listeners[eventName],1,-1 do
            if self.listeners[eventName][i].id == id then
                table.remove(self.listeners[eventName], i);
            end
        end

        if data and #data > 0 then
            return unpack(data);
        end
        return data;
    end
    if (unshift) then
        table.insert(self.listeners[eventName], 1, {id=id, listener=d});
    else
        table.insert(self.listeners[eventName], {id=id, listener=d});
    end

    return id;
end

--- Alias of addlistener except the listener is added to the front of the listeners array for the event named eventName.
-- @param eventName string The name of the event.
-- @param listener Function The callback function.
-- @return string The id of the generated event listener.
function Events:prependListener(eventName, listener)
    return self:addListener(eventName, listener, true);
end

--- Alias of once except the listener is added to the front of the listeners array for the event named eventName.
-- @param eventName string The name of the event.
-- @param listener Function The callback function.
-- @return string The id of the generated event listener.
function Events:prependOnceListener(eventName, listener)
    return self:once(eventName, listener, true);
end

--- Removes the specified listener with listenerId from the listener array for the event named eventName.
-- @param eventName string The name of the event.
-- @param listenerId string The id of the listener to remove.
-- @return Events Returns a reference of self, so that calls can be chained.
function Events:removeListener(eventName, listenerId)
    for i=#self.listeners[eventName],1,-1 do
        if self.listeners[eventName][i].id == listenerId then
            table.remove(self.listeners[eventName], i);
        end
    end
    return self;
end

--- Alias of removeListener.
-- @param eventName string The name of the event.
-- @param listenerId string The id of the listener to remove.
-- @return Events Returns a reference of self, so that calls can be chained.
function Events:off(eventName, listenerId)
    return self:removeListener(eventName, listenerId);
end

--- Removes all listeners, or those of the specified eventName.
-- @return Events Returns a reference of self, so that calls can be chained.
function Events:removeAllListeners(eventName)
    if (eventName) then
        self.listeners[eventName] = {};
    else
        self.listeners = {};
    end
    return self;
end

--- Calls each of the listeners registered for the event named Eventname, in the order they were registered, passing the supplied arguments to each.
-- @param eventName string The name of the event.
-- @param ...ARGS any[] The arguments that should be supplied to the listeners.
-- @return boolean Returns true if there were any listeners, false otherwise.
function Events:emit(eventName, evt)
    if (self.listeners[eventName]) then
        for i=1,#self.listeners[eventName],1 do
            if evt then
                self.listeners[eventName][i].listener(evt);
            else
                self.listeners[eventName][i].listener();
            end
        end
    end
end

--- Returns an array of the names of the events for which the emitter has registered listeners.
-- @return string[] The list of eventnames that have listeners.
function Events:eventNames()
    local names = {}
    for k,v in ipairs(self.listeners) do
        if (#v > 0) then
            table.insert(names, k);
        end
    end
    return names;
end

--- Gets the amount of listeners of the event with given eventName.
-- @param eventName string The name of the event being listened for.
-- @return number The amount of listeners the event with eventName had.
function Events:listenerCount(eventName)
    return #self.listeners[eventName]
end

--- Returns a copy of the array of listeners for the event named eventName.
-- @param eventName string The name of the event to retrieve the listeners for.
-- @return Function[] A list of listener ids from the event with name eventName.
function Events:listeners(eventName)
    local listeners = {}
    for _,v in ipairs(self.listeners[eventName]) do
        table.insert(listeners, v);
    end
    return listeners;
end

--- Returns a copy of the array of listener ids for the event named eventName.
-- @param eventName string The name of the event to retrieve the listeners for.
-- @return string[] A list of listener ids from the event with name eventName.
function Events:listenerIds(eventName)
    local listenerIds = {}
    for k,_ in ipairs(self.listeners[eventName]) do
        table.insert(listenerIds, k);
    end
    return listenerIds;
end

--- Gets the listener function identified by listenerId in the event named eventName.
-- @param eventName string The name of the event to retrieve the listener from.
-- @param listenerId string The id of the listener.
-- @return Function The listner.
function Events:getListener(eventName, listenerId)
    for i = 1, #self.listeners[eventName], 1 do
        if (self.listeners[eventName][i].id == listenerId) then
            return self.listeners[eventName][i];
        end
    end
end

return Events