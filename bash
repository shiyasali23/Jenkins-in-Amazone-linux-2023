#!/bin/bash

# Update package references
sudo dnf update -y

# Install Java
sudo dnf install java-17-amazon-corretto -y

# Create Jenkins directory
sudo mkdir /opt/jenkins
sudo chown -R jenkins:jenkins /opt/jenkins
sudo chmod -R 755 /opt/jenkins

# Add Jenkins repository and install Jenkins
sudo wget -O /etc/yum.repos.d/jenkins.repo https://pkg.jenkins.io/redhat-stable/jenkins.repo
sudo rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
sudo dnf install jenkins -y

# Configure Jenkins service
sudo sed -i 's|Environment="JENKINS_HOME=/var/lib/jenkins"|Environment="JENKINS_HOME=/opt/jenkins"|g' /usr/lib/systemd/system/jenkins.service
sudo sed -i 's|WorkingDirectory=/var/lib/jenkins|WorkingDirectory=/opt/jenkins|g' /usr/lib/systemd/system/jenkins.service
sudo sed -i 's|ExecStart=/usr/bin/java -jar /usr/share/java/jenkins.war|ExecStart=/usr/bin/java -Djava.io.tmpdir=/opt/jenkins/tmp -Djava.awt.headless=true -jar /usr/share/java/jenkins.war --webroot=/opt/jenkins/cache/war --httpPort=8080|g' /usr/lib/systemd/system/jenkins.service

# Create necessary directories
sudo mkdir -p /opt/jenkins/cache/war
sudo mkdir -p /opt/jenkins/tmp
sudo mkdir -p /opt/jenkins/workspace
sudo chown -R jenkins:jenkins /opt/jenkins
sudo chmod -R 755 /opt/jenkins

# Reload and start Jenkins
sudo systemctl daemon-reload
sudo systemctl enable jenkins
sudo systemctl start jenkins

# Verify Jenkins is running
sudo systemctl status jenkins

# Get initial admin password
sudo cat /opt/jenkins/secrets/initialAdminPassword

# Set up swap space
sudo dd if=/dev/zero of=/swapfile bs=1M count=2048
sudo chmod 600 /swapfile
sudo mkswap /swapfile
sudo swapon /swapfile
echo '/swapfile none swap sw 0 0' | sudo tee -a /etc/fstab

# Adjust swappiness
sudo sysctl vm.swappiness=30
