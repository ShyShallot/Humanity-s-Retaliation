-- Script is used for Humanity's Retaliation 
-- This script contains a set of custom functions used by various scripts. Made by ShyShallot
-- Any use of this script without permission will not be fun for offending party.
-- Lua Doc: https://stargate-eaw.de/media/kunena/attachments/92/LuacommandsinFoC.pdf
require("PGStateMachine")
require("HALOFunctions")
function Definitions()
	ServiceRate = 1
	Define_State("State_Init", State_Init);
end

function State_Init(message) 
    if message == OnEnter then 
        neutral = Find_Player("Neutral")
        faction = Object.Get_Owner()
        if Return_Faction(faction) == "EMPIRE" then
            function_list_e()
        else
            function_list_r()
        end
        -- Netural stuff here
        ScriptExit() -- Always have this at the end, we dont want the script to run when we don't need it
    end
end

function function_list_e()
    --Create_Power_Systems_Marker_E()
end

function function_list_r()
    --Create_Power_Systems_Marker_R()
end

--[[function Create_Power_Systems_Marker_E()
    marker = Find_Object_Type("Power_Systems_Marker_E")
    Create_Generic_Object(marker, Object.Get_Position(), faction)
end

function Create_Power_Systems_Marker_R()
    marker = Find_Object_Type("Power_Systems_Marker_R")
    Create_Generic_Object(marker, Object.Get_Position(), faction)
end --]]