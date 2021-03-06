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

UPDATEDATE=$(date +'%Y-%m-%d-%H-%M-%S')
DATE=$(date +"%Y%m%d")
echo "Updating the system."
sudo pacman -Syu --noconfirm >> /dev/null
sleep 1s

# Check for updates using nvchecker.

nvchecker -c $HOME/git.toml -k $HOME/keyfile.toml
cut -f4 -d '"' $HOME/dates.json | rev | cut -c8- | rev > dates
sed -i '/^$/d' dates
END=$(cat $HOME/pkg-git | wc -l)
START=1

while [ $START -le $END ]
do
  GITDATE=$(head -$START $HOME/dates | tail +$START)
  GITNAME=$(head -$START $HOME/pkg-git | tail +$START)
    if [[ $GITDATE -ge $DATE ]];
    then
	rm -rf $HOME/source
        proxychains archlinuxir_dep.sh $GITNAME
        rm -rf $HOME/source
        cd $HOME
        echo $GITNAME >> $HOME/logs/update/Updated-git-$UPDATEDATE
    else
        echo "$GITNAME doesn't need to get updated."
    fi
  START=$(($START + 1))
done

# Copy built packages to webserver root and update the database.

cp /build/*.pkg.tar.* /archlinuxir/x86_64
echo "Updating the Database."
rm /archlinuxir/x86_64/archlinuxir*
repo-add -R /archlinuxir/x86_64/archlinuxir.db.tar.zst /archlinuxir/x86_64/*.pkg.tar.zst > /dev/null 2>&1
echo "Database updated completed."
rm -rf /build/*
find $HOME/logs/update/ -mindepth 1 -mtime +2 -delete
