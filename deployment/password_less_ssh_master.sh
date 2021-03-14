#!/bin/bash

#exit if any command fails
set -e

echo "Generating RSA Key for authentication"
ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

echo "copying rsa key to the nodes"
echo -e "yes\nraspberry\n" | ssh-copy-id pi@node01
echo -e "yes\nraspberry\n" | ssh-copy-id pi@node02
