#!/bin/bash

kubectl create namespace k3s
kubectl --namespace k3s create configmap mysite-html --from-file site.html 
kubectl -n k3s apply -f nginx.yml

# Inspect the service and pods are running
kubectl -n k3s get all

# Check the Ingress is working
kubectl -n k3s get ingress


