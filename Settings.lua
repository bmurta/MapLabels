-- Initialize config early to prevent errors
CityGuideConfig = CityGuideConfig or {}
CityGuideConfig.displayMode = CityGuideConfig.displayMode or "labels"
CityGuideConfig.filterByProfession = CityGuideConfig.filterByProfession or false
CityGuideConfig.labelSize = CityGuideConfig.labelSize or 1.0
CityGuideConfig.iconSize = CityGuideConfig.iconSize or 1.0
CityGuideConfig.enabledCities = CityGuideConfig.enabledCities or {}
CityGuideConfig.cityIconSizes = CityGuideConfig.cityIconSizes or {}
CityGuideConfig.cityLabelSizes = CityGuideConfig.cityLabelSizes or {}

-- Map ID to City Name mapping (ordered by latest expansion first)
local cityOrder = {2339, 627, 85, 84} -- Dornogal, Dalaran, Orgrimmar, Stormwind
local mapNames = {
    [2339] = "Dornogal",
    [627] = "Dalaran (Legion/Remix)",
    [85] = "Orgrimmar",
    [84] = "Stormwind"
}

-- Create the main settings panel
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

-- Create left navigation panel
local navPanel = CreateFrame("Frame", nil, panel, "BackdropTemplate")
navPanel:SetPoint("TOPLEFT", desc, "BOTTOMLEFT", 0, -20)
navPanel:SetSize(150, 400)
navPanel:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
navPanel:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
navPanel:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

-- Create right content panel with scroll
local contentPanel = CreateFrame("Frame", nil, panel, "BackdropTemplate")
contentPanel:SetPoint("TOPLEFT", navPanel, "TOPRIGHT", 10, 0)
contentPanel:SetPoint("BOTTOMRIGHT", panel, "BOTTOMRIGHT", -20, 20)
contentPanel:SetBackdrop({
    bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
    edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
    tile = true, tileSize = 16, edgeSize = 16,
    insets = { left = 4, right = 4, top = 4, bottom = 4 }
})
contentPanel:SetBackdropColor(0.05, 0.05, 0.05, 0.8)
contentPanel:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)

-- Create scroll frame
local scrollFrame = CreateFrame("ScrollFrame", nil, contentPanel, "UIPanelScrollFrameTemplate")
scrollFrame:SetPoint("TOPLEFT", 8, -8)
scrollFrame:SetPoint("BOTTOMRIGHT", -28, 8)

local scrollChild = CreateFrame("Frame", nil, scrollFrame)
scrollChild:SetSize(1, 1) -- Will be resized dynamically
scrollFrame:SetScrollChild(scrollChild)

-- Function to update scroll child width
local function UpdateScrollChildSize()
    local width = scrollFrame:GetWidth() - 10
    scrollChild:SetWidth(width)
end

scrollFrame:SetScript("OnSizeChanged", UpdateScrollChildSize)
UpdateScrollChildSize()

-- Helper functions
local function CreateRadioButton(parent, text, xOffset, yOffset)
    local button = CreateFrame("CheckButton", nil, parent, "UIRadioButtonTemplate")
    button:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)
    
    local label = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("LEFT", button, "RIGHT", 5, 0)
    label:SetText(text)
    
    button.label = label
    return button
end

local function CreateSlider(parent, name, minVal, maxVal, step, xOffset, yOffset, width)
    width = width or 200
    local slider = CreateFrame("Slider", name, parent, "OptionsSliderTemplate")
    slider:SetPoint("TOPLEFT", parent, "TOPLEFT", xOffset, yOffset)
    slider:SetMinMaxValues(minVal, maxVal)
    slider:SetValueStep(step)
    slider:SetObeyStepOnDrag(true)
    slider:SetWidth(width)
    
    _G[name.."Low"]:SetText(minVal)
    _G[name.."High"]:SetText(maxVal)
    
    return slider
end

-- Navigation buttons data
local navCategories = {
    {name = "General", id = "general"},
    {name = "Display", id = "display"},
    {name = "Size Settings", id = "sizes"},
    {name = "Per-City Icons", id = "percityicons"},
    {name = "Per-City Labels", id = "percitylabels"}
}

