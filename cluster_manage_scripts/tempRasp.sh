#!/bin/bash

echo "WiPi Cluster CPU Temperature Check"
echo "Temperature Master"
sudo /opt/vc/bin/vcgencmd measure_temp
echo "Temperature Node01"
ssh node01 'sudo /opt/vc/bin/vcgencmd measure_temp'

echo "Temperature Node02"
ssh node02 'sudo /opt/vc/bin/vcgencmd measure_temp'

echo "All done"
