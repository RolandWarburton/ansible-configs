#!/usr/bin/bash
LAPTOP=eDP-1
if [ $(grep -q open /proc/acpi/button/lid/LID/state) -a $(lsmod | grep -q i915) ]; then
  swaymsg output eDP-1 enable
else
  swaymsg output eDP-1 disable
fi
