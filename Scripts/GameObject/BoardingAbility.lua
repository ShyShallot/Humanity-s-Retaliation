require("PGBaseDefinitions")
require("PGStateMachine")
require("HALOFunctions")
require("PGBase")
-- Script is used for Humanity's Retaliation 
-- Boarding Script is written by ShyShallot, If you wish to use this script please contact the Project Gold Team via Discord
-- Any use of this script without permission will not be fun for offending party.
-- Any Modifications of this Script for Submods of Humanity's Retliation are allowed as long as they stay in this mod 
-- Even if you modify this script for a submod, you still do not have permission to use else where
-- Lua Doc: https://stargate-eaw.de/media/kunena/attachments/92/LuacommandsinFoC.pdf
-- Even tho Tractor Beams and Boarding are 2 unrelated abilities, the Tractor Beam allows us to target a specfic ship and check 
-- weather or not its being affected by it, other abilities like hack don't work due to Petro being very funny
-- Namely this error: Is_Under_Effects_Of_Ability -- ability TARGETED_HACK is not yet supported.  You'll need some programming help if you think it should be.
boarder = {["object"] = Object, ["boarding"] = false}
boarded = {["object"] = nil, ["beingBoarded"] = false}

function Definitions()
    ServiceRate = 1

    Define_State("State_Init", State_Init);
    Define_State("State_AI_Autofire", State_AI_Autofire)
    DebugMessage("%s -- In Definitions", tostring(Script))
    ability_name = "TRACTOR_BEAM" -- Store the Name of the Ability for later use, saves on fingers
    UntilBoardChances = 0  -- Used to check if we should start using chances during the building, like to cancel or take over the ship
    TotalBoardUses = 0 -- Used to destory the Tractor Beam Hardpoint after X amount of uses
    max_distance = 800
    class_limits = "Corvette | Frigate | Capital" -- Used when searching for target, target has to be one of these classes
end

function State_Init(message)
    if message == OnEnter then
        DebugMessage("%s -- In Init", tostring(Script))
        player = Object.Get_Owner() -- Since we cant Use PlayerObject directly, get the player from the Object calling this script
    elseif message == OnUpdate then
        DebugMessage("%s -- In OnEnter", tostring(Script))
        if player.Is_Human() then 
            if Object.Is_Ability_Active(ability_name) then -- If Tractor Beam ability is active
                DebugMessage("%s -- Tractor Beam is now active running function", tostring(Script))
                Find_Nearest_Board_Target(Object) -- Register a Proximity for a Target 800 Units around our Object, this will help us find the target the player supplied
            end
        else 
            DebugMessage("%s -- Running AI Ability", tostring(Script))
            Set_Next_State("State_AI_Autofire") -- Object Calling this script is an AI set our state to AI Autofire for AI use
        end
    end
end

function State_AI_Autofire(message)
    if message == OnUpdate then
        DebugMessage("%s -- Is AI Checking for Ability", tostring(Script))
        if Object.Is_Ability_Ready(ability_name) then -- Is the Boarding Ability ready to use
            DebugMessage("%s -- Running Ability from AI", tostring(Script))
            is_owner_ai = true -- Let Find Nearest Target function know its an AI running it to set proper chances
            Create_Thread("Find_Nearest_Board_Target", Object)
        end
	end		
end

function Find_Nearest_Board_Target(self_obj) 
    DebugMessage("%s -- Running Find_Nearest_Board_Target", tostring(Script))
    target = Find_Nearest(Object, class_limits, player, false) -- Find_Nearest(Object to Search around, Optinal Catergory Filter: "Frigate | Capital", player object, if its owned by the player)
    while (not TestValid(target)) do
        target = Find_Nearest(Object, class_limits, player, false)
        Sleep(1)
    end
    if (TestValid(target)) and (not Is_Boardable_Unit(target)) then
        if is_owner_ai == true then
            Object.Activate_Ability(ability_name, target)
            InitalBoardingChance, TakeOverChance, FailChance = BoardingChances(self_obj.Get_Owner())
            Sleep(1)
            boarded.object = target
            boarder.board(boarded)
        else
            InitalBoardingChance, TakeOverChance, FailChance = BoardingChances(self_obj.Get_Owner())
            Sleep(1)
            boarded.object = target
            boarder.board(boarded)
        end
    end
end

