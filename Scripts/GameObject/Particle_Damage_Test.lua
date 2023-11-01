require("PGStateMachine")
require("HALOFunctions")

function Definitions()
	ServiceRate = 1

	Define_State("State_Init", State_Init);
end

function State_Init(message) 
    if message == OnEnter then
        local damage = Object.Get_Health()  * 0.7
        Object.Take_Damage(damage)
    end
end