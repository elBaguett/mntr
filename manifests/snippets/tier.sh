curl -L -o tier-crd.yaml https://raw.githubusercontent.com/projectcalico/calico/v3.27.3/manifests/crds/tier.crd.yaml
kubectl apply -f tier-crd.yaml