-- $Id: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/AI/SpaceMode/DestroyUnit.lua#1 $
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
--              $File: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/AI/SpaceMode/DestroyUnit.lua $
--
--    Original Author: James Yarrow
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

function Definitions()
	DebugMessage("%s -- In Definitions", tostring(Script))
	
	AllowEngagedUnits = false
	MinContrastScale = 1.1
	MaxContrastScale = 3.0
	Category = "Build_Capital_Ship"
	TaskForce = {
	    {
	   	    "MainForce"			
            ,"DenyHeroAttach"
	        ,"Capital = 1"
	    },
        {
            "MainForce_Normal"
            ,"DenyHeroAttach"
            ,"Capital = 1"
        },
        {
            "Mainforce_Hard"
            ,"DenyHeroAttach"
            ,"Capital = 2"
        }
	}
	
	ChangedTarget = false
	AttackingShields = false
	DropCurrentTarget = false

	kill_target = nil

	DebugMessage("%s -- Done Definitions", tostring(Script))
end



function MainForce_Thread()
	DebugMessage("%s -- In MainForce_Thread.", tostring(Script))
    
	BlockOnCommand(MainForce.Produce_Force())
    
    if PlayerObject.Get_Difficulty() == "Normal" then  
	    QuickReinforce(PlayerObject, AITarget, MainForce, MainForce_Normal)
    elseif PlayerObject.Get_Difficulty() == "Hard" then
        QuickReinforce(PlayerObject, AITarget, MainForce, Mainforce_Hard)
    else
        QuickReinforce(PlayerObject, AITarget, MainForce)
    end
	
	MainForce.Enable_Attack_Positioning(true)
	DebugMessage("MainForce constructed at stage area!")

	MainForce.Set_Plan_Result(true)
	DebugMessage("%s -- MainForce Done!  Exiting Script!", tostring(Script))
	ScriptExit()
end

