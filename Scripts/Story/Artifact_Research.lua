require("PGStateMachine")
require("HALOFunctions")
require("PGBaseDefinitions")
require("HALOFunctions") 
require("PlanetNameTable")

function Definitions()
    ServiceRate = 0.5
	Define_State("State_Init", State_Init);
    Define_State("State_Artifact", State_Research)

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

    decided_planet = nil

    last_selected_planet = nil

    last_artifact_researched = 0

    artifact_dig_cooldown = 1

    on_cooldown = false

    next_tech_researched = false

    tech_up_available = false

end

function State_Init(message)
    if message == OnEnter then

        covenant = Find_Player("EMPIRE")

        DebugMessage("Setting Default Values")

        GlobalValue.Set("Artifacts_Dug", 0)

        GlobalValue.Set("Last_Planet", 0)

        GlobalValue.Set("Global_Artifact_Cooldown", 0)

        Set_Next_State("State_Artifact")
    end
end

function State_Research(message)

    player = Find_Human_Player()

    if message == OnEnter then

        DebugMessage("Entered State_Research")

        plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\COVN_Artifacts.xml")

        event = plot.Get_Event("ARTIFACT_DISPLAY")

        event.Clear_Dialog_Text()

        event.Add_Dialog_Text("Artifacts Needed for Tech Level " .. tostring(player.Get_Tech_Level() + 1) .. ": " .. tostring(GlobalValue.Get("Artifacts_Dug")) .. "/" .. tostring(Artifacts_Needed()))

        event.Add_Dialog_Text("Planets with Known Artifacts: ")

        event.Add_Dialog_Text("") 

        local planets = FindPlanet.Get_All_Planets()

        for i,planet in ipairs(planets) do

            select_event = plot.Get_Event("ARTIFACT_SELECT_"..planet.Get_Type().Get_Name())

            select_event.Set_Reward_Parameter(1, player.Get_Faction_Name())
        end
        
        for planet, cooldown in pairs(planet_cooldown_table) do

            yes_or_no = "Yes"

            if cooldown["cooldown"] then

                DebugMessage("Planet: %s is on Cooldown: %s", tostring(planet), tostring(cooldown["cooldown"]))
                yes_or_no = "No"
            end

            event.Add_Dialog_Text(Capital_First_Letter(planet) .. ": " .. yes_or_no)
        end
         
        research_unit_type = Find_Object_Type("ARTIFACT_RESEARCH")

        dig_up_unit_type = Find_Object_Type("ARTIFACT_DIG_UP")

        player.Lock_Tech(research_unit_type)

        player.Lock_Tech(dig_up_unit_type)

        for _, tech_up in pairs(tech_level_object_types) do
            DebugMessage("Locking: %s", tostring(tech_up))
            player.Lock_Tech(tech_up)
        end

    end

    if message == OnUpdate then

        if player.Get_Tech_Level() == 5 then
            ScriptExit()
        end

        if GlobalValue.Get("Global_Artifact_Cooldown") == 1 then

            DebugMessage("Artifact Dig up is on cooldown")

            last_artifact_researched = Get_Current_Week()

            GlobalValue.Set("Global_Artifact_Cooldown", 0)

            on_cooldown = true

            player.Lock_Tech(dig_up_unit_type)
        end

        DebugMessage("Current Week: %s, Last time an Artifact was Dug up: %s, Length of Cooldown: %s, and Are we on cooldown: %s", tostring(Get_Current_Week()), tostring(last_artifact_researched), tostring(artifact_dig_cooldown), tostring(on_cooldown))

        if Get_Current_Week() >= (last_artifact_researched + artifact_dig_cooldown) and on_cooldown then
            DebugMessage("Off Cooldown")
            on_cooldown = false
        end

        selected_planet = Get_Selected_Planet()

        if selected_planet ~= nil then
            last_selected_planet = selected_planet
        end

        if selected_planet == nil and last_selected_planet ~= nil then
            selected_planet = last_selected_planet
        end

        DebugMessage("Artifact -- Selected Planet: %s", tostring(selected_planet))

        if selected_planet ~= nil and not on_cooldown then 
            if not Is_Planet_On_Cooldown(selected_planet.Get_Type().Get_Name()) then
                DebugMessage("%s is not on cooldown, unlocked Dig Up", tostring(selected_planet.Get_Type().Get_Name()))
                player.Unlock_Tech(dig_up_unit_type)
            else 
                DebugMessage("Selected Planet is either not on cooldown or isnt an artifact planet, locking")
                player.Lock_Tech(dig_up_unit_type)
            end
        else
            DebugMessage("Selected Planet is either not on cooldown or isnt an artifact planet, locking")
            player.Lock_Tech(dig_up_unit_type)
        end

        dig_up_unit = Find_First_Object("ARTIFACT_DIG_UP")

        if dig_up_unit ~= nil then
            if dig_up_unit.Get_Planet_Location() == selected_planet then
                if Find_Research_Faciltiy_on_Planet(selected_planet) ~= nil then
                    decided_planet = selected_planet
                end
            end

            if dig_up_unit.Get_Planet_Location() ~= decided_planet then
                decided_planet = nil
            end

            player.Lock_Tech(dig_up_unit_type)
        else 
            decided_planet = nil
        end


        if selected_planet == decided_planet then
            player.Unlock_Tech(research_unit_type)
        else 
            player.Lock_Tech(research_unit_type)
        end

        DebugMessage("Latest Planet for cooldown: %s", tostring(GlobalValue.Get("Last_Planet")))

        if GlobalValue.Get("Last_Planet") ~= 0 then

            Set_Planet_On_Cooldown(Find_First_Object(GlobalValue.Get("Last_Planet")))

            GlobalValue.Set("Last_Planet", 0)
        end

        Remove_Planets_From_Cooldown()

        event.Clear_Dialog_Text()

        event.Add_Dialog_Text("Artifacts Needed for Tech Level " .. tostring(player.Get_Tech_Level() + 1) .. ": " .. tostring(GlobalValue.Get("Artifacts_Dug")) .. "/" .. tostring(Artifacts_Needed()))

        if dig_up_unit ~= nil and TestValid(decided_planet) then
            event.Add_Dialog_Text("Location to Research the Dug Up Artifact: " .. tostring(Capital_First_Letter(decided_planet.Get_Type().Get_Name())))
        end

        event.Add_Dialog_Text("Planets with Known Artifacts: ")

        event.Add_Dialog_Text("") 
        
        for planet, cooldown in pairs(planet_cooldown_table) do

            yes_or_no = "Yes"

            DebugMessage("Planet cooldown: %s, %s", tostring(planet), tostring(cooldown["cooldown"]))

            if cooldown["cooldown"] then
                yes_or_no = "No"
            end

            event.Add_Dialog_Text(Capital_First_Letter(planet) .. ": " .. yes_or_no)
        end

        if on_cooldown then
            event.Clear_Dialog_Text()

            event.Add_Dialog_Text("Artifact Discoveries are currently are not available.")

            event.Add_Dialog_Text("Day when Artifact Discoveries are available: " .. tostring(last_artifact_researched + artifact_dig_cooldown))

            event.Add_Dialog_Text("")

            event.Add_Dialog_Text("Artifacts Needed for Tech Level " .. tostring(player.Get_Tech_Level() + 1) .. ": " .. tostring(GlobalValue.Get("Artifacts_Dug")) .. "/" .. tostring(Artifacts_Needed()))
        end

        next_tech_upgrade = tech_level_object_types[player.Get_Tech_Level()]

        if GlobalValue.Get("Artifacts_Dug") >= Artifacts_Needed() and (not next_tech_researched) and not tech_up_available then

            valid_unlock = true

            if player.Get_Tech_Level() == 4 then
                hwd = Find_First_Object("Covenant_Heavy_Weapons")
                
                if hwd == nil then
                    valid_unlock = false
                end
            end

            if valid_unlock then

                player.Unlock_Tech(next_tech_upgrade)

            end

            event.Clear_Dialog_Text()

            event.Add_Dialog_Text("Artifacts Needed for Tech Level: " .. tostring(player.Get_Tech_Level() + 1) .. ": All Researched, Check any planet with a Research Facility to Research the Next Tech!")

            player.Lock_Tech(dig_up_unit_type)

            player.Lock_Tech(research_unit_type)

            Game_Message("Artifact Researched, Check Artifact Display")

            tech_up_available = true
        end

        if tech_up_available then
            event.Clear_Dialog_Text()

            event.Add_Dialog_Text("Artifacts Needed for Tech Level: " .. tostring(player.Get_Tech_Level() + 1) .. ": All Researched, Check any planet with a Research Facility to Research the Next Tech!")

            player.Lock_Tech(dig_up_unit_type)

            player.Lock_Tech(research_unit_type)
        end

        next_Tech = Find_First_Object(next_tech_upgrade.Get_Name())

        if next_Tech ~= nil then
            next_tech_researched = true

            GlobalValue.Set("Artifacts_Dug", 0)

            tech_up_available = false
        end

    end
