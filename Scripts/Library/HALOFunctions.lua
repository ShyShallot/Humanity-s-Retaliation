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

function Deal_Unit_Damage(object, damage_to_deal, hardpoint_to_damage, sfx_event_to_play) -- Already a function but this looks better
    if Get_Game_Mode() == "Galactic" then
        DebugMessage("%s -- This function is unusable in Galactic Conquest", tostring(Script))
        ScriptExit()
    end
    if hardpoint_to_damage ~= nil then
        object.Take_Damage(damage_to_deal, tostring(hardpoint_to_damage))
    else 
        object.Take_Damage(damage_to_deal) 
    end

    if sfx_event_to_play ~= nil then
        object.Play_SFX_Event(tostring(sfx_event_to_play))
    else DebugMessage("%s -- No SFX Set, Continuing Script", tostring(Script)) end
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

function Check_Game_Mode(game_mode_to_check_for) 
    gamemode_string = tostring(game_mode_to_check_for)
    if Get_Game_Mode() ~= gamemode_string then 
        return false
    else 
        return true
    end
end

function Is_Valid_Category(object, cat_1, cat_2, cat_3, cat_4, cat_5)
    category_valid = 0

    if cat_1 ~= nil then
        if object.Is_Category(cat_1) then
            category_valid = category_valid + 1
        end
    end

    if cat_2 ~= nil then
        if object.Is_Category(cat_2) then
            category_valid = category_valid + 1
        end
    end

    if cat_3 ~= nil then
        if object.Is_Category(cat_3) then
            category_valid = category_valid + 1
        end
    end

    if cat_4 ~= nil then 
        if object.Is_Category(cat_4) then
            category_valid = category_valid + 1
        end
    end

    if cat_5 ~= nil then 
        if object.Is_Category(cat_5) then
            category_valid = category_valid + 1
        end
    end

    if category_valid >= 1 then
        return true
    else
        return false
    end

end

function Get_Unit_Props_From_Table(table)
    for k, unit in pairs(table) do
        if TestValid(unit) then
            return unit
        end
    end
end

function Object_Firepower(object) 
    if TestValid(object) then
        firepower = object.Get_Type().Get_Combat_Rating()
    end
    return firepower
end