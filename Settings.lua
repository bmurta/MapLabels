-- Create the settings panel
local panel = CreateFrame("Frame", "CityGuideSettingsPanel", UIParent)
panel.name = "City Guide"

-- Title
local title = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOPLEFT", 16, -16)
title:SetText("City Guide Settings")

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

-- Slider helper function
local function CreateSlider(parent, name, minVal, maxVal, step, xOffset, yOffset)
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetWidth(200)
    
    -- Set slider labels
    _G[name.."Low"]:SetText(minVal)
    _G[name.."High"]:SetText(maxVal)
    
    return slider
end

-- Display Mode Section
local displayModeTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
displayModeTitle:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)
displayModeTitle:SetText("Display Mode")

-- Create radio buttons
local labelsButton = CreateRadioButton(panel, "Labels Only", 20, -100)
local iconsButton = CreateRadioButton(panel, "Icons Only", 20, -130)
local bothButton = CreateRadioButton(panel, "Icons with Labels", 20, -160)

-- Function to update radio buttons based on current config
local function UpdateRadioButtons()
    labelsButton:SetChecked(CityGuideConfig.displayMode == "labels")
    iconsButton:SetChecked(CityGuideConfig.displayMode == "icons")
    bothButton:SetChecked(CityGuideConfig.displayMode == "both")
end

-- Set up button clicks
labelsButton:SetScript("OnClick", function()
    CityGuideConfig.displayMode = "labels"
    UpdateRadioButtons()
    CityGuide_UpdateMapLabels()
    print("|cff00ff00City Guide:|r Switched to labels only mode!")
end)

iconsButton:SetScript("OnClick", function()
    CityGuideConfig.displayMode = "icons"
    UpdateRadioButtons()
    CityGuide_UpdateMapLabels()
    print("|cff00ff00City Guide:|r Switched to icons only mode!")
end)

bothButton:SetScript("OnClick", function()
    CityGuideConfig.displayMode = "both"
    UpdateRadioButtons()
    CityGuide_UpdateMapLabels()
    print("|cff00ff00City Guide:|r Switched to icons with labels mode!")
end)

-- Profession Filter Section
local profFilterTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
profFilterTitle:SetPoint("TOPLEFT", bothButton, "BOTTOMLEFT", -20, -30)
profFilterTitle:SetText("Profession Filter")

local profFilterCheck = CreateFrame("CheckButton", nil, panel, "UICheckButtonTemplate")
profFilterCheck:SetPoint("TOPLEFT", profFilterTitle, "BOTTOMLEFT", 0, -10)

local profFilterLabel = profFilterCheck:CreateFontString(nil, "ARTWORK", "GameFontNormal")
profFilterLabel:SetPoint("LEFT", profFilterCheck, "RIGHT", 5, 0)
profFilterLabel:SetText("Only show my learned professions")

profFilterCheck:SetScript("OnClick", function(self)
    CityGuideConfig.filterByProfession = self:GetChecked()
    CityGuide_UpdateMapLabels()
    
    if CityGuideConfig.filterByProfession then
        print("|cff00ff00City Guide:|r Profession filter enabled")
    else
        print("|cff00ff00City Guide:|r Profession filter disabled")
    end
end)

-- Size Settings Section
local sizeTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
sizeTitle:SetPoint("TOPLEFT", profFilterCheck, "BOTTOMLEFT", -20, -30)
sizeTitle:SetText("Size Settings")

-- Label Size Slider
local labelSizeTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
labelSizeTitle:SetPoint("TOPLEFT", sizeTitle, "BOTTOMLEFT", 20, -20)
labelSizeTitle:SetText("Label Size")

local labelSizeSlider = CreateSlider(panel, "CityGuideLabelSizeSlider", 0.5, 2.0, 0.1, 20, -300)
_G["CityGuideLabelSizeSliderText"]:Hide() -- Hide the default title

local labelSizeValue = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
labelSizeValue:SetPoint("TOP", labelSizeSlider, "BOTTOM", 0, 0)
labelSizeValue:SetText(string.format("%.1fx", CityGuideConfig.labelSize or 1.0))

labelSizeSlider:SetScript("OnValueChanged", function(self, value)
    CityGuideConfig.labelSize = value
    labelSizeValue:SetText(string.format("%.1fx", value))
    CityGuide_UpdateMapLabels()
end)

-- Icon Size Slider
local iconSizeTitle = panel:CreateFontString(nil, "ARTWORK", "GameFontNormal")
iconSizeTitle:SetPoint("TOPLEFT", labelSizeSlider, "BOTTOMLEFT", 0, -45)
iconSizeTitle:SetText("Icon Size")

local iconSizeSlider = CreateSlider(panel, "CityGuideIconSizeSlider", 0.5, 2.0, 0.1, 20, -365)
_G["CityGuideIconSizeSliderText"]:Hide() -- Hide the default title

local iconSizeValue = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
iconSizeValue:SetPoint("TOP", iconSizeSlider, "BOTTOM", 0, 0)
iconSizeValue:SetText(string.format("%.1fx", CityGuideConfig.iconSize or 1.0))

iconSizeSlider:SetScript("OnValueChanged", function(self, value)
    CityGuideConfig.iconSize = value
    iconSizeValue:SetText(string.format("%.1fx", value))
    CityGuide_UpdateMapLabels()
end)

-- Reset button
local resetButton = CreateFrame("Button", nil, panel, "UIPanelButtonTemplate")
resetButton:SetSize(120, 25)
resetButton:SetPoint("TOPLEFT", iconSizeSlider, "BOTTOMLEFT", 0, -30)
resetButton:SetText("Reset to Default")

resetButton:SetScript("OnClick", function()
    CityGuideConfig.labelSize = 1.0
    CityGuideConfig.iconSize = 1.0
    labelSizeSlider:SetValue(1.0)
    iconSizeSlider:SetValue(1.0)
    labelSizeValue:SetText("1.0x")
    iconSizeValue:SetText("1.0x")
    CityGuide_UpdateMapLabels()
    print("|cff00ff00City Guide:|r Sizes reset to default")
end)

-- When panel is shown, update the controls
panel:SetScript("OnShow", function()
    UpdateRadioButtons()
    profFilterCheck:SetChecked(CityGuideConfig.filterByProfession)
    labelSizeSlider:SetValue(CityGuideConfig.labelSize or 1.0)
    iconSizeSlider:SetValue(CityGuideConfig.iconSize or 1.0)
    labelSizeValue:SetText(string.format("%.1fx", CityGuideConfig.labelSize or 1.0))
    iconSizeValue:SetText(string.format("%.1fx", CityGuideConfig.iconSize or 1.0))
end)

-- Register the panel with WoW's interface options
if Settings and Settings.RegisterCanvasLayoutCategory then
    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
else
    InterfaceOptions_AddCategory(panel)
end