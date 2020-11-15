#!/bin/bash
sudo scontrol update NodeName=node[01-03] state=resume
#sudo scontrol update NodeName=node01 state=resume
sinfo
echo "Nodes up and running"
sayan@master:/clusterfs/admin_scripts $ cat clusterdown.sh 
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
done#!/bin/bash
sudo scontrol update NodeName=node[01-03] state=resume
#sudo scontrol update NodeName=node01 state=resume
sinfo
echo "Nodes up and running"
