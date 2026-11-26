-- ===== Configuration =====
local HOLD_DURATION      = 3.0    -- seconds fully visible before auto-close (0 = never auto-close)
local FADE_IN_DURATION   = 1.2   -- seconds
local FADE_OUT_DURATION  = 0.25
local SLIDE_IN_DURATION  = 0.45
local SLIDE_OUT_DURATION = 0.20
local SLIDE_OFFSET_X     = 0      -- pixels the box travels horizontally (negative = from the left)
local SLIDE_OFFSET_Y     = -100    -- pixels the box travels vertically (negative = from above)

local WM_XBUTTONDOWN = 523
local MIN_DURATION   = 0.01

local fadeRoot  = Controls.FadeRoot
local box       = Controls.PopupGrid
local popupText = Controls.PopupText
local rButtonUp = MouseEvents.RButtonUp

-- progress: 0 = hidden/offset, 1 = fully shown
local fadeP, slideP = 0, 0
local target = 0          -- 1 = showing, 0 = closing
local holdLeft = 0
local animating = false

local function Apply()
    fadeRoot:SetAlpha(fadeP)
    local k = 1 - slideP
    box:SetOffsetVal(k * SLIDE_OFFSET_X, k * SLIDE_OFFSET_Y)
end

local function ClosePopup()
    if target == 0 or ContextPtr:IsHidden() then return end
    target = 0
    animating = true
end

local function OnUpdate(dt)
    if not animating then return end

    if target == 1 then
        if fadeP < 1 or slideP < 1 then
            fadeP  = math.min(1, fadeP  + dt / math.max(FADE_IN_DURATION,  MIN_DURATION))
            slideP = math.min(1, slideP + dt / math.max(SLIDE_IN_DURATION, MIN_DURATION))
            Apply()
        elseif HOLD_DURATION > 0 then
            holdLeft = holdLeft - dt
            if holdLeft <= 0 then
                ClosePopup()
            end
        else
            animating = false
        end
    else
        fadeP  = math.max(0, fadeP  - dt / math.max(FADE_OUT_DURATION,  MIN_DURATION))
        slideP = math.max(0, slideP - dt / math.max(SLIDE_OUT_DURATION, MIN_DURATION))
        Apply()
        if fadeP == 0 and slideP == 0 then
            animating = false
            ContextPtr:SetHide(true)
        end
    end
end
ContextPtr:SetUpdate(OnUpdate)

local function ShowPopup(text)
    if not text then return end
    popupText:SetText(text)
    ContextPtr:SetHide(false)
    target = 1
    holdLeft = HOLD_DURATION
    animating = true
    Apply()
end
LuaEvents.TC_ShowGreatestCityPopup.Add(ShowPopup)

local function HideImmediately()
    animating = false
    target = 0
    fadeP, slideP = 0, 0
    Apply()
    ContextPtr:SetHide(true)
end

local function OnInput(uiMsg, wParam, lParam)
    if ContextPtr:IsHidden() then return false end

    if uiMsg == rButtonUp then
        ClosePopup()
        return true
    elseif uiMsg == WM_XBUTTONDOWN then
        local button = math.floor(wParam / 65536) % 65536
        if button == 1 or button == 2 or wParam == 1 or wParam == 2 then
            ClosePopup()
            return true
        end
    end
    return false
end
ContextPtr:SetInputHandler(OnInput)

Events.GameplaySetActivePlayer.Add(HideImmediately)
Events.LoadScreenClose.Add(HideImmediately)

HideImmediately()