require("PGStateMachine")
require("HALOFunctions")
require("PGBaseDefinitions")
require("HALOFunctions") 
require("PlanetNameTable")

function Definitions()
    ServiceRate = 0.5
	Define_State("State_Init", State_Init);
    Define_State("State_Loyalty", State_Loyalty)

    planet_loyalty_table = { --[[ 1 means its fully loyal to UNSC/Covenant, 0 means its loyal to Rebels/Banished --]]
        
    }

    last_week = 0

    last_selected_planet = nil
	
end

function State_Init(message)
    if message == OnEnter then

        GlobalValue.Set("Farms_Unlocked", 0)

        human = Find_Human_Player()

        local planets = FindPlanet.Get_All_Planets()

        plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Loyalty_Display.xml")

        for i,planet in ipairs(planets) do

            select_event = plot.Get_Event("SELECT_"..planet.Get_Type().Get_Name())

            select_event.Set_Reward_Parameter(1, human.Get_Faction_Name())

            planet_loyalty_table[planet.Get_Type().Get_Name()] = {
                ["Owner"] = planet.Get_Owner().Get_Faction_Name(),
                ["LastOwner"] = nil,
                ["Loyalty"] = 100,
                ["PrevLoyalty"] = 100,
                ["Farm"] = false
            }
        end
        Story_Event("ACTIVATE_LOYALTY_DISPLAY")
        unsc = Find_Player("REBEL")
        unsc.Lock_Tech(Find_Object_Type("UNSC_FARM"))

        Set_Next_State("State_Loyalty")
    end
end

function Get_Loyalty_Table()
    return planet_loyalty_table
end

function Is_Valid_Entry(planet_name)

    if planet_name == nil or planet_loyalty_table[planet_name] == nil then
        return false
    end

    local loyalty = planet_loyalty_table[planet_name]["Loyalty"]
    if loyalty == nil then
        return false
    end
    return true
end

function Get_Planet_Loyalty(planet_name)
    if planet_name == nil or planet_loyalty_table[planet_name] == nil then
        return false
    end

    loyalty = planet_loyalty_table[planet_name]["Loyalty"]
    if loyalty == nil then
        return -1
    end
    return loyalty
end

function Modify_Planet_Loyalty(planet_name, positive_or_negative, multiplier)

    if multiplier == nil then
        multiplier = 1
    end
    
    local amount = 10 * abs(multiplier) -- when positive_or_negative is true
    if not positive_or_negative then -- if negative
        amount = -10 * abs(multiplier)
    end
    if Is_Valid_Entry(planet_name) then
        planet_entry = planet_loyalty_table[planet_name]
        next_loyalty = planet_entry["Loyalty"] + amount

        if (next_loyalty > 100) then
            next_loyalty = 100
        end
        if (next_loyalty < 0) then
            next_loyalty = 0
        end
        planet_loyalty_table[planet_name]["PrevLoyalty"] = planet_entry["Loyalty"]
        planet_loyalty_table[planet_name]["Loyalty"] = next_loyalty
    end
end


