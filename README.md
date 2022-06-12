# Archlinuxir
Hey This is Bardia and these are a set of scripts that I use in my archlinuxir repository project.
What do these scripts do exactly? Let me explain:

archlinuxir_dep.sh takes a package name then installs the dependencies and passes the package name to archlinuxir_builder.sh

archlinuxir_builder.sh then uses makepkg to build the package and copy it to your web server root directory.

build.sh is a script that takes a file and passes all the names to archlinux_dep.sh and updates the database and some other stuff to make it all work.

update.sh is the script that is ran every 6 hours by cron. Long story short it checks the update date of a package then updates them if they match a pattern.

git-update.sh updates github versions of a package using nvchecker (this scripts exists because when the github version of an aur package gets updated my method cannot check whether it is updated or not so i use this to check for updates).
git-update.sh is ran right after update.sh.

new.sh is a very cut down version of build.sh which is used to test new packages that must be added to the list.

pkg contains a list of packages that should be updated using update.sh.
pkg-git contains a list of git packages that should be updated using git-update.sh.
pkg-all contains all packages.

git.toml and keyfile.toml are both used by nvchecker in git-update.sh.

Thanks to zocker-160 in his aur-builder for zbuilder and zabuilder scripts; archlinuxir_dep.sh and archlinuxir_builder.sh are his scripts with some modifications done to them.

To run the installer run the following command:

bash <(wget -qO - https://bardia.tech/aurbuilder-install)
