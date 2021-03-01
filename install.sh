#!/bin/bash

########### SETTING SAFEGUARD AGAINST FAILURE ###########
#exit if any command fails
set -e

if [ `whoami` != "root" ] ; then
    echo "Rerun as root"
    exit 1
fi

echo "HPC cluster using Raspberry Pi"
echo "=============================="
echo "NOTE: Make sure that you are in MASTER node"
echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"

################# MASTER & NODE  IP CONFIGURATION ################
read -p 'Enter total number of compute nodes: ' numNodes

read -p 'Enter the IP reserved for master node (e.g. 192.168.1.5): ' masterIp
read -p 'Enter the IP address schema (e.g. if master IP: 192.168.1.5, network schema: 192.168.1.0/24): ' schema

# ((numNodes--))
nCount=1
while [ $nCount -le $numNodes ]
do
  read -p "Enter the IP reserved for node 0$nCount: " nodeIp[$nCount]
  ((nCount++))
done

echo "Master IP: " $masterIp
nCount=1
while [ $nCount -le $numNodes ]
do
  echo "Node 0$nCount IP: " ${nodeIp[$nCount]}
  ((nCount++))
done

##################################################################
################ ENTER MAIN PHASE ###############


apt -y update
apt -y upgrade

apt -y install git screen vim-nox python3-pip build-essential ntpdate nfs-kernel-server slurmd slurm-client slurm-wlm slurm-wlm-basic-plugins slurmctld munge mpich libmpich-dev environment-modules libatlas-base-dev

##############
echo "Shared Storage using NFS"
mkdir /nfsdrive
chown nobody.nogroup -R /nfsdrive
chmod 777 -R /nfsdrive
mount -a
echo '/nfsdrive $schema(rw,sync,no_root_squash,no_subtree_check)' >> /etc/exports

exportfs -a

################# SET UP HOSTNAME and HOSTS###############
echo "master" > /etc/hostname

echo "$masterIp master" >> /etc/hosts
nCount=1
while [ $nCount -le $numNodes ]
do
  echo "${nodeIp[$nCount]} node0$nCount" >> /etc/hosts
  ((nCount++))
done

############### CONFIGURE SLURM ####################

git clone https://github.com/sayanadhikari/wipi.git
cp /wipi/configuration_files/* /etc/slurm-llnl/
sed -i "s/master(192.168.2.2)/master($masterIp)/g" /etc/slurm-llnl/slurm.conf
sed -i "s/NodeAddr=192.168.2.2/NodeAddr=$masterIp/g" /etc/slurm-llnl/slurm.conf


nCount=1
while [ $nCount -le $numNodes ]
do
  sed -i "s/NodeAddr=192.168.2.$nCount/NodeAddr=${nodeIp[$nCount]}/g" /etc/slurm-llnl/slurm.conf
  echo "${nodeIp[$nCount]}\tnode0$nCount" >> /etc/hosts
  ((nCount++))
done


echo All done
