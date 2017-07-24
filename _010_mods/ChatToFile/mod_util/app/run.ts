/**
 * Created by Eastborn-PC on 21-07-17.
 */

/// <reference path="../../../../typings/globals/node/index.d.ts" />

import * as tmi from "tmi.js";
import * as discord from "discord.js";

import * as fs from "fs";
import * as request from "request";

import * as yargs from "yargs";

let args = (<any>yargs).options(
    {
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
            'coerce': (arg) => {
                try {
                    fs.accessSync(arg, fs.constants.R_OK)
                } catch(e) {
                    throw new Error("The file ["+arg+"] was not readable or may not exist at all please run a map for more than 2 seconds after [tab] info has disappeared or create the file manually")
                }
                return arg;
            },
            type: 'string'
        }
    })
    .help('help')
    .argv;

function debug(level, message, ...a) {
    let args = [];
    for (let i=0;i<arguments.length;i++) {
        args.push(arguments[i]);
    }
    args.shift();
    args.shift();
    let d = new Date();
    console.log("["+("0" + d.getHours()).slice(-2) + ":" + ("0" + d.getMinutes()).slice(-2)+"]", level+":", message, args.length>0?args:"");
}

let file = args.f;
let twitchUser = typeof(args.u) === "string" ? args.u.toLowerCase() : args.u;
let twitchOauthPass = args.o;
let twitchChannel = "#" + (typeof(args.c) === "string" ? args.c.toLowerCase() : args.c);
let discordId = args.i;
let discordToken = args.t;

let settings = JSON.parse(fs.readFileSync(file).toString());
let settingsDelay = settings.delay;
let settingsFile = settings.location;
let settingsSettingsFile = settings.settingsLocation;
let settingsStaticsFile = settings.staticsLocation;
let settingsEnable = settings.enable;
let settingsChatEnable = settings.chatEnable;
let settingsDeathEnable = settings.deathEnable;
let settingsJoinEnable = settings.joinEnable;
let settingsLeaveEnable = settings.leaveEnable;
let settingsRemoteEnable = settings.remoteEnable;
let settingsPrefix = settings.prefix;
let settingsChatSub = settings.chatSub;
let settingsDeathSub = settings.deathSub;
let settingsJoinSub = settings.joinSub;
let settingsLeaveSub = settings.leaveSub;
let settingsSave = settings.save;

function updateSettings(file: string) {
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

    if (settings.staticsLocation != settingsStaticsFile) {
        changeStaticsFile(settingsStaticsFile, settings.staticsLocation);
        settingsStaticsFile = settings.staticsLocation;
    }



    if (settings.location != settingsFile) {
        changeChatFile(settingsFile, settings.location);
        settingsFile = settings.location;
    }
}

let tmiClient;
let tmiConnected = false;
let tmiIsMod = false;
let discordHook;
let runonce = false;

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

    tmiClient.connect().then(data => {
        tmiClient.on('message', (channel, userstate, message, self) => {
            if (self) {
                return;
            }

            switch(userstate["message-type"]) {
                case "chat":
                    onChat(message);
                    break;
                case "whisper":
                    onChat(message, true, userstate.username);
                    break;
                default:
                    break;
            }

        });

        tmiClient.on('join', (channel, user, isSelf) => {
            if (isSelf) {
                debug("info", "[twitch:" + twitchUser + "," + twitchChannel + "] Twitch client is ready");
                tmiConnected = true;

                if (runonce == false) {
                    tmiClient.mods(twitchChannel).then((data: string[]) => {
                        data.forEach(m => {
                            if (m == twitchUser) {
                                tmiIsMod = true;
                            }
                        });
                        if (twitchUser.toLowerCase() == args.c.toLowerCase()) {
                            tmiIsMod = true;
                        }


                        if (tmiIsMod) {
                            debug("info", "[twitch:" + twitchUser + "," + twitchChannel + "] Twitch client is a mod");
                            setInterval(messageDelay, 0);
                        } else {
                            debug("warn", "[twitch:" + twitchUser + "," + twitchChannel + "] Twitch client is not a mod");
                            setInterval(messageDelay, 1000);
                        }
                        runonce = true;



                    });
                }
            }
        });
    });
} else {
    debug("warn", "[twitch] Twitch client is not initialized");
}

if (discordId) {
    discordHook = new discord.WebhookClient(discordId, discordToken);
    debug("info", "[discord:"+discordId+"] Discord client is ready")
} else {
    debug("warn", "[discord] Discord client is not initialized");
}

let queue = [];
let sending = false;

function messageDelay() {
    if (queue.length > 0 && !sending) {
        sending = true;
        let message = queue.shift();
        if (tmiConnected) {
            debug("info", "[twitch:"+twitchUser+","+twitchChannel+"] Sending message", message);
            tmiClient.say(twitchChannel, message).then(()=>{sending = false;});
        }
        if (discordHook) {
            debug("info", "[discord:"+discordId+"] Sending message", message);
            return discordHook.send(message);
        }
    }
}

function sendChat(message) {
    setTimeout(() => {
        queue.push(message);
    }, settingsDelay);
}

