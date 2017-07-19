--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 14-06-17
-- Time: 20:40
--

local baseFolder = "stream_data/";
local baseFile = "mods_to_file.txt"

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

function onInit()
    global = global or {}

    onLoad();
end

function onLoad()
    script.on_event(defines.events.on_tick, function()
        if (game and global) then

            local str = {}
            for k,v in pairs(game.active_mods) do
                if k ~= "base" then
                    table.insert(str, k);
                end
            end

            if #str > 0 then
                game.write_file(baseFolder..baseFile, table.concat(str, ", "))
            end

            script.on_event(defines.events.on_tick, nil)
        end
    end)
end