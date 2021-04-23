require("PGStateMachine")
require("ShipPowerSystems")
function Definitions()

	ServiceRate = 1

	Define_State("State_Init", State_Init);
	Define_State("State_AI_Autofire", State_AI_Autofire)
	Define_State("State_Human_No_Autofire", State_Human_No_Autofire)
	Define_State("State_Human_Autofire", State_Human_Autofire)

	
end

function State_Init(message)
	if message == OnEnter then
        ability_name = "POWER_TO_WEAPONS"
		-- prevent this from doing anything in galactic mode
		if Get_Game_Mode() == "Galactic" then
			ScriptExit()
		end
		Create_Thread("Ship_Systems", 1)
		if Object.Get_Owner().Is_Human() then
			Set_Next_State("State_Human_No_Autofire")
		else
			Set_Next_State("State_AI_Autofire")
		end
	end
	if message == OnUpdate then
	end
end

function State_AI_Autofire(message)
	if message == OnUpdate then
		Sleep(1)
		if Object.Is_Ability_Ready(ability_name) then
			enemy = FindDeadlyEnemy(Object)
			if TestValid(enemy) then
				if enemy.Get_Type().Get_Combat_Rating() >= Object.Get_Type().Get_Combat_Rating() then
                    Object.Activate_Ability(ability_name, true)
                end
			end
		end
		
		--Land units can change hands
		if Object.Get_Owner().Is_Human() then
			Set_Next_State("State_Human_No_Autofire")
		end				
	end		
end

function State_Human_No_Autofire(message)
	if message == OnUpdate then
		Sleep(1)
		if Object.Is_Ability_Autofire(ability_name) then
			Set_Next_State("State_Human_Autofire")
		end		
	end
end

function State_Human_Autofire(message)
	if message == OnUpdate then
		Sleep(1)
		if Object.Is_Ability_Autofire(ability_name) then
			if Object.Is_Ability_Ready(ability_name) then
				enemy = FindDeadlyEnemy(Object)
				if TestValid(enemy) then
                    if enemy.Get_Type().Get_Combat_Rating() >= Object.Get_Type().Get_Combat_Rating() then
                        Object.Activate_Ability(ability_name, true)
                    end
                end
			end
		else
			Set_Next_State("State_Human_No_Autofire")
		end
	end				
end