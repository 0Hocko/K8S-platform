Cert manager install on Master cluster.

~/k8s-lab/
 └── k26/
     ├── cert-manager/
     │   ├── issuer.yaml
     │   ├── certificate.yaml
     ├── rancher/
     ├── gateway/

Install Cert-Manager

`` kubectl apply -f https://github.com/cert-manager/cert-manager/releases/latest/download/cert-manager.yaml ``

Check with 
`` kubectl get pods -n cert-manager -w ``
NAME                                      READY   STATUS    RESTARTS   AGE
cert-manager-5f9ddb88b4-cxsrk             1/1     Running
cert-manager-cainjector-9bb5d7d75-dtbkx   1/1     Running
cert-manager-webhook-7fc8569958-s2tk8     1/1     Running 

Create Issuer
`` nano ~/k8s-lab/k26/cert-manager/cluster-issuer.yaml `` 
paste in : 
```Bash
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: selfsigned
spec:
  selfSigned: {}
```

Apply it :
`` kubectl apply -f ~/k8s-lab/k26/cert-manager/cluster-issuer.yaml ``

Create first CERT
`` nano ~/k8s-lab/k26/cert-manager/test-cert.yaml ``
Paste in : 
```bash
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: test-cert
  namespace: default
spec:
  secretName: test-cert
  issuerRef:
    name: selfsigned
    kind: ClusterIssuer
  dnsNames:
  - test.k8s.local
```
Apply it 
`` kubectl apply -f ~/k8s-lab/k26/cert-manager/test-cert.yaml ``

Test / check with :
```bash
kubectl get certificate
kubectl describe certificate test-cert
```

NOTE : 
ClusterIssuer → defines how to sign
Certificate → requests a cert
Secret → stores TLS key

