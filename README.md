HPC with Raspberry Pi
===========================


wget https://downloads.raspberrypi.org/raspbian_lite_latest -O raspbian_lite_latest.zip

To install Gkeyll in WiPi:

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
