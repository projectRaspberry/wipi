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
git checkout automated
chown -R pi:pi /home/pi/wipi
cd /home/pi/wipi/config
