--
-- Created by Webstorm:
-- User: Eastborn-PC
-- Date: 14-06-17
-- Time: 20:40
--

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

local gameData = {}
gameData.items = {}
gameData.fluids = {}
function onInit()
    global = global or {}

    global.persistData = {}
    global.persistData.items = {}
    global.persistData.fluids = {}

    onLoad();
end

function onLoad()
    script.on_event(defines.events.on_tick, function()
        if (game and global) then


            gameData.items = game.item_prototypes;
            gameData.fluids = game.fluid_prototypes;

            script.on_event(defines.events.on_tick, nil)
            script.on_event(defines.events.on_tick, onTick)
        end
    end)
end

local isDisplayed
function onTick()
    if ((game.tick % 180) == 0 and global) then
        for _, p in pairs(game.players) do
            if (not isDisplayed) then
                isDisplayed = true;
                local parent = p.gui.center.add{type="frame", name="frame_base",  direction="vertical" }
                    local top = parent.add{type="flow", name="frame_base_top", direction="vertical"}
                        local topHeading = top.add{type="label", name="frame_base_top_label", caption="Tracking List", single_line=true, style="centered-label" }
                        local closeButton = top.add{type="button", name="closeButton", caption="X"}
                        local topList = top.add{type="scroll-pane", name="frame_base_top_list", style="scroll-pane-track-list"}
                            local topItems = {"2", "data", "2", "testtest", "2", "data", "2", "testtest","2", "data", "2", "testtest", "2", "data", "2", "testtest"}
                            for k, v in pairs(topItems) do
                                topList.add{type="label", name="abcdef"..k, caption=v, single_line=true, style="centered-label" }
                            end
                    local bottom = parent.add{type="flow", name="frame_base_bottom", direction="vertical"}
                        local topHeading = bottom.add{type="label", name="frame_base_bottom_label", caption="Add items to the Tracking List", single_line=true, style="centered-label" }
                        local bottomContainer = bottom.add{type="flow", name="frame_base_bottom_container", direction="horizontal" }
                            local itemSelectorLabel = bottomContainer.add{type="label", name="selectItemLabel", caption="Trackable item", single_line=true, style="centered-label"}
                            local itemSelector = bottomContainer.add{type="choose-elem-button", name="selectItem", elem_type="item", item="iron-plate" }
                            local itemSelectorButton = bottomContainer.add{type="button", name="selectItemAdd", caption="Add tracking" }

                script.on_event(defines.events.on_gui_click, function(evnt)
                    for k, v in pairs(evnt) do
                        -- evnt {name=number, tick=number, player_index=number, element=LuaGuiElement, button=number, alt=boolean, control=boolean, shift=boolean}

                        if (evnt.element == itemSelectorButton) then
                            game.print(itemSelector.elem_value)
                        end

                        if (evnt.element == closeButton) then
                            p.gui.center.chil("frame").destroy();
                        end


                    end
                end)
            end
        end
    end
end