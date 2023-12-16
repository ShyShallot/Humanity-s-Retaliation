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

function Despawn_Starting_Structure(player)
    local playerFac = player.Get_Faction_Name()
    DebugMessage("Player -- %s", tostring(playerFac))

    --test_list = Find_All_Objects_Of_Type(player)

    --for key, value in pairs(test_list) do
    --    DebugMessage("%s, %s", tostring(key), tostring(value))
    --end
    
    if playerFac == "EMPIRE" then
        starting_struct = Find_First_Object("COVN_CCS")
    elseif playerFac == "REBEL" then
        starting_struct = Find_First_Object("UNSC_HALCYON")
    elseif playerFac == "Terrorists" then
        starting_struct = Find_First_Object("TERROR_HALCYON")
    elseif playerFac == "Swords" then
        starting_struct = Find_First_Object("SWORDS_CCS")
    end

    DebugMessage("Starting Struct -- %s",tostring(starting_struct))

    if TestValid(starting_struct) then
        DebugMessage("%s -- Found Struct, Getting Planet location", tostring(Script))
        starting_struct_planet = starting_struct.Get_Planet_Location()
        DebugMessage("%s -- Despawning Struct", tostring(Script))
        starting_struct.Despawn()
        DebugMessage("%s -- Resetting that planet", tostring(Script))
        starting_struct_planet.Change_Owner(Find_Player("NEUTRAL"))
        DebugMessage("%s -- All done", tostring(Script))
    else
        DebugMessage("%s -- Could not find Struct", tostring(Script))
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
    empire = Find_Player("EMPIRE")
    rebel = Find_Player("REBEL")
    Spawn_Faction_Starting(empire, empire_structures, empire_units,empire_starbase)
    Spawn_Faction_Starting(rebel, rebel_structures, rebel_units,rebel_starbase)
    --Spawn_Player_Pirates() -- Always spawn pirates last, as they fill in the gaps
    Spawn_Player_Terrorists()
    Spawn_Player_Swords()
    DebugMessage("%s -- All Done", tostring(Script))
end

function Spawn_Player_Terrorists()
    local player = Find_Player("Terrorists")
    Despawn_Starting_Structure(player)
    DebugMessage("%s -- Despawning pirate structure", tostring(Script))
    terrorist_start_units = {
        {
            ["TERROR_HALCYON"] = {1,3}, -- Min, Max for random amount
            ["TERROR_STALWART"] = {2,5},
            ["TERROR_MAKO"] = {2,3},
            ["TERROR_Baselard_Squadron"] = {2,4},
            ["TERROR_SHORTSWORD"] = {1,3}
        }
    }
    Spawn_Subfaction_Starting(player,{},terrorist_start_units,"TERROR_STARBASE_2")
end

function Spawn_Player_Swords()
    local player = Find_Player("Swords")
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
    spawningDone = true
end

function Spawn_Faction_Starting(faction, structures, units, starbase)
    Despawn_Starting_Structure(faction)
    DebugMessage("%s -- Despawning %s Structure", tostring(Script), tostring(faction.Get_Faction_Name()))
    planet_start = Random_Planet_Select()
    if TestValid(planet_start) then
        if Return_Faction(planet_start) == "NEUTRAL" then   
            DebugMessage("%s -- Planet Valid for spawn", tostring(Script))
            planet_start.Change_Owner(faction)
            Spawn_Unit(Find_Object_Type(starbase),planet_start,faction)
        end 
    else
        return
    end
    Spawn_Structure_List(structures, planet_start, faction)
    Spawn_Unit_List(units, planet_start, faction)
end


function Spawn_Subfaction_Starting(faction, structures, units, starbase)
    local Hplayer = Find_Human_Player()
    space_units = units[1]
    local planets = FindPlanet.Get_All_Planets()
    local planetcount = table.getn(planets)
    local piratecontrol = Pirate_Control_Threshold(Hplayer)
    local finalplanetfill = tonumber(Dirty_Floor(planetcount * piratecontrol))
    DebugMessage("%s -- Total Planets to fill", tostring(finalplanetfill))
    local planets_left = finalplanetfill
    for k, planet in pairs(planets) do
        if TestValid(planet) and Return_Faction(planet) == "NEUTRAL" and planets_left >= 1 then
            DebugMessage("%s -- Planet Valid for spawning", tostring(Script))
            if Return_Faction(planet) == "NEUTRAL" then   
                DebugMessage("%s -- Planet Valid for spawn", tostring(Script))
                planet.Change_Owner(faction)
                Spawn_Unit(Find_Object_Type(starbase),planet,faction)
                Spawn_Unit_List(space_units, planet, faction)
                planets_left = planets_left - 1
                DebugMessage("%s -- Planets left to take over", tostring(planets_left))
            else
                return
            end
        end
    end
end

function Random_Planet_Select()
    DebugMessage("%s -- Selecting Random Planet", tostring(Script))
    local planets = FindPlanet.Get_All_Planets()
    local totalplanets = table.getn(planets)
    DebugMessage("%s -- Number of Planets", tostring(totalplanets))
    local selectRandom = EvenMoreRandom(1, totalplanets,50) -- Lua starts index at 1 cause why not
    DebugMessage("%s -- Random Selected Index", tostring(selectRandom))
    randomPlanet = planets[selectRandom]
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
        unitO = Find_Object_Type(unit)
        if type(amount) == "table" then
            DebugMessage("%s -- Amount is a table", tostring(Script))
            amount = EvenMoreRandom(amount[1],amount[2],10)
            DebugMessage("%s -- Amount of Random Units", tostring(amount))
        end
        if amount == 1 then
            Spawn_Unit(unitO, planet, player)
        else
            for x=amount, 1, -1 do
                Spawn_Unit(unitO, planet, player)
                DebugMessage("%s -- Amount left", tostring(x))
            end
        end
    end
end


function Spawn_Structure_List(struct_list, planet,player)
    for i=table.getn(struct_list),1,-1 do
        struct = Find_Object_Type(struct_list[i])
        Spawn_Unit(struct,planet,player)
    end
end

function Pirate_Control_Threshold(player)
    
    if player.Get_Difficulty() == "Easy" then
        pirate_control_threshold = 0.05 -- Pirates control x% of the Map on start
        DebugMessage("%s -- Difficulty is Easy, Pirate Control Treshold", tostring(pirate_control_threshold))
    elseif player.Get_Difficulty() == "Hard" then
        pirate_control_threshold = 0.1
        DebugMessage("%s -- Difficulty is Hard, Pirate Control Treshold", tostring(pirate_control_threshold))
    else
        pirate_control_threshold = 0.2
        DebugMessage("%s -- Difficulty is Normal, Pirate Control Treshold", tostring(pirate_control_threshold))
    end
    if pirate_control_threshold ~= nil then
        DebugMessage("%s -- Final Pirate Control Treshold", tostring(pirate_control_threshold))
        return pirate_control_threshold
    end
end

function Find_Human_Player()
    empire = Find_Player("EMPIRE")
    rebels = Find_Player("REBEL")

    if empire.Is_Human() and (not rebels.Is_Human()) then
        DebugMessage("%s -- Human player is Empire", tostring(Script))
        return empire
    elseif rebels.Is_Human() and (not empire.Is_Human()) then
        DebugMessage("%s -- Human player is Rebel", tostring(Script))
        return rebels
    end
end
