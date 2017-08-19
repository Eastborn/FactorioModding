--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 13-07-17
-- Time: 13:35
--

data:extend({
    {
        name = "tctf-enabled",
        type = "bool-setting",
        setting_type = "runtime-per-user",
        order = "01",
        default_value = true
    },
    {
        name = "tctf-location",
        type = "string-setting",
        setting_type = "runtime-per-user",
        order = "02",
        default_value = "train-amount.txt",
        allow_blank = false
    },
    {
        name = "tctf-sub",
        type = "string-setting",
        setting_type = "runtime-per-user",
        order = "03",
        default_value = "$t",
        allow_blank = false
    }
})