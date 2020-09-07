#!/bin/bash

echo "Clean old config files..."
rm -rf config/*

echo "Initializing backup..."

echo "  - i3"
cp -r $HOME/.config/i3 config

echo "  - polybar"
cp -r $HOME/.config/polybar config

echo "  - ranger"
cp -r $HOME/.config/ranger config

echo "  - rofi"
cp -r $HOME/.config/rofi config

echo "Backup done !"
echo "Do not forget to commit changes on GitHub :-)"

num=$(($(cat /sys/class/backlight/intel_backlight/brightness) + 1000))
