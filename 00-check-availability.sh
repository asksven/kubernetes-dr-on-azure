#!/bin/bash

source setenv

# Check if all resources are available
RES=$(az group exists --name ${RG})

if [ $RES == 'true' ]
then
  echo "Resource Group $RG exists"
  exit 1  
else
  echo "Resource Group $RG does not exist. Continue!"
fi  