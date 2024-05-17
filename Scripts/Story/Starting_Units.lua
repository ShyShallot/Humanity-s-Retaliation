require("PGStoryMode")
require("PGStateMachine")
require("HALOFunctions")
require("PGBase")
function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
    StoryModeEvents =
    {
        Universal_Story_Start = Global_Story
    }

end

-- Yes this code is similar to AOTR, i used it as a base for the most part and how things are done are based off of aotr, 
--i thank them for the original idea

function Story_Mode_Service()

end

function Global_Story(message)
    if  message == OnEnter then 
        planets = FindPlanet.Get_All_Planets()

        rebelPlanets = {}

        empirePlanets = {}

        swordsPlanets = {}

        for i, planet in pairs(planets) do
            if planet.Get_Owner().Get_Faction_Name() == "REBEL" then
                rebelPlanets[i] = planet
            elseif planet.Get_Owner().Get_Faction_Name() == "EMPIRE" then 
                empirePlanets[i] = planet
            end
        end

        starting_units_rebel = { -- max count, these will be spread across the various planets
            ["UNSC_HALCYON"] = 5,
            ["UNSC_PARIS"] = 8,
            ["UNSC_STALWART"] = 10,
            ["Baselard_Squadron"] = 18,
            ["Shortsword_Squadron"] = 16
        }

        unsc_heros = {
            [1] = {
                "UNSC_SOF",
                "UNSC_IAC",
                "UNSC_ROMAN_BLUE"
            }
        }

        starting_units_empire = {
            ["COVN_RCS"] = 4,
            ["COVN_CRS"] = 5,
            ["COVN_CAR"] = 9,
            ["COVN_SDV"] = 10,
            ["Banshee_Squadron"] = 18,
            ["Tarasque_Squadron"] = 14

        }

        covenant_heros = {
            [1] = {
                "COVN_ARDO"
            }

        }

        Spawn_Starting_Units("Rebel",starting_units_rebel,rebelPlanets, unsc_heros)

        Spawn_Starting_Units("Empire",starting_units_empire,empirePlanets, covenant_heros)


        Lock_Vanilla_Units()

    end
end

