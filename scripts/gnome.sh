#!/bin/bash

# Inspired by https://gist.github.com/rmrfasterisk/c88fb4e9c1e178424ca1c1bba740066a

gsettings-do() {

    # Tilix Dark Theme
    gsettings set com.gexperts.Tilix.Settings theme-variant 'dark'

    # Gnome Shell Theming
    gsettings set org.gnome.desktop.interface gtk-theme 'Matcha-dark-azul'
    gsettings set org.gnome.desktop.interface cursor-theme 'Paper'
    gsettings set org.gnome.desktop.interface icon-theme 'Papirus-Dark'
    gsettings set org.gnome.shell.extensions.user-theme name 'Matcha-dark-azul'

    # Set Extensions for gnome
    gsettings set org.gnome.shell enabled-extensions ['user-theme@gnome-shell-extensions.gcampax.github.com', 'dash-to-dock@micxgx.gmail.com', 'cpupower@mko-sl.de', 'ubuntu-appindicators@ubuntu.com']

    # Better Font Smoothing
    gsettings set org.gnome.settings-daemon.plugins.xsettings antialiasing 'rgba'

    # Usability Improvements
    gsettings set org.gnome.desktop.calendar show-weekdate true
    gsettings set org.gnome.desktop.wm.preferences button-layout 'appmenu:minimize,maximize,close'

    # Dash to Dock Theme
    gsettings set org.gnome.shell.extensions.dash-to-dock animate-show-apps false
    gsettings set org.gnome.shell.extensions.dash-to-dock background-opacity 0
    gsettings set org.gnome.shell.extensions.dash-to-dock custom-theme-shrink true
    gsettings set org.gnome.shell.extensions.dash-to-dock dash-max-icon-size 32
    gsettings set org.gnome.shell.extensions.dash-to-dock dock-position 'BOTTOM'
    gsettings set org.gnome.shell.extensions.dash-to-dock multi-monitor true
    gsettings set org.gnome.shell.extensions.dash-to-dock transparency-mode 'FIXED'
    gsettings set org.gnome.shell.extensions.dash-to-dock show-show-apps-button false
    gsettings set org.gnome.shell.extensions.dash-to-dock scroll-action 'switch-workspace'

    # Nautilus (File Manager) Usability
    gsettings set org.gnome.nautilus.icon-view default-zoom-level 'small'

}

# Check if running as root or exit because entering password multiple times is painstaking
if [[ "$1" == "--gsettings" ]]; then
	gsettings-do
	exit 0
else
	if [[ $(id -u) != 0 ]]; then
		echo "Run as root"
		exit 1
	fi
fi

# Apt
sudo apt update

sudo apt install -y \
    paper-icon-theme \
    papirus-icon-theme \
    gnome-shell-extensions-dashtodock
