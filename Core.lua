-- Create our main frame
local frame = CreateFrame("Frame")

-- Table to store our label frames so we can clean them up
local activeLabels = {}

-- Configuration
CityGuideConfig = CityGuideConfig or {}
CityGuideConfig.displayMode = CityGuideConfig.displayMode or "labels"
CityGuideConfig.filterByProfession = CityGuideConfig.filterByProfession or false
CityGuideConfig.labelSize = CityGuideConfig.labelSize or 1.0
CityGuideConfig.iconSize = CityGuideConfig.iconSize or 1.0
CityGuideConfig.enabledCities = CityGuideConfig.enabledCities or {}
CityGuideConfig.cityIconSizes = CityGuideConfig.cityIconSizes or {}
CityGuideConfig.cityLabelSizes = CityGuideConfig.cityLabelSizes or {}
CityGuideConfig.condenseProfessions = CityGuideConfig.condenseProfessions or {}
CityGuideConfig.showFactionPOIs = CityGuideConfig.showFactionPOIs or false
CityGuideConfig.factionPOIsOnly = CityGuideConfig.factionPOIsOnly or {}

-- Function to clear old labels
local function ClearLabels()
    for i, label in ipairs(activeLabels) do
        label:Hide()
    end
    activeLabels = {}
end

-- Function to filter NPCs by faction
local function FilterNPCsByFaction(npcList, mapID)
    local filtered = {}
    for _, npc in ipairs(npcList) do
        if CityGuide_ShouldShowNPCByFaction(npc, mapID, npcList) then
            table.insert(filtered, npc)
        end
    end
    return filtered
end

