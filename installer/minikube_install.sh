#!/bin/bash

# 1. Update system and install dependencies
echo "Updating system packages..."
sudo apt-get update -y && sudo apt-get upgrade -y
sudo apt-get install -y curl apt-transport-https

# 2. Download the Minikube binary
echo "Downloading Minikube..."
curl -LO https://github.com/kubernetes/minikube/releases/latest/download/minikube-linux-amd64

# 3. Install Minikube
echo "Installing Minikube..."
sudo install minikube-linux-amd64 /usr/local/bin/minikube

# 4. Clean up the installer
echo "Clean up Minikube..."
rm minikube-linux-amd64

# 5. Verify installation
echo "Minikube version:"
minikube version