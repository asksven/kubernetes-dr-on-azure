#!/bin/bash

source setenv

./00-show-vars.sh
./00-check-availability.sh

az account set --subscription $SUBSCRIPTION

echo 'create ssh keys'
ssh-keygen -t rsa -b 4096 -P "" -C $CLUSTER_NAME -f ./id_rsa-$CLUSTER_NAME

echo 'create cluster'
# --enable-vmss
az aks create --resource-group=$RG --name=$CLUSTER_NAME --kubernetes-version=$K8S_VERSION --node-count=$AGENT_COUNT --node-vm-size=$VM_SIZE --ssh-key-value=./id_rsa-$CLUSTER_NAME.pub --location=$LOCATION 

echo 'retrieve kubectl config'
unset KUBECONFIG
mkdir -p ./kubeconfig
rm -f ./kubeconfig/config*
az aks get-credentials --resource-group=$RG --name=$CLUSTER_NAME --file ./kubeconfig/config-$CLUSTER_NAME
export KUBECONFIG=./kubeconfig/config-$CLUSTER_NAME 


echo 'stashing secrets'
az keyvault secret set --vault-name "$KEY_VAULT_NAME" --name "$CLUSTER_NAME-privkey" --file ./id_rsa-$CLUSTER_NAME
az keyvault secret set --vault-name "$KEY_VAULT_NAME" --name "$CLUSTER_NAME-pubkey" --file ./id_rsa-$CLUSTER_NAME.pub
az keyvault secret set --vault-name "$KEY_VAULT_NAME" --name "$CLUSTER_NAME-kubectl-config" --file ./kubeconfig/config-$CLUSTER_NAME


echo 'verifying that cluster runs'
echo "running KUBECONFIG=./kubeconfig/config-$CLUSTER_NAME kubectl get nodes"
KUBECONFIG=./kubeconfig/config-$CLUSTER_NAME kubectl get nodes