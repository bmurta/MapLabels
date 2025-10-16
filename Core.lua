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

-- Function to clear old labels
local function ClearLabels()
    for i, label in ipairs(activeLabels) do
        label:Hide()
    end
    activeLabels = {}
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
        CityGuide_CreateOrUpdateMapButton() -- Only call this one now
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
    
    -- Apply profession filter
    local npcList = CityGuide_FilterNPCsByProfession(CityGuideNPCData[mapID])

    if CityGuideConfig.displayMode == "icons" then
        -- Icons only - NO CLUSTERING, use original positions
        for i, npc in ipairs(npcList) do
            local label = CityGuide_CreateIconOnly(canvas, npc.x, npc.y, npc.icon, scale, finalIconSize)
            table.insert(activeLabels, label)
        end
        
    elseif CityGuideConfig.displayMode == "labels" then
        -- Labels only - USE CLUSTERING
        local clusters = CityGuide_ClusterNPCs(npcList)
        
        for _, cluster in ipairs(clusters) do
            local centerX, centerY = CityGuide_GetClusterCenter(cluster)
            local labelText = CityGuide_GetClusterLabel(cluster)
            local color = cluster[1].color or "FFFFFF"
            local label = CityGuide_CreateTextLabel(canvas, centerX, centerY, labelText, scale, "none", color, 1.0, finalLabelSize)
            table.insert(activeLabels, label)
        end
        
    else -- both
        -- Icons + Labels - Show all icons, then clustered labels
        for i, npc in ipairs(npcList) do
            local icon = CityGuide_CreateIconOnly(canvas, npc.x, npc.y, npc.icon, scale, finalIconSize)
            table.insert(activeLabels, icon)
        end
        
        local clusters = CityGuide_ClusterNPCs(npcList)
        
        for _, cluster in ipairs(clusters) do
            local centerX, centerY = CityGuide_GetClusterCenter(cluster)
            local labelText = CityGuide_GetClusterLabel(cluster)
            local color = cluster[1].color or "FFFFFF"
            local textDirection = cluster[1].textDirection or "down"
            local labelDistance = cluster[1].labelDistance or 1.0
            
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
