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
    transport_table, child_table = Define_Transport_Table()
    DebugMessage("%s -- Unit Table", tostring(transport_table))
    should_run = 0
    ability_name = "DEPLOY"
    has_spawned = false
end

function State_Init(message)
	if message == OnEnter then
        DebugMessage("%s -- In On Enter", tostring(Script))
        player = Object.Get_Owner()
        unsc_facility = Find_Object_Type("Custom_Rebel_Mineral_Extractor")
        covie_facility = Find_Object_Type("Custom_Empire_Mineral_Extractor")
        if (Object.Get_Type() == unsc_facility) or (Object.Get_Type() == covie_facility) then
            Create_Thread("Spawn_Transport", player, transport_table)
        end
    elseif message == OnUpdate then
        DebugMessage("%s -- In OnUpdate", tostring(Script))
        if Object.Get_Type() == unsc_facility then
            DebugMessage("%s -- Player faction is UNSC", tostring(Script))
            credits_to_give, time_to_sleep = UNSC_Credits_To_Give()
        elseif Object.Get_Type() == covie_facility then
            DebugMessage("%s -- Player Faction is Covie", tostring(Script))
            credits_to_give, time_to_sleep = Covie_Credits_To_Give()
        else
            ScriptExit()
        end
        if not TestValid(transport) and has_spawned == true then -- Respawn the Transport
            DebugMessage("%s -- Our Transport Died, Running Respawn Sleep", tostring(Script))
            respawn_time = time_to_sleep * 2
            Sleep(respawn_time)
            player.Give_Money(-800)
            DebugMessage("%s -- Subtracting Balance for new Transport", tostring(Script))
            DebugMessage("%s -- Sleep Done, Respawning", tostring(Script))
            if (Object.Get_Type() == unsc_facility) or (Object.Get_Type() == covie_facility) then
                Create_Thread("Spawn_Transport", player, transport_table)
            end
        end
        Sleep(1)
    end
end

function Spawn_Transport() 
    DebugMessage("%s -- Spawning Transport", tostring(Script))
    if player.Get_Faction_Name() == "REBEL" then
        DebugMessage("%s -- Player Faction is UNSC", tostring(Script))
        transport_type = Find_Object_Type("UNSC_Mining_Transport")
        DebugMessage("%s -- Transport Type", tostring(transport_type))
        DebugMessage("%s -- Spawning Unit", tostring(Script))
        transport = Spawn_Transport_From_Type(transport_type, Object, player)
        DebugMessage("%s -- Found Transport", tostring(transport))
        Service_Transport(transport, transport_table)
        has_spawned = true
        should_run = 1
        Skirmish_Econ_Line(transport)
    else
        DebugMessage("%s -- Player Faction is Covie", tostring(Script))
        transport_type = Find_Object_Type("COVN_Mining_Transport")
        DebugMessage("%s -- Transport Type", tostring(transport_type))
        DebugMessage("%s -- Spawning Unit", tostring(Script))
        transport = Spawn_Transport_From_Type(transport_type, Object, player)
        DebugMessage("%s -- Found Transport", tostring(transport))
        Service_Transport(transport, transport_table)
        has_spawned = true
        should_run = 1
        Skirmish_Econ_Line(transport)
    end
end

function Skirmish_Econ_Line(transport)
    DebugMessage("%s -- Running Econ Line", tostring(Script))
    DebugMessage("%s -- Transport in Econ Line", tostring(transport))
    station = player.Get_Space_Station()
    transport.Activate_Ability(ability_name, true)
    Sleep(8)
    DebugMessage("%s -- Moving Transport First Time", tostring(Script))
    transport_moved, target = Transport_Move(station, transport, ability_name)
    while (TestValid(Object)) and (should_run == 1) do
        DebugMessage("%s -- Station to Go to", tostring(station))
        while (TestValid(transport)) and (should_run == 1) do
            --protection_upgrade, transport_protecter = Transport_Protection_Upgrade(transport, player)
            Sleep(1)
            if not TestValid(transport) then
                DebugMessage("%s -- Transport Dead, culling invalid transports from list and killing thread")
                Cull_Unit_List(transport_table)
                should_run = 0
                Thread.Kill(Thread.Get_Current_ID()) -- Put at bottom to make sure the stuff in the If gets ran
            end
            if transport_moved then
                DebugMessage("%s -- Transport finished moving", tostring(Script))
                Transport_Arrive(target, transport, ability_name, time_to_sleep, credits_to_give)
                if target == station then
                    DebugMessage("%s -- We arrived at station, moving to facility", tostring(Script))
                    transport_moved, target = Transport_Move(Object, transport, ability_name)
                else
                    DebugMessage("%s -- We arrived at the Mining Facility, moving to station", tostring(Script))
                    transport_moved, target = Transport_Move(station, transport, ability_name)
                end
            else
                DebugMessage("%s -- Distance to Station", tostring(transport.Get_Distance(station)))
                DebugMessage("%s -- Distance to Mining Facility", tostring(transport.Get_Distance(Object)))
                DebugMessage("%s -- Unit is currently moving, do not disturb", tostring(Script))
                Sleep(1)
            end
        end
        should_run = 0
        Sleep(3)
    end
