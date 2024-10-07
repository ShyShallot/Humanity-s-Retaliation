require("PGStateMachine")
require("HALOFunctions")
require("PGBaseDefinitions")
require("PlanetNameTable")

function Definitions()
    ServiceRate = 0.5
	Define_State("State_Init", State_Init);
    Define_State("State_Freighter", State_Freighter)

    freighter_table = {}

	cooldown_time = 2 -- days or weeks whatever

    DebugMessage("Starting FreightManager")

end

function State_Init(message)
    if message == OnEnter then
        Set_Next_State("State_Freighter")
    end
end

function State_Freighter(message)
    if message == OnUpdate then
		plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Freighter_Display.xml") -- Plot file so we can a list of the freighters and their desitnation

		event = plot.Get_Event("Freight_Display")
        event.Clear_Dialog_Text() -- Clears all added Text
		
        freighter_list = Find_All_Objects_Of_Type("UNSC_GOODS_TRANSPORT")
	    FreighterCount = tableLength(freighter_list)

	    DebugMessage("Found %s Freighters", tostring(FreighterCount))
	    if FreighterCount > 0 then
	    	for i = 1, FreighterCount, 1 do -- start I at 1, add 1 until we reach the amount of Freighters
	    		local freighter_to_move = freighter_list[i]
                DebugMessage("Does Freighter have entry: %s", tostring(freighter_table[freighter_to_move]))
	    		if freighter_table[freighter_to_move] == nil then -- Check if a freighter has been added to the table or not
	    			if Return_Chance(0.55, 1) then -- Add some delay to the inital movement of the Freighter
						local dest = Find_Target(freighter_to_move)
						local starting = freighter_to_move.Get_Planet_Location()
	    				freighter_table[freighter_to_move] = {
	    					Destination = dest,
	    					Start = starting,
	    					Done = false,
                            Movement = nil,
							Number = Generate_Freight_Number(),
							Finished_Date = nil
	    				}

	    				Move_Unit(freighter_to_move)
	    			end
	    		else
	    			local freighter_entry = freighter_table[freighter_to_move]
	    			if freighter_entry.Done == true then
                        DebugMessage("Freighter Done with Transport")
	    				if freighter_entry.Finished_Date == nil then
							freighter_entry.Finished_Date = (Get_Current_Week() + EvenMoreRandom(0,2,10))
						end
						if Get_Current_Week() >= (freighter_entry.Finished_Date + cooldown_time) then
							Reset_Freighter(freighter_to_move, freighter_entry)
						end
	    			else
	    				if freighter_entry.Movement.IsFinished() and freighter_entry.Done == false then
                            if freighter_to_move.Get_Planet_Location() ~= freighter_entry.Destination then
								DebugMessage("Movement Interupted")
								freighter_entry.Destination = freighter_to_move.Get_Planet_Location()
								Reward_Freighter(freighter_to_move, freighter_entry)
							else
								DebugMessage("Rewarding Player for Transport")
	    						Reward_Freighter(freighter_to_move, freighter_entry)
							end
	    				end
 	    			end
	    		end

				if freighter_table[freighter_to_move] ~= nil then
					local freighter_entry = freighter_table[freighter_to_move]

					event.Add_Dialog_Text("Freighter #" .. freighter_entry.Number .. ", Freight Path: " .. freighter_entry.Start.Get_Type().Get_Name() .. " ---> " .. freighter_entry.Destination.Get_Type().Get_Name() .. ", Estimated Income: ".. tostring(Calculate_Reward_Income(freighter_to_move, freighter_entry)) .. " Credits")
					event.Add_Dialog_Text(" ")
				end
			end
	    end
    end
end

function Move_Unit(object)

	if freighter_table[object] == nil then
		return
	end

    DebugMessage("Moving Transport to: %s", tostring(freighter_table[object].Destination))

	if TestValid(freighter_table[object].Destination) and freighter_table[object].Movement == nil then
		local status = object.Get_Parent_Object().Move_To(freighter_table[object].Destination)
        freighter_table[object].Movement = status
    end
end

function Find_Target(freighter, recursive_searched)

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


function Find_Econ_Structure(location)
	local structs = {"UNSC_Trade_Platform","UNSC_Mining_Facility"} -- Add to this list any structures that should add a bonus to the freight trip

	local structs_found = { -- Add to this as well
		["UNSC_Trade_Platform"] = false,
		["UNSC_Mining_Facility"] = false
	}

	local found = 0

	for _, struct in pairs(structs) do
		local structs_list = Find_All_Objects_Of_Type(struct) -- Find all of the related structures

		for _, found_struct in pairs(structs_list) do
			if found_struct.Get_Planet_Location() == location then
				structs_found[struct] = true
			end
		end

		if structs_found[struct] then
			found = found + 1
		end
	end

	return found
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

function Reset_Freighter(freighter, freighter_entry, inital_planet)
	freighter_entry.Done = false
	freighter_entry.Destination = Find_Target(freighter)
	
	if inital_planet == nil then
		freighter_entry.Start = freighter.Get_Planet_Location()
	else
		freighter_entry.Start = inital_planet
	end

	freighter_entry.Finished_Date = nil
	freighter_entry.Movement = nil

	Move_Unit(freighter)
end