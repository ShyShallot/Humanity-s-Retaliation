require("PGBaseDefinitions")
require("PGStateMachine")
require("HALOFunctions")
-- Script is used for Humanity's Retaliation 
-- This a simple script for Autofire and to tell the AI When to use the ability
-- Any use of this script without permission will not be fun for offending party.
-- Any Modifications of this Script for Submods of Humanity's Retliation are allowed as long as they stay in this mod 
-- Even if you modify this script for a submod, you still do not have permission to use else where

-- Lua Doc: https://stargate-eaw.de/media/kunena/attachments/92/LuacommandsinFoC.pdf

function Definitions()
    ServiceRate = 1

    Define_State("State_Init", State_Init);
    DebugMessage("%s -- In Definitions", tostring(Script))
    

end

function State_Init(message)
    if message == OnEnter then
        if Get_Game_Mode() == "Galactic" then
            GlobalValue.Set("Last_Planet", Object.Get_Planet_Location().Get_Type().Get_Name())

            GlobalValue.Set("Global_Artifact_Cooldown", 1)
        end
    end
end