HPC with Raspberry Pi
===========================

To download Raspbian Lite OS

wget https://downloads.raspberrypi.org/raspbian_lite_latest -O raspbian_lite_latest.zip

Note: To run shell scripts seemlessly

Add these lines at the bottom of your .bashrc files (/home/<username>/.bashrc)

```console
alias tempcheck='/clusterfs/admin_scripts/temprasp.sh'
alias clusterup='/clusterfs/admin_scripts/resume_cluster.sh'
alias clusterdown='/clusterfs/admin_scripts/shutdown_cluster.sh'
alias wipiusradd='/clusterfs/admin_scripts/wipi_usradd.sh'


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




