require("PGStateMachine")
require("HALOFunctions")
require("PGBaseDefinitions")
require("HALOFunctions") 


function Definitions()
    ServiceRate = 1
	Define_State("State_Init", State_Init);

    human_planets = {}
end

function State_Init(message)
    
    if message == OnEnter then

        human = Find_Human_Player()

        planets = FindPlanet.Get_All_Planets()

        for _, planet in pairs(planets) do
            if planet.Get_Owner() == human then
                table.insert(human_planets,planet)
            end
        end
    end

    if message == OnUpdate then

    end
end