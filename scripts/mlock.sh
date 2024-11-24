#!/usr/bin/bash
key=$(gsettings get org.gnome.mutter overlay-key)
toggleKey=$(dconf read /com/github/amezin/ddterm/ddterm-toggle-hotkey)
gsettings set org.gnome.mutter overlay-key ''
cmatrix
gsettings set org.gnome.mutter overlay-key "$key"
