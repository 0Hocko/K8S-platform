Install RANCHER with HELM

`` curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash ``

Add Rancher Repo
```bash
helm repo add rancher-stable https://releases.rancher.com/server-charts/stable
helm repo update 
```

Create namespace
`` kubectl create namespace cattle-system ``

Install Rancher 
```bash
helm install rancher rancher-stable/rancher \
  -n cattle-system \
  --set hostname=rancher-hocko.k8s.local \
  --set replicas=1 \
  --set ingress.enabled=false \
  --set service.type=NodePort \
  --set bootstrapPassword=admin
```
NOTE :
| Part              | Meaning                             |
| ----------------- | ----------------------------------- |
| hostname          | your DNS (already configured)       |
| replicas=1        | keeps it simple                     |
| ingress=false     | we avoid nginx ingress (as planned) |
| NodePort          | direct access from your network     |
| bootstrapPassword | initial login password              |

Check if all up and runnign : 
`` kubectl get pods -n cattle-system -w ``

and check what IP and port is used
``kubectl get svc -n cattle-system``
|NAME                     | TYPE      | CLUSTER-IP   |  EXTERNAL-IP |  PORT(S)                   |
|-------------------------|-----------|--------------|--------------|----------------------------|  
|imperative-api-extension | ClusterIP | 10.43.133.48 | <none>       | 6666/TCP                   |
|rancher                  | NodePort  | 10.43.172.59 | <none>       | 80:31413/TCP,443:30512/TCP |
|rancher-webhook          | ClusterIP | 10.43.144.45 | <none>       | 443/TCP                    |

use TEMP port to access rancher via webgui
``https://10.189.26.11:30512/dashboard/auth/setup``
enter bootstrep password from config and set up password and Server url. Use DNS NAME !
`` https://rancher-hocko.k8s.local ``

# ---- FIX TLS - make SSL work ---
Create file : 
```bash
mkdir -p ~/k8s-lab/k26/rancher
nano ~/k8s-lab/k26/rancher/rancher-cert.yaml
```

paste in
```yaml
apiVersion: cert-manager.io/v1
kind: Certificate
metadata:
  name: rancher-cert
  namespace: cattle-system
spec:
  secretName: rancher-tls
  issuerRef:
    name: k8s-local-ca
    kind: ClusterIssuer
  dnsNames:
  - rancher-hocko.k8s.local
```

apply it : 
`` kubectl apply -f ~/k8s-lab/k26/rancher/rancher-cert.yaml ``
wait : 
`` kubectl wait --for=condition=Ready certificate rancher-cert -n cattle-system --timeout=180s ``

if reutrn time out check it :
`` kubectl get certificate -n cattle-system ``
|NAME        | READY | SECRET     |
|------------|-------|------------|
|rancher-cert| False | rancher-tls|

than see that root-ca is there ? 
`` kubectl get certificate -n cert-manager ``
and you will see that root-ca is missing. We have to make it.

we have : 
~/k8s-lab/k26/cert-manager/
 ├── cluster-issuer.yaml
 ├── test-cert.yaml
# Lets add
 ├── root-ca.yaml        ✅ NEW
 ├── ca-issuer.yaml      ✅ NEW (k8s-local-ca)

 ``nano ~/k8s-lab/k26/cert-manager/root-ca.yaml``

```yaml
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
    name: selfsigned
    kind: ClusterIssuer
```
apply :
`` kubectl apply -f ~/k8s-lab/k26/cert-manager/root-ca.yaml ``

now lets create CA issuer file 
`` nano ~/k8s-lab/k26/cert-manager/ca-issuer.yaml ``

```yaml
apiVersion: cert-manager.io/v1
kind: ClusterIssuer
metadata:
  name: k8s-local-ca
spec:
  ca:
    secretName: root-ca-secret
```
Apply (⚠️BUT WAIT FIRST⚠️)

⚠️ IMPORTANT: apply ONLY after root-ca is ready ⚠️

so that is why you run :
`` kubectl wait --for=condition=Ready certificate root-ca -n cert-manager --timeout=180s ``
and you want to get : 
`certificate.cert-manager.io/root-ca condition met`
when you get that apply CA issuer:
`` kubectl apply -f ~/k8s-lab/k26/cert-manager/ca-issuer.yaml ``

Verify now with commadn : 
`` kubectl get clusterissuer ``
and you want to get  :
|NAME         |  READY |
|-------------|--------|
|k8s-local-ca |  True  |
|selfsigned   |  True  |

Now lets fix Rancher CERT :
```bash
kubectl delete certificate rancher-cert -n cattle-system
kubectl apply -f ~/k8s-lab/k26/rancher/rancher-cert.yaml
```
Now we have structure :
cert-manager/
 ├── cluster-issuer.yaml   (bootstrap issuer)
 ├── root-ca.yaml          (your CA)
 ├── ca-issuer.yaml        (real issuer)
 ├── test-cert.yaml        (testing)


Upgrade Helm release to use new cert : 
```bash
helm upgrade rancher rancher-stable/rancher \
  -n cattle-system \
  --set hostname=rancher-hocko.k8s.local \
  --set ingress.tls.source=secret \
  --set privateCA=true
```

