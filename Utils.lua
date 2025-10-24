
-- Utility functions for City Guide

-- Function to get scale for current map
function CityGuide_GetMapScale(mapID)
    -- Get scales from registry
    local scales = CityGuide_GetCityScales()
    return scales[mapID] or 1.0
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