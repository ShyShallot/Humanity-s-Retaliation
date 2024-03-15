require("PGBaseDefinitions")
require("PGStateMachine")
require("HALOFunctions")

function Definitions()
    ServiceRate = 1

    Define_State("State_Init", State_Init);
    Define_State("State_AI_Autofire", State_AI_Autofire)
    DebugMessage("%s -- In Definitions", tostring(Script))
    

end

function State_Init(message)
    if message == OnEnter then

        if Get_Game_Mode() ~= "Galactic" then
            return
        end

        planet = Object.Get_Planet_Location()

        object_to_find = string.gsub(Object.Get_Type().Get_Name(),"DELETE_","")

        object_type = Find_Object_Type(object_to_find)

        all_objects = Find_All_Objects_Of_Type(object_type)

        for _,object in pairs(all_objects) do
            if object.Get_Planet_Location() == Object.Get_Planet_Location() then
                Object.Get_Owner().Give_Money(object.Get_Type().Get_Build_Cost()/2)
                object.Despawn()
                Object.Despawn()
                return
            end
        end
    end
end
