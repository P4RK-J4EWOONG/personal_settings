-- -------------------------------------------------------------------------- --
--                                   Styles                                   --
-- -------------------------------------------------------------------------- --
hs.hints.fontName = "Galmuri11"
hs.hints.fontSize = 14
hs.hints.showTitleThresh = 0
hs.hints.iconAlpha = 1

hs.alert.defaultStyle.textFont = "Galmuri11"
hs.alert.defaultStyle.textColor = { white = 1, alpha = 1 }
hs.alert.defaultStyle.textSize = 14
hs.alert.defaultStyle.radius = 4
hs.alert.defaultStyle.padding = 20

hs.alert.show("<Hammerspoon>\n다시 설정하는 중...")

-- -------------------------------------------------------------------------- --
--                   Pressing ESC changes Korean to English                   --
-- -------------------------------------------------------------------------- --
local inputEnglish = "com.apple.keylayout.ABC"
local esc_bind

function back_to_eng()
	local inputSource = hs.keycodes.currentSourceID()
	if not (inputSource == inputEnglish) then
		hs.keycodes.currentSourceID(inputEnglish)
	end
	esc_bind:disable()
	hs.eventtap.keyStroke({}, 'escape')
	esc_bind:enable()
end
esc_bind = hs.hotkey.new({}, 'escape', back_to_eng):enable()

-- -------------------------------------------------------------------------- --
--    Change color at the top of the screen when changing language settings   --
-- -------------------------------------------------------------------------- --
local boxes = {}
local inputEnglish = "com.apple.keylayout.ABC"
local box_height = 23
local box_alpha = 0.35

local GREEN = hs.drawing.color.osx_green
local RED = hs.drawing.color.osx_red
local YELLOW = hs.drawing.color.osx_yellow

hs.keycodes.inputSourceChanged(function()
    disable_show()
    if hs.keycodes.currentSourceID() ~= inputEnglish then
        enable_show()
    end
end)

function enable_show()
    reset_boxes()
    hs.fnutils.each(hs.screen.allScreens(), function(scr)
        local frame = scr:fullFrame()
        local box = newBox()
        draw_rectangle(box, frame.x, frame.y, frame.w, box_height, YELLOW)
        table.insert(boxes, box)
    end)
end

function disable_show()
    hs.fnutils.each(boxes, function(box)
        if box ~= nil then
            box:delete()
        end
    end)
    reset_boxes()
end

function newBox()
    return hs.drawing.rectangle(hs.geometry.rect(0,0,0,0))
end

function reset_boxes()
    boxes = {}
end

function draw_rectangle(target_draw, x, y, width, height, fill_color)
    target_draw:setSize(hs.geometry.rect(x, y, width, height))
    target_draw:setTopLeft(hs.geometry.point(x, y))

    target_draw:setFillColor(fill_color)
    target_draw:setFill(true)
    target_draw:setAlpha(box_alpha)
    target_draw:setLevel(hs.drawing.windowLevels.overlay)
    target_draw:setStroke(false)
    target_draw:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
    target_draw:show()
end

local shiftctrl = {"shift", "ctrl"}
local altctrlshift = {"alt", "ctrl", "shift"}

-- hs.hotkey.bind(shiftctrl, "w", function()
--     hs.alert.show("Hello World!")
-- end)


function sc_bind(key, func)
    hs.hotkey.bind(shiftctrl, key, func)
end

function acs_bind(key, func)
    hs.hotkey.bind(altctrlshift, key, func)
end


-- -------------------------------------------------------------------------- --
--                        Open the app with a shortcut                        --
-- -------------------------------------------------------------------------- --
function file_exists(path)
    local f=io.open(path,"r")
    if f~=nil then io.close(f) return true else return false end
    -- ~= is != in other languages
end

function launchApp(name)
    -- .. is concat string operator
    return function()
        path = "/Applications/" .. name .. ".app"
        if file_exists(path) then
            hs.application.launchOrFocus(path)
            return
        end
        path = "/System/Library/CoreServices/" .. name .. ".app"
        if file_exists(path) then
            hs.application.launchOrFocus(path)
            return
        end
        path = "/System/Applications/" .. name .. ".app"
        if file_exists(path) then
            hs.application.launchOrFocus(path)
            return
        end
    end
end

sc_bind("s", launchApp("Safari"))
sc_bind("a", launchApp("Visual Studio Code"))
sc_bind("z", launchApp("Finder"))
sc_bind("t", launchApp("iTerm"))

-- -------------------------------------------------------------------------- --
--                                Window Manger                               --
-- -------------------------------------------------------------------------- --
function positionWindow(x, y, w, h)
    return function()
        local win = hs.window.focusedWindow()
        if win == nil then return end
        local f = win:frame()
        local s = win:screen():frame()
        f.x = s.x + s.w * x
        f.y = s.y + s.h * y
        f.w = s.w * w
        f.h = s.h * h
        -- hs.alert.show(s)
        win:setFrame(f)
    end
