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

config.window_padding = {
	left = 5,
	right = 10,
	top = 12,
	bottom = 7,
}
config.window_close_confirmation = "AlwaysPrompt"

config.inactive_pane_hsb = {
	saturation = 0.9,
	brightness = 0.95,
}
-- and finally, return the configuration to wezterm
config.launch_menu = launch_menu
local GLYPH_SEMI_CIRCLE_LEFT = ""
-- local GLYPH_SEMI_CIRCLE_LEFT = utf8.char(0xe0b6)
local GLYPH_SEMI_CIRCLE_RIGHT = ""
-- local GLYPH_SEMI_CIRCLE_RIGHT = utf8.char(0xe0b4)
local GLYPH_CIRCLE = ""
-- local GLYPH_CIRCLE = utf8.char(0xf111)
local GLYPH_ADMIN = "ﱾ"
-- local GLYPH_ADMIN = utf8.char(0xfc7e)

local M = {}

M.cells = {}

M.colors = {
	default = {
		bg = "#d65d03",
		fg = "#282828",
	},
	is_active = {
		bg = "#fe8019",
		fg = "#282828",
	},

	hover = {
		bg = "#fe8019",
		fg = "#0F2536",
	},
}

M.set_process_name = function(s)
	local a = string.gsub(s, "(.*[/\\])(.*)", "%2")
	return a:gsub("%.exe$", "")
end

M.set_title = function(process_name, static_title, active_title, max_width, inset)
	local title
	inset = inset or 6
	title = "  " .. process_name .. " ~ " .. " "
	--   󰴈    󰴈

	if title:len() > max_width - inset then
		local diff = title:len() - max_width + inset
		title = wezterm.truncate_right(title, title:len() - diff)
	end

	return title
end

M.check_if_admin = function(p)
	if p:match("^Administrator: ") then
		return true
	end
	return false
end

---@param fg string
---@param bg string
---@param attribute table
---@param text string
M.push = function(bg, fg, attribute, text)
	table.insert(M.cells, { Background = { Color = bg } })
	table.insert(M.cells, { Foreground = { Color = fg } })
	table.insert(M.cells, { Attribute = attribute })
	table.insert(M.cells, { Text = text })
end

M.setup = function()
	wezterm.on("format-tab-title", function(tab, tabs, panes, config, hover, max_width)
		M.cells = {}

		local bg
		local fg
		local process_name = M.set_process_name(tab.active_pane.foreground_process_name)
		local is_admin = M.check_if_admin(tab.active_pane.title)
		local title = M.set_title(process_name, tab.tab_title, tab.active_pane.title, max_width, (is_admin and 8))

		if tab.is_active then
			bg = M.colors.is_active.bg
			fg = M.colors.is_active.fg
		elseif hover then
			bg = M.colors.hover.bg
			fg = M.colors.hover.fg
		else
			bg = M.colors.default.bg
			fg = M.colors.default.fg
		end

		local has_unseen_output = false
		for _, pane in ipairs(tab.panes) do
			if pane.has_unseen_output then
				has_unseen_output = true
				break
			end
		end

		-- Left semi-circle
		M.push(fg, bg, { Intensity = "Bold" }, GLYPH_SEMI_CIRCLE_LEFT)

		-- Admin Icon
		if is_admin then
			M.push(bg, fg, { Intensity = "Bold" }, " " .. GLYPH_ADMIN)
		end

		-- Title
		M.push(bg, fg, { Intensity = "Bold" }, " " .. title)

		-- Unseen output alert
		if has_unseen_output then
			M.push(bg, "#FF3B8B", { Intensity = "Bold" }, " " .. GLYPH_CIRCLE)
		end

		-- Right padding
		M.push(bg, fg, { Intensity = "Bold" }, " ")

		-- Right semi-circle
		M.push(fg, bg, { Intensity = "Bold" }, GLYPH_SEMI_CIRCLE_RIGHT)

		return M.cells
	end)
end

M.setup()
-- and finally, return the configuration to wezterm
return config
