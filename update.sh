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
      echo $line >> /home/bardia/logs/update/Updated-$updatedate
  else
      echo "$line doesn't need to get updated."
  fi
done < /home/bardia/pkg

sleep 2s

# Copy built packages to webserver root and update the database.

cp /build/*.pkg.tar.* /archlinuxir/x86_64
echo "Updating the Database."
repo-add -R /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst > /dev/null 2>&1
echo "Database updated completed."
rm -rf /build/*
