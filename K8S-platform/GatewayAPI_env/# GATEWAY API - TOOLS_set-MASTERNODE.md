#!/bin/bash

# ------------- VARIABLES -------------
METALLB_IP_RANGE="10.189.33.100-10.189.33.120"

# ------------- KUBECONFIG -------------
export KUBECONFIG=/etc/rancher/rke2/rke2.yaml

# ------------- INSTALL HELM -------------
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash


# ------------- INSTALL GATEWAY API CRDs -------------
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/latest/download/standard-install.yaml

# --- Verify ---
kubectl get crds | grep gateway

# ------------- INSTALL METALLB -------------
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml

# Wait for pods
kubectl wait --namespace metallb-system \
  --for=condition=ready pod \
  --selector=app=metallb \
  --timeout=120s

# ------------- CONFIGURE METALLB -------------
cat <<EOF | kubectl apply -f -
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
  - $METALLB_IP_RANGE
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: default-l2
  namespace: metallb-system
spec: {}
EOF

# ------------- INSTALL ENVOY GATEWAY -------------
helm repo add envoy-gateway https://helm.envoyproxy.io
helm repo update

kubectl create namespace envoy-gateway-system

helm install eg envoy-gateway/envoy-gateway \
  -n envoy-gateway-system

# Wait
kubectl rollout status deployment -n envoy-gateway-system

# ------------- CREATE GATEWAYCLASS + GATEWAY ------------
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: GatewayClass
metadata:
  name: envoy
spec:
  controllerName: gateway.envoyproxy.io/gatewayclass-controller
---
apiVersion: gateway.networking.k8s.io/v1
kind: Gateway
metadata:
  name: main-gateway
  namespace: default
spec:
  gatewayClassName: envoy
  listeners:
  - name: http
    port: 80
    protocol: HTTP
    allowedRoutes:
      namespaces:
        from: All
EOF

# ------------- DEPLOY DEMO APP -------------
cat <<EOF | kubectl apply -f -
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web1
spec:
  replicas: 1
  selector:
    matchLabels:
      app: web1
  template:
    metadata:
      labels:
        app: web1
    spec:
      containers:
      - name: web
        image: nginx
        ports:
        - containerPort: 80
---
apiVersion: v1
kind: Service
metadata:
  name: web1
spec:
  selector:
    app: web1
  ports:
    - port: 80
      targetPort: 80
EOF

# ------------- CREATE HTTPRoute -------------
cat <<EOF | kubectl apply -f -
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web1-route
spec:
  parentRefs:
  - name: main-gateway
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: web1
      port: 80
EOF

# ------------- OUTPUT ACCESS INFO -------------
echo "-----------------------------------"
echo "Gateway Service:"
kubectl get svc -A | grep envoy

echo "-----------------------------------"
echo "Test with:"
echo "curl http://<EXTERNAL-IP>"
echo "-----------------------------------"


# ------------- VERIFY -------------
# Run after scritp ....
kubectl get gateway
kubectl get httproute
kubectl get svc -n envoy-gateway-system
# Expected result should be 
``EXTERNAL-IP: 10.189.33.100  (from MetalLB)``

# Test with curl  :
curl http://10.189.33.100
# Expected result should be 
`` Welcome to nginx! ``
