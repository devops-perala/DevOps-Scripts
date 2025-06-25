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

************************************************************************88
#!/bin/bash

set -e

# === Variables ===
TOMCAT_VERSION="10.1.41"
TOMCAT_USER="tomcat"
TOMCAT_PASS="root123456"
INSTALL_DIR="/opt/tomcat"
TOMCAT_TAR="apache-tomcat-${TOMCAT_VERSION}.tar.gz"
TOMCAT_URL="https://dlcdn.apache.org/tomcat/tomcat-10/v${TOMCAT_VERSION}/bin/${TOMCAT_TAR}"

# === Install Java OpenJDK 17 via Amazon Corretto (AL2023 compatible) ===
echo "[*] Installing Amazon Corretto OpenJDK 17..."
sudo rpm --import https://yum.corretto.aws/corretto.key
sudo curl -Lo /etc/yum.repos.d/corretto.repo https://yum.corretto.aws/corretto.repo
sudo dnf install -y java-17-amazon-corretto wget

# === Create Tomcat user ===
echo "[*] Creating tomcat user..."
sudo useradd -r -m -U -d ${INSTALL_DIR} -s /bin/false ${TOMCAT_USER} || true

# === Download and Install Tomcat ===
echo "[*] Downloading Tomcat ${TOMCAT_VERSION}..."
cd /tmp
wget -q ${TOMCAT_URL}

echo "[*] Installing Tomcat to ${INSTALL_DIR}..."
sudo mkdir -p ${INSTALL_DIR}
sudo tar -xf ${TOMCAT_TAR} -C ${INSTALL_DIR} --strip-components=1
rm -f ${TOMCAT_TAR}

# === Set Permissions ===
echo "[*] Setting permissions..."
sudo chown -R ${TOMCAT_USER}:${TOMCAT_USER} ${INSTALL_DIR}
sudo chmod +x ${INSTALL_DIR}/bin/*.sh

# === Configure Tomcat Users ===
echo "[*] Configuring tomcat-users.xml..."
sudo tee ${INSTALL_DIR}/conf/tomcat-users.xml > /dev/null <<EOF
<tomcat-users>
  <role rolename="manager-gui"/>
  <role rolename="manager-script"/>
  <user username="${TOMCAT_USER}" password="${TOMCAT_PASS}" roles="manager-gui,manager-script"/>
</tomcat-users>
EOF

# === Remove IP restrictions from manager context ===
echo "[*] Removing IP access restrictions..."
sudo sed -i '/<Valve className="org.apache.catalina.valves.RemoteAddrValve"/d' ${INSTALL_DIR}/webapps/manager/META-INF/context.xml
sudo sed -i '/allow="127\.\d+\.\d+\.\d+\|::1"/d' ${INSTALL_DIR}/webapps/manager/META-INF/context.xml

# === Create systemd Service ===
echo "[*] Creating systemd service for Tomcat..."
sudo tee /etc/systemd/system/tomcat.service > /dev/null <<EOF
[Unit]
Description=Apache Tomcat
After=network.target

[Service]
Type=forking

User=${TOMCAT_USER}
Group=${TOMCAT_USER}

Environment="JAVA_HOME=$(dirname $(dirname $(readlink -f $(which java))))"
Environment="CATALINA_PID=${INSTALL_DIR}/temp/tomcat.pid"
Environment="CATALINA_HOME=${INSTALL_DIR}"
Environment="CATALINA_BASE=${INSTALL_DIR}"

ExecStart=${INSTALL_DIR}/bin/startup.sh
ExecStop=${INSTALL_DIR}/bin/shutdown.sh

Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# === Enable and Start Tomcat ===
echo "[*] Starting Tomcat..."
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
sudo systemctl enable tomcat
sudo systemctl start tomcat

# === Output Success Info ===
echo "[✓] Tomcat installed and running as a systemd service!"
echo "Access: http://<your-ec2-public-ip>:8080"
echo "Username: ${TOMCAT_USER}"
echo "Password: ${TOMCAT_PASS}"