local navButtons = {}
local currentCategory = "general"

-- Content sections
local contentSections = {}

-- Function to hide all content sections
local function HideAllSections()
    for id, section in pairs(contentSections) do
        section:Hide()
    end
end

-- Function to show a specific section
local function ShowSection(sectionId)
    HideAllSections()
    if contentSections[sectionId] then
        contentSections[sectionId]:Show()
        currentCategory = sectionId
    end
    
    -- Update nav button highlights
    for _, btn in ipairs(navButtons) do
        if btn.categoryId == sectionId then
            btn:SetBackdropColor(0.3, 0.3, 0.3, 1)
        else
            btn:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
        end
    end
end

-- Create navigation buttons
local yOffset = -10
for i, category in ipairs(navCategories) do
    local btn = CreateFrame("Button", nil, navPanel, "BackdropTemplate")
    btn:SetSize(130, 30)
    btn:SetPoint("TOP", navPanel, "TOP", 0, yOffset)
    btn:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Buttons\\UI-Common-MouseHilight",
        tile = true, tileSize = 16, edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0 }
    })
    btn:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
    btn:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    
    local text = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    text:SetPoint("CENTER")
    text:SetText(category.name)
    
    btn.categoryId = category.id
    btn:SetScript("OnClick", function(self)
        ShowSection(self.categoryId)
    end)
    
    btn:SetScript("OnEnter", function(self)
        if currentCategory ~= self.categoryId then
            self:SetBackdropColor(0.2, 0.2, 0.2, 0.8)
        end
    end)
    
    btn:SetScript("OnLeave", function(self)
        if currentCategory ~= self.categoryId then
            self:SetBackdropColor(0.1, 0.1, 0.1, 0.5)
        end
    end)
    
    table.insert(navButtons, btn)
    yOffset = yOffset - 35
end

-- ========================================
-- GENERAL SECTION
-- ========================================
local generalSection = CreateFrame("Frame", nil, scrollChild)
generalSection:SetPoint("TOPLEFT", 20, -20)
generalSection:SetPoint("TOPRIGHT", -20, -20)
generalSection:SetHeight(400)
contentSections["general"] = generalSection

local generalTitle = generalSection:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
generalTitle:SetPoint("TOPLEFT", 0, 0)
generalTitle:SetText("General Settings")

-- Enabled Cities
local citiesTitle = generalSection:CreateFontString(nil, "ARTWORK", "GameFontNormal")
citiesTitle:SetPoint("TOPLEFT", generalTitle, "BOTTOMLEFT", 0, -20)
citiesTitle:SetText("Enabled Cities")

local cityCheckboxes = {}
local cityYOffset = -80
for _, mapID in ipairs(cityOrder) do
    local cityName = mapNames[mapID]
    local checkbox = CreateFrame("CheckButton", nil, generalSection, "UICheckButtonTemplate")
    checkbox:SetPoint("TOPLEFT", 0, cityYOffset)
    
    local label = checkbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
    label:SetText(cityName)
    
    checkbox.mapID = mapID
    
    checkbox:SetScript("OnClick", function(self)
        CityGuideConfig.enabledCities = CityGuideConfig.enabledCities or {}
        CityGuideConfig.enabledCities[self.mapID] = self:GetChecked()
        CityGuide_UpdateMapLabels()
    end)
    
    cityCheckboxes[mapID] = checkbox
    cityYOffset = cityYOffset - 30
end

-- Profession Filter
local profFilterTitle = generalSection:CreateFontString(nil, "ARTWORK", "GameFontNormal")
profFilterTitle:SetPoint("TOPLEFT", 0, cityYOffset - 20)
profFilterTitle:SetText("Profession Filter")

local profFilterCheck = CreateFrame("CheckButton", nil, generalSection, "UICheckButtonTemplate")
profFilterCheck:SetPoint("TOPLEFT", profFilterTitle, "BOTTOMLEFT", 0, -10)

local profFilterLabel = profFilterCheck:CreateFontString(nil, "ARTWORK", "GameFontNormal")
profFilterLabel:SetPoint("LEFT", profFilterCheck, "RIGHT", 5, 0)
profFilterLabel:SetText("Only show my learned professions")

