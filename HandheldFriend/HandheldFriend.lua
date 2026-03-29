-- HandheldFriend
-- Core: detection, layout switching, action bar control.

HandheldFriend = HandheldFriend or {}
local HF = HandheldFriend

-- ============================================================
-- Defaults
-- ============================================================

local DEFAULTS = {
    mode           = "auto",          -- "auto" | "handheld" | "pc"
    handheldLayout = "Rog Ally",
    pcLayout       = "ASUS Mobil Ekran",
}

local pendingApply = false

-- ============================================================
-- Saved Variables
-- ============================================================

local function InitDB()
    if not HandheldFriendDB then
        HandheldFriendDB = {}
    end
    for k, v in pairs(DEFAULTS) do
        if HandheldFriendDB[k] == nil then
            HandheldFriendDB[k] = v
        end
    end
end

-- ============================================================
-- Detection
-- ============================================================

-- Returns true if we should be in handheld mode.
-- In "auto" mode, a connected gamepad = handheld.
-- Note: Controller Support must be enabled in WoW Game Settings
--       for C_GamePad to detect the ROG Ally's built-in gamepad.
function HF.IsHandheld()
    if not HandheldFriendDB then return false end
    local mode = HandheldFriendDB.mode
    if mode == "handheld" then return true end
    if mode == "pc"       then return false end

    -- Auto: check for connected gamepad devices
    local ok, devices = pcall(C_GamePad.GetAllDeviceIDs)
    if ok and devices then
        return #devices > 0
    end
    return false
end

-- ============================================================
-- Edit Mode Layout
-- ============================================================

local function GetLayoutIndex(name)
    local ok, result = pcall(C_EditMode.GetLayouts)
    if not ok or not result or not result.layouts then return nil end
    for i, layout in ipairs(result.layouts) do
        if layout.layoutName == name then return i end
    end
    return nil
end

local function ApplyLayout(name)
    if not name or name == "" then return end
    local index = GetLayoutIndex(name)
    if index then
        C_EditMode.SetActiveLayout(index)
    else
        print("|cffff6600HandheldFriend:|r Layout \"" .. name .. "\" not found. Check your Edit Mode profiles.")
    end
end

-- ============================================================
-- Action Bars (2-8)
-- ============================================================

-- Uses the Settings API introduced in Dragonflight/TWW.
-- Old SetCVar approach no longer works for action bars in retail.
local function SetActionBars(enabled)
    for i = 2, 8 do
        pcall(Settings.SetValue, "PROXY_SHOW_ACTIONBAR_" .. i, enabled)
    end
end

-- ============================================================
-- Apply
-- ============================================================

function HF.Apply()
    if InCombatLockdown() then
        print("|cffff6600HandheldFriend:|r In combat — settings will apply when combat ends.")
        pendingApply = true
        return
    end

    local isHandheld = HF.IsHandheld()

    if isHandheld then
        ApplyLayout(HandheldFriendDB.handheldLayout)
        SetActionBars(false)
        print("|cff00ff00HandheldFriend:|r Handheld mode applied. Layout: \"" .. (HandheldFriendDB.handheldLayout or "none") .. "\"")
    else
        ApplyLayout(HandheldFriendDB.pcLayout)
        SetActionBars(true)
        print("|cff00ff00HandheldFriend:|r PC mode applied. Layout: \"" .. (HandheldFriendDB.pcLayout or "none") .. "\"")
    end
end

-- ============================================================
-- Events
-- ============================================================

local eventFrame = CreateFrame("Frame", "HandheldFriendEventFrame", UIParent)
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")

eventFrame:SetScript("OnEvent", function(self, event, ...)
    if event == "ADDON_LOADED" then
        local addonName = ...
        if addonName == "HandheldFriend" then
            InitDB()
            print("|cff00ff00HandheldFriend|r v1.0.0 loaded. Type |cffffd700/handheld|r for commands.")
        end

    elseif event == "PLAYER_ENTERING_WORLD" then
        -- Only apply on fresh login or UI reload, not every zone change.
        local isInitialLogin, isReloadingUi = ...
        if isInitialLogin or isReloadingUi then
            HF.Apply()
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Combat ended — apply if we had a deferred request.
        if pendingApply then
            pendingApply = false
            HF.Apply()
        end
    end
end)

-- ============================================================
-- Slash Commands
-- ============================================================

SLASH_HANDHELDFRIEND1 = "/handheld"

SlashCmdList["HANDHELDFRIEND"] = function(msg)
    msg = strtrim(msg:lower())

    if msg == "handheld" then
        HandheldFriendDB.mode = "handheld"
        print("|cff00ff00HandheldFriend:|r Forced to Handheld mode.")
        HF.Apply()

    elseif msg == "pc" then
        HandheldFriendDB.mode = "pc"
        print("|cff00ff00HandheldFriend:|r Forced to PC mode.")
        HF.Apply()

    elseif msg == "auto" then
        HandheldFriendDB.mode = "auto"
        print("|cff00ff00HandheldFriend:|r Switched to Auto-detect.")
        HF.Apply()

    elseif msg == "apply" then
        HF.Apply()

    elseif msg == "debug" then
        print("|cff00ff00HandheldFriend|r — Debug Info:")

        -- DB state
        local db = HandheldFriendDB
        if not db then
            print("  SavedVariables: |cffff0000NOT LOADED|r")
            return
        end
        print("  Mode setting:    " .. tostring(db.mode))
        print("  Handheld layout: " .. tostring(db.handheldLayout))
        print("  PC layout:       " .. tostring(db.pcLayout))

        -- Gamepad detection
        local gpEnabled = C_GamePad.IsEnabled()
        print("  Gamepad support: " .. (gpEnabled and "|cff00ff00enabled|r" or "|cffff6600disabled|r (enable in Game Settings)"))

        local ok, devices = pcall(C_GamePad.GetAllDeviceIDs)
        if ok and devices then
            print("  Gamepad devices: " .. #devices .. " connected")
            for i, id in ipairs(devices) do
                local info = C_GamePad.GetDeviceRawState(id)
                local name = (info and info.name) or tostring(id)
                print("    [" .. i .. "] " .. name)
            end
        else
            print("  Gamepad devices: |cffff0000error reading|r")
        end

        -- IsHandheld result
        print("  IsHandheld():    " .. tostring(HF.IsHandheld()))

        -- Edit Mode layouts
        local okL, result = pcall(C_EditMode.GetLayouts)
        if okL and result and result.layouts then
            print("  Edit Mode layouts (" .. #result.layouts .. " total):")
            for i, layout in ipairs(result.layouts) do
                local active = (result.activeLayout == i) and " |cffffd700[active]|r" or ""
                print("    [" .. i .. "] " .. layout.layoutName .. active)
            end
        else
            print("  Edit Mode layouts: |cffff0000error reading|r")
        end

    else
        print("|cff00ff00HandheldFriend|r — Commands:")
        print("  /handheld auto      — Auto-detect via gamepad")
        print("  /handheld handheld  — Force handheld mode")
        print("  /handheld pc        — Force PC mode")
        print("  /handheld apply     — Re-apply settings now")
        print("  /handheld debug     — Show debug info")
    end
end
