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
        echo "Updating the Database."
        sleep 1s
        repo-add -n -R -p /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst > /dev/null 2>&1
        echo "Database updated completed."
        echo $gitname >> /home/bardia/logs/update/Updated-git-$updatedate
    fi
  start=$(($start + 1))
done

sleep 2s

# Check for a bug that happens with repo-add.

if sudo pacman -S 7-zip-bin --noconfirm | grep "Maximum file size exceeded"
then
  sleep 2s
  cd /archlinuxir/x86_64
  rm archlinuxir*
  repo-add -n -R -p /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst | tee -a /home/bardia/logs/update/dbfail-$updatedate > /dev/null 2>&1
  sleep 2s
  sudo pacman -R 7-zip-bin --noconfirm >> /dev/null
  echo "Fixed a database bug."
else
  sudo pacman -R 7-zip-bin --noconfirm >> /dev/null
  echo "No database fix needed."
fi
