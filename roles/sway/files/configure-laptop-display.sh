#!/usr/bin/bash
LAPTOP="eDP-1";
if [ $(grep -q open /proc/acpi/button/lid/LID/state) -a $(lsmod | grep -q i915) ]; then
  swaymsg output "$LAPTOP" enable
else
  swaymsg output "$LAPTOP" disable
fi
