#!/usr/bin/bash
LAPTOP="eDP-1";
displays=$(swaymsg -t get_outputs | grep name | wc -l)
if [[ $displays -gt 1 ]] && $(grep -q closed /proc/acpi/button/lid/LID/state); then
  echo "disabling laptop"
  swaymsg output "$LAPTOP" disable
else
  echo "enabling laptop"
  swaymsg output "$LAPTOP" enable
fi;

# try and start swww
swww init &> /dev/null

# this is not used at the moment
status=$?

# set the background
swww img $HOME/.local/media/background.png;

# TODO: this is not tested and i dont think its working correctly
# if [ -n "$SWAY_ENABLE_DESKTOP_BACKGROUND" ]; then
#   swww img $HOME/.local/media/background.png;
# fi
