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
	ServiceRate = 20
	UnitServiceRate = 20
	
	Common_Base_Definitions()
	
	-- Percentage of units to move on each service.
	SpaceMovePercent = 0.0
	GroundMovePercent = 0.0

	freighter_table = {}


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


	FreeStore.Move_Object(object, target)

	return true
	
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
	
	
end


function FreeStoreService()

	local plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Freighter_Display.xml")

	local event = plot.Get_Event("Freight_Display")
	event.Clear_Dialog_Text() -- Clears all added Text

	event.Add_Dialog_Text("TEXT_STORY_FREIGHT_MANAGER_CURRENT_LIMIT", tostring(Max_Freighters()))

	local freighter_list = Find_All_Objects_Of_Type("UNSC_GOODS_TRANSPORT")
	local FreighterCount = tableLength(freighter_list)

	if tableLength(All_UNSC_Planets()) < 2 then
		return
	end

	DebugMessage("%s -- Current Freighter Count: %s, Max Freighter Count: %s", tostring(Script), tostring(FreighterCount), tostring(Max_Freighters()))

	if FreighterCount >= Max_Freighters() then
		GlobalValue.Set("Max_Freighters", 1)
	else
		GlobalValue.Set("Max_Freighters", 0)
	end

	local freighters_to_be_removed = FreighterCount - Max_Freighters()

	local removed_freighter_count = 0

	DebugMessage("Found %s Freighters, Freighters To Be Removed: %s", tostring(FreighterCount), tostring(freighters_to_be_removed))
	
	if FreighterCount <= 0 then
		return	
	end

	for i=1, FreighterCount, 1 do
		local freighter_to_move = freighter_list[i]

		DebugMessage("Does Freighter have entry: %s", tostring(freighter_table[freighter_to_move]))

		if freighter_table[freighter_to_move] == nil then
			local frieghter_removed = false
			if removed_freighter_count < freighters_to_be_removed and frieghter_removed > 0 then
				Game_Message("TEXT_STORY_FREIGHT_MANAGER_LIMIT")
				freighter_to_move.Despawn()
				removed_freighter_count = removed_freighter_count + 1
				frieghter_removed = true
			end

			if Return_Chance(0.55, 1) and frieghter_removed == false then
				local dest = Find_Target(freighter_to_move)
				local starting = freighter_to_move.Get_Planet_Location()
				freighter_table[freighter_to_move] = {
					Destination = dest,
	    			Start = starting,
	    			Done = false,
					Number = Generate_Freight_Number(),
					Finished_Date = nil
				}

				MoveUnit(freighter_to_move)
			end
		else
			local freighter_entry = freighter_table[freighter_to_move]
			if freighter_entry.Done == true then
				if freighter_entry.Finished_Date == nil then
					freighter_entry.Finished_Date = (Get_Current_Week() + EvenMoreRandom(0,2,10))
				end
				if Get_Current_Week() >= (freighter_entry.Finished_Date + cooldown_time) then
					Reset_Freighter(freighter_to_move, freighter_entry)
				end
			else
				if FreeStore.Is_Unit_In_Transit(freighter_to_move) == false and freighter_entry.Done == false then
					if freighter_to_move.Get_Planet_Location() ~= freighter_entry.Destination then
						DebugMessage("Movement Interupted")
						freighter_entry.Destination = freighter_to_move.Get_Planet_Location()
						Reward_Freighter(freighter_to_move, freighter_entry)
					else
						DebugMessage("Freighter Done with Transport")
						Reward_Freighter(freighter_to_move, freighter_entry)
					end
				end
			end
		end

		if freighter_table[freighter_to_move] ~= nil then
			local freighter_entry = freighter_table[freighter_to_move]

			event.Add_Dialog_Text("TEXT_STORY_FREIGHT_MANAGER_FREIGHTER_01", tostring(freighter_entry.Number)) 
			event.Add_Dialog_Text("TEXT_STORY_FREIGHT_MANAGER_FREIGHTER_02", freighter_entry.Start.Get_Type().Get_Name(), freighter_entry.Destination.Get_Type().Get_Name())
			event.Add_Dialog_Text("TEXT_STORY_FREIGHT_MANAGER_FREIGHTER_03", tostring(Calculate_Reward_Income(freighter_to_move, freighter_entry)))
			event.Add_Dialog_Text(" ")
		end
	end
