#!/bin/bash

# Exit immediately if a command exits with a non-zero status
set -e

# === Variables ===
TOMCAT_VERSION="10.1.41"
TOMCAT_USER="tomcat"
TOMCAT_PASS="root123456"
TOMCAT_DIR="apache-tomcat-${TOMCAT_VERSION}"
TOMCAT_TAR="${TOMCAT_DIR}.tar.gz"
TOMCAT_URL="https://dlcdn.apache.org/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/${TOMCAT_TAR}"

# === Install Java OpenJDK 11 ===
echo "[*] Installing Java OpenJDK 11..."
sudo amazon-linux-extras enable java-openjdk11 -y
sudo yum clean metadata
sudo yum install java-11-openjdk -y

# === Download and Extract Tomcat ===
echo "[*] Downloading Tomcat ${TOMCAT_VERSION}..."
wget -q ${TOMCAT_URL}

echo "[*] Extracting Tomcat..."
tar -zxf ${TOMCAT_TAR}
rm -f ${TOMCAT_TAR}

# === Configure tomcat-users.xml ===
echo "[*] Configuring Tomcat users and roles..."
cat > ${TOMCAT_DIR}/conf/tomcat-users.xml <<EOF
<tomcat-users>
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <user username="${TOMCAT_USER}" password="${TOMCAT_PASS}" roles="manager-gui,manager-script"/>
</tomcat-users>
EOF

# === Remove IP Restrictions in Manager App ===
echo "[*] Removing IP access restrictions in manager context.xml..."
sed -i '/<Valve className="org.apache.catalina.valves.RemoteAddrValve"/d' ${TOMCAT_DIR}/webapps/manager/META-INF/context.xml
sed -i '/allow="127\.\d+\.\d+\.\d+\|::1"/d' ${TOMCAT_DIR}/webapps/manager/META-INF/context.xml

# === Make Tomcat executable and start ===
echo "[*] Starting Tomcat server..."
chmod +x ${TOMCAT_DIR}/bin/*.sh
sh ${TOMCAT_DIR}/bin/startup.sh

# === Output ===
echo "[✓] Tomcat installed and running."
echo "Access URL: http://<your-ec2-public-ip>:8080"
echo "Username: ${TOMCAT_USER}"
echo "Password: ${TOMCAT_PASS}"
