#!/bin/bash

source setenv

rm -f id_rsa-${CLUSTER_NAME}
rm -f kubeconfig-${CLUSTER_NAME}

./00-check-availability.sh
./00-show-vars.sh           
./01-create-rg.sh           
./02-create-keyvault.sh     
./04-create-aks-cluster.sh  
./05-install-helm.sh        
./06-install-traefik.sh    
./10-install-velero.sh     
./11-restore-workloads.sh
./12-install-mock-ingresses.sh