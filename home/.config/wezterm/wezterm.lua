local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- WezTerm laeuft als Windows-Prozess und startet direkt in die WSL.
-- Diese Datei wird von C:\Users\simon\.wezterm.lua per dofile() geladen.
config.default_domain = "WSL:Ubuntu"

-- default_domain legt nur fest, WO die Shell laeuft, nicht in welchem Verzeichnis.
-- Ohne das Folgende erbt WezTerm das cwd vom Windows-Prozess: /mnt/c/Users/simon.
-- Das braucht zwei Angaben, weil WezTerm zwei getrennte Pfade auswertet:
-- die Domain (Linux-Pfad) und das initiale Fenster (Windows-/UNC-Pfad).
local wsl_domains = wezterm.default_wsl_domains()
for _, domain in ipairs(wsl_domains) do
	domain.default_cwd = "/home/simon"
end
config.wsl_domains = wsl_domains
config.default_cwd = "\\\\wsl.localhost\\Ubuntu\\home\\simon"

config.color_scheme = "rose-pine-moon"
config.font = wezterm.font("Hack Nerd Font")
config.font_size = 9.0
config.window_background_opacity = 0.95
config.hide_tab_bar_if_only_one_tab = true
config.window_decorations = "RESIZE"

-- Dim unfocused windows so the focused one is obvious at a glance.
local UNFOCUSED_FOREGROUND_TEXT_HSB = { hue = 1.0, saturation = 0.25, brightness = 0.45 }
local UNFOCUSED_WINDOW_BACKGROUND_OPACITY = 0.62

-- get_config_overrides() hands back a copy, so the current value is never the
-- same table we last stored; compare the fields instead of the identity.
local function same_text_hsb(actual, expected)
	if actual == nil or expected == nil then
		return actual == expected
	end
	return actual.hue == expected.hue
		and actual.saturation == expected.saturation
		and actual.brightness == expected.brightness
end

wezterm.on("window-focus-changed", function(window)
	local overrides = window:get_config_overrides() or {}
	local text_hsb, opacity
	if not window:is_focused() then
		text_hsb = UNFOCUSED_FOREGROUND_TEXT_HSB
		opacity = UNFOCUSED_WINDOW_BACKGROUND_OPACITY
	end

	-- Only write when one of the two values we own actually changes; a redundant
	-- set_config_overrides() call would trigger another config reload.
	if same_text_hsb(overrides.foreground_text_hsb, text_hsb) and overrides.window_background_opacity == opacity then
		return
	end

	overrides.foreground_text_hsb = text_hsb
	overrides.window_background_opacity = opacity
	window:set_config_overrides(overrides)
end)

return config
