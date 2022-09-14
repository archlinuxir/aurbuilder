# Archlinuxir
Hey This is Bardia and these are a set of scripts that I use in my archlinuxir repository project.
What do these scripts do exactly? Let me explain:

aurdget takes a package name then installs the dependencies and passes the package name to aurbuilder

aurbuilder then uses makepkg to build the package and copy it to your web server root directory.

aurfbuilder is a script that takes a file and passes all the names to aurdget and updates the database and some other stuff to make it all work.

aurupdater is the script that is ran every 6 hours by cron. Long story short it checks the update date of a package then updates them if they match a pattern.

aurgupdater updates github versions of a package using nvchecker (this scripts exists because when the github version of an aur package gets updated my method cannot check whether it is updated or not so i use this to check for updates).
aurgupdater is ran right after aurupdater.

aurtester is a very cut down version of build.sh which is used to test new packages that must be added to the list.

pkg contains a list of packages that should be updated using aurupdater.
pkg-git contains a list of git packages that should be updated using aurgupdater.
pkg-all contains all packages.

git.toml and keyfile.toml are both used by nvchecker in aurgupdater.

Thanks to zocker-160 in his aur-builder for zbuilder and zabuilder scripts; aurdget and aurbuilder are his scripts with some modifications done to them.

To run the installer run the following command:

bash <(wget -qO - https://bardia.tech/aurbuilder-install)
