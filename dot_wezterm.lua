-- Pull in the wezterm API
local wezterm = require("wezterm")
-- This will hold the configuration.
local config = wezterm.config_builder()
local act = wezterm.action
config.font = wezterm.font({ family = "Monaspace Neon", weight = 'Bold' })
config.harfbuzz_features = { 'ss01=0', 'ss02=0', 'ss03=0', 'ss04=0', 'ss05=0' }
config.font_size = 16
config.color_scheme = 'Monokai Pro Ristretto (Gogh)'
config.colors = {
  background = 'black',
  split = '#503B75'
}
config.window_background_opacity = 0.6
config.macos_window_background_blur = 10
config.window_decorations = "RESIZE"
config.keys = {
  { key = 'LeftArrow',  mods = "ALT", action = act.ActivatePaneDirection 'Left' },
  { key = 'RightArrow', mods = "ALT", action = act.ActivatePaneDirection 'Right' },
  { key = 'UpArrow',    mods = "ALT", action = act.ActivatePaneDirection 'Up' },
  { key = 'DownArrow',  mods = "ALT", action = act.ActivatePaneDirection 'Down' },

}
config.inactive_pane_hsb = {
  saturation = 0.45,
  brightness = 0.65
}

local function segments_for_right_status(window)
  return {
    window:active_workspace(),
    window:active_tab(),
    window:active_pane(),
    wezterm.strftime('%a %b %-d %H:%M'),
  }
end

wezterm.on('update-status', function(window, _)
  local SOLID_LEFT_ARROW = wezterm.nerdfonts.pl_right_hard_divider
  local segments = segments_for_right_status(window)

  local color_scheme = window:effective_config().resolved_palette
  -- Note the use of wezterm.color.parse here, this returns
  -- a Color object, which comes with functionality for lightening
  -- or darkening the colour (amongst other things).
  local bg = wezterm.color.parse(color_scheme.background)
  local fg = color_scheme.foreground

  -- Each powerline segment is going to be coloured progressively
  -- darker/lighter depending on whether we're on a dark/light colour
  -- scheme. Let's establish the "from" and "to" bounds of our gradient.
  local gradient_to, gradient_from = bg, bg
  gradient_from = gradient_to:lighten(0.2)

  -- Yes, WezTerm supports creating gradients, because why not?! Although
  -- they'd usually be used for setting high fidelity gradients on your terminal's
  -- background, we'll use them here to give us a sample of the powerline segment
  -- colours we need.
  local gradient = wezterm.color.gradient(
    {
      orientation = 'Horizontal',
      colors = { gradient_from, gradient_to },
    },
    #segments -- only gives us as many colours as we have segments.
  )

  -- We'll build up the elements to send to wezterm.format in this table.
  local elements = {}

  for i, seg in ipairs(segments) do
    local is_first = i == 1

    if is_first then
      table.insert(elements, { Background = { Color = 'none' } })
    end
    table.insert(elements, { Foreground = { Color = gradient[i] } })
    table.insert(elements, { Text = SOLID_LEFT_ARROW })

    table.insert(elements, { Foreground = { Color = fg } })
    table.insert(elements, { Background = { Color = gradient[i] } })
    table.insert(elements, { Text = ' ' .. seg .. ' ' })
  end

  window:set_right_status(wezterm.format(elements))
end)
-- and finally, return the configuration to wezterm
return config
