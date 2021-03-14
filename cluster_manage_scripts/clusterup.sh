#!/bin/bash
sudo scontrol update NodeName=node[01-02] state=resume
#sudo scontrol update NodeName=node01 state=resume
sinfo
echo "Nodes up and running"
