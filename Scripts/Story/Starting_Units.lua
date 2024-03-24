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

        starting_units_rebel = { -- balance these to easy difficulty
            [5] = {
                ["UNSC_HALCYON"] = 1,
                ["UNSC_PARIS"] = 2,
                ["UNSC_STALWART"] = 3,
                ["Baselard_Squadron"] = 3,
                ["Shortsword_Squadron"] = 2
            },
            [4] = {
                ["UNSC_HALCYON"] = 1,
                ["UNSC_PARIS"] = 2,
                ["UNSC_STALWART"] = 3,
                ["Baselard_Squadron"] = 3,
                ["Shortsword_Squadron"] = 2
            },
            [3] = {
                ["UNSC_PARIS"] = 1,
                ["UNSC_STALWART"] = 2,
                ["Baselard_Squadron"] = 3,
                ["Shortsword_Squadron"] = 2
            },
            [2] = {
                ["UNSC_STALWART"] = 2,
                ["Baselard_Squadron"] = 3,
                ["Shortsword_Squadron"] = 2
            },
            [1] = {
                ["Baselard_Squadron"] = 3,
                ["Shortsword_Squadron"] = 2
            }
        }

        starting_units_empire = {
            [5] = {
                ["COVN_RCS"] = 1,
                ["COVN_CRS"] = 2,
                ["COVN_CAR"] = 2,
                ["COVN_SDV"] = 3,
                ["Banshee_Squadron"] = 3,
                ["Tarasque_Squadron"] = 2
            },
            [4] = {
                ["COVN_CRS"] = 2,
                ["COVN_CAR"] = 2,
                ["COVN_SDV"] = 3,
                ["Banshee_Squadron"] = 3,
                ["Tarasque_Squadron"] = 2
            },
            [3] = {
                ["COVN_CRS"] = 1,
                ["COVN_CAR"] = 1,
                ["COVN_SDV"] = 2,
                ["Banshee_Squadron"] = 3,
                ["Tarasque_Squadron"] = 2
            },
            [2] = {
                ["COVN_CAR"] = 1,
                ["COVN_SDV"] = 2,
                ["Banshee_Squadron"] = 3,
                ["Tarasque_Squadron"] = 2
            },
            [1] = {
                ["COVN_SDV"] = 1,
                ["Banshee_Squadron"] = 3,
                ["Tarasque_Squadron"] = 2
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


        Lock_Vanilla_Units()

    end
end

function Spawn_Starting_Units(faction, units, location)
    planet = FindPlanet(location)
    starbase_level = planet.Get_Starbase_Level()
    player = Find_Player(faction)

    shield_tech = Find_First_Object("UNSC_Tech_Shield")

    if player.Get_Faction_Name() == "REBEL" and (not TestValid(shield_tech)) and player.Get_Tech_Level() >= 3 then -- if the unsc starts at tech 4 or 5, spawn the shield tech research at the first planet
        Spawn_Unit(Find_Object_Type("UNSC_Tech_Shield"),planet,player)
    end

    for unit_name, amount in pairs(units[starbase_level]) do
        amount = Diff_Multiplier(amount,player)
        for x=amount, 1, -1 do
            new_units = Spawn_Unit(Find_Object_Type(unit_name),planet,player)
            if new_units ~= nil then
                for _, unit in pairs(new_units) do
                    unit.Prevent_AI_Usage(false)
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