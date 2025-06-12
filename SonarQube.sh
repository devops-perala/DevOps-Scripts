#! /bin/bash
cd /opt/
wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.6.50800.zip
unzip sonarqube-8.9.6.50800.zip
amazon-linux-extras install java-openjdk11 -y
useradd sonar
chown sonar:sonar sonarqube-8.9.6.50800 -R
chmod 777 sonarqube-8.9.6.50800 -R
su - sonar
# use the below command manually after installation
#sh /opt/sonarqube-8.9.6.50800/bin/linux-x86-64/sonar.sh start
#echo "user=admin & password=admin"

********************************************************************88

#!/bin/bash

set -e  # Exit on error

echo "=== Step 1: Installing Java OpenJDK 11 ==="
sudo amazon-linux-extras install java-openjdk11 -y

echo "=== Step 2: Downloading SonarQube ==="
cd /opt/
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.6.50800.zip
sudo unzip sonarqube-8.9.6.50800.zip
sudo rm -f sonarqube-8.9.6.50800.zip

echo "=== Step 3: Creating 'sonar' user ==="
sudo useradd -r -s /bin/bash sonar || echo "User 'sonar' already exists"
sudo chown -R sonar:sonar /opt/sonarqube-8.9.6.50800

echo "=== Step 4: Setting permissions ==="
# Safer than chmod 777
sudo chmod -R 755 /opt/sonarqube-8.9.6.50800

echo "=== Step 5: Starting SonarQube as 'sonar' user ==="
sudo -u sonar /opt/sonarqube-8.9.6.50800/bin/linux-x86-64/sonar.sh start

echo "=== SonarQube Started Successfully ==="
echo "Access SonarQube at: http://<your-server-ip>:9000"
echo "Default credentials => username: admin, password: admin"
