--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 18-07-17
-- Time: 01:30
--
local Player = {};
Player.__index = Player;

local EngineUtil = require('lib.EngineUtils.EngineUtil')

--- Creates the Player object
-- @return Player The Player object that was just created.
function Player:new(player_index, engine, basePath)
    local obj = {};
    setmetatable(obj, Player);

    obj.basePath = basePath;

    obj:update(player_index, engine);

    obj.deaths = {};
    obj.messages = 0;

    return obj;
end

function Player:fromSerialized(serialized, engine)
    local obj = {};
    setmetatable(obj, Player);

    obj.basePath = serialized.basePath;

    obj:update(serialized.player_index, engine);

    obj.deaths = serialized.deaths;
    obj.messages = serialized.messages;

    return obj;
end

function Player:update(player_index, engine)
    local p = game.players[player_index];

    self.player_index = player_index;
    self.name = p.name or "<unknown_player>";
    self.force = p.force.name or "<unknown_force>";

    self.settingEnable = engine.settings:getRuntimePlayerSetting(p, "ctf-enable");
    self.settingChatEnable =engine.settings:getRuntimePlayerSetting(p, "ctf-chatenable");
    self.settingDeathEnable = engine.settings:getRuntimePlayerSetting(p, "ctf-deathenable");
    self.settingDeathScreenshotEnable = engine.settings:getRuntimePlayerSetting(p, "ctf-deathscreenshotenable");
    self.settingJoinEnable = engine.settings:getRuntimePlayerSetting(p, "ctf-joinenable");
    self.settingLeaveEnable = engine.settings:getRuntimePlayerSetting(p, "ctf-leaveenable");
    self.settingRemoteEnable = engine.settings:getRuntimePlayerSetting(p, "ctf-remoteenable");
    self.settingLocation = engine.settings:getRuntimePlayerSetting(p, "ctf-location");
    self.settingSettingsLocation = engine.settings:getRuntimePlayerSetting(p, "ctf-settingslocation");
    self.settingStaticsLocation = engine.settings:getRuntimePlayerSetting(p, "ctf-staticslocation");
    self.settingDeathScreenshotLocation = engine.settings:getRuntimePlayerSetting(p, "ctf-deathscreenlocation");
    self.settingDelay = engine.settings:getRuntimePlayerSetting(p, "ctf-delay");
    self.settingPrefix = engine.settings:getRuntimePlayerSetting(p, "ctf-prefix");
    self.settingChatSub = engine.settings:getRuntimePlayerSetting(p, "ctf-chatsub");
    self.settingDeathSub = engine.settings:getRuntimePlayerSetting(p, "ctf-deathsub");
    self.settingJoinSub = engine.settings:getRuntimePlayerSetting(p, "ctf-joinsub");
    self.settingLeaveSub = engine.settings:getRuntimePlayerSetting(p, "ctf-leavesub");

    self.needsUpdate = false;
end

function Player:logChat(message, forPlayers, engine)
    if (self.needsUpdate) then
        self:update(self.player_index);
    end

    local player = EngineUtil.MakeSafeForRegexRepl(self.name);
    local force = EngineUtil.MakeSafeForRegexRepl(self.force);
    local msg = EngineUtil.MakeSafeForRegexRepl(message);

    self.messages = self.messages + 1;

    for _,forPlayer in ipairs(forPlayers) do
        if (forPlayer.needsUpdate) then
            forPlayer:update(forPlayer.player_index);
        end

        if ((forPlayer.settingEnable) and (forPlayer.settingChatEnable)) then
            local file = forPlayer.basePath .. forPlayer.settingLocation;
            local prefix = forPlayer.settingPrefix;
            local sub = forPlayer.settingChatSub;

            local data = prefix ..
                    sub
                        :gsub("$f", force)
                        :gsub("$m", msg)
                        :gsub("$p", player) ..
                    "\n";

            engine.files:writeFile(file, data, true, forPlayer.player_index);
        end
    end
end