function Change_Planet(planet_name)
    if not Is_Valid_Entry(planet_name) then
        return
    end
    local terrorists = Find_Player("TERRORISTS")
    local swords = Find_Player("SWORDS")
    local planet_owner = planet_loyalty_table[planet_name]["Owner"]
    local planet = Find_First_Object(planet_name)
    if not TestValid(planet) then
        return
    end
    if planet_owner == "NEUTRAL" then -- instead of having to write more functions and more code, this is a faster solution, hopefuly this executes fast enough the player wont notice
        neighbor_prop = Get_Neighbor_Faction_Average(planet)
        if neighbor_prop >= 0.5 then
            planet.Change_Owner(Find_Player("EMPIRE"))
        else 
            planet.Change_Owner(Find_Player("REBEL"))
        end
    end

    if planet_owner == "REBEL" then
        planet.Change_Owner(terrorists)
        terror_units = {
            ["TERROR_HALCYON"] = 1,
            ["TERROR_STALWART"] = 2,
            ["TERROR_MAKO"] = 2
        }
        Spawn_Unit(Find_Object_Type("Terrorists_Star_Base_2"), planet,terrorists)
        Spawn_UnitList(terrorists, terror_units, planet)
        Change_Planet_Owner(terrorists.Get_Faction_Name(),planet_name)
    elseif planet_owner == "EMPIRE" then
        planet.Change_Owner(swords)
        swords_units = {
            ["SWORDS_CCS"] = 1,
            ["SWORDS_CRS"] = 2,
            ["SWORDS_SDV"] = 2
        }
        Spawn_Unit(Find_Object_Type("SWORDS_STARBASE_2"), planet,swords)
        Spawn_UnitList(swords, swords_units, planet)
        Change_Planet_Owner(swords.Get_Faction_Name(), planet_name)
    end

    planet_loyalty_table[planet_name]["Loyalty"] = 100
    planet_loyalty_table[planet_name]["PrevLoyalty"] = 100
    
end

function Spawn_UnitList(faction, units, location)
    for unit_name, amount in pairs(units) do
        DebugMessage("Unit: %s, Amount %s for Faction: %s", tostring(unit_name),tostring(amount), tostring(faction.Get_Faction_Name()))
        if amount < 1 then
            break
        end
        for x=amount, 1, -1 do
            new_units = Spawn_Unit(Find_Object_Type(unit_name),location,faction)
            if new_units ~= nil then
                for _, unit in pairs(new_units) do
                    unit.Prevent_AI_Usage(false)
                end
            end
        end
    end
end

