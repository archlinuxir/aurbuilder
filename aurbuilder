#!/bin/bash

makepkg -s -c -C --noconfirm --noprogressbar --skippgpcheck --nocolor

# Copy the file to our web server directory and delete the build directory.

cp ./*.pkg.tar.* /build
rm ./source -rf
