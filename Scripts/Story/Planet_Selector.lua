require("PGStateMachine")
require("PGBaseDefinitions")
require("HALOFunctions")

function Definitions()
    ServiceRate = 0.5
	Define_State("State_Init", State_Init);

end

function State_Init(message)
    if message == OnEnter then

        human = Find_Human_Player()

        planets = FindPlanet.Get_All_Planets()

        plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Planet_Selection.xml")

        local planets = FindPlanet.Get_All_Planets()

        for i,planet in ipairs(planets) do

            event = plot.Get_Event("SELECT_"..planet.Get_Type().Get_Name())

            event.Set_Reward_Parameter(1, human.Get_Faction_Name())
        end
    end

    if message == OnUpdate then

        plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Planet_Selection.xml")

        DebugMessage("Resetting Select Plot")

        plot.Reset()
    end
end