#! /usr/bin/env bash

#
# Script for build the image. Used builder script of the target repo.
# For build: docker run --privileged -it --rm -v /dev:/dev -v $(pwd):/builder/repo smirart/builder
#
# Copyright (C) 2018 Copter Express Technologies
#
# Author: Artem Smirnov <urpylka@gmail.com>
#
# Distributed under MIT License (available at https://opensource.org/licenses/MIT).
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#

set -e # Exit immidiately on non-zero result

SOURCE_IMAGE="https://downloads.raspberrypi.org/raspios_lite_armhf/images/raspios_lite_armhf-2021-01-12/2021-01-11-raspios-buster-armhf-lite.zip"

export DEBIAN_FRONTEND=${DEBIAN_FRONTEND:='noninteractive'}
export LANG=${LANG:='C.UTF-8'}
export LC_ALL=${LC_ALL:='C.UTF-8'}

echo_stamp() {
  # TEMPLATE: echo_stamp <TEXT> <TYPE>
  # TYPE: SUCCESS, ERROR, INFO

  # More info there https://www.shellhacks.com/ru/bash-colors/

  TEXT="$(date '+[%Y-%m-%d %H:%M:%S]') $1"
  TEXT="\e[1m$TEXT\e[0m" # BOLD

  case "$2" in
    SUCCESS)
    TEXT="\e[32m${TEXT}\e[0m";; # GREEN
    ERROR)
    TEXT="\e[31m${TEXT}\e[0m";; # RED
    *)
    TEXT="\e[34m${TEXT}\e[0m";; # BLUE
  esac
  echo -e ${TEXT}
}

BUILDER_DIR="/builder"
REPO_DIR="${BUILDER_DIR}/repo"
SCRIPTS_DIR="${REPO_DIR}/builder"
IMAGES_DIR="${REPO_DIR}/images"



echo_stamp "Downloading original Linux distribution"
wget --progress=dot:giga -O test.zip ${SOURCE_IMAGE}
echo_stamp "Downloading complete" "SUCCESS" \


echo_stamp "Unzipping Linux distribution image" \
&& unzip -p ${BUILD_DIR}/  \
&& echo_stamp "Unzipping complete" "SUCCESS" \

echo_stamp "Downloading python"
apt update
apt install python3
apt install python3-pip
apt install git
echo_stamp "SUCCESS"

# Downloading python packages
echo_stamp "Downloading python packages"
git clone https://github.com/Inzhenegri/Requirements.git
cd Requirements
pip3 install -r requirements.txt
echo_stamp "SUCCESS"

# Downloading pigpio

ls
touch test.py
python3 test.py
