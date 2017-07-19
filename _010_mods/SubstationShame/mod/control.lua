--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 14-06-17
-- Time: 20:40
--

script.on_init(function()
    onInit();
end)

script.on_load(function()
    -- No "game" Access

    onLoad();
end)

script.on_configuration_changed(function(configChangeData)
    global = {};
    onInit();
end)

local gameData = {}
function onInit()
    global = global or {}

    global.poles = {}

    onLoad();
end

function onLoad()
    script.on_event(defines.events.on_tick, function()
        if (game and global) then

            script.on_event(defines.events.on_built_entity, onBuild)
            script.on_event(defines.events.on_tick, nil)
            script.on_event(defines.events.on_tick, onTick)
        end
    end)
end

local isDisplayed
function onTick()
    if ((game.tick % 180) == 0) then

    end
end

function onBuild(evnt)
    -- evnt {name=number, tick=number, player_index=number, created_entity=LuaEntity, item=string, tags={string->Any}}
    if (evnt.created_entity.name == "substation") then
        table.insert(global.poles, evnt.created_entity)
    end
end