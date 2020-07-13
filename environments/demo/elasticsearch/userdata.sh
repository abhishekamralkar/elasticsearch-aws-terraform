#!/usr/bin/env bash

yum install epel-release -y
yum install figlet -y
SSH_USER=ec2-user
# Generate system banner
sudo sh -c 'echo "Welcome User" > /etc/motd'

