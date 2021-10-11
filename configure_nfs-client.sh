#!/bin/bash

reset=$(tput sgr 0)
green=$(tput setaf 2)
red=$(tput setaf 1)
mag=$(tput setaf 5)
blue=$(tput setaf 6)
true="${green}[OK]${reset}"
false="${red}[KO]${reset}"

echo ${blue} ${pipe} "##Start Configuration##" ${pipe} ${reset}

echo ${blue} ${pipe} "##Install NFS tools##" ${pipe} ${reset}
sudo apt-get install portmap nfs-common


echo ${blue} ${pipe} "##Create New User##" ${pipe} ${reset}

uuid_checker=$(getent "passwd" "4242")
cmd_status=$?

cd ~

if [ $cmd_status -eq 2 ]
then
    sudo useradd -m -u 4242 nfsclient
    sudo passwd nfsclient
    sudo usermod -aG sudo nfsclient
    echo ${green} ${pipe} "##User has been created##" ${pipe} ${reset}
else
    echo ${red} ${pipe} "##UUID already in use##" ${pipe} ${reset}
    exit 1
fi


echo ${blue} ${pipe} "##Mount NFS repertory##" ${pipe} ${reset}
sudo -i -u nfsclient bash << EOF
mkdir /home/nfsclient/nfs
sudo mount -t nfs4 hard,intr 192.170.160.110:/srv/nfs4 /home/nfsclient/nfs
cmd_status=$?

if [ cmd_status -eq 0 ]
then
    echo ${green} ${pipe} "##NFS Repositiry Mount Succes##" ${pipe} ${reset}
    echo "192.170.160.110:/srv/nfs4 /home/nfsclient/nfs hard,intr 0 0" >> /etc/fstab
else
    echo ${red} ${pipe} "##NFS Repository Mount Fail##" ${pipe} ${reset}
    exit 1
fi

echo ${blue} ${pipe} "##Test Read-Write Access##" ${pipe} ${reset}

touch $HOSTNAME
write_status=$?

if [ $write_status -eq 0 ]
then
    echo ${green} ${pipe} "##Write Success##" ${pipe} ${reset}
else
    echo ${red} ${pipe} "##Write Success##" ${pipe} ${reset}



echo "test writting permission" > ./$HOSTANME
write_status=$?

if [ $write_status -eq 0 ]
then
    echo ${green} ${pipe} "##Write into file Success##" ${pipe} ${reset}
else
    echo ${red} ${pipe} "##Write into file fail##" ${pipe} ${reset}
    exit 1
fi

cat ./$HOSTANAME
read_status=$?

if [ $read_status -eq 0 ]
then
    echo ${green} ${pipe} "##Read file Success##" ${pipe} ${reset}
else
    echo ${red} ${pipe} "##Read file Fail##" ${pipe} ${reset}
    exit 1
fi
EOF
echo ${blue} ${pipe} "##End Configuration##" ${pipe} ${reset}
