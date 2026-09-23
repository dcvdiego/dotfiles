#!/bin/sh

# Register komorebi workspace change event
sketchybar --add event komorebi_workspace_change

# Helper: get workspace info from komorebi state
KOMOREBI_STATE=$(komorebic state 2>/dev/null)

# Get number of monitors
MONITOR_COUNT=$(echo "$KOMOREBI_STATE" | jq '.monitors.elements | length')

for m_idx in $(seq 0 $(( MONITOR_COUNT - 1 ))); do
  # Monitor display index (1-based for sketchybar)
  display_idx=$(( m_idx + 1 ))

  # Get workspace names for this monitor
  workspaces=$(echo "$KOMOREBI_STATE" | jq -r ".monitors.elements[$m_idx].workspaces.elements[].name")

  for sid in $workspaces; do
    space=(
      space="$sid"
      icon="$sid"
      icon.highlight_color=$RED
      icon.padding_left=10
      icon.padding_right=10
      display=$display_idx
      padding_left=2
      padding_right=2
      label.padding_right=20
      label.color=$GREY
      label.highlight_color=$WHITE
      label.font="sketchybar-app-font:Regular:16.0"
      label.y_offset=-1
      background.color=$BACKGROUND_1
      background.border_color=$BACKGROUND_2
      script="$PLUGIN_DIR/space.sh"
    )

    sketchybar --add space space.$sid left \
               --set space.$sid "${space[@]}" \
               --subscribe space.$sid mouse.clicked

    # Get window apps for this workspace
    apps=$(echo "$KOMOREBI_STATE" | jq -r "
      .monitors.elements[$m_idx].workspaces.elements[] |
      select(.name == \"$sid\") |
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

    sketchybar --set space.$sid label="$icon_strip"
  done

  # Hide empty workspaces
  empty_workspaces=$(echo "$KOMOREBI_STATE" | jq -r "
    .monitors.elements[$m_idx].workspaces.elements[] |
    select((.containers.elements | length) == 0) |
    .name
  " 2>/dev/null)

  for i in $empty_workspaces; do
    sketchybar --set space.$i display=0
  done
done

space_creator=(
  icon=􀆊
  icon.font="$FONT:Heavy:16.0"
  padding_left=10
  padding_right=8
  label.drawing=off
  display=active
  script="$PLUGIN_DIR/space_windows.sh"
  icon.color=$WHITE
)

sketchybar --add item space_creator left               \
           --set space_creator "${space_creator[@]}"   \
           --subscribe space_creator komorebi_workspace_change
