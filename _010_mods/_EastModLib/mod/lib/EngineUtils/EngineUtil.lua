--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 13-06-17
-- Time: 09:56
--
local EngineUtil = {};

local AsciiType = require('lib.EngineUtils.AsciiType');
local AsciiTypeRange = require('lib.EngineUtils.AsciiTypeRange');

local debug = true;

--- Checks a character or string against the asciitype if they match or not match it.
-- @param charOrString string The string to check.
-- @param asciiType AsciiType The type to check the string for.
-- @param invert bool If we should invert the check.
-- @return bool If the string matched the criteria.
function EngineUtil.checkCharOrString(charOrString, asciiType, invert)
    local c = charOrString;
    local inv = invert or false;
    if (type(c) == "number") then
        c = string.char(c);
    end

    if (#c > 0) then
         local function checkRangeToStr(check, char)
            if (#c == 1) then
                return check(char:byte());
            else
                local ret = true;
                for i=1,#c do
                    if (inv == check(c:byte(i))) then
                        ret = false;
                    end
                end
                return ret;
            end
        end

        for _, v in ipairs(AsciiTypeRange) do
            if ((type(asciiType) == "number" and asciiType == v.Id)
                    or (type(asciiType) == "string" and asciiType:lower() == v.Name:lower())) then
                return checkRangeToStr(v.Check, c);
            end
        end
    else
        return true;
    end
end

--- Checks the string if it is safe for the first parameter of the string:gsub function (regex).
-- @param charOrString string The string to check.
-- @return bool If the string is regex safe.
function EngineUtil.IsSafeForRegex(charOrString)
    return EngineUtil.checkCharOrString(charOrString, AsciiType.Regex, true);
end

--- Will make the given string safe for the first parameter of the string:gsub function (regex).
-- @param charOrString string The string to clean up.
-- @return string The clean string.
function EngineUtil.MakeSafeForRegexTest(charOrString)
    local str = {""};
    for i=1,#charOrString do
        local curChar = charOrString:sub(i,i);
        if (EngineUtil.IsSafeForRegex(curChar)) then
           table.insert(str, "%"..curChar);
        else
            table.insert(str, curChar);
        end
    end
    return table.concat(str, "");
end

--- Will make the given string safe for the second parameter of the string:gsub function.
-- @param charOrString string The string to clean up.
-- @return string The clean string.
function EngineUtil.MakeSafeForRegexRepl(charOrString)
    return charOrString:gsub("%%", "%%%%");
end

--- Generates a random string based on the length, the AsciiType and random seed addition.
-- @param length string The length of the generated string.
-- @param asciiType AsciiType The type of characters that are allowed.
-- @param rndSeed The addition to the random seed.
-- @return string The generated string.
function EngineUtil.GenerateRandomString(length, asciiType, rndSeed)
    rndSeed = rndSeed or 0;
    if (length < 1) then
        return nil;
    end


    if game then
        rndSeed = game.tick + rndSeed;
    end
    math.randomseed(rndSeed);
    local strTbl = {""};
    local check = AsciiTypeRange[asciiType].Check;
    local valid = AsciiTypeRange[asciiType].NumberRange;
    local len = #valid;
    for i=1,length do
        table.insert(strTbl, string.char(valid[math.random(1, len)]));
    end

    return table.concat(strTbl, "");
end

--- Will generate a unique id of 200 characters [a-z,A-z,0-9]
-- Checks against the array if the generated id already exists.
-- @param array Array This array of ids will be compared against to not generated the same one
-- @return string The genrated id
function EngineUtil.GenerateUniqueID(array)
    if (not array) then
        return EngineUtil.GenerateRandomString(200);
    else
        local currentID = EngineUtil.GenerateRandomString(200, AsciiType.NandT);
        local increment = 1;

        while array[currentID] ~= nil do
            currentID = EngineUtil.GenerateRandomString(200, AsciiType.NandT, increment);
            increment = increment + 1;
        end

        return currentID;
    end
end

--- Prints the output if debug is enabled.
-- @param title string The title to display between the [].
-- @param message string The message.
function EngineUtil.Debug(title, message)
    if (debug) then
        game.print("["..game.tick.."]["..title.."]: "..message);
    end
end

function EngineUtil.TableToString(tt, indent, done, getMetaAgain)
    done = done or {};
    indent = indent or 0;
    getMetaAgain = getMetaAgain or false;
    if type(tt) == "table" then
        local sb = {}
        for key, value in pairs(tt) do
            table.insert(sb, string.rep (" ", indent)) -- indent it
            if type (value) == "table" and not done [value] then
                done [value] = true
                table.insert(sb, "{\n");
                table.insert(sb, EngineUtil.TableToString(value, indent + 2, done))
                table.insert(sb, string.rep (" ", indent)) -- indent it
                table.insert(sb, "}\n");
            elseif "number" == type(key) then
                table.insert(sb, string.format("\"%s\"\n", tostring(value)))
            else
                table.insert(sb, string.format(
                    "%s = \"%s\"\n", tostring (key), tostring(value)))
            end
        end
        if not getMetaAgain then

            local mt = getmetatable(tt)
            if type(mt)~='table' then
                return table.concat(sb)
            end
            local index = mt.__index
            if type(index)~='table' then
                return table.concat(sb)
            else
                table.insert(sb, 'index = ' .. EngineUtil.TableToString(index, indent, done, true))
            end
        end
        return table.concat(sb)
    else
        if (tt == nil) then
            return "nil\n"
        end;
        return tt .. "\n"
    end
end

return EngineUtil;