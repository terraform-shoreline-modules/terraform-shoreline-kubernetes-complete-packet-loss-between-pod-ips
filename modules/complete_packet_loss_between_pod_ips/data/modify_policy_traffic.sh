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