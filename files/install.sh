#!/usr/bin/env bash
set -e

echo "Installing dependencies..."
if [ -x "$(command -v apt-get)" ]; then
  sudo apt-get update -y
  sudo apt-get install -y unzip
else
  sudo yum update -y
  sudo yum install -y unzip wget
fi


echo "Fetching Consul..."
CONSUL=1.5.2
cd /tmp
curl https://releases.hashicorp.com/consul/${CONSUL}/consul_${CONSUL}_linux_amd64.zip -o consul.zip

echo "Installing Consul..."
unzip consul.zip >/dev/null
chmod +x consul
sudo mv consul /usr/local/bin/consul

# Read from the file we created
SERVER_COUNT=$(cat /tmp/consul-server-count | tr -d '\n')
CONSUL_JOIN=$(cat /tmp/consul-server-addr | tr -d '\n')
CONSUL_SERVER_IP=$(cat /tmp/consul-server-ip | tr -d '\n')

# Write the IP to host file file
cp /etc/hosts /tmp/hosts
echo "${CONSUL_SERVER_IP} ${CONSUL_JOIN}" >> /tmp/hosts

# Write the flags to a temporary file
cat >/tmp/consul_flags << EOF
CONSUL_FLAGS="-server -ui -bootstrap-expect=${SERVER_COUNT} -join=${CONSUL_JOIN} -data-dir=/opt/consul/data"
EOF

# Write systemd service
cat >/tmp/consul.service << "EOF"
[Unit]
Description=consul agent
Requires=network-online.target
After=network-online.target

[Service]
EnvironmentFile=-/etc/default/consul
Restart=on-failure
ExecStart=/usr/local/bin/consul agent $CONSUL_FLAGS -config-dir=/etc/systemd/system/consul.d
ExecReload=/bin/kill -HUP $MAINPID
KillSignal=SIGINT

[Install]
WantedBy=multi-user.target
EOF

echo "Installing Systemd service..."
sudo mkdir -p /etc/systemd/system/consul.d
sudo chown root:root /tmp/consul.service
sudo mv /tmp/consul.service /etc/systemd/system/consul.service
sudo chmod 0644 /etc/systemd/system/consul.service
sudo mv /tmp/consul_flags /etc/default/consul
sudo mv /tmp/hosts /etc/hosts 
sudo chown root:root /etc/default/consul
sudo chmod 0644 /etc/default/consul

