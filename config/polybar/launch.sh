#!/usr/bin/env bash

# Terminate already running bar instances
killall -q polybar
# If all your bars have ipc enabled, you can also use 
# polybar-msg cmd quit

# Launch polybar
if type "xrandr"; then
  for m in $(xrandr --query | grep " connected" | cut -d" " -f1); do
    MONITOR=$m polybar --reload top &
#    MONITOR=$m polybar --reload bottom &
  done
else
  polybar --reload top &
#  polybar --reload bottom &
fi

echo "Bars launched..."

