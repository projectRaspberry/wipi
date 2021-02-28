Building HPC with Raspberry Pi
===========================
![Raspberry Pi Cluster View](/images/pi_cluster_view2.jpg)
![Raspberry Pi Cluster View](/images/pi_cluster_view1.jpg)

# Step - 0: The Hardware
 - 2x Raspberry Pi 4 Model B - for compute nodes
 - 1x Raspberry Pi 4 Model B - for master/login node
 - 3x MicroSD Cards (1 with high storage capacity (64 GB or 128 GB if possible) and rest of them 8/16 GB)
 - 3x USB-C power cables
 - 1x 5-port Wireless Router
 - 1x 5-port 10/100/1000 network switch (Optional)
 - 1x 6-port USB power-supply (optional)
 - 1x 128GB SSD/external HDD (optional)

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

For MacOS, you can find it under /Volume/boot

Now, type
```console
touch ssh 
```
Now, we have successfully configured a Raspbian Lite OS having ssh enabled. Let’s eject the card from the Mac
```console
diskutil unmountDisk /dev/disk2
```

Repeat this process for all three memory cards. Now insert the cards to your Raspberry Pis. Remember to mark the master node to separate it from others.

Now plug in all the three memory cards in to the storage port of Raspberry Pis. Then connect the network cables(CAT5/6/6A) to in the ethernet port of Pis. Do not power on the Pis at the moment.

# Step - 2: Network Setup

To do this part, you need a wireless router with DHCP enabled. The [Dynamic Host Configuration Protocol (DHCP)](https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol) will allocate IPs as soon as we connect our Raspberry Pis to the network. If you have network switch, first plugin the other end of the ethernet cables connected to Pis. Now plugin one extra cable from switch to Wireless router. Physical network complete. Now power on the wireless router and the switch. 

**Note**: *If you do not have the network switch, then connect the network cables directly to the wireless router.*

Now, login to the wireless router management page using browser. If your laptop is connected to the same network, just type the gateway IP. e.g. if you IP is 10.10.0.10, usually your gateway is 10.10.0.1, it's really simple. If you have trouble getting into the management page look for proper information on the router body. It's written somewhere on the body. After getting into the management page, go to the connected devices page and keep it open.

Now, power on the master node first by connecting the USB-C cable from a power outlet (or the 6-port USB power supply) and keep refresing the page. If everything goes well, you should see a new device named **raspberrypi** connected to the network. Now note down the IPV4 address associated with it.

