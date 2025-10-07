-- Create our main frame
local frame = CreateFrame("Frame")

-- Table to store our label frames so we can clean them up
local activeLabels = {}

-- Map button reference
local mapButton = nil

-- Configuration
-- SavedVariablesPerCharacter would save per character, but we want account-wide
MapLabelsConfig = MapLabelsConfig or {
    displayMode = "labels" -- Options: "labels", "icons", "both"
}

-- Map-specific scale settings
local mapScales = {
    [2339] = 4.0,  -- Dornogal (50% bigger)
    -- Add more maps here as needed
    -- [mapID] = scale_multiplier
}

-- Function to get scale for current map
local function GetMapScale(mapID)
    return mapScales[mapID] or 1.0  -- Default to 1.0 (normal size)
end

-- Function to clear old labels
local function ClearLabels()
    for i, label in ipairs(activeLabels) do
        label:Hide()
    end
    activeLabels = {}
end

-- Function to create a label (text only)
local function CreateTextLabel(parent, x, y, text, scale)
    scale = scale or 1.0
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(130 * scale, 26 * scale)

    local fontString = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    fontString:SetPoint("CENTER")
    fontString:SetText(text)
    fontString:SetTextColor(1, 1, 1, 1)
    local font, _, flags = fontString:GetFont()
    fontString:SetFont(font, 16 * scale, "OUTLINE")

    local mapWidth = parent:GetWidth()
    local mapHeight = parent:GetHeight()
    container:SetPoint("CENTER", parent, "TOPLEFT", x * mapWidth, -y * mapHeight)

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
    container:SetSize(130 * scale, totalHeight)

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
    local iconSize = 24 * scale -- Slightly bigger when shown alone
    container:SetSize(iconSize, iconSize)

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
local function CreateOrUpdateMapButton()
    -- Create button if it doesn't exist
    if not mapButton then
        mapButton = CreateFrame("Button", "MapLabelsToggleButton", WorldMapFrame.BorderFrame, "UIPanelButtonTemplate")
        mapButton:SetSize(120, 22)
        
        -- Position to the left of the ? button (SidePanelToggle.CloseButton)
        mapButton:SetPoint("RIGHT", WorldMapFrame.SidePanelToggle.CloseButton, "LEFT", -5, 0)
        
        -- Button click handler - cycles through modes
        mapButton:SetScript("OnClick", function()
            -- Cycle through modes
            if MapLabelsConfig.displayMode == "labels" then
                MapLabelsConfig.displayMode = "icons"
            elseif MapLabelsConfig.displayMode == "icons" then
                MapLabelsConfig.displayMode = "both"
            else
                MapLabelsConfig.displayMode = "labels"
            end
            
            CreateOrUpdateMapButton() -- Update button text
            MapLabels_UpdateMapLabels()
            print("|cff00ff00Map Labels:|r Switched to " .. MapLabelsConfig.displayMode .. " mode!")
        end)
        
        -- Tooltip
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
    
    -- Update button text based on current mode
    if MapLabelsConfig.displayMode == "labels" then
        mapButton:SetText("Labels Only")
    elseif MapLabelsConfig.displayMode == "icons" then
        mapButton:SetText("Icons Only")
    else -- both
        mapButton:SetText("Icons + Labels")
    end
    
    mapButton:Show()
end

-- Function to add labels to the map (global so other files can access it)
function MapLabels_UpdateMapLabels()
    ClearLabels()

    if not WorldMapFrame:IsShown() then
        return
    end

    local mapID = WorldMapFrame:GetMapID()

    -- Create/update the button whenever map updates
    CreateOrUpdateMapButton()

    if not mapID or not MapLabelsNPCData[mapID] then
        return
    end

    local canvas = WorldMapFrame:GetCanvas()
    local scale = GetMapScale(mapID)  -- Get scale for this map

    -- Create labels for each NPC
    for i, npc in ipairs(MapLabelsNPCData[mapID]) do
        local label
        if MapLabelsConfig.displayMode == "both" then
            label = CreateLabelWithIcon(canvas, npc.x, npc.y, npc.name, npc.icon, scale)
        elseif MapLabelsConfig.displayMode == "icons" then
            label = CreateIconOnly(canvas, npc.x, npc.y, npc.icon, scale)
        else -- labels
            label = CreateTextLabel(canvas, npc.x, npc.y, npc.name, scale)
        end
        table.insert(activeLabels, label)
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