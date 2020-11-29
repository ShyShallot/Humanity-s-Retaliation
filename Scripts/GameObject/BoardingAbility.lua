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
    DebugMessage("%s -- In Definitions", tostring(Script))
    enemy_player = Find_Player("Rebel") -- Enemy Player for reference of finding target
    target = nil -- Target Var for future reference
    

end

function State_Init(message)
    if message == OnEnter then
        DebugMessage("%s -- In Init", tostring(Script))
        ability_name = "TRACTOR_BEAM" -- Check if the object calling the script has the ability in the first place
        UntilBoardChances = 0  
        ShouldRun = 1
        player = Object.Get_Owner()
        
   
    elseif message == OnUpdate then
        DebugMessage("%s -- In OnEnter", tostring(Script))
        if Object.Is_Ability_Active(ability_name) then -- If Tractor Beam ability is active
            DebugMessage("%s -- Tractor Beam is now active running function", tostring(Script))
            Find_Nearest_Board_Target()
        else Sleep(2) end
    end
end

function Find_Nearest_Board_Target() 
    DebugMessage("%s -- Running Find_Nearest_Board_Target", tostring(Script))
    target = Find_Nearest(Object, "Corvette | Frigate | Capital", player, false) -- Find_Nearest(Object to Search around, Optinal Catergory Filter: "Frigate | Capital", player object, if its owned by the player)
    if TestValid(target) then
        BoardingFunction()
        ShouldRun = 1
    else Sleep(2) end  
end

function BoardingFunction()
    DebugMessage("%s -- In Boarding Function", tostring(Script))
    BoardingDamage = target.Get_Health() / 90 -- 10% of its total health
    ShipHealthThreshold = target.Get_Health() / 90
    if Is_Target_Affected_By_Ability(target, ability_name) then  -- If target is alive and is being affected by tractor beam then run
        DebugMessage("%s -- Found Target", tostring(target))
        while TestValid(target) and ShouldRun == 1 do -- Loop function for when the target is alive
            DebugMessage("%s -- Found Nearest Target", tostring(target))
            boardingActive = false -- Boarding is not active, used for loop 
            if Object.Is_Ability_Active(ability_name) then -- Double check if the ability is active 
                DebugMessage("%s -- Abiltiy Active running Main Function", tostring(Script))
                Object.Turn_To_Face(target)
                if Return_Chance(0.25)  then -- if our inital boarding succeddes continue
                    DebugMessage("%s -- Boarding Successful running Boarding", tostring(Script))
                    boardingActive = true -- set board to active and run loop
                    Object.Play_SFX_Event("SFX_UMP_EmpireKesselAlarm")
                    while boardingActive == true do
                        Object.Set_Selectable(false)
                        DebugMessage("%s -- Boarding Active, Running Boarding Damage", tostring(Script))
                        Deal_Unit_Damage_Seconds(target, BoardingDamage, 3, "Unit_Hardpoint_Turbo_Laser_Death")
                        UntilBoardChances = UntilBoardChances + 1
                        if UntilBoardChances >= 8 then
                            if Return_Chance(0.6)  then -- If the boarding units die by chance
                                Sleep(3)
                                ShouldRun = 0
                                boardingActive = false -- Boarding No Longer active, exit loop
                                Object.Cancel_Ability(ability_name) -- Make sure the "Tractor Beam" ability stops
                                Object.Play_SFX_Event("SFX_UM02_MagneticSealedDoor")
                                Object.Set_Selectable(true)
                            end
                            if Return_Chance(0.95) and boardingActive == true then -- If the boarding Take over chance succeeds and boarding is active, take over ship
                                target.Change_Owner(Find_Player("Empire")) -- Switch target ship owner from enemy to covies
                                Object.Cancel_Ability(ability_name) -- Stop the "Tractor Beam" Ability
                                Object.Play_SFX_Event("Unit_Select_Vader_Executor")
                                ShouldRun = 0
                                Object.Set_Selectable(true)
                            end
                            if target.Get_Health() <= ShipHealthThreshold then -- If the Ship health is below a value then just straight up blow up the ship
                                Deal_Unit_Damage(target, 10000000)
                                boardingActive = false -- Boarding no Longer active exit loop
                                Object.Cancel_Ability(ability_name)
                                ShouldRun = 0
                                Object.Set_Selectable(true)
                            end
                            UntilBoardChances = 0
                            Object.Set_Selectable(true)
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
    end
end