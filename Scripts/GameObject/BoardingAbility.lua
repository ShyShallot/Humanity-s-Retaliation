require("PGBaseDefinitions")
require("PGStateMachine")
require("HALOFunctions")
-- Script is used for Humanity's Retaliation 
-- Boarding Script is written by ShyShallot, If you wish to use this script please contact the Project Gold Team via Discord
-- Any use of this script without permission will not be fun for offending party.
-- Lua Doc: https://stargate-eaw.de/media/kunena/attachments/92/LuacommandsinFoC.pdf

-- Even tho Tractor Beams and Boarding are 2 unrelated abilities, the Tractor Beam allows us to target a specfic ship and check 
-- weather or not its being affected by it, other abilities like hack don't work due to Petro being very funny
-- Namely this error: Is_Under_Effects_Of_Ability -- ability TARGETED_HACK is not yet supported.  You'll need some programming help if you think it should be.


function Definitions()
    ServiceRate = 1

    Define_State("State_Init", State_Init);
    Define_State("State_AI_Autofire", State_AI_Autofire)
    DebugMessage("%s -- In Definitions", tostring(Script))
    

end

function State_Init(message)
    if message == OnEnter then
        DebugMessage("%s -- In Init", tostring(Script))
        ability_name = "TRACTOR_BEAM" -- Check if the object calling the script has the ability in the first place
        UntilBoardChances = 0  
        TotalBoardUses = 0
        ShouldRun = 1
        AIRUN = 0
        InitalBoardingChance = 0.45
        TakeOverChance =  0.95
        FailChance = 0.6
        player = Object.Get_Owner() -- Since we cant Use PlayerObject directly, get the player from the Object calling this script
        
   
    elseif message == OnUpdate then
        DebugMessage("%s -- In OnEnter", tostring(Script))
        if player.Is_Human() then 
            if Object.Is_Ability_Active(ability_name) then -- If Tractor Beam ability is active
                DebugMessage("%s -- Tractor Beam is now active running function", tostring(Script))
                Find_Nearest_Board_Target(false)
            else Sleep(2) end
        else 
            DebugMessage("%s -- Running AI Ability", tostring(Script))
            Set_Next_State("State_AI_Autofire")
        end
    end
end

function State_AI_Autofire(message)
    if message == OnUpdate then
        DebugMessage("%s -- Is AI Checking for Ability", tostring(Script))
        if Object.Is_Ability_Ready(ability_name) then
            DebugMessage("%s -- Running Ability from AI", tostring(Script))
            Object.Activate_Ability(ability_name, true)
            if Object.Is_Ability_Active(ability_name) then -- If Tractor Beam ability is active
                DebugMessage("%s -- Tractor Beam is now active running function from AI", tostring(Script))
                Find_Nearest_Board_Target(true)
            else Sleep(2) end
		end
	end		
end

function Find_Nearest_Board_Target(AIRUN) 
    DebugMessage("%s -- Running Find_Nearest_Board_Target", tostring(Script))
    target = Find_Nearest(Object, "Corvette | Frigate | Capital", player, false) -- Find_Nearest(Object to Search around, Optinal Catergory Filter: "Frigate | Capital", player object, if its owned by the player)
    if TestValid(target) then
        if AIRUN == true then
            InitalBoardingChance = 0.65 
            TakeOverChance =  0.93
            FailChance = 0.3
            ShouldRun = 1
            BoardingFunction()
        else
            ShouldRun = 1
            BoardingFunction()
        end
    else Sleep(2) end  
end



function BoardingFunction()
    DebugMessage("%s -- In Boarding Function", tostring(Script))
    BoardingDamage = target.Get_Health() / 90 -- 10% of its total health
    ShipHealthThreshold = target.Get_Health() / 90 -- 10% of its total health
    ShouldRun = 1
    if Is_Target_Affected_By_Ability(target, ability_name) then  -- If target is alive and is being affected by tractor beam then run
        DebugMessage("%s -- Found Target", tostring(target))
        while TestValid(target) and ShouldRun == 1 do -- using a Var and test valid prevents a recursion loop which crashes the game
            DebugMessage("%s -- Found Nearest Target", tostring(target))
            boardingActive = false -- Boarding is not active, used for loop 
            if Object.Is_Ability_Active(ability_name) then -- Double check if the ability is active 
                DebugMessage("%s -- Abiltiy Active running Main Function", tostring(Script))
                Object.Turn_To_Face(target)
                if Return_Chance(InitalBoardingChance)  then -- 55% Percent Chance for players, 45% for AI
                    DebugMessage("%s -- Boarding Successful running Boarding", tostring(Script))
                    boardingActive = true -- set board to active and run loop
                    Object.Play_SFX_Event("SFX_UMP_EmpireKesselAlarm")
                    while boardingActive == true do
                        Object.Set_Selectable(false)
                        DebugMessage("%s -- Boarding Active, Running Boarding Damage", tostring(Script))
                        Deal_Unit_Damage_Seconds(target, BoardingDamage, nil, 0, "Unit_Hardpoint_Turbo_Laser_Death")
                        UntilBoardChances = UntilBoardChances + 1
                        Sleep(3)
                        if UntilBoardChances >= 10 then
                            if Return_Chance(FailChance)  then -- If the boarding units die by chance
                                Sleep(3)
                                ShouldRun = 0
                                target = nil
                                boardingActive = false -- Boarding No Longer active, exit loop
                                Object.Cancel_Ability(ability_name) -- Make sure the "Tractor Beam" ability stops
                                Object.Play_SFX_Event("SFX_UM02_MagneticSealedDoor")
                                Object.Set_Selectable(true)
                            end
                            if Return_Chance(TakeOverChance) and boardingActive == true then -- If the boarding Take over chance succeeds and boarding is active, take over ship
                                target.Change_Owner(Find_Player("Empire")) -- Switch target ship owner from enemy to covies
                                Object.Cancel_Ability(ability_name) -- Stop the "Tractor Beam" Ability
                                boardingActive = false
                                target = nil
                                Object.Play_SFX_Event("Unit_Select_Vader_Executor")
                                ShouldRun = 0
                                Object.Set_Selectable(true)
                            end
                            if target.Get_Health() <= ShipHealthThreshold then -- If the Ship health is below a value then just straight up blow up the ship
                                Deal_Unit_Damage(target, 10000000, nil)
                                boardingActive = false -- Boarding no Longer active exit loop
                                Object.Cancel_Ability(ability_name)
                                ShouldRun = 0
                                target = nil
                                Object.Set_Selectable(true)
                            end
                            TotalBoardUses = TotalBoardUses + 1
                            UntilBoardChances = 0
                            Object.Set_Selectable(true)
                            if TotalBoardUses >= 3 then
                                Deal_Unit_Damage(Object, 1, HP_BOARD_POINT)
                            end
                        end
                    end
                else 
                    Object.Cancel_Ability(ability_name) 
                    ShouldRun = 0
                    Object.Play_SFX_Event("Unit_Star_Destroyer_Death_SFX")
                    DebugMessage("%s -- Canceling Ability Chance Failed", tostring(Script)) 
                end
            end
        end
    else ShouldRun = 0 end
end

