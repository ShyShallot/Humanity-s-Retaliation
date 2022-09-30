require("PGStateMachine")
require("HALOFunctions")
require("PGBaseDefinitions")
require("HALOAIFunctions") 
-- Script is used for Humanity's Retaliation 
-- CarrierAI Script is written by ShyShallot, If you wish to use this script please contact the Project Gold Team via Discord
-- Any use of this script without permission will not be fun for offending party.
-- Any Modifications of this Script for Submods of Humanity's Retliation are allowed as long as they stay in this mod 
-- Even if you modify this script for a submod, you still do not have permission to use else where
-- Lua Doc: https://stargate-eaw.de/media/kunena/attachments/92/LuacommandsinFoC.pdf

function Definitions()
    ServiceRate = 1
	Define_State("State_Init", State_Init);
	ability_name = "TURBO"
end

function State_Init(message)
    if message == OnEnter then
        fmessage = "OnEnter"
        DebugMessage("%s -- In OnUpdate", tostring(Script))
		if Object.Get_Owner().Is_Human() then
			if Object.Is_Ability_Active(ability_name) then
                DebugMessage("%s -- Ability Active Running Search for Protection", tostring(Script))
                Create_Thread("CarrierAI")
            end
		else
            ScriptExit()
		end
    end
end

function CarrierAI(message)
    DebugMessage("%s -- Running Carrier AI", tostring(Script))
    while true do
        DebugMessage("%s -- In fOnUpdate", tostring(Script))
        Search_For_Protection()
        Sleep(ServiceRate)
    end  
end

function Search_For_Protection()
    player = Object.Get_Owner()
    if TestValid(Object) then
        nearestCapital = Find_Nearest(Object, "Capital | Super", player, true)
        findInfinity = Find_First_Object("UNSC_INFINITY")
        DebugMessage("Nearest Capital Ship: %s ", tostring(nearestCapital))
        if TestValid(findInfinity) and player.Get_Faction_Name() == "REBEL" then
            Object.Move_To(findInfinity)
            Object.Play_SFX_Event("Unit_Move_Nebulon");
        else
            if TestValid(nearestCapital) then
                DebugMessage("Moving to Nearest Friendly", tostring(nearestCapital))
                Object.Move_To(nearestCapital)
                Object.Play_SFX_Event("Unit_Move_Nebulon");
            else
                friendlyFrigates = Find_All_Objects_Of_Type(player, "Frigate");
                for i, frig in friendlyFrigates do
                    nearestEnemyToFrig = Find_Nearest(frig, "Corvette | Frigate | Capital | Super",player,false);
                    if(frig.Get_Distance(nearestEnemyToFrig) > 2000) then
                        Object.Move_To(frig);
                        Object.Play_SFX_Event("Unit_Move_Nebulon");
                    end
                end
            end
        end
    end
end
