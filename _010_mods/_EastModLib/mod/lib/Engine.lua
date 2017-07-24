--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 10-06-17
-- Time: 16:57
--
local Engine = {};
Engine.__index = Engine;

local Events = require('lib.EventSystem.Events');
local Files = require('lib.FileSystem.Files');
local Settings = require('lib.SettingSystem.Settings');
local instance;

--- Creates/fetches the Engine object
-- @return Engine The engine object. this is a singleton that provides access to the rest of the EastAPI.
function Engine:new(onLoad, onDone)
    if (instance == nil) then
        local obj = {};
        setmetatable(obj, Engine);

        obj.events = nil;
        obj.files = nil;
        obj.settings = nil;

        obj.readyEvent = script.generate_event_name();

        local function load()
            obj.events = Events:new(obj);
            obj.files = Files:new(obj);
            obj.settings = Settings:new(obj);



            obj.readyKey = obj.events:on(defines.events.on_tick, function()
                if game then
                    obj.events:off(defines.events.on_tick, obj.readyKey)

                    script.raise_event(obj.readyEvent, obj);

                    onDone();
                end
            end)

            onLoad();
        end

        script.on_init(load)
        script.on_load(load)

        instance = obj;
    end
    return instance;
end

return Engine
