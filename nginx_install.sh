#!/bin/bash

# Update system packages
echo "Install Nginx"
sudo apt update -y
sudo apt install nginx

sudo systemctl status nginx
sudo systemctl start nginx
sudo systemctl enable nginx