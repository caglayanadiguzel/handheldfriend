-- HandheldFriend_UI.lua
-- In-game settings panel (Options → AddOns → HandheldFriend)

-- ============================================================
-- Helpers
-- ============================================================

-- Returns a list of Edit Mode layout names from the current character.
local function GetLayoutNames()
    local names = {}
    local ok, result = pcall(C_EditMode.GetLayouts)
    if ok and result and result.layouts then
        for _, layout in ipairs(result.layouts) do
            table.insert(names, layout.layoutName)
        end
    end
    return names
end

-- Creates a thin horizontal separator line anchored below `anchor`.
local function MakeSeparator(parent, anchor, yOffset)
    local sep = parent:CreateTexture(nil, "ARTWORK")
    sep:SetHeight(1)
    sep:SetColorTexture(0.4, 0.4, 0.4, 1)
    sep:SetPoint("TOPLEFT",  anchor, "BOTTOMLEFT",  0,   yOffset)
    sep:SetWidth(560)
    return sep
end

-- Creates a section header FontString anchored below `anchor`.
local function MakeHeader(parent, anchor, yOffset, text)
    local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontNormal")
    fs:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", 0, yOffset)
    fs:SetText(text)
    return fs
end

-- Creates small body text anchored below `anchor`, with optional indent.
local function MakeNote(parent, anchor, yOffset, text, indent)
    local fs = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
    fs:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", indent or 0, yOffset)
    fs:SetText(text)
    fs:SetJustifyH("LEFT")
    fs:SetTextColor(0.75, 0.75, 0.75)
    return fs
end

-- ============================================================
-- Panel Frame
-- ============================================================

local panel = CreateFrame("Frame")

-- ========== Title ==========
local titleText = panel:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
titleText:SetPoint("TOPLEFT", 16, -16)
titleText:SetText("HandheldFriend")

local subtitleText = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
subtitleText:SetPoint("TOPLEFT", titleText, "BOTTOMLEFT", 0, -4)
subtitleText:SetText("Adjusts Edit Mode layout and action bars automatically for handheld or PC.")
subtitleText:SetJustifyH("LEFT")
subtitleText:SetTextColor(0.75, 0.75, 0.75)

-- ========== Status ==========
local sep1 = MakeSeparator(panel, subtitleText, -14)

local statusHeader = MakeHeader(panel, sep1, -12, "Status")

local statusLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
statusLabel:SetPoint("TOPLEFT", statusHeader, "BOTTOMLEFT", 8, -8)
statusLabel:SetText("Current mode:")

local statusValue = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
statusValue:SetPoint("LEFT", statusLabel, "RIGHT", 8, 0)

-- ========== Detection Mode ==========
local sep2 = MakeSeparator(panel, statusLabel, -14)

local detectionHeader = MakeHeader(panel, sep2, -12, "Detection Mode")
local detectionNote   = MakeNote(panel, detectionHeader, -4,
    "Auto uses gamepad detection (ROG Ally built-in controller).\n" ..
    "Force options let you override the automatic detection.", 8)

local detectionDD = CreateFrame("Frame", "HandheldFriendDetectionDD", panel, "UIDropDownMenuTemplate")
detectionDD:SetPoint("TOPLEFT", detectionNote, "BOTTOMLEFT", -16, -4)
UIDropDownMenu_SetWidth(detectionDD, 210)

local DETECTION_OPTIONS = {
    { text = "Auto (Gamepad Detection)", value = "auto" },
    { text = "Force Handheld",           value = "handheld" },
    { text = "Force PC",                 value = "pc" },
}

UIDropDownMenu_Initialize(detectionDD, function(self, level)
    for _, opt in ipairs(DETECTION_OPTIONS) do
        local info    = UIDropDownMenu_CreateInfo()
        info.text     = opt.text
        info.value    = opt.value
        info.checked  = HandheldFriendDB and (HandheldFriendDB.mode == opt.value)
        info.func     = function(btn)
            HandheldFriendDB.mode = btn.value
            UIDropDownMenu_SetText(detectionDD, btn:GetText())
            CloseDropDownMenus()
        end
        UIDropDownMenu_AddButton(info)
    end
end)

-- ========== Layout Settings ==========
local sep3 = MakeSeparator(panel, detectionDD, -8)

local layoutHeader = MakeHeader(panel, sep3, -12, "Layout Settings")
local layoutNote   = MakeNote(panel, layoutHeader, -4,
    "Choose which Edit Mode preset to use for each device.\n" ..
    "The dropdown lists all presets saved in your Edit Mode.", 8)

