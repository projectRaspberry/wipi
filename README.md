Building HPC with Raspberry Pi
===========================
# Step - 0: The Hardware
 - 3x Raspberry Pi 4 Model B - for compute nodes
 - 1x Raspberry Pi 4 Model B - for master/login node
 - 4x MicroSD Cards
 - 4x USB-C power cables
 - 1x 5-port 10/100/1000 network switch
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



