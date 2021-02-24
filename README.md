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

Repeat this process for all four memory cards. Now insert the cards to your Raspberry Pis. Remember to mark the master node to separate it from others.

Now plug in all the four memory cards in to the storage port of Raspberry Pis. Then connect the network cables(CAT5/6/6A) to in the ethernet port of Pis. Do not power on the Pis at the moment.

# Step - 2: Network Setup

To do this part, you need a wireless router with DHCP enabled. The [Dynamic Host Configuration Protocol (DHCP)](https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol) will allocate IPs as soon as we connect our Raspberry Pis to the network. If you have network switch, first plugin the other end of the ethernet cables connected to Pis. Now plugin one extra cable from switch to Wireless router. Physical network complete. Now power on the wireless router and the switch. 

**Note**: *If you do not have the network switch, then connect the network cables directly to the wireless router.*

Now, login to the wireless router management page using browser. If your laptop is connected to the same network, just type the gateway IP. e.g. if you IP is 192.168.1.2, usually your gateway is 192.168.1.1, it's really simple. If you have trouble getting into the management page look for proper information on the router body. It's written somewhere on the body. After getting into the management page, go to the connected devices page and keep it open.

Now, power on the master node first by connecting the USB-C cable from a power outlet (or the 6-port USB power supply) and keep refresing the page. If everything goes well, you should see a new device named **raspberrypi** connected to the network. Now note down the IPV4 address associated with it.

Next, power on the one off the compute nodes and do the same (note it as node01). Repeat the process for all the compute nodes. At the end, you should have something similar to the following information with you:

* master IPV4: **192.168.1.3**
* node01 IPV4: **192.168.1.4**
* node02 IPV4: **192.168.1.5**
* node03 IPV4: **192.168.1.6**

Now, try to ping each of the Pis from your computer terminal and wait for couple of seconds, then kill it by pressing  Ctrl + c.
```console
ping 192.168.1.3
```
You should get an output very similar to the following
```console
PING 192.168.1.5: 56 data bytes
64 bytes from 192.168.1.3: icmp_seq=0 ttl=59 time=1.947 ms
64 bytes from 192.168.1.3: icmp_seq=1 ttl=59 time=3.582 ms
64 bytes from 192.168.1.3: icmp_seq=2 ttl=59 time=3.595 ms
64 bytes from 192.168.1.3: icmp_seq=3 ttl=59 time=3.619 ms
...
--- 192.168.1.3 ping statistics ---
6 packets transmitted, 6 packets received, 0.0% packet loss
round-trip min/avg/max/stddev = 1.947/3.317/3.635/0.614 ms
```

**Note**: *If you have options to reserve IP on your wireless router management page, it is advised to do so for all the Pis. However, it is not mandetory.*

# Step - 3: Setting Up the Master Node

Now, log in to your master node using
```console
ssh pi@192.168.2.2
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
Now, we need to decide the hostnames for master node as well as cluster nodes. I would recommend to stick with the usual ones. Set “master” for master node and for cluster nodes starting from “node01” to “node03” (for 3 node cluster). Use the following command to set it up on master node.
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
192.168.2.2     master
192.168.2.3     node01
192.168.2.4     node02
192.168.2.5     node03
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

Now, we need to create a directory where the storage will be mounted. We can choose any name for that. But, lets choose something that is easy to remember e.g. “shared”,
```console
sudo mkdir /nfsdrive
sudo chown nobody.nogroup -R /shared
sudo chmod 777 -R /shared
```

Now, we need to configure to mount the storage during boot. For, that we need the the UUID of the storage. We can find that using the following command,
```console
pi@master ~> blkid
```
Now, copy the number from /dev/sda1. It’ll look like
UUID=“78543e7a-4hy6-7yea-1274-01e0ff974531”

Now, open and edit fstab to mount the drive on boot.
```console
pi@master ~> sudo nano /etc/fstab
```
Add the following line:
```console
UUID=78543e7a-4hy6-7yea-1274-01e0ff974531 /nfsdrive ext4 defaults 0 2
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
/shared 192.168.2.0/24(rw,sync,no_root_squash,no_subtree_check)
```
Remember, depending upon the IP address schema used on your local network, the ip will be different for setup. For example, if your master node ip is 10.0.0.1, then you need to replace the ip with 10.0.0.0/24.

Now, we can update the configuration of the NFS kernel with the following command,
```console
sudo exportfs -a
```
One of the tasks for NFS to work remains unfinished which we will do in the next section.

# Step - 4: Setting Up the Worker Nodes
We have already decided the IPs for worker nodes [See Step - 2](#step-2)

# Step - 5: Test SSH

[SSH or Secure Shell](https://en.wikipedia.org/wiki/SSH_(Secure_Shell)) provides a secure channel over an unsecured network by using a client–server architecture, connecting an SSH client application with an SSH server. We need to make sure we are able to acess  command-line and remotely execute shell commands on the Pis.

Type the following,
```console
ssh pi@192.168.1.5
```
It would ask you for password with the following output
```console
pi@192.168.1.5's password:
```
Enter **raspberry** as the default password. After successful login it would look like:
```console
pi@raspberrypi:
```
Test the same for all the three compute nodes.




