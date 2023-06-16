require("PGStateMachine")
require("PGSpawnUnits")

function Definitions()

   -- Object isn't valid at this point so don't do any operations that
   -- would require it.  State_Init is the first chance you have to do
   -- operations on Object
   
	DebugMessage("%s -- In Definitions", tostring(Script))
	Define_State("State_Init", State_Init);
    unsc = Find_Player("Rebel")
    covie = Find_Player("Empire")
end


function State_Init(message)
		if message == OnUpdate then
            Target_Covn()
		end
end

function getUnitList()
    return Find_All_Objects_Of_Type(unsc)
end


function Target_Covn()
    unit_list = getUnitList()
    for _, unit in pairs(unit_list) do
        if(TestValid(unit)) then
            if(unit.Is_Category("Bomber")) then
                unit.Attack_Target(Find_All_Objects_Of_Type(covie,"Frigate | Capital | SpaceStructure | Super"))
            end
            if(unit.Is_Category("Fighter")) then
                unit.Attack_Target(Find_All_Objects_Of_Type(covie,"Fighter | Bomber"))
            end
            if(unit.Is_Category("Corvette")) then
                unit.Attack_Target(Find_All_Objects_Of_Type(covie,"Fighter | Bomber | Corvette"))
            end
            if(unit.Is_Category("Frigate")) then
                unit.Attack_Target(Find_All_Objects_Of_Type(covie,"Corvette | Frigate | Capital"))
            end
            if(unit.Is_Category("Captial")) then
                unit.Attack_Target(Find_All_Objects_Of_Type(covie,"Frigate | Capital | Super"))
            end
            if(unit.Is_Category("Super")) then
                unit.Attack_Target(Find_All_Objects_Of_Type(covie,"Capital | Super | SpaceStructure"))
            end
        end
    end
end