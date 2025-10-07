-- Create the settings panel
local panel = CreateFrame("Frame", "MapLabelsSettingsPanel", UIParent)
panel.name = "Map Labels"

-- Title
local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("Map Labels Settings")

-- Description
local desc = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
desc:SetText("Configure how NPCs are displayed on the map")

-- Radio button helper function
local function CreateRadioButton(parent, text, xOffset, yOffset)
    local button = CreateFrame("CheckButton", nil, parent, "UIRadioButtonTemplate")
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)
    
    local label = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("LEFT", button, "RIGHT", 5, 0)
    label:SetText(text)
    
    button.label = label
    return button
end

-- Create radio buttons
local labelsButton = CreateRadioButton(panel, "Labels Only", 20, -60)
local iconsButton = CreateRadioButton(panel, "Icons Only", 20, -90)
local bothButton = CreateRadioButton(panel, "Icons with Labels", 20, -120)

-- Function to update radio buttons based on current config
local function UpdateRadioButtons()
    labelsButton:SetChecked(MapLabelsConfig.displayMode == "labels")
    iconsButton:SetChecked(MapLabelsConfig.displayMode == "icons")
    bothButton:SetChecked(MapLabelsConfig.displayMode == "both")
end

-- Set up button clicks
labelsButton:SetScript("OnClick", function()
    MapLabelsConfig.displayMode = "labels"
    UpdateRadioButtons()
    MapLabels_UpdateMapLabels()
    print("|cff00ff00Map Labels:|r Switched to labels only mode!")
end)

iconsButton:SetScript("OnClick", function()
    MapLabelsConfig.displayMode = "icons"
    UpdateRadioButtons()
    MapLabels_UpdateMapLabels()
    print("|cff00ff00Map Labels:|r Switched to icons only mode!")
end)

bothButton:SetScript("OnClick", function()
    MapLabelsConfig.displayMode = "both"
    UpdateRadioButtons()
    MapLabels_UpdateMapLabels()
    print("|cff00ff00Map Labels:|r Switched to icons with labels mode!")
end)

-- When panel is shown, update the radio buttons
panel:SetScript("OnShow", function()
    UpdateRadioButtons()
end)

-- Register the panel with WoW's interface options
if Settings and Settings.RegisterCanvasLayoutCategory then
    -- Modern WoW (10.0+)
    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
else
    -- Legacy WoW
    InterfaceOptions_AddCategory(panel)
end