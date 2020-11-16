#!/usr/bin/expect

######## GENERATE RSA KEY FOR PASSWORD LESS SSH ###############
echo "GENERATE RSA KEY FOR PASSWORD LESS SSH"
echo "======================================"
read -p 'Enter total number of compute nodes: ' numNodes
echo -e "\n\n\n" | ssh-keygen -t rsa

######## COPY SSH KEY TO NODES ############
nCount=1
while [ $nCount -le $numNodes ]
do
  echo -e "raspberry\n" | ssh-copy-id pi@${nodeIp[$nCount]}
  ((nCount++))
done