end

hs.window.animationDuration = 0

sc_bind("[", positionWindow(0, 0, 1/2, 1))
sc_bind("]", positionWindow(1/2, 0, 1/2, 1))

sc_bind("1", positionWindow(0, 0, 1/2, 1/2))
sc_bind("2", positionWindow(1/2, 0, 1/2, 1/2))
sc_bind("3", positionWindow(0, 1/2, 1/2, 1/2))
sc_bind("4", positionWindow(1/2, 1/2, 1/2, 1/2))
sc_bind("\\", positionWindow(0, 0, 1, 1))

sc_bind("v", positionWindow(0, 0, 2/3, 1))
sc_bind("p", positionWindow(2/3, 0, 1/3, 1))

sc_bind("f", function()
    hs.window.focusedWindow():toggleFullScreen()
end)

sc_bind("c", function()
    hs.window.focusedWindow():centerOnScreen()
end)

-- grid based window functions

hs.grid.setGrid('12x6')
hs.grid.setMargins('0x0')

sc_bind("l", function()
    local win = hs.window.focusedWindow()
    if win == nil then return end
    local screen = win:screen()
    local sg = hs.grid.getGrid(screen)
    local g = hs.grid.get(win)
    if g.x + g.w == sg.w then
        g.x = g.x + 1
        g.w = g.w - 1
        hs.grid.set(win, g)
    else
        g.w = g.w + 1
        hs.grid.set(win, g)
    end
end)

sc_bind("h", function()
    local win = hs.window.focusedWindow()
    if win == nil then return end
    local screen = win:screen()
    local sg = hs.grid.getGrid(screen)
    local g = hs.grid.get(win)
    if g.x + g.w >= sg.w and g.x ~= 0 then
        g.x = g.x - 1
        g.w = g.w + 1
        hs.grid.set(win, g)
    else
        g.w = g.w - 1
        hs.grid.set(win, g)
    end
end)

sc_bind("j", function()
    local win = hs.window.focusedWindow()
    if win == nil then return end
    local screen = win:screen()
    local sg = hs.grid.getGrid(screen)
    local g = hs.grid.get(win)
    if g.y + g.h == sg.h then
        g.y = g.y + 1
        g.h = g.h - 1
        hs.grid.set(win, g)
    else
        g.h = g.h + 1
        hs.grid.set(win, g)
    end
end)

sc_bind("k", function()
    local win = hs.window.focusedWindow()
    if win == nil then return end
    local screen = win:screen()
    local sg = hs.grid.getGrid(screen)
    local g = hs.grid.get(win)
    if g.y + g.h >= sg.h and g.y ~= 0 then
        g.y = g.y - 1
        g.h = g.h + 1
        hs.grid.set(win, g)
    else
        g.h = g.h - 1
        hs.grid.set(win, g)
    end
end)

acs_bind("l", hs.grid.pushWindowRight)
acs_bind("h", hs.grid.pushWindowLeft)
acs_bind("j", hs.grid.pushWindowDown)
acs_bind("k", hs.grid.pushWindowUp)

-- -------------------------------------------------------------------------- --
--                           Focus on other Windows                           --
-- -------------------------------------------------------------------------- --

sc_bind("g", hs.hints.windowHints)
sc_bind("r", hs.reload)

-- -------------------------------------------------------------------------- --
--                         Move window to other spaces                        --
-- -------------------------------------------------------------------------- --

function getGoodFocusedWindow(nofull)
    local win = hs.window.focusedWindow()
    if not win or not win:isStandard() then return end
    if notfull and win:isFullScreen() then return end
    return win
end

function flashScreen(screen)
    local flash = hs.canvas.new(screen:fullFrame()):appendElements(
        {
            action = "fill",
            fillColor = {alpha = 0.25, red = 1},
            type = "rectangle"
        })
    flash:show()
    hs.timer.doAfter(.15,function () flash:delete() end)
end

function moveWindowOneSpace(dir, switch)
    local win = getGoodFocusedWindow(true)
    if not win then return end
    local screen = win:screen()
    local uuid = screen:getUUID()
    local userSpaces = nil
    for k,v in pairs(hs.spaces.allSpaces()) do
        userSpaces=v
        if k == uuid then break end
    end
    if not userSpaces then return end
    local thisSpace = hs.spaces.windowSpaces(win) -- first space win appears on
    if not thisSpace then return else thisSpace = thisSpace[1] end
    local last = nil
    local skipSpaces=0
for _, spc in ipairs(userSpaces) do
        if hs.spaces.spaceType(spc) ~="user" then -- skippable space
        skipSpaces = skipSpaces+1
        else
        if last and
            ((dir == "left" and spc == thisSpace) or
            (dir == "right" and last == thisSpace)) then
            local newSpace = (dir == "left" and last or spc)
            if switch then
            -- spaces.gotoSpace(newSpace)  -- also possible, invokes MC
            switchSpace(skipSpaces + 1, dir)
            end
            hs.spaces.moveWindowToSpace(win, newSpace)
            return
        end
        last = spc	 -- Haven't found it yet...
        skipSpaces = 0
        end
    end
    flashScreen(screen)   -- Shouldn't get here, so no space found
