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
	if message == OnUpdate then
        --DebugMessage("%s -- In OnUpdate", tostring(Script))
		if Object.Get_Owner().Is_Human() then
			if Object.Is_Ability_Active(ability_name) then
                --DebugMessage("%s -- Ability Active Running Search for Protection", tostring(Script))
                Create_Thread("Search_For_Protection")
            end
		else
            --DebugMessage("%s -- AI Called Function, Running Automaticly", tostring(Script))
			Create_Thread("Search_For_Protection")
		end
        Sleep(1)
	end
end

function Search_For_Protection()
    player = Object.Get_Owner()
    if TestValid(Object) then
        nearestFriendly = Find_Nearest(Object, "Capital | Super", player, true)
        findInfinity = Find_First_Object("UNSC_INFINITY")
        --DebugMessage("Nearest Friendly: %s ", tostring(nearestFriendly))
        if TestValid(findInfinity) and player.Get_Faction_Name() == "REBEL" then
            Object.Move_To(findInfinity)
            if Object.Get_Distance(findInfinity) < 300 then
                Object.Stop()
            end
        else
            if TestValid(nearestFriendly) then
                --DebugMessage("Moving to Nearest Friendly", tostring(nearestFriendly))
                Object.Move_To(nearestFriendly)
                if Object.Get_Distance(nearestFriendly) < 300 then
                    Object.Stop()
                end
            else
                friendlyFrigates = Find_All_Objects_Of_Type(player, "Frigate")
                totalFirepower = Get_Total_Unit_Table_Combat_Power(friendlyFrigates)
                --DebugMessage("%s -- Couldn't Find Nearest Capital Ship, looking for group of frigates", tostring(Script))
                --DebugMessage("%s -- Friendly Frigates", tostring(friendlyFrigates))
                if TestValid(friendlyFrigates[1]) then 
                    --DebugMessage("%s -- Found first Frigate", tostring(Script))
                    for k, frigate in pairs(friendlyFrigates) do
                        if TestValid(frigate) then
                            --DebugMessage("%s -- Checking Combat Power", tostring(Script))
                            --DebugMessage("%s -- Total Combat Power", tostring(Get_Total_Unit_Table_Combat_Power(friendlyFrigates)))
                            if totalFirepower >= (Object_Firepower(Object) * 2) then
                                if Get_Target_Distance(frigate, friendlyFrigates[1])  < 500 then
                                    --DebugMessage("%s -- Found Group of Frigates Moving", tostring(Script))
                                    Object.Move_To(frigate)
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end