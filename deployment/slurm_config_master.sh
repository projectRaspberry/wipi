#!/bin/bash

#exit if any command fails
set -e

if [ `whoami` != "root" ] ; then
    echo "Rerun as root"
    exit 1
fi

echo "Configuring SLURM on master node"

wipi_repo=/home/pi/wipi
cp $wipi_repo/deployment/slurm_config/* /etc/slurm-llnl/

echo "Copying munge key to the shared directory"
cp /etc/munge/munge.key /shared_dir

echo "Add a new group named admin and add pi to it"
groupadd admin
usermod -a -G admin pi

echo "Adding admin group to sudoes file"
echo "%admin	ALL=(ALL) ALL" >>/etc/sudoers
echo "%admin	ALL=(ALL) NOPASSWD: ALL" >>/etc/sudoers

echo "Copying Cluster Management Scripts to HOME"
cp -r $wipi_repo/cluster_manage_scripts /home/pi/cluster_manage_scripts
chmod 777 /home/pi/cluster_manage_scripts
chmod a+x /home/pi/cluster_manage_scripts/clusterup.sh
chmod a+x /home/pi/cluster_manage_scripts/clusterdown.sh
chmod a+x /home/pi/cluster_manage_scripts/tempRasp.sh

echo "adding aliases to bashrc for smooth execution of scripts"
echo "alias tempcheck='/home/pi/cluster_manage_scripts/tempRasp.sh'">>~/.bashrc
echo "alias clusterup='/home/pi/cluster_manage_scripts/clusterup.sh'">>~/.bashrc
echo "alias clusterdown='/home/pi/cluster_manage_scripts/clusterdown.sh'">>~/.bashrc

echo "Copying openmpi and slurm files to HOME"
cp -r $wipi_repo/open_mpi /shared_dir
cp -r $wipi_repo/slurm_jobs /shared_dir
chmod 777 /shared_dir/open_mpi
chmod 777 /shared_dir/slurm_jobs

echo "Enable and start SLURM Control Services and munge"
systemctl enable munge
systemctl start munge

systemctl enable slurmd
systemctl start slurmd

systemctl enable slurmctld
systemctl start slurmctld

echo "Rebooting system, please wait ...."
reboot
