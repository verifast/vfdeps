#!/bin/bash

set -e # Stop as soon as a command fails.
set -x # Print what is being executed.

if [ $(uname -s) = "Linux" ]; then

    echo "Not yet supported."
    exit 1

elif [ $(uname -s) = "Darwin" ]; then

    pwd
    export PKG_CONFIG_PATH=/usr/local/opt/libffi/lib/pkgconfig
    VFDEPS_VERSION=`git describe --always`
    VFDEPS_DIRNAME=vfdeps-$VFDEPS_VERSION
    VFDEPS_DIR=/usr/local/$VFDEPS_DIRNAME
    BUILD_DIR=`pwd`
    mkdir upload
    UPLOAD_DIR=$BUILD_DIR/upload
    sudo mkdir $VFDEPS_DIR
    sudo chown -R $(whoami):admin /usr/local/*
    make PREFIX=$VFDEPS_DIR
    VFDEPS_FILENAME=$VFDEPS_DIRNAME-macos.txz
    VFDEPS_FILEPATH=$UPLOAD_DIR/$VFDEPS_FILENAME
    cd /usr/local
    tar cjf $VFDEPS_FILEPATH $VFDEPS_DIRNAME
    cd $BUILD_DIR

    echo '{' > bintray.json
    echo '    package: {' >> bintray.json
    echo '        name: "vfdeps",' >> bintray.json
    echo '        repo: "verifast",' >> bintray.json
    echo '        subject: "verifast",' >> bintray.json
    echo '        vcs_url: "https://github.com/verifast/vfdeps",' >> bintray.json
    echo '        licenses: ["MIT"]' >> bintray.json
    echo '    },' >> bintray.json
    echo '    version: {' >> bintray.json
    echo '        name: "'$VFDEPS_VERSION'"' >> bintray.json
    echo '    },' >> bintray.json
    echo '    files: [{includePattern: "upload/(.*)", uploadPattern: "$1"}],' >> bintray.json
    echo '    publish: true' >> bintray.json
    echo '}' >> bintray.json

    cat bintray.json

else

    echo "Your OS is not supported by this script."
    exit 1
  
fi
