#!/bin/bash

source setenv

./00-show-vars.sh

export KUBECONFIG=./kubeconfig/config-$CLUSTER_NAME

for NS in $(cat namespaces)
do
  echo Restoring namespace $NS
  backup_name=$(velero backup get | grep $NS | head -n1 | awk '{print $1}')
  echo Most recent backup: $backup_name
  velero restore create --from-backup $backup_name
done

# wait for the namespaces to have been create
for NS in $(cat namespaces)
do
  echo Checking for restore of namespace $NS
  exists=0
  while [ $exists -eq 0 ]; do
    echo "Waiting for namespace..."
    command=$(KUBECONFIG=./kubeconfig/config-$CLUSTER_NAME kubectl get ns $NS)
    if [ $? -eq 0 ]; then
      exists=1
      echo Namespace $NS exists
    fi
    [ $exists -eq 0  ] && sleep 10
  done
done
