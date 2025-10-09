-- UI creation functions for City Guide

-- Map button reference
local mapButton = nil
local profFilterButton = nil

-- Function to create a label (text only)
function CityGuide_CreateTextLabel(parent, x, y, text, scale, textDirection, color, labelDistance, sizeMultiplier)
    scale = scale or 1.0
    textDirection = textDirection or "down"
    color = color or "FFFFFF"
    labelDistance = labelDistance or 1.0
    sizeMultiplier = sizeMultiplier or 1.0 -- New parameter for label size
    
    -- Apply size multiplier to scale
    local finalScale = scale * sizeMultiplier
    
    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(200 * finalScale, 26 * finalScale)
    
    container:SetFrameStrata("HIGH")
    container:SetFrameLevel(9999)

    local fontString = container:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    fontString:SetPoint("CENTER")
    fontString:SetText(text)
    
    local r = tonumber(color:sub(1, 2), 16) / 255
    local g = tonumber(color:sub(3, 4), 16) / 255
    local b = tonumber(color:sub(5, 6), 16) / 255
    fontString:SetTextColor(r, g, b, 1)
    
    local font, _, flags = fontString:GetFont()
    fontString:SetFont(font, 16 * finalScale, "OUTLINE")

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
    sizeMultiplier = sizeMultiplier or 1.0 -- New parameter for icon size
    
    -- Apply size multiplier to scale
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

-- Function to create/update the map button
function CityGuide_CreateOrUpdateMapButton()
    if not mapButton then
        mapButton = CreateFrame("Button", "CityGuideToggleButton", WorldMapFrame.BorderFrame, "UIPanelButtonTemplate")
        mapButton:SetSize(120, 22)
        
        if WorldMapFrame.overlayFrames and WorldMapFrame.overlayFrames[2] then
            mapButton:SetPoint("RIGHT", WorldMapFrame.overlayFrames[2], "LEFT", -15, 0)
        else
            mapButton:SetPoint("TOPRIGHT", WorldMapFrame.BorderFrame, "TOPRIGHT", -10, -10)
        end
        
        mapButton:SetScript("OnClick", function()
            if CityGuideConfig.displayMode == "labels" then
                CityGuideConfig.displayMode = "icons"
            elseif CityGuideConfig.displayMode == "icons" then
                CityGuideConfig.displayMode = "both"
            else
                CityGuideConfig.displayMode = "labels"
            end
            
            CityGuide_CreateOrUpdateMapButton()
            CityGuide_UpdateMapLabels()
            print("|cff00ff00City Guide:|r Switched to " .. CityGuideConfig.displayMode .. " mode!")
        end)
        
        mapButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("City Guide Display Mode")
            GameTooltip:AddLine("Click to cycle through display modes", 1, 1, 1)
            GameTooltip:Show()
        end)
        
        mapButton:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    
    if CityGuideConfig.displayMode == "labels" then
        mapButton:SetText("Labels Only")
    elseif CityGuideConfig.displayMode == "icons" then
        mapButton:SetText("Icons Only")
    else
        mapButton:SetText("Icons + Labels")
    end
    
    mapButton:Show()
end

-- Function to create/update profession filter button
function CityGuide_CreateOrUpdateProfFilterButton()
    if not profFilterButton then
        profFilterButton = CreateFrame("CheckButton", "CityGuideProfFilterButton", WorldMapFrame.BorderFrame, "UICheckButtonTemplate")
        profFilterButton:SetSize(22, 22)
        
        if mapButton then
            profFilterButton:SetPoint("RIGHT", mapButton, "LEFT", -5, 0)
        else
            profFilterButton:SetPoint("TOPRIGHT", WorldMapFrame.BorderFrame, "TOPRIGHT", -140, -10)
        end
        
        local label = profFilterButton:CreateFontString(nil, "OVERLAY", "GameFontNormal")
        label:SetPoint("RIGHT", profFilterButton, "LEFT", -5, 0)
        label:SetText("My Profs")
        
        profFilterButton:SetScript("OnClick", function(self)
            CityGuideConfig.filterByProfession = self:GetChecked()
            CityGuide_UpdateMapLabels()
            
            if CityGuideConfig.filterByProfession then
                local profs = CityGuide_GetPlayerProfessions()
                if #profs > 0 then
                    print("|cff00ff00City Guide:|r Filtering to your professions")
                else
                    print("|cffff0000City Guide:|r You have no professions learned")
                end
            else
                print("|cff00ff00City Guide:|r Showing all professions")
            end
        end)
        
        profFilterButton:SetScript("OnEnter", function(self)
            GameTooltip:SetOwner(self, "ANCHOR_TOP")
            GameTooltip:SetText("Filter My Professions")
            GameTooltip:AddLine("Only show your learned professions", 1, 1, 1)
            local profs = CityGuide_GetPlayerProfessions()
            if #profs > 0 then
                GameTooltip:AddLine(" ", 1, 1, 1)
                GameTooltip:AddLine("Your professions:", 0.5, 1, 0.5)
                for _, profNames in ipairs(profs) do
                    GameTooltip:AddLine("  • " .. profNames[1], 1, 1, 1)
                end
            end
            GameTooltip:Show()
        end)
        
        profFilterButton:SetScript("OnLeave", function()
            GameTooltip:Hide()
        end)
    end
    
    profFilterButton:SetChecked(CityGuideConfig.filterByProfession)
    profFilterButton:Show()
end

-- Function to hide the map button
function CityGuide_HideMapButton()
    if mapButton then
        mapButton:Hide()
    end
end

-- Function to hide profession filter button
function CityGuide_HideProfFilterButton()
    if profFilterButton then
        profFilterButton:Hide()
    end
end