-- UI creation functions for City Guide

-- Map button reference
local mapButton = nil
local profFilterButton = nil
local buttonContainer = nil

-- Icon paths for each mode (better choices)
local modeIcons = {
    labels = "Interface\\Icons\\INV_Inscription_Scroll",  -- Scroll icon for text
    icons = "Interface\\Icons\\Ability_Spy",              -- Spyglass for viewing/finding
    both = "Interface\\Icons\\INV_Misc_Map02"             -- Map icon for both
}

-- Function to create a label (text only)
function CityGuide_CreateTextLabel(parent, x, y, text, scale, textDirection, color, labelDistance, sizeMultiplier)
    scale = scale or 1.0
    textDirection = textDirection or "down"
    color = color or "FFFFFF"
    labelDistance = labelDistance or 1.0
    sizeMultiplier = sizeMultiplier or 1.0
    
    local finalScale = scale * sizeMultiplier
    
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(200 * finalScale, 50 * finalScale) -- Increased height for multi-line
    
    container:SetFrameStrata("HIGH")
    container:SetFrameLevel(9999)

    -- Check if text contains line breaks
    local lines = {}
    for line in text:gmatch("[^\n]+") do
        table.insert(lines, line)
    end
    
    if #lines > 1 then
        -- Multi-line text - create multiple font strings
        local lineHeight = 16 * finalScale
        local totalHeight = lineHeight * #lines
        
        for i, line in ipairs(lines) do
            local fontString = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
            
            -- Position each line
            local yOffset = (totalHeight / 2) - (i - 0.5) * lineHeight
            fontString:SetPoint("CENTER", container, "CENTER", 0, yOffset)
            fontString:SetText(line)
            
            local r = tonumber(color:sub(1, 2), 16) / 255
            local g = tonumber(color:sub(3, 4), 16) / 255
            local b = tonumber(color:sub(5, 6), 16) / 255
            fontString:SetTextColor(r, g, b, 1)
            
            local font, _, flags = fontString:GetFont()
            fontString:SetFont(font, 16 * finalScale, "OUTLINE")
        end
    else
        -- Single-line text (original code)
        local fontString = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
        fontString:SetPoint("CENTER")
        fontString:SetText(text)
        
        local r = tonumber(color:sub(1, 2), 16) / 255
        local g = tonumber(color:sub(3, 4), 16) / 255
        local b = tonumber(color:sub(5, 6), 16) / 255
        fontString:SetTextColor(r, g, b, 1)
        
        local font, _, flags = fontString:GetFont()
        fontString:SetFont(font, 16 * finalScale, "OUTLINE")
    end

    local mapWidth = parent:GetWidth()
    local mapHeight = parent:GetHeight()
    
    local baseOffset = 0.03
    
    local offsetX, offsetY = 0, 0
    if textDirection == "left" then
        offsetX = -(baseOffset * labelDistance) * mapWidth
    elseif textDirection == "right" then
        offsetX = (baseOffset * labelDistance) * mapWidth
    elseif textDirection == "top" then
        offsetY = (baseOffset * labelDistance) * mapHeight
    elseif textDirection == "down" then
        offsetY = -(baseOffset * labelDistance) * mapHeight
    elseif textDirection == "none" then
        offsetX = 0
        offsetY = 0
    end
    
    container:SetPoint("CENTER", parent, "TOPLEFT", x * mapWidth + offsetX, -y * mapHeight + offsetY)

    container:Show()
    return container
end

-- Function to create icon only
function CityGuide_CreateIconOnly(parent, x, y, iconPath, scale, sizeMultiplier)
    scale = scale or 1.0
    sizeMultiplier = sizeMultiplier or 1.0
    
    local finalScale = scale * sizeMultiplier
    
    local container = CreateFrame("Frame", nil, parent)
    local iconSize = 24 * finalScale
    container:SetSize(iconSize, iconSize)

    container:SetFrameStrata("HIGH")
    container:SetFrameLevel(9999)
    
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

