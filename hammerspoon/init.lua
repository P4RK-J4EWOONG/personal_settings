hs.hotkey.bind({'ctrl', 'shift'}, '/',  hs.reload)

hs.hints.fontName = "Galmuri11"
hs.hints.fontSize = 14
hs.hints.showTitleThresh = 0
hs.hints.iconAlpha = 1

hs.alert.defaultStyle.textFont = "Galmuri11"
hs.alert.defaultStyle.textColor = { white = 1, alpha = 1 }
hs.alert.defaultStyle.textSize = 14
hs.alert.defaultStyle.radius = 4
hs.alert.defaultStyle.padding = 20

hs.alert.show("🔨 <Hammerspoon>\n다시 설정하는 중...")

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


function sc_bind(key, func)
    hs.hotkey.bind(shiftctrl, key, func)
end

hs.hints.hintChars = {"A", "S", "D", "F", "J", "k", "l", ";"}
sc_bind("a", hs.hints.windowHints)

local FRemap = require('foundation_remapping')
local remapper = FRemap.new()
remapper:remap('capslock', 'f18')
remapper:register()
