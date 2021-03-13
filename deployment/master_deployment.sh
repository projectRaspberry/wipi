#!/bin/bash

#exit if any command fails
set -e

if [ `whoami` != "root" ] ; then
    echo "Rerun as root"
    exit 1
fi

apt -y update
apt -y upgrade
apt -y install git ntpdate screen vim-nox python3-pip nfs-kernel-server slurm-wlm munge openmpi-bin openmpi-common libopenmpi3 libopenmpi-dev build-essential

git clone --recursive https://github.com/sayanadhikari/wipi.git
cd wipi
git checkout automated
chown -R pi:pi /home/pi/wipi
cd /home/pi/wipi/deployment/config_data/master

hostname master
cp hostname /etc/hostname
cp hosts /etc/hosts


locale=en_US.UTF-8
layout=us
raspi-config nonint do_change_locale $locale
raspi-config nonint do_configure_keyboard $layout

timedatectl set-timezone US/Eastern


sudo mkdir -p /home/shared_dir
sudo mount --bind /home/shared_dir/ /home/shared_dir/
echo '/home/shared_dir  /home/shared_dir   none   bind  0 0' >>/etc/fstab
if grep -Fxq "NEED_SVCGSSD=" /etc/default/nfs-kernel-server
then
    echo "SVCGSSD exists"
else
    echo 'NEED_SVCGSSD=no' >>/etc/default/nfs-kernel-server
fi
