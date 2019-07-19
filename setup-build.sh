#!/bin/bash

#
# Installs dependencies for the VFDeps package.
#

set -e # Stop as soon as a command fails.
set -x # Print what is being executed.

if [ $(uname -s) = "Linux" ]; then
  sudo apt-get update
  sudo apt-get install -y --no-install-recommends \
       git wget ca-certificates make m4 \
       gcc patch unzip libgtk2.0-dev \
       valac libgtksourceview2.0-dev

elif [ $(uname -s) = "Darwin" ]; then
  #brew update

  if [ $TRAVIS = "true" ]; then
      brew unlink python # See https://github.com/verifast/verifast/issues/127
  fi

  function brewinstall {
      if brew list $1 1>/dev/null 2>/dev/null; then
	  true;
      else
	  brew install $1;
      fi
  }  
  brewinstall wget
  brewinstall gtk+
  brewinstall gtksourceview
  brewinstall vala
  
else

  # We assume we're on Windows
  curl -Lf https://cygwin.com/setup-x86.exe
  ./setup-x86.exe -B -qnNd -R c:/cygwin -l c:/cygwin/var/cache/setup -s http://ftp.inf.tu-dresden.de/software/windows/cygwin32/ -P p7zip -P cygutils-extra -P make -P mingw64-i686-gcc-g++ -P mingw64-i686-gcc-core -P mingw64-i686-gcc -P patch -P rlwrap -P libreadline6 -P diffutils -P mingw64-i686-binutils

  echo "none /cygdrive cygdrive binary,posix=0,user,noacl 0 0" > c:/cygwin/etc/fstab

fi
