-- Script is used for Humanity's Retaliation 
-- This script contains a set of custom functions used by various scripts. Made by ShyShallot
-- Any use of this script without permission will not be fun for offending party.
-- Lua Doc: https://stargate-eaw.de/media/kunena/attachments/92/LuacommandsinFoC.pdf
require("PGStateMachine")
function Definitions()

	ServiceRate = 1

	Define_State("State_Init", State_Init);
	Define_State("State_AI_Autofire", State_AI_Autofire)
	Define_State("State_Human_No_Autofire", State_Human_No_Autofire)
	Define_State("State_Human_Autofire", State_Human_Autofire)

	
end

function State_Init(message)
	if message == OnEnter then
		layer_manager = require("eaw-layerz/layermanager")
		layer_manager:update_unit_layer(Object,true)
        ability_name = "SUPER_LASER"
		-- prevent this from doing anything in galactic mode
		if Get_Game_Mode() == "Galactic" then
			ScriptExit()
		end
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
		if Object.Is_Ability_Ready(ability_name) then
			enemy = FindDeadlyEnemy(Object)
			if TestValid(enemy) then
                Object.Activate_Ability(ability_name, enemy)
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
		if Object.Is_Ability_Autofire(ability_name) then
			Set_Next_State("State_Human_Autofire")
		end		
	end
end

function State_Human_Autofire(message)
	if message == OnUpdate then
		if Object.Is_Ability_Autofire(ability_name) then
			if Object.Is_Ability_Ready(ability_name) then
				enemy = FindDeadlyEnemy(Object)
				if TestValid(enemy) then
                    Object.Activate_Ability(ability_name, enemy)
                end
			end
		else
			Set_Next_State("State_Human_No_Autofire")
		end
	end				
end