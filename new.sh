#!/bin/bash

# Sleeps exist to prevent a set of bugs from happening.
# I Use proxychains because without it downloading will be slow.
# If you want to run these set of scripts with an unprivileged user then:
# pacman, echo, and mv must be added to sudoers file.
# Also move all the scripts to /usr/bin or /usr/local/bin or any place which is in PATH.
# You can remove proxychains in these scripts if you don't need them.
# You must create /build and /archlinuxir directories and give your user permission to write to them.

cd $HOME
rm -rf $HOME/source
BUILDNEW=$(date +'%Y-%m-%d-%H-%M-%S')
echo "Updating the system."
sudo pacman -Syu --noconfirm >> /dev/null

# This loop reads the file that countains our packages in my case its 'pkg2'.

while IFS= read -r line; do
     rm -rf $HOME/source
     proxychains archlinuxir_dep.sh $line | tee -a $HOME/logs/build/build-$BUILDNEW
     rm -rf $HOME/source
done < $HOME/pkg2

rm $HOME/source -rf && cd $HOME
