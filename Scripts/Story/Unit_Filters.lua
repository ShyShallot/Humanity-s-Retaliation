require("PGStateMachine")
require("HALOFunctions")
require("PGBaseDefinitions")
require("HALOFunctions") 


function Definitions()
    ServiceRate = 1
	Define_State("State_Init", State_Init);


    filters = {}

    Filter_List = {}

    unit_table = {}

    active_filter = nil
    
end

function State_Init(message)

    
    plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Unit_Filters.xml")

    human = Find_Human_Player()

    if message == OnEnter then
        unit_table = require("globalUnitTable")

        filters = {
            ["Structures_Super_Filter"] = {
                Name = "STRUCTURE_SUPER_FILTER_CLICKED",
                Clicked = false,
                Gui_Name = "b_filters4"
            },
    
            ["Capitals_Filter"] = { 
                Name = "CAPITAL_FILTER_CLICKED",
                Clicked = false,
                Gui_Name = "b_filters5"
            },
    
            ["Frigate_Corvette_Filter"] = {
                Name = "FRIGATE_CORVETTE_FILTER_CLICKED",
                Clicked = false,
                Gui_Name = "b_filters6"
            },
    
            ["Fighter_Filter"] = {
                Name = "FIGHTER_FILTER_CLICKED",
                Clicked = false,
                Gui_Name = "b_filters7"
            }
        }
    
        Filter_List = {
            ["Structures_Super_Filter"] = "Structure | Super",
            ["Capitals_Filter"] = "Capital",
            ["Frigate_Corvette_Filter"] = "Frigate | Corvette",
            ["Fighter_Filter"] = "Fighter"
        }

        active_filter = nil

        for event, _ in pairs(filters) do
            DebugMessage("Event Name: %s", event)
            plot.Get_Event(event).Set_Reward_Parameter(1, human.Get_Faction_Name())
        end

        GlobalValue.Set("Filter_Active", 0)
    end

    if message == OnUpdate then

        PrintTable(filters)

        for event, trigger in pairs(filters) do

            DebugMessage("Event: %s", event)

            DebugMessage("Trigger: %s, Clicked: %s", trigger.Name, tostring(trigger.Clicked))

            --PrintTable(trigger)
            
            if Check_Story_Flag(human, trigger.Name, nil, true) then

                DebugMessage("%s was Clicked.", trigger.Name)

                if filters[event].Clicked then
                    filters[event].Clicked = false
                else 
                    filters[event].Clicked = true
                end
            end

            if filters[event].Clicked then
                for sevent, strigger in pairs(filters) do

                    if not StringCompare(sevent, event) and strigger.Clicked then
                        DebugMessage("Event: %s Clicked, Disabling: %s", event, sevent)

                        Disable_Filter(strigger.Gui_Name)

                        filters[sevent].Clicked = false
                    end
                end

                active_filter = event

                DebugMessage("Active Filter: %s", event)

                GlobalValue.Set("Filter_Active", 1)
            end
        end

        all_false = 0

        for event, trigger in pairs(filters) do
            if trigger.Clicked == false then
                all_false = all_false + 1
            end
        end

        if all_false == tableLength(filters) then
            active_filter = nil

            GlobalValue.Set("Filter_Active", 0)
        end

        if active_filter == nil then
            for unit_name, unit in pairs(unit_table) do

                DebugMessage("Unit: %s, Special: %s", tostring(unit_name), tostring(unit.Special))

                Lock_Tree(unit, unit_name, human)
            end
        else
            for unit_name, unit in pairs(unit_table) do

                DebugMessage("Unit to Check: %s, Category: %s", unit_name, unit.Category)

                DebugMessage("Special Case: %s", tostring(unit.Special))

                if not Is_Unit_In_Filter(unit.Category, Filter_List[active_filter]) then
                    human.Lock_Tech(Find_Object_Type(unit_name))
                else
                    if unit.Special ~= nil then
                        special_object = Find_First_Object(unit.Special)

                        if TestValid(special_object) then
                            if unit.Special_Inverted then
                                human.Lock_Tech(Find_Object_Type(unit_name))
                            else
                                human.Unlock_Tech(Find_Object_Type(unit_name))
                            end
                        else
                            if GlobalValue.Get(unit.Special) == 1 then
                                human.Unlock_Tech(Find_Object_Type(unit_name))

                                if unit.Special_Inverted then
                                    human.Lock_Tech(Find_Object_Type(unit_name))
                                end
                            end
                        end
                    else
                        human.Unlock_Tech(Find_Object_Type(unit_name))
                    end
                end
            end
        end
    end
end

function Lock_Tree(unit, unit_name, faction)
    if unit.Special ~= nil then
        special_object = Find_First_Object(unit.Special)

        if TestValid(special_object) then
            if unit.Special_Inverted then
                faction.Lock_Tech(Find_Object_Type(unit_name))
            else
                faction.Unlock_Tech(Find_Object_Type(unit_name))
            end
        else
            if GlobalValue.Get(unit.Special) == 1 then
                if unit.Special_Inverted then
                    faction.Lock_Tech(Find_Object_Type(unit_name))
                else
                    faction.Unlock_Tech(Find_Object_Type(unit_name))
                end
            else
                if GlobalValue.Get(unit.Special) == 0 then
                    faction.Lock_Tech(Find_Object_Type(unit_name))
                end

                if GlobalValue.Get(unit.Special) == nil then
                    if unit.Special_Inverted then
                        faction.Unlock_Tech(Find_Object_Type(unit_name))
                    else
                        faction.Lock_Tech(Find_Object_Type(unit_name))
                    end
                end
            end
        end
    else
        faction.Unlock_Tech(Find_Object_Type(unit_name))
    end
end


function Disable_Filter(filter_name)
    local plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Unit_Filters.xml")

    local event = plot.Get_Event("Force_Click_Filter")

    event.Set_Reward_Parameter(0,filter_name)

    Story_Event("Force_Click_Element")
end

function Is_Unit_In_Filter(category, filter)
    DebugMessage("Category: %s, Filter: %s", category, filter)

    local filters = split(filter, " | ")

    local is_in_filter = false

    for _, split_filter in pairs(filters) do
        if StringCompare(split_filter,category) then
            is_in_filter = true
        end
    end

    return is_in_filter
end