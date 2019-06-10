#!/bin/bash

source setenv

./00-show-vars.sh

KUBECONFIG=./kubeconfig/config-$CLUSTER_NAME kubectl apply -f mock-ingresses/