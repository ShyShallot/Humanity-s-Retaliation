require("PGStoryMode")
require("PGStateMachine")
require("HALOFunctions")

function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
    Define_State("State_Init", State_Init)

    mission_started = false

    shield_tech_built = false

    info_shown = false

end

function State_Init(message) 


    if  message == OnEnter then 
        Rebel_Player = Find_Player("REBEL")

    end
    if message == OnUpdate then
        Forerunner_Artifact_Mission_Check()
        Check_For_Shield_Tech()
        Upgrade_Carriers()
        Sleep(1)
    end
end


function Forerunner_Artifact_Mission_Check()
    local Rebel_Player = Find_Player("REBEL")

    local installation_05 = FindPlanet("Installation_05")

    local shield_research = Find_First_Object("UNSC_Tech_Shield")

    if not TestValid(installation_05) then
        DebugMessage("Could not Find Installation 05")
        return
    end

    if TestValid(shield_research) then
        return
    end

    if shield_tech_built then
        return
    end

    if Rebel_Player.Get_Tech_Level() >= 3 then -- Rebel Tech goes from 0-4, 4 being tech 5
        DebugMessage("Player is Tech 4")
        if installation_05.Get_Owner().Get_Faction_Name() ~= "REBEL" and not mission_started then
            DebugMessage("Starting Capture Mission")
            Story_Event("START_INSTALLATION_CAPTURE")
            mission_started = true
        elseif installation_05.Get_Owner().Get_Faction_Name() == "REBEL" then 
            GlobalValue.Set("Is_Shield_Tech_Not_Available", 0)
            if not info_shown then
                Story_Event("SHIELD_TECH_INFO")
                info_shown = true
            end
        end
    else 
        GlobalValue.Set("Is_Shield_Tech_Not_Available", 1)
    end
end

function Check_For_Shield_Tech()
    shield_research = Find_First_Object("UNSC_Tech_Shield")

    Rebel_Player = Find_Player("REBEL")

    if TestValid(shield_research) then
        shield_tech_built = true
        GlobalValue.Set("Is_Shield_Tech_Not_Researched", 0)
        GlobalValue.Set("Is_Shield_Tech_Not_Available", 1)
        GlobalValue.Set("Is_Shield_Tech_Researched", 1)
    else
        if shield_tech_built then 
            shield_tech_built = false
            mission_started = false
        end
        GlobalValue.Set("Is_Shield_Tech_Not_Researched", 1)
        GlobalValue.Set("Is_Shield_Tech_Not_Available", 0)
        GlobalValue.Set("Is_Shield_Tech_Researched", 0)
    end
end

function Upgrade_Carriers() 
    shield_tech = Find_First_Object("UNSC_Tech_Shield")
    Rebel_Player = Find_Player("REBEL")
    tech_level = Rebel_Player.Get_Tech_Level() + 1
    if TestValid(shield_tech) and tech_level == 4 then
        poseidon_carriers = Find_All_Objects_Of_Type("UNSC_POSEIDON")
        musashi_carriers = Find_All_Objects_Of_Type("UNSC_MUSASHI")
        if table.getn(poseidon_carriers) <= 0 and table.getn(musashi_carriers) <= 0 then 
            return
        end
        for i, poseidon in pairs(poseidon_carriers) do
            planet = poseidon.Get_Planet_Location()
            poseidon.Despawn()
            Spawn_Unit(Find_Object_Type("UNSC_POSEIDON_2"),planet,Rebel_Player)
        end
        for i, musashi in pairs(musashi_carriers) do
            planet = poseidon.Get_Planet_Location()
            musashi.Despawn()
            Spawn_Unit(Find_Object_Type("UNSC_MUSASHI_2"),planet,Rebel_Player)
        end
    end
end