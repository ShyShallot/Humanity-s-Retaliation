require("PGStateMachine")
require("PGSpawnUnits")
require("HALOSkirmishEconLibrary")
-- Script is used for Humanity's Retaliation 
-- This script is written by ShyShallot, If you wish to use this script please contact the Project Gold Team via Discord
-- Any use of this script without permission will not be fun for offending party.
-- Any Modifications of this Script for Submods of Humanity's Retliation are allowed as long as they stay in this mod 
-- Even if you modify this script for a submod, you still do not have permission to use else where
-- Lua Doc: https://stargate-eaw.de/media/kunena/attachments/92/LuacommandsinFoC.pdf

-- Please note this script is a shithole, please do not touch/modify this script unless you know exactly what your doing
-- sneezing on this script may cause it to fucking break :)
function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
	ServiceRate = 1
	Define_State("State_Init", State_Init);
    has_ran = 0
    test_bool = true
end


function State_Init(message)
    if message == OnEnter then -- For Some reason OnEnter runs every time the script loops, but this does not apply to GC Scripts
        DebugMessage("%s -- In OnEnter", tostring(Script))
        if has_ran == 1 then
            DebugMessage("%s -- We ran what we wanted doing nothing")
            return false
        else   
            DebugMessage("%s -- Grabbing Parent", tostring(Script))
            parent = Grab_Parent()
            player = Object.Get_Owner()
            has_ran = 1
        end
    end
    if message == OnUpdate then
        DebugMessage("%s -- In OnUpdate Function", tostring(Script))
        if not TestValid(parent) then
            DebugMessage("%s -- Parent Dead, Commiting Suicide", tostring(Script))
            Deal_Unit_Damage(Object, 1000000000)
        end
        --[[if player.Get_Faction_Name() == "REBEL" then Disables due to too much
            protect_upgrade = Find_First_Object("RS_Econ_Transport_Protection_Upgrade")
        else
            protect_upgrade = Find_First_Object("ES_Econ_Transport_Protection_Upgrade")
        end
        if TestValid(protect_upgrade) then
           transport_protecter = Transport_Protection_Upgrade(Object, player)
        end
        DebugMessage("%s -- Protection Upgrade", tostring(protection_upgrade))
        DebugMessage("%s -- Current Transport Protecter", tostring(transport_protecter))
        if Transport_Protection_Check(protection_upgrade, transport_protecter) then
            DebugMessage("%s -- Protection Upgrade active and Protector is alive, becoming god", tostring(Script))
            Object.Make_Invulnerable(true)
        elseif Transport_Protection_Check(protection_upgrade, transport_protecter) == false then
            DebugMessage("%s -- Protector Dead, revoking admin rights", tostring(Script))
            Object.Make_Invulnerable(false)
        end--]]
    end
end

function Grab_Parent()
    if Object.Get_Owner().Get_Faction_Name() == "REBEL" then   
        parent_mining_facility = Find_Nearest(Object, "Custom_Rebel_Mineral_Extractor")
        if TestValid(parent_mining_facility) then
            return parent_mining_facility
        end
    else
        parent_mining_facility = Find_Nearest(Object, "Custom_Empire_Mineral_Extractor")
        if TestValid(parent_mining_facility) then
            return parent_mining_facility
        end
    end
end
