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
IMAGE_NAME="2021-01-11-raspios-buster-armhf-lite.img"
IMAGE_PATH="${IMAGES_DIR}/${IMAGE_NAME}"

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

/usr/sbin/img-resize ${IMAGE_NAME} max '7G'
/usr/sbin/img-chroot ${IMAGE_NAME} copy "builder/assets/init_rpi.sh" "/root/"
/usr/sbin/img-chroot ${IMAGE_NAME} copy "builder/assets/hardware_setup.sh" "/root/"
/usr/sbin/img-chroot ${IMAGE_NAME} copy "builder/image-init.sh" "/root/"

# Monkey
/usr/sbin/img-chroot ${IMAGE_NAME} copy "builder/assets/monkey" "/root/"

# rsyslog config
/usr/sbin/img-chroot ${IMAGE_NAME} copy 'builder/assets/rsyslog.conf' '/etc'
/usr/sbin/img-chroot ${IMAGE_NAME} copy 'builder/assets/rsysrot.sh' '/etc/rsyslog.d'
# Butterfly
/usr/sbin/img-chroot ${IMAGE_NAME} copy 'builder/assets/butterfly.service' '/lib/systemd/system/'
/usr/sbin/img-chroot ${IMAGE_NAME} copy 'builder/assets/butterfly.socket' '/lib/systemd/system/'
/usr/sbin/img-chroot ${IMAGE_NAME} copy 'builder/assets/monkey.service' '/lib/systemd/system/'
# software install
# /usr/sbin/img-chroot ${IMAGE_NAME} exec 'builder/image-software.sh'
# examples
/usr/sbin/img-chroot ${IMAGE_NAME} copy 'builder/assets/examples' '/home/pi/'  # TODO: symlink?
# network setup
/usr/sbin/img-chroot ${IMAGE_NAME} exec 'builder/image-network.sh'


/usr/sbin/img-resize '2021-01-11-raspios-buster-armhf-lite.img'
