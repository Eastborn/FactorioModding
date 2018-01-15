"use strict";
/**
 * Created by Eastborn-PC on 21-07-17.
 */
Object.defineProperty(exports, "__esModule", { value: true });
/// <reference path="../../../../typings/globals/node/index.d.ts" />
var tmi = require("tmi.js");
var discord = require("discord.js");
var imgur = require("imgur-node-api");
var fs = require("fs");
var yargs = require("yargs");
var args = yargs.options({
    'u': {
        'alias': 'TwitchUser',
        'desc': 'The username on twitch --ex: eastborn [Requires "TwitchOauth" and "TwitchChannel" to be set]',
        'demandOption': false,
        'implies': 'o',
        type: 'string'
    },
    'o': {
        'alias': 'TwitchOauth',
        'desc': 'The oauth token paired with this twitch account --see: https://twitchapps.com/tmi/ --ex: oauth:f5gxgjew4w0ie6mvdnjvabphruc7cg [Requires "TwitchUser" and "TwitchChannel" to be set]',
        'demandOption': false,
        'implies': 'c',
        type: 'string'
    },
    'c': {
        'alias': 'TwitchChannel',
        'desc': 'The twitch chat channel to connect to --usually your username without a # in front --ex: eastborn [Requires "TwitchUser" and "TwitchOauth" to be set]',
        'demandOption': false,
        'implies': 'u',
        type: 'string'
    },
    'i': {
        'alias': 'DicordWebhookId',
        'desc': 'The id from the discord webhook --see https://discordapp.com/developers/docs/resources/webhook --found by creating a web hook and going to the webhook url --ex: 318862783998744607 [Requires "DiscordToken" to be set]',
        'demandOption': false,
        'implies': 't',
        type: 'string'
    },
    't': {
        'alias': 'DiscordToken',
        'desc': 'The token from the discord webhook --see https://discordapp.com/developers/docs/resources/webhook --found by creating a web hook and going to the webhook url --ex: RjKOcriCIq2Aslq-T_zTy19ODE6qEKzmxdlN6OYTrv35TWZ7GQHwfJhvxN95KS7rgvQW [Requires "DicordWebhookId" to be set]',
        'demandOption': false,
        'implies': 'i',
        type: 'string'
    },
    'f': {
        'alias': 'File',
        'desc': 'The settings file that should be monitored for data',
        'demandOption': true,
        'normalize': true,
        'coerce': function (arg) {
            try {
                fs.accessSync(arg, fs.constants.R_OK);
            }
            catch (e) {
                throw new Error("The file [" + arg + "] was not readable or may not exist at all please run a map for more than 2 seconds after [tab] info has disappeared or create the file manually");
            }
            return arg;
        },
        type: 'string'
    }
})
    .help('help')
    .argv;
