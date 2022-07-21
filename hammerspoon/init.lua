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

hs.alert.show("Relaod Hammerspoon")

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

-- h_bind("e", launchApp("Visual Studio Code"))
-- h_bind("c", launchApp("Safari"))
-- h_bind("t", launchApp("iTerm"))
-- h_bind("z", launchApp("Finder"))

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

-- hs.window.animationDuration = 0

sc_bind("1", positionWindow(0, 0, 1/2, 1))
sc_bind("2", positionWindow(1/2, 0, 1/2, 1))

sc_bind("3", positionWindow(0, 0, 1/2, 1/2))
sc_bind("4", positionWindow(1/2, 0, 1/2, 1/2))
sc_bind("5", positionWindow(0, 1/2, 1/2, 1/2))
sc_bind("6", positionWindow(1/2, 1/2, 1/2, 1/2))

sc_bind("[", positionWindow(0, 0, 2/3, 1))
sc_bind("]", positionWindow(2/3, 0, 1/3, 1))

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