function State_Loyalty(message)
    if message == OnUpdate then

        Unlock_Farms()

        DebugMessage("Current Week: %s, Raw Week: %s, Last Week: %s", tostring(Get_Current_Week()),tostring(Get_Current_Week_Raw()),tostring(last_week))

        last_selected_planet = selected_planet

        selected_planet = Get_Selected_Planet()

        DebugMessage("Selected Planet: %s", tostring(selected_planet))

        if selected_planet ~= nil then
            local selected_planet_name = selected_planet.Get_Type().Get_Name()
            local planet_loyalty = planet_loyalty_table[selected_planet_name]
            if TestValid(selected_planet) and (last_selected_planet ~= selected_planet) and Is_Valid_Entry(selected_planet_name) then
                local planet_units = Get_Units_At_Planet(selected_planet_name, selected_planet.Get_Owner())
                if not (planet_units == nil) then
                    if Has_Custom_Name(selected_planet_name) then
                        text = tostring(Get_Cus_Name(selected_planet_name)) .. "'s Loyalty: " .. tostring(planet_loyalty["Loyalty"]) .. tostring("%") .. ", Yesterday's Loyalty: " ..tostring(planet_loyalty["PrevLoyalty"]) .. tostring("%")
                    else
                        text = tostring(Capital_First_Letter(selected_planet_name)) .. "'s Loyalty: " .. tostring(planet_loyalty["Loyalty"]) .. tostring("%") .. ", Yesterday's Loyalty: " ..tostring(planet_loyalty["PrevLoyalty"]) .. tostring("%")
                    end
                    
                    if selected_planet.Get_Owner().Is_Human() then
                        text = text .. ", Power: " .. tostring(formatNumberWithCommas(Combat_Power_From_List(planet_units))) .. " / " .. tostring(formatNumberWithCommas(Tech_Power_Upkeep(Find_Human_Player())))
                    else 
                        text = text .. ", Power: Unknown"
                    end
                    Show_Screen_Text(text,3, nil, false)
                end
            end
        end

        plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Loyalty_Display.xml")
        event = plot.Get_Event("Loyalty_Display")
        event.Clear_Dialog_Text()
        --event.Add_Dialog_Text("Current Planet Power Requirement: " .. tostring(formatNumberWithCommas(Tech_Power_Upkeep(Find_Human_Player()))))
        --event.Add_Dialog_Text(" ")

        if Get_Current_Week() < 1 then
            --local planets = FindPlanet.Get_All_Planets()
            --
            --for i,planet in ipairs(planets) do
            --    local planet_name = planet.Get_Type().Get_Name()
            --    local planet_loyalty = planet_loyalty_table[planet_name]
            --    if planet.Get_Owner().Is_Human() then
            --        local planet_units = Get_Units_At_Planet(planet_name, planet.Get_Owner())
            --        if not (planet_units == nil) then
            --            event.Add_Dialog_Text(tostring(Capital_First_Letter(planet_name)) .. "'s Loyalty: " .. tostring(planet_loyalty["Loyalty"]) .. tostring("%%") .. ", Yesterday's Loyalty: " ..tostring(planet_loyalty["PrevLoyalty"]) .. tostring("%%") .. ", Power: " .. tostring(formatNumberWithCommas(Combat_Power_From_List(planet_units))))
            --            event.Add_Dialog_Text(" ")
            --        end
            --    end
            --end
            return
        end

        if last_week >= Get_Current_Week() then
            return
        end

        local planets = FindPlanet.Get_All_Planets()

        for i,planet in ipairs(planets) do
            local planet_name = planet.Get_Type().Get_Name()
            local planet_loyalty = planet_loyalty_table[planet_name]

            DebugMessage("Current Planet: %s", tostring(planet_name))

            if not (planet_loyalty == nil) then

                local last_owner = Change_Planet_Owner(planet.Get_Owner().Get_Faction_Name(), planet_name) -- make sure planet owner is up to date

                if last_owner ~= planet_loyalty_table[planet_name]["Owner"] then -- reset loyalty on owner change
                    planet_loyalty_table[planet_name]["Loyalty"] = 100
                    planet_loyalty_table[planet_name]["PrevLoyalty"] = 100
                end

                if planet_loyalty["Owner"] == "REBEL" or planet_loyalty["Owner"] == "EMPIRE" then
                    if planet_loyalty["Owner"] == "REBEL" then
                        Does_Planet_Have_Farm = Find_Farm_On_Planet(planet_name)
                        if TestValid(Does_Planet_Have_Farm and Farms_Active(planet.Get_Owner())) then
                            DebugMessage("Planet %s has a farm", tostring(planet_name))
                            Modify_Planet_Loyalty(planet_name,true)
                        elseif (not TestValid(Does_Planet_Have_Farm) and Farms_Active(planet.Get_Owner())) then
                            DebugMessage("Planet %s is missing a farm, Are Farms Active?: %s", tostring(planet_name), tostring(Farms_Active(planet.Get_Owner())))
                            Modify_Planet_Loyalty(planet_name,false)
                        end
                    end
                    if Are_Neighbors_Majority_Enemy(planet_loyalty["Owner"],planet) then
                        Modify_Planet_Loyalty(planet_name,false,0.5)
                    end
                    local planet_units = Get_Units_At_Planet(planet_name, planet.Get_Owner())
                    DebugMessage("Planet Name: %s", tostring(planet_name))
                    if not (planet_units == nil) then
                        DebugMessage("Planet: %s, Power: %s, Upkeep: %s", tostring(planet_name), tostring(Combat_Power_From_List(planet_units)), tostring(Tech_Power_Upkeep(planet.Get_Owner())))

                        local planet_combat_power = Combat_Power_From_List(planet_units)
                        if planet_combat_power < (Tech_Power_Upkeep(planet.Get_Owner())) then
                            DebugMessage("Combat Power is less than Upkeep for planet: %s", tostring(planet_name))
                            if planet_combat_power == 0 then
                                Modify_Planet_Loyalty(planet_name, false, 1)
                            else
                                Modify_Planet_Loyalty(planet_name, false, 0.5)
                            end
                        else 
                            Modify_Planet_Loyalty(planet_name, true, 0.5)
                        end
                        if planet.Get_Owner().Is_Human() then
                            event.Add_Dialog_Text(tostring(Capital_First_Letter(planet_name)) .. "'s Loyalty: " .. tostring(planet_loyalty["Loyalty"]) .. tostring("%%") .. ", Yesterday's Loyalty: " ..tostring(planet_loyalty["PrevLoyalty"]) .. tostring("%%") .. ", Power: " .. tostring(formatNumberWithCommas(Combat_Power_From_List(planet_units))))
                            event.Add_Dialog_Text(" ")
                        end
                    end
                    if planet_loyalty["Loyalty"] <= 0 then
                        Planet_Lost_Sound(planet_loyalty["Owner"])
                        if planet.Get_Owner().Is_Human() then
                            Game_Message("We Lost " .. planet_name .. " due to a lack of Loyalty!")
                        end
                        Change_Planet(planet_name)
                    end
                end
                if planet_loyalty["Owner"] == "NEUTRAL" then
                    Modify_Planet_Loyalty(planet_name,false,0.4)

                    if planet_loyalty["Loyalty"] <= 0 and planet_loyalty["Owner"] == "NEUTRAL" then
                        Change_Planet(planet_name)
                    end
                end
            end
        end
        
        Game_Message("Planet Loyalty Updated, Check Mission Log")

        last_week = Get_Current_Week()
    end
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
    if not player.Get_Faction_Name() == "REBEL" or not player.Get_Faction_Name() == "EMPIRE" then -- this is kinda pointless but we dont want to support minor factions so its just a percaution
        return nil
    end
    local all_player_units = Find_All_Objects_Of_Type(player, "Fighter | Bomber | Corvette | Frigate | Capital | Super") -- get any meaningful unit owned by the input'd player
    planet_units = {}
    for _, unit in ipairs(all_player_units) do
        if TestValid(unit) then
            if TestValid(unit.Get_Planet_Location()) then -- make sure the unit isnt moving pretty much
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

