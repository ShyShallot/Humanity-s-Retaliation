require("PGStateMachine")
require("HALOFunctions")
require("PGBaseDefinitions")
require("HALOFunctions") 


function Definitions()
    ServiceRate = 1
	Define_State("State_Init", State_Init);
    Define_State("State_Rescue", State_Rescue)

    hero_alive_table = {
        ["COVN_MACCABEUS"] = false,
        ["COVN_ARDO"] = false,
        ["COVN_JUL"] = false,
        ["COVN_PIOUS"] = false
    }

    hero_name_table = {
        ["COVN_MACCABEUS"] = "Shipmaster Maccabeus",
        ["COVN_ARDO"] = "General Ardo 'Moretumee",
        ["COVN_JUL"] = "Shipmaster Jul 'Mdama",
        ["COVN_PIOUS"] = "Fleetmaster Nizat 'Kvarosee"
    }

    mission = {}
    mission.active = false
    mission.unit = nil

    respawn_days = 3
    respawn_time = 60 * respawn_days

end

function State_Init(message)
    if message == OnEnter then
        Set_Next_State("State_Rescue")
    end
end

function State_Rescue(message)
    if message == OnUpdate then

        for hero, isAlive in pairs(hero_alive_table) do

            Sleep(respawn_time)

            local player = Find_Human_Player()

            local is_hero_alive = EvaluatePerception(hero.."_Alive", player)

            DebugMessage("Perception: " .. tostring(hero) .. "_Alive" .. " Result: " .. tostring(is_hero_alive) .. ", Table Value: " .. tostring(isAlive) .. ", Is Mission Active: " .. tostring(mission.active))

            if is_hero_alive == 0 and isAlive and mission.active == false and Get_Current_Week_Raw() > 0.2 then

                local prison_planet = Select_Prison_Planet()

                DebugMessage("Prison Planet is: %s", tostring(prison_planet.Get_Type().Get_Name()))

                DebugMessage("Hero to Rescue: %s", tostring(hero))

                if (prison_planet == nil) then
                    return
                end

                hero_alive_table[hero] = false

                mission.active = true
                mission.unit = hero

                local plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Rescue_Hero.xml")

                local event = plot.Get_Event("Rescue_Major_Hero_Dialog")

                event.Clear_Dialog_Text()

                event.Add_Dialog_Text("Hero to Rescue: " .. hero_name_table[hero])

                event.Add_Dialog_Text("Target Planet: %s", tostring(prison_planet.Get_Type().Get_Name()))

                event = plot.Get_Event("Rescue_Majar_Hero_Mission")

                event.Set_Event_Parameter(0, prison_planet)

                event.Set_Reward_Parameter(0, hero)

                Story_Event("Rescue_Major_Hero_Activate")
            end

            if not isAlive and is_hero_alive == 1 then
                DebugMessage("Hero: " .. hero .. ", Is Alive from Perception but not table")
                hero_alive_table[hero] = true
            end

            if hero_alive_table[hero] and (mission.unit == hero) and mission.active then
                mission.unit = nil
                mission.active = false
            end
        end
    end
end

function Select_Prison_Planet()
    local all_planets = FindPlanet.Get_All_Planets()

    local planet_power_table = {}


    for _, planet in pairs(all_planets) do

        if planet.Get_Owner().Get_Faction_Name() == Opposite_Faction() then
            local planet_units = Get_Units_At_Planet(planet.Get_Type().Get_Name(), planet.Get_Owner())

            if table.getn(planet_units) > 0 then
                local combat_power = Combat_Power_From_List(planet_units)
                DebugMessage("Combat Power On Planet %s: %s", tostring(planet.Get_Type().Get_Name()), tostring(combat_power))
                planet_power_table[planet] = combat_power
            end
        end
    end

    local power_table_sum = 0

    for planet, power in pairs(planet_power_table) do
        power_table_sum = power_table_sum + power
    end
    
    DebugMessage("Power Table Sum: %s", tostring(power_table_sum))

    if power_table_sum == 0 then
        return
    end

    local num_of_entries = tableLength(planet_power_table)

    local power_table_avg = power_table_sum/num_of_entries

    DebugMessage("Power Table Avg: %s, Num of Entries: %s", tostring(power_table_avg),tostring(num_of_entries))

    local smallestDif = {}
    smallestDif.planet = nil
    smallestDif.value = 1000000

    for planet, power in pairs(planet_power_table) do
        DebugMessage("Planet: %s, Power: %s", tostring(planet.Get_Type().Get_Name()), tostring(power))
        local diff = abs(power_table_avg - power)
        DebugMessage("Power Table Avg: %s, Planet Power: %s, Planet Avg Diff: %s", tostring(power_table_avg), tostring(power), tostring(diff))
        DebugMessage("Is %s smaller than %s: %s", tostring(diff), tostring(smallestDif.value), tostring(diff < smallestDif.value))
        if diff < smallestDif.value then
            smallestDif.planet = planet
            smallestDif.value = diff
        end
    end

    DebugMessage("Prison Planet is: %s", tostring(smallestDif.planet.Get_Type().Get_Name()))

    return smallestDif.planet
end

function Get_Units_At_Planet(planet_name, player)

    if not player.Get_Faction_Name() == "REBEL" or not player.Get_Faction_Name() == "EMPIRE" then
        return nil
    end

    local all_player_units = Find_All_Objects_Of_Type(player, "Fighter | Bomber | Corvette | Frigate | Capital | Super")
    local planet_units = {}
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

function Opposite_Faction()
    local human = Find_Human_Player()

    if human.Get_Faction_Name() == "REBEL" then
        return "EMPIRE"
    end

    return "REBEL"
end