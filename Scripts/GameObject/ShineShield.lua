require("PGStateMachine")
require("HALOFunctions")

--Once this object has fully transitioned to a playable side it spits out vehicles for its owner

function Definitions()
	ServiceRate = 1

	Define_State("State_Init", State_Init);
end

function State_Init(message) 
    if message == OnEnter then
        covies = Find_Player("Empire")

    elseif message == OnUpdate then
        covie_unit_list = Find_All_Objects_Of_Type(covies)
        Shine_Shield(covie_unit_list)

    end

end

function Shine_Shield(units)
    for k, unitG in pairs(units) do
        if TestValid(unitG) then
            unit = unitG
        end
    end
    if TestValid(unit) then
        if unit.Get_Shield() <= 0.0 then
            Sleep(1)
        else 
            for k, unit in pairs(units) do
                if TestValid(units) then
                    if unit.Get_Rate_Of_Damage_Taken() > 1 then
                        Hide_Sub_Object(unit, 0, "SHIELD")
                        Sleep(0.6)
                        Hide_Sub_Object(unit, 1, "SHIELD")
                    end
                end
            end
        end
    end
end
