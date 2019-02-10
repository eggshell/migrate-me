#!/bin/bash

ibmcloud plugin install -f kubernetes-service
ibmcloud plugin install -f container-registry

ibmcloud login                     \
  --apikey "${IBMCLOUD_API_KEY}"   \
  -a "https://api.ng.bluemix.net"  \
  -r "us-south"

ibmcloud target           \
  -o "Developer Advocacy" \
  -s "dev"

ibmcloud cr login
ibmcloud cr region-set us-south

while [ -z "${KUBECONFIG}" ]; do
  $(ibmcloud ks cluster-config --export ${CLUSTER_NAME})
done

kubectl version
kubectl cluster-info

ibmcloud cr build --tag registry.ng.bluemix.net/eggshell/status_page:1 .
kubectl apply -f deploy/status-namespace.yaml

kubectl get secret bluemix-default-secret --export -o yaml | kubectl apply --namespace=status-page -f -
kubectl get secret bluemix-default-secret-regional --export -o yaml | kubectl apply --namespace=status-page -f -
kubectl get secret bluemix-default-secret-international --export -o yaml | kubectl apply --namespace=status-page -f -

kubectl apply -f deploy/redis-deployment.yaml
kubectl apply -f deploy/status-deployment.yaml
