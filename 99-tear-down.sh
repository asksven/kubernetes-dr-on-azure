#!/bin/bash

source setenv

./00-show-vars.sh

# delete the entry in there are old IPs
az network dns record-set a delete --name *.${REQUESTED_NAME} --resource-group $AZ_DNS_RG --zone-name $PARENT_DOMAIN --subscription $SUBSCRIPTION --yes

# delete the resource groups
az group delete --name $RG --yes
# the econd one does not need to be delete as it automatically done by the first deletion
#az group delete --name MC_${RG}-${CLUSTER_NAME}_${LOCATION} --yes