-- Function to create/update the combined button container
function CityGuide_CreateOrUpdateMapButton()
    if not buttonContainer then
        -- Create container frame with backdrop
        buttonContainer = CreateFrame("Frame", "CityGuideButtonContainer", WorldMapFrame.BorderFrame, "BackdropTemplate")
        buttonContainer:SetSize(70, 30)
        
        -- Position it
        if WorldMapFrame.overlayFrames and WorldMapFrame.overlayFrames[2] then
            buttonContainer:SetPoint("RIGHT", WorldMapFrame.overlayFrames[2], "LEFT", -20, 0)
        else
            buttonContainer:SetPoint("TOPRIGHT", WorldMapFrame.BorderFrame, "TOPRIGHT", -10, -10)
        end
        
        -- Set backdrop (dark background)
        buttonContainer:SetBackdrop({
            bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
            edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
            tile = true,
            tileSize = 16,
            edgeSize = 12,
            insets = { left = 3, right = 3, top = 3, bottom = 3 }
        })
        buttonContainer:SetBackdropColor(0, 0, 0, 0.8)
        buttonContainer:SetBackdropBorderColor(0.4, 0.4, 0.4, 1)
        
        -- Create profession filter as a standard checkbox
        profFilterButton = CreateFrame("CheckButton", "CityGuideProfFilterButton", buttonContainer, "UICheckButtonTemplate")
        profFilterButton:SetSize(24, 24)
        profFilterButton:SetPoint("LEFT", buttonContainer, "LEFT", 5, 0)
        
        profFilterButton:SetScript("OnClick", function(self)
            CityGuideConfig.filterByProfession = self:GetChecked()
            CityGuide_UpdateMapLabels()
            
            if CityGuideConfig.filterByProfession then
                print("|cff00ff00City Guide:|r Profession filter enabled")
            else
                print("|cff00ff00City Guide:|r Profession filter disabled")
            end
        end)
        
        profFilterButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText("Filter My Professions")
            if CityGuideConfig.filterByProfession then
                GameTooltip:AddLine("|cff00ff00Enabled|r - Showing only your professions", 1, 1, 1)
            else
                GameTooltip:AddLine("|cffaaaaaa Disabled|r - Showing all professions", 1, 1, 1)
            end
            local profs = CityGuide_GetPlayerProfessions()
            if #profs > 0 then
                GameTooltip:AddLine(" ", 1, 1, 1)
                GameTooltip:AddLine("Your professions:", 0.5, 1, 0.5)
                for _, profNames in ipairs(profs) do
                    GameTooltip:AddLine("  • " .. profNames[1], 1, 1, 1)
                end
            end
            GameTooltip:AddLine(" ", 1, 1, 1)
            GameTooltip:AddLine("Click to toggle", 0.8, 0.8, 0.8)
            GameTooltip:Show()
        end)
        
        profFilterButton:SetScript("OnLeave", function(self)
            GameTooltip:Hide()
        end)
        
        -- Create mode toggle button
        mapButton = CreateFrame("Button", "CityGuideToggleButton", buttonContainer)
        mapButton:SetSize(24, 24)
        mapButton:SetPoint("LEFT", profFilterButton, "RIGHT", 8, 0)
        
        -- Mode icon
        local modeIcon = mapButton:CreateTexture(nil, "ARTWORK")
        modeIcon:SetSize(20, 20)
        modeIcon:SetPoint("CENTER")
        modeIcon:SetTexture(modeIcons[CityGuideConfig.displayMode])
        mapButton.icon = modeIcon
        
        mapButton:SetScript("OnClick", function(self)
            if CityGuideConfig.displayMode == "labels" then
                CityGuideConfig.displayMode = "icons"
            elseif CityGuideConfig.displayMode == "icons" then
                CityGuideConfig.displayMode = "both"
            else
                CityGuideConfig.displayMode = "labels"
            end
            
            -- Update icon immediately
            self.icon:SetTexture(modeIcons[CityGuideConfig.displayMode])
            CityGuide_UpdateMapLabels()
            
            -- Force refresh tooltip if it's showing
            if GameTooltip:IsOwned(self) then
                GameTooltip:Hide()
                self:GetScript("OnEnter")(self)
            end
            
            local modeName = CityGuideConfig.displayMode == "labels" and "Labels Only" or
                            CityGuideConfig.displayMode == "icons" and "Icons Only" or
                            "Icons with Labels"
            print("|cff00ff00City Guide:|r " .. modeName)
        end)
        
        mapButton:SetScript("OnEnter", function(self)
            self.icon:SetVertexColor(1, 1, 0.5)
            
            local modeName = CityGuideConfig.displayMode == "labels" and "Labels Only" or
                            CityGuideConfig.displayMode == "icons" and "Icons Only" or
                            "Icons with Labels"
            
            GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            GameTooltip:SetText("City Guide Display")
            GameTooltip:AddLine("Current: |cff00ff00" .. modeName .. "|r", 1, 1, 1)
            GameTooltip:AddLine(" ", 1, 1, 1)
            GameTooltip:AddLine("Click to cycle modes", 0.8, 0.8, 0.8)
            GameTooltip:Show()
        end)
        
        mapButton:SetScript("OnLeave", function(self)
            self.icon:SetVertexColor(1, 1, 1)
            GameTooltip:Hide()
        end)
    end
    
    -- Update checkbox state
    profFilterButton:SetChecked(CityGuideConfig.filterByProfession)
    
    -- Update mode icon
    mapButton.icon:SetTexture(modeIcons[CityGuideConfig.displayMode])
    
    buttonContainer:Show()
end

-- Function to hide the map button
function CityGuide_HideMapButton()
    if buttonContainer then
        buttonContainer:Hide()
    end
end

-- Function to hide profession filter button (kept for compatibility)
function CityGuide_HideProfFilterButton()
    -- No longer needed, handled by hiding container
end