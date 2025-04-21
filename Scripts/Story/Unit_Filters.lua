require("PGStateMachine")
require("PGStoryMode")
require("HALOFunctions")
require("PGBaseDefinitions")
local unit_table = require("globalUnitTable")


function Definitions()
    StoryModeEvents =
    {
        Universal_Story_Start = Init_Filters,
        Structures_Super_Filter = Set_Structures_Super_Filter,
        Capitals_Filter = Set_Capitals_Filter,
        Frigate_Corvette_Filter = Set_Frigate_Corvette_Filter,
        Fighter_Filter = Set_Fighter_Filter,
        Flush = Flush,
        Reset_Filters = Reset_Filters,
    }

    Filter_List = {}

    active_filter = nil

    lock_list = {}

    
    Structure_Super_Filter = "Structure | Super"
    Capitals_Filter = "Capital"
    Frigate_Corvette_Filter = "Frigate | Corvette"
    Fighter_Filter = "Fighter"

    Structure_Super_Filter_GUI = "b_filters4"
    Capitals_Filter_GUI = "b_filters5"
    Frigate_Corvette_Filter_GUI = "b_filters6"
    Fighter_Filter_GUI = "b_filters7"
    
end

function Init_Filters(message)
    if message == OnEnter then
        DebugMessage("%s -- Init_Filters", tostring(Script))

        local human = Find_Human_Player()

        for unit_name, unit_info in pairs(unit_table) do

            DebugMessage("%s -- Adding Unit to Lock List: %s", tostring(Script), tostring(unit_name))

            local unit_type = Find_Object_Type(unit_name)

            DebugMessage("%s -- Unit Type: %s", tostring(Script), tostring(unit_type))

            if unit_type ~= nil then
                Unit_Build_Status(unit_type, false, human)
            end
        end

        local plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Unit_Filters.xml")
        
        local Structures_Super_Filter_Event = plot.Get_Event("Structures_Super_Filter")
        Structures_Super_Filter_Event.Set_Reward_Parameter(1, human.Get_Faction_Name())

        local Capitals_Filter_Event = plot.Get_Event("Capitals_Filter")
        Capitals_Filter_Event.Set_Reward_Parameter(1, human.Get_Faction_Name())

        local Frigate_Corvette_Filter_Event = plot.Get_Event("Frigate_Corvette_Filter")
        Frigate_Corvette_Filter_Event.Set_Reward_Parameter(1, human.Get_Faction_Name())

        local Fighter_Filter_Event = plot.Get_Event("Fighter_Filter")
        Fighter_Filter_Event.Set_Reward_Parameter(1, human.Get_Faction_Name())

        Set_Next_State("Flush")
    end
end

function Set_Structures_Super_Filter(message)
    local human = Find_Human_Player()
    if message == OnEnter then
        DebugMessage("%s -- Set_Structures_Super_Filter", tostring(Script))

        if active_filter == "Structures_Super_Filter" then
            DebugMessage("%s -- Structures Super Filter Already Active", tostring(Script))
            Set_Next_State("Reset_Filters")
            return
        end

        Filter_By_Category(Structure_Super_Filter)
        active_filter = "Structures_Super_Filter"

        Set_Next_State("Flush")
    end
end

function Set_Capitals_Filter(message)
    local human = Find_Human_Player()
    if message == OnEnter then
        DebugMessage("%s -- Set_Capitals_Filter", tostring(Script))

        if active_filter == "Capitals_Filter" then
            DebugMessage("%s -- Capitals Filter Already Active", tostring(Script))
            Set_Next_State("Reset_Filters")
            return
        end

        Filter_By_Category(Capitals_Filter)
        active_filter = "Capitals_Filter"

        Set_Next_State("Flush")
    end
end

function Set_Frigate_Corvette_Filter(message)
    local human = Find_Human_Player()
    if message == OnEnter then
        DebugMessage("%s -- Set_Frigate_Corvette_Filter", tostring(Script))

        if active_filter == "Frigate_Corvette_Filter" then
            DebugMessage("%s -- Frigate Corvette Filter Already Active", tostring(Script))
            Set_Next_State("Reset_Filters")
            return
        end

        Filter_By_Category(Frigate_Corvette_Filter)
        active_filter = "Frigate_Corvette_Filter"

        Set_Next_State("Flush")
    end
end

function Set_Fighter_Filter(message)
    local human = Find_Human_Player()
    if message == OnEnter then
        DebugMessage("%s -- Set_Fighter_Filter", tostring(Script))

        if active_filter == "Fighter_Filter" then
            DebugMessage("%s -- Fighter Filter Already Active", tostring(Script))
            Set_Next_State("Reset_Filters")
            return
        end

        Filter_By_Category(Fighter_Filter)
        active_filter = "Fighter_Filter"

        Set_Next_State("Flush")
    end
end

