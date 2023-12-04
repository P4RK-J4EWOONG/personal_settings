-- ------------------------------------------------------------------------------------------------------------------ --
--              HAMMERSPOON CONFIGURATION FOR LANGUAGE SWITCHING, WINDOW FOCUS HINTS, AND VISUAL FEEDBACK             --
-- ------------------------------------------------------------------------------------------------------------------ --
-- Style configuration
hs.hints.fontName = "Galmuri11"
hs.hints.fontSize = 14
hs.hints.showTitleThresh = 0
hs.hints.iconAlpha = 1
hs.alert.defaultStyle.textFont = "Galmuri11"
hs.alert.defaultStyle.textColor = {
    white = 1,
    alpha = 1
}
hs.alert.defaultStyle.textSize = 14
hs.alert.defaultStyle.radius = 4
hs.alert.defaultStyle.padding = 20

-- Display initial configuration message
hs.alert.show("🔨 <Hammerspoon>\n다시 설정하는 중...")

-- Language switching with ESC key
local inputEnglish = "com.apple.keylayout.ABC"
local escBind

local function switchToEnglish()
    if hs.keycodes.currentSourceID() ~= inputEnglish then
        hs.keycodes.currentSourceID(inputEnglish)
    end
    escBind:disable()
    hs.eventtap.keyStroke({}, 'escape')
    escBind:enable()
end

escBind = hs.hotkey.new({}, 'escape', switchToEnglish):enable()

-- Key bindings for window focus and other functions
local shiftCtrl = {"shift", "ctrl"}
local function bindShortcut(key, func)
    hs.hotkey.bind(shiftCtrl, key, func)
end

-- Window focus hints configuration
hs.hints.hintChars = {"A", "S", "D", "F", "J", "K", "L", ";"}
bindShortcut("a", hs.hints.windowHints)

-- Foundation remapping for Capslock
local FRemap = require('foundation_remapping')
local remapper = FRemap.new()
remapper:remap('capslock', 'f18')
remapper:register()

-- Language indicator configuration
local boxHeight = 3
local boxWidth = 3
local boxAlpha = 1
local boxes = {}

local languageConfig = {
    ["com.apple.keylayout.ABC"] = {
        name = "English",
        color = {
            red = 0.7686,
            green = 0.1176,
            blue = 0.2275
        }
    },
    ["com.apple.inputmethod.Korean.2SetKorean"] = {
        name = "Korean",
        color = {
            red = 0.16,
            green = 0.17,
            blue = 0.19
        }
    }
}

-- Functions for language indicator
local function newBox()
    return hs.drawing.rectangle(hs.geometry.rect(0, 0, 0, 0))
end

local function resetBoxes()
    boxes = {}
end

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

local function enableShow(language)
    if not language then
        return
    end
    resetBoxes()
    hs.fnutils.each(hs.screen.allScreens(), function(screen)
        local frame = screen:fullFrame()

        local topBox = newBox()
        drawRectangle(topBox, frame.x, frame.y, frame.w, boxHeight, language.color)
        table.insert(boxes, topBox)

        local bottomBox = newBox()
        drawRectangle(bottomBox, frame.x, frame.y + frame.h - boxHeight, frame.w, boxHeight, language.color)
        table.insert(boxes, bottomBox)

        local leftBox = newBox()
        drawRectangle(leftBox, frame.x, frame.y + boxHeight, boxWidth, frame.h - 2 * boxHeight, language.color)
        table.insert(boxes, leftBox)

        local rightBox = newBox()
        drawRectangle(rightBox, frame.x + frame.w - boxWidth, frame.y + boxHeight, boxWidth, frame.h - 2 * boxHeight,
            language.color)
        table.insert(boxes, rightBox)
    end)
end

local function disableShow()
    hs.fnutils.each(boxes, function(box)
        if box then
            box:delete()
        end
    end)
    resetBoxes()
end

-- Handle language change
hs.keycodes.inputSourceChanged(function()
    local currentSourceID = hs.keycodes.currentSourceID()
    local language = languageConfig[currentSourceID]
    disableShow()
    enableShow(language)
end)
