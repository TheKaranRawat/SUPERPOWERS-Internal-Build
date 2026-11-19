-------------------------------------------------
-- EventBanner.lua
-- Sleek slide-in banner for big world events.
--
-- Design notes (performance + multiplayer):
--  * 100% client-side UI. It only READS game state. It never changes
--    gameplay, never uses GameEvents/LuaEvents/network calls -> cannot desync.
--  * No per-frame work while idle. The update callback is only registered
--    while a banner is on screen and is cleared afterwards.
--  * Detection is a tiny poll once per turn (a few hash lookups per
--    watched event per major civ). An event is dropped from the watch list
--    the moment someone wins it, so the work shrinks over time.
--  * Every client sees the same game state, so every client independently
--    reaches the same "first civ" result. Ties on the same turn go to the
--    lowest player ID.
--  * The first poll after load is silent, so loading a save never replays
--    old events.
--  * Winners are found once, globally. Each viewer (active player) is then
--    told about them separately, so hotseat players each get their own
--    banners, filtered by what THEY have met.
-------------------------------------------------
include("IconSupport")

-------------------------------------------------
-- CONFIG
-------------------------------------------------
local SLIDE_TIME      = 0.35   -- seconds for slide in / out (match Speed in the XML)
local HOLD_TIME       = 5.0    -- seconds the banner stays fully shown
local GAP_TIME        = 0.40   -- pause between queued banners
local MAX_QUEUE       = 6      -- oldest queued banner is dropped beyond this
local CIV_ICON_SIZE   = 128  -- must match the CivIcon image sizes in EventBanner.xml
local EVENT_ICON_SIZE = 128  -- unit/building/tech icon size (must match EventIcon in the XML; falls back to 64 if the atlas has no 128)

-- Civs you have not met are still announced, but shown anonymously:
-- the name becomes UNKNOWN_CIV_NAME and the civ icon becomes the "?" icon.
-- true  = reveal the real civ even if you haven't met them.
-- false = hide unmet civs behind "Unknown Civ" (default).
local REVEAL_UNMET_CIVS = false
local UNKNOWN_CIV_NAME  = "Unknown Civ"

-------------------------------------------------
-- EVENTS  (edit this list)
--
--  kind     "YEAR"     key = nil,  year = number         (fires once when game year >= year)
--           "TECH"     key = "TECH_xxx"                  (first civ to know the tech)
--           "UNIT"     key = "UNIT_xxx"                  (first civ to own one; matches by unit class)
--           "BUILDING" key = "BUILDING_xxx"              (first civ to have one; matches by building class)
--  icon     optional custom .dds file name. Leave it out on UNIT / BUILDING / TECH
--           events to show the game's own icon of that unit / building / tech.
--  title    plain text or a TXT_KEY. {1_Civ} is replaced by the civ's short name.
--  desc     plain text or a TXT_KEY. {1_Civ} works here too. Keep it ~80 chars (2 lines).
--  showCiv  false hides the civ icon (YEAR events never show one)
-------------------------------------------------
local EVENTS = {
    { id = "ZERO_AD",
      kind = "YEAR", year = 0,
      icon = "EB_ZeroAD.dds",
      title = "The Dawn of a New Age",
      desc  = "The world has reached 0 AD." },

    { id = "TECH_PHILOSOPHY",
      kind = "TECH", key = "TECH_PHILOSOPHY",       -- custom .dds image
      icon = "EB_Philosophy.dds",
      title = "Philosophy Discovered",
      desc  = "{1_Civ} is the first to master philosophy." },

    { id = "UNIT_KNIGHT",
      kind = "UNIT", key = "UNIT_KNIGHT",           -- shows the Knight's own icon
      title = "Knights Take the Field",
      desc  = "{1_Civ} fields the first armored knights." },

      { id = "UNIT_DREADNOUGHT",
      kind = "UNIT", key = "UNIT_DREADNOUGHT",           -- shows the Knight's own icon
      title = "Floating Fortresses Sighted",
      desc  = "{1_Civ} have begun construction of a new class of naval behemoths. According to reports sailors nationwide are refusing to report for duty." },

    { id = "BUILDING_PYRAMID",
      kind = "BUILDING", key = "BUILDING_PYRAMID", -- shows the Pyramids' own icon
      title = "The Pyramids Are Complete",
      desc  = "{1_Civ} has raised a wonder for the ages." },
}

