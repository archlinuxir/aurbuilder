#!/bin/bash
# I Use proxychains because without it downloading will be slow.

cd /home/bardia/
start=$(date +%s)
updatedate=$(date +'%Y-%m-%d-%H-%M-%S')
echo "Updating the system."
sudo pacman -Syu --noconfirm >> /dev/null

# This loop reads the file that countains our packages in my case its 'pkg'.

while IFS= read -r line; do

# Get last update date from pacaur and convert it to unix time.
# Pacaur and cower are deprecated but I decided to use it as it
# gave me just what i needed with a single command.

  lastupdate=$(pacaur info $line | grep "Last Modified" | cut -c19-)
  unixlast=$(date -d "$lastupdate" +"%s")

# Add 14 hours to the last update time so if it does have any updates
# Our 6 hour cronjob will grab it (BUG: gets updated 2 times ).

  unixlast6=$(($unixlast + 50400))

# 50400 for 14 hours (60x60x14 seconds)

  if [[ $unixlast6 -ge $start ]];
  then

    if [ "$line" == "tor-browser" ]
    then
        proxychains archlinuxir_dep.sh tor-browser
        sed -i 's#https://dist.torproject.org/torbrowser/#https://tor.calyxinstitute.org/dist/torbrowser/#g' source/PKGBUILD
        proxychains archlinuxir_dep.sh tor-browser
    else
        proxychains archlinuxir_dep.sh $line
        rm -rf /home/bardia/source && cd /archlinuxir/x86_64
    fi

# Update the database.

      echo "Updating the Database."
      repo-add -n -R -p /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst > /dev/null 2>&1
      echo "Database updated completed."
      echo $line >> /home/bardia/logs/update/Updated-$updatedate
  else
      echo "$line doesn't need to get updated."
  fi
done < /home/bardia/pkg

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
