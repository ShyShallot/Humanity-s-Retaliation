-- $Id: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/AI/SpaceMode/TacticalMultiplayerBuildSpaceUnitsGeneric.lua#5 $
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
-- (C) Petroglyph Games, Inc.
--
--
--  *****           **                          *                   *
--  *   **          *                           *                   *
--  *    *          *                           *                   *
--  *    *          *     *                 *   *          *        *
--  *   *     *** ******  * **  ****      ***   * *      * *****    * ***
--  *  **    *  *   *     **   *   **   **  *   *  *    * **   **   **   *
--  ***     *****   *     *   *     *  *    *   *  *   **  *    *   *    *
--  *       *       *     *   *     *  *    *   *   *  *   *    *   *    *
--  *       *       *     *   *     *  *    *   *   * **   *   *    *    *
--  *       **       *    *   **   *   **   *   *    **    *  *     *   *
-- **        ****     **  *    ****     *****   *    **    ***      *   *
--                                          *        *     *
--                                          *        *     *
--                                          *       *      *
--                                      *  *        *      *
--                                      ****       *       *
--
--/////////////////////////////////////////////////////////////////////////////////////////////////
-- C O N F I D E N T I A L   S O U R C E   C O D E -- D O   N O T   D I S T R I B U T E
--/////////////////////////////////////////////////////////////////////////////////////////////////
--
--              $File: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/AI/SpaceMode/TacticalMultiplayerBuildSpaceUnitsGeneric.lua $
--
--    Original Author: James Yarrow
--
--            $Author: James_Yarrow $
--
--            $Change: 54441 $
--
--          $DateTime: 2006/09/13 15:08:39 $
--
--          $Revision: #5 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("pgevents")
require("HALOFunctions")

function Definitions()
	
	Category = "Tactical_Multiplayer_Build_Space_Units_Generic"
	IgnoreTarget = true
	TaskForce = { 
		{
		"ReserveForce"
		
		,"Fighter | Bomber = 0,4"
		,"Corvette | Frigate = 0,10"
		,"Capital = 0,8"
		,"SpaceHero = 0,5"
		,"Super = 0,1"
		,"ES_Enhanced_Shielding_L1_Upgrade | ES_Enhanced_Shielding_L2_Upgrade | ES_Improved_Weapons_L1_Upgrade | ES_Improved_Weapons_L2_Upgrade | ES_Improved_Weapons_L3_Upgrade | ES_Improved_Defenses_L1_Upgrade | ES_Improved_Defenses_L2_Upgrade = 0,7"
		,"RS_Improved_Weapons_L1_Upgrade | RS_Improved_Weapons_L2_Upgrade | RS_Improved_Weapons_L3_Upgrade | RS_Improved_Defenses_L1_Upgrade | RS_Improved_Defenses_L2_Upgrade | RS_Improved_Defenses_L3_Upgrade = 0,6"
		},
		
	}
	RequiredCategories = {"Fighter | Bomber | Corvette | Frigate | Capital | SpaceHero"}
	AllowFreeStoreUnits = false

end

function ReserveForce_Thread()
			
	BlockOnCommand(ReserveForce.Produce_Force())
	ReserveForce.Set_Plan_Result(true)
	ReserveForce.Set_As_Goal_System_Removable(false)

	-- Give some time to accumulate money.
	tech_level = PlayerObject.Get_Tech_Level()
	DebugMessage("Current Tech Level: %s", tostring(tech_level))
	diff = PlayerObject.Get_Difficulty()
	DebugMessage("Current Difficulty: %s", tostring(diff))
	min_credits, max_sleep_seconds = Calculate_Credit_Sleep_Time(tech_level, diff, PlayerObject)
	current_sleep_seconds = 0
	if (min_credits ~= 0 and max_sleep_seconds ~= 0) or (min_credits ~= nil and max_sleep_seconds ~= nil) then
		while (PlayerObject.Get_Credits() < min_credits) and (current_sleep_seconds < max_sleep_seconds) do
			current_sleep_seconds = current_sleep_seconds + 1
			Sleep(1)
		end
	end

	ScriptExit()
end

function SuicideForce_Thread()
	Create_Thread("AI_Is_Overun")
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
