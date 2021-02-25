require("HALOFunctions")
-- Script is used for Humanity's Retaliation 
-- Boarding Script is written by ShyShallot, If you wish to use this script please contact the Project Gold Team via Discord
-- Any use of this script without permission will not be fun for offending party.
-- Any Modifications of this Script for Submods of Humanity's Retliation are allowed as long as they stay in this mod 
-- Even if you modify this script for a submod, you still do not have permission to use else where
-- Lua Doc: https://stargate-eaw.de/media/kunena/attachments/92/LuacommandsinFoC.pdf

-- Please note this script is a shithole, please do not touch/modify this script unless you know exactly what your doing
-- sneezing on this script may cause it to fucking break :)
function Define_Transport_Table()
    transports_in_use = {}
    child_object = {}
    return transports_in_use, child_object
end

function Service_Transport(unit, transport_list)
    DebugMessage("%s -- Servicing Transport", tostring(Script))
    if (TestValid(unit)) and (TestValid(transport_list)) then
        DebugMessage("%s -- Unit is Provided and is Valid", tostring(Script))
        table.insert(transport_list, unit)
        if table.getn(transport_list) > 0 then
            for _, transport in pairs(transport_list) do
                if TestValid(transport) then
                    DebugMessage("%s -- Transport Valid", tostring(Script))
                    if unit == transport then
                        DebugMessage("%s -- Unit is equal to transport, do nothing", tostring(Script))
                        return false
                    else 
                        DebugMessage("%s -- Adding Unit to Table", tostring(Script))
                        table.insert(transport_list, unit) 
                    end
                end
            end
        end
    end
    return transport_list
end


function Is_Unit_In_Use(table, unit)
    for _, transport in pairs(table) do
        if TestValid(transport) then
            if TestValid(unit) then
                if transport == unit then
                    return true
                else return false end
            end
        end
    end
end

function Find_Transport_Not_In_use(table, player)
    if player.Get_Faction_Name() == "REBEL" then
        unit_to_search = Find_All_Objects_Of_Type("UNSC_Mining_Transport")
    else
        unit_to_search = Find_All_Objects_Of_Type("COVN_Mining_Transport")
    end
    for _, transport in pairs(table) do
        if TestValid(transport) and TestValid(unit_to_search) then
            if unit_to_search == transport then
                return false
            else return unit_to_search end
        end
    end
end

--[[function Transport_Protection_Upgrade(transport, player)
    if player.Get_Faction_Name() == "REBEL" then
        protect_upgrade = Find_First_Object("RS_Econ_Transport_Protection_Upgrade")
        transport_protection_type = Find_Object_Type("UNSC_Mining_Transport_Protector")
        DebugMessage("Current Transport Protector Type: %s", tostring(transport_protection_type))
    else
        protect_upgrade = Find_First_Object("ES_Econ_Transport_Protection_Upgrade")
        transport_protection_type = Find_Object_Type("COVN_Mining_Transport_Protector")
        DebugMessage("Current Transport Protector Type: %s", tostring(transport_protection_type))
    end
    if TestValid(protect_upgrade) then
        transport_protecter = Spawn_Transport_From_Type(transport_protection_type, transport, player)
        DebugMessage("Current Transport Protector: %s", tostring(transport_protecter))
        return transport_protecter
    end
end

function Transport_Protection_Check(upgrade, protector)
    if TestValid(upgrade) and TestValid(protector) then
        DebugMessage("%s -- Both the Upgrade and Protecter are alive, despawning", tostring(Script))
        has_been_bought = 1
        upgrade.Despawn() -- We immediatly despawn the upgrade, so that we can build it again
    elseif TestValid(upgrade) and (not TestValid(protector)) then
        DebugMessage("%s -- Current Protecter Status: Upgrade alive, Transport Not Alive", tostring(Script))
        return false
    elseif (not TestValid(upgrade)) and TestValid(protector) then
        DebugMessage("%s -- Current Protecter Status: Transport is Alive and not upgrade", tostring(Script))
        if has_been_bought == 1  then
            DebugMessage("%s -- Upgrade Dead, Transport Alive and upgrade has been bought", tostring(Script))
            return true
        else
            return false
        end
    elseif (not TestValid(upgrade)) and (not TestValid(protector)) then
        DebugMessage("%s -- Current Protecter Status: Neither are alive", tostring(Script))
        return false
    end
    return false
end ]]

function Spawn_Transport_From_Type(type, object, player) -- Function Exists because EAW
    transports = Spawn_Unit(type, Object, player)
    for _, unit in pairs(transports) do -- Spawn_Unit returns a table for some god damn reason so have to do this
        if TestValid(unit) then
            return unit
        end
    end
end