#!/bin/bash

#exit if any command fails
set -e

if [ `whoami` != "root" ] ; then
    echo "Rerun as root"
    exit 1
fi

nodeNumber=$1

echo "Updating system, it may take a while..."

apt -y update
apt -y upgrade
apt -y install git ntpdate screen vim-nox python3-pip nfs-common slurmd slurm-client munge openmpi-bin openmpi-common libopenmpi3 libopenmpi-dev build-essential

echo "Cloning Github repo.."
git clone --recursive https://github.com/sayanadhikari/wipi.git
cd wipi
git checkout automated
chown -R pi:pi /home/pi/wipi
cd /home/pi/wipi/deployment/config_data/node

hostname $nodeNumber
cp hostname /etc/hostname
echo "${nodeNumber}">/etc/hostname
cp hosts /etc/hosts
echo "127.0.1.1      ${nodeNumber}">>/etc/hosts
# Back to home dir
cd

echo "Setting up system locale and keyboards"
timezone=US/Eastern
timedatectl set-timezone $timezone

# Setting up NFS share
echo "Setting up NFS share"

mkdir -p /shared_dir
chown nobody.nogroup -R /shared_dir
chmod 777 -R /shared_dir

echo "10.10.0.11:/shared_dir    /shared_dir    nfs    defaults   0 0" >> /etc/fstab

mount -a

echo "Rebooting system, please wait ...."
reboot
