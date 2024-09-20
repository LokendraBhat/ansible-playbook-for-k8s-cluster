# IF The error you're encountering, tls: failed to verify certificate: x509: certificate signed by unknown authority

## Steps to Resolve:
1. Verify Kubeconfig on the Remote Node (master_1): Ensure that the kubeconfig file is properly set up and accessible. The default location for this file is $HOME/.kube/config or /etc/kubernetes/admin.conf (for root users).
```cat $HOME/.kube/config```
If you are running the command as a root user, make sure you have set up the correct kubeconfig:
```export KUBECONFIG=/etc/kubernetes/admin.conf```


2. Ensure Permissions for Kubeconfig:
```mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config```

3. Regenerate Certificates (if necessary): 
If the certificates have expired or were incorrectly configured during the setup, you can try regenerating them. For kubeadm-based clusters, use the following command to regenerate certificates:
```sudo kubeadm certs renew all```

4. Verify Kubernetes API Server's Certificate: The error might be due to an invalid or missing CA certificate in your kubeconfig. Make sure that the CA certificate in the kubeconfig matches the certificate used by the Kubernetes API server.

Check the certificate-authority entry in the kubeconfig file and ensure that it points to a valid CA certificate. You can verify the certificate by comparing it to the one in /etc/kubernetes/pki/ca.crt.
