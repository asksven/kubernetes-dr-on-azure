#!/bin/bash

source setenv

./00-show-vars.sh

az account set --subscription $SUBSCRIPTION

ID=`az network dns zone show --resource-group $AZ_DNS_RG --name $PARENT_DOMAIN --query 'id' --output tsv`

SP_NAME=`echo ${REQUESTED_NAME}DnsValidator | sed 's/[\._-]//g'`
az ad sp create-for-rbac --name "${SP_NAME}" --role "DNS Zone Contributor" --scopes $ID > sp.tmp

APP_ID=$(jq '.appId' -r sp.tmp)
PASSWORD=$(jq '.password' -r sp.tmp)
TENANT=$(jq '.tenant' -r sp.tmp)

echo APP_ID: $APP_ID

# Following variables need to be substituted
# {{ ACME_CONTACT }}: your e-mail
# {{ DOMAIN }}: the DR domain name
# {{ PROD_DOMAIN }}: the production domain name
# {{ AZ_CLIENT_ID }}: service principal client-id for accessing the DNS zone
# {{ AZ_CLIENT_SECRET }}: service principal secret for accessing the DNS zone
# {{ AZ_SUBSCRIPTION_ID }}: subscription-id where the DNS zone is setup
# {{ AZ_TENANT_ID }}: tenant-id where the DNS zone is setup
# {{ AZ_DNS_RG }}: : resource group where the DNS zone is setup

#echo ACME_CONTACT: $ACME_CONTACT
#echo DOMAIN: $DOMAIN
#echo PROD_DOMAIN: $PARENT_DOMAIN
#echo AZ_CLIENT_ID: $APP_ID
#echo AZ_CLIENT_SECRET: $PASSWORD
#echo AZ_SUBSCRIPTION_ID: $SUBSCRIPTION
#echo AZ_TENANT_ID: $TENANT
#echo AZ_DNS_RG: $AZ_DNS_RG

TARGET_DIR=$PWD/.generated
mkdir -p $TARGET_DIR

echo Generating yaml files into $TARGET_DIR

for f in traefik/*.yaml
do
  echo processing $f
  jinja2 $f --format=yaml --strict \
    -D ACME_CONTACT=${ACME_CONTACT} \
    -D DOMAIN=${DOMAIN} \
    -D PROD_DOMAIN=${PARENT_DOMAIN} \
    -D AZ_CLIENT_ID=${APP_ID} \
    -D AZ_CLIENT_SECRET=${PASSWORD} \
    -D AZ_SUBSCRIPTION_ID=${SUBSCRIPTION} \
    -D AZ_TENANT_ID=${TENANT} \
    -D AZ_DNS_RG=${AZ_DNS_RG} \
    > "${TARGET_DIR}/$(basename ${f})"
done


KUBECONFIG=./kubeconfig/config-$CLUSTER_NAME kubectl -n kube-system apply -f .generated/traefik-rbac.yaml

KUBECONFIG=./kubeconfig/config-$CLUSTER_NAME helm upgrade --install traefik-dr stable/traefik --namespace kube-system -f .generated/traefik-dr.yaml
KUBECONFIG=./kubeconfig/config-$CLUSTER_NAME helm upgrade --install traefik stable/traefik --namespace kube-system -f .generated/traefik-production.yaml

KUBECONFIG=./kubeconfig/config-$CLUSTER_NAME kubectl wait --for=condition=available --timeout=600s deployment/traefik -n kube-system 

external_ip=
while [ -z $external_ip ]; do
   echo "Waiting for end point..."
   external_ip=$(KUBECONFIG=./kubeconfig/config-$CLUSTER_NAME kubectl -n kube-system get svc traefik --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
   [ -z "$external_ip" ] && sleep 10
done

echo "External IP found: $external_ip"

external_ip2=
while [ -z $external_ip2 ]; do
   echo "Waiting for end point..."
   external_ip2=$(KUBECONFIG=./kubeconfig/config-$CLUSTER_NAME kubectl -n kube-system get svc traefik-dr --template="{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}")
   [ -z "$external_ip2" ] && sleep 10
done

echo "External IP found: $external_ip"
echo "External IP2 found: $external_ip2"

# Create the entries for the $REQUESTED_NAME
# delete the entry in there are old IPs
az network dns record-set a delete --name *.${REQUESTED_NAME} --resource-group $AZ_DNS_RG --zone-name $PARENT_DOMAIN --subscription $SUBSCRIPTION --yes

# update the DNS zone with this IP
az network dns record-set a add-record --ipv4-address $external_ip2 --record-set-name *.${REQUESTED_NAME} --resource-group $AZ_DNS_RG --zone-name $PARENT_DOMAIN --subscription $SUBSCRIPTION

az network dns record-set a update --set ttl=60 --name *.${REQUESTED_NAME} --resource-group $AZ_DNS_RG --zone-name $PARENT_DOMAIN --subscription $SUBSCRIPTION
