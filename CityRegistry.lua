-- City Registry - Single source of truth for all city configurations
-- Add new cities here in the order you want them to appear (latest expansion first)

CityGuideRegistry = {
    -- Each entry: {mapID, displayName, scale}
    -- Scale: affects label/icon sizing for that map (default 1.0 if not specified)
    
    {2393, "Silvermoon", 3.0},
    {2339, "Dornogal", 3.0},
    {2472, "Tazavesh (K'aresh)", 1.0},
    {2112, "Valdrakken", 3.0},
    {627, "Dalaran (Legion/Remix)", 1.2},
    {85, "Orgrimmar", 1.0},
    {84, "Stormwind", 1.0},
    
    -- To add a new city, just add a line here:
    -- {mapID, "Display Name", scale},
}

-- Helper functions to extract data from registry
function CityGuide_GetCityOrder()
    local order = {}
    for _, city in ipairs(CityGuideRegistry) do
        table.insert(order, city[1]) -- mapID
    end
    return order
end

function CityGuide_GetCityNames()
    local names = {}
    for _, city in ipairs(CityGuideRegistry) do
        names[city[1]] = city[2] -- [mapID] = displayName
    end
    return names
end

function CityGuide_GetCityScales()
    local scales = {}
    for _, city in ipairs(CityGuideRegistry) do
        scales[city[1]] = city[3] or 1.0 -- [mapID] = scale (default 1.0)
    end
    return scales
end