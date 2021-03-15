Building HPC with Raspberry Pi
===========================
![Raspberry Pi Cluster View](/images/pi_cluster_view2.jpg)
![Raspberry Pi Cluster View](/images/pi_cluster_view1.jpg)

# Step - 0: The Hardware
 - 2x Raspberry Pi 4 Model B - for compute nodes ([Shop at raspberrypi.org](https://www.raspberrypi.org/products/raspberry-pi-4-model-b/))
 - 1x Raspberry Pi 4 Model B - for master/login node ([Shop at raspberrypi.org](https://www.raspberrypi.org/products/raspberry-pi-4-model-b/))
 - 3x MicroSD Cards (16 GB or higher) ([Shop at Amazon](https://www.amazon.com/PNY-Elite-microSDHC-Memory-3-Pack/dp/B07YXJM282/))
 - 3x USB-C power cables ([Shop at Amazon](https://www.amazon.com/dp/B08G1HS6SL/))
 - 1x 5-port Wireless Router ([Shop at Amazon](https://www.amazon.com/TP-Link-AC1200-WiFi-Router-Access/dp/B07RKYQGG4/))
 - 3x CAT 5/6 Ethernet Cable ([Shop at Amazon](https://www.amazon.com/Cable-Matters-5-Pack-Snagless-Ethernet/dp/B00C2B3T6C/))
 - 1x 5-port 10/100/1000 network switch (Optional) ([Shop at Amazon](https://www.amazon.com/NETGEAR-5-Port-Gigabit-Ethernet-Unmanaged/dp/B07S98YLHM/))
 - 1x 6-port USB power-supply (optional) ([Shop at Amazon](https://www.amazon.com/Anker-5-Port-Charger-PowerPort-iPhone/dp/B00VH8ZW02/))
 - 1x SSD/external HDD or Flash drive ([Shop at Amazon](https://www.amazon.com/PNY-Turbo-32GB-Flash-Drive/dp/B00FDUHD2K/))
 - 1x Raspberry Pi 4 cluster case with cooling fan and heatsinks ([Shop at Amazon](https://www.amazon.com/GeeekPi-Cluster-Raspberry-Heatsink-Stackable/dp/B07MW24S61/))

# Step - 1: Prepare the Micro-SD cards for Raspberry Pi OS
Download latest version of Raspbian Lite OS by using your MacOS/Linux terminal and type

```console
wget https://downloads.raspberrypi.org/raspbian_lite_latest -O raspbian_lite_latest.zip
```
Now extract the zipped file
```console
unzip raspbian_lite_latest.zip
```
Check the directory for the contents from the extraction and find the name of the disk image file with extension .img (e.g. 2020-02-13-raspbian-buster-lite.img)
Now insert a SD/Micro-SD card inside your laptop and check for the attached devices/mount point of the card For MacOs:
```console
diskutil list
```
For Linux:
```console
lsblk
```
Let’s say it is attached to dev/disk2. First unmount the disk,
```console
diskutil unmountDisk /dev/disk2
```
For linux (use "sudo" if necessary)
```console
umount /dev/disk2
```
Then flash the image to memory card
```console
sudo dd if=2020-02-13-raspbian-buster-lite.img of=/dev/disk2
```
If successful, a drive will be mounted under the name boot. Raspberry Pis usually comes with disabled SSH configuration. We don’t want that. To enable it create an empty file inside the boot directory. 

For MacOS, you can find it under /Volumes/boot
```console
cd /Volumes/boot/
```
Now, type
```console
touch ssh 
```
Now, we have successfully configured a Raspbian Lite OS having ssh enabled. 

Let’s eject the card from the Mac
```console
cd
```
```console
diskutil unmountDisk /dev/disk2
```

Repeat this process for all three memory cards. Now insert the cards to your Raspberry Pis. Remember to mark the master node to separate it from others.

Now plug in all the three memory cards in to the storage port of Raspberry Pis. Then connect the network cables(CAT5/6/6A) to in the ethernet port of Pis. Do not power on the Pis at the moment.

#### External storage as shared storage
The concept of cluster is based on idea of working together. In order to do so, they need to have access to the same files. We can arrange this by mounting an external SSD drive (not necessary but convenient and faster) or flash drive, and exporting that storage as a network file system (NFS). It would allow us to access the files from all nodes.

The process is straight forward and simple. At this point, insert the external storage into your master node.

# Step - 2: Network Setup

To do this part, you need a wireless router with DHCP enabled. The [Dynamic Host Configuration Protocol (DHCP)](https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol) will allocate IPs as soon as we connect our Raspberry Pis to the network. If you have network switch, first plugin the other end of the ethernet cables connected to Pis. Now plugin one extra cable from switch to Wireless router. Physical network complete. Now power on the wireless router and the switch. 

**Note**: *If you do not have the network switch, then connect the network cables directly to the wireless router.*

Now, login to the wireless router management page using browser. If your laptop is connected to the same network, just type the gateway IP. e.g. if you IP is 10.10.0.10, usually your gateway is 10.10.0.1, it's really simple. If you have trouble getting into the management page look for proper information on the router body. It's written somewhere on the body. After getting into the management page, go to the connected devices page and keep it open.

## Setting up Wireless Router for the first time
:warning: Instructions are applicable for TP-Link Routers. :clapper: [Video instruction](https://youtu.be/Cg_gGECGLiY)

Similar informations are available for other manufactures:
- D-Link Routers: [Click Here](https://eu.dlink.com/uk/en/support/faq/routers/mydlink-routers/dir-810l/how-do-i-set-up-and-install-my-router) :point_left:
- NETGEAR Routers: [Click Here](https://kb.netgear.com/119/How-do-I-set-up-and-install-my-NETGEAR-router):point_left:

If you want to use the router as modem, you need to follow the instruction given in the picture below:
![Tp-link modem setup](/images/tp-link-3.png)
![Tp-link modem setup 2](/images/tp-link-2.png)
:warning: If you already have a modem and want use this device as a router only, follow the instruction below:
![Tp-link modem setup 3](/images/tp-link-1.png)
Now, power on the master node first by connecting the USB-C cable from a power outlet (or the 6-port USB power supply) and keep refresing the page. If everything goes well, you should see a new device named **raspberrypi** connected to the network. Now note down the IPV4 address associated with it.

Next, **power on** one of the compute nodes and do the same (note it as node01). Repeat the process for all the compute nodes. At the end, you should have something similar to the following information with you:

* master IPV4: **10.10.0.11**
* node01 IPV4: **10.10.0.12**
* node02 IPV4: **10.10.0.13**

Now, try to ping each of the Pis from your computer terminal and wait for couple of seconds, then kill it by pressing  Ctrl + c.
```console
ping 10.10.0.11
```
You should get an output very similar to the following
```console
PING 10.10.0.11: 56 data bytes
64 bytes from 10.10.0.11: icmp_seq=0 ttl=59 time=1.947 ms
64 bytes from 10.10.0.11: icmp_seq=1 ttl=59 time=3.582 ms
64 bytes from 10.10.0.11: icmp_seq=2 ttl=59 time=3.595 ms
64 bytes from 10.10.0.11: icmp_seq=3 ttl=59 time=3.619 ms
...
--- 10.10.0.11 ping statistics ---
6 packets transmitted, 6 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 1.947/3.317/3.635/0.614 ms
```

**Note**: *If you have options to reserve IP on your wireless router management page, it is advised to do so for all the Pis. However, it is not mandetory.*

# Step - 3: Setting Up the Master Node

Now, log in to your master node using
```console
ssh pi@10.10.0.11
```
Upon connection use password *raspberry*. (Note: it is the default password)


Now, use the following command to download the shell script for master node
```console
pi@raspberrypi~$ wget https://raw.githubusercontent.com/sayanadhikari/wipi/automated/deployment/master_deployment.sh
```
The script you just downloaded should be in */home/pi/* with the name *master_deployment.sh*.

#### Safety check for shared storage:

Just before setting up the network, we inserted the external storage into master node. Now use the following command to see the dev location and mount point of your storage.
```console
pi@raspberrypi ~> lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
mmcblk0     105:0    0  7.4G  0 disk 
├─mmcblk0p1 105:1    0 43.8M  0 part /boot
└─mmcblk0p2 105:2    0  7.4G  0 part /
sda         3:16     0 59.2G  0 disk
└─sda1      3:17     0 59.2G  0 part
```
In our case, the main partition of the external storage is mounted at */dev/sda1*. However, if it is different for you, you should edit the *master_deployment.sh* file and modify the following lines accordingly. (Note: replace */dev/sda1* with */dev/sda2* or whatever path you get from *lsblk* command)
```shell
mkfs.ext4 /dev/sda1
UUID=$(blkid -o value -s UUID /dev/sda1)
```

Now run the script to prepare the master node.
```console
pi@raspberrypi~$ sudo bash ./master_deployment.sh
```
At the end of the script execution, the system will automatically reboot. After reboot, log-in to the master node again using 
```console
ssh pi@10.10.0.11
```
and run the following command
```console
pi@master~$ sudo chmod 777 -R /shared_dir
```

# Step - 4: Setting Up the Worker Nodes
We already have the IPs for worker nodes [See Step - 2](#step---2-network-setup). Now let's prepare them one by one. Log into node01 by using the following command,
```console
ssh pi@10.10.0.12
```
Upon connection use password *raspberry*. (Note: it is the default password)

Now, use the following command to download the shell script for worker node
```console
pi@raspberrypi~$ wget https://raw.githubusercontent.com/sayanadhikari/wipi/automated/deployment/node_deployment.sh
```
The script you just downloaded should be in */home/pi/* with the name *node_deployment.sh*. Now run the script to prepare the worker node.
```console
pi@raspberrypi~$ sudo bash ./node_deployment.sh node01
```
At the end of the script execution, the system will automatically reboot.

Now repeat the process for rest of the worker nodes. Login to rest of the worker nodes using their respective ips (information available at Step-2). Also, remember to replace “node01” word in the last command with their respective node numbers. 


# Step - 5: Configuring SLURM on master Node
Slurm is an open source, and highly scalable cluster management and job scheduling system. It can be used for both large and small Linux clusters. Let’s install it on our Pi cluster. To do that, first we need to login to the master node using ssh again,
```console
ssh pi@10.10.0.11
```
Then, go to the deployment directory inside the wipi repository,
```console
pi@master ~> cd /home/pi/wipi/deployment
```

To allow password-less ssh across the system, run the *password_less_ssh_master.sh* using the following command,
```console
pi@master~$ bash password_less_ssh_master.sh
```

Now run the script *slurm_config_master.sh* to prepare the master node for slurm.
```console
pi@master~$ sudo bash slurm_config_master.sh
```

To ensure smooth operation, the system will reboot at this point.

# Step - 6: Configuring SLURM on Compute Nodes

We have successfully configured the master node, we need to do the same on compute nodes. Now, log into the one of the nodes let's say node01
```console
ssh pi@10.10.0.12
```

Then, go to the deployment directory inside the wipi repository,
```console
pi@node01 ~> cd /home/pi/wipi/deployment
```
Now run the script *slurm_config_nodes.sh* to prepare the worker node for slurm.
```console
pi@node01~$ sudo bash slurm_config_nodes.sh
```
To ensure smooth operation, the system will reboot at this point.

#### Diagnostic check for MUNGE
Now, we need to verify whether our the SLURM controller can successfully authenticate with the client nodes using munge. In order to do that, we need to login to master node and use the following command,
```console
pi@master ~> ssh pi@node01 munge -n | unmunge
```
Upon successful operation, you should get output something similar to the following,
```console
ssh pi@node01 munge -n | unmunge
pi@node01's password: 
STATUS:           Success (0)
ENCODE_HOST:      master (127.0.1.1)
ENCODE_TIME:      2020-08-30 22:45:00 +0200 (1598820300)
DECODE_TIME:      2020-08-30 22:45:00 +0200 (1598820300)
TTL:              300
CIPHER:           aes128 (4)
MAC:              sha256 (5)
ZIP:              none (0)
UID:              pi (1001)
GID:              pi (1001)
LENGTH:           0
```
Sometime, you might get an error, which indicates that you may have failed to copy the exact munge key to the nodes.

Now repeat this process on all the other nodes.


# Step - 7: Test SLURM 
Login to master node using ssh and type the following command
```console
pi@master ~>sinfo
```
You should get an output something like this
```console
PARTITION  AVAIL  TIMELIMIT  NODES  STATE NODELIST
picluster*    up   infinite      2   idle node[01-03]
```

You can simply run a task to ask the hostname for each node
```console
pi@master ~>srun --nodes=2 hostname
```
It will give you an output similar to
```console
node02
node01
```
# Step - 8: Powering On and Off (Cluster)
Write a shell script with the following lines of codes and save it as clusterup.sh
```console
#!/bin/bash
sudo scontrol update NodeName=node[01-02] state=resume
sinfo
echo "Nodes up and running"
```
Each time you power on your cluster, run the following command at the startup,
```console
pi@master ~>clusterup
```
Each time you need to power off your cluster, run the following command,
```console
pi@master ~>clusterdown
```
If you wanr to check the temperatures of individual nodes use the following command,

```console
pi@master ~>tempcheck
```
# Step - 9: OpenMPI

OpenMPI is the Open sourced Message Passing Interface. In short it is a very abstract description on how messages can be exchanged between different processes. It will allow us to run a job across multiple nodes connected to the same cluster.

Now let's test OPENMPI, go to the *open_mpi* directory inside *shared_dir*
```console
pi@master ~>cd /shared_dir/open_mpi
```
Now, compile the program using mpicc
```console
mpicc hello_mpi.c
```
This would create an executable name a.out
You can run the executable using the following command
```console
mpirun -np 2 -hostfile hostfile ./a.out
```
Now, let’s test the same using SLURM job manager. In order to do so, first we have to create a job script. Go to the *slurm_jobs* directory inside *shared_dir*
```console
pi@master ~>cd /shared_dir/slurm_jobs
```
To submit a job use the following command
```console
sbatch hello_mpi_slurm.sh 
```
To view the status of any job
```console
squeue -u pi
```
NOTE: pi is your username

# References:
- https://medium.com/@glmdev/building-a-raspberry-pi-cluster-784f0df9afbd
- https://medium.com/@glmdev/building-a-raspberry-pi-cluster-aaa8d1f3d2ca
- https://medium.com/@glmdev/building-a-raspberry-pi-cluster-f5f2446702e8
- https://epcced.github.io/wee_archlet/
- https://scw-aberystwyth.github.io/Introduction-to-HPC-with-RaspberryPi/
- https://github.com/colinsauze/pi_cluster
- https://magpi.raspberrypi.org/articles/build-a-raspberry-pi-cluster-computer
- https://www.hydromag.eu/~aa3025/rpi/



