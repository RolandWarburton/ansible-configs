#!/usr/bin/bash

# get the number of displays
displays=$(swaymsg -t get_outputs | grep name | wc -l)

# the laptop display
LAPTOP="eDP-1";

# if there is more than one display and the lid is closed
if [[ $displays -gt 1 ]] && $(grep -q closed /proc/acpi/button/lid/LID/state); then
  swaymsg output "$LAPTOP" disable
else
  swaymsg output "$LAPTOP" enable
fi;
fi
