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
            Game_Message("The " .. player.Get_Faction_Name() .. " player is a pussy, initiating self destruct in 5 seconds")
            Sleep(5)
            station.Take_Damage(100000000000000)
        end
	end
end
