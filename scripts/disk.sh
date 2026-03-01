1  sudo mkfs.ext4 /dev/nvme1n1
    2  sudo mkdir -p /var/lib/etcd
    3  sudo mount /dev/nvme1n1 /var/lib/etcd
    4  echo '/dev/nvme1n1 /var/lib/etcd ext4 defaults,nofail 0 2' | sudo tee -a /etc/fstab