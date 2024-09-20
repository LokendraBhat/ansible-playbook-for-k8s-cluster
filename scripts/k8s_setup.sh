#!/bin/bash

echo -e "\n----------------- TO SETUP k8s(applicable for all nodes) -----------------\n"

echo -e "\n----------------- 1. Disble SELinux and firewalld and System update -----------------"
setenforce 0
sed -i s/enforcing/disabled/g /etc/selinux/config
cat /etc/selinux/config

fd_status=$(systemctl is-active --quiet firewalld)
if [[ $fd_status != 0 ]]; then systemctl stop firewalld && systemctl disable firewalld; else echo "" >/dev/null; fi

yum update -y

echo -e "\n----------------- 2. Disable swap -----------------"
swapoff -a
echo -e "comment out lines containing "/swapfile" in the /etc/fstab file by adding a # at the beginning of those lines."
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
cat /etc/fstab

echo -e "\n----------------- 3. Install tools and dependencies -----------------"
yum install telnet wget curl bind-utils sysstat git net-tools tar gzip zip unzip rsync vim -y
yum install epel-release -y && yum install netcat htop -y

echo -e "\n----------------- 4. Enable Kernel Modules and Network Settings -----------------"
cat <<EOF | sudo tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
modprobe overlay
modprobe br_netfilter

cat <<EOF | sudo tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward = 1
EOF
sysctl --system


echo -e "\n----------------- 5. Install Docker (Container Runtime) -----------------"
dnf install -y yum-utils
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
dnf install -y containerd.io

echo "configure containerd so that it can use the systemdcgroup driver"
containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml
systemctl restart containerd
systemctl enable containerd


echo -e "\n----------------- 6. Install Kubernetes Components -----------------"
echo "a) Add the Kubernetes repository -----------------"
echo "Reference: https://kubernetes.io/docs/tasks/administer-cluster/kubeadm/change-package-repository"
cat <<EOF | sudo tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.30/rpm/repodata/repomd.xml.key
exclude=kubelet kubeadm kubectl cri-tools kubernetes-cni
EOF

echo "b) Install kubeadm, kubelet, and kubectl -----------------"
yum install -y kubelet kubeadm kubectl --disableexcludes=kubernetes

echo "Enable and start kubelet -----------------"
systemctl enable kubelet --now
systemctl status kubelet

echo -e "\n----------------- INSTALLATION SETUP COMPLETED -----------------\n"
