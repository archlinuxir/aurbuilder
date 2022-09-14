#!/bin/bash

# Sleeps exist to prevent a set of bugs from happening.
# I Use proxychains because without it downloading will be slow.
# If you want to run these set of scripts with an unprivileged user then:
# pacman, yay, echo and mv must be added to sudoers file.
# Also move all the scripts to /usr/bin or /usr/local/bin or any place which is in PATH.
# You can remove proxychains in these scripts if you don't need them.
# You must create /build and /archlinuxir directories and give your user permission to write to them.
# Also create a logs directory in your home directory: logs, logs/build, logs/update.
# If you have installed it via the installer then it probably has done everything for you.

sudo pacman -Syu --noconfirm
sleep 1s
cd $HOME

rm $HOME/source -rf
proxychains archlinuxir_dep.sh gnome-shell-extension-arc-menu-git
rm $HOME/source -rf
proxychains archlinuxir_dep.sh plymouth-git
rm $HOME/source -rf
proxychains archlinuxir_dep.sh vala-panel-appmenu-xfce-git
rm $HOME/source -rf
proxychains archlinuxir_dep.sh gnome-shell-extension-openweather-git
rm $HOME/source -rf
proxychains archlinuxir_dep.sh blueprint-compiler-git
rm $HOME/source -rf
proxychains archlinuxir_dep.sh gnome-text-editor-git
rm $HOME/source -rf
proxychains archlinuxir_dep.sh gnome-console-git
rm $HOME/source -rf
proxychains archlinuxir_dep.sh gnome-shell-extension-just-perfection-desktop-git
rm $HOME/source -rf
proxychains archlinuxir_dep.sh gnome-shell-extension-shell-configurator-git
rm $HOME/source -rf
proxychains archlinuxir_dep.sh amberol-git
rm $HOME/source -rf
proxychains archlinuxir_dep.sh libadwaita-git
rm $HOME/source -rf

cp /build/*.pkg.tar.* /archlinuxir/x86_64
echo "Updating the Database."
rm /archlinuxir/x86_64/archlinuxir*
repo-add -R /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst > /dev/null 2>&1
echo "Database updated completed."
rm -rf /build/*
find $HOME/logs/update/ -mindepth 1 -mtime +2 -delete
