#!/bin/bash

export KUBECONFIG=/etc/rancher/rke2/rke2.yaml
METALLB_RANGE="10.189.36.100-10.189.36.120"

# ==============================
# HELM
# ==============================
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

# ==============================
# GATEWAY API
# ==============================
kubectl apply -f https://github.com/kubernetes-sigs/gateway-api/releases/latest/download/standard-install.yaml

# ==============================
# METALLB
# ==============================
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml

kubectl wait -n metallb-system --for=condition=ready pod --all --timeout=120s

kubectl apply -f - <<EOF
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: pool
  namespace: metallb-system
spec:
  addresses:
  - $METALLB_RANGE
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: adv
  namespace: metallb-system
EOF

# ==============================
# ENVOY GATEWAY
# ==============================
helm repo add envoy-gateway https://helm.envoyproxy.io
helm repo update

kubectl create ns envoy-gateway-system

helm install eg envoy-gateway/envoy-gateway -n envoy-gateway-system

# ==============================
# GATEWAY
# ==============================
kubectl apply -f - <<EOF
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

# ==============================
# CERT-MANAGER (LOCAL TLS)
# ==============================
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml

sleep 10

kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned
spec:
  selfSigned: {}
EOF

# ==============================
# DEMO APP
# ==============================
kubectl create deployment web1 --image=nginx
kubectl expose deployment web1 --port 80

# ==============================
# HTTP ROUTE
# ==============================
kubectl apply -f - <<EOF
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: web1
spec:
  parentRefs:
  - name: main-gateway
  hostnames:
  - web1.apps.k8s.local
  rules:
  - backendRefs:
    - name: web1
      port: 80
EOF

echo "✅ Workload cluster ready"