function Player:logDeath(evt, allPlayers, forPlayers, engine)
    local reason = "<unknown reason>";

    if (evt.cause == nil) then
        reason = "<unknown reason> most likely a Landmine or Poison Capsule"
    else
        if (evt.cause.name == "small-worm-turret") then reason = "Small Worm";
        elseif (evt.cause.name == "medium-worm-turret") then reason = "Medium Worm";
        elseif (evt.cause.name == "big-worm-turret") then reason = "Big Worm";
        elseif (evt.cause.name == "small-biter") then reason = "Small Biter";
        elseif (evt.cause.name == "medium-biter") then reason = "Medium Biter";
        elseif (evt.cause.name == "big-biter") then reason = "Big Biter";
        elseif (evt.cause.name == "behemoth-biter") then reason = "Behemoth Biter";
        elseif (evt.cause.name == "small-spitter") then reason = "Small Spitter";
        elseif (evt.cause.name == "medium-spitter") then reason = "Medium Spitter";
        elseif (evt.cause.name == "big-spitter") then reason = "Big Spitter";
        elseif (evt.cause.name == "behemoth-spitter") then reason = "Behemoth Spitter";
        else
            if (evt.cause.type == "locomotive" or evt.cause.type == "cargo-wagon" or evt.cause.type == "fluid-wagon") then
                local train = evt.cause.train;
                local trainId = train.id;
                local manual = train.manual_mode;

                reason = "Train("..trainId..")";

                local passengers = {};
                local function getPassengerFromStock(stock)
                    local passenger = stock.get_driver();
                    if (passenger) then
                        table.insert(passengers, passenger.player.name);
                    end
                end
                if (train.locomotives.front_movers) then for _,v in pairs(train.locomotives.front_movers) do getPassengerFromStock(v) end end
                if (train.locomotives.back_movers) then for _,v in pairs(train.locomotives.back_movers) do getPassengerFromStock(v) end end
                for _,v in pairs(train.cargo_wagons) do getPassengerFromStock(v) end
                for _,v in pairs(train.fluid_wagons) do getPassengerFromStock(v) end
                for _,v in pairs(train.carriages) do
                    if v.name == "artillery-wagon" then
                        local passenger = v.get_driver();
                        if (passenger) then
                            table.insert(passengers, passenger.player.name);
                        end
                    end
                end
                if (manual) then
                    if (#passengers > 0) then
                        reason = reason.." being driven by "..table.concat(passengers, ", ");
                    else
                        reason = reason.." in manual mode with no driver(s)";
                    end
                else
                    local schedule = train.schedule;

                    if (schedule and schedule.records and schedule.current and schedule.records[schedule.current]) then
                        reason = reason.." traveling to "..schedule.records[schedule.current].station
                    end

                    if (#passengers > 0) then
                        reason = reason.." carrying "..table.concat(passengers, ", ");
                    end
                end
            elseif (evt.cause.type == "car") then
                if (evt.cause.name == "car") then
                    reason = "Car"
                    if (evt.cause.get_driver()) then
                        reason = reason.." driven by "..evt.cause.get_driver().player.name;
                    elseif (evt.cause.last_user) then
                        reason = reason.." last changed by"..evt.cause.last_user.name;
                    end
                elseif (evt.cause.name == "tank") then
                    reason = "Tank"
                    if (evt.cause.get_driver()) then
                        reason = reason.." driven by "..evt.cause.get_driver().player.name;
                    elseif (evt.cause.last_user) then
                        reason = reason.." last changed by"..evt.cause.last_user.name;
                    end
                end
            elseif (evt.cause.type == "player") then
                reason = evt.cause.player.name;
            elseif (evt.cause.type == "combat-robot") then
                if (evt.cause.name == "defender") then reason = "Defender robot";
                elseif (evt.cause.name == "distractor") then reason = "Distractor robot";
                elseif (evt.cause.name == "destroyer") then reason = "Destroyer robot";
                end
                local lastuser = "<unkown user>";
                if (evt.cause.last_user) then
                    lastuser = evt.cause.last_user.name
                end
                reason = reason .. " created by " .. lastuser;
            else
                if (evt.cause.name == "gun-turret") then reason = "Gun Turret";
                elseif (evt.cause.name == "laser-turret") then reason = "Laser Turret";
                elseif (evt.cause.name == "flamethrower-turret") then reason = "Flamethrower Turret";
                elseif (evt.cause.name == "artillery-turret") then reason = "Artillery Turret";
                elseif (evt.cause.name == "artillery-wagon") then reason = "Artillery Wagon";
                end
                local lastuser = nil;
                if (evt.cause.last_user) then
                    lastuser = evt.cause.last_user.name
                end
                if (lastuser) then
                    reason = reason .. " last changed by " .. lastuser;
                else
                    if global.CTF_displayNames and global.CTF_displayNames[evt.cause.name] then
                        reason = global.CTF_displayNames[evt.cause.name];
                    else
                        reason =  evt.cause.name;
                    end
                end
            end
        end
    end

    table.insert(self.deaths, reason);

    local latestDeath = #self.deaths;

    local totalDeaths = 0;
    local forceDeaths = 0;

    for _,forPlayer in ipairs(allPlayers) do
        if (forPlayer.needsUpdate) then
            forPlayer:update(forPlayer.player_index);
        end

        totalDeaths = totalDeaths + #forPlayer.deaths;
        if (self.force == forPlayer.force) then
            forceDeaths = forceDeaths + #forPlayer.deaths;
        end
    end

    for _,forPlayer in ipairs(forPlayers) do
        local deathfile = nil;

        if ((forPlayer.settingEnable) and (forPlayer.settingDeathScreenshotEnable)) then
            deathfile = forPlayer.basePath .. forPlayer.settingDeathScreenshotLocation .. 'death-' .. self.name .. '-' .. latestDeath .. '-' .. game.tick .. '.png';

            game.take_screenshot{
                player=self.name,
                by_player=forPlayer.player_index,
                surface=game.players[self.player_index].surface.index,
                position=game.players[self.player_index].position,
                resolution= {1280 , 720},
                zoom=0.8,
                path=deathfile,
                show_gui=false,
                show_entity_info=true,
                anti_alias=false
            }
        end

        if ((forPlayer.settingEnable) and (forPlayer.settingDeathEnable)) then
            local deathsSameReason = 0;
            for _,v in ipairs(self.deaths) do
                if (v == reason) then
                    deathsSameReason = deathsSameReason + 1
                end
            end

            local player = EngineUtil.MakeSafeForRegexRepl(self.name);
            local force = EngineUtil.MakeSafeForRegexRepl(self.force);
            local rsn = EngineUtil.MakeSafeForRegexRepl(reason);
            local deaths = #self.deaths;

            local file = forPlayer.basePath .. forPlayer.settingLocation;
            local prefix = forPlayer.settingPrefix;
            local sub = forPlayer.settingDeathSub;

            local data = prefix ..
                    sub
                        :gsub("$d", deaths)
                        :gsub("$f", force)
                        :gsub("$o", forceDeaths)
                        :gsub("$p", player)
                        :gsub("$r", rsn)
                        :gsub("$s", deathsSameReason)
                        :gsub("$t", totalDeaths);

            local dataFin
            if (deathfile ~= nil ) then
                dataFin = data .. '[{<>}]' .. deathfile .. "\n";
            else
                dataFin = data .. "\n";
            end

            engine.files:writeFile(file, dataFin, true, forPlayer.player_index);
        end
    end
end

function Player:logJoin(allPlayers, forPlayers, engine)
    local totalDeaths = 0;
    local forceDeaths = 0;

    for _,forPlayer in ipairs(allPlayers) do
        if (forPlayer.needsUpdate) then
            forPlayer:update(forPlayer.player_index);
        end

        totalDeaths = totalDeaths + #forPlayer.deaths;
        if (self.force == forPlayer.force) then
            forceDeaths = forceDeaths + #forPlayer.deaths;
        end
    end

    local player = EngineUtil.MakeSafeForRegexRepl(self.name);
    local force = EngineUtil.MakeSafeForRegexRepl(self.force);
    local deaths = #self.deaths;

    for _,forPlayer in ipairs(forPlayers) do
        if ((forPlayer.settingEnable) or (forPlayer.settingJoinEnable)) then
            local file = forPlayer.basePath .. forPlayer.settingLocation;
            local prefix = forPlayer.settingPrefix;
            local sub = forPlayer.settingJoinSub;

            local data = prefix ..
                sub
                    :gsub("$d", deaths)
                    :gsub("$f", force)
                    :gsub("$o", forceDeaths)
                    :gsub("$p", player)
                    :gsub("$t", totalDeaths) ..
                "\n";

            engine.files:writeFile(file, data, true, forPlayer.player_index);
        end
    end
end

function Player:logLeave(allPlayers, forPlayers, engine)
    local totalDeaths = 0;
    local forceDeaths = 0;

    for _,forPlayer in ipairs(allPlayers) do
        if (forPlayer.needsUpdate) then
            forPlayer:update(forPlayer.player_index);
        end

        totalDeaths = totalDeaths + #forPlayer.deaths;
        if (self.force == forPlayer.force) then
            forceDeaths = forceDeaths + #forPlayer.deaths;
        end
    end

    local player = EngineUtil.MakeSafeForRegexRepl(self.name);
    local force = EngineUtil.MakeSafeForRegexRepl(self.force);
    local deaths = #self.deaths;

    for _,forPlayer in ipairs(forPlayers) do
        if ((forPlayer.settingEnable) and (forPlayer.settingLeaveEnable)) then
            local file = forPlayer.basePath .. forPlayer.settingLocation;
            local prefix = forPlayer.settingPrefix;
            local sub = forPlayer.settingLeaveSub;

            local data = prefix ..
                    sub
                    :gsub("$d", deaths)
                    :gsub("$f", force)
                    :gsub("$o", forceDeaths)
                    :gsub("$p", player)
                    :gsub("$t", totalDeaths) ..
                    "\n";

            engine.files:writeFile(file, data, true, forPlayer.player_index);
        end
    end
end

function Player:clear(done, engine)
    engine.files:writeFile(self.basePath .. self.settingLocation, "", false, self.player_index, done)
end

function Player:saveSettingsFile(engine)
    local function gBS(bool)
        if (bool) then
            return "true";
        else
            return "false";
        end
    end

    engine.files:writeFile(self.basePath .. self.settingSettingsLocation,
        "{ \"delay\": "..self.settingDelay..
            ", \"location\": \"" .. self.settingLocation..
            "\", \"settingsLocation\": \""..self.settingSettingsLocation..
            "\", \"staticsLocation\": \""..self.settingStaticsLocation..
            "\", \"deathScreenshotLocation\": \""..self.settingDeathScreenshotLocation..
            "\", \"enable\": "..gBS(self.settingEnable)..
            ", \"chatEnable\": "..gBS(self.settingChatEnable)..
            ", \"deathEnable\": "..gBS(self.settingDeathEnable)..
            ", \"deathScreenshotEnable\": "..gBS(self.settingDeathScreenshotEnable)..
            ", \"joinEnable\": "..gBS(self.settingJoinEnable)..
            ", \"leaveEnable\": "..gBS(self.settingLeaveEnable)..
            ", \"remoteEnable\": "..gBS(self.settingRemoteEnable)..
            ", \"prefix\": \""..self.settingPrefix..
            "\", \"chatSub\": \""..self.settingChatSub..
            "\", \"deathSub\": \""..self.settingDeathSub..
            "\", \"joinSub\": \""..self.settingJoinSub..
            "\", \"leaveSub\": \""..self.settingLeaveSub..
            "\", \"save\": \"".. game.surfaces["nauvis"].map_gen_settings.seed..
        "\" }", false, self.player_index);
end

return Player
