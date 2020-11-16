Building HPC with Raspberry Pi
===========================
# Step - 0: The Hardware
 - 3x Raspberry Pi 4 Model B - for compute nodes
 - 1x Raspberry Pi 4 Model B - for master/login node
 - 4x MicroSD Cards
 - 4x USB-C power cables
 - 1x 5-port Wireless Router
 - 1x 5-port 10/100/1000 network switch (Optional)
 - 1x 6-port USB power-supply (optional)
 - 1x 128GB SSD (optional)

# Step - 1: Prepare Raspberry Pi OS
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

# Step - 2: Prepare Raspberry Pis

Now plug in all the four memory cards in to the storage port of Raspberry Pis. Then connect the network cables(CAT5/6/6A) to in the ethernet port of Pis. Do not power on the Pis at the moment.

# Step - 3: Network Setup

To do this part, you need a wireless router with DHCP enabled. The [Dynamic Host Configuration Protocol (DHCP)](https://en.wikipedia.org/wiki/Dynamic_Host_Configuration_Protocol) will allocate IPs as soon as we connect our Raspberry Pis to the network. If you have network switch, first plugin the other end of the ethernet cables connected to Pis. Now plugin one extra cable from switch to Wireless router. Physical network complete. Now power on the wireless router and the switch. 

**Note**: *If you do not have the network switch, then connect the network cables directly to the wireless router.*

Now, login to the wireless router management page using browser. If your laptop is connected to the same network, just type the gateway IP. e.g. if you IP is 192.168.1.3, usually your gateway is 192.168.1.1, it's really simple. If you have trouble getting into the management page look for proper information on the router body. It's written somewhere on the body. After getting into the management page, go to the connected devices page and keep it open.

Now, power on the master node first by connecting the USB-C cable from a power outlet (or the 6-port USB power supply) and keep refresing the page. If everything goes well, you should see a new device named raspberrypi connected to the network. Now note down the IPV4 address associated with it.

Next, power on the one off the compute nodes and do the same (note it as node01). Repeat the process for all the compute nodes. At the end, you should have something similar to the following information with you:

* master IPV4: **192.168.1.5**
* node01 IPV4: **192.168.1.6**
* node02 IPV4: **192.168.1.7**
* node03 IPV4: **192.168.1.8**

**Note**: *If you have options to reserve IP on your wireless router management page, it is advised to do so for all the Pis. However, it is not mangetory.*



######################################


Note: To run shell scripts seemlessly add these lines at the bottom of your .bashrc files (/home/username/.bashrc) provided the name of your shared nfs drive is "nfsdrive" and you have stored all the scripts inside admin_scripts directory.

```console
alias tempcheck='/nfsdrive/admin_scripts/tempRasp.sh'
alias clusterup='/nfsdrive/admin_scripts/clusterup.sh'
alias clusterdown='/nfsdrive/admin_scripts/clusterdown.sh'
```
To install Gkeyll on WiPi:

Just comment out line 33 in file gkyl.cxx

Also comment out the lines in main():
```c
#if defined(__clang__)
  fesetenv(FE_DFL_DISABLE_SSE_DENORMS_ENV);
#elif defined(__powerpc__)
  // not sure what the POWER calls are for denormalized floats
#elif defined(__GNUC__) || defined(__GNUG__)
  _MM_SET_FLUSH_ZERO_MODE(_MM_FLUSH_ZERO_ON);
#endif
```



