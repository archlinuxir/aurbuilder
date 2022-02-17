#!/bin/bash

if test -z "$1";
then
  echo "Specify a software to build"
  exit 1
fi

# AUR Packages are served like this so I use git clone to grab it.

git clone https://aur.archlinux.org/$1.git ~/source

cd ~/source
echo "Installing all the missing dependencies."

# Save a packages dependency to a file and install them using yay(pacman).

makepkg --printsrcinfo > SINFO
while read -r -u 9 key value;
do
  if [ "$key" == "depends" ];
  then
    DEP=$(echo "$value" | cut -d ' ' -f2 | cut -d '>' -f1)
    echo "Installing $DEP."
    yay --noconfirm --noeditmenu --removemake --needed -S "$DEP"
  fi
done 9< "SINFO"

# Call archlinuxir_builder to build the package.

archlinuxir_builder.sh "$1"
