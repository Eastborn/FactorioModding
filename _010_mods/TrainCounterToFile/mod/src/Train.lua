--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 28-07-17
-- Time: 17:14
--
local Train = {};
Train.__index = Train;

--- Creates the Train object
-- @return Train The Train object that was just created.
function Train:new(train)
    local obj = {};
    setmetatable(obj, Train);

    obj:update(train);

    return obj;
end

function Train:fromSerialized(train)
    setmetatable(train, Train);
    return train;
end

function Train:update(train)
    train = train or self.train;

    self.train = train;
    self.id = train.id;
end

function Train:allParts()
    return self.train.carriages;
end

Train.Create = 1;
Train.Merge = 2;
Train.Split = 3;
function Train.IdChangeReason(condition, evt)
    if (condition == Train.Create) then
        return evt.train and not evt.old_train_id_1 and not evt.old_train_id_2;
    elseif (condition == Train.Merge) then
        return evt.train and evt.old_train_id_1 and evt.old_train_id_2;
    elseif (condition == Train.Split) then
        return evt.train and evt.old_train_id_1 and not evt.old_train_id_2;
    end
    return false;
end

return Train