-- Function to add labels to the map
function CityGuide_UpdateMapLabels()
    ClearLabels()

    if not WorldMapFrame:IsShown() then
        return
    end

    local mapID = WorldMapFrame:GetMapID()
    
    -- Safety check: Make sure NPCData is loaded
    if not CityGuideNPCData then
        return
    end

    -- Check if this city is enabled (default to enabled if not in config)
    if CityGuideConfig.enabledCities[mapID] == false then
        CityGuide_HideMapButton()
        return
    end

    -- Only show button if we have data for this map
    if mapID and CityGuideNPCData[mapID] then
        CityGuide_CreateOrUpdateMapButton()
    else
        CityGuide_HideMapButton()
        return
    end

    local canvas = WorldMapFrame:GetCanvas()
    local scale = CityGuide_GetMapScale(mapID)
    
    -- Ensure cityIconSizes and cityLabelSizes tables exist
    CityGuideConfig.cityIconSizes = CityGuideConfig.cityIconSizes or {}
    CityGuideConfig.cityLabelSizes = CityGuideConfig.cityLabelSizes or {}
    
    -- Get per-city size multipliers (default to 1.0 if not set)
    local cityIconMultiplier = CityGuideConfig.cityIconSizes[mapID] or 1.0
    local cityLabelMultiplier = CityGuideConfig.cityLabelSizes[mapID] or 1.0
    local finalIconSize = CityGuideConfig.iconSize * cityIconMultiplier
    local finalLabelSize = CityGuideConfig.labelSize * cityLabelMultiplier
    
    -- Get the full NPC list
    local fullNPCList = CityGuideNPCData[mapID]
    
    -- Apply faction filter first
    local factionFilteredList = FilterNPCsByFaction(fullNPCList, mapID)
    
    -- Then apply profession filter
    local filteredNPCList = CityGuide_FilterNPCsByProfession(factionFilteredList)

    if CityGuideConfig.displayMode == "icons" then
        -- Icons only - NO CLUSTERING, use original positions, regular square icons
        for i, npc in ipairs(filteredNPCList) do
            local label = CityGuide_CreateIconOnly(canvas, npc.x, npc.y, npc.icon, nil, scale, finalIconSize)
            table.insert(activeLabels, label)
        end
        
    elseif CityGuideConfig.displayMode == "smallicons" then
        -- Small Icons only - NO CLUSTERING, use original positions, minimap style
        for i, npc in ipairs(filteredNPCList) do
            local label = CityGuide_CreateIconOnly(canvas, npc.x, npc.y, npc.icon, npc.minimapIcon, scale, finalIconSize)
            table.insert(activeLabels, label)
        end
        
    elseif CityGuideConfig.displayMode == "labels" then
        -- Labels only - USE CLUSTERING
        local clusters = CityGuide_ClusterNPCs(filteredNPCList)
        
        -- Apply profession condensation if enabled for this map
        -- BUT NOT if profession filter is active (show individual professions for user's profs)
        CityGuideConfig.condenseProfessions = CityGuideConfig.condenseProfessions or {}
        if CityGuideConfig.condenseProfessions[mapID] and not CityGuideConfig.filterByProfession then
            -- Get profession hub if defined
            local professionHub = CityGuideProfessionHubs and CityGuideProfessionHubs[mapID]
            clusters = CityGuide_CondenseProfessionClusters(clusters, professionHub)
        end
        
        for _, cluster in ipairs(clusters) do
            local centerX, centerY
            local color, textDirection, labelDistance
            
            -- Check if this is a profession hub with custom position
            if cluster.isProfessionHub and cluster.professionHubX then
                centerX = cluster.professionHubX
                centerY = cluster.professionHubY
                color = cluster.professionHubColor or "00FF00"
                textDirection = cluster.professionHubTextDirection or "none"
                labelDistance = cluster.professionHubLabelDistance or 1.0
            else
                centerX, centerY = CityGuide_GetClusterCenter(cluster)
                color = cluster[1].color or "FFFFFF"
                textDirection = "none"
                labelDistance = 1.0
            end
            
            local labelText = CityGuide_GetClusterLabel(cluster)
            local label = CityGuide_CreateTextLabel(canvas, centerX, centerY, labelText, scale, textDirection, color, labelDistance, finalLabelSize)
            table.insert(activeLabels, label)
        end
        
    elseif CityGuideConfig.displayMode == "both" then
        -- Icons + Labels mode (regular square icons)
        -- IMPORTANT: Show icons for FILTERED list (respects profession filter)
        for i, npc in ipairs(filteredNPCList) do
            local icon = CityGuide_CreateIconOnly(canvas, npc.x, npc.y, npc.icon, nil, scale, finalIconSize)
            table.insert(activeLabels, icon)
        end
        
        -- Cluster the FILTERED list (respects profession filter)
        local clusters = CityGuide_ClusterNPCs(filteredNPCList)
        
        -- Apply profession condensation if enabled for this map
        -- BUT NOT if profession filter is active (show individual professions for user's profs)
        CityGuideConfig.condenseProfessions = CityGuideConfig.condenseProfessions or {}
        if CityGuideConfig.condenseProfessions[mapID] and not CityGuideConfig.filterByProfession then
            -- Get profession hub if defined
            local professionHub = CityGuideProfessionHubs and CityGuideProfessionHubs[mapID]
            clusters = CityGuide_CondenseProfessionClusters(clusters, professionHub)
        end
        
        for _, cluster in ipairs(clusters) do
            local centerX, centerY
            local color, textDirection, labelDistance
            
            -- Check if this is a profession hub with custom position
            if cluster.isProfessionHub and cluster.professionHubX then
                centerX = cluster.professionHubX
                centerY = cluster.professionHubY
                color = cluster.professionHubColor or "00FF00"
                textDirection = cluster.professionHubTextDirection or "down"
                labelDistance = cluster.professionHubLabelDistance or 1.0
            else
                centerX, centerY = CityGuide_GetClusterCenter(cluster)
                color = cluster[1].color or "FFFFFF"
                textDirection = cluster[1].textDirection or "down"
                labelDistance = cluster[1].labelDistance or 1.0
            end
            
            local labelText = CityGuide_GetClusterLabel(cluster)
            local label = CityGuide_CreateTextLabel(canvas, centerX, centerY, labelText, scale, textDirection, color, labelDistance, finalLabelSize)
            table.insert(activeLabels, label)
        end
        
    elseif CityGuideConfig.displayMode == "smallboth" then
        -- Small Icons + Labels mode (minimap style with glow)
        -- IMPORTANT: Show icons for FILTERED list (respects profession filter)
        for i, npc in ipairs(filteredNPCList) do
            local icon = CityGuide_CreateIconOnly(canvas, npc.x, npc.y, npc.icon, npc.minimapIcon, scale, finalIconSize)
            table.insert(activeLabels, icon)
        end
        
        -- Cluster the FILTERED list (respects profession filter)
        local clusters = CityGuide_ClusterNPCs(filteredNPCList)
        
        -- Apply profession condensation if enabled for this map
        -- BUT NOT if profession filter is active (show individual professions for user's profs)
        CityGuideConfig.condenseProfessions = CityGuideConfig.condenseProfessions or {}
        if CityGuideConfig.condenseProfessions[mapID] and not CityGuideConfig.filterByProfession then
            -- Get profession hub if defined
            local professionHub = CityGuideProfessionHubs and CityGuideProfessionHubs[mapID]
            clusters = CityGuide_CondenseProfessionClusters(clusters, professionHub)
        end
        
        for _, cluster in ipairs(clusters) do
            local centerX, centerY
            local color, textDirection, labelDistance
            
            -- Check if this is a profession hub with custom position
            if cluster.isProfessionHub and cluster.professionHubX then
                centerX = cluster.professionHubX
                centerY = cluster.professionHubY
                color = cluster.professionHubColor or "00FF00"
                textDirection = cluster.professionHubTextDirection or "down"
                labelDistance = cluster.professionHubLabelDistance or 1.0
            else
                centerX, centerY = CityGuide_GetClusterCenter(cluster)
                color = cluster[1].color or "FFFFFF"
                textDirection = cluster[1].textDirection or "down"
                labelDistance = cluster[1].labelDistance or 1.0
            end
            
            local labelText = CityGuide_GetClusterLabel(cluster)
            local label = CityGuide_CreateTextLabel(canvas, centerX, centerY, labelText, scale, textDirection, color, labelDistance, finalLabelSize)
            table.insert(activeLabels, label)
        end
    end
end

-- Hook into map events
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    print("City Guide addon loaded! Type /cg for commands")

    WorldMapFrame:HookScript("OnShow", CityGuide_UpdateMapLabels)
    WorldMapFrame:HookScript("OnHide", ClearLabels)

    hooksecurefunc(WorldMapFrame, "OnMapChanged", CityGuide_UpdateMapLabels)
end)