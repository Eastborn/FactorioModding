--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 13-07-17
-- Time: 13:35
--

data:extend({
    {
        name = "ctf-enable",
        type = "bool-setting",
        setting_type = "runtime-per-user",
        order = "02",
        default_value = false
    },
    {
        name = "ctf-chatenable",
        type = "bool-setting",
        setting_type = "runtime-per-user",
        order = "03",
        default_value = false
    },
    {
        name = "ctf-deathenable",
        type = "bool-setting",
        setting_type = "runtime-per-user",
        order = "04",
        default_value = false
    },
    {
        name = "ctf-deathscreenshotenable",
        type = "bool-setting",
        setting_type = "runtime-per-user",
        order = "05",
        default_value = false
    },
    {
        name = "ctf-joinenable",
        type = "bool-setting",
        setting_type = "runtime-per-user",
        order = "06",
        default_value = false
    },
    {
        name = "ctf-leaveenable",
        type = "bool-setting",
        setting_type = "runtime-per-user",
        order = "07",
        default_value = false
    },
    {
        name = "ctf-remoteenable",
        type = "bool-setting",
        setting_type = "runtime-per-user",
        order = "08",
        default_value = false
    },
    {
        name = "ctf-location",
        type = "string-setting",
        setting_type = "runtime-per-user",
        order = "09",
        default_value = "chat-data.txt",
        allow_blank = false
    },
    {
        name = "ctf-settingslocation",
        type = "string-setting",
        setting_type = "runtime-per-user",
        order = "10",
        default_value = "chat-data-setting.json",
        allow_blank = false
    },
    {
        name = "ctf-staticslocation",
        type = "string-setting",
        setting_type = "runtime-per-user",
        order = "11",
        default_value = "chat-data-static.json",
        allow_blank = false
    },
    {
        name = "ctf-deathscreenlocation",
        type = "string-setting",
        setting_type = "runtime-per-user",
        order = "12",
        default_value = "deathscreens/",
        allow_blank = false
    },
    {
        name = "ctf-delay",
        type = "int-setting",
        setting_type = "runtime-per-user",
        order = "13",
        default_value = 1000*10,
        minimum_value = 0,
        maximum_value = 1000*60*60
    },
    {
        name = "ctf-prefix",
        type = "string-setting",
        setting_type = "runtime-per-user",
        order = "14",
        default_value = "<Factorio> ",
        allow_blank = true
    },
    {
        name = "ctf-chatsub",
        type = "string-setting",
        setting_type = "runtime-per-user",
        order = "15",
        default_value = "$f-$p: $m",
        allow_blank = false
    },
    {
        name = "ctf-deathsub",
        type = "string-setting",
        setting_type = "runtime-per-user",
        order = "16",
        default_value = "$f($o deaths)-$p has died by $r, he/she died $d times so far where $s by $r. Total death count $t.",
        allow_blank = false
    },
    {
        name = "ctf-joinsub",
        type = "string-setting",
        setting_type = "runtime-per-user",
        order = "17",
        default_value = "$f($o deaths)-$p has joined the server. He/She died $d times so far.",
        allow_blank = false
    },
    {
        name = "ctf-leavesub",
        type = "string-setting",
        setting_type = "runtime-per-user",
        order = "18",
        default_value = "$f($o deaths)-$p has left the server. He/She died $d times so far.",
        allow_blank = false
    }
})