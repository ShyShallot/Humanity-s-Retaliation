-- Script is used for Humanity's Retaliation 
-- This script contains a set of custom functions used by various scripts. Made by ShyShallot
-- Any use of this script without permission will not be fun for offending party.
-- Lua Doc: https://stargate-eaw.de/media/kunena/attachments/92/LuacommandsinFoC.pdf
-- This script ties the Reactor hardpoint to the actual unit
-- The Reactor Hardpoint works by using a Gravity Well Hardpoint,
-- To check if the reactor is alive we simply check if the Ship can use the Gravity Well Ability
-- Limitations are any ship that should use the Gravity well for its actual function cant have a reactor
require("PGStateMachine")
require("HALOFunctions")
function Definitions()
	ServiceRate = 1
	Define_State("State_Init", State_Init);
    ability_name = "INTERDICT"
    units_with_reactors = { -- Moved table here so the Unit_Reactor_Table doesn't create everytime
            Find_Object_Type("COVN_CRS"),
            Find_Object_Type("COVN_CAS"),
            Find_Object_Type("COVN_CCS"),
            Find_Object_Type("COVN_RCS"),
            Find_Object_Type("COVN_CPV"),
            Find_Object_Type("COVN_DDS"),
            Find_Object_Type("UNSC_POA"),
            Find_Object_Type("UNSC_AUTUMN"),
            Find_Object_Type("UNSC_INFINITY"),
            Find_Object_Type("UNSC_HALCYON"),
            Find_Object_Type("UNSC_MARATHON"),
            Find_Object_Type("UNSC_MUSASHI"),
            Find_Object_Type("UNSC_POSEIDON"),
            Find_Object_Type("UNSC_VINDICATION"),
            Find_Object_Type("UNSC_STRIDENT")
    }
    exploded_units_e = {}
    exploded_units_r = {}
end

function State_Init(message) 
    if message == OnEnter then
        DebugMessage("%s -- Creating Unit List Covenant", tostring(Script))
        reactor_unit_list_e = Unit_Reactor_Table(exploded_units_e) -- first define our unit reactor list
        DebugMessage("%s -- Creating Unit List UNSC", tostring(Script))
        reactor_unit_list_r = Unit_Reactor_Table(exploded_units_r) -- first define our unit reactor list
    elseif message == OnUpdate then
        Create_Thread("Reactor_Table_Function_E", reactor_unit_list_e, exploded_units_e)
        DebugMessage("%s -- Updating Unit List Covenant", tostring(Script))
        Create_Thread("Reactor_Table_Function_R", reactor_unit_list_r, exploded_units_r)
        DebugMessage("%s -- Updating Unit List UNSC", tostring(Script))
    end
end

function Reactor_Table_Function_E()
    DebugMessage("%s -- Updating COVIE Unit List", tostring(Script))
    DebugMessage("%s -- Printing Active Units with reactors - OnUpdate", tostring(Script))
    DebugPrintTable(reactor_unit_list_e)
    DebugMessage("%s -- Printing Dead Units with no reactors", tostring(Script))
    DebugPrintTable(exploded_units_e)
    reactor_unit_list_e = Unit_Reactor_Table(exploded_units_r) -- reactor_unit_list calls Unit_Reactor table and defines itsself to the result of the function
    Sleep(1)
    Process_Reactor_Table(reactor_unit_list_e, exploded_units_e) -- Overall function that checks the table and does shit
    Sleep(1)
end

function Reactor_Table_Function_R()
    DebugMessage("%s -- Updating UNSC Unit List", tostring(Script))
    DebugMessage("%s -- Printing Active Units with reactors - OnUpdate", tostring(Script))
    DebugPrintTable(reactor_unit_list_r)
    DebugMessage("%s -- Printing Dead Units with no reactors", tostring(Script))
    DebugPrintTable(exploded_units_r)
    reactor_unit_list_r = Unit_Reactor_Table(exploded_units_r) -- reactor_unit_list calls Unit_Reactor table and defines itsself to the result of the function
    Sleep(1)
    Process_Reactor_Table(reactor_unit_list_r, exploded_units_r) -- Overall function that checks the table and does shit
    Sleep(1)
end

function Reactor_Explode(unit)
    DebugMessage("%s -- Spawning Reduce Firerate", tostring(Script))
    Create_Generic_Object("Reduce_Ship_Firespeed_40", unit.Get_Position(), unit.Get_Owner()) -- Spawn a projectile with a special mod tag to reduce the ships firerate
    DebugMessage("%s -- Spawning Big Kaboom", tostring(Script))
    Create_Generic_Object("Reactor_Explode", unit.Get_Position(), Find_Player("UNDERWORLD")) -- Spawn the reactor exploding projectile under a 3rd faction that is not playable so it damages everyone
end

function Engines_Destroyed(unit)
    if not unit.Are_Engines_Online() and TestValid(unit) then
        DebugMessage("%s -- Engines are Destroyed and Unit is Alive, Spawning Projectile", tostring(Script))
        Create_Generic_Object("Redirect_Engine_Power_40", unit.Get_Position(), unit.Get_Owner()) -- if the engines are no longer alive, spawn a projectile to increase the ships firerate
    end
end

