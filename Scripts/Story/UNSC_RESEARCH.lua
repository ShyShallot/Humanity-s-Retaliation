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

        GlobalValue.Set("Shield_Tech_Available", 0)
    end
    if message == OnUpdate then
        Forerunner_Artifact_Mission_Check()
        Check_For_Shield_Tech()
        Upgrade_Carriers()
        Sleep(1)
    end
end


function Forerunner_Artifact_Mission_Check()
    Rebel_Player = Find_Player("REBEL")

    installation_05 = FindPlanet("Installation_05")

    shield_research = Find_First_Object("UNSC_Tech_Shield")

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
            Lock_Unit("UNSC_Tech_Shield",Rebel_Player,false)
            GlobalValue.Set("Shield_Tech_Available", 1)
            if not info_shown then
                Story_Event("SHIELD_TECH_INFO")
                info_shown = true
            end
        end
    else 
        Lock_Unit("UNSC_Tech_Shield",Rebel_Player)
    end
end

function Check_For_Shield_Tech()
    shield_research = Find_First_Object("UNSC_Tech_Shield")

    Rebel_Player = Find_Player("REBEL")

    if TestValid(shield_research) then
        shield_tech_built = true
        Lock_Unit("UNSC_Tech_Shield",Rebel_Player)
        Lock_Unit("UNSC_TECH_5",Rebel_Player,false)
        Lock_Unit("BROADSWORD_SQUADRON",Rebel_Player,false)
        Lock_Unit("UNSC_STRIDENT",Rebel_Player,false)
        Lock_Unit("UNSC_MUSASHI_2",Rebel_Player,false)
        Lock_Unit("UNSC_POSEIDON_2",Rebel_Player,false)
        Lock_Unit("UNSC_MUSASHI",Rebel_Player)
        Lock_Unit("UNSC_POSEIDON",Rebel_Player)
        if Rebel_Player.Get_Tech_Level() == 4 then
            Lock_Unit("UNSC_INFINITY",Rebel_Player,false)
            Lock_Unit("UNSC_VINDICATION",Rebel_Player,false)
            Lock_Unit("UNSC_AUTUMN",Rebel_Player,false)
        end
    else
        if shield_tech_built then 
            shield_tech_built = false
            mission_started = false
        end
        GlobalValue.Set("Shield_Tech_Available", 0)
        Lock_Unit("UNSC_TECH_5",Rebel_Player)
        Lock_Unit("BROADSWORD_SQUADRON",Rebel_Player)
        Lock_Unit("UNSC_STRIDENT",Rebel_Player)
        Lock_Unit("UNSC_MUSASHI_2",Rebel_Player)
        Lock_Unit("UNSC_POSEIDON_2",Rebel_Player)
        Lock_Unit("UNSC_MUSASHI",Rebel_Player,false)
        Lock_Unit("UNSC_POSEIDON",Rebel_Player,false)
        Lock_Unit("UNSC_INFINITY",Rebel_Player)
        Lock_Unit("UNSC_VINDICATION",Rebel_Player)
        Lock_Unit("UNSC_AUTUMN",Rebel_Player)
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