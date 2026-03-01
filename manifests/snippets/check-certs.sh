ETCDCTL_API=3 etcdctl \
  --endpoints=https://10.0.20.10:2379,https://10.0.20.11:2379 \
  --cacert=/etc/kubernetes/pki/etcd/ca.crt \
  --cert=/etc/kubernetes/pki/apiserver-etcd-client.crt \
  --key=/etc/kubernetes/pki/apiserver-etcd-client.key \
  endpoint health