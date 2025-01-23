--Made by ShyShallot for Legacy of Zann
require("PGStateMachine")
require("PGBase")
require("PGSpawnUnits")
require("HALOFunctions")

spawningDone = false

function isSpawningDone() 
    return spawningDone
end
-- Please Note this script is a total fucking mess, it works and i dont want to spend 2 more days re-writing it
-- This script File is the main Function File for the Rebel Slice Mechanic

--function Planet_List()
--    local planets = FindPlanet.Get_All_Planets()
--    for k, v in pairs(planets) do
--        DebugMessage("%s -- Planet List Key", tostring(k))
--        DebugMessage("%s -- Planet List Value", tostring(v))
--    end
--end

function Despawn_Starting_Structure(player, starting_unit)
    local playerFac = player.Get_Faction_Name()
    DebugMessage("Despawn for Player -- %s", tostring(playerFac))

    --test_list = Find_All_Objects_Of_Type(player)

    --for key, value in pairs(test_list) do
    --    DebugMessage("%s, %s", tostring(key), tostring(value))
    --end

    local player_planet = Find_First_Object(starting_unit).Get_Planet_Location()
    if TestValid(player_planet) then
        DebugMessage("%s -- Resetting that planet", tostring(Script))
        player_planet.Change_Owner(Find_Player("NEUTRAL"))
        Find_First_Object(starting_unit).Despawn()
        DebugMessage("%s -- All done", tostring(Script))
    else
        DebugMessage("%s -- Could not find Planet", tostring(Script))
        return
    end
end

empire_structures = {}
empire_starbase = "Empire_Star_Base_5"
empire_units = {
    ["COVN_CCS"] = 1, 
    ["COVN_RCS"] = 1,
    ["COVN_CRS"] = 2,
    ["COVN_CAR"] = 1,
    ["COVN_SDV"] = 2, 
    ["Cerastes_Squadron"] = 2, 
    ["Banshee_Squadron"] = 4
}
rebel_structures = {}
rebel_starbase = "Rebel_Star_Base_4"
rebel_units = {
    ["UNSC_Halcyon"] = 3,
    ["UNSC_Paris"] = 2,
    ["UNSC_STALWART"] = 1,
    ["UNSC_MAKO"] = 2,
    ["Shortsword_Squadron"] = 2,
    ["Baselard_Squadron"] = 3
}

function Spawn_Random_Units()
    DebugMessage("%s -- Function called spawning starting units", tostring(Script))
    --Planet_List() This is only used for Debugging, do not renable unless needed
    local empire = Find_Player("EMPIRE")
    local rebel = Find_Player("REBEL")
    Spawn_Faction_Starting(empire, empire_structures, empire_units,empire_starbase, "COVN_CCS")
    Spawn_Faction_Starting(rebel, rebel_structures, rebel_units,rebel_starbase, "UNSC_HALCYON")
    --Spawn_Player_Pirates() -- Always spawn pirates last, as they fill in the gaps
    Sub_Faction_Planet_Master()
    Sleep(5)
    DebugMessage("%s -- All Done", tostring(Script))
    spawningDone = true
end

function Spawn_Player_Terrorists()
    local player = Find_Player("Terrorists")

    player.Enable_As_Actor()

    Despawn_Starting_Structure(player)
    DebugMessage("%s -- Despawning pirate structure", tostring(Script))
    local terrorist_start_units = {
        {
            ["TERROR_HALCYON"] = {1,3}, -- Min, Max for random amount
            ["TERROR_STALWART"] = {2,5},
            ["TERROR_MAKO"] = {2,3},
            ["TERROR_Baselard_Squadron"] = {2,4},
            ["TERROR_SHORTSWORD"] = {1,3}
        }
    }
    Spawn_Subfaction_Starting(player,{},terrorist_start_units,"Terrorists_Star_Base_2")
end

function Spawn_Player_Swords()
    local player = Find_Player("Swords")

    player.Enable_As_Actor()
    
    Despawn_Starting_Structure(player)
    DebugMessage("%s -- Despawning pirate structure", tostring(Script))
    swords_start_units = {
        {
            ["SWORDS_CCS"] = {1,1}, -- Min, Max for random amount
            ["SWORDS_CRS"] = {2,5},
            ["SWORDS_CAR"] = {2,3},
            ["SWORDS_SDV"] = {2,4},
            ["SWORDS_Banshee_Squadron"] = {1,3}
        }
    }
    Spawn_Subfaction_Starting(player,{},swords_start_units,"SWORDS_STARBASE_2")
    
end

function Spawn_Faction_Starting(faction, structures, units, starbase, starting_unit)
    Despawn_Starting_Structure(faction,starting_unit)
    DebugMessage("%s -- Despawning %s Structure", tostring(Script), tostring(faction.Get_Faction_Name()))
    local planet_start = Random_Planet_Select()
    if TestValid(planet_start) then
        if Return_Faction(planet_start) ~= "NEUTRAL" then   
            return
        end 
    else
        return
    end
    planet_start.Change_Owner(faction)

    DebugMessage("%s -- Planet Valid for spawn", tostring(Script))
    Spawn_Unit_List(units, planet_start, faction)
    Sleep(1)
    Spawn_Structure_List(structures, planet_start, faction)
    Sleep(1)
    Spawn_Unit(Find_Object_Type(starbase),planet_start,faction)
