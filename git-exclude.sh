#!/bin/bash

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
proxychains archlinuxir_dep.sh amberol-git
rm $HOME/source -rf

cp /build/*.pkg.tar.* /archlinuxir/x86_64
echo "Updating the Database."
rm /archlinuxir/x86_64/archlinuxir*
repo-add -R /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst > /dev/null 2>&1
echo "Database updated completed."
rm -rf /build/*
find $HOME/logs/update/ -mindepth 1 -mtime +2 -delete
