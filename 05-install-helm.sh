#!/bin/bash

source setenv

./00-show-vars.sh

#curl https://raw.githubusercontent.com/helm/helm/master/scripts/get > get_helm.sh
#chmod 700 get_helm.sh
#./get_helm.sh

KUBECONFIG=./kubeconfig/config-$CLUSTER_NAME kubectl apply -f helm/helm-rbac.yaml

KUBECONFIG=./kubeconfig/config-$CLUSTER_NAME helm init --service-account tiller --wait

#KUBECONFIG=./kubeconfig/config-$CLUSTER_NAME kubectl wait --for=condition=available --timeout=600s deployment/tiller-deploy -n kube-system