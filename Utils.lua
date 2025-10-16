-- Utility functions for City Guide

-- Map-specific scale settings
local mapScales = {
    [2339] = 3.0,  -- Dornogal
    [627] = 1.2, -- Dalaran / Legion Remix
    [2112] = 3.0, -- Valdrakken
    -- Add more maps here as needed
}

-- Function to get scale for current map
function CityGuide_GetMapScale(mapID)
    return mapScales[mapID] or 1.0
end

-- Function to calculate distance between two points
function CityGuide_CalculateDistance(x1, y1, x2, y2)
    local dx = (x1 - x2) * 1000
    local dy = (y1 - y2) * 1000
    return math.sqrt(dx * dx + dy * dy)
end

-- Function to get cluster center position
function CityGuide_GetClusterCenter(cluster)
    local sumX, sumY = 0, 0
    for _, npc in ipairs(cluster) do
        sumX = sumX + npc.x
        sumY = sumY + npc.y
    end
    return sumX / #cluster, sumY / #cluster
end