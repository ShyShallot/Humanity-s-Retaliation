require("PGStateMachine")
require("PGBaseDefinitions")
require("HALOFunctions") 
require("PlanetNameTable")
require("PGStoryMode")

function Definitions()

    ServiceRate = 1

    StoryModeEvents = 
    {
        ARTIFACT_DISPLAY = Init_Artifact_System,
        Artifact_Researched = Increment_Artifact_Count,
        Loop = Main_Artifact_Loop,
        Flush = Flush,
        Artifact_Dug_Up = Artifact_Dug_Up,
        Artifacts_Needed_To_Tech_2 = Reset_Artifact_Count,
        Artifacts_Needed_To_Tech_3 = Reset_Artifact_Count,
        Artifacts_Needed_To_Tech_4 = Reset_Artifact_Count,
        Artifacts_Needed_To_Tech_5 = Reset_Artifact_Count,
        Artifacts_Completed = End_Artifact_Research,
        Tech_Level_Advanced = Player_Advanced_Tech,
    }

    planet_cooldown_table = {
        ["alluvion"] = {
            ["cooldown"] = false,
            ["cooldown_week"] = 0
        },
        ["arcadia"] = {
            ["cooldown"] = false,
            ["cooldown_week"] = 0
        },
        ["meridian"] = {
            ["cooldown"] = false,
            ["cooldown_week"] = 0
        },
        ["harvest"] = {
            ["cooldown"] = false,
            ["cooldown_week"] = 0
        },
        ["mars"] = {
            ["cooldown"] = false,
            ["cooldown_week"] = 0
        },
        ["netherop"] = {
            ["cooldown"] = false,
            ["cooldown_week"] = 0
        },
        ["threshold"] = {
            ["cooldown"] = false,
            ["cooldown_week"] = 0
        },
        ["kamchatka"] = {
            ["cooldown"] = false,
            ["cooldown_week"] = 0
        },
        ["trove"] = {
            ["cooldown"] = false,
            ["cooldown_week"] = 0
        },
        ["installation_05"] = {
            ["cooldown"] = false,
            ["cooldown_week"] = 0
        },
        ["sanghelios"] = {
            ["cooldown"] = false,
            ["cooldown_week"] = 0
        },
        ["palamok"] = {
            ["cooldown"] = false,
            ["cooldown_week"] = 0
        },
    }

    tech_level_object_types = {
        Find_Object_Type("DS_Primary_Hyperdrive"), Find_Object_Type("DS_Shield_Gen"), Find_Object_Type("DS_Superlaser_Core"), Find_Object_Type("DS_Durasteel")
    }

    on_cooldown = 0

    cooldown_time = 1 -- weeks

    planet_cooldown_time = 6

    artifacts_researched = 0

    selected_planet = nil

    artifact_has_been_dug_up = false

    waiting_for_tech_up = false
end


function Init_Artifact_System(message)

    DebugMessage("%s -- Entering Init_Artifact_System -- Message: %s", tostring(Script), tostring(message))

    if message == OnEnter then
        
        GlobalValue.Set("Artifact_Research_Not_Allowed", 1)

        GlobalValue.Set("Artifact_Dig_Up_Not_Allowed", 1)

        GlobalValue.Set("Covenant_Main_Tech_Locked", 1)

        Move_To_Flush()

        Set_Next_State("Flush")
    end
end

