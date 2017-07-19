--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 13-06-17
-- Time: 14:25
--

--- CompareType is the type a comparison can have
-- Used for describing ranges
local CompareType = {
    "e",
    "ne",
    "lt",
    "gt",
    "lte",
    "gte",
    e=1,    -- Equals                   ==
    ne=2,   -- Not Equals               ~=
    lt=3,   -- Less Than                <
    gt=4,   -- Greater Than             >
    lte=5,  -- Less Than or Equals      <=
    gte=6   -- Greater Than or Equals   >=
};

return CompareType