#!/bin/bash

arkade install kubernetes-dashboard

# Create along-lived Bearer Token for Service Account
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: Secret
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
  annotations:
    kubernetes.io/service-account.name: "admin-user"   
type: kubernetes.io/service-account-token
EOF

# Dashboard Service RBAC configuration: Creating a ClusterRoleBinding and Service Account
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
EOF


#Get the Kubernetes Dashboard URL by running:
export POD_NAME=$(kubectl get pods -n kubernetes-dashboard -l "app.kubernetes.io/name=kubernetes-dashboard,app.kubernetes.io/instance=kubernetes-dashboard" -o jsonpath="{.items[0].metadata.name}")
echo "Your Kubernetes Dashboard URL is: https://127.0.0.1:8443/"
node_ip=$(kubectl -n kubernetes-dashboard describe pod $POD_NAME | grep "Node:" | cut -d "/" -f 2)

kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user-token | awk '{print $1}')
echo "Use above token to login to the dashboard: https://127.0.0.1:8443/login"
sleep 5
## To forward the dashboard to your local machine on port 8443
kubectl -n kubernetes-dashboard port-forward services/kubernetes-dashboard 8443:443 &
# Or directly to one of the POD containers 
#kubectl -n kubernetes-dashboard port-forward $POD_NAME 8443:443 &
# Also the docker run command to start the management container needs to add the port mapping: -p 8443:8443