#!/bin/bash
sleep 30 ,
sudo yum update
sudo amazon-linux-extras enable nginx1
sudo yum -y install nginx
sudo systemctl enable nginx
