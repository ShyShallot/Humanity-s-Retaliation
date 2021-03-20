require("HALOFunctions")

function Get_Total_Unit_Table_Combat_Power(unitTable)
    DebugMessage("%s -- Get_Total_Unit_Table_Combat_Power Called, Calculating", tostring(Script))
    local combatPower = 0
    for k, unit in pairs(unitTable) do
        if TestValid(unit) then
            DebugMessage("%s -- Adding Combat Power", tostring(Script))
            combatPower = combatPower + Object_Firepower(unit)
        end
    end
    DebugMessage("%s -- Combat Power", tostring(combatPower))
    return combatPower
end

function Move_To_Nearest_Friendly(self_obj, nearestFriendly, player) -- Dont be afraid to provide a nil value, if its nil it will still work with this function
    if TestValid(nearestFriendly) then
        DebugMessage("Moving to Nearest Friendly", tostring(nearestFriendly))
        self_obj.Move_To(nearestFriendly)
        if self_obj.Get_Distance(nearestFriendly) < 300 then
            self_obj.Stop()
        end
    else
        friendlyFrigates = Find_All_Objects_Of_Type(player, "Frigate")
        totalFirepower = Get_Total_Unit_Table_Combat_Power(friendlyFrigates)
        DebugMessage("%s -- Couldn't Find Nearest Capital Ship, looking for group of frigates", tostring(Script))
        DebugMessage("%s -- Friendly Frigates", tostring(friendlyFrigates))
        if TestValid(friendlyFrigates[1]) then 
            DebugMessage("%s -- Found first Frigate", tostring(Script))
            for k, frigate in pairs(friendlyFrigates) do
                if TestValid(frigate) then
                    DebugMessage("%s -- Checking Combat Power", tostring(Script))
                    DebugMessage("%s -- Total Combat Power", tostring(Get_Total_Unit_Table_Combat_Power(friendlyFrigates)))
                    if totalFirepower >= (Object_Firepower(self_obj) * 2) then
                        if Get_Target_Distance(frigate, friendlyFrigates[1])  < 500 then
                            DebugMessage("%s -- Found Group of Frigates Moving", tostring(Script))
                            self_obj.Move_To(frigate)
                        end
                    end
                end
            end
        end
    end
end

function Calculate_AI_FOW_Distance(factor, ai)
	diff = ai.Get_Difficulty()
	seeing_distance = 3000
	if diff == "NORMAL" then
        seeing_distance = 4000
    elseif diff == "HARD" then
        seeing_distance = 5500
    end
    if factor == 1 or factor == 0 then
        return seeing_distance
    end
    final_distance = seeing_distance * factor
    return final_distance
end