function debug(level, message) {
    var a = [];
    for (var _i = 2; _i < arguments.length; _i++) {
        a[_i - 2] = arguments[_i];
    }
    var args = [];
    for (var i = 0; i < arguments.length; i++) {
        args.push(arguments[i]);
    }
    args.shift();
    args.shift();
    var d = new Date();
    console.log("[" + ("0" + d.getHours()).slice(-2) + ":" + ("0" + d.getMinutes()).slice(-2) + "]", level + ":", message, args.length > 0 ? args : "");
}
imgur.setClientID('60672811b6e4c02');
var file = args.f;
var twitchUser = typeof (args.u) === "string" ? args.u.toLowerCase() : args.u;
var twitchOauthPass = args.o;
var twitchChannel = "#" + (typeof (args.c) === "string" ? args.c.toLowerCase() : args.c);
var discordId = args.i;
var discordToken = args.t;
var settings = JSON.parse(fs.readFileSync(file).toString());
var settingsDelay = settings.delay;
var settingsFile = settings.location;
var settingsSettingsFile = settings.settingsLocation;
var settingsStaticsFile = settings.staticsLocation;
var settingsEnable = settings.enable;
var settingsChatEnable = settings.chatEnable;
var settingsDeathEnable = settings.deathEnable;
var settingsJoinEnable = settings.joinEnable;
var settingsLeaveEnable = settings.leaveEnable;
var settingsRemoteEnable = settings.remoteEnable;
var settingsPrefix = settings.prefix;
var settingsChatSub = settings.chatSub;
var settingsDeathSub = settings.deathSub;
var settingsJoinSub = settings.joinSub;
var settingsLeaveSub = settings.leaveSub;
var settingsSave = settings.save;
var settingsScreensLoc = settings.deathScreenshotLocation;
function updateSettings(file) {
    settings = JSON.parse(fs.readFileSync(file).toString());
    settingsDelay = settings.delay;
    settingsSettingsFile = settings.settingsLocation;
    settingsEnable = settings.enable;
    settingsChatEnable = settings.chatEnable;
    settingsDeathEnable = settings.deathEnable;
    settingsJoinEnable = settings.joinEnable;
    settingsLeaveEnable = settings.leaveEnable;
    settingsRemoteEnable = settings.remoteEnable;
    settingsPrefix = settings.prefix;
    settingsChatSub = settings.chatSub;
    settingsDeathSub = settings.deathSub;
    settingsJoinSub = settings.joinSub;
    settingsLeaveSub = settings.leaveSub;
    settingsSave = settings.save;
    settingsScreensLoc = settings.deathScreenshotLocation;
    if (settings.staticsLocation != settingsStaticsFile) {
        changeStaticsFile(settingsStaticsFile, settings.staticsLocation);
        settingsStaticsFile = settings.staticsLocation;
    }
    if (settings.location != settingsFile) {
        changeChatFile(settingsFile, settings.location);
        settingsFile = settings.location;
    }
}
var tmiClient;
var tmiConnected = false;
var tmiIsMod = false;
var discordHook;
var runonce = false;
if (twitchUser) {
    tmiClient = new tmi.client({
        options: {
            debug: true
        },
        connection: {
            reconnect: true
        },
        identity: {
            username: twitchUser,
            password: twitchOauthPass
        },
        channels: [twitchChannel]
    });
    tmiClient.connect().then(function (data) {
        tmiClient.on('message', function (channel, userstate, message, self) {
            if (self) {
                return;
            }
            switch (userstate["message-type"]) {
                case "chat":
                    onChat(message, false, userstate.username);
                    break;
                case "whisper":
                    onChat(message, true, userstate.username);
                    break;
                default:
                    break;
            }
        });
        tmiClient.on('join', function (channel, user, isSelf) {
            if (isSelf) {
                debug("info", "[twitch:" + twitchUser + "," + twitchChannel + "] Twitch client is ready");
                tmiConnected = true;
                if (runonce == false) {
                    tmiClient.mods(twitchChannel).then(function (data) {
                        debug("info", "[twitch:mods," + twitchChannel + "] " + data.join(", "));
                        data.forEach(function (m) {
                            if (m == twitchUser) {
                                tmiIsMod = true;
                            }
                        });
                        if (twitchUser && twitchChannel && twitchUser.toLowerCase() == twitchChannel.toLowerCase()) {
                            tmiIsMod = true;
                        }
                        if (tmiIsMod) {
                            debug("info", "[twitch:" + twitchUser + "," + twitchChannel + "] Twitch client is a mod");
                            setInterval(messageDelay, 0);
                        }
                        else {
                            debug("warn", "[twitch:" + twitchUser + "," + twitchChannel + "] Twitch client is not a mod");
                            setInterval(messageDelay, 1000);
                        }
                        runonce = true;
                    });
                }
            }
        });
    });
}
else {
    debug("warn", "[twitch] Twitch client is not initialized");
}
if (discordId) {
    discordHook = new discord.WebhookClient(discordId, discordToken);
    debug("info", "[discord:" + discordId + "] Discord client is ready");
}
else {
    debug("warn", "[discord] Discord client is not initialized");
}
var queue = [];
var sending = false;
function messageDelay() {
    if (queue.length > 0 && !sending) {
        sending = true;
        var message = queue.shift();
        if (tmiConnected) {
            debug("info", "[twitch:" + twitchUser + "," + twitchChannel + "] Sending message", message);
            tmiClient.say(twitchChannel, message).then(function () { sending = false; });
        }
        if (discordHook) {
            debug("info", "[discord:" + discordId + "] Sending message", message);
            return discordHook.send(message);
        }
    }
}
function sendChat(message) {
    setTimeout(function () {
        queue.push(message);
    }, settingsDelay);
}
function onChat(message, whisper, user) {
    /*
    -!CTFCmd
    -!Deaths <player>
    -!Messages <player>
    -!Online
    -!Players
     */
    if (user && twitchUser && user.toLowerCase() == twitchUser.toLowerCase()) {
        return;
    }
    if (message) {
        var m = "";
        message = message.toLowerCase();
        if (message.indexOf('!ctfcmd') > -1) {
            m = "!CTFCmd " +
                "!Online " +
                "!Players " +
                "!Deaths <PlayerName> " +
                "!Messages <PlayerName> ";
        }
        else if (message.indexOf('!online') > -1) {
            m = "There are " + online.length + " players online: " + online.join(", ");
        }
        else if (message.indexOf('!players') > -1) {
            m = players.length + " players have been on this map: " + players.join(", ");
        }
        else if (message.indexOf('!deaths') > -1) {
            var split = message.split(" ");
            var next_1 = false;
            var val_1 = null;
            split.forEach(function (v) {
                if (v.length > 0) {
                    if (next_1 == true) {
                        val_1 = v;
                        next_1 = false;
                    }
                    else if (v == "!deaths") {
                        next_1 = true;
                    }
                }
            });
            if (val_1 == null) {
                var amount = 0;
                for (var k in playerDeaths) {
                    if (playerDeaths.hasOwnProperty(k)) {
                        amount += playerDeaths[k];
                    }
                }
                m = "There have been " + amount + " deaths in this map";
            }
            else {
                if (playerDeaths.hasOwnProperty(val_1)) {
                    m = val_1 + " has died " + playerDeaths[val_1] + " times";
                }
                else {
                    m = "The player " + val_1 + " has not been on this map yet";
                }
            }
        }
        else if (message.indexOf('!messages') > -1) {
            var split = message.split(" ");
            var next_2 = false;
            var val_2 = null;
            split.forEach(function (v) {
                if (v.length > 0) {
                    if (next_2 == true) {
                        val_2 = v;
                        next_2 = false;
                    }
                    else if (v == "!messages") {
                        next_2 = true;
                    }
                }
            });
            if (val_2 == null) {
                var amount = 0;
                for (var k in playerMessages) {
                    if (playerMessages.hasOwnProperty(k)) {
                        amount += playerMessages[k];
                    }
                }
                m = "There have been " + amount + " messages sent in this map";
            }
            else {
                if (playerMessages.hasOwnProperty(val_2)) {
                    m = val_2 + " has sent " + playerMessages[val_2] + " messages";
                }
                else {
                    m = "The player " + val_2 + " has not been on this map yet";
                }
            }
        }
        if (whisper) {
            if (tmiConnected) {
                tmiClient.whisper(user, m);
            }
        }
        else {
            queue.push(m);
        }
    }
}
var tmpFileData = "";
var tmpFileBeingRead = false;
function changeChatFile(oldFile, newFile) {
    if (oldFile) {
        fs.unwatchFile(oldFile);
        tmpFileBeingRead = false;
    }
    fs.watchFile(newFile, { persistent: true, interval: 500 }, function (curr, prev) {
        if (!tmpFileBeingRead) {
            tmpFileBeingRead = true;
            fs.readFile(settingsFile, function (err, data) {
                if (err) {
                    debug("error", "[" + settingsFile + "] File couldn't be read");
                    return;
                }
                data = (data + "").replace(tmpFileData, "").trim();
                debug("info", "[file:" + settingsFile + "] File was read:", data);
                if (data.length > 0) {
                    var chatData = data.split('\n');
                    var cont_1 = function (l) {
                        var trimmed = l.trim();
                        if (trimmed.length > 0) {
                            sendChat(trimmed);
                        }
                    };
                    chatData.forEach(function (l) {
                        if (l.indexOf('[{<>}]') > -1) {
                            var picLoc = l.substring(l.indexOf('[{<>}]') + 6);
                            l = l.substring(0, l.indexOf('[{<>}]'));
                            var actualLoc_1 = picLoc.substring(picLoc.indexOf(settingsScreensLoc));
                            setTimeout(function () {
                                imgur.upload(actualLoc_1, function (err, res) {
                                    if (err) {
                                        return cont_1(l);
                                    }
                                    var defLink = res.data.link;
                                    imgur.update({
                                        id: res.data.id,
                                        title: "[Factorio] [ChatToFile] " + l,
                                        description: l
                                    }, function (err, res) {
                                        if (err) {
                                            return cont_1(l);
                                        }
                                        //TODO This shit doesnt let me log in to delete stuff but w/e
                                        debug('info', 'Uploaded Death screenshot(' + actualLoc_1 + ') to imgur(' + defLink + ')');
                                        cont_1(l + ' ' + defLink);
                                    });
                                });
                            }, 500);
                        }
                        else {
                            cont_1(l);
                        }
                    });
                    fs.writeFile(settingsFile, '', function () {
                        tmpFileData = "";
                        tmpFileBeingRead = false;
                    });
                    tmpFileData = data;
                }
                else {
                    tmpFileBeingRead = false;
                }
            });
        }
    });
    debug("info", "[file:" + newFile + "] Watching of chat file initiated");
}
var deaths = null;
var messages = null;
var playerDeaths = null;
var playerMessages = null;
var online = null;
var players = null;
function changeStaticsFile(oldFile, newFile, force) {
    if (force === void 0) { force = false; }
    if (oldFile) {
        fs.unwatchFile(oldFile);
    }
    function setStatics(file) {
        fs.readFile(file, function (err, data) {
            var d = JSON.parse(data.toString());
            deaths = d.deaths;
            messages = d.messages;
            playerDeaths = d.playerDeaths;
            playerMessages = d.playerMessages;
            online = d.online;
            players = d.players;
        });
    }
    fs.watchFile(newFile, { persistent: true, interval: 500 }, function (curr, prev) {
        setStatics(newFile);
    });
    if (force) {
        setStatics(newFile);
    }
    debug("info", "[file:" + newFile + "] Watching of statics file initiated");
}
fs.watchFile(file, { persistent: true, interval: 500 }, function (curr, prev) {
    updateSettings(file);
});
debug("info", "[file:" + file + "] Watching of settings file initiated");
changeChatFile(null, settingsFile);
changeStaticsFile(null, settingsStaticsFile, true);
