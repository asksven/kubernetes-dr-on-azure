# Create an AKS DR cluster

## Overview
This is a collection of runbooks that create a DR kubernetes cluster on-the-fly:
01. Create a resource group
02. Create a keyvault
04. Create an AKS cluster
05. Install helm / tiller
06. Install traefik (ingress controller)
10. Install velero to point to the backups
11. Restore namespaces listed in `namespaces`
99. Tears down the whole cluster

## Input data

The input data for the scripts are located in `setenv`:
- `REQUESTED_NAME`: the name of the requested cluster
- `SUBSCRIPTION': the Azure subscription-id where the cluster should be created
- `LOCATION`: the azure location/region to provision resources
- `VM_SIZE`: the cluster node vm size
- `AGENT_COUNT`: the number of nodes
- `K8S_VERSION`: the k8s version to be provisioned
- `ACME_CONTACT`: your e-mail contact address for let's encrypt
- `PARENT_DOMAIN`: the name of the parent domain (managed by the DNS zone)
- `MAIN_DC_IP`: the IP of the production cluster
- `AZ_DNS_RG`: the name of the resource group the DNS zone is in
- `AZURE_BACKUP_RESOURCE_GROUP`: the resource group velero backs-up into
- `AZURE_STORAGE_ACCOUNT_ID`: the ID of the velero storage account


## Execution

1. Edit `setenv`
2. Run `execute-dr.sh`: this will create the cluster but not switch the prod DNS
3. Run `13-dns-to-dr.sh` to switch production to the DR cluster
4. Run `99-dns-back-to-prod.sh` to switch back the the production cluster