--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 14-06-17
-- Time: 07:38
--
local Engine = require('lib.Engine');
local EngineUtil = require('lib.EngineUtils.EngineUtil')

local Player = require('src.Player')

local basePath = "stream-data/";
local engine;

function getOnline()
    local p = {};
    for _,v in ipairs(global.players) do
        if (game.players[v.player_index].connected) then
            table.insert(p, v);
        end
    end
    return p;
end

function getPlayer(player_index)
    for _,v in ipairs(global.players) do
        if (player_index == v.player_index) then
            return v;
        end
    end
    local p = Player:new(player_index, engine, basePath);
    p:saveSettingsFile();
    table.insert(global.players, p);
    return p;
end

function done(engine)
    local events = engine.events;
    local settings = engine.settings;

    global = global or {}
    global.players = global.players or {}

    game.print(EngineUtil.TableToString(global.players, 0, {}, true));

    events:on(settings.runtimeUserSettingChanged, function(evt)
        local p = getPlayer(evt.player_index);
        p.needsUpdate = true;

        if (evt.setting == "ctf-location") then
            p:removeFile();
        elseif (evt.setting == "ctf-settingslocation") then
            p:removeSettingsFile(function()
                p:update(p.player_index);
                p:saveSettingsFile();
            end);
        end
    end);

    events:on(defines.events.on_console_chat, function(evt)
        getPlayer(evt.player_index):logChat(evt.message, getOnline());
    end);

    events:on(defines.events.on_player_died, function(evt)
        getPlayer(evt.player_index):logDeath(evt, global.players, getOnline());
    end);

    commands.add_command("ChatToFileClear", "command-help.chat-to-file-clear", function(evt)
        local p = getPlayer(evt.player_index)
        p:clear(function() game.players[p.player_index].print("ChatToFile file '".. p.settingLocation .."' cleared") end);
    end)

    remote.add_interface("ChatToFile", {
        chat = function(message)
            local msg = EngineUtil.MakeSafeForRegexRepl(message);

            for _, forPlayer in ipairs(getOnline()) do
                if (forPlayer.needsUpdate) then
                    forPlayer:update(forPlayer.player_index);
                end

                if ((forPlayer.settingEnable) and (forPlayer.settingRemoteEnable)) then
                    local file = forPlayer.basePath .. forPlayer.settingLocation;
                    local prefix = EngineUtil.MakeSafeForRegexRepl(forPlayer.settingPrefix);

                    local data = prefix .. msg .. "\n";

                    forPlayer.engine.files:writeFile(file, data, true, forPlayer.player_index);
                end
            end

            return true;
        end
    });
end

engine = Engine:new();
script.on_event(engine.readyEvent, done)