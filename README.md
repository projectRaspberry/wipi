HPC with Raspberry Pi
===========================

To download Raspbian Lite OS

wget https://downloads.raspberrypi.org/raspbian_lite_latest -O raspbian_lite_latest.zip

Note: To run shell scripts seemlessly add these lines at the bottom of your .bashrc files (/home/<username>/.bashrc) provided the name of your shared nfs drive is "nfsdrive" and you have stored all the scripts inside admin_scripts directory.

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



