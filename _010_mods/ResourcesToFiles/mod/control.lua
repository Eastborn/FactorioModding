--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 14-06-17
-- Time: 20:40
--

local baseFolder = "stream_data/resources_to_files/";
local force;
local xtermsItems = {iron="iron-plate", copper="copper-plate", electronic="electronic-circuit"}

script.on_init(function()
    onInit();
end)

script.on_load(function()
    -- No "game" Access

    onLoad();
end)

script.on_configuration_changed(function(configChangeData)
    global = {};
    onInit();
end)

function onInit()
    global = global or {}
    global.itemDataIn = global.itemDataIn or {}
    global.fluidDataIn = global.fluidDataIn or {}
    global.itemDataOut = global.itemDataOut or {}
    global.fluidDataOut = global.fluidDataOut or {}
    global.lastData = {}
    global.pulseInterval = settings.startup["rtf-delay"].value
    global.xTermsSetting = settings.startup["rtf-xterm"].value

    if (global.xTermsSetting) then
        for k, v in pairs(xtermsItems) do
            global.itemDataIn[v] = global.itemDataIn[v] or {}
            table.insert(global.itemDataIn[v], {tick=0, count=0, name=v})

            global.itemDataOut[v] = global.itemDataOut[v] or {}
            table.insert(global.itemDataOut[v], {tick=0, count=0, name=v})
        end
    else
        for k, v in pairs(game.item_prototypes) do
            global.itemDataIn[k] = global.itemDataIn[k] or {}
            table.insert(global.itemDataIn[k], {tick=0, count=0, name=v.name})

            global.itemDataOut[k] = global.itemDataOut[k] or {}
            table.insert(global.itemDataOut[k], {tick=0, count=0, name=v.name})
        end

        for k,v in pairs(game.fluid_prototypes) do
            global.fluidDataIn[k] = global.fluidDataIn[k] or {}
            table.insert(global.fluidDataIn[k], {tick=0, count=0, name=v.name})

            global.fluidDataOut[k] = global.fluidDataOut[k] or {}
            table.insert(global.fluidDataOut[k], {tick=0, count=0, name=v.name})
        end
    end

    onLoad();
end

function onLoad()
    script.on_event(defines.events.on_tick, function()
        if (game and global) then
            local forces = {}
            for k, v in pairs(game.players) do
                if (forces[v.force.name]) then
                    forces[v.force.name] = forces[v.force.name] + 1
                else
                    forces[v.force.name] = 1
                end
            end

            local maxNumber = 0
            local maxName = ""
            for k, v in pairs(forces) do
                if (v > maxNumber) then
                    maxNumber = v
                    maxName = k
                end
            end

            force = game.forces[maxName]

            for k, v in pairs(global.itemDataIn) do
                local fn = baseFolder.."items_in/"..v[1].name..".txt";
                game.write_file(fn, "", false)
                global.lastData[fn] = "";
            end
            for k, v in pairs(global.itemDataOut) do
                local fn = baseFolder.."items_out/"..v[1].name..".txt";
                game.write_file(fn, "", false)
                global.lastData[fn] = "";
            end
            for k, v in pairs(global.fluidDataIn) do
                local fn = baseFolder.."fluids_in/"..v[1].name..".txt";
                game.write_file(baseFolder.."fluids_in/"..v[1].name..".txt", "", false)
                global.lastData[fn] = "";
            end
            for k, v in pairs(global.fluidDataOut) do
                local fn = baseFolder.."fluids_out/"..v[1].name..".txt";
                game.write_file(fn, "", false)
                global.lastData[fn] = "";
            end

            script.on_event(defines.events.on_tick, nil)
            script.on_event(defines.events.on_tick, onTick)
        end
    end)
end

function updateValue(arr, categoryFolder)
    if #arr > 1 then
        local first = arr[1]
        local last = arr[#arr]

        local ticks = last.tick - first.tick;
        local difference = last.count - first.count;
        local ratio = 60*60 / ticks
        local ratePerMin = math.floor(difference * ratio);

        local fn = baseFolder..categoryFolder.."/"..arr[1].name..".txt"
        if global.lastData[fn] ~= ratePerMin then
            addToSaveQueue(fn, ratePerMin)
        end

        if #arr > global.pulseInterval/10 then
            table.remove(arr, 1)
        end

    end
end

local fileQueue = {}
function addToSaveQueue(file, data)
    table.insert(fileQueue, {file=file, data=data});
end

function saveFilesFromQueue(tickDevision)
    local amount = math.ceil(#fileQueue / tickDevision);

    for i = 1, amount do
        local item = table.remove(fileQueue, 1);
        game.write_file(item.file, item.data)
        global.lastData[item.file] = item.data
    end
end

function onTick()
    if (#fileQueue > 0) then
        saveFilesFromQueue(global.pulseInterval)
    end

    if ((game.tick % global.pulseInterval) == 0 and global) then

        if global.xTermsSetting then
            for k, v in pairs(xtermsItems) do
                if (force.item_production_statistics.input_counts[v] and force.item_production_statistics.output_counts[v]) then
                    table.insert(global.itemDataIn[v], {tick=game.tick, count=force.item_production_statistics.input_counts[v], name=v})
                    updateValue(global.itemDataIn[v], "items_in")
                    table.insert(global.itemDataOut[v], {tick=game.tick, count=force.item_production_statistics.output_counts[v], name=v})
                    updateValue(global.itemDataOut[v], "items_out")
                end
            end
        else
            for k, v in pairs(force.item_production_statistics.input_counts) do
                table.insert(global.itemDataIn[k], {tick=game.tick, count=v, name=k})
                updateValue(global.itemDataIn[k], "items_in")
            end
            for k, v in pairs(force.item_production_statistics.output_counts) do
                table.insert(global.itemDataOut[k], {tick=game.tick, count=v, name=k})
                updateValue(global.itemDataOut[k], "items_out")
            end

            for k, v in pairs(force.fluid_production_statistics.input_counts) do
                table.insert(global.fluidDataIn[k], {tick=game.tick, count=v, name=k})
                updateValue(global.fluidDataIn[k], "fluids_in")
            end

            for k, v in pairs(force.fluid_production_statistics.output_counts) do
                table.insert(global.fluidDataOut[k], {tick=game.tick, count=v, name=k})
                updateValue(global.fluidDataOut[k], "fluids_out")
            end
        end
    end
end