require("PGStoryMode")
require("PGStateMachine")
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
            elseif planet.Get_Owner().Get_Faction_Name() == "SWORDS" then 
                swordsPlanets[i] = planet
            end
        end

        starting_units_rebel = {
            [4] = {
                ["UNSC_HALCYON"] = 2,
                ["UNSC_PARIS"] = 2,
                ["UNSC_STALWART"] = 1,
                ["Baselard_Squadron"] = 3,
                ["Shortsword_Squadron"] = 2
            },
            [3] = {
                ["UNSC_HALCYON"] = 1,
                ["UNSC_PARIS"] = 1,
                ["UNSC_STALWART"] = 2,
                ["Baselard_Squadron"] = 2,
                ["Shortsword_Squadron"] = 1
            },
            [1] = {
                ["UNSC_STALWART"] = 2,
                ["Baselard_Squadron"] = 1,
                ["Shortsword_Squadron"] = 1
            }
        }

        starting_units_empire = {
            [5] = {
                ["COVN_RCS"] = 1,
                ["COVN_CRS"] = 3,
                ["COVN_CAR"] = 1,
                ["COVN_SDV"] = 2,
                ["Banshee_Squadron"] = 3,
                ["Tarasque_Squadron"] = 2
            },
            [3] = {
                ["COVN_CRS"] = 1,
                ["COVN_CAR"] = 1,
                ["COVN_SDV"] = 1,
                ["Banshee_Squadron"] = 2,
                ["Tarasque_Squadron"] = 1
            },
            [1] = {
                ["COVN_SDV"] = 1,
                ["Banshee_Squadron"] = 1,
                ["Tarasque_Squadron"] = 1
            }
        }

        starting_units_swords = {
            [2] = {
                ["SWORDS_CCS"] = 1,
                ["SWORDS_CRS"] = 3,
                ["SWORDS_CAR"] = 1,
                ["SWORDS_SDV"] = 2,
                ["SWORDS_Banshee_Squadron"] = 3,
                ["SWORDS_Cerastes_Squadron"] = 2
            }
        }

        for _, planet in pairs(rebelPlanets) do
            Spawn_Starting_Units("Rebel",starting_units_rebel,planet.Get_Type().Get_Name())
        end

        for _, planet in pairs(empirePlanets) do
            Spawn_Starting_Units("Empire",starting_units_empire,planet.Get_Type().Get_Name())
        end

        for _, planet in pairs(swordsPlanets) do
            Spawn_Starting_Units("Swords",starting_units_swords,planet.Get_Type().Get_Name())
        end

        Lock_Vanilla_Units()

    end
end

function Spawn_Starting_Units(faction, units, location)
    planet = FindPlanet(location)
    starbase_level = planet.Get_Starbase_Level()
    player = Find_Player(faction)

    matching_key = find_matching_key(starbase_level,units)

    for unit_name, amount in pairs(units[matching_key]) do
        for x=amount, 1, -1 do
            Spawn_Unit(Find_Object_Type(unit_name),planet,player)
        end
    end
end

function find_matching_key(level, list)
    matching_key = nil
    for key, _ in pairs(list) do
        if key <= level and (matching_key == nil or key > matching_key) then
            matching_key = key
        end
    end
    return matching_key
end

function Lock_Vanilla_Units()
    empire = Find_Player("EMPIRE")
    empire.Lock_Tech(Find_Object_Type("Generic_Probe_Droid"))
    empire.Lock_Tech(Find_Object_Type("Probe_Droid_Team"))
    rebel = Find_Player("REBEL")
    rebel.Lock_Tech(Find_Object_Type("A_Wing_Squadron"))
end