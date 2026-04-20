# 1. Install Envoy Gateway (CRDs + controller)
helm install envoy-gateway oci://docker.io/envoyproxy/gateway-helm \
  --version v1.7.2 \
  -n envoy-gateway-system \
  --create-namespace
 
# 2. Wait for it to be ready
kubectl wait --timeout=2m -n envoy-gateway-system \
  deployment/envoy-gateway --for=condition=Available
 
# 3. Apply GatewayClass + Gateway + demo app in one shot
kubectl apply -f - <<'EOF'
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
  name: eg
  namespace: default
spec:
  gatewayClassName: envoy
  listeners:
  - name: http
    protocol: HTTP
    port: 80
    allowedRoutes:
      namespaces:
        from: All
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: gateway-demo
  namespace: default
spec:
  replicas: 1
  selector:
    matchLabels:
      app: gateway-demo
  template:
    metadata:
      labels:
        app: gateway-demo
    spec:
      containers:
      - name: demo
        image: hashicorp/http-echo:latest
        args: ["-text=Gateway API is live."]
        ports:
        - containerPort: 5678
---
apiVersion: v1
kind: Service
metadata:
  name: gateway-demo
  namespace: default
spec:
  selector:
    app: gateway-demo
  ports:
  - port: 80
    targetPort: 5678
---
apiVersion: gateway.networking.k8s.io/v1
kind: HTTPRoute
metadata:
  name: gateway-demo
  namespace: default
spec:
  parentRefs:
  - name: eg
    namespace: default
  rules:
  - matches:
    - path:
        type: PathPrefix
        value: /
    backendRefs:
    - name: gateway-demo
      port: 80
EOF