-- $Id: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/AI/ConquerOpponentPlan.lua#1 $
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
--              $File: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/AI/ConquerOpponentPlan.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: Andre_Arsenault $
--
--            $Change: 37816 $
--
--          $DateTime: 2006/02/15 15:33:33 $
--
--          $Revision: #1 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("pgevents")
require("HALOFunctions")

-- Tell the script pooling system to pre-cache this number of scripts.
ScriptPoolCount = 2

--
-- Galactic Mode Contrast Script
--

function Definitions()
	MinContrastScale = 1.25
	MaxContrastScale = 1.75

	Category = "Conquer_Opponent | Capture_Installation_05 | Conquer_Empty_Planet"
	TaskForce = {
	-- First Task Force
	{
		"SpaceForce"				
		,"Frigate | Capital | Corvette | Bomber = 100%"
	}
	}
	RequiredCategories = {"Frigate | Capital | Bomber" }

	PerFailureContrastAdjust = 0.15
	
	SpaceSecured = true
	WasConflict = false
	
	difficulty = PlayerObject.Get_Difficulty()

	sleeps = {
		["Easy"] = 240,
		["Normal"] = 180,
		["Hard"] = 120
	}

	sleep_duration = sleeps[difficulty]

end

function SpaceForce_Thread()
	-- Since we're using plan failure to adjust contrast, we're 
	-- only concerned with failures in battle. Default the 
	-- plan to successful and then 
	-- only on the event of our task force being killed is the
	-- plan set to a failed state.

	SpaceSecured = false

	DebugMessage("SpaceForce: %s", tostring(SpaceForce))

	SpaceForce.Set_Plan_Result(true)

	if SpaceForce.Are_All_Units_On_Free_Store() then
		DebugMessage("SpaceForce is in Free Store")
		AssembleForce(SpaceForce)
	else
		DebugMessage("We need to produce the required units")
		BlockOnCommand(SpaceForce.Produce_Force())
		return
	end

	DebugMessage("Moving units to: %s", tostring(target))
	SpaceForceMovement = BlockOnCommand(SpaceForce.Move_To(Target))

	while not SpaceForceMovement.isFinished() do
		Sleep(1)
	end

	WasConflict = true
	if SpaceForce.Get_Force_Count() == 0 then
		DebugMessage("All units dead")
		SpaceForce.Set_Plan_Result(false)		
		Exit_Plan_With_Possible_Sleep()
	end

	DebugMessage("We took the planet")
			
	SpaceSecured = true
	
	SpaceForce.Release_Forces(1.0)

	Exit_Plan_With_Possible_Sleep()
end


function Exit_Plan_With_Possible_Sleep()
	if SpaceForce then
		SpaceForce.Release_Forces(1.0)
	end
	if WasConflict then
		if PlayerObject.Get_Faction_Name() == "REBEL" then
			sleep_duration = sleep_duration * 2
		end
		Sleep(sleep_duration)
	end
	ScriptExit()
end

function SpaceForce_Production_Failed(tf, failed_object_type)
	
end
