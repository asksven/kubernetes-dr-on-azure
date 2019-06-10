#!/bin/bash

source setenv

./00-show-vars.sh

#exit 1

az account set --subscription $SUBSCRIPTION

echo 'create keyvault'
az keyvault create --name $KEY_VAULT_NAME --location $LOCATION --resource-group $RG --sku standard --subscription $SUBSCRIPTION

if [ $? -ne 0 ]
then
  echo "Create keyvault failed"
  exit 1
fi

