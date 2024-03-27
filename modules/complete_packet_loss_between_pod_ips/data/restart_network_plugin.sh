#!/bin/bash

# Set the name of the network plugin to restart
PLUGIN=${NETWORK_PLUGIN}

# Get the name of the pod running the plugin
PLUGIN_POD=$(kubectl get pods -n kube-system -l k8s-app=$PLUGIN -o jsonpath='{.items[0].metadata.name}')

# Delete the pod running the network plugin
kubectl delete pod $PLUGIN_POD -n kube-system