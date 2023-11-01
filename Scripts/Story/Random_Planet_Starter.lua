--Made by ShyShallot for Legacy of Zann
require("PGStateMachine")
require("PGBase")
require("PGSpawnUnits")
require("LOZFunctions")

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
    if playerFac == "EMPIRE" then
        DebugMessage("%s -- Player is Empire", tostring(Script))
        starting_struct = Find_First_Object("Empire_Starbase_5", player)
    elseif playerFac == "REBEL" then
        DebugMessage("%s -- Player is Rebel", tostring(Script))
        starting_struct = Find_First_Object("Rebel_Starbase_5", player)
    end

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
empire_starbase = "Empire_Star_Base_5_Starting"
empire_units = {
    ["COVN_CCS"] = 1, 
    ["COVN_CRS"] = 2, 
    ["Cerastes_Squadron"] = 2, 
    ["Banshee_Squadron"] = 4
}
rebel_structures = {}
rebel_starbase = "Rebel_Star_Base_5_Starting"
rebel_units = {
    ["UNSC_Halcyon"] = 1,
    ["UNSC_Paris"] = 2,
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
    DebugMessage("%s -- All Done", tostring(Script))
end

function Spawn_Player_Pirates()
    local player = Find_Player("PIRATES")
    local Hplayer = Find_Human_Player()
    Despawn_Starting_Structure(player)
    DebugMessage("%s -- Despawning pirate structure", tostring(Script))
    pirate_start_table = {
        {
            ["PIRATE_FRIGATE"] = {1,5}, -- Min, Max for random amount
            ["PIRATE_CORONA_FRIGATE"] = {1,2},
            ["Z95_HEADHUNTER_SQUADRON"] = {3,5},
        },
        {
            ["PIRATE_COMMAND_CENTER"] = 1,
            ["PIRATE_SKIFF_TEAM"] = {2,5},
            ["PIRATE_SOLDIER_SQUAD"] = {5,7},
        }
    }
    space_units = pirate_start_table[1]
    ground_units = pirate_start_table[2]
    local planets = FindPlanet.Get_All_Planets()
    local planetcount = table.getn(planets)
    local piratecontrol = Pirate_Control_Threshold(Hplayer)
    local finalplanetfill = planetcount * piratecontrol
    DebugMessage("%s -- Total Planets to fill", tostring(finalplanetfill))
    local planets_left = finalplanetfill
    for k, planet in pairs(planets) do
        if TestValid(planet) and Return_Faction(planet) == "NEUTRAL" and planets_left >= 1 then
            DebugMessage("%s -- Planet Valid for spawning", tostring(Script))
            if Return_Faction(planet) == "NEUTRAL" and (Return_Faction(planet) ~= "REBEL" or Return_Faction(planet) ~= "EMPIRE") then   
                DebugMessage("%s -- Planet Valid for spawn", tostring(Script))
                planet.Change_Owner(player)
                Spawn_Unit(Find_Object_Type("PIRATE_ASTEROID_BASE"),planet,player)
                Spawn_Unit_List(space_units, planet, player)
                Spawn_Unit_List(ground_units, planet, player)
                planets_left = planets_left - 1
                DebugMessage("%s -- Planets left to take over", tostring(planets_left))
            else
                return
            end
        end
    end
    DebugMessage("%s -- All Done spawning Pirates", tostring(Script))
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

function Random_Planet_Select()
    DebugMessage("%s -- Selecting Random Planet", tostring(Script))
    local planets = FindPlanet.Get_All_Planets()
    local totalplanets = table.getn(planets)
    DebugMessage("%s -- Number of Planets", tostring(totalplanets))
    local selectRandom = EvenMoreRandom(1, totalplanets,30) -- Lua starts index at 1 cause why not
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
            for x=amount, 0, -1 do
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
        pirate_control_threshold = 0.5 -- Pirates control x% of the Map on start
        DebugMessage("%s -- Difficulty is Easy, Pirate Control Treshold", tostring(pirate_control_threshold))
    elseif player.Get_Difficulty() == "Hard" then
        pirate_control_threshold = 0.8
        DebugMessage("%s -- Difficulty is Hard, Pirate Control Treshold", tostring(pirate_control_threshold))
    else
        pirate_control_threshold = 0.95
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
