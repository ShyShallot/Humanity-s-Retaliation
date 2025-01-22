require("pgcommands")
require("HALOFunctions")


function Base_Definitions()
	DebugMessage("%s -- In Base_Definitions", tostring(Script))

	-- how often does this script get serviced?
	ServiceRate = 20
	UnitServiceRate = 20
	
	Common_Base_Definitions()
	
	-- Percentage of units to move on each service.
	SpaceMovePercent = 0.0
	GroundMovePercent = 0.0

	if Definitions then
		Definitions()
	end
end

function main()

	DebugMessage("%s -- In main for %s", tostring(Script), tostring(FreeStore))
	
	ScriptExit()
end


function Calculate_Planet_CP_Average()
	local player = Find_Human_Player()

	local planets = FindPlanet.Get_All_Planets()

	local human_planets = {}

	for _, planet in pairs(planet) do
		if planet.Get_Owner() == player then
			table.insert(planet, human_planets)
		end
	end

	local units = Find_All_Objects_Of_Type(player)

	local avgUnitPower = 0

	for _, unit in pairs(units) do
		avgUnitPower = avgUnitPower + unit.Get_Type().Get_Combat_Rating()
	end

	avgUnitPower = avgUnitPower / tableLength(units)
end