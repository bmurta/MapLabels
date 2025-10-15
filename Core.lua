-- Create our main frame
local frame = CreateFrame("Frame")

-- Table to store our label frames so we can clean them up
local activeLabels = {}

-- Configuration
CityGuideConfig = CityGuideConfig or {
    displayMode = "labels", -- Options: "labels", "icons", "both"
    filterByProfession = false, -- Filter to show only player's professions
    labelSize = 1.0, -- Label size multiplier (1.0 = default)
    iconSize = 1.0 -- Icon size multiplier (1.0 = default)
}

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

    -- Only show button if we have data for this map
    if mapID and CityGuideNPCData[mapID] then
        CityGuide_CreateOrUpdateMapButton() -- Only call this one now
    else
        CityGuide_HideMapButton()
        return
    end

    local canvas = WorldMapFrame:GetCanvas()
    local scale = CityGuide_GetMapScale(mapID)
    
    -- Apply profession filter
    local npcList = CityGuide_FilterNPCsByProfession(CityGuideNPCData[mapID])

    if CityGuideConfig.displayMode == "icons" then
        -- Icons only - NO CLUSTERING, use original positions
        for i, npc in ipairs(npcList) do
            local label = CityGuide_CreateIconOnly(canvas, npc.x, npc.y, npc.icon, scale, CityGuideConfig.iconSize)
            table.insert(activeLabels, label)
        end
        
    elseif CityGuideConfig.displayMode == "labels" then
        -- Labels only - USE CLUSTERING
        local clusters = CityGuide_ClusterNPCs(npcList)
        
        for _, cluster in ipairs(clusters) do
            local centerX, centerY = CityGuide_GetClusterCenter(cluster)
            local labelText = CityGuide_GetClusterLabel(cluster)
            local color = cluster[1].color or "FFFFFF"
            local label = CityGuide_CreateTextLabel(canvas, centerX, centerY, labelText, scale, "none", color, 1.0, CityGuideConfig.labelSize)
            table.insert(activeLabels, label)
        end
        
    else -- both
        -- Icons + Labels - Show all icons, then clustered labels
        for i, npc in ipairs(npcList) do
            local icon = CityGuide_CreateIconOnly(canvas, npc.x, npc.y, npc.icon, scale, CityGuideConfig.iconSize)
            table.insert(activeLabels, icon)
        end
        
        local clusters = CityGuide_ClusterNPCs(npcList)
        
        for _, cluster in ipairs(clusters) do
            local centerX, centerY = CityGuide_GetClusterCenter(cluster)
            local labelText = CityGuide_GetClusterLabel(cluster)
            local color = cluster[1].color or "FFFFFF"
            local textDirection = cluster[1].textDirection or "down"
            local labelDistance = cluster[1].labelDistance or 1.0
            
            local label = CityGuide_CreateTextLabel(canvas, centerX, centerY, labelText, scale, textDirection, color, labelDistance, CityGuideConfig.labelSize)
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