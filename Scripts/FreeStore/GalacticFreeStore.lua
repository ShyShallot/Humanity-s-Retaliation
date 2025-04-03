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
require("GalacticHeroFreeStore")
require("HALOFunctions")

function Base_Definitions()
	DebugMessage("%s -- In Base_Definitions", tostring(Script))

	-- how often does this script get serviced?
	ServiceRate = 45
	UnitServiceRate = 45
	
	Common_Base_Definitions()
	
	-- Percentage of units to move on each service.
	SpaceMovePercent = 0.5
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

	local dest_target = nil

	if not TestValid(dest_target) then
		dest_target = Find_Target_Planet(object)
	end

	if dest_target then
		DebugMessage("%s -- Moving %s to %s", tostring(Script), tostring(object), tostring(dest_target))
		Modify_Global_Unit_List(object,dest_target)
		FreeStore.Move_Object(object, dest_target)
		return true
	else
		DebugMessage("%s -- Object: %s, unable to find a suitable destination for this object.", tostring(Script), tostring(object))
		return false
	end
end

function On_Unit_Service(object)

	-- If this unit isn't in a safe spot move him regardless of the MovedUnitsThisService
	-- Also, Heroes need to be where they most want to be asap
	if (FreeStore.Is_Unit_Safe(object) == false) or (object.Get_Type().Is_Hero()) then
		MoveUnit(object)
		return
	end
		
	if object.Is_Transport() then
		if GameRandom.Get_Float() < GroundAvailablePercent and GroundUnitsMoved < GroundUnitsToMove then
			if FreeStore.Is_Unit_In_Transit(object) == false then
				DebugMessage("%s -- Object: %s service move order issued", tostring(Script), tostring(object))
				if MoveUnit(object) then
					GroundUnitsMoved = GroundUnitsMoved + 1
				end
			end
		end
	else
		if GameRandom.Get_Float() < SpaceAvailablePercent and SpaceUnitsMoved < SpaceUnitsToMove then
			if FreeStore.Is_Unit_In_Transit(object) == false then
				DebugMessage("%s -- Object: %s service move order issued", tostring(Script), tostring(object))
				if MoveUnit(object) then
					SpaceUnitsMoved = SpaceUnitsMoved + 1
				end
			end
		end
	end
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

	Calculate_Unit_List()

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

function Calculate_Unit_List()
	local units = Find_All_Objects_Of_Type("Fighter | Bomber | Transport | Corvette | Frigate | Capital | Super")

	DebugMessage("%s -- Total Units Found: %s", tostring(Script), tostring(tableLength(units)))

	Global_Unit_List = {}

	for _, unit in pairs (units) do
		if TestValid(unit) then
			--DebugMessage("%s -- Creating Global List for %s, Owner: %s, Planet: %s", tostring(Script), tostring(unit), tostring(unit.Get_Owner()), tostring(unit.Get_Planet_Location()))
			if TestValid(unit.Get_Owner()) and TestValid(unit.Get_Planet_Location()) then
				local unit_owner_name = unit.Get_Owner().Get_Faction_Name()

				local unit_planet_name = unit.Get_Planet_Location().Get_Type().Get_Name()
				if Global_Unit_List[unit_owner_name] == nil then
					Global_Unit_List[unit_owner_name] = {}
				end

				if Global_Unit_List[unit_owner_name][unit_planet_name] == nil then
					Global_Unit_List[unit_owner_name][unit_planet_name] = {}
				end

				if Global_Unit_List[unit_owner_name][unit_planet_name] ~= nil then
					table.insert(Global_Unit_List[unit_owner_name][unit_planet_name], unit)
				end
			end
		end
	end

	if tableLength(Global_Unit_List) > 1 then
		Global_Unit_List_Active = true
	end
end

