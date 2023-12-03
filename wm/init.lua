-- -------------------------------------------------------------------------- --
--                                   Styles                                   --
-- -------------------------------------------------------------------------- --
hs.hints.fontName = "Galmuri11"
hs.hints.fontSize = 14
hs.hints.showTitleThresh = 0
hs.hints.iconAlpha = 1

hs.alert.defaultStyle.textFont = "Galmuri11"
hs.alert.defaultStyle.textColor = {white = 1, alpha = 1}
hs.alert.defaultStyle.textSize = 14
hs.alert.defaultStyle.radius = 4
hs.alert.defaultStyle.padding = 20

hs.alert.show("🔨 <Hammerspoon>\n다시 설정하는 중...")

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

local shiftctrl = {"shift", "ctrl"}
local altctrlshift = {"alt", "ctrl", "shift"}

function sc_bind(key, func) hs.hotkey.bind(shiftctrl, key, func) end

-- -- -------------------------------------------------------------------------- --
-- --                           Focus on other Windows                           --
-- -- -------------------------------------------------------------------------- --
hs.hints.hintChars = {"A", "S", "D", "F", "J", "k", "l", ";"}
sc_bind("a", hs.hints.windowHints)

local FRemap = require('foundation_remapping')
local remapper = FRemap.new()
remapper:remap('capslock', 'f18')
remapper:register()

local boxHeight = 3
local boxWidth = 3
local boxAlpha = 1
local boxes = {}

local languageConfig = {
    ["com.apple.keylayout.ABC"] = {
        name = "English",
        color = {red = 0.7686, green = 0.1176, blue = 0.2275}
    },
    ["com.apple.inputmethod.Korean.2SetKorean"] = {
        name = "Korean",
        color = {red = 0.16, green = 0.17, blue = 0.19}
    }
}

function enableShow(language)
    if not language then return end
    resetBoxes()
    hs.fnutils.each(hs.screen.allScreens(), function(screen)
        local frame = screen:fullFrame()

        local topBox = newBox()
        drawRectangle(topBox, frame.x, frame.y, frame.w, boxHeight,
                      language.color)
        table.insert(boxes, topBox)

        local bottomBox = newBox()
        drawRectangle(bottomBox, frame.x, frame.y + frame.h - boxHeight,
                      frame.w, boxHeight, language.color)
        table.insert(boxes, bottomBox)

        local leftBox = newBox()
        drawRectangle(leftBox, frame.x, frame.y + boxHeight, boxWidth,
                      frame.h - 2 * boxHeight, language.color)
        table.insert(boxes, leftBox)

        local rightBox = newBox()
        drawRectangle(rightBox, frame.x + frame.w - boxWidth,
                      frame.y + boxHeight, boxWidth, frame.h - 2 * boxHeight,
                      language.color)
        table.insert(boxes, rightBox)
    end)
end

function disableShow()
    hs.fnutils.each(boxes, function(box) if box then box:delete() end end)
    resetBoxes()
end

function newBox() return hs.drawing.rectangle(hs.geometry.rect(0, 0, 0, 0)) end

function resetBoxes() boxes = {} end

function drawRectangle(targetDraw, x, y, width, height, fillColor)
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

hs.keycodes.inputSourceChanged(function()
    local currentSourceID = hs.keycodes.currentSourceID()
    disableShow()
    enableShow(languageConfig[currentSourceID])
end)

local previousLanguage = nil
local alertStyle = {atScreenEdge = 2}

function showAlertForLanguage(language)
    if not language then return end
    if language == previousLanguage then return end

    previousLanguage = language
    local alertMessage = "" .. language.name
    hs.alert.show(alertMessage, alertStyle)
end

hs.keycodes.inputSourceChanged(function()
    local currentSourceID = hs.keycodes.currentSourceID()
    local language = languageConfig[currentSourceID]
    disableShow()
    enableShow(language)
end)
