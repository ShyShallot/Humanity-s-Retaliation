
require("PGStateMachine")

function Definitions()
	Define_State("State_Init", State_Init);
end

function State_Init(message)
	if message == OnEnter then
        DebugMessage("%s -- In On_Enter, running funcs", tostring(Script))
        Init_Reactor_Systems()
        ScriptExit()
	end
end

function Init_Reactor_Systems()
    DebugMessage("%s -- Spawning Powers Systems marker", tostring(Script))
    netural = Find_Player("Neutral")
    Create_Generic_Object("Power_Systems_Marker", Object.Get_Position(), netural)
    DebugMessage("%s -- Done", tostring(Script))
end