require("PGStateMachine")
require("PGBaseDefinitions")
require("HALOFunctions")
require("PGStoryMode")

function Definitions()
    ServiceRate = 0.5
	Define_State("State_Init", State_Init);

end

function State_Init(message)
    if message == OnEnter then

        ScriptExit()

        local human = Find_Human_Player()

        local planets = FindPlanet.Get_All_Planets()

        local plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Planet_Zoom.xml")

        local planets = FindPlanet.Get_All_Planets()

        for i,planet in ipairs(planets) do

            local event = plot.Get_Event("ZOOM_"..planet.Get_Type().Get_Name())

            event.Set_Reward_Parameter(1, human.Get_Faction_Name())
        end
    end

    if message == OnUpdate then

        local planets = FindPlanet.Get_All_Planets()

        local plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Planet_Zoom.xml")

        local human = Find_Human_Player()

        for _, planet in pairs(planets) do
            local event = "PLAYER_ZOOMED_"..planet.Get_Type().Get_Name()

            if Check_Story_Flag(human, event, nil, false) then
                DebugMessage("ZOOM EVENT FOR %s", tostring(planet))
                --GUI_Component_Visibility("i_main_organize",false)
            end
        end

        DebugMessage("Resetting Zoom Plot")

        plot.Reset()
    end
end