-------------------------------------------------
-- STATE
-------------------------------------------------
local watching  = {}      -- events nobody has won yet
local winners   = {}      -- events that have been won: { ev = ev, pid = winnerID or nil }
local old       = {}      -- events already won when the game was loaded (never announced)
local seenBy    = {}      -- activePlayerID -> { [ev] = true } already announced / skipped for them
local queue     = {}      -- banners waiting to be shown
local baselined = false   -- first poll is silent
local state     = "IDLE"  -- IDLE | IN | HOLD | OUT | GAP
local timer     = 0

-------------------------------------------------
-- SETUP: resolve database keys once
-------------------------------------------------
local function ResolveEvents()
    watching = {}
    for _, ev in ipairs(EVENTS) do
        local ok = true
        if ev.kind == "TECH" then
            ev.ref  = GameInfoTypes[ev.key]
            ev.info = GameInfo.Technologies[ev.key]
            ok = (ev.ref ~= nil)
        elseif ev.kind == "UNIT" then
            local info = GameInfo.Units[ev.key]
            ev.info = info
            ev.ref  = info and GameInfoTypes[info.Class] or nil
            ok = (ev.ref ~= nil)
        elseif ev.kind == "BUILDING" then
            local info = GameInfo.Buildings[ev.key]
            ev.info = info
            ev.ref  = info and GameInfoTypes[info.BuildingClass] or nil
            ok = (ev.ref ~= nil)
        elseif ev.kind == "YEAR" then
            ok = (ev.year ~= nil)
        else
            ok = false
        end

        if ok then
            table.insert(watching, ev)
        else
            print("EventBanner: skipping event '" .. tostring(ev.id) .. "' (bad kind/key)")
        end
    end
end

-------------------------------------------------
-- DETECTION (read-only)
-------------------------------------------------
local function PlayerHas(ev, pPlayer)
    local kind = ev.kind
    if kind == "TECH" then
        return Teams[pPlayer:GetTeam()]:IsHasTech(ev.ref)
    elseif kind == "UNIT" then
        return pPlayer:GetUnitClassCount(ev.ref) > 0
    elseif kind == "BUILDING" then
        return pPlayer:GetBuildingClassCount(ev.ref) > 0
    end
    return false
end

-- returns the lowest-ID major civ that has it, or nil
local function FindFirst(ev)
    for pid = 0, GameDefines.MAX_MAJOR_CIVS - 1 do
        local pPlayer = Players[pid]
        if pPlayer and pPlayer:IsAlive() and PlayerHas(ev, pPlayer) then
            return pid
        end
    end
    return nil
end

-- true if the viewer is allowed to see WHICH civ did it (themselves, same team, or met)
local function CanSee(activePlayerID, pid)
    if REVEAL_UNMET_CIVS then return true end
    local myTeam    = Players[activePlayerID]:GetTeam()
    local theirTeam = Players[pid]:GetTeam()
    return myTeam == theirTeam or Teams[myTeam]:IsHasMet(theirTeam)
end

-------------------------------------------------
-- BANNER: populate + animate
-------------------------------------------------
local function Txt(str, civName)
    if str == nil then return "" end
    return Locale.ConvertTextKey(str, civName or "")
end

local function PlayerColorVec(pid, which)
    local colorSet = GameInfo.PlayerColors[Players[pid]:GetPlayerColor()]
    local c = GameInfo.Colors[colorSet[which]]
    return Vector4(c.Red, c.Green, c.Blue, 1)
