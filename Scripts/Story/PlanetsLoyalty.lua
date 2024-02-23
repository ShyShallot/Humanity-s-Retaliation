require("PGStateMachine")
require("HALOFunctions")
require("PGBaseDefinitions")
require("HALOFunctions") 

function Definitions()
    ServiceRate = 1
	Define_State("State_Init", State_Init);

    planet_loyaltly_table = { --[[ 1 means its fully loyal to UNSC/Covenant, 0 means its loyal to Rebels/Banished --]]
        
    }

    human = Find_Human_Player()

    last_runtime = GetCurrentTime()
	
end

function State_Init(message)
    if message == OnEnter then
        last_runtime = GetCurrentTime()
        local planets = FindPlanet.Get_All_Planets()

        for i,planet in ipairs(planets) do
            planet_loyaltly_table[planet.Get_Type().Get_Name()] = {
                ["Owner"] = planet.Get_Owner().Get_Faction_Name(),
                ["Loyalty"] = 1.0,
                ["Farm_Mission"] = false
            }
        end
        Sleep(60)
        Loyalty_Display()
        Story_Event("ACTIVATE_LOYALTY_DISPLAY")
    end
    if message == OnUpdate then
        Loyalty_Display()
    end
end

function Get_Loyalty_Table()
    return planet_loyaltly_table
end

function Is_Valid_Entry(planet_name)
    local loyalty = planet_loyaltly_table[planet_name]["Loyalty"]
    if loyalty == nil then
        return false
    end
    return true
end

function Get_Planet_Loyalty(planet_name)
    loyalty = planet_loyaltly_table[planet_name]["Loyalty"]
    if loyalty == nil then
        return -1
    end
    return loyalty
end

function Modify_Planet_Loyalty(planet_name, positive_or_negative)

    local amount = 0.1 -- when positive_or_negative is true
    if not positive_or_negative then -- if negative
        amount = -0.1
    end
    if Is_Valid_Entry(planet_name) then
        if planet_loyaltly_table[planet_name]["Owner"] == "Terrorists" or planet_loyaltly_table[planet_name]["Owner"] == "Swords" then
            planet_loyaltly_table[planet_name]["Loyalty"] = 1
            return
        end
        local loyalty = planet_loyaltly_table[planet_name]["Loyalty"]
        if (loyalty + amount) > 1 or (loyalty + amount) < 0 then
            return
        end
        planet_loyaltly_table[planet_name]["Loyalty"] = loyalty + amount
    end
end

function Change_Planet(planet_name)
    local terrorists = Find_Player("TERRORISTS")
    local swords = Find_Player("SWORDS")
    local planet_owner = planet_loyaltly_table[planet_name]["Owner"]
    local planet = Find_First_Object(planet_name)
    if not TestValid(planet) then
        return
    end
    if planet_owner == "REBEL" then
        planet.Change_Owner(terrorists)
        terror_units = {
            ["TERROR_STARBASE_2"] = 1,
            ["TERROR_HALCYON"] = 1,
            ["TERROR_STALWART"] = 2,
            ["TERROR_MAKO"] = 2
        }

        Spawn_UnitList(terrorists, terror_units, planet)
    elseif planet_owner == "EMPIRE" then
        planet.Change_Owner(swords)
        swords_units = {
            ["SWORDS_STARBASE_2"] = 1,
            ["SWORDS_CCS"] = 1,
            ["SWORDS_CRS"] = 2,
            ["SWORDS_SDV"] = 2
        }

        Spawn_UnitList(swords, swords_units, planet)
    end
end

function Spawn_UnitList(faction, units, location)
    for unit_name, amount in ipairs(units) do
        for x=amount, 1, -1 do
            new_units = Spawn_Unit(Find_Object_Type(unit_name),location,faction)
            if new_units ~= nil then
                for _, unit in ipairs(new_units) do
                    unit.Prevent_AI_Usage(false)
                end
            end
        end
    end
end

