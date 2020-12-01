-- Script is used for Humanity's Retaliation 
-- This script contains a set of custom functions used by various scripts. Made by ShyShallot
-- Any use of this script without permission will not be fun for offending party.
-- Lua Doc: https://stargate-eaw.de/media/kunena/attachments/92/LuacommandsinFoC.pdf



function Return_Chance(value_to_check) -- Returns true or false
    if value_to_check > 1 then
        DebugMessage("%s -- ERROR Value to Check cannot be greater than 1, please fix yo shit", tostring(Script))
        DebugMessage("Current Value to Check: %s", tostring(value_to_check))
        ScriptExit()
    end
    Chance = GameRandom(0, 1) 
    if Chance >= value_to_check then 
        return true
    end
end

function Deal_Unit_Damage(object, damage_to_deal, time_to_sleep, sfx_event_to_play) -- Already a function but this looks better
    if Get_Game_Mode() == "Galactic" then
        DebugMessage("%s -- This function is unusable in Galactic Conquest", tostring(Script))
        ScriptExit()
    end
    object.Take_Damage(damage_to_deal)
    if sfx_event_to_play ~= nil then
        object.Play_SFX_Event(tostring(sfx_event_to_play))
    else DebugMessage("%s -- No SFX Set, Continuing Script", tostring(Script)) end
end

function Deal_Unit_Damage_Seconds(object, damage_to_deal, time_to_sleep, sfx_event_to_play) -- Uses Deal_Unit_Damage but with SFX and Sleep
    Deal_Unit_Damage(object, damage_to_deal)
    if sfx_event_to_play ~= nil then
        object.Play_SFX_Event(tostring(sfx_event_to_play))
    else DebugMessage("%s -- No SFX Set, Continuing Script", tostring(Script)) end
    Sleep(time_to_sleep)
end

function Get_Target_Distance(point_a, point_b) -- Already a function but looks cleaner
    distance = point_a.Get_Distance(point_b)
    return distance
end

function Is_Target_Affected_By_Ability(object, ability_name) 
    if object.Is_Under_Effects_Of_Ability(ability_name) and TestValid(object) then
        return true
    end
end
