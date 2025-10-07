-- Slash Commands for MapLabels
-- Coordinate capture helper
local function CaptureCoordinates(npcName, iconPath)
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then
        print("|cffff0000Error:|r Could not get map ID")
        return
    end

    local position = C_Map.GetPlayerMapPosition(mapID, "player")
    if not position then
        print("|cffff0000Error:|r Could not get position")
        return
    end

    local x, y = position:GetXY()
    x = x * 100 -- Convert to 0-100 format
    y = y * 100

    -- Format the output
    local output
    if iconPath then
        output = string.format('{x = %.2f / 100, y = %.2f / 100, name = "%s", icon = "%s"},', x, y, npcName, iconPath)
    else
        output = string.format('{x = %.2f / 100, y = %.2f / 100, name = "%s", icon = "ICON_PATH_HERE"},', x, y, npcName)
    end

    print("|cff00ff00Coordinate captured!|r")
    print(output)

    -- Create a frame with an editbox for easy copying
    if not MapLabelsCopyFrame then
        MapLabelsCopyFrame = CreateFrame("Frame", "MapLabelsCopyFrame", UIParent, "BasicFrameTemplateWithInset")
        MapLabelsCopyFrame:SetSize(600, 120)
        MapLabelsCopyFrame:SetPoint("CENTER")
        MapLabelsCopyFrame:Hide()
        MapLabelsCopyFrame:SetMovable(true)
        MapLabelsCopyFrame:EnableMouse(true)
        MapLabelsCopyFrame:RegisterForDrag("LeftButton")
        MapLabelsCopyFrame:SetScript("OnDragStart", MapLabelsCopyFrame.StartMoving)
        MapLabelsCopyFrame:SetScript("OnDragStop", MapLabelsCopyFrame.StopMovingOrSizing)

        MapLabelsCopyFrame.title = MapLabelsCopyFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        MapLabelsCopyFrame.title:SetPoint("TOP", 0, -5)
        MapLabelsCopyFrame.title:SetText("Copy Coordinates (Ctrl+A, Ctrl+C)")

        -- Create scrollable editbox
        local scrollFrame = CreateFrame("ScrollFrame", nil, MapLabelsCopyFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 10, -30)
        scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

        local editBox = CreateFrame("EditBox", nil, scrollFrame)
        editBox:SetMultiLine(true)
        editBox:SetFontObject(ChatFontNormal)
        editBox:SetWidth(550)
        editBox:SetAutoFocus(false)
        editBox:SetScript("OnEscapePressed", function()
            MapLabelsCopyFrame:Hide()
        end)

        scrollFrame:SetScrollChild(editBox)
        MapLabelsCopyFrame.editBox = editBox
    end

    -- Show the frame with the coordinate text
    MapLabelsCopyFrame.editBox:SetText(output)
    MapLabelsCopyFrame.editBox:HighlightText()
    MapLabelsCopyFrame:Show()
end

-- Slash command for coordinate capture
local function HandleCaptureCommand(msg)
    local npcName, iconPath = msg:match("^(.-)%s*,%s*(.+)$")

    if not npcName or npcName == "" then
        npcName = msg:trim()
    end

    if npcName == "" then
        print("|cff00ff00MapLabels Coordinate Capture:|r")
        print("/mlc <name> - Capture coordinates for NPC")
        print("/mlc <name>, <icon path> - Capture with icon path")
        print("|cffaaaaaa Example: /mlc Bank")
        print("|cffaaaaaa Example: /mlc Bank, Interface\\\\Icons\\\\INV_Misc_Bag_07")
        return
    end

    CaptureCoordinates(npcName, iconPath)
end