function Main_Artifact_Loop(message)
    
    DebugMessage("%s -- Entering Main_Artifact_Loop -- Message: %s", tostring(Script), tostring(message))

    if message == OnUpdate then

        Update_Selected_Planet()
        
        if Has_Artifact_Requirement_Been_Met() then
            Set_Next_State("Artifacts_Needed_To_Tech_2")
        end

        local player = Find_Player("EMPIRE")

        local plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\COVN_Artifacts.xml")

        local Artifact_Display = plot.Get_Event("ARTIFACT_DISPLAY")

        Artifact_Display.Clear_Dialog_Text()

        local Artifacts_Required = Artifact_Research_Requirement()

        Artifact_Display.Add_Dialog_Text("HALO_ARTIFACT_NEEDED", tostring(player.Get_Tech_Level() + 1), tostring(tostring(artifacts_researched) .. "/" .. tostring(Artifacts_Required)))

        Artifact_Display.Add_Dialog_Text(" ")

        if Get_Current_Week() < on_cooldown then

            Artifact_Display.Add_Dialog_Text("HALO_ARTIFACT_ON_COOLDOWN", on_cooldown)

            GlobalValue.Set("Artifact_Dig_Up_Not_Allowed", 1)

            GlobalValue.Set("Artifact_Research_Not_Allowed", 1)

        end

        DebugMessage("%s -- Has Artifact Been Dug Up: %s", tostring(Script), tostring(artifact_has_been_dug_up))

        if artifact_has_been_dug_up then

            local current_artifact = Find_First_Object("ARTIFACT_DIG_UP")

            DebugMessage("%s -- Current Artifact: %s", tostring(Script), tostring(current_artifact))

            DebugMessage("%s -- Selected Planet: %s", tostring(Script), tostring(selected_planet))

            if selected_planet ~= nil and TestValid(current_artifact) and TestValid(current_artifact.Get_Planet_Location()) then

                DebugMessage("%s -- Valid Selected Planet and Artifact", tostring(Script))

                local Research_Facility_At_Planet = Does_Planet_Have_Research_Facility(current_artifact.Get_Planet_Location())

                DebugMessage("%s -- Current Artifact Planet: %s, Does Planet have Research Facility: %s", tostring(Script), tostring(current_artifact.Get_Planet_Location()), tostring(Research_Facility_At_Planet))

                if Research_Facility_At_Planet and selected_planet == current_artifact.Get_Planet_Location() then
                    DebugMessage("%s -- Artifact Location has a research facility and is the current selected planet", tostring(Script))
                    GlobalValue.Set("Artifact_Research_Not_Allowed", 0)
                else
                    DebugMessage("%s -- Conditions for Researching the artifact not met, locking", tostring(Script))
                    GlobalValue.Set("Artifact_Research_Not_Allowed", 1)
                end
            end

            if selected_planet == nil then
                DebugMessage("%s -- Selected Planet is nil, locking research", tostring(Script))
                GlobalValue.Set("Artifact_Research_Not_Allowed", 1)
            end
        else

            DebugMessage("%s -- Artifact Has Not Been Dug Up, Selected Planet: %s", tostring(Script), tostring(selected_planet))

            if selected_planet ~= nil then

                local selected_planet_entry_name = string.lower(selected_planet.Get_Type().Get_Name())

                local selected_planet_entry = planet_cooldown_table[selected_planet_entry_name]

                if selected_planet_entry ~= nil then
                    if selected_planet_entry["cooldown"] == false then
                        GlobalValue.Set("Artifact_Dig_Up_Not_Allowed", 0)
                    else
                        GlobalValue.Set("Artifact_Dig_Up_Not_Allowed", 1)
                    end
                end
            else
                GlobalValue.Set("Artifact_Dig_Up_Not_Allowed", 1)
            end

            GlobalValue.Set("Artifact_Research_Not_Allowed", 1)
        end

        if waiting_for_tech_up then
            Artifact_Display.Clear_Dialog_Text()
            Artifact_Display.Add_Dialog_Text("HALO_ARTIFACT_WAITING_FOR_TECH_UP")
        end

        for planet_name, cooldown_info in pairs(planet_cooldown_table) do

            local planet_on_cooldown = cooldown_info["cooldown"]
            local cooldown_ends = cooldown_info["cooldown_week"]

            if planet_on_cooldown then
                if Get_Current_Week() >= cooldown_ends then
                    planet_cooldown_table[planet]["cooldown"] = false
                end
            end

            Artifact_Display.Add_Dialog_Text(" ")
            Artifact_Display.Add_Dialog_Text(string.upper(planet_name))
            Artifact_Display.Add_Dialog_Text("HALO_ARTIFACT_PLANET_01", tostring(cooldown_info["cooldown"]))
            Artifact_Display.Add_Dialog_Text("HALO_ARTIFACT_PLANET_02", tostring(cooldown_info["cooldown_week"]))
        end

    end
end

function Flush(message)

    DebugMessage("%s -- Entering Flush -- Message: %s", tostring(Script), tostring(message))

    Set_Next_State("Loop")
    
end