function Find_Target_Planet(object)

	if Global_Unit_List_Active == false then
		DebugMessage("%s -- Global_Unit_List Not Active", tostring(Script))
		return nil
	end

	local planet_list = FindPlanet.Get_All_Planets()

	local controlled_planets = {}

	local enemy_planets = {}

	local vunurable_planets = {}

	for _, planet in pairs(planet_list) do
		if planet.Get_Owner() == PlayerObject then
			DebugMessage("%s -- Adding %s to Our Planets", tostring(Script), tostring(planet))
			table.insert(controlled_planets, planet)
		elseif planet.Get_Owner() ~= PlayerObject and planet.Get_Owner() ~= Find_Player("Neutral") then
			DebugMessage("%s -- Adding %s to Enemy Planets", tostring(Script), tostring(planet))
			table.insert(enemy_planets, planet)
		end
	end

	local lowest_combat_power = 100000000
	local target_planet = nil

	for _, planet in pairs(controlled_planets) do

		local planet_combat_power = 0

		local Planet_Unit_List = Get_Planet_Unit_List(planet.Get_Owner(),planet)

		local is_vunurable = false

		if tableLength(Planet_Unit_List) > 0 then
			for _, unit in pairs(Planet_Unit_List) do
				planet_combat_power = planet_combat_power + unit.Get_Type().Get_Combat_Rating()
			end
		end

		DebugMessage("%s -- Combat Power for Planet %s: %s", tostring(Script), tostring(planet), tostring(planet_combat_power))

		if planet_combat_power < Tech_Power_Upkeep() then
			DebugMessage("%s -- Adding %s to Vunurable Planets", tostring(Script), tostring(planet))
			table.insert(vunurable_planets, planet)
			is_vunurable = true
		end

		for _, enemy_planet in pairs(enemy_planets) do
			if tableLength(Find_Path(PlayerObject, planet, enemy_planet)) == 2 then
				local enemy_planet_combat_power = 0

				local Enemy_Planet_Unit_list = Get_Planet_Unit_List(enemy_planet.Get_Owner(),enemy_planet)

				if tableLength(Enemy_Planet_Unit_list) > 0 then
					for _, unit in pairs(Enemy_Planet_Unit_list) do
						enemy_planet_combat_power = enemy_planet_combat_power + unit.Get_Type().Get_Combat_Rating()
					end
				end

				DebugMessage("%s -- Enemy Planet Combat Power for Planet %s: %s", tostring(Script), tostring(enemy_planet), tostring(enemy_planet_combat_power))

				if enemy_planet_combat_power > planet_combat_power then
					if not is_vunurable then
						DebugMessage("%s -- Adding %s to Vunurable Planets", tostring(Script), tostring(planet))
						table.insert(vunurable_planets, planet)
					end
				end
			end
		end


	end

	local is_target_planet_vunurable = false

	for _, planet in pairs(vunurable_planets) do
		if target_planet == planet then
			is_target_planet_vunurable = true
		end
	end

	if not is_target_planet_vunurable then
		target_planet = vunurable_planets[EvenMoreRandom(1,tableLength(vunurable_planets))]
	end

	DebugMessage("%s -- Final Target Planet %s", tostring(Script), tostring(target_planet))

	local Path_To_Target = Find_Path(PlayerObject, object.Get_Planet_Location(), target_planet)

	local Is_Valid_Path = false

	local Valid_Path_Check_Count = 0

	while not Is_Valid_Path and Valid_Path_Check_Count < 10 do
		local valid_planets = 0
		for _, planet in pairs(Path_To_Target) do
			if planet.Get_Owner() == object.Get_Owner() then
				valid_planets = valid_planets + 1
			end
		end

		if valid_planets < tableLength(Path_To_Target) then
			target_planet = vunurable_planets[EvenMoreRandom(1,tableLength(vunurable_planets))]
		else
			Is_Valid_Path = true
		end

		Valid_Path_Check_Count = Valid_Path_Check_Count + 1
	end

	return target_planet
end

function Get_Planet_Unit_List(owner, planet)
	if not TestValid(owner) and not TestValid(planet) then
		return {}
	end

	if Global_Unit_List[owner.Get_Faction_Name()] == nil then
		return {}
	end

	if Global_Unit_List[owner.Get_Faction_Name()][planet.Get_Type().Get_Name()] == nil then
		return {}
	end

	return Global_Unit_List[owner.Get_Faction_Name()][planet.Get_Type().Get_Name()]
	
end

function Modify_Global_Unit_List(unit, new_planet)

	if not TestValid(new_planet) then
		return
	end

	local planet_list = Get_Planet_Unit_List(unit.Get_Owner(),unit.Get_Planet_Location())
	if tableLength(planet_list) <= 0 then
		return 
	end

	for _, planet_unit in pairs(planet_list) do
		if planet_unit == unit then
			table.remove(Global_Unit_List[unit.Get_Owner().Get_Faction_Name()][unit.Get_Planet_Location().Get_Type().Get_Name()])
		end
	end

	table.insert(Global_Unit_List[unit.Get_Owner().Get_Faction_Name()][new_planet.Get_Type().Get_Name()],unit)
end


function Tech_Power_Upkeep()
    if PlayerObject.Get_Faction_Name() == "REBEL" then
        return 3000 * (PlayerObject.Get_Tech_Level() + 1)
    else 
        return 3000 * PlayerObject.Get_Tech_Level()
    end
end
