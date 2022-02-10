#!/bin/bash

# Sleeps exist to prevent a set of bugs from happening.
# I Use proxychains because without it downloading will be slow.

updatedate=$(date +'%Y-%m-%d-%H-%M-%S')
date=$(date +"%Y%m%d")
echo "Updating the system."
sudo pacman -Syu --noconfirm >> /dev/null
sleep 1s

# Check for updates using nvchecker.

nvchecker -c /home/bardia/git.toml -k /home/bardia/keyfile.toml
cut -f4 -d '"' /home/bardia/dates.json | rev | cut -c8- | rev > dates
sed -i '/^$/d' dates
end=$(cat /home/bardia/pkg-git | wc -l)
start=1

while [ $start -le $end ]
do
  gitdate=$(head -$start /home/bardia/dates | tail +$start)
  gitname=$(head -$start /home/bardia/pkg-git | tail +$start)
  gitdate1=$(($gitdate + 1))
    if [[ $gitdate1 -ge $date ]];
    then
        proxychains archlinuxir_dep.sh $gitname
        rm -rf /home/bardia/source
        cd /home/bardia
        echo $gitname >> /home/bardia/logs/update/Updated-git-$updatedate
    else
        echo "$gitname doesn't need to get updated."
    fi
  start=$(($start + 1))
done

sleep 2s

# Copy built packages to webserver root and update the database.

cp /build/*.pkg.tar.* /archlinuxir/x86_64
echo "Updating the Database."
repo-add -R /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst > /dev/null 2>&1
echo "Database updated completed."
rm -rf /build/*
