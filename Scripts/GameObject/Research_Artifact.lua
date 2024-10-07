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

            local artifacts_dug = GlobalValue.Get("Artifacts_Dug")

            artifacts_dug = artifacts_dug + 1

            GlobalValue.Set("Artifacts_Dug", artifacts_dug)
            
            local dig_up_unit = Find_First_Object("ARTIFACT_DIG_UP")

            if dig_up_unit ~= nil then
                dig_up_unit.Despawn()
            end

            Object.Despawn()
        end
    end
end