function Loyalty_Display()


    plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Loyalty_Display.xml")
    event = plot.Get_Event("Loyalty_Display")
    event.Clear_Dialog_Text()
    event.Add_Dialog_Text("Current Planet Power Requirement: " .. tostring(formatNumberWithCommas(Tech_Power_Upkeep(Find_Human_Player()))))
    event.Add_Dialog_Text(" ")
    local planets = FindPlanet.Get_All_Planets()

    for i,planet in ipairs(planets) do
        local planet_name = planet.Get_Type().Get_Name()
        local planet_loyalty = planet_loyaltly_table[planet_name]
        if planet_loyalty["Owner"] == "REBEL" or planet_loyalty["Owner"] == "EMPIRE" then
            if planet_loyalty["Owner"] == "REBEL" then
                if TestValid(Find_Farm_On_Planet(planet_name) and planet_loyalty["Farm_Mission"]) then
                    DebugMessage("Planet %s has a farm", tostring(planet_name))
                    Modify_Planet_Loyalty(planet_name,true)
                elseif (not TestValid(Find_Farm_On_Planet(planet_name)) and planet_loyalty["Farm_Mission"]) then
                    DebugMessage("Planet %s is missing a farm, Mission: %s", tostring(planet_name), tostring(planet_loyalty["Farm_Mission"]))
                    Modify_Planet_Loyalty(planet_name,false)
                end
            end
            local planet_units = Get_Units_At_Planet(planet_name, planet.Get_Owner())
            if not (planet_units == nil) then
                DebugMessage("Power: %s, Upkeep: %s", tostring(Combat_Power_From_List(planet_units)), tostring(Tech_Power_Upkeep(planet.Get_Owner())))
                if Combat_Power_From_List(planet_units) < (Tech_Power_Upkeep(planet.Get_Owner())) then
                    DebugMessage("Combat Power is less than Upkeep for planet: %s", tostring(planet_name))
                    Modify_Planet_Loyalty(planet_name, false)
                end
                if planet.Get_Owner().Is_Human() then
                    event.Add_Dialog_Text(tostring(Capital_First_Letter(planet_name)) .. "'s Loyalty: " .. tostring(planet_loyalty["Loyalty"] * 100) .. tostring("%%") .. ", Power: " .. tostring(formatNumberWithCommas(Combat_Power_From_List(planet_units))))
                    event.Add_Dialog_Text(" ")
                end
            end
        end
    end

    Sleep(60)
end

function Capital_First_Letter(name)
    strings = split(name, "_")
    final_string = ""
    for i, word in split(name, "_") do
        first_letter = string.sub(word,1,1)
        final_string = final_string .. first_letter .. string.lower(string.sub(word, 2, string.len(word))) .. " "
    end
    return final_string
end

function Find_Farm_On_Planet(planet)
    local farms = Find_All_Objects_Of_Type("UNSC_FARM")
    local found_farm = nil
    for _, farm in ipairs(farms) do
        if farm.Get_Planet_Location().Get_Type().Get_Name() == planet then
            found_farm = farm
            break
        end 
    end
    return found_farm
end

function Get_Units_At_Planet(planet_name, player)
    if not player.Get_Faction_Name() == "REBEL" or not player.Get_Faction_Name() == "EMPIRE" then
        return nil
    end
    local all_player_units = Find_All_Objects_Of_Type(player, "Fighter | Bomber | Corvette | Frigate | Capital | Super")
    planet_units = {}
    for _, unit in ipairs(all_player_units) do
        if TestValid(unit) then
            if TestValid(unit.Get_Planet_Location()) then
                if unit.Get_Planet_Location().Get_Type().Get_Name() == planet_name then
                    table.insert(planet_units,unit)
                end
            end
        end
    end
    return planet_units
end

function Tech_Power_Upkeep(player)
    if player.Get_Faction_Name() == "REBEL" then
        return 3000 * (player.Get_Tech_Level() + 1)
    else 
        return 3000 * player.Get_Tech_Level()
    end
end