function Filter_By_Category(category)

    local human = Find_Human_Player()

    External_Lock_Checks()

    for unit_type_name, should_lock in pairs(lock_list) do
        local unit_type = Find_Object_Type(unit_type_name)

        local unit_type_info = unit_table[unit_type_name]

        --DebugMessage("%s -- Unit Type: %s, Unit Type Info: %s", tostring(Script), tostring(unit_type_name), tostring(unit_type_info))

        if unit_type ~= nil and unit_type_info ~= nil then
            local unit_category = unit_type_info.Category
            --DebugMessage("%s -- Unit Category: %s", tostring(Script), tostring(unit_category))
            if Is_Unit_In_Filter(unit_category, category) == false then -- if unit is not in the filter
                --DebugMessage("%s -- %s is not in filter, locking", tostring(Script), tostring(unit_type_name))
                human.Lock_Tech(unit_type)
            else -- if unit is in filter
                if should_lock == false then -- if the unit is not supposed to be locked unlock it
                    human.Unlock_Tech(unit_type)
                else -- if the unit is supposed to be locked, lock it
                    human.Lock_Tech(unit_type) 
                end
            end
        end
    end
end

function Reset_Filters(message)
    if message == OnEnter then
        DebugMessage("%s -- Reset_Filters", tostring(Script))

        DebugMessage("%s -- Active Filter: %s", tostring(Script), tostring(active_filter))

        local gui_element = nil

        if active_filter == "Structures_Super_Filter" then
            gui_element = Structure_Super_Filter_GUI
        elseif active_filter == "Capitals_Filter" then
            gui_element = Capitals_Filter_GUI
        elseif active_filter == "Frigate_Corvette_Filter" then
            gui_element = Frigate_Corvette_Filter_GUI
        elseif active_filter == "Fighter_Filter" then
            gui_element = Fighter_Filter_GUI
        end

        DebugMessage("%s -- Resetting Filter: %s", tostring(Script), tostring(gui_element))

        if gui_element ~= nil then
            DebugMessage("%s -- Force_Click_Filter: %s", tostring(Script), tostring(gui_element))
            --Force_Click_Filter(gui_element)
        end

        active_filter = nil

        DebugMessage("%s -- Active Filter: %s", tostring(Script), tostring(active_filter))

        local human = Find_Human_Player()

        for unit_type_name, should_lock in pairs(lock_list) do
            local unit_type = Find_Object_Type(unit_type_name)
            if unit_type ~= nil then
                DebugMessage("%s -- Unit Type: %s, Should Lock: %s", tostring(Script), tostring(unit_type_name), tostring(should_lock))
                if should_lock == false then -- if the unit is not supposed to be locked unlock it
                    human.Unlock_Tech(unit_type)
                else -- if the unit is supposed to be locked, lock it
                    human.Lock_Tech(unit_type) 
                end
            end
        end

        Set_Next_State("Flush")
    end
    
end

function Unit_Build_Status(unit_type, should_lock, owner)
    
    if should_lock ~= true then
        should_lock = false
    end

    if owner.Is_Human() == false then -- we dont want to convolute our lock_list with AI units
        if should_lock then
            owner.Lock_Tech(unit_type)
        else
            owner.Unlock_Tech(unit_type)
        end
        return
    end
    

    lock_list[unit_type.Get_Name()] = should_lock
end

function External_Lock_Checks()
    local human = Find_Human_Player()
    for unit_type_name, unit_info in pairs(unit_table) do
        local unit_type = Find_Object_Type(unit_type_name)

        if unit_info.Global_Value_Check ~= nil then
            if GlobalValue.Get(unit_info.Global_Value_Check) == 1 then
                --DebugMessage("%s -- Locking Unit: %s", tostring(Script), tostring(unit_type_name))
                if unit_type ~= nil then
                    Unit_Build_Status(unit_type, true, human)
                end
            else
                --DebugMessage("%s -- Unlocking Unit: %s", tostring(Script), tostring(unit_type_name))
                if unit_type ~= nil then
                    Unit_Build_Status(unit_type, false, human)
                end
            end
        end
    end
end


function Is_Unit_In_Filter(category, filter)
    --DebugMessage("Category: %s, Filter: %s", tostring(category), tostring(filter))

    local filters = split(filter, " | ")

    local is_in_filter = false

    for _, split_filter in pairs(filters) do
        if StringCompare(split_filter,category) then
            is_in_filter = true
        end
    end

    return is_in_filter
end

function Force_Click_Filter(filter_name)
    local plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Unit_Filters.xml")
    local event = plot.Get_Event("Force_Click_Filter")

    event.Set_Reward_Parameter(0, filter_name)

    Story_Event("Force_Click_Element")
end

function Flush(message)
    if message == OnEnter then
        DebugMessage("%s -- Flush", tostring(Script))

    end

    if message == OnUpdate then
        DebugMessage("%s -- In OnUpdate", tostring(Script))
        if active_filter == nil then
            External_Lock_Check_Update()
        end
    end
end

function External_Lock_Check_Update()
    local human = Find_Human_Player()

    for unit_type_name, unit_info in pairs(unit_table) do
        local unit_type = Find_Object_Type(unit_type_name)

        if unit_info.Global_Value_Check ~= nil then
            if GlobalValue.Get(unit_info.Global_Value_Check) == 1 then
                DebugMessage("%s -- Locking Unit: %s", tostring(Script), tostring(unit_type_name))
                if unit_type ~= nil then
                    human.Lock_Tech(unit_type)
                end
            else
                DebugMessage("%s -- Unlocking Unit: %s", tostring(Script), tostring(unit_type_name))
                if unit_type ~= nil then
                    human.Unlock_Tech(unit_type)
                end
            end
        end
    end
end