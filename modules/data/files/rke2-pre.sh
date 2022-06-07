#!/bin/bash

# OS tuning
sudo sysctl -w vm.max_map_count=262144
sudo sysctl -w fs.file-max=131072
ulimit -n 131072
ulimit -u 8192

# Configure NetworkManager to ignore calico/flannel related network interfaces
sudo cat << 'EOF' >> /etc/NetworkManager/conf.d/rke2-canal.conf
[keyfile]
unmanaged-devices=interface-name:cali*;interface-name:flannel*
EOF
sudo systemctl reload NetworkManager

# Disable Firewalld to avoid Firewalld conflicts with RKE2's default Canal (Calico + Flannel) networking stack
sudo systemctl stop firewalld
sudo systemctl disable firewalld

# Increase /var volume on RHEL system
# List the file system
sudo df -h
# Check whether free space is available space in the volume group
sudo vgdisplay rootvg
# Use lvextend command to increase the size
sudo lvextend -l +100%FREE /dev/mapper/rootvg-varlv
# Extend the file system
sudo xfs_growfs /dev/mapper/rootvg-varlv
# Use df command and verify new size
sudo df -h

if [ $TYPE = "server" ]; then
   sudo mkdir -p /var/lib/rancher/rke2/server/manifests
   sudo touch /var/lib/rancher/rke2/server/manifests/nginxtodaemonset.yaml
   sudo chmod 777 /var/lib/rancher/rke2/server/manifests/nginxtodaemonset.yaml
   sudo cat << 'EOF' >> /var/lib/rancher/rke2/server/manifests/nginxtodaemonset.yaml
apiVersion: helm.cattle.io/v1
kind: HelmChartConfig
metadata:
  name: rke2-ingress-nginx
  namespace: kube-system
spec:
  valuesContent: |-
    controller:
      kind: DaemonSet
      daemonset:
        useHostPort: true
EOF

fi