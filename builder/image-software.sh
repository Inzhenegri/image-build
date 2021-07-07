#! /usr/bin/env bash

#
# Script for installing software to the image.
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

echo_stamp() {
  # TEMPLATE: echo_stamp <TEXT> <TYPE>
  # TYPE: SUCCESS, ERROR, INFO

  # More info there https://www.shellhacks.com/ru/bash-colors/

  TEXT="$(date '+[%Y-%m-%d %H:%M:%S]') $1"
  TEXT="\e[1m${TEXT}\e[0m" # BOLD

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

# https://gist.github.com/letmaik/caa0f6cc4375cbfcc1ff26bd4530c2a3
# https://github.com/travis-ci/travis-build/blob/master/lib/travis/build/templates/header.sh
my_travis_retry() {
  local result=0
  local count=1
  while [ $count -le 3 ]; do
    [ $result -ne 0 ] && {
      echo -e "\n${ANSI_RED}The command \"$@\" failed. Retrying, $count of 3.${ANSI_RESET}\n" >&2
    }
    # ! { } ignores set -e, see https://stackoverflow.com/a/4073372
    ! { "$@"; result=$?; }
    [ $result -eq 0 ] && break
    count=$(($count + 1))
    sleep 1
  done

  [ $count -gt 3 ] && {
    echo -e "\n${ANSI_RED}The command \"$@\" failed 3 times.${ANSI_RESET}\n" >&2
  }

  return $result
}

echo_stamp "Increase apt retries"

echo "APT::Acquire::Retries \"3\";" > /etc/apt/apt.conf.d/80-retries

echo_stamp "Install apt keys & repos"

# # TODO: This STDOUT consist 'OK'
# curl http://deb.coex.tech/aptly_repo_signing.key 2> /dev/null | apt-key add -
# apt-get update \
# && apt-get install --no-install-recommends -y dirmngr > /dev/null \
# && apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv-key C1CF6E31E6BADE8868B172B4F42ED6FBAB17C654

# echo "deb http://packages.ros.org/ros/ubuntu buster main" > /etc/apt/sources.list.d/ros-latest.list
# echo "deb http://deb.coex.tech/opencv3 buster main" > /etc/apt/sources.list.d/opencv3.list
# echo "deb http://deb.coex.tech/rpi-ros-melodic buster main" > /etc/apt/sources.list.d/rpi-ros-melodic.list
# echo "deb http://deb.coex.tech/clover buster main" > /etc/apt/sources.list.d/clover.list

# TODO: FIX ERROR: /usr/bin/apt-key: 596: /usr/bin/apt-key: cannot create /dev/null: Permission denied
echo_stamp "Updating apt-get"
apt-get update
echo_stamp "Done updating apt-get" "SUCCESS"

echo_stamp "Update apt"
apt update -y
apt install git python3-pip python-pip -y
dpkg --configure -a
echo_stamp "Apt updated" "SUCCESS"

echo_stamp "ffmpeg installation"
apt install ffmpeg -y
echo_stamp "Done ffmpeg" "SUCCESS"

# echo_stamp "Building mjpg-streamer"
# apt-get install libjpeg8-dev imagemagick libv4l-dev -y
# ln -s /usr/include/linux/videodev2.h /usr/include/linux/videodev.h
# wget http://sourceforge.net/p/mjpg-streamer/code/HEAD/tarball
# unzip mjpg-streamer-code-182.zip
# cd mjpg-streamer-code-182/mjpg-streamer
# make mjpg_streamer input_file.so output_http.so
# cp mjpg_streamer /usr/local/bin
# cp output_http.so input_file.so /usr/local/lib/
# cp -R www /usr/local/www
# echo_stamp "Done mjpg-streamer build" "SUCCESS"


# Let's retry fetching those packages several times, just in case
echo_stamp "Software installation"
apt install --no-install-recommends -y --allow-downgrades cmake-data=3.13.4-1 cmake=3.13.4-1 # FIXME: using older CMake due to https://travis-ci.org/github/CopterExpress/clover/jobs/764367665#L6984
apt install --no-install-recommends -y \
unzip \
zip \
ipython \
ipython3 \
screen \
byobu  \
nmap \
lsof \
git \
dnsmasq  \
tmux \
tree \
vim \
libjpeg8 \
tcpdump \
ltrace \
libpoco-dev \
libzbar0 \
python-rosdep \
python-rosinstall-generator \
python-wstool \
python-rosinstall \
build-essential \
libffi-dev \
monkey \
pigpio python-pigpio python3-pigpio \
i2c-tools \
ntpdate \
python-dev \
python3-dev \
python-systemd \
python3-opencv \
libatlas-base-dev \
python3-numpy

echo_stamp "Installing raspberry pi GPIO tools"
apt install -y python-smbus i2c-tools
pip3 install adafruit-blinka adafruit-circuitpython-dht dht11
apt install -y libgpiod2
echo_stamp "Done raspberry pi GPIO tools" "SUCCESS"

# echo_stamp "Upgrading installed packages"
# apt upgrade -y
# echo_stamp "Upgraded" "SUCCESS"

# Deny byobu to check available updates
sed -i "s/updates_available//" /usr/share/byobu/status/status
# sed -i "s/updates_available//" /home/pi/.byobu/status

# echo_stamp "Installing pip"
# curl https://bootstrap.pypa.io/get-pip.py -o get-pip.py
# curl https://bootstrap.pypa.io/pip/2.7/get-pip.py -o get-pip2.py
# python3 get-pip.py
# python get-pip2.py
# rm get-pip.py get-pip2.py

pip install --upgrade pip
pip3 install --upgrade pip
python -m pip install -U pip

echo_stamp "Make sure both pip and pip3 are installed"
pip --version
pip3 --version

echo_stamp "Downloading setuptools"
pip3 install setuptools
echo_stamp "setuptools are downloaded" "SUCCESS"

echo_stamp "Installing packages"
pip3 install pyzmq pyzbar imutils RPi.GPIO
echo_stamp "Packages are downloaded" "SUCCESS"

echo_stamp "Getting picamera using wget"
wget https://archive.raspberrypi.org/debian/pool/main/p/picamera/python3-picamera_1.13_armhf.deb
dpkg -i python3-picamera_1.13_armhf.deb
echo_stamp "picamera done" "SUCCESS"

echo_stamp "Vidgear installation"
git clone https://github.com/abhiTronix/vidgear.git && cd vidgear
git checkout development
pip3 install .
pip3 install .[asyncio]
echo_stamp "Done vidgear" "SUCCESS"

echo_stamp "Install and enable Butterfly (web terminal)"
echo_stamp "Workaround for tornado >= 6.0 breaking butterfly"
export CRYPTOGRAPHY_DONT_BUILD_RUST=1
my_travis_retry pip3 install tornado==5.1.1
my_travis_retry pip3 install butterfly
my_travis_retry pip3 install butterfly[systemd]
systemctl enable butterfly.socket

echo_stamp "Install ws281x library"
pip install --prefer-binary rpi_ws281x

# echo_stamp "Setup Monkey"
# mv /etc/monkey/sites/default /etc/monkey/sites/default.orig
# mv /root/monkey /etc/monkey/sites/default
# sed -i 's/SymLink Off/SymLink On/' /etc/monkey/monkey.conf
# systemctl enable monkey.service
# echo_stamp "Setup Monkey done" "SUCCESS"

echo_stamp "Install Node.js"
cd /home/pi
wget https://nodejs.org/dist/v10.15.0/node-v10.15.0-linux-armv6l.tar.gz
tar -xzf node-v10.15.0-linux-armv6l.tar.gz
cp -R node-v10.15.0-linux-armv6l/* /usr/local/
rm -rf node-v10.15.0-linux-armv6l/
rm node-v10.15.0-linux-armv6l.tar.gz

echo_stamp "Installing ptvsd"
pip install ptvsd
pip3 install ptvsd

echo_stamp "Add .vimrc"
cat << EOF > /home/pi/.vimrc
set mouse-=a
syntax on
autocmd BufNewFile,BufRead *.launch set syntax=xml
EOF

echo_stamp "Change default keyboard layout to US"
sed -i 's/XKBLAYOUT="gb"/XKBLAYOUT="us"/g' /etc/default/keyboard

echo_stamp "Attempting to kill dirmngr"
gpgconf --kill dirmngr
# dirmngr is only used by apt-key, so we can safely kill it.
# We ignore pkill's exit value as well.
pkill -9 -f dirmngr || true

echo_stamp "End of software installation"
