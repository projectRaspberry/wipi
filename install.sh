#!/bin/bash

echo "HPC cluster using Raspberry Pi"
echo "=============================="
echo " "

################# MASTER & NODE  IP CONFIGURATION ################
read -p 'Enter total number of compute nodes: ' numNodes

read -p 'Enter the IP reserved for master node: ' masterIp

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

echo All done