end

function Artifacts_Needed()
    tech_level = player.Get_Tech_Level()

    req_table = {2,3,4,5}

    return req_table[tech_level]
end

function Is_Planet_On_Cooldown(planet_name)
    if planet_cooldown_table[string.lower(planet_name)] ~= nil then
        DebugMessage("Planet: %s is on cooldown: %s", tostring(planet_name), tostring(planet_cooldown_table[string.lower(planet_name)]["cooldown"]))
        return planet_cooldown_table[string.lower(planet_name)]["cooldown"]
    end
end

function Set_Planet_On_Cooldown(planet)
    input_planet_name = string.lower(planet.Get_Type().Get_Name())

    DebugMessage("Planet for cooldown: %s", tostring(input_planet_name))

    for planet_to_check, _ in pairs(planet_cooldown_table) do
        if string.lower(planet_to_check) == input_planet_name then
            DebugMessage("Planet is on cooldown, Week for cooldown: %s", tostring(Get_Current_Week()))
            planet_cooldown_table[planet_to_check]["cooldown"] = true
            planet_cooldown_table[planet_to_check]["cooldown_week"] = Get_Current_Week()
            return cooldown
        end
    end
end

function Remove_Planets_From_Cooldown()
    local cooldown_time = 1 -- how many days/weeks

    for planet, cooldown_info in pairs(planet_cooldown_table) do
        if cooldown_info["cooldown"] then
            DebugMessage("%s Cooldown Start: %s, End Time: %s, Current Week: %s", tostring(planet), tostring(cooldown_info["cooldown_week"]), tostring(cooldown_info["cooldown_week"] + cooldown_time), tostring(Get_Current_Week()))
            if (cooldown_info["cooldown_week"] + cooldown_time) <= Get_Current_Week() then
                DebugMessage("%s is no longer on cooldown", tostring(planet))
                planet_cooldown_table[planet]["cooldown"] = false
            end
        end
    end
end

function Find_Research_Faciltiy_on_Planet(planet)
    all_research_stations = Find_All_Objects_Of_Type("COVN_RESEARCH_FACILITY")

    for _, station in pairs(all_research_stations) do
        if station.Get_Planet_Location() == planet then
            return station
        end
    end

    return nil
end

function Get_Selected_Planet()

    player = Find_Human_Player()

    local planets = FindPlanet.Get_All_Planets()

    for _,planet in pairs(planets) do

        flag_name = "ARTIFACT_PLAYER_SELECTED_" .. string.upper(planet.Get_Type().Get_Name())
        --DebugMessage("Checking Planet: %s", flag_name)
        if Check_Story_Flag(player, flag_name, nil, true) then
            DebugMessage("Found Selected Planet: %s", planet.Get_Type().Get_Name())
            return planet
        end
    end
end