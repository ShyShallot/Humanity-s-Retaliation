require("PGStateMachine")
require("HALOFunctions")

function Definitions()
	ServiceRate = 1

	Define_State("State_Init", State_Init);
end

function State_Init(message) 
    if message == OnEnter then
        DebugMessage("Projectile Health: %s ", tostring(Object.Get_Hull()))
    end
end