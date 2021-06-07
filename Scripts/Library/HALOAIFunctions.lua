-- Script is used for Humanity's Retaliation 
-- This script contains a set of custom functions used by various scripts. Made by ShyShallot
-- Any use of this script without permission will not be fun for offending party.
-- Lua Doc: https://stargate-eaw.de/media/kunena/attachments/92/LuacommandsinFoC.pdf
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

function Calculate_AI_FOW_Distance(factor, ai, base)
	diff = ai.Get_Difficulty()
	seeing_distance = base
	if diff == "NORMAL" then
        seeing_distance = base * 1.5
    elseif diff == "HARD" then
        seeing_distance = base * 2
    end
    if factor == 1 or factor == 0 then
        return seeing_distance
    end
    final_distance = seeing_distance * factor
    return final_distance
end

function Calculate_Credit_Sleep_Time(tech, diff, player)
	local faction = Return_Faction(PlayerObject)
	DebugMessage("Current Faction: %s", tostring(faction))
	local min_credits = 2000
	local max_sleep_seconds = 30
	DebugMessage("Min Credits: %s", tostring(min_credits))
	DebugMessage("Max Sleep Time: %s", tostring(max_sleep_seconds))
	if faction == "EMPIRE" then
		fac_credits_multi = 1.5
		fac_sleep_seconds_multi = 2
		DebugMessage("Credit Multiplier based on Faction: %s", tostring(fac_credits_multi))
		DebugMessage("Sleep Multiplier based on Faction: %s", tostring(fac_sleep_seconds_multi))
	else
		fac_credits_multi = 1.15
		fac_sleep_seconds_multi = 1.5
	end
	if Tactical_Tech_Level(PlayerObject) == 1 then
		tech_credits_mutli  = 0.85
		DebugMessage("Credit Multiplier based on Tech: %s", tostring(tech_credits_mutli))
	elseif Tactical_Tech_Level(PlayerObject) == 2 then
		tech_credits_mutli = 1.0
		DebugMessage("Credit Multiplier based on Tech: %s", tostring(tech_credits_mutli))
	elseif  Tactical_Tech_Level(PlayerObject) == 3 then
		tech_credits_mutli = 1.4
		DebugMessage("Credit Multiplier based on Tech: %s", tostring(tech_credits_mutli))
	elseif  Tactical_Tech_Level(PlayerObject) == 4 then
		tech_credits_mutli = 1.65
		DebugMessage("Credit Multiplier based on Tech: %s", tostring(tech_credits_mutli))
	elseif  Tactical_Tech_Level(PlayerObject) == 5 then
		tech_credits_mutli = 1.85
		DebugMessage("Credit Multiplier based on Tech: %s", tostring(tech_credits_mutli))
	end

	diff_credits_multi = 1.15
	diff_sleep_multi = 1.35
	DebugMessage("Credit Multiplier based on Diff: %s", tostring(diff_credits_multi))
	DebugMessage("Sleep Multiplier based on Diff: %s", tostring(diff_sleep_multi))
	if diff == "NORMAL" then
		diff_credits_multi = 1
		diff_sleep_multi = 1.2
		DebugMessage("Credit Multiplier based on Diff: %s", tostring(diff_credits_multi))
		DebugMessage("Sleep Multiplier based on Diff: %s", tostring(diff_sleep_multi))
	elseif diff == "HARD" then
		diff_credits_multi = 0.85
		diff_sleep_multi = 1
		DebugMessage("Credit Multiplier based on Diff: %s", tostring(diff_credits_multi))
		DebugMessage("Sleep Multiplier based on Diff: %s", tostring(diff_sleep_multi))
	end
	
	
	local min_credits = min_credits * fac_credits_multi * tech_credits_mutli * diff_credits_multi
	local max_sleep_seconds = max_sleep_seconds * fac_sleep_seconds_multi * diff_sleep_multi
	DebugMessage("Min Credits: %s", tostring(min_credits))
	DebugMessage("Max Sleep Time: %s", tostring(max_sleep_seconds))
	return min_credits, max_sleep_seconds
end