--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 18-07-17
-- Time: 00:08
--
local Settings = {};
Settings.__index = Settings;

--- Creates the Settings object
-- @return Settings The Settings object that was just created.
function Settings:new(engine)
    local obj = {};
    setmetatable(obj, Settings);

    obj.runtimeUserSettingChanged = script.generate_event_name();
    obj.runtimeGlobalSettingChanged = script.generate_event_name();

    engine.events:on(defines.events.on_runtime_mod_setting_changed, function(evt)
        if (evt.setting_type == "runtime-per-user") then
            engine.events:emit(obj.runtimeUserSettingChanged, {
                player_index=evt.player_index,
                setting=evt.setting,
                value=self:getRuntimePlayerSetting(evt.player_index, evt.setting)
            });
        else
            engine.events:emit(obj.runtimeGlobalSettingChanged, {
                --player_index=evt.player_index,
                setting=evt.setting,
                value=self:getRuntimeGlobalSetting(evt.setting)
            });
        end
    end)



    return obj;
end

function Settings:getRuntimePlayerSetting(player, setting)
    local t = type(player);
    if (t == "table") then
        return player.mod_settings[setting].value;
    elseif (t == "string" or t == "number") then
        return game.players[player].mod_settings[setting].value;
    end
    return nil;
end

function Settings:getRuntimeGlobalSetting(setting)
    return settings.global[setting].value;
end

function Settings:getStartupSetting(setting)
    return settings.startup[setting].value;
end

return Settings
