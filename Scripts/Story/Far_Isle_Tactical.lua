require("PGStateMachine")
require("HALOFunctions")
function Definitions()

	ServiceRate = 1

	Define_State("State_Init", State_Init);

    spawned_units = false
end

function State_Init(message)
	if message == OnEnter then
		-- prevent this from doing anything in galactic mode
		if Get_Game_Mode() == "Galactic" then
			ScriptExit()
		end
		
	end
	if message == OnUpdate then

        player = Find_Human_Player()

        Spawn_Terror_Units()

        if Check_Story_Flag(player, "Rebels_Wiped", nil, true) then

            far_isle_flag = Find_First_Object("Longsword_Spawn")

            
            Reinforce_Unit(Find_Object_Type("Longsword_Far_Isle_Squadron"),false,player)

            Story_Event("Reinforce_Longsword_Objective")

            longsword = Find_First_Object("Longsword_Far_Isle_Squadron_Container")

            while not TestValid(longsword) do
                longsword = Find_First_Object("Longsword_Far_Isle_Squadron_Container")
                Sleep(1)
            end

            Story_Event("Longsword_Spawned")

            far_isle_flag.Highlight(true)

            while not (longsword.Get_Distance(far_isle_flag) < 150) do
                Sleep(1)
            end

            far_isle_flag.Highlight(false)

            Story_Event("Longsword_Moved")

            longsword.Set_Selectable(false)

            longsword.Suspend_Locomotor(true)

            Sleep(5)

            Create_Generic_Object(Find_Object_Type("SHIVA_NUKE_HUGE"),far_isle_flag.Get_Position(),player)

            longsword.Play_SFX_Event("SFX_Concussion_Missile_Detonation")
            
            Story_Event("Nuke_Activated")

            ScriptExit()
    
        end
	end
end

function Spawn_Terror_Units()

    if spawned_units then
        return
    end

    insurrectionists_units = {
        ["TERROR_HALCYON"] = 4,
        ["TERROR_STALWART"] = 3,
        ["TERROR_GLADIUS"] = 4,
        ["TERROR_Baselard_Squadron"] = 5
    }

    terror = Find_Player("TERRORISTS")

    terror.Enable_As_Actor()

    defender_flag = Find_First_Object("Defending Forces Position")

    for unit, amount in pairs(insurrectionists_units) do
        DebugMessage("Unit: %s, Amount: %s",tostring(unit),tostring(amount))
        for x=amount, 1, -1 do
            DebugMessage("Amount: %s", tostring(x))
            unitToSpawn = Find_Object_Type(unit)
            
            new_units = Spawn_Unit(unitToSpawn,defender_flag,terror)
            if new_units ~= nil then
                for _, unit in pairs(new_units) do
                    unit.Prevent_AI_Usage(false)
                end
            end
        end
    end

    spawned_units = true

    Story_Event("Spawned_All_Units")

end