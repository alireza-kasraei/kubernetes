#!/bin/bash

# Enable ssh password authentication
echo "[TASK 1] Enable ssh password authentication"
sed -i 's/^PasswordAuthentication .*/PasswordAuthentication yes/' /etc/ssh/sshd_config
echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config
systemctl reload sshd

# Set Root password
echo "[TASK 2] Set root password"
echo -e "root\nroot" | passwd root >/dev/null 2>&1

echo "[TASK 3] Set kernel parameters"
cat >>/etc/sysctl.d/kubernetes.conf<<EOF
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
vm.max_map_count=262144
EOF
sysctl --system

echo "[TASK 4] disabling the firewall"
ufw disable

echo "[TASK 5] turning the swap off"
swapoff -a; sed -i '/swap/d' /etc/fstab


echo "[TASK 6] installing docker"
apt install -y apt-transport-https ca-certificates curl gnupg-agent software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
apt update && apt install -y docker-ce=5:19.03.10~3-0~ubuntu-focal containerd.io