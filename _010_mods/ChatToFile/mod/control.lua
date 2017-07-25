--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 14-06-17
-- Time: 07:38
--
local Engine = require('lib.Engine');
local EngineUtil = require('lib.EngineUtils.EngineUtil');

local Player = require('src.Player');
local Statics = require('src.Statics');

local basePath = "stream-data/";
local engine;
local statics;

local function done()
    global = global or {}
    if (not global.players) then
        global.players = {};
    end

    if (global.players) then
        for k,v in ipairs(global.players) do
            global.players[k] = Player:fromSerialized(v, engine);
        end
    else
        global.players = {}
    end

    local function getPlayer(player_index)
        for _,v in ipairs(global.players) do
            if (player_index == v.player_index) then
                if (v.logJoin == nil) then
                    local p = Player:fromSerialized(v, engine);
                    global.players[_] = p;
                    return p;
                end
                return v;
            end
        end
        local p = Player:new(player_index, engine, basePath);
        p:saveSettingsFile(engine);
        statics:save();
        table.insert(global.players, p);
        return p;
    end

    for _,v in pairs(game.players) do


        local p = getPlayer(v.index);
        p:saveSettingsFile(engine);
    end

    statics:save();
end

local function getOnline()
    local p = {};
    for _,v in ipairs(global.players) do
        if (game.players[v.player_index].connected) then
            table.insert(p, v);
        end
    end
    return p;
end

local function getPlayer(player_index)
    if (game and not global.players) then
        done();
    end
    for _,v in ipairs(global.players) do
        if (player_index == v.player_index) then
            if (v.logJoin == nil) then
                local p = Player:fromSerialized(v, engine);
                global.players[_] = p;
                return p;
            end
            return v;
        end
    end
    local p = Player:new(player_index, engine, basePath);
    p:saveSettingsFile(engine);
    statics:save();
    table.insert(global.players, p);
    return p;
end

local function remoteCall(message)
    local msg = EngineUtil.MakeSafeForRegexRepl(message);

    for _, forPlayer in ipairs(getOnline()) do
        if (forPlayer.needsUpdate) then
            forPlayer:update(forPlayer.player_index, engine);
        end

        if ((forPlayer.settingEnable) and (forPlayer.settingRemoteEnable)) then
            local file = forPlayer.basePath .. forPlayer.settingLocation;
            local prefix = EngineUtil.MakeSafeForRegexRepl(forPlayer.settingPrefix);

            local data = prefix .. msg .. "\n";

            engine.files:writeFile(file, data, true, forPlayer.player_index);
        end
    end

    return true;
end

local function remoteUpdate(player_index)
    if (player_index and game.players[player_index]) then
        local p = getPlayer(player_index);
        p:update(p.player_index, engine);
        p:saveSettingsFile(engine);
    end
end

local function load()
    local events = engine.events;
    local settings = engine.settings;

    events:on(defines.events.on_console_chat, function(evt)
        getPlayer(evt.player_index):logChat(evt.message, getOnline(), engine);
        statics:save();
    end);

    events:on(defines.events.on_player_died, function(evt)
        getPlayer(evt.player_index):logDeath(evt, global.players, getOnline(), engine);
        statics:save();
    end);

    events:on(defines.events.on_player_changed_force, function(evt)
        getPlayer(evt.player_index):update(evt.player_index, engine);
    end)

    events:on(defines.events.on_player_joined_game, function(evt)
        local p = getPlayer(evt.player_index);
        p:logJoin(global.players, getOnline(), engine);
        p:saveSettingsFile(engine);
        statics:save();
    end);

    events:on(defines.events.on_player_left_game, function(evt)
        getPlayer(evt.player_index):logLeave(global.players, getOnline(), engine);
        statics:save();
    end);

    events:on(settings.runtimeUserSettingChanged, function(evt)
        if (evt.setting and string.match(evt.setting, "ctf-")) then
            local p = getPlayer(evt.player_index);
            p:update(p.player_index, engine);
            p:saveSettingsFile(engine);
        end
    end);

    commands.add_command("ChatToFileClear", "command-help.ctf-clear", function(evt)
        local p = getPlayer(evt.player_index)
        p:clear(function() game.players[p.player_index].print("ChatToFile file '".. p.settingLocation .."' cleared") end, engine);
    end);

    commands.add_command("ChatToFileWhisper", "command-help.ctf-w", function(evt)
        local p = getPlayer(evt.player_index)
        game.print(p.name..": "..evt.parameter);
    end);

    remote.add_interface("ChatToFile", {
        chat = remoteCall,
        playerUpdate = remoteUpdate
    });
end

engine = Engine:new(load, done);
statics = Statics:new(engine);