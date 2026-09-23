#!/usr/bin/env bash

source "$CONFIG_DIR/colors.sh"

KOMOREBI_STATE=$(komorebic state 2>/dev/null)
FOCUSED_MONITOR_IDX=$(komorebic query focused-monitor-index 2>/dev/null)

# Get non-empty workspace names on focused monitor
WORKSPACES_FOCUSED_MONITOR=$(echo "$KOMOREBI_STATE" | jq -r "
  .monitors.elements[$FOCUSED_MONITOR_IDX].workspaces.elements[] |
  select((.containers.elements | length) > 0) |
  .name
" 2>/dev/null)

# Get empty workspace names on focused monitor
EMPTY_WORKSPACES=$(echo "$KOMOREBI_STATE" | jq -r "
  .monitors.elements[$FOCUSED_MONITOR_IDX].workspaces.elements[] |
  select((.containers.elements | length) == 0) |
  .name
" 2>/dev/null)

reload_workspace_icon() {
  local ws_name="$1"
  apps=$(echo "$KOMOREBI_STATE" | jq -r "
    .monitors.elements[].workspaces.elements[] |
    select(.name == \"$ws_name\") |
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

  sketchybar --animate sin 10 --set space.$ws_name label="$icon_strip"
}

if [ "$SENDER" = "komorebi_workspace_change" ]; then
  # Reload icons for previous and current workspace
  if [ -n "$KOMOREBI_PREV_WORKSPACE" ]; then
    reload_workspace_icon "$KOMOREBI_PREV_WORKSPACE"
  fi
  if [ -n "$KOMOREBI_FOCUSED_WORKSPACE" ]; then
    reload_workspace_icon "$KOMOREBI_FOCUSED_WORKSPACE"
  fi

  # Current workspace highlight
  if [ -n "$KOMOREBI_FOCUSED_WORKSPACE" ]; then
    sketchybar --set space.$KOMOREBI_FOCUSED_WORKSPACE icon.highlight=true \
                         label.highlight=true \
                         background.border_color=$GREY
  fi

  # Previous workspace unhighlight
  if [ -n "$KOMOREBI_PREV_WORKSPACE" ]; then
    sketchybar --set space.$KOMOREBI_PREV_WORKSPACE icon.highlight=false \
                         label.highlight=false \
                         background.border_color=$BACKGROUND_2
  fi

  # Show non-empty workspaces on focused monitor
  DISPLAY_IDX=$(( FOCUSED_MONITOR_IDX + 1 ))
  for i in $WORKSPACES_FOCUSED_MONITOR; do
    sketchybar --set space.$i display=$DISPLAY_IDX
  done

  # Hide empty workspaces on focused monitor
  for i in $EMPTY_WORKSPACES; do
    sketchybar --set space.$i display=0
  done

  # Always show focused workspace
  if [ -n "$KOMOREBI_FOCUSED_WORKSPACE" ]; then
    sketchybar --set space.$KOMOREBI_FOCUSED_WORKSPACE display=$DISPLAY_IDX
  fi
fi
