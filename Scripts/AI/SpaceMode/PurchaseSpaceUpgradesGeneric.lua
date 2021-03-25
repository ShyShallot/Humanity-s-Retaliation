-- $Id: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/AI/SpaceMode/PurchaseSpaceUpgradesGeneric.lua#5 $
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
--              $File: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/AI/SpaceMode/PurchaseSpaceUpgradesGeneric.lua $
--
--    Original Author: James Yarrow
--
--            $Author: James_Yarrow $
--
--            $Change: 55010 $
--
--          $DateTime: 2006/09/19 19:14:06 $
--
--          $Revision: #5 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("pgevents")
require("TacticalMultiplayerBuildSpaceUnitsGeneric")

function Definitions()
	
	Category = "Purchase_Space_Upgrades_Generic"
	IgnoreTarget = true
	TaskForce = {
	{
		"ReserveForce"
		,"DenySpecialWeaponAttach"
		,"DenyHeroAttach"
		,"RS_Improved_Weapons_L1_Upgrade | RS_Improved_Weapons_L2_Upgrade | RS_Improved_Weapons_L3_Upgrade | RS_Increased_Supplies_L1_Upgrade | RS_Increased_Supplies_L2_Upgrade | RS_Improved_Defenses_L1_Upgrade | RS_Improved_Defenses_L2_Upgrade | RS_Improved_Defenses_L3_Upgrade = 0,2"
		,"ES_Increased_Supplies_L1_Upgrade | ES_Increased_Supplies_L2_Upgrade | ES_Improved_Weapons_L1_Upgrade | ES_Improved_Weapons_L2_Upgrade | ES_Improved_Weapons_L3_Upgrade | ES_Hypervelocity_Gun_Use_Upgrade | ES_Improved_Defenses_L1_Upgrade | ES_Improved_Defenses_L2_Upgrade | ES_Enhanced_Shielding_L1_Upgrade | ES_Enhanced_Shielding_L2_Upgrade = 0,2"
	},
	{
		"SuicideForce"
		,"RS_Self_Destruct_Station | ES_Self_Destruct_Station = 1"
	}
	}
	 
	RequiredCategories = {"Upgrade"}
	AllowFreeStoreUnits = false

end

function ReserveForce_Thread()
			
	AI_Is_Overun()
	BlockOnCommand(ReserveForce.Produce_Force())
	ReserveForce.Set_Plan_Result(true)
	ReserveForce.Set_As_Goal_System_Removable(false)

	-- Give some time to accumulate money.
	tech_level = PlayerObject.Get_Tech_Level()
	diff = PlayerObject.Get_Difficulty()
	min_credits, max_sleep_seconds = Calculate_Credit_Sleep_Time(tech_level, diff, PlayerObject)
	if (min_credits ~= 0 and max_sleep_seconds ~= 0) or (min_credits ~= nil and max_sleep_seconds ~= nil) then
		while (PlayerObject.Get_Credits() < min_credits) and (current_sleep_seconds < max_sleep_seconds) do
			current_sleep_seconds = current_sleep_seconds + 1
			Sleep(1)
		end
	end

	ScriptExit()
end


function AI_Is_Overun()
	while EvaluatePerception("Game_Age", PlayerObject) > 60 do
		if Return_Faction(PlayerObject) == "EMPRIE" then
			enemy = Find_Player("REBEL")
		elseif Return_Faction(PlayerObject) == "REBEL" then
			enemy = Find_Player("EMPIRE")
		else
			return
		end
		if TestValid(enemy) then
			enemy_forces = Find_All_Objects_Of_Type(enemy)
			friendly_forces = Find_All_Objects_Of_Type(PlayerObject)
			enemy_combat_power = Get_Total_Unit_Table_Combat_Power(enemy_forces)
			friendly_combat_power = Get_Total_Unit_Table_Combat_Power(friendly_forces)
			combat_power_threshold = friendly_combat_power * 1.5 
			if enemy_combat_power > combat_power_threshold then
				BlockOnCommand(SuicideForce.Produce_Force())
				ScriptExit()
			end
		end
		Sleep(1)
	end
end


