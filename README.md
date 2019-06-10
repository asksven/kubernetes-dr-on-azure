# Create an AKS devtest cluster

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

The input data for the scripts are located in `params`:
- `REQUESTED_NAME`: the name of the requested cluster 

## Configuration

The configuration of the automation as well as the dynamic creation of resource names is located in `setenv`

## Execution

1. Edit `params` and enter the name of the cluster
2. Run the scripts `01..11` in sequence

## Advanced topics

## Storage of secrets, passwords and keys

All secrets, password and keys created by the automation are stored in the Azure Keyvault created in `02`.

## Add IP restrictions at the NSG

We want to limit the imbound traffic to IPs from the own network. For that we have to go through all inbound rules having `internet` as source, change their source to `IP Addresses` and set the range to `195.234.12.0/24,195.234.13.0/24,212.90.104.0/22,91.151.24.0/21`.

## Retrieve gitlab root password

```
kubectl -n gitlab get secret gitlab-gitlab-initial-root-password -o json | jq '.data.password' -r | base64 --decode
```