#!/bin/bash

kubectl version > /dev/null &> /dev/null
while [ $? -ne 0 ]; do sleep 1; kubectl version > /dev/null &> /dev/null; done

install -o root -g root -m 0755 /var/lib/rancher/rke2/bin/kubectl /usr/local/bin/kubectl

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/master/scripts/get-helm-3
chmod 500 get_helm.sh
./get_helm.sh

if [ $SERVER_TYPE = "leader" ]; then
   helm repo add jetstack https://charts.jetstack.io
   helm repo update

   helm install cert-manager jetstack/cert-manager \
      --namespace cert-manager \
      --create-namespace \
      --version v1.7.1

   kubectl apply -f https://github.com/jetstack/cert-manager/releases/download/v1.7.1/cert-manager.crds.yaml

   helm repo add rancher-latest https://releases.rancher.com/server-charts/latest
   helm repo update

   helm upgrade --install rancher rancher-latest/rancher \
                --version ${rancher_version} \
                --namespace cattle-system \
                --create-namespace \
                --set hostname=${rancher_address} \
                --set bootstrapPassword=admin \
                --set ingress.tls.source=letsEncrypt \
                --set letsEncrypt.email=${letsencrypt_email_address} \
                --set letsEncrypt.ingress.class=nginx

   helm repo add rancher-charts https://charts.rancher.io
   helm repo update

   helm upgrade --install rancher-backup-crd rancher-charts/rancher-backup-crd \
                --namespace cattle-resources-system \
                --create-namespace
   helm upgrade --install rancher-backup rancher-charts/rancher-backup \
                --namespace cattle-resources-system

   helm upgrade --install rancher-monitoring-crd rancher-charts/rancher-monitoring-crd \
                --namespace cattle-resources-system
   helm upgrade --install rancher-monitoring rancher-charts/rancher-monitoring \
                --namespace cattle-monitoring-system \
                --create-namespace

   kubectl label nodes --selector node-role.kubernetes.io/master node-role.kubernetes.io/worker=true --overwrite=true

   cat << EOF | kubectl apply -f -
apiVersion: cert-manager.io/v1
kind: Issuer
metadata:
  name: letsencrypt-production
  namespace: cattle-system
spec:
  acme:
    # The ACME server URL
    server: https://acme-v02.api.letsencrypt.org/directory
    # Email address used for ACME registration
    email: ${letsencrypt_email_address}
    # Name of a secret used to store the ACME account private key
    privateKeySecretRef:
      name: letsencrypt-production
    # Enable the HTTP-01 challenge provider
    solvers:
      - http01:
          ingress:
            class: nginx
EOF
fi
