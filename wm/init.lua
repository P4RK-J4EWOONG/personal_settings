-- ------------------------------------------------------------------------------------------------------------------ --
--              HAMMERSPOON CONFIGURATION FOR LANGUAGE SWITCHING, WINDOW FOCUS HINTS, AND VISUAL FEEDBACK             --
-- ------------------------------------------------------------------------------------------------------------------ --
-- Configuration for visual styles
-- LuaFormatter off
hs.hints.fontName = "Galmuri11" -- Font name for hints
hs.hints.fontSize = 14 -- Font size for hints
hs.hints.showTitleThresh = 0 -- Threshold for showing window titles in hints
hs.hints.iconAlpha = 1 -- Icon transparency for hints
hs.alert.defaultStyle.textFont = "Galmuri11" -- Default font for alerts
hs.alert.defaultStyle.textColor = {white = 1, alpha = 1} -- Default text color for alerts
hs.alert.defaultStyle.textSize = 14 -- Default text size for alerts
hs.alert.defaultStyle.radius = 4 -- Default corner radius for alerts
hs.alert.defaultStyle.padding = 20 -- Default padding for alerts
-- LuaFormatter on

-- Display initial configuration message
hs.alert.show("🔨 <Hammerspoon>\n다시 설정하는 중...") -- Alert to show on startup

-- Configuration for language switching using the ESC key
local inputEnglish = "com.apple.keylayout.ABC" -- Input source ID for English
local escBind -- Variable to hold the ESC key binding

-- Function to switch to English input source and then send ESC key event
local function switchToEnglish()
    if hs.keycodes.currentSourceID() ~= inputEnglish then
        hs.keycodes.currentSourceID(inputEnglish) -- Switch to English input source if not already selected
    end
    escBind:disable() -- Temporarily disable ESC key binding to avoid recursive calls
    hs.eventtap.keyStroke({}, 'escape') -- Send ESC key event
    escBind:enable() -- Re-enable ESC key binding
end

escBind = hs.hotkey.new({}, 'escape', switchToEnglish):enable() -- Bind ESC key to switchToEnglish function

-- Key bindings for window focus hints and other functions
local shiftCtrl = {"shift", "ctrl"} -- Modifier keys for custom shortcuts

-- Function to bind a shortcut key to a function
local function bindShortcut(key, func) hs.hotkey.bind(shiftCtrl, key, func) end

-- Window focus hints configuration
hs.hints.hintChars = {"A", "S", "D", "F", "J", "K", "L", ";"} -- Characters to use for window hints
bindShortcut("a", hs.hints.windowHints) -- Bind Shift+Ctrl+A to show window hints

-- Foundation remapping for Capslock key
local FRemap = require('foundation_remapping') -- Import foundation remapping module
local remapper = FRemap.new() -- Create a new remapper instance
remapper:remap('capslock', 'f18') -- Remap Capslock to F18
remapper:register() -- Register the remapper

-- Language indicator configuration
local boxHeight = 1 -- Height of the indicator boxes
local boxWidth = 1 -- Width of the indicator boxes
local boxAlpha = 1 -- Transparency of the indicator boxes
local boxes = {} -- Table to hold the indicator box objects

-- Configuration for different language indicators
local languageConfig = {
    ["com.apple.keylayout.ABC"] = {
        name = "English", -- Language name
        color = {hex = "#FFC600"} -- Indicator color for English
    },
    ["com.apple.inputmethod.Korean.2SetKorean"] = {
        name = "Korean", -- Language name
        color = {hex = "#000000"} -- Indicator color for Korean
    }
}

-- Function to create a new drawing box
local function newBox() return
    hs.drawing.rectangle(hs.geometry.rect(0, 0, 0, 0)) end

-- Function to reset the indicator boxes
local function resetBoxes()
    boxes = {} -- Clear the boxes table
end

-- Function to draw a rectangle as an indicator box
local function drawRectangle(targetDraw, x, y, width, height, fillColor)
    targetDraw:setSize(hs.geometry.rect(x, y, width, height)) -- Set the size of the box
    targetDraw:setTopLeft(hs.geometry.point(x, y)) -- Set the top-left position of the box
    targetDraw:setFillColor(fillColor) -- Set the fill color of the box
    targetDraw:setFill(true) -- Enable fill for the box
    targetDraw:setAlpha(boxAlpha) -- Set the transparency of the box
    targetDraw:setLevel(hs.drawing.windowLevels.overlay) -- Set the drawing level
    targetDraw:setStroke(false) -- Disable stroke for the box
    targetDraw:setBehavior(hs.drawing.windowBehaviors.canJoinAllSpaces) -- Set the window behavior
    targetDraw:show() -- Show the box
end

-- Function to enable the language indicator
local function enableShow(language)
    if not language then return end -- Exit if no language is provided
    resetBoxes() -- Reset existing boxes
    hs.fnutils.each(hs.screen.allScreens(), function(screen)
        local frame = screen:fullFrame()

        -- Top indicator box
        -- LuaFormatter off
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
    local currentSourceID = hs.keycodes.currentSourceID()
    local language = languageConfig[currentSourceID]
    disableShow()
    enableShow(language)
end)