function Is_Reactor_Active(unit)
    if unit.Is_Ability_Ready(ability_name) or unit.Is_Ability_Active(ability_name) then -- This simply checks if the ship can use its ability that is linked to the reactor system
        return true
    end
end

function Unit_Reactor_Table(deathtable)
    DebugMessage("%s -- Running Unit Reactor, Defining Table", tostring(Script))
    final_unit_table = {}
    for _, ship in pairs(units_with_reactors) do
        DebugMessage("%s -- Current Ship Type to search for: %s", tostring(Script), tostring(ship.Get_Name()))
        allShipObjectsOfType = Find_All_Objects_Of_Type(ship)
        for _, unit in pairs(allShipObjectsOfType) do
            DebugMessage("%s -- Checking All Objects Of Type Table", tostring(Script))
            if TestValid(unit) then
                DebugMessage("%s -- Found Unit and is valid", tostring(Script))
                if table.getn(deathtable) == 0 then
                    DebugMessage("%s -- Exploded Units Table is empty, adding unit to table", tostring(Script))
                    table.insert(final_unit_table, unit)
                else
                    for k, unitC in pairs(deathtable) do
                        DebugMessage("%s -- Checking if ship is in exploded units table", tostring(Script))
                        if TestValid(unitC) then
                            if unit == unitC then
                                DebugMessage("%s -- Unit is in table", tostring(Script))
                                return
                            else
                                DebugMessage("%s -- Found Unit of Type inserting into final table", tostring(Script))
                                table.insert(final_unit_table, unit)
                            end
                        else 
                            DebugMessage("%s -- Unit we are trying to compare does not exist, removing", tostring(Script))
                            table.remove(deathtable, k)
                            break
                        end
                    end
                end
            end
        end
    end
    DebugMessage("%s -- Done and returning table", tostring(Script))
    return final_unit_table -- return the final table with all the current units
end

function Process_Reactor_Table(tableunits, dead_table)
    DebugMessage("%s -- Printing Active Units with reactors - Process_Reactor_Table()", tostring(Script))
    DebugPrintTable(tableunits)
    DebugPrintTable(dead_table)
    for k, unit in pairs(tableunits) do -- loops through every item in the mentioned table and for every item it does the below
        if not TestValid(unit) then
            DebugMessage("%s -- Unit not alive", tostring(Script))
            table.remove(tableunits, k)
        else 
            DebugMessage("%s -- Unit is Valid, %s", tostring(Script), tostring(unit.Get_Type().Get_Name()))
            if table.getn(dead_table) > 0 then
                for k, unitC in pairs(dead_table) do
                    DebugMessage("%s -- Checking if any units in death table", tostring(Script))
                    if TestValid(unitC) then
                        if unitC == unit then
                            DebugMessage("%s -- Unit was in death table, returning", tostring(Script))
                            table.remove(tableunits, k)
                            DebugPrintTable(tableunits)
                            DebugPrintTable(dead_table)
                            return
                        else
                            if not Is_Reactor_Active(unit) and unit.Can_Move() then -- If the Reactor of the unit is not active, run the below
                                DebugMessage("%s -- Reactor isn't alive, running reactor funcs, %s", tostring(Script), tostring(unit.Get_Type().Get_Name()))
                                Reactor_Explode(unit) -- Explode the Reactor of the unit by spawning a projectile
                                if unit.Get_Owner().Get_Faction_Name() == "EMPIRE" then -- if the Unit's owner so the AI or player is playing as the Covenant 
                                    DebugMessage("%s -- Player is Covie, adding Engine to Firerate", tostring(Script))
                                    Engines_Destroyed(unit) -- Run the Engines_Destroyed function for this unit
                                end
                                DebugMessage("%s -- Current Index: %s, Current Unit: %s", tostring(Script), tostring(k), tostring(unit))
                                table.remove(tableunits, k)
                                table.insert(dead_table, unit)
                                Sleep(1)
                                return 
                            end
                            DebugMessage("%s -- Exiting For Statement for this Unit: %s", tostring(Script), tostring(unit.Get_Type().Get_Name()))
                            return
                        end
                    end
                end
            else
                DebugMessage("%s -- Dead Units Table is empty", tostring(Script))
                if not Is_Reactor_Active(unit) and unit.Can_Move()  then -- If the Reactor of the unit is not active, run the below
                    DebugMessage("%s -- Reactor isn't alive, running reactor funcs, %s", tostring(Script), tostring(unit.Get_Type().Get_Name()))
                    Reactor_Explode(unit) -- Explode the Reactor of the unit by spawning a projectile
                    if unit.Get_Owner().Get_Faction_Name() == "EMPIRE" then -- if the Unit's owner so the AI or player is playing as the Covenant 
                        DebugMessage("%s -- Player is Covie, adding Engine to Firerate", tostring(Script))
                        Engines_Destroyed(unit) -- Run the Engines_Destroyed function for this unit
                    end
                    DebugMessage("%s -- Current Index: %s, Current Unit: %s", tostring(Script), tostring(k), tostring(unit))
                    table.remove(tableunits, k)
                    table.insert(dead_table, unit)
                    Sleep(1)
                    return 
                end
                DebugMessage("%s -- Exiting For Statement for this Unit: %s", tostring(Script), tostring(unit.Get_Type().Get_Name()))
                return
            end
        end
    end
end
