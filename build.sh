#!/bin/bash

set -e # Stop as soon as a command fails.
set -x # Print what is being executed.

pwd
VFDEPS_VERSION=`git describe --always`
VFDEPS_DIRNAME=vfdeps-$VFDEPS_VERSION

BUILD_DIR=`pwd`
mkdir -p upload
UPLOAD_DIR=$BUILD_DIR/upload

if [ $(uname -s) = "Linux" ]; then

    VFDEPS_PARENT_DIR=/tmp
    VFDEPS_PLATFORM=linux

    VFDEPS_DIR=$VFDEPS_PARENT_DIR/$VFDEPS_DIRNAME

    make PREFIX=$VFDEPS_DIR

elif [ $(uname -s) = "Darwin" ]; then

    VFDEPS_PARENT_DIR=/usr/local
    VFDEPS_PLATFORM=macos

    VFDEPS_DIR=$VFDEPS_PARENT_DIR/$VFDEPS_DIRNAME

    sudo mkdir $VFDEPS_DIR
    sudo chown -R $(whoami):admin /usr/local/*

    export PKG_CONFIG_PATH=/usr/local/opt/libffi/lib/pkgconfig

    make PREFIX=$VFDEPS_DIR

else

    echo "Your OS is not supported by this script. For Windows, see verifast/vfdeps-win."
    exit 1

fi

VFDEPS_FILENAME=$VFDEPS_DIRNAME-$VFDEPS_PLATFORM.txz
VFDEPS_FILEPATH=$UPLOAD_DIR/$VFDEPS_FILENAME
cd $VFDEPS_PARENT_DIR
tar cjf $VFDEPS_FILEPATH $VFDEPS_DIRNAME
cd $BUILD_DIR
ls -l $VFDEPS_FILEPATH
shasum -a 224 $VFDEPS_FILEPATH