end


hs.hotkey.bind(altctrlshift, "[", nil, function()
    moveWindowOneSpace("left", false)
end)

hs.hotkey.bind(altctrlshift, "]", nil, function()
    moveWindowOneSpace("right", false)
end)

-- -------------------------------------------------------------------------- --
--                               RoundedCorners                               --
-- -------------------------------------------------------------------------- --
RoundedCorners = hs.loadSpoon("RoundedCorners")
RoundedCorners.radius = 15
RoundedCorners:start()

-- -------------------------------------------------------------------------- --
--                                  TimeFlow                                  --
-- -------------------------------------------------------------------------- --
FnMate = hs.loadSpoon("TimeFlow")

-- -------------------------------------------------------------------------- --
--                                  micCheck                                  --
-- -------------------------------------------------------------------------- --
function micCheck()
    if hs.audiodevice.defaultInputDevice():muted() then
        hs.audiodevice.defaultInputDevice():setMuted(false)

        hs.alert.show("🎙 마이크 : 켜짐")
    else
        hs.audiodevice.defaultInputDevice():setMuted(true)
        hs.alert.show("🎙 마이크 : 음소거")
    end
end

acs_bind("m", function()
    micCheck()
end)

-- -------------------------------------------------------------------------- --
--                                   VimMode                                  --
-- -------------------------------------------------------------------------- --
local VimMode = hs.loadSpoon("VimMode")
local vim = VimMode:new()

vim
    :disableForApp('Code')
    :disableForApp('zoom.us')
    :disableForApp('iTerm')
    :disableForApp('iTerm2')
    :disableForApp('Terminal')

vim:shouldDimScreenInNormalMode(false)
vim:shouldShowAlertInNormalMode(true)
vim:setAlertFont("Galmuri11")
vim:bindHotKeys({ enter = { {'ctrl'}, ';' } })

-- -------------------------------------------------------------------------- --
--                                   battery                                  --
-- -------------------------------------------------------------------------- --

-- Battery
local previousPowerSource = hs.battery.powerSource()

function minutesToHours(minutes)
    if minutes <= 0 then
        return "0:00";
    else
        hours = string.format("%d", math.floor(minutes / 60))
        mins = string.format("%02.f", math.floor(minutes - (hours * 60)))
        return string.format("%s시간 %s분", hours, mins)
    end
end

function showBatteryStatus()
    local message

    if hs.battery.isCharging() then
        local pct = hs.battery.percentage()
        local untilFull = hs.battery.timeToFullCharge()
        message = "🔌 충전 중:"

        if untilFull == -1 then
        message = string.format("%s %.0f%% (calculating...)", message, pct);
        else
        message = string.format("%s %.0f%% (%s 남음)", message, pct, minutesToHours(untilFull))
        end
    elseif hs.battery.powerSource() == "Battery Power" then
        local pct = hs.battery.percentage()
        local untilEmpty = hs.battery.timeRemaining()
        message = "🔋 배터리:"

        if untilEmpty == -1 then
        message = string.format("%s %.0f%% (calculating...)", message, pct)
        else
        message = string.format("%s %.0f%% (%s 남음)", message, pct, minutesToHours(untilEmpty))
        end
    else
        message = "Fully charged"
    end

    hs.alert.closeAll()
    hs.alert.show(message)
end

function batteryChangedCallback()
    local powerSource = hs.battery.powerSource()

    if powerSource ~= previousPowerSource then
        showBatteryStatus()
        previousPowerSource = powerSource;
    end
end

hs.battery.watcher.new(batteryChangedCallback):start()

sc_bind("s", showBatteryStatus)

-- -------------------------------------------------------------------------- --
--                          Reconnect to current Wifi                         --
-- -------------------------------------------------------------------------- --
function ssidChangedCallback()
    local ssid = hs.wifi.currentNetwork()
    if ssid then
        hs.alert.closeAll()
        hs.alert.show("📡 Network 연결: " .. ssid)
    end
end

hs.wifi.watcher.new(ssidChangedCallback):start()

hs.hotkey.bind(shiftctrl, "w", nil, function()
    local ssid = hs.wifi.currentNetwork()
    if not ssid then return end

    hs.alert.closeAll()
    hs.alert.show("📡 Network 재설정 : " .. ssid)
    hs.execute("networksetup -setairportpower en0 off")
    hs.execute("networksetup -setairportpower en0 on")
end)

hs.hotkey.bind(shiftctrl, "i", hs.window.frontmostWindow().focusWindowEast)
hs.hotkey.bind(shiftctrl, "u", hs.window.frontmostWindow().focusWindowWest)