end

-- "?" placeholder for civs the viewer hasn't met. The unknown-civ icon is the game's
-- CIVILIZATION_RANDOM entry (index 22 of CIV_COLOR_ATLAS), a complete round badge,
-- so the BG and shadow images are hidden.
local function SetUnknownCivIcon()
    local index, atlas = 22, "CIV_COLOR_ATLAS"
    local info = GameInfo.Civilizations["CIVILIZATION_RANDOM"]
    if info and info.PortraitIndex and info.IconAtlas then
        index, atlas = info.PortraitIndex, info.IconAtlas
    end
    Controls.CivIconBG:SetHide(true)
    Controls.CivIconShadow:SetHide(true)
    pcall(function() Controls.CivIcon:SetColor(Vector4(1, 1, 1, 1)) end)   -- clear any civ tint
    IconHookup(index, CIV_ICON_SIZE, atlas, Controls.CivIcon)
    pcall(function() Controls.Accent:SetColor(Vector4(0.6, 0.66, 0.76, 1)) end)
end

-- Round civ flag via the game's own CivIconHookup (same call shape the base UI uses).
local function SetCivIcon(pid)
    Controls.CivIconBG:SetHide(false)
    Controls.CivIconShadow:SetHide(false)
    CivIconHookup(pid, CIV_ICON_SIZE, Controls.CivIcon, Controls.CivIconBG, Controls.CivIconShadow, false, true)

    -- accent bar takes the civ's primary colour (falls back to gold if unavailable)
    if not pcall(function() Controls.Accent:SetColor(PlayerColorVec(pid, "PrimaryColor")) end) then
        pcall(function() Controls.Accent:SetColor(Vector4(1, 0.82, 0.47, 1)) end)
    end
end

local function Populate(item)
    local ev  = item.ev
    local pid = item.pid
    local civName = ""
    if pid and item.unknown then
        civName = UNKNOWN_CIV_NAME
    elseif pid then
        local civInfo = GameInfo.Civilizations[Players[pid]:GetCivilizationType()]
        civName = Locale.ConvertTextKey(civInfo.ShortDescription)
    end

    Controls.Headline:SetText(Txt(ev.title, civName))
    Controls.Desc:SetText(Txt(ev.desc, civName))

    -- Left icon: a custom .dds wins if you set `icon`; otherwise UNIT / BUILDING /
    -- TECH events automatically show the game's own icon for that item.
    local iconShown = false
    if ev.icon then
        pcall(function() Controls.EventIcon:SetTextureOffsetVal(0, 0) end)   -- clear any atlas offset
        Controls.EventIcon:SetTexture(ev.icon)
        Controls.EventIcon:SetSizeVal(EVENT_ICON_SIZE, EVENT_ICON_SIZE)
        iconShown = true
    elseif ev.info and ev.info.IconAtlas and ev.info.PortraitIndex then
        local size = EVENT_ICON_SIZE
        iconShown = IconHookup(ev.info.PortraitIndex, size, ev.info.IconAtlas, Controls.EventIcon)
        if not iconShown then            -- atlas has no icon at this size: try 64
            size = 64
            iconShown = IconHookup(ev.info.PortraitIndex, size, ev.info.IconAtlas, Controls.EventIcon)
        end
        Controls.EventIcon:SetSizeVal(size, size)
    end
    Controls.EventIcon:SetHide(not iconShown)

    if pid and ev.showCiv ~= false then
        Controls.CivIconBox:SetHide(false)
        if item.unknown then
            SetUnknownCivIcon()
        else
            SetCivIcon(pid)
        end
    else
        Controls.CivIconBox:SetHide(true)
        pcall(function() Controls.Accent:SetColor(Vector4(1, 0.82, 0.47, 1)) end)
    end
end

local OnUpdate -- forward declaration

