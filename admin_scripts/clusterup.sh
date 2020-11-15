#!/bin/bash
sudo scontrol update NodeName=node[01-03] state=resume
#sudo scontrol update NodeName=node01 state=resume
sinfo
echo "Nodes up and running"