profFilterCheck:SetScript("OnClick", function(self)
    CityGuideConfig.filterByProfession = self:GetChecked()
    CityGuide_UpdateMapLabels()
end)

-- ========================================
-- DISPLAY SECTION
-- ========================================
local displaySection = CreateFrame("Frame", nil, scrollChild)
displaySection:SetPoint("TOPLEFT", 20, -20)
displaySection:SetPoint("TOPRIGHT", -20, -20)
displaySection:SetHeight(200)
contentSections["display"] = displaySection

local displayTitle = displaySection:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
displayTitle:SetPoint("TOPLEFT", 0, 0)
displayTitle:SetText("Display Mode")

local displayDesc = displaySection:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
displayDesc:SetPoint("TOPLEFT", displayTitle, "BOTTOMLEFT", 0, -5)
displayDesc:SetText("Choose how to display NPCs on the map")

-- Radio buttons
local labelsButton = CreateRadioButton(displaySection, "Labels Only", 0, -60)
local iconsButton = CreateRadioButton(displaySection, "Icons Only", 0, -90)
local bothButton = CreateRadioButton(displaySection, "Icons with Labels", 0, -120)

local function UpdateRadioButtons()
    labelsButton:SetChecked(CityGuideConfig.displayMode == "labels")
    iconsButton:SetChecked(CityGuideConfig.displayMode == "icons")
    bothButton:SetChecked(CityGuideConfig.displayMode == "both")
end

labelsButton:SetScript("OnClick", function()
    CityGuideConfig.displayMode = "labels"
    UpdateRadioButtons()
    CityGuide_UpdateMapLabels()
end)

iconsButton:SetScript("OnClick", function()
    CityGuideConfig.displayMode = "icons"
    UpdateRadioButtons()
    CityGuide_UpdateMapLabels()
end)

bothButton:SetScript("OnClick", function()
    CityGuideConfig.displayMode = "both"
    UpdateRadioButtons()
    CityGuide_UpdateMapLabels()
end)

-- ========================================
-- SIZE SETTINGS SECTION
-- ========================================
local sizesSection = CreateFrame("Frame", nil, scrollChild)
sizesSection:SetPoint("TOPLEFT", 20, -20)
sizesSection:SetPoint("TOPRIGHT", -20, -20)
sizesSection:SetHeight(300)
contentSections["sizes"] = sizesSection

local sizesTitle = sizesSection:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
sizesTitle:SetPoint("TOPLEFT", 0, 0)
sizesTitle:SetText("Global Size Settings")

local sizesDesc = sizesSection:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
sizesDesc:SetPoint("TOPLEFT", sizesTitle, "BOTTOMLEFT", 0, -5)
sizesDesc:SetText("Adjust the base size for all cities")
sizesDesc:SetWidth(400)
sizesDesc:SetJustifyH("LEFT")

-- Label Size
local labelSizeTitle = sizesSection:CreateFontString(nil, "ARTWORK", "GameFontNormal")
labelSizeTitle:SetPoint("TOPLEFT", sizesDesc, "BOTTOMLEFT", 0, -30)
labelSizeTitle:SetText("Label Size")

local labelSizeSlider = CreateSlider(sizesSection, "CityGuideLabelSizeSlider", 0.5, 2.0, 0.1, 0, -110, 300)
_G["CityGuideLabelSizeSliderText"]:Hide()

local labelSizeValue = sizesSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
labelSizeValue:SetPoint("TOP", labelSizeSlider, "BOTTOM", 0, 0)
labelSizeValue:SetText("1.0x")

labelSizeSlider:SetScript("OnValueChanged", function(self, value)
    CityGuideConfig.labelSize = value
    labelSizeValue:SetText(string.format("%.1fx", value))
    CityGuide_UpdateMapLabels()
end)

-- Icon Size
local iconSizeTitle = sizesSection:CreateFontString(nil, "ARTWORK", "GameFontNormal")
iconSizeTitle:SetPoint("TOPLEFT", labelSizeSlider, "BOTTOMLEFT", 0, -45)
iconSizeTitle:SetText("Icon Size (Global)")

