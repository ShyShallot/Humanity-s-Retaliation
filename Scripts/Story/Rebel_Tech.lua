require("PGStoryMode")
require("PGStateMachine")
function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
    StoryModeEvents =
    {
        Universal_Story_Start = Global_Story
    }

end

-- Yes this code is similar to AOTR, i used it as a base for the most part and how things are done are based off of aotr, 
--i thank them for the original idea

function Story_Mode_Service()

end

function Global_Story(message)
    if  message == OnEnter then 
        Rebel_Player = Find_Player("REBEL")

        locked_units = {
            "UNSC_AUTUMN",
            "UNSC_INFINITY",
            "UNSC_STRIDENT",
            "UNSC_VINDICATION",
            "BROADSWORD_SQUADRON",
            "Rebel_Star_Base_5",
        }

        for _, unit in pairs(locked_units) do
            Rebel_Player.Lock_Tech(Find_Object_Type(unit))
        end
    end
end