local function ShowNext()
    local item = table.remove(queue, 1)
    if not item then
        state = "IDLE"
        ContextPtr:ClearUpdate()            -- zero cost while idle
        Controls.BannerAlpha:SetHide(true)
        return
    end

    local ok, err = pcall(Populate, item)
    if not ok then
        print("EventBanner populate error: " .. tostring(err))
        return ShowNext()                   -- skip the broken item, try the next one
    end
    Controls.BannerAlpha:SetHide(false)
    Controls.BannerAlpha:SetToBeginning()
    Controls.BannerSlide:SetToBeginning()
    Controls.BannerAlpha:Play()
    Controls.BannerSlide:Play()

    state = "IN"
    timer = SLIDE_TIME
    ContextPtr:SetUpdate(OnUpdate)
end

-- Runs only while a banner is active.
OnUpdate = function(dt)
    timer = timer - (dt or 0.033)
    if timer > 0 then return end

    if state == "IN" then
        state = "HOLD"
        timer = HOLD_TIME
    elseif state == "HOLD" then
        state = "OUT"
        timer = SLIDE_TIME
        Controls.BannerAlpha:Reverse()
        Controls.BannerSlide:Reverse()
    elseif state == "OUT" then
        state = "GAP"
        timer = GAP_TIME
        Controls.BannerAlpha:SetHide(true)
    elseif state == "GAP" then
        ShowNext()
    end
end

local function Enqueue(ev, pid, unknown)
    if #queue >= MAX_QUEUE then
        table.remove(queue, 1)              -- drop the oldest
    end
    table.insert(queue, { ev = ev, pid = pid, unknown = unknown })
    if state == "IDLE" then
        ShowNext()
    end
end

-------------------------------------------------
-- POLL (once per turn)
-------------------------------------------------
local function Poll()
    local active = Game.GetActivePlayer()
    if active == nil or active < 0 or Players[active] == nil then return end

    -- 1) Find winners. Shared by every viewer; the watch list shrinks as events are won.
    if #watching > 0 then
        local year = Game.GetGameTurnYear()
        local stillWatching = {}
        for _, ev in ipairs(watching) do
            local fired, pid = false, nil
            if ev.kind == "YEAR" then
                fired = (year >= ev.year)
            else
                pid = FindFirst(ev)
                fired = (pid ~= nil)
            end

            if fired then
                winners[#winners + 1] = { ev = ev, pid = pid }
                if not baselined then old[ev] = true end   -- already true at load: stay silent
            else
                stillWatching[#stillWatching + 1] = ev
            end
        end
        watching = stillWatching
    end
    baselined = true

    -- 2) Tell THIS viewer about anything they haven't heard yet (per-viewer, so hotseat works).
    local seen = seenBy[active]
    if not seen then
        seen = {}
        seenBy[active] = seen
    end
    for _, w in ipairs(winners) do
        local ev = w.ev
        if not seen[ev] and not old[ev] then
            seen[ev] = true
            -- everyone gets the banner; unmet civs are shown anonymously
            Enqueue(ev, w.pid, w.pid ~= nil and not CanSee(active, w.pid))
        end
    end
end

local function SafePoll()
    local ok, err = pcall(Poll)
    if not ok then print("EventBanner poll error: " .. tostring(err)) end
end

-------------------------------------------------
-- HOOKUP
-------------------------------------------------
local function OnActivePlayerChanged()
    -- hotseat / observer switch: clear anything on screen
    queue = {}
    state = "IDLE"
    ContextPtr:ClearUpdate()
    Controls.BannerAlpha:SetHide(true)
end

ResolveEvents()
Controls.BannerAlpha:SetHide(true)

Events.ActivePlayerTurnStart.Add(SafePoll)
Events.LoadScreenClose.Add(SafePoll)                 -- silent baseline after loading a save / new game
Events.GameplaySetActivePlayer.Add(OnActivePlayerChanged)