local iconSizeSlider = CreateSlider(sizesSection, "CityGuideIconSizeSlider", 0.5, 2.0, 0.1, 0, -195, 300)
_G["CityGuideIconSizeSliderText"]:Hide()

local iconSizeValue = sizesSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
iconSizeValue:SetPoint("TOP", iconSizeSlider, "BOTTOM", 0, 0)
iconSizeValue:SetText("1.0x")

iconSizeSlider:SetScript("OnValueChanged", function(self, value)
    CityGuideConfig.iconSize = value
    iconSizeValue:SetText(string.format("%.1fx", value))
    CityGuide_UpdateMapLabels()
end)

-- Reset button
local resetButton = CreateFrame("Button", nil, sizesSection, "UIPanelButtonTemplate")
resetButton:SetSize(120, 25)
resetButton:SetPoint("TOPLEFT", iconSizeSlider, "BOTTOMLEFT", 0, -30)
resetButton:SetText("Reset All Sizes")

-- ========================================
-- PER-CITY ICONS SECTION
-- ========================================
local perCitySection = CreateFrame("Frame", nil, scrollChild)
perCitySection:SetPoint("TOPLEFT", 20, -20)
perCitySection:SetPoint("TOPRIGHT", -20, -20)
perCitySection:SetHeight(400)
contentSections["percityicons"] = perCitySection

local perCityTitle = perCitySection:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
perCityTitle:SetPoint("TOPLEFT", 0, 0)
perCityTitle:SetText("Per-City Icon Size")

local perCityDesc = perCitySection:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
perCityDesc:SetPoint("TOPLEFT", perCityTitle, "BOTTOMLEFT", 0, -5)
perCityDesc:SetText("Adjust icon size for individual cities (multiplied by global icon size)")
perCityDesc:SetWidth(400)
perCityDesc:SetJustifyH("LEFT")

-- Create per-city sliders
local cityIconSliders = {}
local cityIconSizeValues = {}
local perCityYOffset = -80

for _, mapID in ipairs(cityOrder) do
    local cityName = mapNames[mapID]
    local cityTitle = perCitySection:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    cityTitle:SetPoint("TOPLEFT", 0, perCityYOffset)
    cityTitle:SetText(cityName .. " Icon Size")
    
    local citySlider = CreateSlider(perCitySection, "CityGuide"..cityName:gsub("[^%w]", "").."IconSlider", 0.5, 2.0, 0.1, 0, perCityYOffset - 20, 300)
    _G["CityGuide"..cityName:gsub("[^%w]", "").."IconSliderText"]:Hide()
    
    local cityValue = perCitySection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    cityValue:SetPoint("TOP", citySlider, "BOTTOM", 0, 0)
    cityValue:SetText("1.0x")
    
    citySlider:SetScript("OnValueChanged", function(self, value)
        CityGuideConfig.cityIconSizes[mapID] = value
        cityValue:SetText(string.format("%.1fx", value))
        CityGuide_UpdateMapLabels()
    end)
    
    cityIconSliders[mapID] = citySlider
    cityIconSizeValues[mapID] = cityValue
    perCityYOffset = perCityYOffset - 75
end

-- Update reset button to include per-city sizes
resetButton:SetScript("OnClick", function()
    CityGuideConfig.labelSize = 1.0
    CityGuideConfig.iconSize = 1.0
    CityGuideConfig.cityIconSizes = {}
    CityGuideConfig.cityLabelSizes = {}
    labelSizeSlider:SetValue(1.0)
    iconSizeSlider:SetValue(1.0)
    labelSizeValue:SetText("1.0x")
    iconSizeValue:SetText("1.0x")
    
    for mapID, slider in pairs(cityIconSliders) do
        slider:SetValue(1.0)
        cityIconSizeValues[mapID]:SetText("1.0x")
    end
    
    for mapID, slider in pairs(cityLabelSliders) do
        slider:SetValue(1.0)
        cityLabelSizeValues[mapID]:SetText("1.0x")
    end
    
    CityGuide_UpdateMapLabels()
    print("|cff00ff00City Guide:|r All sizes reset to default")
end)

