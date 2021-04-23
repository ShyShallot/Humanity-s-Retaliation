require("PGStateMachine")
require("HALOFunctions")
function Definitions()

	DebugMessage("%s -- In Definitions", tostring(Script))
	ServiceRate = 1
	Define_State("State_Init", State_Init);
    ability_name = "INTERDICT"
    reactor_exploded = false
end

function State_Init(message) 
    if message == OnEnter then 
        Create_Thread("Ship_Systems", 1)
    elseif message == OnUpdate then
    end
end

function Ship_Systems(cycletime)
    while true do
        if Object.Get_Owner().Get_Faction_Name() == "EMPIRE" then
            DebugMessage("%s -- Player is Covie, adding Engine to Firerate", tostring(Script))
            Engines_Destroyed(Object)
        end
        DebugMessage("%s -- Checking for Reactor Health", tostring(Script))
        if Object.Is_Ability_Active(ability_name) then
            Object.Cancel_Ability(ability_name)
            Object.Reset_Ability_Counter()
        end
        if reactor_exploded == false then
            Reactor_Explode()
        end
        Sleep(cycletime)
    end
end

function Is_Reactor_Active(unit)
    if unit.Is_Ability_Ready(ability_name) then
        return true
    end
end

function Reactor_Explode()
    if not Is_Reactor_Active(Object) then
        if reactor_exploded == false then
            if not Object.Are_Engines_Online() then
                Object.Override_Max_Speed(0.1)
                DebugMessage("%s -- Engines are Alive, Reactor is not, Reducing Speed", tostring(Script))
            end
            DebugMessage("%s -- Spawning Reduce Firerate", tostring(Script))
            Create_Generic_Object("Reduce_Ship_Firespeed_40", Object.Get_Position(), Find_Player("UNDERWORLD"))
            DebugMessage("%s -- Spawning Big Kaboom", tostring(Script))
            Create_Generic_Object("Reactor_Explode", Object.Get_Position(), Find_Player("UNDERWORLD"))
            reactor_exploded = true
        end
    end
end

function Engines_Destroyed(unit)
    if not unit.Are_Engines_Online() and TestValid(unit) then
        DebugMessage("%s -- Engines are Destroyed and Unit is Alive, Spawning Projectile", tostring(Script))
        Create_Generic_Object("Redirect_Engine_Power_40", unit.Get_Position(), unit.Get_Owner())
    end
end

