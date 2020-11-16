Building HPC with Raspberry Pi
===========================
#Step - 0: The Hardware
 - 3x Raspberry Pi 4 Model B - for compute nodes
 - 1x Raspberry Pi 4 Model B - for master/login node
 - 4x MicroSD Cards
 - 4x USB-C power cables
 - 1x 5-port 10/100/1000 network switch
 - 1x 6-port USB power-supply (optional)
 - 1x 128GB SSD (optional)

To download Raspbian Lite OS
```console
wget https://downloads.raspberrypi.org/raspbian_lite_latest -O raspbian_lite_latest.zip
```
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