-- ========================================
-- PER-CITY LABELS SECTION
-- ========================================
local perCityLabelSection = CreateFrame("Frame", nil, scrollChild)
perCityLabelSection:SetPoint("TOPLEFT", 20, -20)
perCityLabelSection:SetPoint("TOPRIGHT", -20, -20)
perCityLabelSection:SetHeight(400)
contentSections["percitylabels"] = perCityLabelSection

local perCityLabelTitle = perCityLabelSection:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
perCityLabelTitle:SetPoint("TOPLEFT", 0, 0)
perCityLabelTitle:SetText("Per-City Label Size")

local perCityLabelDesc = perCityLabelSection:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
perCityLabelDesc:SetPoint("TOPLEFT", perCityLabelTitle, "BOTTOMLEFT", 0, -5)
perCityLabelDesc:SetText("Adjust label size for individual cities (multiplied by global label size)")
perCityLabelDesc:SetWidth(400)
perCityLabelDesc:SetJustifyH("LEFT")

-- Create per-city label sliders
local cityLabelSliders = {}
local cityLabelSizeValues = {}
local perCityLabelYOffset = -80

for _, mapID in ipairs(cityOrder) do
    local cityName = mapNames[mapID]
    local cityTitle = perCityLabelSection:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    cityTitle:SetPoint("TOPLEFT", 0, perCityLabelYOffset)
    cityTitle:SetText(cityName .. " Label Size")
    
    local citySlider = CreateSlider(perCityLabelSection, "CityGuide"..cityName:gsub("[^%w]", "").."LabelSlider", 0.5, 2.0, 0.1, 0, perCityLabelYOffset - 20, 300)
    _G["CityGuide"..cityName:gsub("[^%w]", "").."LabelSliderText"]:Hide()
    
    local cityValue = perCityLabelSection:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
    cityValue:SetPoint("TOP", citySlider, "BOTTOM", 0, 0)
    cityValue:SetText("1.0x")
    
    citySlider:SetScript("OnValueChanged", function(self, value)
        CityGuideConfig.cityLabelSizes = CityGuideConfig.cityLabelSizes or {}
        CityGuideConfig.cityLabelSizes[mapID] = value
        cityValue:SetText(string.format("%.1fx", value))
        CityGuide_UpdateMapLabels()
    end)
    
    cityLabelSliders[mapID] = citySlider
    cityLabelSizeValues[mapID] = cityValue
    perCityLabelYOffset = perCityLabelYOffset - 75
end

-- Update function when panel is shown
panel:SetScript("OnShow", function()
    UpdateRadioButtons()
    
    CityGuideConfig.enabledCities = CityGuideConfig.enabledCities or {}
    
    for mapID, checkbox in pairs(cityCheckboxes) do
        if CityGuideConfig.enabledCities[mapID] == nil then
            checkbox:SetChecked(true)
        else
            checkbox:SetChecked(CityGuideConfig.enabledCities[mapID])
        end
    end
    
    profFilterCheck:SetChecked(CityGuideConfig.filterByProfession)
    labelSizeSlider:SetValue(CityGuideConfig.labelSize or 1.0)
    iconSizeSlider:SetValue(CityGuideConfig.iconSize or 1.0)
    labelSizeValue:SetText(string.format("%.1fx", CityGuideConfig.labelSize or 1.0))
    iconSizeValue:SetText(string.format("%.1fx", CityGuideConfig.iconSize or 1.0))
    
    for mapID, slider in pairs(cityIconSliders) do
        local citySize = CityGuideConfig.cityIconSizes[mapID] or 1.0
        slider:SetValue(citySize)
        cityIconSizeValues[mapID]:SetText(string.format("%.1fx", citySize))
    end
    
    for mapID, slider in pairs(cityLabelSliders) do
        local citySize = CityGuideConfig.cityLabelSizes[mapID] or 1.0
        slider:SetValue(citySize)
        cityLabelSizeValues[mapID]:SetText(string.format("%.1fx", citySize))
    end
    
    ShowSection("general")
end)

-- Register the panel
if Settings and Settings.RegisterCanvasLayoutCategory then
    local category = Settings.RegisterCanvasLayoutCategory(panel, panel.name)
    Settings.RegisterAddOnCategory(category)
else
    InterfaceOptions_AddCategory(panel)
end
