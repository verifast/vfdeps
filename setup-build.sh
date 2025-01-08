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
       valac libgtksourceview2.0-dev \
       ninja-build

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
  # brewinstall gtksourceview
  brewinstall oras
  oras pull ghcr.io/homebrew/core/gtksourceview:2.10.5_7@sha256:368413983346081e277782a5df7ac4b9e9ad1adce149fa7028fa6d99e809b7ae
  brew install ./gtksourceview--2.10.5_7.monterey.bottle.tar.gz
  brewinstall vala
  brewinstall ninja
  
else

  echo "Your OS is not supported by this script. For Windows, see verifast/vfdeps-win."
  exit 1

fi
