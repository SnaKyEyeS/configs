#!/bin/bash

echo "Clean old bakcup files..."
rm -rf config/*
rm -rf apt/*

echo "Initializing backup..."

echo "  - i3"
cp -r $HOME/.config/i3 config

echo "  - polybar"
cp -r $HOME/.config/polybar config

echo "  - ranger"
cp -r $HOME/.config/ranger config

echo "  - rofi"
cp -r $HOME/.config/rofi config

echo "  - compton"
cp -r $HOME/.config/compton config

echo "  - atom"
cp -r $HOME/.config/atom config

echo "  - apt"
grep "apt install" $HOME/.zsh_history > apt/history
grep "apt-get install" $HOME/.zsh_history >> apt/history

echo "Backup done !"
echo "Do not forget to commit changes on GitHub :-)"
