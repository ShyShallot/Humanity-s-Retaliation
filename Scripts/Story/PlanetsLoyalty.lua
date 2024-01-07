require("PGStateMachine")
require("HALOFunctions")
require("PGBaseDefinitions")
require("HALOFunctions") 

function Definitions()
    ServiceRate = 1
	Define_State("State_Init", State_Init);

    planet_loyaltly_table = { --[[ 1 means its fully loyal to UNSC/Covenant, 0 means its loyal to Rebels/Banished --]]
        
    }

    planet_influence_table = { --[[ Negative Influence means its a rebel/banished planet giving influence to nearby planets --]]

    }

    planet_neighbor_table = {
        ["Earth"] = {
            "Reach",
            "Mars",
            "Madrigal",
        },
        ["Reach"] = {
            "Earth",
            "Harmony",
            ""
        }
    }
	
end

function State_Init(message)
    if message == OnEnter then
        human = Find_Human_Player()

        local planets = FindPlanet.Get_All_Planets()

        for i,planet in pairs(planets) do
            planet_loyaltly_table[i] = {
                [planet.Get_Type().Get_Name()] = {
                    ["Owner"] = planet.Get_Owner().Get_Faction_Name(),
                    ["Loyalty"] = 1.0,
                    ["Neighbors"] = {}
                }
            }
            for y, Splanet in pairs(planets) do
                if not (Splanet == planet) then
                    
                end
            end
        end
    end
    if message == OnUpdate then
        
    end
end
