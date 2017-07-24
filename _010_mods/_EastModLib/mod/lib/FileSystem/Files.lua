--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 16-07-17
-- Time: 23:03
--
local Files = {};
Files.__index = Files;

local FileQueueElement = require('lib.FileSystem.FileQueueElement')

--- Creates the Files object
-- @return Files The Files object that was just created.
function Files:new(engine)
    local obj = {};
    setmetatable(obj, Files);

    obj.queue = {}

    obj.queueLengthIntermediary = 0
    engine.events:on(defines.events.on_tick, function()
        local queueLenght = #obj.queue;
        if (queueLenght <= 0) then

        elseif (queueLenght > 0 and queueLenght < 60 and game.tick % obj.queueLengthIntermediary == 0) then
            obj:processQueue();
        elseif (queueLenght >= 60) then
            obj:processQueue(queueLenght/60)
        end

        if (game.tick % 60 == 0) then
            obj.queueLengthIntermediary = queueLenght;
        end
    end)

    return obj;
end

function Files:processQueue(amount)
    amount = amount or 1;

    for i=0,amount,1 do
        local element = table.remove(self.queue, 1);
        if element then
            self:executeElement(element);
        end
    end
end

function Files:executeElement(element)
    if (element.remove) then
        game.remove_path(element.filePath);
    else
        if (element.player) then
            game.write_file(element.filePath, element.data, element.append, element.player);
        else
            game.write_file(element.filePath, element.data, element.append);
        end
    end
    element.done();
end

function Files:writeFile(filePath, data, append, player, done)
    local solved = false;
    if (#self.queue > 0) then
        for i=1, #self.queue, 1 do
            if (self.queue[i].filePath == filePath and self.queue[i].player == player) then
                if (self.queue[i].remove) then
                    self.queue[i].remove = false;
                end
                if (append) then
                    self.queue[i].data = self.queue[i].data .. data;
                else
                    self.queue[i].data = data;
                end
                solved = true;
            end
        end
    end
    if (not solved) then
        table.insert(self.queue, FileQueueElement:new(filePath, false, data, append, player, done));
    end
end

function Files:removeFile(filePath, done)
    local solved = false;
    if (#self.queue > 0) then
        for i=1, #self.queue, 1 do
            if (self.queue[i].filePath == filePath) then
                self.remove = true;
                solved = true;
            end
        end
    end
    if (not solved) then
        table.insert(self.queue, FileQueueElement:new(filePath, true, nil, nil, nil, done));
    end
end

return Files
