#!/bin/bash

# Sleeps exist to prevent a set of bugs from happening.
# I Use proxychains because without it downloading will be slow.

cd /home/bardia
rm -rf ./source
BUILDNEW=$(date +'%Y-%m-%d-%H-%M-%S')
echo "Updating the system."
sudo pacman -Syu --noconfirm >> /dev/null

# This loop reads the file that countains our packages in my case its 'pkg2'.

while IFS= read -r line; do
     proxychains archlinuxir_dep.sh $line | tee -a /home/bardia/logs/build/build-$BUILDNEW
done < /home/bardia/pkg2

rm /home/bardia/source -rf && cd /home/bardia
