#!/bin/bash

apt-get update && apt-get install -y cloud-guest-utils gdisk && growpart /dev/nvme0n1 1 && resize2fs /dev/nvme0n1p1 && apt-get install -y e2fsprogs cloud-guest-utils

if ! blkid /dev/xvdf; then
  mkfs.ext4 /dev/xvdf
fi
mkdir -p /var/lib/etcd
mount /dev/xvdf /var/lib/etcd
echo '/dev/xvdf /var/lib/etcd ext4 defaults,nofail 0 2' >> /etc/fstab