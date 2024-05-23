local wezterm = require('wezterm')

return {
   font = wezterm.font_with_fallback({
      { family = 'JetBrainsMono Nerd Font' },
      { family = 'JetBrains Mono' },
      { family = 'Noto Sans SC:style=Regular' },
      { family = 'Noto Sans Mono CJK SC' },
   }),
   font_size = 14,

   --ref: https://wezfurlong.org/wezterm/config/lua/config/freetype_pcf_long_family_names.html#why-doesnt-wezterm-use-the-distro-freetype-or-match-its-configuration
   freetype_load_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
   freetype_render_target = 'Normal', ---@type 'Normal'|'Light'|'Mono'|'HorizontalLcd'
}
