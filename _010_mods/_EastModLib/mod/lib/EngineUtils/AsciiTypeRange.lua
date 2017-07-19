--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 13-06-17
-- Time: 14:31
--

--- AsciiTypeRange is the range an asciitype has
-- These objects consist of Identification string,
-- id and a description as well as an actual range in both number and formula.
-- Also a check function is added just for ease of use.
local AsciiTypeRange = {
    {
        Name="OutOfRange",
        Description="Out of range Characters",
        Id=1,
        Range={
            {"lt", 0},
            {"gt", 255}
        },
        Check=function(c) return c < 0 or c > 255; end
    },
    {
        Name="Control",
        Description="Control Characters",
        Id=2,
        Range={
            {
                {"gte", 0},
                {"lte", 31}
            },
            {"e", 127}
        },
        NumberRange={0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,127},
        Check=function(c) return (c >= 0 and c <= 31) or c == 127; end
    },
    {
        Name="Regex",
        Description="Lua Regex Special Characters",
        Id=3,
        Range={
            {"e", 36},
            {"e", 37},
            {"e", 40},
            {"e", 41},
            {"e", 42},
            {"e", 43},
            {"e", 45},
            {"e", 46},
            {"e", 63},
            {"e", 91},
            {"e", 93},
            {"e", 94},
        },
        NumberRange={36, 37, 40, 41, 42, 43, 45, 46, 63, 91, 93, 94},
        Check=function(c) return c == 36 --[[ $ ]] or c == 37 --[[ % ]] or c == 40 --[[ ( ]] or c == 41 --[[ ) ]]
                or c == 42 --[[ * ]] or c == 43 --[[ + ]] or c == 45 --[[ - ]] or c == 46 --[[ . ]] or c == 63 --[[ ? ]]
                or c == 91 --[[ [ ]] or c == 93 --[[ ] ]] or c == 94 --[[ ^ ]]; end
    },
    {
        Name="Extended",
        Description="Extended Ascii Characters",
        Id=4,
        Range={
            {
                {"gte", 128},
                {"lte", 255}
            }
        },
        NumberRange={128,129,130,131,132,133,134,135,136,137,138,139,140,141,142,143,144,145,146,147,148,149,150,151,
            152,153,154,155,156,157,158,159,160,161,162,163,164,165,166,167,168,169,170,171,172,173,174,175,176,177,178,
            179,180,181,182,183,184,185,186,187,188,189,190,191,192,193,194,195,196,197,198,199,200,201,202,203,204,205,
            206,207,208,209,210,211,212,213,214,215,216,217,218,219,220,221,222,223,224,225,226,227,228,229,230,231,232,
            233,234,235,236,237,238,239,240,241,242,243,244,245,246,247,248,249,250,251,252,253,254,255},
        Check=function(c) return c >= 128 and c <= 255; end
    },
    {
        Name="NonNandT",
        Description="Non-Number or Text Characters",
        Id=5,
        Range={
            {
                {"gte", 32},
                {"lte", 37}
            },
            {
                {"gte", 58},
                {"lte", 64}
            },
            {
                {"gte", 91},
                {"lte", 96}
            },
            {
                {"gte", 123},
                {"lte", 126}
            }
        },
        NumberRange={32,33,34,35,36,37,58,59,60,61,62,63,64,91,92,93,94,95,96,123,124,125,126},
        Check=function(c) return (c >= 32 and c <= 47) --[[ [Space]!"#$%&'()*+,-./ ]]
                or (c >= 58 and c <= 64) --[[ :;<=>?@ ]] or (c >= 91 and c <= 96) --[[ [/]^_` ]]
                or (c >= 123 and c <= 126) --[[ {|}~ ]]; end
    },
    {
        Name="NandT",
        Description="Number or Text Characters",
        Id=6,
        Range={
            {
                {"gte", 48},
                {"lte", 57}
            },
            {
                {"gte", 65},
                {"lte", 90}
            },
            {
                {"gte", 97},
                {"lte", 122}
            }
        },
        NumberRange={48,49,50,51,52,53,54,55,56,57,65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,
            87,88,89,90,97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,
            121,122},
        Check=function(c) return (c >= 48 and c <= 57) --[[ 0-9 ]] or (c >= 65 and c <= 90) --[[ A-Z ]]
                or (c >= 97 and c <= 122) --[[ a-z ]]; end
    },
    {
        Name="Numbers",
        Description="Number Characters",
        Id=7,
        Range={
            {
                {"gte", 48},
                {"lte", 57}
            }
        },
        NumberRange={48,49,50,51,52,53,54,55,56,57},
        Check=function(c) return c >= 48 and c <= 57; end
    },
    {
        Name="Text",
        Description="Text Characters",
        Id=8,
        Range={
            {
                {"gte", 65},
                {"lte", 90}
            },
            {
                {"gte", 97},
                {"lte", 122}
            }
        },
        NumberRange={65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90,97,98,99,100,101,102,
            103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,121,122},
        Check=function(c) return (c >= 65 and c <= 90) --[[ A-Z ]] or (c >= 97 and c <= 122) --[[ a-z ]]; end
    },
    {
        Name="TextUpper",
        Description="Text Uppercase Characters",
        Id=9,
        Range={
            {
                {"gte", 65},
                {"lte", 90}
            }
        },
        NumberRange={65,66,67,68,69,70,71,72,73,74,75,76,77,78,79,80,81,82,83,84,85,86,87,88,89,90},
        Check=function(c) return (c >= 65 and c <= 90) --[[ A-Z ]]; end
    },
    {
        Name="TextLower",
        Description="Text Lowercase Characters",
        Id=10,
        Range={
            {
                {"gte", 97},
                {"lte", 122}
            }
        },
        NumberRange={97,98,99,100,101,102,103,104,105,106,107,108,109,110,111,112,113,114,115,116,117,118,119,120,
            121,122},
        Check=function(c) return c >= 97 and c <= 122 --[[ a-z ]]; end
    }
};

-- Sets the Ids as indexes as well with the same content
AsciiTypeRange.OutOfRange=AsciiTypeRange[1];
AsciiTypeRange.Control=AsciiTypeRange[2];
AsciiTypeRange.Regex=AsciiTypeRange[3];
AsciiTypeRange.Extended=AsciiTypeRange[4];
AsciiTypeRange.NonNandT=AsciiTypeRange[5];
AsciiTypeRange.NandT=AsciiTypeRange[6];
AsciiTypeRange.Numbers=AsciiTypeRange[7];
AsciiTypeRange.Text=AsciiTypeRange[8];
AsciiTypeRange.TextUpper=AsciiTypeRange[9];
AsciiTypeRange.TextLower=AsciiTypeRange[10];

return AsciiTypeRange