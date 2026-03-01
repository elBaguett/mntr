#!/bin/bash
set -eux
swapoff -a || true
sed -i.bak '/ swap / s/^/#/' /etc/fstab

if command -v grubby >/dev/null 2>&1; then
  grubby --update-kernel=ALL --args="systemd.unified_cgroup_hierarchy=1" || true
fi

if [ -d /etc/default/grub.d ]; then
  if ! grep -q systemd.unified_cgroup_hierarchy /etc/default/grub; then
    echo 'GRUB_CMDLINE_LINUX="$GRUB_CMDLINE_LINUX systemd.unified_cgroup_hierarchy=1"' >> /etc/default/grub
    update-grub || grub2-mkconfig -o /boot/grub2/grub.cfg || true
  fi
fi

for user in root bin daemon adm lp sync shutdown halt mail operator games ftp nobody dbus systemd-network systemd-oom systemd-resolve rpc libstoragemgmt systemd-coredump systemd-timesync sshd chrony ec2-instance-connect stapunpriv rpcuser tcpdump ec2-user ; do
  if id $user &>/dev/null; then
    echo "$user ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/90-cloud-init-$user
    chmod 0440 /etc/sudoers.d/90-cloud-init-$user
  fi
done