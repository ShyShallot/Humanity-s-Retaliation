require("PGStateMachine")
require("HALOFunctions")

function Definitions()

	ServiceRate = 3

    last_moved_when = nil

    next_move_when = nil

    target = nil

    movement_block = nil

    times_scouted = 0

	Define_State("State_Init", State_Init);
end

function State_Init(message)
	if message == OnEnter then

		-- prevent this from doing anything in galactic mode
		if Get_Game_Mode() ~= "Galactic" then
			ScriptExit()
		end

	end

    if message == OnUpdate then
        DebugMessage("%s -- Current Target : %s", tostring(Script), tostring(target))
        DebugMessage("%s -- Last Moved : %s", tostring(Script), tostring(last_moved_when))
        DebugMessage("%s -- Next Move : %s", tostring(Script), tostring(next_move_when))
        if movement_block ~= nil then
            DebugMessage("%s -- Movement Block Status: %s", tostring(Script), tostring(movement_block.IsFinished()))
        end

        if times_scouted >= 3 then
            Object.Despawn()
            ScriptExit()
        end

        Move_Scout()
    end
end

function Move_Scout()

    DebugMessage("%s -- Move_Scout -- Moving %s", tostring(Script), tostring(Object))

    if target == nil then
        DebugMessage("%s -- Move_Scout -- No Target, Searching", tostring(Script))

        target = Find_Target()

        DebugMessage("%s -- Move_Scout -- Found Target: %s", tostring(Script), tostring(target))

        if target == nil then
            DebugMessage("%s -- Move_Scout -- Target is Nil, Cancelling Move", tostring(target))
            return
        end

        local Scout_Units = Find_All_Objects_Of_Type("UNSC_Scout_Corvette")

        if tableLength(Scout_Units) > 1 then
            DebugMessage("%s -- Move_Scout -- More than 1 Scout", tostring(Script))
            for _, scout in pairs(Scout_Units) do
                if scout ~= Object then
                    if scout.Can_move() then
                        if scout.Get_Planet_Location() == target then
                            DebugMessage("%s -- Move_Scout -- Scout already at location, Cancelling Move", tostring(Scout))
                            return
                        end
                    end
                end
            end
        end
        
        last_moved_when = Get_Current_Week() + 1

        Move_Object(target)
    end

    if target ~= nil and last_moved_when ~= nil then -- if we have a target, and we have moved
        if Object.Get_Planet_Location() == target and next_move_when == nil then -- if we are at our target, start the scout window
            next_move_when = last_moved_when + 3
        end
    end

    if next_move_when == nil then
        return
    end
    
    if Get_Current_Week() >= next_move_when and Object.Get_Planet_Location().Get_Owner() ~= Object.Get_Owner() then -- If We have finished our scout window, and we are at an enemy planet, move to friendly planet
        times_scouted = times_scouted + 1

        target = Find_Nearest_Home_Planet()

        last_moved_when = Get_Current_Week()

        next_move_when = last_moved_when + 3

        Move_Object(target)
    end

    if Get_Current_Week() >= next_move_when and Object.Get_Planet_Location().Get_Owner() == Object.Get_Owner() then -- If we have finished the scout cooldown, and we are at a friendly planet
        target = nil

        last_moved_when = nil

        next_move_when = nil
    end
end

function Find_Target()

    if Object.Get_Planet_Location() == nil then
        return nil
    end

    DebugMessage("%s -- %s Current Location: %s", tostring(Script), tostring(Object), tostring(Object.Get_Planet_Location()))

    local controlled_planets = {}

    local enemy_planets = {}

    local All_Planets = FindPlanet.Get_All_Planets()

    

    for _, planet in pairs(All_Planets) do
        if planet.Get_Owner() == Object.Get_Owner() then
            DebugMessage("%s -- Adding %s to Our Planets", tostring(Script), tostring(planet))
            table.insert(controlled_planets, planet)
        elseif planet.Get_Owner() ~= Find_Player("Neutral") then
            DebugMessage("%s -- Adding %s to Enemy Planets", tostring(Script), tostring(planet))
            table.insert(enemy_planets, planet)
        end
    end

    local target_planet = enemy_planets[EvenMoreRandom(1, tableLength(enemy_planets), 3)]

    if target_planet == nil then
        return nil
    end

    DebugMessage("%s -- Target Planet %s", tostring(Script), tostring(target_planet))

    while (not Is_Valid_Target_Path(Object.Get_Planet_Location(), target_planet)) do
        target_planet = enemy_planets[EvenMoreRandom(1, tableLength(enemy_planets), 3)]
    end

    DebugMessage("%s -- Final Target Planet %s ", tostring(Script), tostring(target_planet))

    return target_planet

end

function Is_Valid_Target_Path(start, target)
    local path = Find_Path(Object.Get_Owner(), start, target)

    if tableLength(path) == 2 and start.Get_Owner() == Object.Get_Owner() then
        return true
    end

    if start.Get_Owner() == target.Get_Owner() then
        return false
    end

    local is_valid = true

    local enemy_planet_count = 0

    for _, planet in pairs(path) do
        if planet.Get_Owner() ~= Object.Get_Owner() then
            enemy_planet_count = enemy_planet_count + 1
        end    

        if enemy_planet_count > 1 then
            is_valid = false
            break
        end
    end

    return is_valid
end

function Find_Nearest_Home_Planet()

    if Object.Get_Planet_Location() == nil then
        return nil
    end

    local closest_jump = 100000000
    local closest_planet = nil

    local All_Planets = FindPlanet.Get_All_Planets()

    for _, planet in pairs(All_Planets) do
        if planet.Get_Owner() == Object.Get_Owner() then
            local jump_length = tableLength(Find_Path(Object.Get_Owner(), Object.Get_Planet_Location(), planet))

            if jump_length < closest_jump then
                closest_jump = jump_length
                closest_planet = planet
            end
        end
    end

    return closest_planet

end

function Move_Object(target)
    local fleet = Object.Get_Parent_Object()

    movement_block = fleet.Move_To(target)
end