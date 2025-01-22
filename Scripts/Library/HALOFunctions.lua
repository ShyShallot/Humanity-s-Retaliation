-- Main Overall Custom Functions Script for LOZ
-- Lua Doc: https://stargate-eaw.de/media/kunena/attachments/92/LuacommandsinFoC.pdf
require("PGBase")

function Return_Chance(value_to_check, factor) -- Returns true or false
    if not factor then
        factor = 0.8
    end
    if value_to_check < 1 then
        value_to_check = value_to_check * 100
    end
    local randomValue = EvenMoreRandom(0,100)
    if value_to_check <= randomValue then
        return true
    end
    return false
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
        count = 20
    end
    --DebugMessage("%s -- Min: %s, Max: %s, Count: %s", tostring(Script),min,max,count)
    local values = {}
    for i = 1, count, 1 do
        values[i] = GameRandom.Free_Random(min,max)
        --DebugMessage("%s -- Random Num: %s", tostring(Script),values[i])
    end
    return values[GameRandom.Free_Random(1,count)]
end

function EvenMoreRandomFloat(min,max,count)
    if count == 0 or count == nil then
        count = 20
    end

    if min == nil then
        min = 0
    end

    if max == nil then
        max = 1
    end

    local values = {}

    sum = 0

    for i=1,count, 1 do
        values[i] = GameRandom.Get_Float(min,max)

        sum = sum + values[i]
    end

    return sum/tableLength(values)

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

function Capital_First_Letter(name)
    strings = split(name, "_")
    final_string = ""
    for i, word in strings do
        first_letter = string.upper(string.sub(word,1,1))
        if i <= table.getn(strings) - 1 then
            final_string = final_string .. first_letter .. string.lower(string.sub(word, 2, string.len(word))) .. " "
        else
            final_string = final_string .. first_letter .. string.lower(string.sub(word, 2, string.len(word)))
        end
    end
    return final_string
end


function bubbleSort(tbl)
    local n = table.getn(tbl)
    local swapped = true -- Set swapped to true to enter the loop at least once
    while swapped do
        swapped = false -- Reset swapped flag
        for i = 1, n-1 do
            if tbl[i] > tbl[i+1] then
                tbl[i], tbl[i+1] = tbl[i+1], tbl[i] -- Swap elements
                swapped = true -- Set swapped to true to indicate a swap occurred
            end
        end
    end
end

function median(tbl)
    local temp = {}
    for k, v in pairs(tbl) do
        table.insert(temp, v)
    end
    bubbleSort(temp)
    local n = table.getn(temp)
    if customModulo(n, 2) == 0 then
        return (temp[n/2] + temp[(n/2) + 1]) / 2
    else
        return temp[(n+1)/2]
    end
end

function removeOutliers(data)
    local result = {}
    local medianValue = median(data)
    local deviation = 1.2 -- You can adjust this value based on your requirements

    for _, value in ipairs(data) do
        if abs(value - medianValue) <= deviation * medianValue then
            table.insert(result, value)
        end
    end

    return result
end

function Distance_Between_Positions(first_position,second_position)
    first_x, first_y, first_z = first_position.Get_XYZ()

    second_x, second_y, second_z = second_position.Get_XYZ()

    x_diff = second_x - first_x
    y_diff = second_y - first_y
    z_diff = second_z - first_y

    x_squared = x_diff * x_diff
    y_squared = y_diff * y_diff
    z_squared = z_diff * z_diff

    return square_root(x_squared + y_squared + z_squared)
end

function square_root(n)
    if n == 0 then
        return 0
    end

    local guess = n / 2
    local tolerance = 1e-12 -- Adjust tolerance as needed for precision
    local iterations = 0

    repeat
        local new_guess = (guess + n / guess) / 2
        if abs(new_guess - guess) < tolerance then
            return new_guess
        end
        guess = new_guess
        iterations = iterations + 1
    until iterations > 20 -- Maximum number of iterations to avoid infinite loop (adjust as needed)

    -- If the loop exits without meeting the tolerance, return the last guess
    return guess
end

function Lock_Unit_Type(player,unit_type, lock) -- true = lock, false or unprovided is unlock
    if lock == nil or lock ~= true then
        lock = false
    end

    if GlobalValue.Get("Filter_Active") == 1 then
        return
    end

    if unit_type.Is_Build_Locked(player) and lock then
        return
    end

    if unit_type.Is_Build_Locked(player) ~= true then
        if lock then 
            player.Lock_Tech(unit_type)
        end

        if not lock then
            return
        end
    end
end

function Map_Value(value, iMin, iMax, oMin, oMax)
    if iMin == nil then
        iMin = 0
    end

    if iMax == nil then
        iMax = 1
    end

    if oMin == nil then
        oMin = 0
    end

    if oMax == nil then
        oMax = 1
    end

    return ((value - iMin) / (iMax - iMin)) * (oMax - oMin) + oMin

end

function Lock_Unit(unit_name,player, lock)
    if GlobalValue.Get("Filter_Active") == 1 then
        return
    end

    if lock == nil then
        player.Lock_Tech(Find_Object_Type(unit_name))
    end

    if lock == false then
        player.Unlock_Tech(Find_Object_Type(unit_name))
    end
end