end


function Spawn_Subfaction_Starting(faction, structures, units, starbase)
    
end

function Random_Planet_Select()
    DebugMessage("%s -- Selecting Random Planet", tostring(Script))
    local planets = FindPlanet.Get_All_Planets()
    local totalplanets = table.getn(planets)
    DebugMessage("%s -- Number of Planets", tostring(totalplanets))
    local selectRandom = EvenMoreRandom(1, totalplanets,20) -- Lua starts index at 1 cause why not
    DebugMessage("%s -- Random Selected Index", tostring(selectRandom))
    local randomPlanet = planets[selectRandom]
    DebugMessage("%s -- Random Planet", tostring(randomPlanet))
    return randomPlanet
    
end

function Spawn_Unit_List(unit_list, planet, player)
    local x = 0
    DebugMessage("%s -- Unit List", tostring(unit_list))
    for unit, amount in pairs(unit_list) do
        DebugMessage("%s -- Unit to Spawn", tostring(unit))
        DebugMessage("%s -- Amount to spawn", tostring(amount))
        DebugMessage("%s -- Spawning Space Units", tostring(Script))
        local unitO = Find_Object_Type(unit)
        if type(amount) == "table" then
            DebugMessage("%s -- Amount is a table", tostring(Script))
            amount = EvenMoreRandom(amount[1],amount[2],10)
            DebugMessage("%s -- Amount of Random Units", tostring(amount))
        end
        if amount == 1 then
            local new_units = Spawn_Unit(unitO, planet, player)
            if new_units ~= nil then
                for _, unit in pairs(new_units) do
                    unit.Prevent_AI_Usage(false)
                end
            end
        else
            for x=amount, 1, -1 do
                local new_units = Spawn_Unit(unitO, planet, player)
                if new_units ~= nil then
                    for _, unit in pairs(new_units) do
                        unit.Prevent_AI_Usage(false)
                    end
                end
                DebugMessage("%s -- Amount left", tostring(x))
            end
        end
    end
end


function Spawn_Structure_List(struct_list, planet,player)
    for i=table.getn(struct_list),1,-1 do
        local struct = Find_Object_Type(struct_list[i])
        Spawn_Unit(struct,planet,player)
    end
end

function Sub_Faction_Planet_Master()
    local Terror = Find_Player("Terrorists")

    local Swords = Find_Player("Swords")

    local all_planets = FindPlanet.Get_All_Planets()

    local Setup_Planets = {}

    local Neutral_Percentage = tonumber(Dirty_Floor(EvenMoreRandom(10,30) / 100 )) -- anywhere from 10 to 30% of planets will be neutral

    local Neutal_Count = tonumber(Dirty_Floor((tableLength(all_planets) - 4) * Neutral_Percentage)) -- amount of planets then subtract 4, for the 4 starting planets 

    local Non_Neutral_Count = (tableLength(all_planets) - 4) - Neutal_Count

    Sub_Faction_Setup(Terror, "TERROR_HALCYON", all_planets)

    Terror.Enable_As_Actor()

    Sub_Faction_Setup(Swords, "SWORDS_CCS", all_planets)

    Swords.Enable_As_Actor()

    DebugMessage("Starting Subfaction Spread")

    for _, planet in pairs(all_planets) do

        if(tableLength(Setup_Planets) >= Non_Neutral_Count) then
            break
        end

        if (TestValid(planet)) then
            DebugMessage("Random Spread Planet: " .. tostring(planet))

            local Planet_Changed = false

            if planet.Get_Owner() == Find_Player("Neutral") then
                DebugMessage("Planet is Neutral")

                local closest_planet = nil
                local distance = 500

                for _, cPlanet in pairs(all_planets) do
                    if cPlanet.Get_Owner() ~= Find_Player("Neutral") then
                        local path = Find_Path(Find_Player("Rebel"), planet, cPlanet)

                        local path_length = tableLength(path)

                        if(path_length < distance) then
                            closest_planet = cPlanet
                            distance = path_length
                        end
                    end
                end

                local max_distance = 3 -- x planet max influence

                if closest_planet ~= nil and distance < (max_distance + 2) then
                    DebugMessage(tostring(closest_planet) .. " was within margin, Owner: " .. tostring(closest_planet.Get_Owner().Get_Name()))
                    if closest_planet.Get_Owner() == Terror or closest_planet.Get_Owner() == Find_Player("Rebel")then
                        DebugMessage("Changed Owner")
                        planet.Change_Owner(Terror)
                        Planet_Changed = true
                    end

                    if closest_planet.Get_Owner() == Swords or closest_planet.Get_Owner() == Find_Player("Empire") then
                        DebugMessage("Changed Owner")
                        planet.Change_Owner(Swords)
                        Planet_Changed = true
                    end
                end
            end

            if Planet_Changed then
                Setup_Planets[planet] = true
            end
        end
    end

    local All_Terror_Planets = {}

    local All_Swords_Planets = {}

    for _, planet in pairs(all_planets) do
        if planet.Get_Owner() == Terror then
            table.insert(All_Terror_Planets, planet)
        end

        if planet.Get_Owner() == Swords then
            table.insert(All_Swords_Planets, planet)
        end
    end
    
    DebugPrintTable(All_Terror_Planets)

    DebugPrintTable(All_Swords_Planets)

    local Amount_Of_Terror_Planets = tableLength(All_Terror_Planets)

    local Amount_Of_Swords_Planets = tableLength(All_Swords_Planets)

    local Max_Terror_Units_By_Type = {}

    Max_Terror_Units_By_Type.Capital = {0,1} -- Min, Max

    Max_Terror_Units_By_Type.Frigate = {0,5}

    Max_Terror_Units_By_Type.Corvette = {2,6}

    Max_Terror_Units_By_Type.Fighter = {4,8}

    DebugPrintTable(Max_Terror_Units_By_Type)

    local Max_Swords_Units_By_Type = {}

    Max_Swords_Units_By_Type.Capital = {0,1}

    Max_Swords_Units_By_Type.Frigate = {0,4}

    Max_Swords_Units_By_Type.Corvette = {0,5}

    Max_Swords_Units_By_Type.Fighter = {3,10}

    DebugPrintTable(Max_Swords_Units_By_Type)
  
    local Terror_Valid_Units = {
        Capital = {"TERROR_HALCYON"},
        Frigate = {"TERROR_STALWART"},
        Corvette = {"TERROR_MAKO", "TERROR_GLADIUS"},
        Fighter = {"TERROR_SHORTSWORD_Squadron","TERROR_Baselard_Squadron"}
    }

    local Swords_Valid_Units = {
        Capital = {"SWORDS_CCS"},
        Frigate = {"SWORDS_CRS"},
        Corvette = {"SWORDS_CAR","SWORDS_SDV"},
        Fighter = {"SWORDS_Banshee_Squadron", "SWORDS_Cerastes_Squadron"}
    }

    Spawn_Sub_Faction_Units(All_Terror_Planets, Max_Terror_Units_By_Type, Terror, Terror_Valid_Units, "Terrorists_Star_Base_3")

    Spawn_Sub_Faction_Units(All_Swords_Planets, Max_Swords_Units_By_Type, Swords, Swords_Valid_Units, "SWORDS_STARBASE_2")

