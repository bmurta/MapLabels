-- Create our main frame
local frame = CreateFrame("Frame")

-- Table to store our label frames so we can clean them up
local activeLabels = {}

-- Map button reference
local mapButton = nil

-- Configuration
MapLabelsConfig = MapLabelsConfig or {
    displayMode = "labels" -- Options: "labels", "icons", "both"
}

-- Map-specific scale settings
local mapScales = {
    [2339] = 4.0,  -- Dornogal
    [627] = 1.2, -- Dalaran / Legion Remix
    -- Add more maps here as needed
}

-- Function to get scale for current map
local function GetMapScale(mapID)
    return mapScales[mapID] or 1.0
end

-- Function to calculate distance between two points
local function CalculateDistance(x1, y1, x2, y2)
    local dx = (x1 - x2) * 1000
    local dy = (y1 - y2) * 1000
    return math.sqrt(dx * dx + dy * dy)
end

-- Function to cluster nearby NPCs
local function ClusterNPCs(npcList, clusterRadius)
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
                        local distance = CalculateDistance(npc.x, npc.y, otherNpc.x, otherNpc.y)
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

-- Function to get cluster center position
local function GetClusterCenter(cluster)
    local sumX, sumY = 0, 0
    for _, npc in ipairs(cluster) do
        sumX = sumX + npc.x
        sumY = sumY + npc.y
    end
    return sumX / #cluster, sumY / #cluster
end

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
local function GetClusterLabel(cluster)
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

-- Function to clear old labels
local function ClearLabels()
    for i, label in ipairs(activeLabels) do
        label:Hide()
    end
    activeLabels = {}
end

-- Function to create a label (text only)
local function CreateTextLabel(parent, x, y, text, scale, textDirection, color, labelDistance)
    scale = scale or 1.0
    textDirection = textDirection or "down" -- down, left, right, top, none
    color = color or "FFFFFF" -- default white
    labelDistance = labelDistance or 1.0 -- multiplier for distance (1.0 = default, 2.0 = double distance, 0.5 = half)
    
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(200 * scale, 26 * scale)
    
    -- Set higher frame strata and level to appear above Blizzard elements
    container:SetFrameStrata("HIGH")
    container:SetFrameLevel(9999)

    local fontString = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    fontString:SetPoint("CENTER")
    fontString:SetText(text)
    
    -- Parse hex color
    local r = tonumber(color:sub(1, 2), 16) / 255
    local g = tonumber(color:sub(3, 4), 16) / 255
    local b = tonumber(color:sub(5, 6), 16) / 255
    fontString:SetTextColor(r, g, b, 1)
    
    local font, _, flags = fontString:GetFont()
    fontString:SetFont(font, 16 * scale, "OUTLINE")

    local mapWidth = parent:GetWidth()
    local mapHeight = parent:GetHeight()
    
    -- Base offset that can be multiplied by labelDistance
    local baseOffset = 0.03
    
    -- Adjust position based on text direction
    local offsetX, offsetY = 0, 0
    if textDirection == "left" then
        offsetX = -(baseOffset * labelDistance) * mapWidth -- Move left
    elseif textDirection == "right" then
        offsetX = (baseOffset * labelDistance) * mapWidth -- Move right
    elseif textDirection == "top" then
        offsetY = (baseOffset * labelDistance) * mapHeight -- Move up
    elseif textDirection == "down" then
        offsetY = -(baseOffset * labelDistance) * mapHeight -- Move down
    elseif textDirection == "none" then
        offsetX = 0
        offsetY = 0 -- No offset - label at exact position
    end
    
    container:SetPoint("CENTER", parent, "TOPLEFT", x * mapWidth + offsetX, -y * mapHeight + offsetY)

    container:Show()
    return container
end

-- Function to create a label with icon
local function CreateLabelWithIcon(parent, x, y, text, iconPath, scale)
    scale = scale or 1.0
    local container = CreateFrame("Frame", nil, parent)

    local iconSize = 20 * scale
    local labelHeight = 26 * scale
    local spacing = 2 * scale
    local totalHeight = iconSize + spacing + labelHeight
    container:SetSize(200 * scale, totalHeight)

    -- Create the icon
    local icon = container:CreateTexture(nil, "ARTWORK")
    icon:SetSize(iconSize, iconSize)
    icon:SetTexture(iconPath)
    icon:SetPoint("TOP", container, "TOP", 0, 0)

    -- Create the text
    local fontString = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    fontString:SetText(text)
    fontString:SetTextColor(1, 1, 1, 1)
    local font, _, flags = fontString:GetFont()
    fontString:SetFont(font, 16 * scale, "OUTLINE")
    fontString:SetPoint("TOP", icon, "BOTTOM", 0, -spacing)

    local mapWidth = parent:GetWidth()
    local mapHeight = parent:GetHeight()
    container:SetPoint("CENTER", parent, "TOPLEFT", x * mapWidth, -y * mapHeight)

    container:Show()
    return container
end

