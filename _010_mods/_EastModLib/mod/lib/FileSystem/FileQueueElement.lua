--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 17-07-17
-- Time: 09:38
--
local FileQueueElement = {};
FileQueueElement.__index = FileQueueElement;

--- Creates the FileQueueElement object
-- @return FileQueueElement The FileQueueElement object that was just created.
function FileQueueElement:new(filePath, remove, data, append, player, done)
    local obj = {};
    setmetatable(obj, FileQueueElement);

    obj.filePath = filePath;
    obj.remove = remove;
    obj.data = data;
    obj.append = append or false;
    obj.player = player;
    obj.done = done or function() end;

    return obj;
end

return FileQueueElement
