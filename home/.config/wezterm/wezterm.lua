local wezterm = require("wezterm")

local config = wezterm.config_builder()

-- WezTerm runs as a Windows process and starts straight into WSL.
-- This file is pulled in from C:\Users\simon\.wezterm.lua via dofile().
config.default_domain = "WSL:Ubuntu"

-- default_domain only decides WHERE the shell runs, not in which directory.
-- Without the following, WezTerm inherits the cwd from the Windows process and
-- lands in /mnt/c/Users/simon. It takes two settings because WezTerm resolves
-- two separate paths: the domain (Linux path) and the initial window (UNC path).
-- The third piece is OSC 7 from zsh, see home.nix - without it WezTerm cannot
-- know a pane's directory, so a new tab never inherits it.
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
