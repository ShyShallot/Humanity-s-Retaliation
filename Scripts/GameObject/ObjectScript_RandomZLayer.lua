
require("PGStateMachine")

function Definitions()

	DebugMessage("%s -- In Definitions", tostring(Script))
	Define_State("State_Init", State_Init);

    
end


function State_Init(message)
    if message == OnEnter then
        layer_manager = require("eaw-layerz/layermanager")
        layer_manager:update_unit_layer(Object,true)
        ScriptExit()
    end

end