function BoardingChances(owner) -- For Chance Scaling, cleans up shtuff
    diff = owner.Get_Difficulty()
    if owner.Is_Human() then
        InitalBoardingChance = 0.65 -- The Intial Chance for the boarding to begin
        TakeOverChance =  0.10 -- Used for the chance of taking over the ship
        FailChance = 0.45 -- The Chance for the boarding to fail and stop
    elseif diff == "Easy" then
        InitalBoardingChance = 0.45 
        TakeOverChance =  0.05
        FailChance = 0.65
    elseif diff == "Normal" then
        InitalBoardingChance = 0.65
        TakeOverChance =  0.10
        FailChance = 0.45
    elseif diff == "Hard" then
        InitalBoardingChance = 0.70
        TakeOverChance =  0.20
        FailChance = 0.30
    end
    return InitalBoardingChance, TakeOverChance, FailChance
end

function Is_Boardable_Unit(target)
    exluded_units = {
        UNSC_IROQUOIS,
        UNSC_POA,
        UNSC_INFINITY,
        COVN_CAS,
        UNSC_Mining_Transport,
        COVN_Mining_Transport
    }
    for k, exluded in pairs(exluded_units) do
        if (TestValid(target)) then
            if target.Get_Type() == Find_Object_Type(exluded) then
                return false
            else
                return true
            end
        end
    end
end

boarder.board = function(target)
    if TestValid(target.object) then
        DebugMessage("%s -- In Boarding Function", tostring(Script))
        local BoardingDamage = target.object.Get_Health() / 95 -- 5% of its total health
        if not target.beingBoarded and Is_Target_Affected_By_Ability(target.object, ability_name) and Object.Is_Ability_Active(ability_name) then
            DebugMessage("%s -- Target is available for Boarding Starting", tostring(Script))
            boarding = true
            while TestValid(target.object) and Object.Is_Ability_Active(ability_name) do
                if Get_Target_Distance(Object, target.object) <= max_distance then
                    DebugMessage("%s -- Target within Distance", tostring(Script))
                    if Return_Chance(InitalBoardingChance) then
                        DebugMessage("%s -- Initial Boarding Allowed Starting", tostring(Script))
                        Game_Message("HALO_BOARDING_ACTIVE")
                        target.beingBoarded = true
                        uses = 0
                        target.object.Prevent_All_Fire(true)
                        Object.Prevent_All_Fire(true)
                        target.object.Suspend_Locomotor(true)
                        Object.Suspend_Locomotor(true)
                        while boarding do 
                            Deal_Unit_Damage(target.object, BoardingDamage, nil, "Unit_Hardpoint_Turbo_Laser_Death")
                            if Return_Chance(FailChance)  then -- If the boarding units die by chance
                                target = nil -- Set our target as Null or Nil so the script stops damaging the ship
                                boarding = false -- Boarding No Longer active, exit loop
                                Object.Cancel_Ability(ability_name) -- Make sure the "Tractor Beam" ability stops
                                Object.Play_SFX_Event("SFX_UM02_MagneticSealedDoor")
                                Game_Message("HALO_BOARDING_FAIL")
                                uses = uses + 1
                            end
                            if Return_Chance(TakeOverChance) and boardingActive == true then -- If the boarding Take over chance succeeds and boarding is active, take over ship
                                target.object.Change_Owner(Object.Get_Owner().Get_Faction_Name()) -- Switch target ship owner from enemy to covies
                                Object.Cancel_Ability(ability_name) -- Stop the "Tractor Beam" Ability
                                boarding = false
                                target = nil
                                Object.Play_SFX_Event("Unit_Select_Vader_Executor")
                                Game_Message("HALO_BOARDING_TAKEOVER")
                                uses = uses + 1
                            end
                            if TestValid(target.object) then 
                                if target.object.Get_Hull() <= 0.2 then -- If the Ship health is below a value then just straight up blow up the ship
                                    Deal_Unit_Damage(target.object, 10000000, nil)
                                    boarding = false -- Boarding no Longer active exit loop
                                    Object.Cancel_Ability(ability_name)
                                    target = nil
                                    Game_Message("HALO_BOARDING_THRESH")
                                    uses = uses + 1
                                    return
                                end
                            end
                            if uses >= 3 then
                                Deal_Unit_Damage(Object, 1, HP_BOARD_POINT)
                                target = nil
                                ScriptExit()
                            end
                            Sleep(3)
                        end
                    else
                        boarding = false
                        target = nil
                        Object.Cancel_Ability(ability_name) 
                        Object.Play_SFX_Event("Unit_Star_Destroyer_Death_SFX")
                        Game_Message("HALO_BOARDING_FAIL")
                        DebugMessage("%s -- Canceling Ability Chance Failed", tostring(Script)) 
                        return
                    end
                else
                    Sleep(15) -- give some time to catch up
                    if Get_Target_Distance(Object, target) > max_distance then
                        boarding = false
                        target = nil
                        Object.Cancel_Ability(ability_name)
                    end
                end
                Sleep(1)
            end
        end
    end
end