function Artifact_Dug_Up(message)

    DebugMessage("%s -- Entering Artifact_Dug_Up -- Message: %s", tostring(Script), tostring(message))

    if message == OnEnter then
        
        local artifact = Find_First_Object("ARTIFACT_DIG_UP")

        if TestValid(artifact) then
            artifact_has_been_dug_up = true

            local inital_artifact_location = string.lower(artifact.Get_Planet_Location().Get_Type().Get_Name())

            if planet_cooldown_table[inital_artifact_location] ~= nil then
                planet_cooldown_table[inital_artifact_location]["cooldown"] = true
                planet_cooldown_table[inital_artifact_location]["cooldown_week"] = Get_Current_Week() + planet_cooldown_time
            end
        end

        Move_To_Flush()
    end
end

function Increment_Artifact_Count(message)

    DebugMessage("%s -- Entering Increment_Artifact_Count -- Message: %s", tostring(Script), tostring(message))

    if message == OnEnter then
        artifacts_researched = artifacts_researched + 1

        on_cooldown = Get_Current_Week() + cooldown_time

        artifact_has_been_dug_up = false

        Move_To_Flush()
    end
end

function Reset_Artifact_Count(message)

    DebugMessage("%s -- Entering Reset_Artifact_Count -- Message: %s", tostring(Script), tostring(message))

    if message == OnEnter then
        artifacts_researched = 0

        GlobalValue.Set("Covenant_Main_Tech_Locked", 0)

        waiting_for_tech_up = true

        Move_To_Flush()
    end
end

function End_Artifact_Research(message)

    DebugMessage("%s -- Entering End_Artifact_Research -- Message: %s", tostring(Script), tostring(message))

    if message == OnEnter then
        ScriptExit()
    end
end

function Does_Planet_Have_Research_Facility(planet)
    local covenant_research_platforms = Find_All_Objects_Of_Type("COVN_RESEARCH_FACILITY")

    for _, platform in pairs(covenant_research_platforms) do
        if platform.Get_Planet_Location() == planet then
            return true
        end
    end

    return false
end

function Artifact_Research_Requirement()
    local player = Find_Player("EMPIRE")

    if player.Get_Tech_Level() == 5 then
        return 0
    end

    local req_per_tech = {2,3,4,5}

    return req_per_tech[player.Get_Tech_Level()]
end

function Artifact_Planet_Selected(message)
    if message == OnEnter then

        Update_Selected_Planet()

        Move_To_Flush()
    end
end


function Update_Selected_Planet()
    local player = Find_Player("EMPIRE")

    local planets = FindPlanet.Get_All_Planets()

    for _,planet in pairs(planets) do

        flag_name = "ARTIFACT_PLAYER_SELECTED_" .. string.upper(planet.Get_Type().Get_Name())
        DebugMessage("Checking Planet: %s", flag_name)

        if Check_Story_Flag(player, flag_name, nil, true) then
            DebugMessage("Found Selected Planet: %s", planet.Get_Type().Get_Name())
            selected_planet = planet
        end
    end
end

function Player_Advanced_Tech(message)
    if message == OnEnter then
        GlobalValue.Set("Covenant_Main_Tech_Locked", 1)

        waiting_for_tech_up = false

        Move_To_Flush()
    end
end

function Move_To_Flush()
    DebugMessage("%s -- Next State: %s, Current State: %s", tostring(Script), tostring(Get_Next_State()), tostring(Get_Current_State()))

    if Get_Next_State() == Get_Current_State() then

        DebugMessage("%s -- Next State is the same as current state, moving to Flush", tostring(Script))

        Set_Next_State("Flush")
    end
end

function Has_Artifact_Requirement_Been_Met()

    local player = Find_Player("EMPIRE")

    if player.Get_Tech_Level() > 4 then
        return false
    end

    local triggers = {"Artifact_Requirement_Met_Tech_2", "Artifact_Requirement_Met_Tech_3", "Artifact_Requirement_Met_Tech_4", "Artifact_Requirement_Met_Tech_5"}

    local trigger = triggers[player.Get_Tech_Level()]
    
    if trigger == nil then
        return false
    end

    if Check_Story_Flag(player, trigger, nil, true) then
        return true
    end

    return false
end