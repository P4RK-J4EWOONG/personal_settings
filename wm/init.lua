-- ------------------------------------------------------------------------------------------------------------------ --
--              HAMMERSPOON CONFIGURATION FOR LANGUAGE SWITCHING, WINDOW FOCUS HINTS, AND VISUAL FEEDBACK             --
-- ------------------------------------------------------------------------------------------------------------------ --
-- Configuration for visual styles
-- LuaFormatter off
hs.hints.fontName                 = "Galmuri11"
hs.hints.fontSize                 = 14
hs.hints.showTitleThresh          = 0
hs.hints.iconAlpha                = 1
hs.alert.defaultStyle.textFont    = "Galmuri11"
hs.alert.defaultStyle.textColor   = {white = 1, alpha = 1}
hs.alert.defaultStyle.textSize    = 14
hs.alert.defaultStyle.radius      = 4
hs.alert.defaultStyle.padding     = 20
-- LuaFormatter on

-- Display initial configuration message
hs.alert.show("🔨 <Hammerspoon>\n다시 설정하는 중...")

-- Configuration for language switching using the ESC key
local inputEnglish = "com.apple.keylayout.ABC"
local escBind

-- Function to switch to English input source and then send ESC key event
local function switchToEnglish()
    if hs.keycodes.currentSourceID() ~= inputEnglish then
        hs.keycodes.currentSourceID(inputEnglish)
    end
    escBind:disable()
    hs.eventtap.keyStroke({}, 'escape')
    escBind:enable()
end

escBind = hs.hotkey.new({}, 'escape', switchToEnglish):enable()

-- Key bindings for window focus hints and other functions
local shiftCtrl = {"shift", "ctrl"}

-- Function to bind a shortcut key to a function
local function bindShortcut(key, func) hs.hotkey.bind(shiftCtrl, key, func) end

-- Window focus hints configuration
hs.hints.hintChars = {"A", "S", "D", "F", "J", "K", "L", ";"}
bindShortcut("a", hs.hints.windowHints)

-- Foundation remapping for Capslock key
-- LuaFormatter off
local FRemap    = require('foundation_remapping')
local remapper  = FRemap.new()
-- LuaFormatter on

remapper:remap('capslock', 'f18')
remapper:register()

-- Language indicator configuration
-- LuaFormatter off
local boxHeight   = 1
local boxWidth    = 1
local boxAlpha    = 1
local boxes       = {}
-- LuaFormatter on

-- Configuration for different language indicators
-- LuaFormatter off
local languageConfig = {
    ["com.apple.keylayout.ABC"] = { name = "English", color = {hex = "#FFC600"} },
    ["com.apple.inputmethod.Korean.2SetKorean"] = { name = "Korean", color = {hex = "#000000"} }
}
-- LuaFormatter on

-- Function to create a new drawing box
local function newBox() return
    hs.drawing.rectangle(hs.geometry.rect(0, 0, 0, 0)) end

-- Function to reset the indicator boxes
local function resetBoxes()
    boxes = {} -- Clear the boxes table
end

-- Function to draw a rectangle as an indicator box
local function drawRectangle(targetDraw, x, y, width, height, fillColor)
    targetDraw:setSize(hs.geometry.rect(x, y, width, height))
    targetDraw:setTopLeft(hs.geometry.point(x, y))
    targetDraw:setFillColor(fillColor)
    targetDraw:setFill(true)
    targetDraw:setAlpha(boxAlpha)
    targetDraw:setLevel(hs.drawing.windowLevels.overlay)
    targetDraw:setStroke(false)
    targetDraw:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces)
    targetDraw:show()
end

-- Function to enable the language indicator
local function enableShow(language)
    if not language then return end
    resetBoxes()
    hs.fnutils.each(hs.screen.allScreens(), function(screen)
        local frame = screen:fullFrame()

        -- LuaFormatter off
        -- Top indicator box
        local topBox = newBox()
        drawRectangle(topBox, frame.x, frame.y, frame.w, boxHeight, language.color)
        table.insert(boxes, topBox)

        -- Bottom indicator box
        local bottomBox = newBox()
        drawRectangle(bottomBox, frame.x, frame.y + frame.h - boxHeight, frame.w, boxHeight, language.color)
        table.insert(boxes, bottomBox)

        -- Left indicator box
        local leftBox = newBox()
        drawRectangle(leftBox, frame.x, frame.y + boxHeight, boxWidth, frame.h - 2 * boxHeight, language.color)
        table.insert(boxes, leftBox)

        -- Right indicator box
        local rightBox = newBox()
        drawRectangle(rightBox, frame.x + frame.w - boxWidth, frame.y + boxHeight, boxWidth, frame.h - 2 * boxHeight, language.color)
        table.insert(boxes, rightBox)
        -- LuaFormatter on
    end)
end

-- Function to disable the language indicator
local function disableShow()
    hs.fnutils.each(boxes, function(box) if box then box:delete() end end)
    resetBoxes()
end

-- Handle language change events
hs.keycodes.inputSourceChanged(function()
    -- LuaFormatter off
    local currentSourceID   = hs.keycodes.currentSourceID()
    local language          = languageConfig[currentSourceID]
    -- LuaFormatter on

    disableShow()
    enableShow(language)
end)
