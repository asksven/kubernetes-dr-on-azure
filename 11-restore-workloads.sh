#!/bin/bash

source setenv

./00-show-vars.sh

for NS in $(cat namespaces)
do
  echo Restoring namespace $NS
  backup_name=$(velero backup get | grep $NS | head -n1 | awk '{print $1}')
  echo Most recent backup: $backup_name
  velero restore create --from-backup $backup_name
done
