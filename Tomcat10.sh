#!/bin/bash

# Exit immediately if a command fails
set -e

# === Install Java OpenJDK 11 ===
echo "Installing Java OpenJDK 11..."
sudo amazon-linux-extras install java-openjdk11 -y

# === Download and extract Tomcat 10.1.41 ===
echo "Downloading and extracting Tomcat 10.1.41..."
wget https://dlcdn.apache.org/tomcat/tomcat-10/v10.1.41/bin/apache-tomcat-10.1.41.tar.gz
tar -zxvf apache-tomcat-10.1.41.tar.gz

# === Configure Tomcat user ===
echo "Configuring Tomcat user and roles..."

TOMCAT_DIR="apache-tomcat-10.1.41"
USERS_FILE="$TOMCAT_DIR/conf/tomcat-users.xml"

# Insert roles and user
sed -i '56 a\<role rolename="manager-gui"/>' $USERS_FILE
sed -i '57 a\<role rolename="manager-script"/>' $USERS_FILE
sed -i '58 a\<user username="tomcat" password="root123456" roles="manager-gui,manager-script"/>' $USERS_FILE
sed -i '59 a\</tomcat-users>' $USERS_FILE
sed -i '56d' $USERS_FILE

# === Remove IP restrictions from Manager webapp ===
echo "Removing IP access restrictions on Manager app..."
CONTEXT_FILE="$TOMCAT_DIR/webapps/manager/META-INF/context.xml"
sed -i '21d' $CONTEXT_FILE
sed -i '22d' $CONTEXT_FILE

# === Start Tomcat ===
echo "Starting Tomcat..."
sh $TOMCAT_DIR/bin/startup.sh

echo "Tomcat installed and running."
echo "Access: http://<your-ec2-ip>:8080"
echo "Login: tomcat / root123456"
