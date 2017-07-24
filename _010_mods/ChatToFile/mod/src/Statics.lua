--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 24-07-17
-- Time: 09:52
--
local Statics = {};
Statics.__index = Statics;

--- Creates the Statics object
-- @return Statics The Statics object that was just created.
function Statics:new(engine)
    local obj = {};
    setmetatable(obj, Statics);

    self.engine = engine;

    return obj;
end

function Statics:save()
    local players = global.players;
    local online = {};

    local _deaths = 0;
    local _playerDeaths = {};
    local _messages = 0;
    local _playerMessages = {};
    local _online = {};
    local _players = {}
    for _,v in ipairs(players) do
        _deaths = _deaths + #v.deaths;
        _playerDeaths[v.name] = #v.deaths;
        _messages = _messages + v.messages;
        _playerMessages[v.name] = v.messages;
        table.insert(_players, v.name);
        if (game.players[v.player_index].connected) then
            table.insert(_online, v.name);
            table.insert(online, v);
        end
    end

    local savestr = "{"

    savestr = savestr.. "\"deaths\": ".._deaths..",";
    savestr = savestr.. "\"messages\": ".._messages..",";

    savestr = savestr.. "\"playerDeaths\": {";
    for k,v in pairs(_playerDeaths) do
        savestr = savestr.. "\""..k:lower().."\": "..v..",";
    end
    savestr = savestr:sub(1, -2)
    savestr = savestr.. "},";

    savestr = savestr.. "\"playerMessages\": {";
    for k,v in pairs(_playerMessages) do
        savestr = savestr.. "\""..k:lower().."\": "..v..",";
    end
    savestr = savestr:sub(1, -2)
    savestr = savestr.. "},";

    savestr = savestr.. "\"online\": [";
    for _,v in pairs(_online) do
        savestr = savestr.. "\""..v.."\",";
    end
    savestr = savestr:sub(1, -2)
    savestr = savestr.. "],";

    savestr = savestr.. "\"players\": [";
    for _,v in pairs(_players) do
        savestr = savestr.. "\""..v.."\",";
    end
    savestr = savestr:sub(1, -2)
    savestr = savestr.. "]";

    savestr = savestr .. "}";

    for k,v in ipairs(online) do
        if v.settingEnable then
            local path = v.basePath .. v.settingStaticsLocation;

            self.engine.files:writeFile(path, savestr, false, v.player_index);
        end
    end
end

return Statics
