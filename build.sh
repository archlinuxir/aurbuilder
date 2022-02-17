#!/bin/bash

# Sleeps exist to prevent a set of bugs from happening.
# I Use proxychains because without it downloading will be slow.

cd /home/bardia
rm -rf /home/bardia/source
BUILDDATE=$(date +'%Y-%m-%d-%H-%M-%S')
echo "Updating the system."
sudo pacman -Syu --noconfirm >> /dev/null

# This loop reads the file that countains our packages in my case its 'pkg'.

while IFS= read -r line; do
     proxychains archlinuxir_dep.sh $line | tee -a /home/bardia/logs/build/build-$BUILDDATE
done < /home/bardia/pkg-all

rm /home/bardia/source -rf && cd /home/bardia

# Copy built packages to webserver root and update the database.

cp /build/*.pkg.tar.* /archlinuxir/x86_64
echo "Updating the Database."
rm /archlinuxir/x86_64/archlinuxir*
repo-add -R /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst > /dev/null 2>&1
echo "Database updated completed."
rm -rf /build/*

# Compare first runs built packages to the ones that should have been built.

echo "Updating the system."
sudo pacman -Syu --noconfirm >> /dev/null
pacman -Sql archlinuxir > /home/bardia/logs/build/available-$BUILDDATE
diff --suppress-common-lines -y pkg-all /home/bardia/logs/build/available-$BUILDDATE  | awk '{ print $1 }' | sort | grep -v '>' > /home/bardia/logs/build/missing-$BUILDDATE
sleep 2s

# The loop will be run a second time to build left out packages.

while IFS= read -r line; do
     proxychains archlinuxir_dep.sh $line | tee -a /home/bardia/logs/build/build-$BUILDDATE
done < /home/bardia/logs/build/list/pkg2-$BUILDDATE

rm /home/bardia/source -rf && cd /home/bardia

sleep 2s

# These packages fail with my builder program for some reason
# so i decided to build them seperately.

proxychains archlinuxir_dep.sh visual-studio-code-bin | tee -a /home/bardia/logs/build/build-$BUILDDATE
proxychains archlinuxir_dep.sh yay-bin | tee -a /home/bardia/logs/build/build-$BUILDDATE

# Tor package file fails because of censorship so
# This pulls the PKGBUILD file and replaces a few
# values and runs the build script again.

proxychains archlinuxir_dep.sh tor-browser | tee -a /home/bardia/logs/build/build-$BUILDDATE
cd /home/bardia/
sed -i 's#https://dist.torproject.org/torbrowser/#https://tor.calyxinstitute.org/dist/torbrowser/#g' source/PKGBUILD
proxychains archlinuxir_dep.sh tor-browser | tee -a /home/bardia/logs/build/build-$BUILDDATE
rm -rf /home/bardia/source
# Copy built packages to webserver root and update the database.

cp /build/*.pkg.tar.* /archlinuxir/x86_64
echo "Updating the Database."
rm /archlinuxir/x86_64/archlinuxir*
repo-add -R /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst > /dev/null 2>&1
echo "Database updated completed."
rm -rf /build/*
find /home/bardia/logs/build/ -mindepth 1 -mtime +2 -delete