Next, power on the one off the compute nodes and do the same (note it as node01). Repeat the process for all the compute nodes. At the end, you should have something similar to the following information with you:

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
64 bytes from 10.10.0.10: icmp_seq=0 ttl=59 time=1.947 ms
64 bytes from 10.10.0.10: icmp_seq=1 ttl=59 time=3.582 ms
64 bytes from 10.10.0.10: icmp_seq=2 ttl=59 time=3.595 ms
64 bytes from 10.10.0.10: icmp_seq=3 ttl=59 time=3.619 ms
...
--- 192.168.1.3 ping statistics ---
6 packets transmitted, 6 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 1.947/3.317/3.635/0.614 ms
```

**Note**: *If you have options to reserve IP on your wireless router management page, it is advised to do so for all the Pis. However, it is not mandetory.*

# Step - 3: Setting Up the Master Node

Now, log in to your master node using
```console
ssh pi@10.10.0.11
```
Upon connection use password raspberry. (Note: it is the default password)

Now, we need to configure the node before starting to use. 
```console
pi@raspberrypi~$ sudo raspi-config
```
It opens up the config utility. You can change the default password if you want (highly recommended). Next you should set the locale, timezone, and wifi country. Then, select finish and press enter to exit the utility.

A snapshot of the utility screen is provided below.

![Raspberry Pi Configuration Window](/images/raspi-config.jpg)


### System Update and Upgrade
```console
pi@raspberrypi ~> sudo apt-get update && sudo apt-get upgrade
```
Now, we need to decide the hostnames for master node as well as cluster nodes. I would recommend to stick with the usual ones. Set “master” for master node and for cluster nodes starting from “node01” to “node02” (for 2 node cluster). Use the following command to set it up on master node.
```console
pi@raspberrypi ~> sudo hostname master     # choice of yours
```
Change "raspberrypi" to “master” by editing the hostname file.

```console
pi@raspberrypi ~> sudo nano /etc/hostname  
```
Now edit the hosts file
```console
pi@raspberrypi ~> sudo nano /etc/hosts   
```

Add the following at the bottom of the existing information
```console
127.0.1.1       master
10.10.0.11     master
10.10.0.12     node01
10.10.0.13     node02
```

### Network time:

Now, since we are planning for a HPC system that uses a SLURM scheduler and the Munge authentication, we need to make sure that the system time is accurate. For that purpose we can install ntpdate package to periodically sync the system time in the background.
```console
pi@raspberrypi ~> sudo apt install ntpdate -y
```
To apply the effect of changes that have been made so far reboot the system using the following command
```console
sudo reboot
```
After, successful reboot, login to the master node again using ssh. 

Next stop, shared storage:

The concept of cluster is based on idea of working together. In order to do so, they need to have access to the same files. We can arrange this mounting an external SSD drive (not necessary but convenient and faster) and exporting that storage as a network file system (NFS). It would allow us to access the files from all nodes.

First, insert the external storage into your master node. Now login to your master node using ssh and use the following command to see the dev location and mount point of your storage.
```console
pi@master ~> lsblk
NAME        MAJ:MIN RM  SIZE RO TYPE MOUNTPOINT
mmcblk0     105:0    0  7.4G  0 disk 
├─mmcblk0p1 105:1    0 43.8M  0 part /boot
└─mmcblk0p2 105:2    0  7.4G  0 part /
sda         3:16     0 59.2G  0 disk
└─sda1      3:17     0 59.2G  0 part
```

In our case, the main partition of the external storage is mounted at /dev/sda1
Before, using it as a NFS drive, we need to format it properly in ext4 file system. Use the following command to do that.
```console
sudo mkfs.ext4 /dev/sda1
```
:warning: Note: If you are not using any external storage, and want to use the Micro-SD card instead skip the formatting.

Now, we need to create a directory where the storage will be mounted. We can choose any name for that. But, lets choose something that is easy to remember e.g. “shared”,
```console
sudo mkdir /shared
sudo chown nobody.nogroup -R /shared
sudo chmod 777 -R /shared
```

Now, we need to configure to mount the storage during boot. For, that we need the the UUID of the storage. We can find that using the following command,
```console
pi@master ~> blkid
```
```console
/dev/mmcblk0p1: LABEL_FATBOOT="boot" LABEL="boot" UUID="4BBD-D3E7" TYPE="vfat" PARTUUID="738a4d67-01"
/dev/mmcblk0p2: LABEL="rootfs" UUID="45e99191-771b-4e12-a526-0779148892cb" TYPE="ext4" PARTUUID="738a4d67-02"
/dev/sda1: UUID="50e407fc-37d8-4eb4-994d-ca6254c4e12e" TYPE="ext4"
```
Now, copy the number from /dev/sda1 if you are using external HDD. Otherwise, copy the number from /dev/mmcblk0p2. It’ll look like
UUID=“50e407fc-37d8-4eb4-994d-ca6254c4e12e”
Now, open and edit fstab to mount the drive on boot.
```console
pi@master ~> sudo nano /etc/fstab
```
Add the following line:
```console
UUID=78543e7a-4hy6-7yea-1274-01e0ff974531 /shared ext4 defaults 0 2
```
All done, now we can mount the drive using the following command,
```console
pi@master ~> sudo mount -a
```
If it fails for some reason, reboot the master node and try again. If it is still not working double check the process and look for typo.

### Enable NFS Share


Now, we have a storage that can be shared but we need to install NFS server on master node in order to do so.
```console
pi@master ~> sudo apt install nfs-kernel-server -y
```
Now, edit /etc/exports and add the following line to export
```console
/shared 10.10.0.0/24(rw,sync,no_root_squash,no_subtree_check)
```
Remember, depending upon the IP address schema used on your local network, the ip will be different for setup. For example, if your master node ip is 192.168.0.11, then you need to replace the ip with 192.168.0.0/24.

Now, we can update the configuration of the NFS kernel with the following command,
```console
sudo exportfs -a
```
One of the tasks for NFS to work remains unfinished which we will do in the next section.

# Step - 4: Setting Up the Worker Nodes
We already have the IPs for worker nodes [See Step - 2](#step---2-network-setup). Now let's prepare them one by one. Log into node01 by using the following command,
```console
ssh pi@10.10.0.12
```
It will ask for a password, use the default one “raspberry.” It will open up a terminal, the same that you had for the master. Now configure the node using 
```console
pi@raspberrypi~$ sudo raspi-config
```
It opens up the config utility. Next you should set the locale, timezone, and wifi country. Then, select finish and press enter to exit the utility. Exactly same what you did for the master node, except the password. 

Now let’s update the hostname.
```console
pi@raspberrypi ~> sudo hostname node01
```
Change "raspberrypi" to “node01” by editing the hostname file.
```console    
pi@raspberrypi ~> sudo nano /etc/hostname  
```
Now edit the hosts file
```console
pi@raspberrypi ~> sudo nano /etc/hosts  
```
Add the following
```console
127.0.1.1      node01
10.10.0.11     master
10.10.0.12     node01
10.10.0.13     node02
```
Next,

System Update and Upgrade
```console
pi@raspberrypi ~> sudo apt-get update && sudo apt-get upgrade
```
Now reboot the system to apply the effect of changes that have been made so far.
```console
pi@raspberrypi ~> sudo reboot
```

After the reboot, login to the system again.

### NFS MOUNT

To access the storage that we shared on master node from individual worker nodes, we need to install and configure NFS services.
```console
sudo apt install nfs-common -y
```
Now, we need to create the same directory in order to mount the storage.
```console
pi@node01 ~> sudo mkdir /shared 
pi@node01 ~> sudo chown nobody.nogroup /shared 
pi@node01 ~> sudo chmod -R 777 /shared
```
To allow automatic mounting we need to edit the fstab file for each node. Use the following command to edit,
```console
pi@node01 ~> sudo nano /etc/fstab
```
And add the following line below the existing texts
```console
10.10.0.11:/shared    /shared    nfs    defaults   0 0
```
Now, use the following to finish the mounting
```console
pi@node01 ~> sudo mount -a
```
To check whether the shared storage is working. Open a new terminal window and login to your master node. Then create a blank file. 
```console
ssh pi@10.10.0.11
```
```console
pi@master ~> cd /shared
pi@master ~> touch nas_test.dat
```
Now go back to the node01 terminal and check the contents of your shared directory
```console
pi@node01 ~> cd /shared
pi@node01 ~> ls
```
If you see nas_test.dat file here, means you have successfully created a Network File System. If you can’t see, you may have to reboot the node once.

Now repeat the process for rest of the worker nodes. Remember to replace “node01” word with their respective node numbers.

# Step - 5: Configuring SLURM on master Node
Slurm is an open source, and highly scalable cluster management and job scheduling system. It can be used for both large and small Linux clusters. Let’s install it on our Pi cluster.
```console
pi@master ~> sudo apt install slurm-wlm -y
```
Upon successful installation, we need to configure slurm,
```console
pi@master ~> cd /home/pi
pi@master ~> cp /usr/share/doc/slurm-client/examples/slurm.conf.simple.gz .
pi@master ~> gzip -d slurm.conf.simple.gz
pi@master ~> sudo mv slurm.conf.simple /etc/slurm-llnl/slurm.conf 
```
Now edit the configuration file by searching for the keyword on the left (e.g. “SlurmctlHost”) and edit the line as per the information provide below,
```console
pi@master ~> sudo nano /etc/slurm-llnl/slurm.conf
```
```console
SlurmctldHost=master(10.10.0.11)
SelectType=select/cons_res
SelectTypeParameters=CR_Core
ClusterName=cluster
```
Now we need to add the node information as well as partition at the end of the file. Delete the example entry for the compute node and add the following configurations for the cluster nodes:
```console
NodeName=master NodeAddr=10.10.0.11 CPUs=4 State=UNKNOWN
NodeName=node01 NodeAddr=10.10.0.12 CPUs=4 State=UNKNOWN
NodeName=node02 NodeAddr=10.10.0.13 CPUs=4 State=UNKNOWN
PartitionName=picluster Nodes=node[01-02] Default=YES MaxTime=INFINITE State=UP
```
Now we need to create a configuration for cgroup support
```console
pi@master ~> sudo nano /etc/slurm-llnl/cgroup.conf
```
Now, add the following,
```console
CgroupMountpoint="/sys/fs/cgroup"
CgroupAutomount=yes
CgroupReleaseAgentDir="/etc/slurm-llnl/cgroup"
AllowedDevicesFile="/etc/slurm-llnl/cgroup_allowed_devices_file.conf"
ConstrainCores=no
TaskAffinity=no
ConstrainRAMSpace=yes
ConstrainSwapSpace=no
ConstrainDevices=no
AllowedRamSpace=100
AllowedSwapSpace=0
MaxRAMPercent=100
MaxSwapPercent=100
MinRAMSpace=30
```

Now, we need to whitelist system devices by creating the file 

```console
pi@master ~> sudo nano /etc/slurm-llnl/cgroup_allowed_devices_file.conf
```
Now add the following lines,
```console
/dev/null
/dev/urandom
/dev/zero
/dev/sda*
/dev/cpu/*/*
/dev/pts/*
/shared*
```
Now we need to set the same for all nodes. To do that we need to copy these files to the shared storage.
```console
pi@master ~> sudo cp /etc/slurm-llnl/*.conf /shared
pi@master ~> sudo cp /etc/munge/munge.key /shared
```

All done, now we need to enable and start SLURM Control Services and munge,
```console
pi@master ~> sudo systemctl enable munge
pi@master ~> sudo systemctl start munge
```
```console
pi@master ~> sudo systemctl enable slurmd
pi@master ~> sudo systemctl start slurmd
```
```console
pi@master ~> sudo systemctl enable slurmctld
pi@master ~> sudo systemctl start slurmctld
```

To ensure smooth operation, we need to reboot the system at this point.

# Step - 6: Configuring SLURM on Compute Nodes

We have successfully configured the master node, we need to do the same on compute nodes. Now, log into the one of the nodes and install slurm
```console
pi@node01 ~> sudo apt install slurmd slurm-client -y
```
Upon installation, we need to copy the configuration files from the shared storage to the node.
```console
pi@node01 ~> sudo cp /shared/munge.key /etc/munge/munge.key
pi@node01 ~> sudo cp /shared/*.conf /etc/slurm-llnl/
```
Similar to the master node, we need to enable and start slurm daemon and munge on the nodes.
```console
pi@node01 ~> sudo systemctl enable munge
pi@node01 ~> sudo systemctl start munge
```
```console
pi@node01 ~> sudo systemctl enable slurmd
pi@node01 ~> sudo systemctl start slurmd
```

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
picluster*    up   infinite      3   idle node[01-03]
```

To resume the nodes
```console
sudo scontrol update NodeName=node[01-03] state=resume
```
You can simply run a task to ask the hostname for each node
```console
pi@master ~>srun --nodes=3 hostname
```
It will give you an output similar to
```console
node02
node03
node01
```
# Step - 8: Powering On and Off (Cluster)
Write a shell script with the following lines of codes and save it as clusterup.sh
```console
#!/bin/bash
sudo scontrol update NodeName=node[01-03] state=resume
sinfo
echo "Nodes up and running"
```

Now, you need to setup password less super user access to perform the next action. To do that efficiently, we need to create admin groups
```console
sudo groupadd admin
```
Now add your users (or yourself) to that group
```console
sudo usermod –a –G admin pi
```
Now edit sudoers file 
```console
sudo vim /etc/sudoers
```
Add these lines or edit accordingly
```console
# User privilege specification
root	ALL=(ALL:ALL) ALL
# Allow members of group sudo to execute any command
%sudo	ALL=(ALL:ALL) ALL
%admin	ALL=(ALL) ALL
# See sudoers(5) for more information on "#include" directives:
%admin	ALL=(ALL) NOPASSWD: ALL
```
REPEAT this process for each node. Starting from admin group add.
Write a shell script with the following lines of codes and save it as clusterdown.sh
```console
#!/bin/bash
echo "WiPi Cluster Shutdown"
echo "====================="
sudo scontrol update NodeName=node[01-03] state=down reason="power down"
ssh node01 "sudo halt"
ssh node02 "sudo halt"
ssh node03 "sudo halt"
echo "Nodes disconnected and shutting down"
echo "Do you want to shutdown master node too?"
echo "Press 'y' to continue or q to abort"
count=0
while : ; do
read -n 1 k <&1
if [[ $k = y ]] ; then
printf "\nShutting down Master Node\n"
sudo halt
elif [[ $k = q ]] ; then
printf "\nShutdown aborted\n" 
break
else
((count=$count+1))
printf "\nWrong Key Pressed\n"
echo "Press 'q' to abort"
fi
done
```

Now make these scripts executable using the following command
```console
pi@master ~>chmod a+x clusterup.sh
pi@master ~>chmod a+x clusterup.sh
```
Each time you power on your cluster, run this script at the startup using the following command.
```console
pi@master ~>./clusterup.sh
```
Each time you need to power off your cluster, run this script at the end using the following command.
```console
pi@master ~>./clusterdown.sh
```

# Step - 9: Password-less SSH

Now, we’ll set up password-less SSH on master node
```console
pi@master ~> ssh-keygen -t rsa
```
This would ask you for input, each time press enter key to proceed. After successful operation, the output will look like the following
```console
Generating public/private rsa key pair.
Enter file in which to save the key (/home/pi/.ssh/id_rsa): 
Created directory '/home/pi/.ssh'.
Enter passphrase (empty for no passphrase): 
Enter same passphrase again: 
Your identification has been saved in /home/pi/.ssh/id_rsa.
Your public key has been saved in /home/pi/.ssh/id_rsa.pub.
The key fingerprint is:
9b:98:c7:86:17:0a:1e:32:95:65:ee:1c:0f:48:48:ef pi@beira
The key's randomart image is:
+---[RSA 2048]----+
| .... o          |
|  .o *           |
|    = +          |
|   o o +         |
|  o E o S        |
|   + o * +       |
|    . = B        |
|       +         |
|                 |
+-----------------+
```
Now copy your rsa key to all the nodes
```console
pi@master ~> ssh-copy-id pi@node01
```
```console
pi@master ~> ssh-copy-id pi@node02
```
```console
pi@master ~> ssh-copy-id pi@node03
```
# Step - 10: OpenMPI

OpenMPI is the Open sourced Message Passing Interface. In short it is a very abstract description on how messages can be exchanged between different processes. It will allow us to run a job across multiple nodes connected to the same cluster.
```console
pi@master ~>sudo su -
#srun —-nodes=3 apt install openmpi-bin openmpi-common libopenmpi3 libopenmpi-dev -y
```
Note: the number 3 was chosen based on our available nodes.

If you are interested in using master node as well, you need to install the same for master node too.
```console
pi@master ~>sudo apt install openmpi-bin openmpi-common libopenmpi3 libopenmpi-dev -y
```
Now create a host file to run MPI jobs
```console
pi@master ~>nano hostfile
```
Now add the following (Change the ip addresses accordingly)
```console
10.10.0.11:4
10.10.0.12:4
10.10.0.13:4
```
NOTE: The last number “4” represents the number of cores(processors) in each CPU.

Now, we are ready to use MPI on our cluster. Let’s test a sample script.

Create a hello world program in C and save it as hello_mpi.c
```c
#include <mpi.h>
#include <stdio.h>

int main(int argc, char** argv) {
    // Initialize the MPI environment
    MPI_Init(NULL, NULL);

    // Get the number of processes
    int world_size;
    MPI_Comm_size(MPI_COMM_WORLD, &world_size);

    // Get the rank of the process
    int world_rank;
    MPI_Comm_rank(MPI_COMM_WORLD, &world_rank);

    // Get the name of the processor
    char processor_name[MPI_MAX_PROCESSOR_NAME];
    int name_len;
    MPI_Get_processor_name(processor_name, &name_len);

    // Print off a hello world message
    printf("Hello world from processor %s, rank %d"
           " out of %d processors\n",
           processor_name, world_rank, world_size);

    // Finalize the MPI environment.
    MPI_Finalize();
}
```
Now, compile the program using mpicc
```console
mpicc hello_mpi.c
```
This would create an executable name a.out
You can run the executable using the following command
```console
mpirun -np 3 -hostfile hostfile ./a.out
```
Now, let’s test the same using SLURM job manager. In order to do so, first we have to create a job script. Create a file named hello_mpi.sh and enter the following lines
```console
#!/bin/bash
#SBATCH --nodes=3
#SBATCH --ntasks-per-node=4
#SBATCH --partition=picluster
cd $SLURM_SUBMIT_DIR
mpicc hello_mpi.c -o hello_mpi
mpirun ./hello_mpi
```
NOTE: The number 3 represents the number of nodes available in your cluster and the number 4 represents the number of cores(processors) available in each node.

To submit a job use the following command
```console
sbatch hello_mpi.sh 
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



