require("PGStateMachine")

function Definitions()

-- Object script stuff

	ServiceRate = 1

	Define_State("State_Init", State_Init);
end

function State_Init(message)
	if message == OnEnter then
		ObjectType = Object.Get_Type()
        Spawn_Unit(ObjectType,Object,Object.Get_Owner())
        Object.Despawn()
	end
end