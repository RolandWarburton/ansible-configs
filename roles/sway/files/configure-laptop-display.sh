#!/usr/bin/bash
LAPTOP="eDP-1";
displays=$(swaymsg -t get_outputs | grep name | wc -l)
if [[ $displays -gt 1 ]] && $(grep -q closed /proc/acpi/button/lid/LID/state); then
  swaymsg output "$LAPTOP" disable
else
  swaymsg output "$LAPTOP" enable
fi;

if [ -n "$SWAY_ENABLE_DESKTOP_BACKGROUND" ]; then
  # Check if swww is not running
  if ! pgrep swww >/dev/null 2>&1; then
    # try and start swww
    swww init &> /dev/null

    # this is not used at the moment
    status=$?

    # set the background
    swww img $HOME/.local/media/background.png;
  fi
fi