end

function Spawn_Sub_Faction_Units(Planet_List, Max_Table, Faction, Units, Starbase)
    for _, planet in pairs(Planet_List) do
        for Category, Amount in pairs(Max_Table) do
            DebugMessage("Category: ".. tostring(Category) .. ", Amount: " .. tostring(Amount))
            local min = Amount[1]
            local max = Amount[2]

            local finalAmount = EvenMoreRandom(min,max,8)
            
            local randomPercent = tonumber(Dirty_Floor(EvenMoreRandom(0,100) / 100))

            finalAmount = tonumber(Dirty_Floor(finalAmount * randomPercent))

            for i=1, finalAmount do
                local randomUnitIndex = EvenMoreRandom(1, tableLength(Units[Category]))

                local randomUnit = Units[Category][randomUnitIndex]

                local randomUnitType = Find_Object_Type(randomUnit)

                Spawn_Unit(randomUnitType, planet, Faction)
            end
        end

        Spawn_Unit(Find_Object_Type(Starbase), planet, Faction)
    end

    
end


function Sub_Faction_Setup(Faction, Starting_Unit, all_planets)
    Despawn_Starting_Structure(Faction, Starting_Unit)

    local random_index = EvenMoreRandom(1, tableLength(all_planets))

    DebugMessage("Random Starting Index for Faction " .. tostring(Faction.Get_Faction_Name()) .. ": " .. tostring(random_index))

    local planet = all_planets[random_index]

    DebugMessage("Starting Planet: " .. tostring(planet))

    local max_check_count = 10

    local current_count = 0

    if TestValid(planet) then
        while (planet.Get_Owner() ~= Find_Player("Neutral")) do
            DebugMessage(tostring(planet) .. " is Not Neutral")

            random_index = EvenMoreRandom(1, tableLength(all_planets))

            planet = all_planets[random_index]

            DebugMessage("New Planet: " .. tostring(planet))

            current_count = current_count + 1

            if current_count >= max_check_count then
                DebugMessage("Reached Max Search")
                break
            end
        end

        DebugMessage("Final Starting Point: " .. tostring(planet) .. ", for Faction: " .. tostring(Faction.Get_Faction_Name()))

        planet.Change_Owner(Faction)
    end
end

function Find_Faction_Starting_Planet(Faction)
    local Planets = FindPlanet.Get_All_Planets()

    local starting_planet = nil

    for _, planet in pairs(Planets) do
        if planet.Get_Owner() == Faction then
            starting_planet = planet
            break
        end
    end

    return starting_planet
end