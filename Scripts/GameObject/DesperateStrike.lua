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
    Define_State("State_AI_Autofire", State_AI_Autofire)
    DebugMessage("%s -- In Definitions", tostring(Script))
    

end

function State_Init(message)
    if message == OnEnter then
        DebugMessage("%s -- In Init", tostring(Script))
        layer_manager = require("eaw-layerz/layermanager")
		layer_manager:update_unit_layer(Object,true)
        ability_name = "DEFEND" -- Check if the object calling the script has the ability in the first place
        player = Object.Get_Owner() -- Since we cant Use PlayerObject directly, get the player from the Object calling this script
    elseif message == OnUpdate then
        DebugMessage("%s -- In OnEnter", tostring(Script))
        if player.Is_Human() then 
            if Object.Is_Ability_Autofire(ability_name) then
                if Object.Is_Ability_Ready(ability_name) then
                    Activate_Desperate_Strike(ability_name)
                end
            end
        else 
            DebugMessage("%s -- Running AI Ability", tostring(Script))
            Set_Next_State("State_AI_Autofire")
        end
    end
end

function State_AI_Autofire(message)
    if message == OnUpdate then
        DebugMessage("%s -- Is AI Checking for Ability", tostring(Script))
        if Object.Is_Ability_Ready(ability_name) then -- If Tractor Beam ability is active
            Activate_Desperate_Strike(ability_name)
        end
	end		
end

function Activate_Desperate_Strike(ability_name)
    nearestFriendly = Find_Nearest(Object, "Corvette | Frigate | Capital | Super", player, true)
    nearestEnemy = Find_Nearest(Object, "Corvette | Frigate | Capital | Super", player, false)
    if TestValid(nearestEnemy) and TestValid(nearestFriendly) then
        enemypower = Object_Firepower(nearestEnemy)
        power = Object_Firepower(Object)
        if nearestFriendly.Get_Distance(Object) > 1000 and enemypower > (power / 2) then
            Object.Activate_Ability(ability_name)
        end
    end
end