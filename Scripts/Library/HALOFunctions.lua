-- Main Overall Custom Functions Script for LOZ
-- Lua Doc: https://stargate-eaw.de/media/kunena/attachments/92/LuacommandsinFoC.pdf
require("PGBase")

function Return_Chance(value_to_check, factor) -- Returns true or false
    if not factor then
        factor = 0.8
    end
    if value_to_check <= 1 then
        chance = GameRandom.Get_Float(0, 1) 
        chance = chance / factor
        DebugMessage("%s -- Generated Chance: %s", tostring(Script), tostring(chance))
        if chance <= value_to_check then -- the value to check is the threshold to our chance, so if you input 0.65 as long as its greater than or equal to it succeeds
            DebugMessage("%s -- %s was Smaller or Equal to: %s", tostring(Script), tostring(value_to_check), tostring(value_to_check))
            return true 
        end
    elseif value_to_check <= 100 and value_to_check >= 1 then
        chance = EvenMoreRandom(0, 100) 
        chance = chance / factor
        if chance <= value_to_check then 
            return true
        end
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

function Return_Faction(obj)
    return obj.Get_Owner().Get_Faction_Name()
end

function Return_Name(obj)
    return obj.Get_Type().Get_Name() -- Return the XML Name
end

function Combat_Power_From_List(list)
    local combat_power = 0
    if list == nil then
        return
    end
    for k, unit in pairs(list) do
        if TestValid(unit) then
            combat_power = combat_power + Object_Firepower(unit)
        end
    end
    if combat_power >= 0 then
        return combat_power
    end
end

function tableMerge(t1, t2) -- Credit to RCIX for this function: https://stackoverflow.com/a/1283608
    for k,v in pairs(t2) do
        if type(v) == "table" then
            if type(t1[k] or false) == "table" then
                tableMerge(t1[k] or {}, t2[k] or {})
            else
                t1[k] = v
            end
        else
            t1[k] = v
        end
    end
    return t1
end

function tableLength(table)
    local count = 0
    for _ in pairs(table) do
        count = count + 1
    end
    return count
end

function getRandomStringKey(Table)
    local keys = {}
    for key, _ in pairs(Table) do
        if type(key) == "string" then
            table.insert(keys, key)
        end
    end

    if table.getn(keys) > 0 then
        local randomIndex = EvenMoreRandom(1, table.getn(keys))
        return keys[randomIndex]
    else
        return nil -- Return nil if there are no string keys in the table
    end
end

function EvenMoreRandom(min,max,count) -- the GameRandom tends to be consistant despite being random, usual min max value, with the count being the amount of random numbers generated to then be randomly chosen
    if count == 0 or count == nil then
        count = 5
    end
    DebugMessage("%s -- Min: %s, Max: %s, Count: %s", tostring(Script),min,max,count)
    local values = {}
    for i = 1, count, 1 do
        values[i] = GameRandom(min,max)
        DebugMessage("%s -- Random Num: %s", tostring(Script),values[i])
    end
    return values[GameRandom(1,count)]
end

function Find_Human_Player()
    empire = Find_Player("EMPIRE")
    rebels = Find_Player("REBEL")

    if empire.Is_Human() and (not rebels.Is_Human()) then
        DebugMessage("%s -- Human player is Empire", tostring(Script))
        return empire
    elseif rebels.Is_Human() and (not empire.Is_Human()) then
        DebugMessage("%s -- Human player is Rebel", tostring(Script))
        return rebels
    end
end

function PrintTable(array)
    for key,pair in pairs(array) do
        DebugMessage("Key: %s, Pair: %s", tostring(key), tostring(pair))
    end
end

function split(str, separator)
    local result = {}
    local start = 1
    
    while true do
        local i, j = string.find(str, separator, start)
        
        if not i then
            table.insert(result, string.sub(str, start))
            break
        end
        
        table.insert(result, string.sub(str, start, i - 1))
        start = j + 1
    end
    
    return result
end

function formatNumberWithCommas(number)
    local formattedNumber = tostring(number)
    local length = string.len(formattedNumber)

    local result = ""
    local count = 0

    for i = length, 1, -1 do
        result = string.sub(formattedNumber, i, i) .. result
        count = count + 1

        if customModulo(count, 3) == 0 and i > 1 then
            result = "," .. result
        end
    end

    return result
end

function customModulo(dividend, divisor)
    local quotient = Dirty_Floor(dividend / divisor)
    local remainder = dividend - (quotient * divisor)
    return remainder
end

function Get_Current_Week()
    return tonumber(Dirty_Floor(Get_Current_Week_Raw() + 0.5))
end

function Get_Current_Week_Raw()
    weekTime = 60
    week = (GetCurrentTime.Galactic_Time() / weekTime)
    return week
end

function Percentage(number, total)
    if total == 0 then
        return 0
    end

    return (number/total) * 100
end

function abs(number)
    if number < 0 then
        return -number
    end

    return number
end
