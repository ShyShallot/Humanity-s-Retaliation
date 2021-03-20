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

function Return_Faction(wrapper)
    playerE = Find_Player("Empire") -- This is enefficant as fuck but as long as there isnt like 15 factions its fine
    playerR = Find_Player("Rebel")
    if (wrapper ==  playerE) or (wrapper == playerR) then
        return wrapper.Get_Faction_Name()
    else
        return wrapper.Get_Type().Get_Faction_Name()
    end
end

function Tactical_Tech_Level(player) -- Get the players Tech Level in Tactical Battles, 
    --i think you use player.Get_Tech_Level() but this ignores the rebels 0-4 and empires 1-5
    if Return_Faction(player) == "EMPIRE" then -- Could use for statements but too lazy to debug rn
        if TestValid(Find_First_Object("Skirmish_Empire_Star_Base_1")) then
            tech_level = 1
            return tech_level
        elseif TestValid(Find_First_Object("Skirmish_Empire_Star_Base_2")) then
            tech_level = 2
            return tech_level
        elseif TestValid(Find_First_Object("Skirmish_Empire_Star_Base_3")) then
            tech_level = 3
            return tech_level
        elseif TestValid(Find_First_Object("Skirmish_Empire_Star_Base_4")) then
            tech_level = 4
            return tech_level
        elseif TestValid(Find_First_Object("Skirmish_Empire_Star_Base_5")) then
            tech_level = 5
            return tech_level
        end
    elseif Return_Faction(player) == "REBEL" then
        if TestValid(Find_First_Object("Skirmish_Rebel_Star_Base_1")) then
            tech_level = 1
            return tech_level
        elseif TestValid(Find_First_Object("Skirmish_Rebel_Star_Base_2")) then
            tech_level = 2
            return tech_level
        elseif TestValid(Find_First_Object("Skirmish_Rebel_Star_Base_3")) then
            tech_level = 3
            return tech_level
        elseif TestValid(Find_First_Object("Skirmish_Rebel_Star_Base_4")) then
            tech_level = 4
            return tech_level
        elseif TestValid(Find_First_Object("Skirmish_Rebel_Star_Base_5")) then
            tech_level = 5
            return tech_level
        end
    end
end

function Get_Unit_Props_From_Table(table)
    for k, unit in pairs(table) do
        if TestValid(unit) then
            return unit
        end
    end
end

function Object_Firepower(object) -- Easier then Object.Get_Type().Get_Combat_Rating()
    if TestValid(object) then
        firepower = object.Get_Type().Get_Combat_Rating()
    end
    return firepower
end

function Unit_List_Combat_Power(list)
    totalcombatpower = 0
    for k, unit in pairs(list) do
        if TestValid(unit) then
            totalcombatpower = totalcombatpower + Object_Firepower(unit)
        end
    end
    if totalcombatpower > 0 then
        return totalcombatpower
    end
end
