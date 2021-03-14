#!/bin/bash

#exit if any command fails
set -e

echo "Generating RSA Key for authentication"
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

echo "raspberry">~/passwd.txt
echo "copying rsa key to the nodes"
sshpass -f ~/passwd.txt ssh-copy-id pi@node01
sshpass -f ~/passwd.txt ssh-copy-id pi@node02
