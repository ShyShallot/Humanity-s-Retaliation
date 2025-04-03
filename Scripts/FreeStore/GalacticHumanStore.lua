-- $Id: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/FreeStore/GalacticFreeStore.lua#3 $
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
--              $File: //depot/Projects/StarWars_Expansion/Run/Data/Scripts/FreeStore/GalacticFreeStore.lua $
--
--    Original Author: Brian Hayes
--
--            $Author: James_Yarrow $
--
--            $Change: 56727 $
--
--          $DateTime: 2006/10/24 14:14:26 $
--
--          $Revision: #3 $
--
--/////////////////////////////////////////////////////////////////////////////////////////////////

require("pgcommands")
require("HALOFunctions")

function Base_Definitions()
	DebugMessage("%s -- In Base_Definitions", tostring(Script))

	-- how often does this script get serviced?
	ServiceRate = 45
	UnitServiceRate = 45
	
	Common_Base_Definitions()
	
	-- Percentage of units to move on each service.
	SpaceMovePercent = 0.2
	GroundMovePercent = 0.25

	Global_Unit_List = {}

	Global_Unit_List_Active = false

	if Definitions then
		Definitions()
	end
end

function main()

	DebugMessage("%s -- In main for %s", tostring(Script), tostring(FreeStore))
	
	if FreeStoreService then
		while 1 do
			FreeStoreService()
			PumpEvents()
		end
	end
	
	ScriptExit()
end

function MoveUnit(object)

	return false
end

function On_Unit_Service(object)

	
end

--	// param 1: playerwrapper.
--	// param 2: perception function name
--	// param 3: goal application type string
--	// param 4: reachability type string
--	// param 5: The probability of selecting the target with highest desire
--	// param 6: The source from which the find target should search for relative targets.
--	// param 7: The maximum distance from source to target.
function On_Unit_Added(object)
	DebugMessage("%s -- Object: %s added to freestore", tostring(Script), tostring(object))

	obj_type = object.Get_Type()
	if obj_type.Is_Hero() then
		DebugMessage("%s -- Hero Object: %s added to freestore", tostring(Script), obj_type.Get_Name())
	end

	MoveUnit(object)
	
end


function FreeStoreService()

	if PlayerObject.Get_Faction_Name() == "REBEL" then
		leader_object = Find_First_Object("MON_MOTHMA")
	elseif PlayerObject.Get_Faction_Name() == "EMPIRE" then
		leader_object = Find_First_Object("EMPEROR_PALPATINE")
	end

	MovedUnitsThisService = 0
	GroundUnitsMoved = 0
	GroundUnitsToMove = 0
	SpaceUnitsMoved = 0
	SpaceUnitsToMove = 0
	SpaceAvailablePercent = 0
	GroundAvailablePercent = 0

	object_count = FreeStore.Get_Object_Count()
	
	if object_count ~= 0 then
		-- get the count of space force in the freestore
		scnt = FreeStore.Get_Object_Count(true)
		-- get the count of ground force in the freestore
		gcnt = FreeStore.Get_Object_Count(false)
		
		SpaceAvailablePercent = scnt / object_count
		GroundAvailablePercent = gcnt / object_count
		SpaceUnitsToMove = SpaceMovePercent * scnt
		GroundUnitsToMove = GroundMovePercent * gcnt
		DebugMessage("%s -- SpaceAvailablePercent: %f, GroundAvailablePercent: %f, SpaceUnitsToMove: %f, GroundUnitsToMove: %f, scnt: %f, gcnt: %f",
			tostring(Script), SpaceAvailablePercent, GroundAvailablePercent, SpaceUnitsToMove, GroundUnitsToMove, scnt, gcnt)
	end

end
