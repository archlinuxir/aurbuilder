#!/bin/bash

# Sleeps exist to prevent a set of bugs from happening.
# I Use proxychains because without it downloading will be slow.

cd /home/bardia
builddate=$(date +'%Y-%m-%d-%H-%M-%S')
date > /home/bardia/logs/build/date/before_run-$builddate
echo "Updating the system."
sudo pacman -Syu --noconfirm >> /dev/null

# This loop reads the file that countains our packages in my case its 'pkg'.

while IFS= read -r line; do
     proxychains archlinuxir_dep.sh $line | tee -a /home/bardia/logs/build/build-$builddate
done < /home/bardia/pkg-all

# Update the database.

echo "Updating the Database."
repo-add -n -R -p /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst | tee -a /home/bardia/logs/build/dbupdate-$builddate > /dev/null 2>&1
echo "Database updated completed."
sleep 2s
rm /home/bardia/source -rf && cd /home/bardia

# Check for a bug that happens with repo-add.

if sudo pacman -S 7-zip-bin --noconfirm | grep "Maximum file size exceeded"
then
    sleep 2s
    cd /archlinuxir/x86_64
    rm archlinuxir*
    repo-add -n -R -p /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst | tee -a /home/bardia/logs/update/dbfail-$builddate > /dev/null 2>&1
    sleep 2s
    sudo pacman -R 7-zip-bin --noconfirm >> /dev/null
    echo "Fixed a database bug at stage 1."
else
    sudo pacman -R 7-zip-bin --noconfirm >> /dev/null
    echo "No database fix needed."
fi

date > /home/bardia/logs/build/date/first_run-$builddate

# Compare first runs built packages to the ones that should have been built.

echo "Updating the system."
sudo pacman -Syu --noconfirm >> /dev/null
pacman -Sql archlinuxir > /home/bardia/logs/build/list/available-$builddate
comm -13 /home/bardia/logs/build/list/available-$builddate pkg > /home/bardia/logs/build/list/pkg2-$builddate
sleep 2s

# The loop will be run a second time to build left out packages.

while IFS= read -r line; do
     proxychains archlinuxir_dep.sh $line | tee -a /home/bardia/logs/build/build-$builddate
done < /home/bardia/logs/build/list/pkg2-$builddate

# Update the database again.

echo "Updating the Database."
repo-add -n -R -p /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst | tee -a /home/bardia/logs/build/dbupdate-$builddate > /dev/null 2>&1
echo "Database updated completed."
sleep 2s
rm /home/bardia/source -rf && cd /home/bardia

# Check for a bug that happens with repo-add.

if sudo pacman -S 7-zip-bin --noconfirm | grep "Maximum file size exceeded"
then
    sleep 2s
    cd /archlinuxir/x86_64
    rm archlinuxir*
    repo-add -n -R -p /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst | tee -a /home/bardia/logs/update/dbfail-$builddate > /dev/null 2>&1
    sleep 2s
    sudo pacman -R 7-zip-bin --noconfirm >> /dev/null
    echo "Fixed a database bug at stage 2."
else
    sudo pacman -R 7-zip-bin --noconfirm >> /dev/null
    echo "No database fix needed."
fi

date > /home/bardia/logs/build/date/second_run-$builddate

cd /home/bardia
sleep 2s

# These packages fail with my builder program for some reason
# so i decided to build them seperately.

proxychains archlinuxir_dep.sh visual-studio-code-bin | tee -a /home/bardia/logs/build/build-$builddate
proxychains archlinuxir_dep.sh yay-bin | tee -a /home/bardia/logs/build/build-$builddate

# Tor package file fails because of censorship so
# This pulls the PKGBUILD file and replaces a few
# values and runs the build script again.

proxychains archlinuxir_dep.sh tor-browser | tee -a /home/bardia/logs/build/build-$builddate
sed -i 's#https://dist.torproject.org/torbrowser/#https://tor.calyxinstitute.org/dist/torbrowser/#g' source/PKGBUILD
proxychains archlinuxir_dep.sh tor-browser | tee -a /home/bardia/logs/build/build-$builddate

# One last database update.

echo "Updating the Database."
repo-add -n -R -p /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst | tee -a /home/bardia/logs/build/dbupdate-$builddate > /dev/null 2>&1
echo "Database updated completed."
sleep 2s
rm /home/bardia/source -rf && cd /home/bardia

# Check for a bug that happens with repo-add.

if sudo pacman -S 7-zip-bin --noconfirm | grep "Maximum file size exceeded"
then
    sleep 2s
    cd /archlinuxir/x86_64
    rm archlinuxir*
    repo-add -n -R -p /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst | tee -a /home/bardia/logs/update/dbfail-$builddate > /dev/null 2>&1
    sleep 2s
    sudo pacman -R 7-zip-bin --noconfirm >> /dev/null
    echo "Fixed a database bug at stage 3."
else
    sudo pacman -R 7-zip-bin --noconfirm >> /dev/null
    echo "No database fix needed."
fi

date > /home/bardia/logs/build/date/end-$builddate