function Spawn_Starting_Units(faction, units, locations, heros)

    player = Find_Player(faction)

    shield_tech = Find_First_Object("UNSC_Tech_Shield")

    spawned_units = {}

    total_max = 0

    for unit_name, max in pairs(units) do
        total_max = total_max + max
        spawned_units[unit_name] = 0
    end

    diff_multi_table = {
        ["Easy"] = 1.5,
        ["Normal"] = 1.0,
        ["Hard"] = 0.75
    }

    diff_multi = diff_multi_table[player.Get_Difficulty()]

    if not player.Is_Human() then
        diff_multi = 1
    end

    DebugMessage("Total Max Number of Units: %s, Number of Controlled Planets: %s", tostring(total_max), tostring(tableLength(locations)))

    planet_max = tonumber(Dirty_Floor((total_max / (tableLength(locations) / 1.5)) * diff_multi)) -- the reason for using tableLength is that using table.getn doesnt give the actual amount of elements in the array, for reasons beyond my knowledge 
    
    DebugMessage("Planet Max: %s", planet_max)

    for _, planet in pairs(locations) do
        if player.Get_Faction_Name() == "Rebel" and (not TestValid(shield_tech)) and player.Get_Tech_Level() >= 3 then -- if the unsc starts at tech 4 or 5, spawn the shield tech research at the first planet
            Spawn_Unit(Find_Object_Type("UNSC_Tech_Shield"),planet,player)
        end

        if Return_Chance(0.4) then 
            tech_level = player.Get_Tech_Level()

            if faction == "Rebel" then
                tech_level = tech_level + 1
            end

            DebugMessage("Tech Level: %s, Faction: %s", tostring(tech_level), tostring(faction))

            PrintTable(heros[tech_level])

            if heros[tech_level] ~= nil or tableLength(heros[tech_level]) > 0 then

                random_hero = EvenMoreRandom(1,tableLength(heros[tech_level]))

                DebugMessage("Hero Index: %s", tostring(random_hero))

                hero = heros[tech_level][random_hero]

                if not TestValid(Find_First_Object(hero)) and hero ~= nil then
                    new_units = Spawn_Unit(Find_Object_Type(hero), planet, player)
                    if new_units ~= nil then
                        for _, unit in pairs(new_units) do
                            unit.Prevent_AI_Usage(false)
                        end
                    end
                end
            end
        end

        for unit_name, max in pairs(units) do
            unit_type = Find_Object_Type(unit_name)

            if spawned_units[unit_name] < max then
                
                if spawned_units[unit_name] == 0 then
                    amount = EvenMoreRandom(0,tonumber(Dirty_Floor(max*0.35)))
                else 
                    amount = EvenMoreRandom(0,(max - spawned_units[unit_name]))
                end

                DebugMessage("Unit to Spawn: %s, Amount to Spawn: %s, Max: %s, Current Amount: %s, Spawning at: %s", unit_type.Get_Name(), tostring(amount), tostring(max), tostring(spawned_units[unit_name]), planet.Get_Type().Get_Name())
            end

            amount = Diff_Multiplier(amount, player)

            DebugMessage("After Diff and Planet Max: %s", tostring(amount))

            if spawned_units[unit_name] + amount > max then
                DebugMessage("Amount to spawn is Greater than max")
                amount = 0

                if spawned_units[unit_name] < max then
                    DebugMessage("Current Spawned is less than max")
                    amount = EvenMoreRandom(1,max - spawned_units[unit_name])

                    DebugMessage("Spawning %s more", tostring(amount))
                end
            end

            planet_units = tableLength(Get_Units_At_Planet(planet.Get_Type().Get_Name(),player))

            if amount > (planet_max - planet_units) then
                amount = EvenMoreRandom(1,planet_max - planet_units)
            end

            DebugMessage("Amount of Units Already on the planet: %s", tostring(planet_units))

            if planet_units >= planet_max then
                DebugMessage("Reached Planet Max")
                amount = 0
            end

            if planet_units < planet_max then
                DebugMessage("Planet Units is less than Max")
                if planet_units + amount > planet_max and not (planet_units + amount == planet_max) then
                    DebugMessage("Planet Units plus amount is greater to planet max but not equal to")
                    amount = planet_max - planet_units
                    DebugMessage("Final Amount: %s", tostring(amount))
                end
            end

            if amount > 0 then
                spawned_units[unit_name] = spawned_units[unit_name] + amount

                for x=amount, 1, -1 do
                    new_units = Spawn_Unit(unit_type, planet, player)
                    if new_units ~= nil then
                        for _, unit in pairs(new_units) do
                            unit.Prevent_AI_Usage(false)
                        end
                    end
                end
            end
        end
    end

    for unit_name, amount in pairs(spawned_units) do
        if amount < units[unit_name] then

            DebugMessage("Unit: %s, Spawned Amount: %s, Max: %s", tostring(unit_name), tostring(amount), tostring(units[unit_name]))

            amount_to_spawn = EvenMoreRandom(1,units[unit_name] - amount)

            DebugMessage("Amount to Spawn: %s", tostring(amount_to_spawn))

            for x=amount_to_spawn, 1, -1 do
                random_planet = Select_Random_Planet(faction)

                DebugMessage("Spawning at: %s", tostring(random_planet.Get_Type().Get_Name()))

                new_units = Spawn_Unit(Find_Object_Type(unit_name), random_planet, player)
                if new_units ~= nil then
                    for _, unit in pairs(new_units) do
                        unit.Prevent_AI_Usage(false)
                    end
                end
            end
        end
    end
end

function Lock_Vanilla_Units()
    empire = Find_Player("EMPIRE")
    empire.Lock_Tech(Find_Object_Type("Generic_Probe_Droid"))
    empire.Lock_Tech(Find_Object_Type("Probe_Droid_Team"))
    empire.Lock_Tech(Find_Object_Type("TIE_Scout_Squadron"))
    rebel = Find_Player("REBEL")
    rebel.Lock_Tech(Find_Object_Type("A_Wing_Squadron"))
end

function Diff_Multiplier(value, player)

    diff = player.Get_Difficulty()

    human_multiplier = {
        ["Easy"] = 1.5,
        ["Normal"] = 1,
        ["Hard"] = 0.5
    }

    ai_multiplier = {
        ["Hard"] = 1.5,
        ["Normal"] = 1,
        ["Easy"] = 0.5
    }

    if player.Is_Human() then
        return tonumber(Dirty_Floor((value * human_multiplier[diff]) + 0.5 ))
    end
    
    return tonumber(Dirty_Floor((value * ai_multiplier[diff]) + 0.5 ))
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
                if unit.Get_Planet_Location().Get_Type().Get_Name() == planet_name and not (unit.Get_Type().Is_Hero()) then
                    table.insert(planet_units,unit)
                end
            end
        end
    end
    return planet_units
end

function Select_Random_Planet(faction_name)
    local all_planets = FindPlanet.Get_All_Planets()

    local random_planet = all_planets[EvenMoreRandom(1,tableLength(all_planets))]

    while string.lower(random_planet.Get_Owner().Get_Faction_Name()) ~= string.lower(faction_name) do
        random_planet = all_planets[EvenMoreRandom(1,tableLength(all_planets))]
    end

    return random_planet
end
