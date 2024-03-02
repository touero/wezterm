-- Pull in the wezterm API
local wezterm = require("wezterm")
local act = wezterm.action
local mod = {}

local function is_found(str, pattern)
	return string.find(str, pattern) ~= nil
end

local function platform()
	return {
		is_windows = is_found(wezterm.target_triple, "windows"),
		is_linux = is_found(wezterm.target_triple, "linux"),
		is_mac = is_found(wezterm.target_triple, "apple"),
	}
end

-- This table will hold the configuration.
local config = {}

-- In newer versions of wezterm, use the config_builder which will
-- help provide clearer error messages
if wezterm.config_builder then
	config = wezterm.config_builder()
end

-- This is where you actually apply your config choices

if platform().is_mac then
	mod.SUPER = "SUPER"
	mod.SUPER_REV = "SUPER|CTRL"
elseif platform().is_windows then
	config.deault_domain = "WSL:Ubuntu-22.04"
	mod.SUPER = "ALT"
	mod.SUPER_REV = "ALT|CTRL"
end

config.keys = {
	{ key = "F11", mods = "NONE", action = act.ToggleFullScreen },
	{ key = "/", mods = mod.SUPER, action = act.Hide },
}

-- Changing the color scheme:
config.term = "xterm-256color"
config.animation_fps = 60
config.max_fps = 60
config.color_scheme = "Gruvbox Dark"

-- Adding JetBrains Mono font and set font size
config.font = wezterm.font("JetBrains Mono", { weight = "Medium" })
config.font_size = 14

-- Set to background opacity
config.window_background_opacity = 0.95

-- Set to borderless mode
config.window_decorations = "RESIZE"

config.default_cursor_style = "BlinkingBar"
config.cursor_blink_rate = 500

-- Set to deault rows and columns
config.initial_rows = 35
config.initial_cols = 150

-- Set bar
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = false
config.tab_max_width = 25
config.show_tab_index_in_tab_bar = true
config.switch_to_last_active_tab_when_closing_tab = true

-- About window
config.window_frame = {
	active_titlebar_bg = "#343434",
	inactive_titlebar_bg = "#5c5c5c",
}

-- About tag bar
config.colors = {
	background = "#282828",
	foreground = "#fbf1c7",

	--         Black      Maroon     Green      Olive      Navy       Purple     Teal       Silver
	ansi = { "#282828", "#cc241d", "#98971a", "#d79921", "#458588", "#b16286", "#689d6a", "#a89984" },

	--             Grey       Red        Lime      Yellow      Blue      Fuchsia    Squa      White
	brights = { "#928374", "#fb4934", "#b8bb26", "#fabd2f", "#83a598", "#d3869b", "#8ec07c", "#ebdbb2" },

	tab_bar = {
		background = "#000000",
		active_tab = {
			bg_color = "#585b70",
			fg_color = "#cdd6f4",
		},
		inactive_tab = {
			bg_color = "#313244",
			fg_color = "#45475a",
		},
		inactive_tab_hover = {
			bg_color = "#313244",
			fg_color = "#cdd6f4",
		},
		new_tab = {
			bg_color = "#1f1f28",
			fg_color = "#cdd6f4",
		},
		new_tab_hover = {
			bg_color = "#181825",
			fg_color = "#cdd6f4",
			italic = true,
		},
	},
}

-- and finally, return the configuration to wezterm
return config