-- Handheld layout
local handheldLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
handheldLabel:SetPoint("TOPLEFT", layoutNote, "BOTTOMLEFT", 8, -10)
handheldLabel:SetText("Handheld Layout")

local handheldDD = CreateFrame("Frame", "HandheldFriendHandheldDD", panel, "UIDropDownMenuTemplate")
handheldDD:SetPoint("TOPLEFT", handheldLabel, "BOTTOMLEFT", -16, -2)
UIDropDownMenu_SetWidth(handheldDD, 210)

UIDropDownMenu_Initialize(handheldDD, function(self, level)
    for _, name in ipairs(GetLayoutNames()) do
        local info   = UIDropDownMenu_CreateInfo()
        info.text    = name
        info.value   = name
        info.checked = HandheldFriendDB and (HandheldFriendDB.handheldLayout == name)
        info.func    = function(btn)
            HandheldFriendDB.handheldLayout = btn.value
            UIDropDownMenu_SetText(handheldDD, btn.value)
            CloseDropDownMenus()
        end
        UIDropDownMenu_AddButton(info)
    end
end)

-- PC layout
local pcLabel = panel:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
pcLabel:SetPoint("TOPLEFT", handheldDD, "BOTTOMLEFT", 16, -10)
pcLabel:SetText("PC Layout")

local pcDD = CreateFrame("Frame", "HandheldFriendPCDD", panel, "UIDropDownMenuTemplate")
pcDD:SetPoint("TOPLEFT", pcLabel, "BOTTOMLEFT", -16, -2)
UIDropDownMenu_SetWidth(pcDD, 210)

UIDropDownMenu_Initialize(pcDD, function(self, level)
    for _, name in ipairs(GetLayoutNames()) do
        local info   = UIDropDownMenu_CreateInfo()
        info.text    = name
        info.value   = name
        info.checked = HandheldFriendDB and (HandheldFriendDB.pcLayout == name)
        info.func    = function(btn)
            HandheldFriendDB.pcLayout = btn.value
            UIDropDownMenu_SetText(pcDD, btn.value)
            CloseDropDownMenus()
        end
        UIDropDownMenu_AddButton(info)
    end
end)

-- ========== Action Bars ==========
local sep4 = MakeSeparator(panel, pcDD, -8)

local abHeader = MakeHeader(panel, sep4, -12, "Action Bars")
local abNote   = MakeNote(panel, abHeader, -4,
    "Action Bars 2–8 are automatically turned OFF in Handheld mode\n" ..
    "and ON in PC mode. This is not configurable.", 8)

-- ========== Apply Button ==========
local sep5 = MakeSeparator(panel, abNote, -14)

local applyBtn = CreateFrame("Button", nil, panel, "GameMenuButtonTemplate")
applyBtn:SetPoint("TOPLEFT", sep5, "BOTTOMLEFT", 0, -14)
applyBtn:SetSize(140, 30)
applyBtn:SetText("Apply Now")
applyBtn:SetScript("OnClick", function()
    HandheldFriend.Apply()
end)

local applyNote = MakeNote(panel, applyBtn, -6,
    "Applies settings immediately. Also applies automatically on login and UI reload.", 0)

-- ============================================================
-- Status Updater
-- ============================================================

local DETECTION_LABELS = {
    auto     = "Auto (Gamepad Detection)",
    handheld = "Force Handheld",
    pc       = "Force PC",
}

local function UpdateStatus()
    if not HandheldFriendDB then return end

    local isHandheld = HandheldFriend.IsHandheld()
    local mode = HandheldFriendDB.mode

    local modeText  = isHandheld and "Handheld" or "PC"
    local qualifier = (mode == "auto") and " (Auto-detected)" or " (Forced)"
    local color     = isHandheld and "|cff00ff00" or "|cff00aaff"

    statusValue:SetText(color .. modeText .. "|r" .. qualifier)

    UIDropDownMenu_SetText(detectionDD, DETECTION_LABELS[mode] or DETECTION_LABELS.auto)
    UIDropDownMenu_SetText(handheldDD,  HandheldFriendDB.handheldLayout or "")
    UIDropDownMenu_SetText(pcDD,        HandheldFriendDB.pcLayout       or "")
end

-- Refresh status and dropdown texts every time the panel is opened.
panel:SetScript("OnShow", UpdateStatus)

-- ============================================================
-- Register with the Settings system (Options → AddOns)
-- ============================================================

local category = Settings.RegisterCanvasLayoutCategory(panel, "HandheldFriend")
category.ID = "HandheldFriend"
Settings.RegisterAddOnCategory(category)
