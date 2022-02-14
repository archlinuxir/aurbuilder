#!/bin/bash

# Sleeps exist to prevent a set of bugs from happening.
# I Use proxychains because without it downloading will be slow.

UPDATEDATE=$(date +'%Y-%m-%d-%H-%M-%S')
DATE=$(date +"%Y%m%d")
echo "Updating the system."
sudo pacman -Syu --noconfirm >> /dev/null
sleep 1s

# Check for updates using nvchecker.

nvchecker -c /home/bardia/git.toml -k /home/bardia/keyfile.toml
cut -f4 -d '"' /home/bardia/dates.json | rev | cut -c8- | rev > dates
sed -i '/^$/d' dates
END=$(cat /home/bardia/pkg-git | wc -l)
START=1

while [ $START -le $END ]
do
  GITDATE=$(head -$START /home/bardia/dates | tail +$START)
  GITNAME=$(head -$START /home/bardia/pkg-git | tail +$START)
    if [[ $GITDATE -eq $DATE ]];
    then
        proxychains archlinuxir_dep.sh $GITNAME
        rm -rf /home/bardia/source
        cd /home/bardia
        echo $GITNAME >> /home/bardia/logs/update/Updated-git-$UPDATEDATE
    else
        echo "$gitname doesn't need to get updated."
    fi
  START=$(($START + 1))
done

sleep 2s

# Copy built packages to webserver root and update the database.

cp /build/*.pkg.tar.* /archlinuxir/x86_64
echo "Updating the Database."
rm /archlinuxir/x86_64/archlinuxir*
repo-add -R /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst > /dev/null 2>&1
echo "Database updated completed."
rm -rf /build/*
find /home/bardia/logs/build/ -mindepth 1 -mtime +2 -delete
