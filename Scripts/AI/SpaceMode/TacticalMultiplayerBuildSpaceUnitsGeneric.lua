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


function Definitions()
	
	Category = "Tactical_Multiplayer_Build_Space_Units_Generic"
	IgnoreTarget = true
	TaskForce = {
		{
		"ReserveForce"
		,"Fighter | Bomber = 0,8"
		,"Corvette | Frigate = 0,10"
		,"Capital = 0,8"
		,"SpaceHero = 0,1"
		,"Super = 0,1"
		}
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
	min_credits = 2000
	max_sleep_seconds = 30
	if tech_level == 2 then
		min_credits = 4000
		max_sleep_seconds = 50
	elseif tech_level >= 3 then
		min_credits = 6000
		max_sleep_seconds = 80
	end
	
	current_sleep_seconds = 0
	while (PlayerObject.Get_Credits() < min_credits) and (current_sleep_seconds < max_sleep_seconds) do
		current_sleep_seconds = current_sleep_seconds + 1
		Sleep(1)
	end

	ScriptExit()
end