-- Slash command for coordinate capture (coordinates only)
local function HandleCoordsOnlyCommand(msg)
    local mapID = C_Map.GetBestMapForUnit("player")
    if not mapID then
        print("|cffff0000Error:|r Could not get map ID")
        return
    end

    local position = C_Map.GetPlayerMapPosition(mapID, "player")
    if not position then
        print("|cffff0000Error:|r Could not get position")
        return
    end

    local x, y = position:GetXY()
    x = x * 100 -- Convert to 0-100 format
    y = y * 100

    -- Format just the coordinates
    local output = string.format('{x = %.2f / 100, y = %.2f / 100,', x, y)

    print("|cff00ff00Coordinates captured!|r")
    print(output)

    -- Create a frame with an editbox for easy copying
    if not MapLabelsCoordsFrame then
        MapLabelsCoordsFrame = CreateFrame("Frame", "MapLabelsCoordsFrame", UIParent, "BasicFrameTemplateWithInset")
        MapLabelsCoordsFrame:SetSize(400, 100)
        MapLabelsCoordsFrame:SetPoint("CENTER")
        MapLabelsCoordsFrame:Hide()
        MapLabelsCoordsFrame:SetMovable(true)
        MapLabelsCoordsFrame:EnableMouse(true)
        MapLabelsCoordsFrame:RegisterForDrag("LeftButton")
        MapLabelsCoordsFrame:SetScript("OnDragStart", MapLabelsCoordsFrame.StartMoving)
        MapLabelsCoordsFrame:SetScript("OnDragStop", MapLabelsCoordsFrame.StopMovingOrSizing)

        MapLabelsCoordsFrame.title = MapLabelsCoordsFrame:CreateFontString(nil, "OVERLAY", "GameFontHighlight")
        MapLabelsCoordsFrame.title:SetPoint("TOP", 0, -5)
        MapLabelsCoordsFrame.title:SetText("Copy Coordinates (Ctrl+A, Ctrl+C)")

        -- Create scrollable editbox
        local scrollFrame = CreateFrame("ScrollFrame", nil, MapLabelsCoordsFrame, "UIPanelScrollFrameTemplate")
        scrollFrame:SetPoint("TOPLEFT", 10, -30)
        scrollFrame:SetPoint("BOTTOMRIGHT", -30, 10)

        local editBox = CreateFrame("EditBox", nil, scrollFrame)
        editBox:SetMultiLine(true)
        editBox:SetFontObject(ChatFontNormal)
        editBox:SetWidth(350)
        editBox:SetAutoFocus(false)
        editBox:SetScript("OnEscapePressed", function()
            MapLabelsCoordsFrame:Hide()
        end)

        scrollFrame:SetScrollChild(editBox)
        MapLabelsCoordsFrame.editBox = editBox
    end

    -- Show the frame with the coordinate text
    MapLabelsCoordsFrame.editBox:SetText(output)
    MapLabelsCoordsFrame.editBox:HighlightText()
    MapLabelsCoordsFrame:Show()
end

-- Main slash command handler
local function HandleSlashCommand(msg)
    msg = msg:lower():trim()

    if msg == "both" then
        MapLabelsConfig.displayMode = "both"
        print("|cff00ff00MapLabels:|r Icons with labels enabled!")
        MapLabels_UpdateMapLabels()
    elseif msg == "icons" or msg == "icon" then
        MapLabelsConfig.displayMode = "icons"
        print("|cff00ff00MapLabels:|r Icons only mode!")
        MapLabels_UpdateMapLabels()
    elseif msg == "labels" or msg == "label" then
        MapLabelsConfig.displayMode = "labels"
        print("|cff00ff00MapLabels:|r Labels only mode!")
        MapLabels_UpdateMapLabels()
    elseif msg == "toggle" then
        -- Cycle through modes: labels -> icons -> both -> labels
        if MapLabelsConfig.displayMode == "labels" then
            MapLabelsConfig.displayMode = "icons"
        elseif MapLabelsConfig.displayMode == "icons" then
            MapLabelsConfig.displayMode = "both"
        else
            MapLabelsConfig.displayMode = "labels"
        end
        print("|cff00ff00MapLabels:|r Switched to " .. MapLabelsConfig.displayMode .. " mode!")
        MapLabels_UpdateMapLabels()
    else
        print("|cff00ff00MapLabels Commands:|r")
        print("/ml labels - Show labels only")
        print("/ml icons - Show icons only")
        print("/ml both - Show icons with labels")
        print("/ml toggle - Cycle through modes")
        print("/mlc <name> - Capture coordinates with name")
        print("/mll - Capture coordinates only")
    end
end

-- Register slash commands
SLASH_MAPLABELS1 = "/maplabels"
SLASH_MAPLABELS2 = "/ml"
SlashCmdList["MAPLABELS"] = HandleSlashCommand

SLASH_MAPLABELSCAPTURE1 = "/mlc"
SLASH_MAPLABELSCAPTURE2 = "/capture"
SlashCmdList["MAPLABELSCAPTURE"] = HandleCaptureCommand

SLASH_MAPLABELSCOORDS1 = "/mll"
SLASH_MAPLABELSCOORDS2 = "/coords"
SlashCmdList["MAPLABELSCOORDS"] = HandleCoordsOnlyCommand
