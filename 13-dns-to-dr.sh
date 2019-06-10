#!/bin/bash

source setenv

./00-show-vars.sh


# Create the entries for the $PARENT_DOMAIN
# delete the entry in there are old IPs
az network dns record-set a delete --name *.${PARENT_DOMAIN} --resource-group $AZ_DNS_RG --zone-name $PARENT_DOMAIN --subscription $SUBSCRIPTION --yes

# update the DNS zone with this IP
az network dns record-set a add-record --ipv4-address $external_ip --record-set-name *.${REQUESTED_NAME} --resource-group $AZ_DNS_RG --zone-name $PARENT_DOMAIN --subscription $SUBSCRIPTION

az network dns record-set a update --set ttl=60 --name *.${PARENT_DOMAIN} --resource-group $AZ_DNS_RG --zone-name $PARENT_DOMAIN --subscription $SUBSCRIPTION
