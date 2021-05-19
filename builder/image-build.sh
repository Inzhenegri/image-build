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

BUILD_DIR="/build"
BUILDER_DIR="/builder"
REPO_DIR="${BUILDER_DIR}/repo"
SCRIPTS_DIR="${REPO_DIR}/builder"
IMAGES_DIR="${REPO_DIR}/images"
RPI_ZIP_NAME="test.zip"
RPI_IMAGE_NAME=$(echo ${RPI_ZIP_NAME} | sed 's/zip/img/')

# Downloading original Linux distribution
if [ ! -e "${RPI_ZIP_NAME}" ]; then
  echo_stamp "Downloading original Linux distribution"
  wget --progress=dot:giga -O ${RPI_ZIP_NAME} ${SOURCE_IMAGE}
  echo_stamp "Downloading complete" "SUCCESS" \
else echo_stamp "Linux distribution already donwloaded"; fi

# Unzipping Linux distribution image
echo_stamp "Unzipping Linux distribution image" \
&& unzip ${RPI_ZIP_NAME} \
&& echo_stamp "Unzipping complete" "SUCCESS" \
|| (echo_stamp "Unzipping was failed!" "ERROR"; exit 1)

${BUILDER_DIR}/image-resize.sh ${IMAGE_PATH} max '7G'

# Downloading python3 and pip3
echo_stamp "Downloading python3 and pip3"
apt update
apt install python3 python3-pip -y
echo_stamp "Downloaded python3 and pip3" "SUCCESS"

# Configuring git
# echo_stamp "Configuring git"
# git config --global user.name "arskosh05@mail.ru"
# git config --global user.email arskosh05@mail.ru
# ls

# Downloading setuptools
echo_stamp "Downloading setuptools"
pip3 install --upgrade setuptools
echo_stamp "setuptools are downloaded" "SUCCESS"

# Installing packages
echo_stamp "Installing packages"
pip3 install --upgrade pip
pip3 install numpy opencv-python pyzmq pygame pyzbar tensorflow
echo_stamp "Downloaded packages" "SUCCESS"

# Installing dependencies from requirements.txt
# echo_stamp "Installing dependencies from requirements.txt"
# pip3 install --upgrade pip
# pip3 install -r requirements.txt
# echo_stamp "Installed from requirements.txt" "SUCCESS"

# Downloading pigpio
echo_stamp "Installing pigpio"
wget https://github.com/joan2937/pigpio/archive/master.zip
unzip master.zip
cd pigpio-master
make
make install
echo_stamp "Installed pigpio" "SUCCESS"
