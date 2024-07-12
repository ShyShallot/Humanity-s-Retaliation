require("pgcommands")
require("HALOFunctions")

-- using AOTR's as a basis for the implentation


function Base_Definitions()
	DebugMessage("%s -- In Base_Definitions", tostring(Script))

	-- how often does this script get serviced?
	ServiceRate = 20
	UnitServiceRate = 20
	
	Common_Base_Definitions()
	
	-- Percentage of units to move on each service.
	SpaceMovePercent = 0.0
	GroundMovePercent = 0.0

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


	
end

function On_Unit_Service(object)
	-- If this unit isn't in a safe spot move him regardless of the MovedUnitsThisService
	-- Also, Heroes need to be where they most want to be asap
	-- if (FreeStore.Is_Unit_Safe(object) == false) or (object.Get_Type().Is_Hero()) then
	-- --if (object.Get_Type().Is_Hero()) then
	-- 	MoveUnit(object)
	-- 	return
	-- end

	-- if object.Is_Transport() then
  --       if GroundAvailablePercent ~= nil and GroundUnitsMoved ~= nil and GroundUnitsToMove ~= nil then
	-- 	if GameRandom.Get_Float() < GroundAvailablePercent and GroundUnitsMoved < GroundUnitsToMove then
	-- 		if FreeStore.Is_Unit_In_Transit(object) == false then
	-- 			DebugMessage("%s -- Object: %s service move order issued", tostring(Script), tostring(object))
	-- 			if MoveUnit(object) then
	-- 				GroundUnitsMoved = GroundUnitsMoved + 1
	-- 			end
	-- 		end
	-- 	end
  --       end
	-- elseif SpaceAvailablePercent ~= nil and SpaceUnitsMoved ~= nil and SpaceUnitsToMove ~= nil then
	-- 	if GameRandom.Get_Float() < SpaceAvailablePercent and SpaceUnitsMoved < SpaceUnitsToMove then
	-- 		if FreeStore.Is_Unit_In_Transit(object) == false then
	-- 			DebugMessage("%s -- Object: %s service move order issued", tostring(Script), tostring(object))
	-- 			if MoveUnit(object) then
	-- 				SpaceUnitsMoved = SpaceUnitsMoved + 1
	-- 			end
	-- 		end
	-- 	end
	-- end
end

--	// param 1: playerwrapper.
--	// param 2: perception function name
--	// param 3: goal application type string
--	// param 4: reachability type string
--	// param 5: The probability of selecting the target with highest desire
--	// param 6: The source from which the find target should search for relative targets.
--	// param 7: The maximum distance from source to target.
function On_Unit_Added(object)
	-- DebugMessage("%s -- Object: %s added to freestore", tostring(Script), tostring(object))

	-- obj_type = object.Get_Type()
	-- if obj_type.Is_Hero() then
	-- 	DebugMessage("%s -- Hero Object: %s added to freestore", tostring(Script), obj_type.Get_Name())
	-- end

	-- MoveUnit(object)
	
end


function FreeStoreService()
	-- MovedUnitsThisService = 0
	-- GroundUnitsMoved = 0
	-- GroundUnitsToMove = 0
	-- SpaceUnitsMoved = 0
	-- SpaceUnitsToMove = 0
	-- SpaceAvailablePercent = 0
	-- GroundAvailablePercent = 0
	FreighterCount = 0

	-- object_count = FreeStore.Get_Object_Count()
	-- if object_count ~= 0 then
	-- 	-- get the count of space force in the freestore
	-- 	scnt = FreeStore.Get_Object_Count(true)
	
  --       if scnt == nil then
  --           scnt = 0
  --       end
	-- 	-- get the count of ground force in the freestore
	-- 	gcnt = FreeStore.Get_Object_Count(false)

  --       if gcnt == nil then
  --           gcnt = 0
  --       end

	freighter_list = Find_All_Objects_Of_Type("UNSC_GOODS_TRANSPORT")
	FreighterCount = table.getn(freighter_list)
	if FreighterCount > 0 then
		for i = 1, FreighterCount, 1 do
			freighter_to_move = freighter_list[i]
			DebugMessage("%s -- Freightstore, trying to move freighter %s", tostring(Script), tostring(freighter_to_move))
			if not FreeStore.Is_Unit_In_Transit(freighter_to_move) then
				if Return_Chance(0.5,1) then
					DebugMessage("%s -- Freightstore, moving freighter %s", tostring(Script), tostring(freighter_to_move))
					MoveUnit(freighter_to_move)
				end
			end
		end
	end
		
		-- SpaceAvailablePercent = scnt / object_count
		-- GroundAvailablePercent = gcnt / object_count
		-- SpaceUnitsToMove = SpaceMovePercent * scnt
		-- GroundUnitsToMove = GroundMovePercent * gcnt
		-- DebugMessage("%s -- SpaceAvailablePercent: %f, GroundAvailablePercent: %f, SpaceUnitsToMove: %f, GroundUnitsToMove: %f, scnt: %f, gcnt: %f",
		-- 	tostring(Script), SpaceAvailablePercent, GroundAvailablePercent, SpaceUnitsToMove, GroundUnitsToMove, scnt, gcnt)
	-- end
end

function Find_Freighter_Target(object)

	my_planet = object.Get_Planet_Location()

    if not TestValid(my_planet) then
        return nil
    end

    freight_target = FindTarget.Reachable_Target(PlayerObject, "Is_Connected_To_Me", "Friendly", "Friendly_Only", 0.1, object)
    if not TestValid(freight_target) then
    	return nil
	end

	freight_target = freight_target.Get_Game_Object()
	
	if freight_target.Get_Type().Get_Name() == my_planet.Get_Type().Get_Name() then
		return nil
	end

	if not freight_target.Get_Is_Planet_AI_Usable() then
		return nil
    end
	
	return Freighter_Logic(object, PlayerObject, freight_target, true)
end