function Farms_Active(player)
    offset = 0
    if player.Get_Faction_Name() == "REBEL" then
        offset = 1
    end
    if player.Get_Tech_Level() >= (2 - offset) then
        return true
    end
    return false
end

function Unlock_Farms()
    local rebel = Find_Player("REBEL")
    if Farms_Active(rebel) then
        Lock_Unit("UNSC_FARM",rebel,false)
        Story_Event("Farms_Unlocked")

        GlobalValue.Set("Farms_Unlocked", 1)
    end
end

function Get_Path_To_Target_Planet(target_planet) -- Only checks for neighbor, could rename but meh
    local target_planet_name = target_planet.Get_Type().Get_Name()

    local all_planets = FindPlanet.Get_All_Planets()

    for _,planet in pairs(all_planets) do
        --DebugMessage("Start Planet: %s, End Planet: %s", tostring(target_planet_name), tostring(planet_name))

        found_path = Find_Path(target_planet.Get_Owner(),target_planet,planet) -- Find Planet Table, includes start and end planets at beginning and end respectivly 
        --PrintTable(found_path)
        if table.getn(found_path) == 2 then
            --DebugMessage("Path is equal to 2")
            return found_path
        end
    end
end

function Get_Neighbors(target_planet)
    local target_planet_name = target_planet.Get_Type().Get_Name()

    local all_planets = FindPlanet.Get_All_Planets()

    local neighbors = {}

    for _,planet in pairs(all_planets) do
        --DebugMessage("Start Planet: %s, End Planet: %s", tostring(target_planet_name), tostring(planet_name))

        found_path = Find_Path(target_planet.Get_Owner(),target_planet,planet) -- Find Planet Table, includes start and end planets at beginning and end respectivly 
        --PrintTable(found_path)
        if table.getn(found_path) == 2 then -- planet is not a neighbor if there are than 2 planets (start and end) in the list
            table.insert(neighbors,found_path[2])
        end
    end

    return neighbors
