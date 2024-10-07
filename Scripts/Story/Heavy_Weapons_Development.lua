require("PGStoryMode")
require("PGStateMachine")
require("HALOFunctions")
function Definitions()
    DebugMessage("%s -- In Definitions", tostring(Script))
    Define_State("State_Init", State_Init)


    planet_owners = {}

    hwd_units = {
        "COVN_ORS",
        "COVN_CPV",
        "COVN_CAS"
    }

    num_of_conquered_unsc_planets = 0

    needed_unsc_planets = 5

    num_of_built_cas = 0

    amount_needed = 3

    cso_cas_req_met = false
end

function State_Init(message) 

    covenant = Find_Player("EMPIRE")

    planets = FindPlanet.Get_All_Planets()

    if  message == OnEnter then 
        GlobalValue.Set("CSO_UNLOCKED", 0)

        for _, planet in pairs(planets) do
            DebugMessage("Planet: %s, Owner: %s", tostring(planet.Get_Type().Get_Name()), tostring(planet.Get_Owner()))
            planet_owners[planet.Get_Type().Get_Name()] = planet.Get_Owner()

            DebugMessage("%s", tostring(planet_owners[planet.Get_Type().Get_Name()]))
        end
    end
    if message == OnUpdate then

        if covenant.Get_Tech_Level() < 4 then
            return
        end

        for _, planet in pairs(planets) do
            planet_name = planet.Get_Type().Get_Name()
            DebugMessage("Planet: %s, Planet Array Owner: %s, Planet Current Owner: %s", tostring(planet_name), tostring(planet_owners[planet_name].Get_Faction_Name()), tostring(planet.Get_Owner().Get_Faction_Name()))
            if planet_owners[planet_name] ~= nil then
                planet_owner = planet_owners[planet_name]
                if planet.Get_Owner() ~= planet_owner then
                    DebugMessage("Current Planet owner ~= last owner")
                    if string.lower(planet_owner.Get_Faction_Name()) == "rebel" then
                        DebugMessage("Planet Owner has changed, and previous was UNSC")
                        num_of_conquered_unsc_planets = num_of_conquered_unsc_planets + 1
                    end
                    DebugMessage("New Owner: %s", planet.Get_Owner().Get_Faction_Name())
                    planet_owners[planet_name] = planet.Get_Owner()
                end
            end
        end

        hwd = Find_First_Object("Covenant_Heavy_Weapons")

        DebugMessage("Is HWD Researched: %s", tostring(hwd))

        if hwd ~= nil then
            Lock_HWD_UNITS(covenant,false)
        else 
            Lock_HWD_UNITS(covenant,true)
        end

        num_of_built_cas = tableLength(Find_All_Objects_Of_Type("COVN_CAS"))

        if num_of_built_cas >= amount_needed and (not cso_cas_req_met) then
            cso_cas_req_met = true
        end

        if num_of_conquered_unsc_planets < needed_unsc_planets then
            cso_cas_req_met = false
        end

        if covenant.Get_Tech_Level() < 5 then
            cso_cas_req_met = false
        end

        if cso_cas_req_met then
            Lock_Unit("COVN_CSO", covenant, false)

            GlobalValue.Set("CSO_UNLOCKED", 1)
        else
            Lock_Unit("COVN_CSO", covenant)
        end

        if covenant.Get_Tech_Level() == 4 then
            plot = Get_Story_Plot("HaloFiles\\Campaigns\\StoryMissions\\Covenant_Tech.xml")

            event = plot.Get_Event("HWD_DISPLAY")

            event.Clear_Dialog_Text()

            status = "Not Researched"

            if hwd ~= nil then
                status = "Researched"
            end

            event.Add_Dialog_Text("Heavy Weapons Development Status: " .. status)

            event.Add_Dialog_Text("CAS-class Carriers Built: " .. tostring(num_of_built_cas) .. "/" .. tostring(amount_needed))

            event.Add_Dialog_Text("UNSC Planets Conquered: " .. tostring(num_of_conquered_unsc_planets) .. "/" .. tostring(needed_unsc_planets))

            event.Add_Dialog_Text("CSO-class Supercarrier Unlocked: " .. Capital_First_Letter(tostring(cso_cas_req_met)))
        end

    end
end

function Lock_HWD_UNITS(player,lock_or_unlock)
    if lock_or_unlock ~= true then
        lock_or_unlock = false
    end

    for _, unit in pairs(hwd_units) do
        if lock_or_unlock then
            Lock_Unit(unit,player)
        else
            Lock_Unit(unit,player,false)
        end
    end
end
