#!/bin/bash

source setenv

./00-show-vars.sh
./00-check-availability.sh

#exit 1

az account set --subscription $SUBSCRIPTION

echo 'create resource group'
az group create -n $RG --location $LOCATION --subscription $SUBSCRIPTION

if [ $? -ne 0 ]
then
  echo "Create RG failed"
  exit 1
fi
