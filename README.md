
### About Shoreline
The Shoreline platform provides real-time monitoring, alerting, and incident automation for cloud operations. Use Shoreline to detect, debug, and automate repairs across your entire fleet in seconds with just a few lines of code.

Shoreline Agents are efficient and non-intrusive processes running in the background of all your monitored hosts. Agents act as the secure link between Shoreline and your environment's Resources, providing real-time monitoring and metric collection across your fleet. Agents can execute actions on your behalf -- everything from simple Linux commands to full remediation playbooks -- running simultaneously across all the targeted Resources.

Since Agents are distributed throughout your fleet and monitor your Resources in real time, when an issue occurs Shoreline automatically alerts your team before your operators notice something is wrong. Plus, when you're ready for it, Shoreline can automatically resolve these issues using Alarms, Actions, Bots, and other Shoreline tools that you configure. These objects work in tandem to monitor your fleet and dispatch the appropriate response if something goes wrong -- you can even receive notifications via the fully-customizable Slack integration.

Shoreline Notebooks let you convert your static runbooks into interactive, annotated, sharable web-based documents. Through a combination of Markdown-based notes and Shoreline's expressive Op language, you have one-click access to real-time, per-second debug data and powerful, fleetwide repair commands.

### What are Shoreline Op Packs?
Shoreline Op Packs are open-source collections of Terraform configurations and supporting scripts that use the Shoreline Terraform Provider and the Shoreline Platform to create turnkey incident automations for common operational issues. Each Op Pack comes with smart defaults and works out of the box with minimal setup, while also providing you and your team with the flexibility to customize, automate, codify, and commit your own Op Pack configurations.

# Complete Packet Loss Between Pod IPs

This incident type refers to a situation where there is a complete loss of network connectivity between pods or nodes in a network. When there is a 100% packet loss, it means that no data is being transmitted or received between the affected pods or nodes. This can lead to various issues, such as service disruption, downtime, and other related problems. Identifying and resolving the root cause of this incident is critical to ensure the proper functioning of the network.

### Parameters

```shell
export POD_NAME="PLACEHOLDER"
export NETWORK_PLUGIN="kube-flannel|calico|weave-net"
export DESTINATION_IP="PLACEHOLDER"
export POLICY_NAME="PLACEHOLDER"
export NAMESPACE="PLACEHOLDER"
```

## Debug

### Check if any pods are in a "Not Ready" state

```shell
kubectl get pods -A | grep -v Running
```

### Check if the pod's network interface is up and running

```shell
kubectl exec ${POD_NAME} -- ip link
```

### Check if there are any network policies that could be blocking traffic

```shell
kubectl get networkpolicies
```

### Check if there are any Kubernetes network plugins that could be causing issues

```shell
kubectl get pods -n kube-system | grep -E ${NETWORK_PLUGIN}
```

### Check if there are any network issues on the node where the affected pod is running

```shell
kubectl exec ${POD_NAME} -- traceroute ${DESTINATION_IP}
```

### Check if there are any issues with the Kubernetes network overlay

```shell
kubectl get pods --all-namespaces -l k8s-app=kube-dns | grep -v Running
```

## Repair

### Modify the network policies if they are blocking the traffic

```shell
#!/bin/bash

# Set the namespace and policy name
NAMESPACE=${NAMESPACE}
POLICY_NAME=${POLICY_NAME}

# Get the policy details
POLICY_DETAILS=$(kubectl get networkpolicies -n $NAMESPACE $POLICY_NAME -o json)

# Check if the policy is blocking traffic
IS_BLOCKING=$(echo $POLICY_DETAILS | jq '.spec.ingress | length == 0')

if [ "$IS_BLOCKING" = true ]; then
  # If the policy is blocking traffic, modify it to allow traffic
  kubectl patch networkpolicy -n $NAMESPACE $POLICY_NAME --type='json' -p='[{"op": "add", "path": "/spec/ingress/0/from", "value": [{"podSelector": {}}]}]'
  echo "Policy $POLICY_NAME modified to allow traffic."
else
  echo "Policy $POLICY_NAME is already allowing traffic."
fi
```

### Restart the kubernetes network plugins

```shell
#!/bin/bash

# Set the name of the network plugin to restart
PLUGIN=${NETWORK_PLUGIN}

# Get the name of the pod running the plugin
PLUGIN_POD=$(kubectl get pods -n kube-system -l k8s-app=$PLUGIN -o jsonpath='{.items[0].metadata.name}')

# Delete the pod running the network plugin
kubectl delete pod $PLUGIN_POD -n kube-system
```