#!/bin/bash

export KUBECONFIG=/etc/rancher/rke2/rke2.yaml

# ---------- INSTALL CERT-MANAGER ----------
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml

kubectl wait --for=condition=Available deployment \
  -n cert-manager \
  --all \
  --timeout=180s

# ---------- SELF-SIGNED ROOT ISSUER ----------
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned-root
spec:
  selfSigned: {}
EOF

# ---------- ROOT CA CERT ----------
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: root-ca
  namespace: cert-manager
spec:
  isCA: true
  commonName: k8s-local-root-ca
  secretName: root-ca-secret
  issuerRef:
    name: selfsigned-root
    kind: ClusterIssuer
EOF

# wait for CA
sleep 5


# ---------- CA ISSUER ----------
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: k8s-local-ca
spec:
  ca:
    secretName: root-ca-secret
EOF

# ---------- GATEWAY CERT ----------
kubectl apply -f - <<EOF
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: gateway-cert
  namespace: default
spec:
  secretName: gateway-cert
  issuerRef:
    name: k8s-local-ca
    kind: ClusterIssuer
  dnsNames:
  - web1.k8s.local
  - "*.k8s.local"
EOF

# ---------- PATCH GATEWAY ----------
kubectl apply -f - <<EOF
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
  - name: https
    port: 443
    protocol: HTTPS
    hostname: "*.k8s.local"
    tls:
      mode: Terminate
      certificateRefs:
      - name: gateway-cert
    allowedRoutes:
      namespaces:
        from: All
EOF
# ---------- LINE 99 ----------
echo "TLS configured for k8s.local"