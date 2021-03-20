require("PGStateMachine")

function Definitions()

-- Object script stuff

	ServiceRate = 1

	Define_State("State_Init", State_Init);

end

function State_Init(message)
	if message == OnEnter then
        player = Object.Get_Owner()
        station = player.Get_Space_Station()
        if TestValid(station) then
            station.Take_Damage(100000000000000)
        end
	end
end
