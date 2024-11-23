require("PGStateMachine")

function Definitions()

	DebugMessage("%s -- In Definitions", tostring(Script))
		
	Define_State("State_Init", State_Init);

end


function State_Init(message)

	if message == OnEnter then
		Play_Bink_Movie("Background")
    end

end
