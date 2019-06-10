#!/bin/bash

source setenv

./00-show-vars.sh

export KUBECONFIG=./kubeconfig/config-$CLUSTER_NAME

velero install \
    --provider azure \
    --bucket velero-prd \
    --secret-file ./velero/credentials-velero \
    --backup-location-config resourceGroup=$AZURE_BACKUP_RESOURCE_GROUP,storageAccount=$AZURE_STORAGE_ACCOUNT_ID \
    --wait
