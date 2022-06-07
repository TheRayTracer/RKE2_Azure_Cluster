#!/bin/bash

sudo touch /usr/local/rke2-setup.log
sudo chmod 666 /usr/local/rke2-setup.log
exec >/usr/local/rke2-setup.log 2>&1

export TYPE="${type}"
export REGISTRATION_CMD="${registration_command}"

make_config() {
  sudo mkdir -p /etc/rancher/rke2
  sudo touch /etc/rancher/rke2/config.yaml
}

append_config() {
  echo "$1" >> "/etc/rancher/rke2/config.yaml"
}

elect_leader() {
# Simple leader election
  host=$(hostname)
  hostNum=$${host: -2}

  if [ "$hostNum" = "00" ]; then
    SERVER_TYPE="leader"
    echo "Electing as cluster leader"
  else
    echo "Electing as joining server"
  fi
}

identify_leader() {
  echo "Identifying server type..."

# Default to a joining server
  SERVER_TYPE="join"

  supervisor_status=$(curl --max-time 5 --write-out '%%{http_code}' -sk --output /dev/null https://"${ip_address}":9345/ping)

  if [ "$supervisor_status" -eq 200 ]; then
    echo "API server available, identifying as server joining existing cluster"
  else
    echo "API server unavailable, performing simple leader election"
    elect_leader
  fi
}

cluster_wait() {
  while true; do
    supervisor_status=$(curl --max-time 5 --write-out '%%{http_code}' -sk --output /dev/null https://"${ip_address}":9345/ping)
    if [ "$supervisor_status" -eq 200 ]; then
      echo "Cluster is ready"

    # Let things settle down for a bit, without this HA cluster creation is very unreliable
      sleep 10
      break
    fi
    echo "Waiting for cluster to be ready..."
    sleep 10
  done
}

{
  echo "*** Begin RKE2 setup script ***"

  echo "Begin pre setup step"
  ${pre_install}
  echo "End pre setup step"

  make_config
  append_config "token: ${token}"
  append_config "cloud-provider-name: azure"
  append_config "cloud-provider-config: /etc/rancher/rke2/cloud.conf"
  append_config "node-label: ${node_labels}"
  append_config "node-taint: ${node_taints}"

  if [ "$TYPE" = "server" ]; then
    append_config "tls-san:"
    append_config "  - ${ip_address}"

    identify_leader
    if [ $SERVER_TYPE = "join" ]; then
      append_config "server: https://${ip_address}:9345"
    # Wait for cluster to exist before joining
      cluster_wait
    fi

  # This attempts to stagger the times when servers try to join the cluster
  # We rely on the well ordered cardinal host names that VMSS will assign.
    host=$(hostname)
    hostNum=$${host: -2}
    sleepTime=$(( hostNum * 60 ))
    echo "Staggering the join process, waiting $sleepTime seconds before joining..."
    sleep $sleepTime

    systemctl enable rke2-server
    systemctl daemon-reload
    systemctl start rke2-server

    export PATH=$PATH:/var/lib/rancher/rke2/bin
    chmod 644 /etc/rancher/rke2/rke2.yaml
    export KUBECONFIG=/etc/rancher/rke2/rke2.yaml

    if [ $SERVER_TYPE = "leader" ]; then
      if [ ! -z "$REGISTRATION_CMD" ]; then
      # Leader should issue registration command to Rancher server
        echo "Registering with Rancher server with command ${registration_command}"
        ${registration_command}
      fi
    fi
  else
    append_config "server: https://${ip_address}:9345"

    systemctl enable rke2-agent
    systemctl daemon-reload
    systemctl start rke2-agent
  fi

  echo "Begin post setup step"
  ${post_install}
  echo "End post setup step"

  echo "*** End RKE2 setup script ***"
}
