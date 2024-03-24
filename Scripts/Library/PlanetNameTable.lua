
function Get_Name_Table()
    local names = {
        ["AKTIS_4"] = "Aktis IV",
        ["ERIDANUS_2"] = "Eridanus II",
        ["KHAELMOTHKA"] = "Khael'mothka",
        ["TVAO"] = "T'vao",
        ["VEN_3"] = "Ven III",
        ["VICTORS_TRUTH"] = "Victor's Truth"
    }

    return names
end

function Get_Cus_Name(planet_name)
    name_table = Get_Name_Table()

    if name_table[string.upper(planet_name)] ~= nil then
        return name_table[string.upper(planet_name)]
    end

    return planet_name
end

function Has_Custom_Name(planet_name)
    name_table = Get_Name_Table()
    if name_table[string.upper(planet_name)] ~= nil then
        return true
    end

    return false
end