-- Function to create icon only
local function CreateIconOnly(parent, x, y, iconPath, scale)
    scale = scale or 1.0
    local container = CreateFrame("Frame", nil, parent)
    local iconSize = 24 * scale
    container:SetSize(iconSize, iconSize)

    -- Set higher frame strata and level to appear above Blizzard elements
    container:SetFrameStrata("HIGH")
    container:SetFrameLevel(9999)
    
    -- Create the icon
    local icon = container:CreateTexture(nil, "ARTWORK")
    icon:SetSize(iconSize, iconSize)
    icon:SetTexture(iconPath)
    icon:SetPoint("CENTER")

    local mapWidth = parent:GetWidth()
    local mapHeight = parent:GetHeight()
    container:SetPoint("CENTER", parent, "TOPLEFT", x * mapWidth, -y * mapHeight)

    container:Show()
    return container
end

-- Function to create/update the map button
-- Function to create/update the map button
local function CreateOrUpdateMapButton()
    if not mapButton then
        mapButton = CreateFrame("Button", "MapLabelsToggleButton", WorldMapFrame.BorderFrame, "UIPanelButtonTemplate")
        mapButton:SetSize(120, 22)
        
        -- Try to anchor to Map Filter button, with fallback
        if WorldMapFrame.overlayFrames and WorldMapFrame.overlayFrames[2] then
            -- Anchor to the left of the Map Filter button
            mapButton:SetPoint("RIGHT", WorldMapFrame.overlayFrames[2], "LEFT", -5, 0)
        else
            -- Fallback: top right of map
            mapButton:SetPoint("TOPRIGHT", WorldMapFrame.BorderFrame, "TOPRIGHT", -10, -10)
        end
        
        mapButton:SetScript("OnClick", function()
            if MapLabelsConfig.displayMode == "labels" then
                MapLabelsConfig.displayMode = "icons"
            elseif MapLabelsConfig.displayMode == "icons" then
                MapLabelsConfig.displayMode = "both"
            else
                MapLabelsConfig.displayMode = "labels"
            end
            
            CreateOrUpdateMapButton()
            MapLabels_UpdateMapLabels()
            print("|cff00ff00Map Labels:|r Switched to " .. MapLabelsConfig.displayMode .. " mode!")
        end)
        
        mapButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("Map Labels Display Mode")
            GameTooltip:AddLine("Click to cycle through display modes", 1, 1, 1)
            GameTooltip:Show()
        end)
        
        mapButton:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    
    if MapLabelsConfig.displayMode == "labels" then
        mapButton:SetText("Labels Only")
    elseif MapLabelsConfig.displayMode == "icons" then
        mapButton:SetText("Icons Only")
    else
        mapButton:SetText("Icons + Labels")
    end
    
    mapButton:Show()
end

-- Function to add labels to the map
function MapLabels_UpdateMapLabels()
    ClearLabels()

    if not WorldMapFrame:IsShown() then
        return
    end

    local mapID = WorldMapFrame:GetMapID()

    -- Only show button if we have data for this map
    if mapID and MapLabelsNPCData[mapID] then
        CreateOrUpdateMapButton()
    else
        -- Hide button if no data for this map
        if mapButton then
            mapButton:Hide()
        end
        return
    end

    local canvas = WorldMapFrame:GetCanvas()
    local scale = GetMapScale(mapID)

    if MapLabelsConfig.displayMode == "icons" then
        -- Icons only - NO CLUSTERING, use original positions
        for i, npc in ipairs(MapLabelsNPCData[mapID]) do
            local label = CreateIconOnly(canvas, npc.x, npc.y, npc.icon, scale)
            table.insert(activeLabels, label)
        end
        
    elseif MapLabelsConfig.displayMode == "labels" then
        -- Labels only - USE CLUSTERING
        local clusters = ClusterNPCs(MapLabelsNPCData[mapID])
        
        for _, cluster in ipairs(clusters) do
            local centerX, centerY = GetClusterCenter(cluster)
            local labelText = GetClusterLabel(cluster)
            -- Use color from first item in cluster, or default white
            local color = cluster[1].color or "FFFFFF"
            -- No offset in labels-only mode - pass "none" as textDirection
            local label = CreateTextLabel(canvas, centerX, centerY, labelText, scale, "none", color)
            table.insert(activeLabels, label)
        end
        
    else -- both
        -- Icons + Labels - Show all icons, then clustered labels
        -- First, show all icons at their EXACT positions
        for i, npc in ipairs(MapLabelsNPCData[mapID]) do
            local icon = CreateIconOnly(canvas, npc.x, npc.y, npc.icon, scale)
            table.insert(activeLabels, icon)
        end
        
        -- Then, show CLUSTERED labels (same logic as labels-only mode)
        local clusters = ClusterNPCs(MapLabelsNPCData[mapID])
        
        for _, cluster in ipairs(clusters) do
            local centerX, centerY = GetClusterCenter(cluster)
            local labelText = GetClusterLabel(cluster)
            -- Use color and textDirection from first item in cluster
            local color = cluster[1].color or "FFFFFF"
            local textDirection = cluster[1].textDirection or "down"
            local labelDistance = cluster[1].labelDistance or 1.0
            
            local label = CreateTextLabel(canvas, centerX, centerY, labelText, scale, textDirection, color, labelDistance)
            table.insert(activeLabels, label)
        end
    end
end

-- Hook into map events
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event)
    print("MapLabels addon loaded! Type /ml for commands")

    WorldMapFrame:HookScript("OnShow", MapLabels_UpdateMapLabels)
    WorldMapFrame:HookScript("OnHide", ClearLabels)

    hooksecurefunc(WorldMapFrame, "OnMapChanged", MapLabels_UpdateMapLabels)
end)