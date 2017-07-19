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

    obj.engine = engine;
    obj.basePath = basePath;

    obj:update(player_index);

    obj.deaths = {};
    obj.needsUpdate = false;

    return obj;
end

function Player:update(player_index)
    local p = game.players[player_index];
    self.player_index = player_index;
    self.name = p.name or "<unknown_player>";
    self.force = p.force.name or "<unknown_force>";

    self.settingEnable = self.engine.settings:getRuntimePlayerSetting(p, "ctf-enable");
    self.settingChatEnable = self.engine.settings:getRuntimePlayerSetting(p, "ctf-chatenable");
    self.settingDeathEnable = self.engine.settings:getRuntimePlayerSetting(p, "ctf-deathenable");
    self.settingRemoteEnable = self.engine.settings:getRuntimePlayerSetting(p, "ctf-remoteenable");
    self.settingLocation = self.engine.settings:getRuntimePlayerSetting(p, "ctf-location");
    self.settingSettingsLocation = self.engine.settings:getRuntimePlayerSetting(p, "ctf-settingslocation");
    self.settingDelay = self.engine.settings:getRuntimePlayerSetting(p, "ctf-delay");
    self.settingPrefix = self.engine.settings:getRuntimePlayerSetting(p, "ctf-prefix");
    self.settingChatSub = self.engine.settings:getRuntimePlayerSetting(p, "ctf-chatsub");
    self.settingDeathSub = self.engine.settings:getRuntimePlayerSetting(p, "ctf-deathsub");


    self.needsUpdate = false;
end

function Player:logChat(message, forPlayers)
    if (self.needsUpdate) then
        self:update(self.player_index);
    end

    local player = EngineUtil.MakeSafeForRegexRepl(self.name);
    local force = EngineUtil.MakeSafeForRegexRepl(self.force);
    local msg = EngineUtil.MakeSafeForRegexRepl(message);

    for _,forPlayer in ipairs(forPlayers) do
        if (forPlayer.needsUpdate) then
            forPlayer:update(forPlayer.player_index);
        end

        if ((not forPlayer.settingEnable) or (not forPlayer.settingChatEnable)) then
            return nil;
        end

        local file = forPlayer.basePath .. forPlayer.settingLocation;
        local prefix = forPlayer.settingPrefix;
        local sub = forPlayer.settingChatSub;

        local data = prefix ..
                sub
                    :gsub("$f", force)
                    :gsub("$m", msg)
                    :gsub("$p", player) ..
                "\n";

        self.engine.files:writeFile(file, data, true, forPlayer.player_index);
    end
end

function Player:logDeath(evt, allPlayers, forPlayers)
    --game.print(EngineUtil.TableToString(evt.cause) .." cause"); -- no cause == landmine/poison capsule
    --game.print(EngineUtil.TableToString(evt.cause.name) .." name");
    -- tank=tank locomotive=locomotive car=car cargo-wagon=cargo-wagon fluid-wagon=fluid-wagon player=player medium-worm-turret=medium-worm-turret
    -- small-worm-turret=small-worm-turret big-worm-turret=big-worm-turret small-biter=small-biter medium-biter=medium-biter big-biter=big-biter
    -- behemoth-biter=behemoth-biter small-spitter=small-spitter medium-spitter=medium-spitter big-spitter=big-spitter behemoth-spitter=behemoth-spitter
    -- defender-defender-capsule distractor=distractor-capsule destroyer=destroyer-capsule gun-turret=gun-turret laser-turret=laser-turret flamethrower-turret=flamethrower-turret
    --game.print(EngineUtil.TableToString(evt.cause.type).." type");
    -- locomotive/cargo-wagon/fluid-wagon==train  unit==biter  car==tank/car  player==player(any weapon) turret=worm combat-robot=defender/distractor
    -- ammo-turret=gunturret electric-turret=laserturret fluid-turret=flamer-turret
    --game.print(EngineUtil.TableToString(evt.cause.passenger.name).." passenger"); -- evt.cause.passenger = nil if no passenger
    --game.print(EngineUtil.TableToString(evt.cause.last_user.name).." lastuser"); -- evt.cause.last_user = nil if no lastuser (train/tank/car/combat-robot/ammo-turret/electric-turret) has last user
    --TODO test laser defence + discharge defence
    local reason = "test"

    table.insert(self.deaths, reason);

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
        if ((not forPlayer.settingEnable) or (not forPlayer.settingDeathEnable)) then
            return nil;
        end

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
                    :gsub("$t", totalDeaths) ..
                "\n";

        self.engine.files:writeFile(file, data, true, forPlayer.player_index);
    end
end

function Player:clear(done)
    self.engine.files:writeFile(self.basePath .. self.settingLocation, "", false, self.player_index, done)
end

function Player:removeFile(done)
    self.engine.files:removeFile(self.basePath .. self.settingLocation, done)
end

function Player:saveSettingsFile(done)
    self.engine.files:writeFile(self.basePath .. self.settingSettingsLocation, "{ delay: "..self.settingDelay.." }", false, self.player_index, done);
end

function Player:removeSettingsFile(done)
    self.engine.files:removeFile(self.basePath .. self.settingSettingsLocation, done);
end

return Player