end

function Covie_Credits_To_Give()
    covie_upgrade_l1 = Find_First_Object("ES_Increased_Supplies_L1_Upgrade")
    covie_upgrade_l2 = Find_First_Object("ES_Increased_Supplies_L2_Upgrade")
    if (not TestValid(covie_upgrade_l1) and (not TestValid(covie_upgrade_l2))) then
        DebugMessage("%s -- Player has no Econ Upgrades", tostring(Script))
        covie_credits_to_give = 600
        sleepTime = 15
        DebugMessage("%s -- Credits to give", tostring(covie_credits_to_give))
        DebugMessage("%s -- Sleep Time", tostring(sleepTime))
        return covie_credits_to_give, sleepTime
    end
    if TestValid(covie_upgrade_l1) and (not TestValid(covie_upgrade_l2)) then
        DebugMessage("%s -- Player has Level 1 Econ Upgrade", tostring(Script))
        covie_credits_to_give = 1250
        sleepTime = 11
        DebugMessage("%s -- Credits to give", tostring(covie_credits_to_give))
        DebugMessage("%s -- Sleep Time", tostring(sleepTime))
        return covie_credits_to_give, sleepTime
    end
    if TestValid(covie_upgrade_l2) then
        DebugMessage("%s -- Player has Level 2 Econ Upgrade", tostring(Script))
        covie_credits_to_give = 1600
        sleepTime = 8
        DebugMessage("%s -- Credits to give", tostring(covie_credits_to_give))
        DebugMessage("%s -- Sleep Time", tostring(sleepTime))
        return covie_credits_to_give, sleepTime
    end
end

function UNSC_Credits_To_Give()
    unsc_upgrade_l1 = Find_First_Object("RS_Increased_Supplies_L1_Upgrade")
    unsc_upgrade_l2 = Find_First_Object("RS_Increased_Supplies_L2_Upgrade")
    if (not TestValid(unsc_upgrade_l1) and (not TestValid(unsc_upgrade_l2))) then
        DebugMessage("%s -- Player has no Econ Upgrades", tostring(Script))
        unsc_credits_to_give = 900
        sleepTime = 15
        DebugMessage("%s -- Credits to give", tostring(unsc_credits_to_give))
        DebugMessage("%s -- Sleep Time", tostring(sleepTime))
        return unsc_credits_to_give, sleepTime
    end
    if TestValid(unsc_upgrade_l1) and (not TestValid(unsc_upgrade_l2)) then
        DebugMessage("%s -- Player has Level 1 Econ Upgrade", tostring(Script))
        unsc_credits_to_give = 1350
        sleepTime = 11
        DebugMessage("%s -- Credits to give", tostring(unsc_credits_to_give))
        DebugMessage("%s -- Sleep Time", tostring(sleepTime))
        return unsc_credits_to_give, sleepTime
    end
    if TestValid(unsc_upgrade_l2) then
        DebugMessage("%s -- Player has Level 2 Econ Upgrade", tostring(Script))
        unsc_credits_to_give = 1750
        sleepTime = 8
        DebugMessage("%s -- Credits to give", tostring(unsc_credits_to_give))
        DebugMessage("%s -- Sleep Time", tostring(sleepTime))
        return unsc_credits_to_give, sleepTime
    end
end

function Transport_Arrive(target_location, object, ability_name, sleepTime, credits)
    DebugMessage("%s -- Transport has Arrived Running", tostring(Script))
    object.Activate_Ability(ability_name, true)
    Sleep(sleepTime)
    if target_location.Get_Type() == player.Get_Space_Station().Get_Type() then
        DebugMessage("%s -- We arrived at our Station, Giving Credits", tostring(Script))
        player.Give_Money(credits)
    end
    object.Activate_Ability(ability_name, false)
    return true
end

function Transport_Move(target_location, object, ability_name)
    DebugMessage("%s -- Transport being called to move", tostring(Script))
    if TestValid(target_location) and TestValid(object) then
        DebugMessage("%s -- Transport is Valid to move", tostring(Script))
        if target_location.Get_Type() == Object.Get_Type() then
            distance_till_arrived = 605
        else
            distance_till_arrived = 400
        end
        object.Activate_Ability(ability_name, false)
        move_to = object.Move_To(target_location)
        moving = true
        DebugMessage("%s -- Moving to", tostring(move_to))
        Sleep(1)
        while moving == true do
            Sleep(1)
            --if TestValid(protector) then
            --    protector.Move_To(object)
            --end
            if move_to and TestValid(object) then
                if object.Get_Distance(target_location) <= distance_till_arrived then
                    DebugMessage("%s -- Transport Finished Moving", tostring(Script))
                    moving = false
                    return true, target_location
                else
                    DebugMessage("%s -- Transport has finished moving but is not within distance, continuing move", tostring(Script))
                    DebugMessage("Distance to Target Location: %s", tostring(object.Get_Distance(target_location)))
                    move_to = object.Move_To(target_location)
                end
            elseif not TestValid(object) then
                moving = false 
            end
        end
    end
end
