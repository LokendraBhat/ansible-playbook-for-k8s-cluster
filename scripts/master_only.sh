#!/bin/bash

echo -e "\n------------ Execute only on MASTER NODE -----------\n"

echo -e "\nInitialize the Master Node"
# kubeadm init --control-plane-endpoint=master1.com   # --pod-network-cidr=192.168.0.0/16
sudo kubeadm init --control-plane-endpoint=master1.com --pod-network-cidr=10.244.0.0/16
# The CIDR range 10.244.0.0/16 is the recommended range for Flannel, but you can change it based on your requirements.

# Check if kubeadm init was successful
if [ $? -eq 0 ]; then
  echo -e "\nKubernetes control-plane has initialized successfully!"
  
  if [ "$EUID" -ne 0 ]; then
    echo -e "\nSetting up kubeconfig for the regular user..."
    mkdir -p $HOME/.kube
    sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
    sudo chown $(id -u):$(id -g) $HOME/.kube/config
  else
    echo -e "\nYou are running as root. You can set the KUBECONFIG environment variable:"
    export KUBECONFIG=/etc/kubernetes/admin.conf
    echo "KUBECONFIG set to /etc/kubernetes/admin.conf"
  fi

  echo -e "\n********** Install Pod Network Add-On (CNI) - Flannel **********"
  # Uncomment the following line for Calico and comment flannel
  # kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml 
  kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

  echo -e "\n\n********* Join Worker Nodes to the Cluster *********"
  echo -e "\nNote down the kubeadm join command with the token that you will use to join the worker nodes."
else
  echo -e "\nError: Kubernetes control-plane initialization failed."
  exit 1
fi
