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

# Detect OS and install Java
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
    VERSION_ID=$VERSION_ID
else
    echo "Unable to detect OS."
    exit 1
fi

case "$OS" in
  amzn)
    if [[ "$VERSION_ID" == "2" ]]; then
      sudo yum install -y amazon-linux-extras
      sudo amazon-linux-extras enable java-openjdk11
      sudo yum install -y java-11-openjdk
    else
      sudo dnf install -y java-11-amazon-corretto
    fi
    ;;
  centos|rhel)
    sudo yum install -y java-11-openjdk
    ;;
  ubuntu|debian)
    sudo apt update
    sudo apt install -y openjdk-11-jdk
    ;;
  *)
    echo "Unsupported OS: $OS"
    exit 1
    ;;
esac

echo "=== Step 2: Downloading SonarQube ==="
cd /opt/
sudo wget https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-8.9.6.50800.zip
sudo unzip -o sonarqube-8.9.6.50800.zip
sudo rm -f sonarqube-8.9.6.50800.zip

echo "=== Step 3: Creating 'sonar' user ==="
sudo useradd -r -s /bin/bash sonar || echo "User 'sonar' already exists"
sudo chown -R sonar:sonar /opt/sonarqube-8.9.6.50800

echo "=== Step 4: Setting permissions ==="
sudo chmod -R 755 /opt/sonarqube-8.9.6.50800

echo "=== Step 5: Starting SonarQube as 'sonar' user ==="
sudo -u sonar /opt/sonarqube-8.9.6.50800/bin/linux-x86-64/sonar.sh start

echo "=== SonarQube Started Successfully ==="
echo "Access SonarQube at: http://<your-server-ip>:9000"
echo "Default credentials => username: admin, password: admin"

