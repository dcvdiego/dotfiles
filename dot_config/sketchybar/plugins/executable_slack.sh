#!/usr/bin/env bash
# Slack unread indicator.
#
# The old `lsappinfo info -only StatusLabel "Slack"` mechanism stopped working on
# macOS 27 (status item not registered, especially with mirrored displays), so we
# read Slack's window title via System Events instead:
#   "! <channel> - <workspace> - N new item(s) - Slack"  -> unread activity
ICON="󰒱"

if ! pgrep -xq Slack; then
  sketchybar --set "${NAME:-slack}" drawing=off
  exit 0
fi
sketchybar --set "${NAME:-slack}" drawing=on

TITLES=$(osascript \
  -e 'tell application "System Events" to tell process "Slack"' \
  -e 'get value of attribute "AXTitle" of every window' \
  -e 'end tell' 2>/dev/null)

LABEL=""
ICON_COLOR="0xffa6da95" # green: no unreads

if [[ $TITLES =~ ([0-9]+)[[:space:]]new[[:space:]]items? ]]; then
  LABEL="${BASH_REMATCH[1]}"
  ICON_COLOR="0xffed8796" # red: unread messages
elif [[ $TITLES == !* || $TITLES =~ ,![[:space:]] || $TITLES =~ -![[:space:]] ]]; then
  LABEL="•"
  ICON_COLOR="0xffeed49f" # yellow: activity, no count
fi

sketchybar --set "${NAME:-slack}" icon=$ICON label="${LABEL}" icon.color=${ICON_COLOR}
