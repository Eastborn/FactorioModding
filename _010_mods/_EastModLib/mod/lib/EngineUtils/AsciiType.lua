--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 13-06-17
-- Time: 14:29
--

--- AsciiType is the type a character can be
-- This is usefull for selecting out certain character sets to exclude for example regex special characters
local AsciiType = {
    "OutOfRange",
    "Control",
    "Regex",
    "Extended",
    "NonNandT",
    "NandT",
    "Numbers",
    "Text",
    "TextUpper",
    "TextLower",
    OutOfRange=1,   -- Out of range Characters
    Control=2,      -- Control Characters
    Regex=3,        -- Lua Regex Special Characters
    Extended=4,     -- Extended Ascii Characters
    NonNandT=5,     -- Non-Number or Text Characters
    NandT=6,        -- Number or Text Characters
    Numbers=7,      -- Number Characters
    Text=8,         -- Text Characters
    TextUpper=9,    -- Text Uppercase Characters
    TextLower=10    -- Text LowerCase Characters
}

return AsciiType