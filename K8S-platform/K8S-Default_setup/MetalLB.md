# Installation of MetalLB on cluster

# ----- Install -----
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.14.5/config/manifests/metallb-native.yaml
 
# ------ Config ------
# create file and appy.
cat <<EOF > metallb-config.yaml
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: default-pool
  namespace: metallb-system
spec:
  addresses:
  - 10.189.36.100-10.189.36.110
---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: l2
  namespace: metallb-system
EOF
 
# ------- Apply kubectl --------

`` kubectl apply -f metallb-config.yaml  ``
 