function onChat(message: string, whisper?: boolean, user?: string) {
    /*
    -!CTFCmd
    -!Deaths <player>
    -!Messages <player>
    -!Online
    -!Players
     */
    let m = "";
    message = message.toLowerCase();
    if (message.indexOf('!ctfcmd') > -1) {
        m = "!CTFCmd displays this help command " +
            "!Online shows the online players_____________________ " +
            "!Players shows the players that have been on the map____ " +
            "!Deaths <PlayerName> Shows the total deaths or the deaths of the specified player_______________________ " +
            "!Messages <PlayerName> Shows the total amount of messages, or the amount of messages of the specified player "
    } else if (message.indexOf('!online') > -1) {
        m = "There are " + online.length + " players online: " + online.join(", ");
    } else if (message.indexOf('!players') > -1) {
        m = players.length + " players have been on this map: " + players.join(", ");
    } else if (message.indexOf('!deaths') > -1) {
        let split = message.split(" ");
        let next = false;
        let val = null;
        split.forEach(v=> {
            if (v.length > 0) {
                if (next == true) {
                    val = v;
                    next = false;
                } else if (v == "!deaths") {
                    next = true;
                }
            }
        });

        if (val == null) {
            let amount = 0;
            for (let k in playerDeaths) {
                if (playerDeaths.hasOwnProperty(k)) {
                    amount += playerDeaths[k];
                }
            }

            m = "There have been " + amount + " deaths in this map";
        } else {
            if (playerDeaths.hasOwnProperty(val)) {
                m = val + " has sent " + playerDeaths[val] + " messages";
            } else {
                m = "The player " + val + " has not been on this map yet";
            }
        }
    } else if (message.indexOf('!messages') > -1) {
        let split = message.split(" ");
        let next = false;
        let val = null;
        split.forEach(v=> {
            if (v.length > 0) {
                if (next == true) {
                    val = v;
                    next = false;
                } else if (v == "!messages") {
                    next = true;
                }
            }
        });

        if (val == null) {
            let amount = 0;
            for (let k in playerMessages) {
                if (playerMessages.hasOwnProperty(k)) {
                    amount += playerMessages[k];
                }
            }

            m = "There have been " + amount + " messages sent in this map";
        } else {
            if (playerMessages.hasOwnProperty(val)) {
                m = val + " has sent " + playerMessages[val] + " messages";
            } else {
                m = "The player " + val + " has not been on this map yet";
            }
        }
    }

    if (whisper) {
        if (tmiConnected) {
            tmiClient.whisper(user, m);
        }
    } else {
        queue.push(m);
    }
}

let tmpFileData = "";
let tmpFileBeingRead = false;

function changeChatFile(oldFile, newFile) {
    if (oldFile) {
        fs.unwatchFile(oldFile);
        tmpFileBeingRead = false;
    }

    fs.watchFile(newFile, {persistent: true, interval: 500}, (curr, prev) => {
        if (!tmpFileBeingRead) {
            tmpFileBeingRead = true;

            fs.readFile(settingsFile, (err, data: Buffer | string) => {
                if (err) {
                    debug("error", "[" + settingsFile + "] File couldn't be read");
                    return;
                }

                data = (data + "").replace(tmpFileData, "").trim();
                debug("info", "[file:" + settingsFile + "] File was read:", data);

                if (data.length > 0) {
                    let chatData = data.split('\n');

                    chatData.forEach(function (l) {
                        let trimmed = l.trim();
                        if (trimmed.length > 0) {
                            sendChat(trimmed);
                        }
                    });
                    fs.writeFile(settingsFile, '', function () {
                        tmpFileData = "";
                        tmpFileBeingRead = false;
                    });

                    tmpFileData = data;
                } else {
                    tmpFileBeingRead = false;
                }
            });
        }
    });

    debug("info", "[file:"+newFile+"] Watching of chat file initiated");
}

let deaths: number = null;
let messages: number = null;
let playerDeaths: any = null;
let playerMessages: any = null;
let online: string[] = null;
let players: string[] = null;

function changeStaticsFile(oldFile, newFile, force = false) {
    if (oldFile) {
        fs.unwatchFile(oldFile);
    }

    function setStatics(file) {
        fs.readFile(file, (err, data) => {
            let d = JSON.parse(data.toString());

            deaths = d.deaths;
            messages = d.messages;
            playerDeaths = d.playerDeaths;
            playerMessages = d.playerMessages;
            online = d.online;
            players = d.players;
        })
    }

    fs.watchFile(newFile, {persistent: true, interval: 500}, (curr, prev) => {
        setStatics(newFile);
    });

    if (force) {
        setStatics(newFile);
    }

    debug("info", "[file:"+newFile+"] Watching of statics file initiated");
}

fs.watchFile(file, {persistent: true, interval: 500}, (curr, prev) => {
    updateSettings(file);
});
debug("info", "[file:"+file+"] Watching of settings file initiated");

changeChatFile(null, settingsFile);
changeStaticsFile(null, settingsStaticsFile, true);