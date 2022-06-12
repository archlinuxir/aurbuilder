#!/bin/bash
# I Use proxychains because without it downloading will be slow.
# If you want to run these set of scripts with an unprivileged user then:
# pacman, echo, and mv must be added to sudoers file.
# Also move all the scripts to /usr/bin or /usr/local/bin or any place which is in PATH.
# You can remove proxychains in these scripts if you don't need them.
# You must create /build and /archlinuxir directories and give your user permission to write to them.

cd $HOME
START=$(date +%s)
UPDATEDATE=$(date +'%Y-%m-%d-%H-%M-%S')
echo "Updating the system."
sudo pacman -Syu --noconfirm >> /dev/null

# This loop reads the file that countains our packages in my case its 'pkg'.

while IFS= read -r line; do

# Get last update date from pacaur and convert it to unix time.
# Pacaur and cower are deprecated but I decided to use it as it
# gave me just what i needed with a single command.

  LASTUPDATE=$(pacaur info $line | grep "Last Modified" | cut -c19-)
  UNIXLAST=$(date -d "$LASTUPDATE" +"%s")

# Add 14 hours to the last update time so if it does have any updates
# Our 6 hour cronjob will grab it (BUG: gets updated twice ).

  UNIXLAST6=$(($UNIXLAST + 50400))

# 50400 for 14 hours (60x60x14 seconds)

  if [[ $UNIXLAST6 -ge $START ]];
  then

    if [ "$line" == "tor-browser" ]
    then
	rm -rf $HOMEsource
        proxychains archlinuxir_dep.sh tor-browser
        cd $HOME
        sed -i 's#https://dist.torproject.org/torbrowser/#https://tor.calyxinstitute.org/dist/torbrowser/#g' $HOME/source/PKGBUILD
        proxychains archlinuxir_dep.sh tor-browser
    else
        proxychains archlinuxir_dep.sh $line
        rm -rf $HOME/source && cd /archlinuxir/x86_64
    fi
      echo $line >> $HOME/logs/update/Updated-$UPDATEDATE
  else
      echo "$line doesn't need to get updated."
  fi
done < $HOME/pkg

sleep 2s

# Copy built packages to webserver root and update the database.

cp /build/*.pkg.tar.* /archlinuxir/x86_64
echo "Updating the Database."
rm /archlinuxir/x86_64/archlinuxir*
repo-add -R /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst > /dev/null 2>&1
echo "Database updated completed."
rm -rf /build/*
find $HOME/logs/update/ -mindepth 1 -mtime +2 -delete