end

function Get_Neighbor_Faction_Average(target_planet) -- the closer to 1 this value is, the more empire controlled neighbors there are
    -- so 0.5 is even, 0 is fully rebel neighbors, 1 is full empire neighbos, we are ignoring sub factions on purpose
    local neighbors = Get_Neighbors(target_planet)

    local neighbor_statistics = {
        ["EMPIRE"] = 0,
        ["REBEL"] = 0
    }

    for _,neighbor in pairs(neighbors) do 
        neighbor_owner = neighbor.Get_Owner().Get_Faction_Name()
        if neighbor_owner == "EMPIRE" or neighbor_owner == "REBEL" then
            neighbor_statistics[neighbor_owner] = neighbor_statistics[neighbor_owner] + 1
        end
    end

    if neighbor_statistics["EMPIRE"] == 0 and neighbor_statistics["REBEL"] == 0 then
        return 0
    end

    local proportion = neighbor_statistics["EMPIRE"] / (neighbor_statistics["REBEL"] + neighbor_statistics["EMPIRE"])

    return proportion

end

function Are_Neighbors_Majority_Enemy(faction_name, target_planet)
    local neighbor_average = Get_Neighbor_Faction_Average(target_planet)

    if (faction_name == "REBEL" and neighbor_average <= 0.5) then
        return false
    elseif (faction_name == "REBEL" and neighbor_average > 0.5) then
        return true
    end

    if (faction_name == "EMPIRE" and neighbor_average >= 0.5) then
        return false
    elseif (faction_name == "EMPIRE" and neighbor_average < 0.5) then
        return true
    end
end

function Planet_Lost_Sound(faction_name)
    if faction_name == "REBEL" then
        Story_Event("Planet_Lost_Sound_Rebel")
    end
    Story_Event("Planet_Lost_Sound_Empire")
end

function Change_Planet_Owner(faction_name, planet_name)
    planet_loyalty_table[planet_name]["LastOwner"] = planet_loyalty_table[planet_name]["Owner"]
    planet_loyalty_table[planet_name]["Owner"] = faction_name

    return planet_loyalty_table[planet_name]["LastOwner"]
end

function Show_Screen_Text(text, time_to_show, color, teletype) -- inspired by the Thrawns Revenge Team but slightly modified to fit our purpose
    local plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Loyalty_Display.xml")
    local text_event = plot.Get_Event("Show_Screen_Text")

    local colorstring = ""
    if color then
        colorstring = color.r .. " " .. color.g .. " " .. color.b 
    end

    local use_teletype = 1
    if teletype == false then
        use_teletype = 0
    end

    text_event.Set_Reward_Parameter(0,text)
    text_event.Set_Reward_Parameter(1,tostring(time_to_show)) -- time in seconds
    text_event.Set_Reward_Parameter(2, "") -- parameter we dont care about
    text_event.Set_Reward_Parameter(3, "")
    text_event.Set_Reward_Parameter(4, use_teletype) -- whether or not the text is slowly typed out or is just shown
    text_event.Set_Reward_Parameter(5, colorstring) -- for color
    Story_Event("SHOW_SCREEN_TEXT")
end

function Get_Selected_Planet()

    local player = Find_Human_Player()

    local planets = FindPlanet.Get_All_Planets()

    for _,planet in pairs(planets) do

        flag_name = "PLAYER_SELECTED_" .. string.upper(planet.Get_Type().Get_Name())
        --DebugMessage("Checking Planet: %s", flag_name)
        if Check_Story_Flag(player, flag_name, nil, true) then
            DebugMessage("Found Selected Planet: %s", planet.Get_Type().Get_Name())
            return planet
        end
    end

    return nil

end