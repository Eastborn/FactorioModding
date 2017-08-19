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

function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end

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
        for k,v in ipairs(global.players) do
            if (player_index == v.player_index) then
                if (v.logJoin == nil) then
                    local p = Player:fromSerialized(v, engine);
                    global.players[k] = p;
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
    return global.players;

    --[[local p = {};
    for _,v in ipairs(global.players) do
        if (game.players[v.player_index].connected) then
            table.insert(p, v);
        end
    end
    return p;]]--
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

    commands.add_command("ChatToFileSetDeaths", "command-help.ctf-sd", function(evt)
        local t = evt.parameter:split(" ");
        if (#t == 2) then
            local pl;
            for _,v in pairs(game.players) do
                if (v.name:lower() == t[1]:lower()) then
                       pl = v;
                end
            end
            local t2 = tonumber(t[2]);
            if (pl) then
                if (t2) then
                    local p = getPlayer(pl.index);
                    local dLen = #p.deaths;
                    if (dLen > t2) then
                        local delta = dLen - t2;
                        for i=1, delta, 1 do
                            table.remove(p.deaths, 1);
                        end
                    elseif (dLen < t2) then
                        local delta = t2 - dLen
                        for i=1,delta,1 do
                            table.insert(p.deaths, 1, "<unknown reason>");
                        end
                    end
                    statics:save();
                    game.players[evt.player_index].print(pl.name.." his deaths have been set to "..t2);
                else
                    game.players[evt.player_index].print("amount of deaths "..t[1].." is not a valid number")
                end
            else
                game.players[evt.player_index].print("player "..t[1].." does not exist")
            end
        else
            game.players[evt.player_index].print("2 parameters needed <Username> and <amount of deaths>")
        end
    end);

    commands.add_command("ChatToFileGetOldDeaths", "command-help.ctf-god", function(evt)
        if (global.playersDiedInfo and #global.playersDiedInfo > 0) then
            local obj = {}
            for _,v in ipairs(global.playersDiedInfo) do
                if (obj[v.index]) then
                    obj[v.index] = obj[v.index] + 1;
                else
                    obj[v.index] = 1;
                end
            end
            for k,v in pairs(obj) do
                game.players[evt.player_index].print(game.players[k].name..":"..v);
            end
        end
    end);

    remote.add_interface("ChatToFile", {
        chat = remoteCall,
        playerUpdate = remoteUpdate
    });
end

engine = Engine:new(load, done);
statics = Statics:new(engine);