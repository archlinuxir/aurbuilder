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

# Add our own repository to let package checks work.
if cat /etc/pacman.conf | grep archlinuxir; then
   true
else
   sudo echo "[archlinuxir]
SigLevel = Optional
Server = https://Mirror.bardia.tech/$repo/$arch" >> /etc/pacman.conf
fi

cd $HOME
rm -rf $HOME/source
BUILDDATE=$(date +'%Y-%m-%d-%H-%M-%S')
echo "Updating the system."
sudo pacman -Syu --noconfirm >> /dev/null

# This loop reads the file that countains our packages in my case its 'pkg'.

while IFS= read -r line; do
     proxychains archlinuxir_dep.sh $line | tee -a $HOME/logs/build/build-$BUILDDATE
done < $HOME/pkg-all

rm $HOME/source -rf && cd $HOME

# Compare first runs built packages to the ones that should have been built.

echo "Updating the system."
sudo pacman -Syu --noconfirm >> /dev/null
pacman -Sql archlinuxir > $HOME/logs/build/available-$BUILDDATE
diff --suppress-common-lines -y $HOME/pkg-all $HOME/logs/build/available-$BUILDDATE  | awk '{ print $1 }' | sort | grep -v '>' > $HOME/logs/build/missing-$BUILDDATE
sleep 2s

# The loop will be run a second time to build left out packages.

while IFS= read -r line; do
     proxychains archlinuxir_dep.sh $line | tee -a $HOME/logs/build/build-$BUILDDATE
done < $HOME/logs/build/list/missing-$BUILDDATE

rm $HOME/source -rf && cd $HOME

sleep 2s

# Compare second runs built packages to the ones that should have been built.

echo "Updating the system."
sudo pacman -Syu --noconfirm >> /dev/null
pacman -Sql archlinuxir > $HOME/logs/build/available2-$BUILDDATE
diff --suppress-common-lines -y pkg-all $HOME/logs/build/available2-$BUILDDATE  | awk '{ print $1 }' | sort | grep -v '>' >> > $HOME/logs/build/missing2-$BUILDDATE
sleep 2s

# The loop will be run a third time to build left out packages.

while IFS= read -r line; do
     proxychains archlinuxir_dep.sh $line | tee -a $HOME/logs/build/build-$BUILDDATE
done < $HOME/logs/build/missing2-$BUILDDATE

rm $HOME/source -rf && cd $HOME

sleep 2s

# Compare third runs built packages to the ones that should have been built.

echo "Updating the system."
sudo pacman -Syu --noconfirm >> /dev/null
pacman -Sql archlinuxir > $HOME/logs/build/available3-$BUILDDATE
diff --suppress-common-lines -y pkg-all $HOME/logs/build/available3-$BUILDDATE  | awk '{ print $1 }' | sort | grep -v '>' >> > $HOME/logs/build/missing3-$BUILDDATE
sleep 2s

# The loop will be run a forth time to build left out packages.

while IFS= read -r line; do
     proxychains archlinuxir_dep.sh $line | tee -a $HOME/logs/build/build-$BUILDDATE
done < $HOME/logs/build/missing3-$BUILDDATE

rm $HOME/source -rf && cd $HOME

sleep 2s

# Tor package file fails because of censorship so
# This pulls the PKGBUILD file and replaces a few
# values and runs the build script again.

proxychains archlinuxir_dep.sh tor-browser | tee -a $HOME/logs/build/build-$BUILDDATE
cd $HOME
sed -i 's#https://dist.torproject.org/torbrowser/#https://tor.calyxinstitute.org/dist/torbrowser/#g' $HOME/source/PKGBUILD
proxychains archlinuxir_dep.sh tor-browser | tee -a $HOME/logs/build/build-$BUILDDATE

# Copy built packages to webserver root and update the database.

cp /build/*.pkg.tar.* /archlinuxir/x86_64
echo "Updating the Database."
rm /archlinuxir/x86_64/archlinuxir*
repo-add -R /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst > /dev/null 2>&1
echo "Database updated completed."
rm -rf /build/*

# Remove our own repository from the list of repositories.
# This speeds things up a bit on updates.

if cat /etc/pacman.conf | grep archlinuxir; then
   sudo head -n -3 /etc/pacman.conf > /etc/pacman.conf.new
   sudo mv /etc/pacman.conf.new /etc/pacman.conf
else
   true
fi

find $HOME/logs/build/ -mindepth 1 -mtime +2 -delete
