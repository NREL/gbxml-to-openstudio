#!/usr/bin/env bash

ruby --version

OPENSTUDIO_VERSION=$1
OPENSTUDIO_SHA=$2

if [ ! -z ${OPENSTUDIO_VERSION} ] && [ ! -z ${OPENSTUDIO_SHA} ]; then
    echo "Installing OpenStudio ${OPENSTUDIO_VERSION}.${OPENSTUDIO_SHA}"

    OPENSTUDIO_DOWNLOAD_BASE_URL=https://s3.amazonaws.com/openstudio-builds/$OPENSTUDIO_VERSION
    OPENSTUDIO_DOWNLOAD_FILENAME=OpenStudio-$OPENSTUDIO_VERSION.$OPENSTUDIO_SHA-Linux.deb
    OPENSTUDIO_DOWNLOAD_URL=$OPENSTUDIO_DOWNLOAD_BASE_URL/$OPENSTUDIO_DOWNLOAD_FILENAME

    # Install gdebi, then download and install OpenStudio, then clean up.
    # gdebi handles the installation of OpenStudio's dependencies including Qt5 and Boost
    # libwxgtk3.0-0 is a new dependency as of 3/8/2018
    sudo apt-get update
    sudo apt-get install -y gdebi curl
    echo "openstudio download url ${OPENSTUDIO_DOWNLOAD_URL}"
    sudo curl -SLO --insecure --retry 3 $OPENSTUDIO_DOWNLOAD_URL
    sudo gdebi -n $OPENSTUDIO_DOWNLOAD_FILENAME
    sudo rm -f $OPENSTUDIO_DOWNLOAD_FILENAME
    sudo rm -rf /usr/SketchUpPlugin
    sudo rm -rf /var/lib/apt/lists/*
    openstudio openstudio_version
    echo "path: ${PATH}"
    echo "path to openstudio"
    which openstudio
    # ls -al /usr/local/bin
    # ls /usr/local/openstudio-2.7.0

    sudo gem install bundler -v 1.16.6
    sudo bundle install
    # need this to require 'openstudio' from Ruby
    export RUBYLIB="/usr/local/openstudio-${OPENSTUDIO_VERSION}/Ruby:/usr/Ruby"
    echo $RUBYLIB
else
    echo "Must pass in the OpenStudio version and sha to be installed (e.g. setup.sh 2.4.0 f58a3e1808)"
    exit 9
fi
