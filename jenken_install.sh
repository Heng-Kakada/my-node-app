#!/bin/bash

# Update system packages
echo "Updating system packages..."
sudo apt update -y

# Install Java (Jenkins requires Java to run)
echo "Installing OpenJDK 17..."
sudo apt install fontconfig openjdk-17-jre -y

# Import the Jenkins GPG key
echo "Adding Jenkins repository key..."
sudo wget -O /usr/share/keyrings/jenkins-keyring.asc \
  https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key

# Add the Jenkins software repository
echo "Adding Jenkins repository to sources..."
echo "deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] \
  https://pkg.jenkins.io/debian-stable binary/" | sudo tee \
  /etc/apt/sources.list.d/jenkins.list > /dev/null

# Update package list again to include Jenkins repo
sudo apt update -y

# Install Jenkins
echo "Installing Jenkins..."
sudo apt install jenkins -y

# Start and enable Jenkins service
echo "Starting Jenkins service..."
sudo systemctl start jenkins
sudo systemctl enable jenkins

# Display Initial Admin Password
echo "-------------------------------------------------------"
echo "Installation Complete!"
echo "Jenkins is running on http://$(hostname -I | awk '{print $1}'):8080"
echo "Initial Admin Password:"
sudo cat /var/lib/jenkins/secrets/initialAdminPassword
echo "-------------------------------------------------------"