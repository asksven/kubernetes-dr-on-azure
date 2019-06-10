#!/bin/bash

source setenv

./00-show-vars.sh

velero install \
    --provider azure \
    --bucket velero-prd \
    --secret-file ./velero/credentials-velero \
    --backup-location-config resourceGroup=$AZURE_BACKUP_RESOURCE_GROUP,storageAccount=$AZURE_STORAGE_ACCOUNT_ID \
    --wait
