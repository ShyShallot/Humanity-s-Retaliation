require("PGStateMachine")
require("HALOFunctions")
require("PGBaseDefinitions")
require("HALOAIFunctions") 

function Definitions()
    ServiceRate = 1
	Define_State("State_Init", State_Init);

    planet_loyaltly_table = { /* 1 means its fully loyal to UNSC/Covenant, 0 means its loyal to Rebels/Banished */
        [""] = 0,
    }

    planet_influence_table = { /* Negative Influence means its a rebel/banished planet giving influence to nearby planets */

    }
	
end

function State_Init(message)
    if message == OnEnter then
        fmessage = "OnEnter"
        DebugMessage("%s -- In OnUpdate", tostring(Script))
		if Object.Get_Owner().Is_Human() then
			if Object.Is_Ability_Active(ability_name) then
                DebugMessage("%s -- Ability Active Running Search for Protection", tostring(Script))
                Create_Thread("CarrierAI")
            end
		else
            ScriptExit()
		end
    end
end



function Get_Nearest_Planet(checkPlanet)
    local planets = FindPlanet.Get_All_Planets()

    for i,planet in pairs(planets) do
        
    end
end