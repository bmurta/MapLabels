-- Display Settings Section

function CityGuideSettings_LoadDisplaySection()
    local scrollChild = CityGuideSettings.scrollChild
    
    local displaySection = CreateFrame("Frame", nil, scrollChild)
    displaySection:SetPoint("TOPLEFT", 20, -20)
    displaySection:SetPoint("TOPRIGHT", -20, -20)
    displaySection:SetHeight(400)
    CityGuideSettings.contentSections["display"] = displaySection
    
    -- Section title
    local titleContainer = CreateFrame("Frame", nil, displaySection, "BackdropTemplate")
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
    titleIcon:SetTexture("Interface\\Icons\\INV_Misc_Map02")
    
    local displayTitle = titleContainer:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    displayTitle:SetPoint("LEFT", titleIcon, "RIGHT", 10, 0)
    displayTitle:SetText("Display Mode")
    displayTitle:SetTextColor(1, 0.9, 0.5)
    
    local displayDesc = displaySection:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    displayDesc:SetPoint("TOPLEFT", titleContainer, "BOTTOMLEFT", 0, -10)
    displayDesc:SetText("Choose how to display NPCs on the map")
    displayDesc:SetTextColor(0.7, 0.7, 0.7)
    
    -- Helper function to update button states
    local function UpdateButtonStates(buttons, selectedMode)
        for mode, btn in pairs(buttons) do
            if mode == selectedMode then
                btn:SetBackdropColor(0.2, 0.4, 0.2, 1)
                btn:SetBackdropBorderColor(0.3, 0.8, 0.3, 1)
                if btn.checkmark then
                    btn.checkmark:Show()
                end
            else
                btn:SetBackdropColor(0, 0, 0, 0.4)
                btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
                if btn.checkmark then
                    btn.checkmark:Hide()
                end
            end
        end
    end
    
    -- Create mode buttons
    local modeButtons = {}
    local modeData = {
        {mode = "labels", text = "Labels Only", desc = "Show only text labels", y = -90},
        {mode = "icons", text = "Icons Only", desc = "Show only square icons", y = -150},
        {mode = "both", text = "Icons with Labels", desc = "Square icons + labels", y = -210},
        {mode = "smallicons", text = "Small Icons", desc = "Minimap-style icons only", y = -270},
        {mode = "smallboth", text = "Small Icons with Labels", desc = "Minimap-style icons + labels", y = -330},
    }
    
    for _, data in ipairs(modeData) do
        local btn = CreateFrame("Button", nil, displaySection, "BackdropTemplate")
        btn:SetSize(355, 50)
        btn:SetPoint("TOPLEFT", 0, data.y)
        btn:SetBackdrop({
            bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true, tileSize = 16, edgeSize = 8,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        btn:SetBackdropColor(0, 0, 0, 0.4)
        btn:SetBackdropBorderColor(0.4, 0.4, 0.4, 0.8)
        
        -- Checkmark icon
        local checkmark = btn:CreateTexture(nil, "OVERLAY")
        checkmark:SetSize(24, 24)
        checkmark:SetPoint("LEFT", btn, "LEFT", 10, 0)
        checkmark:SetTexture("Interface\\RaidFrame\\ReadyCheck-Ready")
        checkmark:Hide()
        btn.checkmark = checkmark
        
        -- Title
        local title = btn:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        title:SetPoint("TOPLEFT", btn, "TOPLEFT", 45, -10)
        title:SetText(data.text)
        title:SetTextColor(1, 1, 1)
        
        -- Description
        local desc = btn:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall")
        desc:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -3)
        desc:SetText(data.desc)
        desc:SetTextColor(0.7, 0.7, 0.7)
        
        -- Click handler
        btn:SetScript("OnClick", function(self)
            CityGuideConfig.displayMode = data.mode
            UpdateButtonStates(modeButtons, data.mode)
            CityGuide_UpdateMapLabels()
            print("|cff00ff00City Guide:|r Switched to " .. data.text)
        end)
        
        -- Hover effects
        btn:SetScript("OnEnter", function(self)
            if CityGuideConfig.displayMode ~= data.mode then
                self:SetBackdropColor(0.1, 0.1, 0.1, 0.8)
            end
            title:SetTextColor(1, 1, 0.5)
        end)
        
        btn:SetScript("OnLeave", function(self)
            if CityGuideConfig.displayMode ~= data.mode then
                self:SetBackdropColor(0, 0, 0, 0.4)
            end
            title:SetTextColor(1, 1, 1)
        end)
        
        modeButtons[data.mode] = btn
    end
    
    -- Store references
    displaySection.modeButtons = modeButtons
    displaySection.UpdateButtonStates = UpdateButtonStates
end

function CityGuideSettings_UpdateDisplaySection()
    -- Simplified - just check if the global exists and has our section
    if not CityGuideSettings then return end
    if not CityGuideSettings.contentSections then return end
    
    local section = CityGuideSettings.contentSections["display"]
    if not section then return end
    if not section.modeButtons then return end
    if not section.UpdateButtonStates then return end
    
    -- Update button states
    section.UpdateButtonStates(section.modeButtons, CityGuideConfig.displayMode)
end