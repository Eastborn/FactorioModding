--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 14-06-17
-- Time: 07:38
--
local Engine = require('lib.Engine');
local EngineUtil = require('lib.EngineUtils.EngineUtil');

local Train = require('src.Train');

local basePath = "stream-data/";
local engine;

--[[
on_entity_died
    -entity :: LuaEntity
    -cause :: LuaEntity (optional): The entity that did the killing if available.
    -force :: LuaForce (optional): The force that did the killing if any.
on_player_mined_entity
    Called after the results of an entity being mined are collected just before the entity is destroyed. After this event any items in the buffer will be transferred into the player as if they came from mining the entity.
    -player_index :: uint: The index of the player doing the mining.
    -entity :: LuaEntity: The entity that has been mined.
    -buffer :: LuaInventory: The temporary inventory that holds the result of mining the entity.
on_player_rotated_entity
    -Called when the player rotates an entity. This event is only fired when the entity actually changes its orientation -- pressing the rotate key on an entity that can't be rotated won't fire this event.
    -entity :: LuaEntity: The rotated entity.
    -player_index :: uint
on_train_changed_state
    Called when a train changes state (started to stopped and vice versa)
    -train :: LuaTrain
on_runtime_mod_setting_changed
    Called when a runtime mod setting is changed by a player.
    -player_index :: uint: The player who changed the setting
    -setting :: string: The setting name that changed
    -setting_type :: string: The setting type: "runtime-per-user", or "runtime-global"
]]

local function getTrainCount()
    local c = 0;
    for _,v in pairs(global.Trains) do
        if (v) then
            c = c + 1;
        end
    end
    return c;
end

local function writeTrainCount()
    local settings = engine.settings
    local files = engine.files;
    local amount = getTrainCount();
    for _,p in pairs(game.players) do
        local enabled = settings:getRuntimePlayerSetting(p.index, "tctf-enabled");

        if (enabled) then
            local path = settings:getRuntimePlayerSetting(p.index, "tctf-location");
            local sub = settings:getRuntimePlayerSetting(p.index, "tctf-sub");

            local data = sub:gsub("$t", amount);

            files:writeFile(basePath..path, data, false, p.index)
        end
    end
end

local function done()
    global = global or {};

    if (global.Trains) then
        for k,v in pairs(global.Trains) do
            global.Trains[k] = Train:fromSerialized(v);
        end
    else
        global.Trains = {}
    end

    writeTrainCount();
end

local function load()
    local events = engine.events;

    --Called when a new train is created either through disconnecting/connecting an existing one or building a new one.
    --      train :: LuaTrain
    --      old_train_id_1 :: uint (optional): The first old train id when splitting/merging trains.
    --      old_train_id_2 :: uint (optional): The second old train id when splitting/merging trains.
    -- Event is emitted on new train creation (including for any single carriage when you add that to a train) with only evt.train;
    -- Event is emmited on train merging (pressing g or right after single carriage addition) with evt.train/evt.old_train_id_1/evt.old_train_id_2; IN THE SAME TICK
    --      Merging 3 trains will emit this event twice once for the first 2 and another time with the generated train from the previous event and the remaining one;
    -- Event is emitted on train splitting (pressing v) with evt.train/evt.old_train_id_1 twice for each resulting train; IN THE SAME TICK
    events:on(defines.events.on_train_created, function(evt)
        local t = Train:new(evt.train)

        if (Train.IdChangeReason(Train.Create, evt)) then
            -- Create train
            global.Trains[t.id]=t;
        elseif (Train.IdChangeReason(Train.Merge, evt)) then
            -- Merge train
            global.Trains[t.id]=t;
            global.Trains[evt.old_train_id_1] = nil;
            global.Trains[evt.old_train_id_2] = nil;
        elseif (Train.IdChangeReason(Train.Split, evt)) then
            -- Split train
            global.Trains[t.id]=t;
            global.Trains[evt.old_train_id_1] = nil;
        end

        game.print(getTrainCount())
    end)

    --on_entity_died
    --      entity :: LuaEntity
    --      cause :: LuaEntity (optional): The entity that did the killing if available.
    --      force :: LuaForce (optional): The force that did the killing if any.
    events:on(defines.events.on_entity_died, function(evt)
        game.print(EngineUtil.TableToString(evt));
        game.print("CRASH between "..evt.entity.train.id.. " "..evt.cause.train.id);
        if (evt.entity and evt.entity.train and global.Trains[evt.entity.train.id]) then
            game.print("CRASH between "..evt.entity.train.id.. " "..evt.cause.train.id);
            global.Trains[evt.entity.train.id] = nil;
        end

        game.print(getTrainCount())
    end)
end

engine = Engine:new(load, done);