end

function Find_Target(freighter)

	local target = FindTarget.Reachable_Target(freighter.Get_Owner(), "Is_Connected_To_Me", "Friendly", "Friendly_Only", 0.1, freighter) -- Using PerceptualEquations from SandboxHuman, select a planet that we own

	if target == nil then
		return Find_Target(freighter)
	end

	if freighter.Get_Planet_Location() == nil then
		return Find_Target(freighter)
	end
    
    -- PerceptualEquation does not return a gameobject, so we call a function that somehow does turn it into one
    target = target.Get_Game_Object()

    -- Find a path from the freighter's location to the target
    local path = Find_Path(freighter.Get_Owner(), freighter.Get_Planet_Location(), target)

	if path == nil then
		return Find_Target(freighter)
	end

	if tableLength(path) < 2 then
		return Find_Target(freighter)
	end
    
    -- Check if the path contains any planets not controlled by the freighter's owner
    local contains_non_controlled = false
    for _, planet in pairs(path) do
        if planet.Get_Owner() ~= freighter.Get_Owner() then
            contains_non_controlled = true
            break
        end
    end

    -- If the target is the same as the freighter's current location or if the path contains non-controlled planets, call the function recursively
    if target == freighter.Get_Planet_Location() or contains_non_controlled then
        return Find_Target(freighter)  -- Recursive call
    end

    -- Return the valid target if found
    if TestValid(target) then
        return target
    end
end

function All_UNSC_Planets()
	local planets = FindPlanet.Get_All_Planets()

	local unsc_planets = {}

	for _, planet in pairs(planets) do
		if planet.Get_Owner() == PlayerObject then
			table.insert(unsc_planets, planet)
		end
	end

	return unsc_planets
end

function Max_Freighters()

	local Trade_Platform_Count = tableLength(Find_All_Objects_Of_Type("UNSC_Trade_Platform"))

	local Base_Max = 2

	return Base_Max * Trade_Platform_Count
end

function Generate_Freight_Number()
	local randomNum = EvenMoreRandom(1,500, 15)

	local isTaken = false

	if tableLength(freighter_table) > 1 then
		for _, freighter in pairs(freighter_table) do
			if freighter.Number == randomNum then
				isTaken = true
				break
			end
		end
	end

	if isTaken then
		return Generate_Freight_Number()
	end

	return randomNum
end

function Calculate_Reward_Income(freighter, entry)
	local base_credit = 110

	local credit_muliplier = (tableLength(Find_Path(freighter.Get_Owner(), entry.Start, entry.Destination))) - 1

	if credit_muliplier < 1 then
		credit_muliplier = 1
	end

	if credit_muliplier > 10 then
		credit_muliplier = 10
	end

	return (base_credit * credit_muliplier)
end


function Reward_Freighter(freighter, entry)
	
	local bonus = 0

	if Find_Econ_Structure(entry.Destination) > 0 then
		bonus = 250
    end

	local income = Calculate_Reward_Income(freighter, entry) + bonus

	freighter.Get_Owner().Give_Money(income)

    freighter_table[freighter].Done = true

    DebugMessage("Finished Freight Trip from: " .. tostring(entry.Start) .. " To: " ..  tostring(entry.Destination) .. ", With an Income of " .. tostring(income) .. " Credits")

	Game_Message("Finished Freight Trip from: " .. entry.Start.Get_Type().Get_Name() .. " To: " ..  tostring(entry.Destination.Get_Type().Get_Name()) .. ", With an Income of " .. (income) .. " Credits")
end