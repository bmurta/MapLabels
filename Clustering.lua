-- Clustering logic for City Guide

-- Profession names for grouping
local professions = {
    ["Alchemy"] = true,
    ["Blacksmithing"] = true,
    ["Enchanting"] = true,
    ["Engineering"] = true,
    ["Inscription"] = true,
    ["Jewelcrafting"] = true,
    ["Leatherworking"] = true,
    ["Tailoring"] = true,
    ["Alch"] = true,
    ["BS"] = true,
    ["Ench"] = true,
    ["Engi"] = true,
    ["Insc"] = true,
    ["Jewel"] = true,
    ["LW"] = true,
    ["Tailor"] = true,
}

-- Function to check if all items in cluster are professions
local function AreAllProfessions(cluster)
    for _, npc in ipairs(cluster) do
        if not professions[npc.name] then
            return false
        end
    end
    return true
end

-- Function to generate cluster label text
function CityGuide_GetClusterLabel(cluster)
    if #cluster == 1 then
        return cluster[1].name
    end
    
    if #cluster == 2 then
        return cluster[1].name .. " & " .. cluster[2].name
    end
    
    -- Check if all are professions
    if AreAllProfessions(cluster) then
        -- Sort professions by X coordinate (left to right)
        local sortedProfs = {}
        for _, npc in ipairs(cluster) do
            table.insert(sortedProfs, npc)
        end
        table.sort(sortedProfs, function(a, b) return a.x < b.x end)
        
        -- Create comma-separated list of profession names
        local profNames = {}
        for _, prof in ipairs(sortedProfs) do
            table.insert(profNames, prof.name)
        end
        return table.concat(profNames, ", ")
    end
    
    -- Mixed items - list all names
    local names = {}
    for i, npc in ipairs(cluster) do
        table.insert(names, npc.name)
    end
    return table.concat(names, ", ")
end

-- Function to cluster nearby NPCs
function CityGuide_ClusterNPCs(npcList, clusterRadius)
    clusterRadius = clusterRadius or 60 -- Radius for clustering
    local clusters = {}
    local assigned = {}
    
    for i, npc in ipairs(npcList) do
        if not assigned[i] then
            -- If this NPC has noCluster flag, create a cluster with just itself
            if npc.noCluster then
                table.insert(clusters, {npc})
                assigned[i] = true
            else
                -- Start a new cluster
                local cluster = {npc}
                assigned[i] = true
                
                -- Find all nearby NPCs (that also don't have noCluster)
                for j, otherNpc in ipairs(npcList) do
                    if not assigned[j] and not otherNpc.noCluster then
                        local distance = CityGuide_CalculateDistance(npc.x, npc.y, otherNpc.x, otherNpc.y)
                        if distance < clusterRadius then
                            table.insert(cluster, otherNpc)
                            assigned[j] = true
                        end
                    end
                end
                
                table.insert(clusters, cluster)
            end
        end
    end
    
    return clusters
end