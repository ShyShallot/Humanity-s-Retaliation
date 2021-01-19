require("PGBaseDefinitions")
require("PGStateMachine")
require("HALOFunctions")
-- Script is used for Humanity's Retaliation 
-- Boarding Script is written by ShyShallot, If you wish to use this script please contact the Project Gold Team via Discord
-- Any use of this script without permission will not be fun for offending party.
-- Any Modifications of this Script for Submods of Humanity's Retliation are allowed as long as they stay in this mod 
-- Even if you modify this script for a submod, you still do not have permission to use else where

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
        UntilBoardChances = 0  -- Used to check if we should start using chances during the building, like to cancel or take over the ship
        TotalBoardUses = 0 -- Used to destory the Tractor Beam Hardpoint after X amount of uses
        ShouldRun = 0 -- Should we loop the Damage and Chance functions during boarding
        InitalBoardingChance = 0.45 -- The Intial Chance for the boarding to begin
        TakeOverChance =  0.95 -- Used for the chance of taking over the ship
        FailChance = 0.6 -- The Chance for the boarding to fail and stop
        player = Object.Get_Owner() -- Since we cant Use PlayerObject directly, get the player from the Object calling this script
   
    elseif message == OnUpdate then
        DebugMessage("%s -- In OnEnter", tostring(Script))


        if player.Is_Human() then 
            if Object.Is_Ability_Active(ability_name) then -- If Tractor Beam ability is active
                DebugMessage("%s -- Tractor Beam is now active running function", tostring(Script))
                Find_Nearest_Board_Target(false)
            end
        else 
            DebugMessage("%s -- Running AI Ability", tostring(Script))
            -- DO NOT ENABLE THIS YET refer to Line 71 and 72
            --Set_Next_State("State_AI_Autofire")
        end
    end
end

function State_AI_Autofire(message)
    if message == OnUpdate then
        DebugMessage("%s -- Is AI Checking for Ability", tostring(Script))
        if Object.Is_Ability_Ready(ability_name) then -- Is the Boarding Ability ready to use
            DebugMessage("%s -- Running Ability from AI", tostring(Script))
            Find_Nearest_Board_Target(true) -- Run this function with true to let the Function know the AI is using it
		end
	end		
end

function Find_Nearest_Board_Target(is_owner_ai) 
    DebugMessage("%s -- Running Find_Nearest_Board_Target", tostring(Script))
    target = Find_Nearest(Object, "Corvette | Frigate | Capital", player, false) -- Find_Nearest(Object to Search around, Optinal Catergory Filter: "Frigate | Capital", player object, if its owned by the player)
    if TestValid(target) then
        if is_owner_ai == true then
            -- IGNORE this for now, cause fuck this, freezes the game for no damn reason
            -- Have to fix later
            --Object.Activate_Ability(ability_name, target)
            --Sleep(1)
            --InitalBoardingChance = 0.65 
            --TakeOverChance =  0.93
            --FailChance = 0.3
            --ShouldRun = 1
            --Sleep(1)
            --BoardingFunction()
            --Sleep(1)
            --is_owner_ai = false 
        else
            ShouldRun = 1
            BoardingFunction()
        end
    else 
        DebugMessage("%s -- Cant Find Targeting Sleeping Script", tostring(Script))
        Sleep(1)
    end  -- Cant find Target sleeping for 1 seconds to give time to find one.
end



function BoardingFunction()
    DebugMessage("%s -- In Boarding Function", tostring(Script))
    BoardingDamage = target.Get_Health() / 90 -- 10% of its total health
    ShipHealthThreshold = target.Get_Health() / 90 -- 10% of its total health
    ShouldRun = 1
    if Is_Target_Affected_By_Ability(target, ability_name) then  -- If target is alive and is being affected by tractor beam then run
        DebugMessage("%s -- Found Target", tostring(target))
        while TestValid(target) and ShouldRun == 1 do -- using a Var and test valid prevents a recursion loop which crashes the game
            if Get_Target_Distance(Object, target) <= 800 then 
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
                            local chances = UntilBoardChances + 1
                            Sleep(3)
                            if chances >= 5 then
                                if Return_Chance(FailChance)  then -- If the boarding units die by chance
                                    Sleep(3)
                                    ShouldRun = 0
                                    target = nil -- Set our target as Null or Nil so the script stops damaging the ship
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
                                local uses = TotalBoardUses + 1
                                chances = 0
                                Object.Set_Selectable(true)
                                if uses >= 3 then
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
            else Object.Cancel_Ability(ability_name) end
        end
    else 
        ShouldRun = 0 
    end -- If the target we found isnt Alive and/or Not being affected by the Tractor Beam essentially restart the script
end

