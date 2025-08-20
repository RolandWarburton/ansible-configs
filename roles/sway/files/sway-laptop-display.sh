#!/usr/bin/bash
LAPTOP="eDP-1";
WAYLAND_DISPLAY="wayland-1"

displays=$(swaymsg -t get_outputs | grep name | wc -l)
if [[ $displays -gt 1 ]] && $(grep -q closed /proc/acpi/button/lid/LID/state); then
  swaymsg output "$LAPTOP" disable
else
  swaymsg output "$LAPTOP" enable
fi;

if [ -n "$SWAY_ENABLE_DESKTOP_BACKGROUND" ]; then
  # Check if swww is not running
  if ! pgrep swww >/dev/null 3>&1; then
    # try and start swww
    swww-daemon &> /dev/null
    sleep 1
  fi
  # set the background
  swww img $HOME/.local/media/background.png;
fi
