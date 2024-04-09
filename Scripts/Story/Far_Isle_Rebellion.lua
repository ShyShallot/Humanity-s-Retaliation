require("PGStateMachine")
require("HALOFunctions")
require("PGBaseDefinitions")
require("HALOFunctions") 


function Definitions()
    ServiceRate = 1
	Define_State("State_Init", State_Init);

    
end

function State_Init(message)
    if message == OnEnter then
        warning = false

        started = false

    end
    
    if message == OnUpdate then
        player = Find_Human_Player()

        far_isle = Find_First_Object("Far_Isle")

        has_far_isle_mission_started = Check_Story_Flag(player, "Far_Isle_Rebellion_Start", nil, false)

        if Get_Current_Week() >= 20 and far_isle.Get_Owner().Get_Faction_Name() == player.Get_Faction_Name() and (not warning) then
            warning = true
            Story_Event("Start_Far_Isle_Warning")
        end

        if Get_Current_Week() >= 25 and far_isle.Get_Owner().Get_Faction_Name() == player.Get_Faction_Name() and (not has_far_isle_mission_started) then
            Story_Event("Start_Far_Isle_Fall")
            started = true
        end
        
        if not started then
            DebugMessage("Far Isle mission has not yet started")
            return
        end

        DebugMessage("Killing UNSC Units on Far Isle")
        Kill_UNSC_Units_At_Location(far_isle, player)

        terror = Find_Player("TERRORISTS")

        far_isle.Change_Owner(terror)
        DebugMessage("Changing Far Isle Planet Owner")

        ScriptExit()
    end
end

function Kill_UNSC_Units_At_Location(planet_name, player)
    if not player.Get_Faction_Name() == "REBEL" or not player.Get_Faction_Name() == "EMPIRE" then
        return nil
    end
    local all_player_units = Find_All_Objects_Of_Type(player, "Fighter | Bomber | Corvette | Frigate | Capital | Super")
    for _, unit in ipairs(all_player_units) do
        if TestValid(unit) then
            if TestValid(unit.Get_Planet_Location()) then
                if unit.Get_Planet_Location().Get_Type().Get_Name() == planet_name then
                    unit.Despawn()
                end
            end
        end
    end
end