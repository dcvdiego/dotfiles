#!/bin/sh

# Some events send additional information specific to the event in the $INFO
# variable. E.g. the front_app_switched event sends the name of the newly
# focused application in the $INFO variable:
# https://felixkratz.github.io/SketchyBar/config/events#events-and-scripting

if [ "$SENDER" = "front_app_switched" ]; then
  sketchybar --set "$NAME" label="$INFO" icon.background.image="app.$INFO" icon.background.image.scale=0.8

  FOCUSED_WS=$(komorebic query focused-workspace-name 2>/dev/null)
  KOMOREBI_STATE=$(komorebic state 2>/dev/null)

  apps=$(echo "$KOMOREBI_STATE" | jq -r "
    .monitors.elements[].workspaces.elements[] |
    select(.name == \"$FOCUSED_WS\") |
    .containers.elements[].windows.elements[].details.exe
  " 2>/dev/null)

  icon_strip=" "
  if [ -n "$apps" ]; then
    while read -r app; do
      icon_strip+=" $($CONFIG_DIR/plugins/icon_map.sh "$app")"
    done <<< "$apps"
  else
    icon_strip=" —"
  fi
  sketchybar --set space.$FOCUSED_WS label="$icon_strip"
fi
