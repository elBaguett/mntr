kubectl auth can-i list pods --as=system:serviceaccount:kube-system:kube-state-metrics
kubectl auth can-i list deployments --as=system:serviceaccount:kube-system:kube-state-metrics
kubectl auth can-i list nodes --as=system:serviceaccount:kube-system:kube-state-metrics