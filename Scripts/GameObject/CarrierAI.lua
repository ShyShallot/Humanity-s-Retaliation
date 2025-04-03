require("PGStateMachine")
require("HALOFunctions")
require("PGBaseDefinitions")
require("HALOAIFunctions") 
-- Script is used for Humanity's Retaliation 
-- CarrierAI Script is written by ShyShallot, If you wish to use this script please contact the Project Gold Team via Discord
-- Any use of this script without permission will not be fun for offending party.
-- Any Modifications of this Script for Submods of Humanity's Retliation are allowed as long as they stay in this mod 
-- Even if you modify this script for a submod, you still do not have permission to use else where
-- Lua Doc: https://stargate-eaw.de/media/kunena/attachments/92/LuacommandsinFoC.pdf

function Definitions()
    ServiceRate = 1
	Define_State("State_Init", State_Init);
	ability_name = "TURBO"
end

function State_Init(message)

    if message == OnEnter then
        layer_manager = require("eaw-layerz/layermanager")
		layer_manager:update_unit_layer(Object,true)
    end

    if message == OnUpdate then
		if Object.Get_Owner().Is_Human() then
			if Object.Is_Ability_Active(ability_name) then
                DebugMessage("%s -- Ability Active Running Search for Protection", tostring(Script))
                Search_For_Protection()
                Sleep(2)
            elseif Object.Is_Ability_Autofire(ability_name) then 
                Object.Activate_Ability(ability_name,true)
            end
		else
            ScriptExit()
		end
    end

end

function Search_For_Protection()
    player = Object.Get_Owner()
    if TestValid(Object) then
        local all_player_units = Find_All_Objects_Of_Type(player, "Corvette | Frigate | Capital | Super")

        if tableLength(all_player_units) == 0 then
            return
        end

        strongest_unit = nil
        biggest_power = 0
        largest_surrounding_units = 0
        surrounding_units = {}

        for i, unit in pairs(all_player_units) do
            unit_power = unit.Get_Type().Get_Combat_Rating()

            DebugMessage("Strongest Unit: %s, Biggest Power: %s, Largest Neighbors: %s, Unit: %s, Unit Power: %s, Is Larger than Strongest: %s", tostring(strongest_unit), tostring(biggest_power), tostring(largest_surrounding_units), tostring(unit.Get_Type().Get_Name()), tostring(unit_power), tostring(unit_power > biggest_power))

            if unit_power >= biggest_power and not (unit == Object) then -- if its just a greater than, then it wont find the group with the most neighbors
                
                neighbors = Get_Neighbors(unit)

                PrintTable(neighbors)

                DebugMessage("Amount of Neighbors: %s, Largest Neighbor Count: %s", tostring(tableLength(neighbors)), tostring(largest_surrounding_units))

                if tableLength(neighbors) > largest_surrounding_units then

                    strongest_unit = unit
                    biggest_power = unit_power

                    surrounding_units = neighbors

                    largest_surrounding_units = tableLength(surrounding_units)
                end
            end
        end

        if strongest_unit == nil then -- if there are no other units
            space_station = player.Get_Space_Station()

            if TestValid(space_station) then
                Object.Move_To(space_station)
            end

            return
        end

        positions_x = {} -- seperate arrays because its easier to calculate the avg and sum for the x,y and z if they are seperate and im lazy
        positions_y = {}
        positions_z = {}

        strongest_unit_x, strongest_unit_y, strongest_unit_z = strongest_unit.Get_Position().Get_XYZ()

        table.insert(positions_x, strongest_unit_x) -- insert the strongest unit to include in the avg
        table.insert(positions_y, strongest_unit_y)
        table.insert(positions_z, strongest_unit_z)

        for i, unit in pairs(surrounding_units) do
            unit_x, unit_y, unit_z = unit.Get_Position().Get_XYZ()
            table.insert(positions_x, unit_x)
            table.insert(positions_y, unit_y)
            table.insert(positions_z, unit_z)
        end

        x_avg = 0
        y_avg = 0
        z_avg = 0

        for i, value in ipairs(positions_x) do
            x_avg = x_avg + value
            y_avg = y_avg + positions_y[i] -- positions tables will always be the same size
            z_avg = z_avg + positions_z[i]
        end

        x_avg = tonumber(Dirty_Floor(x_avg/tableLength(positions_x)))
        y_avg = tonumber(Dirty_Floor(y_avg/tableLength(positions_x)))
        z_avg = tonumber(Dirty_Floor(z_avg/tableLength(positions_x)))

        avg_position = Create_Position(x_avg,y_avg,z_avg)

        Object.Move_To(avg_position)


        -- if you just want to avg all unit positions

        --[[positions_x = {}
        positions_y = {}
        positions_z = {}


        for i, unit in pairs(all_player_units) do
            unit_power = unit.Get_Type().Get_Combat_Rating()
            unit_x, unit_y, unit_z = unit.Get_Position().Get_XYZ()
            positions_x[i] = unit_x
            positions_y[i] = unit_y
            positions_z[i] = unit_z
        end

        removeOutliers(positions_x)
        removeOutliers(positions_y)
        removeOutliers(positions_z)

        x_avg = 0
        y_avg = 0
        z_avg = 0

        for i, value in ipairs(positions_x) do
            x_avg = x_avg + value
            y_avg = y_avg + positions_y[i] -- positions tables will always be the same size
            z_avg = z_avg + positions_z[i]
        end

        x_avg = tonumber(Dirty_Floor(x_avg/tableLength(positions_x)))
        y_avg = tonumber(Dirty_Floor(y_avg/tableLength(positions_x)))
        z_avg = tonumber(Dirty_Floor(z_avg/tableLength(positions_x)))

        avg_position = Create_Position(x_avg,y_avg,z_avg)

        Object.Move_To(avg_position) --]]
    end
end


function Get_Neighbors(unit)

    local surrounding_units = {}

    local all_player_units = Find_All_Objects_Of_Type(player, "Corvette | Frigate | Capital | Super")

    for i, secondunit in pairs(all_player_units) do
        if not (unit == secondunit) then
            if secondunit.Get_Distance(unit) <= 1000 then
                table.insert(surrounding_units, secondunit)
            end
        end
    end

    return surrounding_units
end