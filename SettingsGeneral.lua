-- General Settings Section

function CityGuideSettings_LoadGeneralSection()
    local scrollChild = CityGuideSettings.scrollChild
    
    -- Create general section
    local generalSection = CreateFrame("Frame", nil, scrollChild)
    generalSection:SetPoint("TOPLEFT", 20, -20)
    generalSection:SetPoint("TOPRIGHT", -20, -20)
    generalSection:SetHeight(600)
    CityGuideSettings.contentSections["general"] = generalSection
    
    -- Section title with icon
    local titleContainer = CreateFrame("Frame", nil, generalSection, "BackdropTemplate")
    titleContainer:SetSize(380, 50)
    titleContainer:SetPoint("TOPLEFT", 0, 0)
    titleContainer:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
        tile = true, tileSize = 16, edgeSize = 12,
        insets = { left = 3, right = 3, top = 3, bottom = 3 }
    })
    titleContainer:SetBackdropColor(0, 0, 0, 0.5)
    titleContainer:SetBackdropBorderColor(0.5, 0.5, 0.5, 1)
    
    local titleIcon = titleContainer:CreateTexture(nil, "ARTWORK")
    titleIcon:SetSize(32, 32)
    titleIcon:SetPoint("LEFT", titleContainer, "LEFT", 10, 0)
    titleIcon:SetTexture("Interface\\Icons\\INV_Misc_Book_09")
    
    local generalTitle = titleContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    generalTitle:SetPoint("LEFT", titleIcon, "RIGHT", 10, 0)
    generalTitle:SetText("General Settings")
    generalTitle:SetTextColor(1, 0.9, 0.5)
    
    -- Enabled Cities
    local citiesTitle = generalSection:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
    citiesTitle:SetPoint("TOPLEFT", titleContainer, "BOTTOMLEFT", 0, -20)
    citiesTitle:SetText("Enabled Cities")
    citiesTitle:SetTextColor(0.8, 0.9, 1)
    
    local citiesDesc = generalSection:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    citiesDesc:SetPoint("TOPLEFT", citiesTitle, "BOTTOMLEFT", 0, -5)
    citiesDesc:SetText("Select which cities show City Guide labels")
    citiesDesc:SetTextColor(0.7, 0.7, 0.7)
    
    local cityCheckboxes = {}
    local cityYOffset = -115
    local cityOrder = CityGuide_GetCityOrder()
    local mapNames = CityGuide_GetCityNames()
    
    for _, mapID in ipairs(cityOrder) do
        local cityName = mapNames[mapID]
        local checkbox = CreateFrame("CheckButton", nil, generalSection, "UICheckButtonTemplate")
        checkbox:SetPoint("TOPLEFT", 20, cityYOffset)
        
        local label = checkbox:CreateFontString(nil, "ARTWORK", "GameFontNormal")
        label:SetPoint("LEFT", checkbox, "RIGHT", 5, 0)
        label:SetText(cityName)
        
        checkbox.mapID = mapID
        
        checkbox:SetScript("OnClick", function(self)
            CityGuideConfig.enabledCities = CityGuideConfig.enabledCities or {}
            CityGuideConfig.enabledCities[self.mapID] = self:GetChecked()
            CityGuide_UpdateMapLabels()
        end)
        
        -- Hover effect
        checkbox:SetScript("OnEnter", function(self)
            label:SetTextColor(1, 1, 0.5)
        end)
        
        checkbox:SetScript("OnLeave", function(self)
            label:SetTextColor(1, 1, 1)
        end)
        
        cityCheckboxes[mapID] = checkbox
        cityYOffset = cityYOffset - 30
    end
    
    -- Store references for updates
    generalSection.cityCheckboxes = cityCheckboxes
    end
function CityGuideSettings_UpdateGeneralSection()
    local section = CityGuideSettings.contentSections["general"]
    if not section then return end
    
    CityGuideConfig.enabledCities = CityGuideConfig.enabledCities or {}
    
    for mapID, checkbox in pairs(section.cityCheckboxes) do
        if CityGuideConfig.enabledCities[mapID] == nil then
            checkbox:SetChecked(true)
        else
            checkbox:SetChecked(CityGuideConfig.enabledCities[mapID])
        end
    end
end