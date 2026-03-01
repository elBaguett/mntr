for node in ip-10-10-10-11 ip-10-20-10-10 ip-10-10-20-14 ip-10-20-20-12 ip-10-10-20-11 ip-10-20-20-10; do
  ip=$(getent hosts $node | awk '{print $1}')
  iid=$(aws ec2 describe-instances --filter "Name=private-ip-address,Values=${ip}" --region eu-west-1 --query 'Reservations[].Instances[].InstanceId' --output text)
  az=$(aws ec2 describe-instances --instance-id $iid --region eu-west-1 --query 'Reservations[].Instances[].Placement.AvailabilityZone' --output text)
  echo "$node → $iid in $az"
  kubectl patch node "$node" -p '{"spec":{"providerID":"aws:///'"$az"'/'"$iid"'"}}'
done

for node in ip-10-20-10-10 10.20.20.10 10.20.20.12 ; do
  ip=$(getent hosts $node | awk '{print $1}')
  iid=$(aws ec2 describe-instances --filter "Name=private-ip-address,Values=${ip}" --region eu-west-1 --query 'Reservations[].Instances[].InstanceId' --output text)
  az=$(aws ec2 describe-instances --instance-id $iid --region eu-west-1 --query 'Reservations[].Instances[].Placement.AvailabilityZone' --output text)
  echo "$node → $iid in $az"
  kubectl patch node "$node" -p '{"spec":{"providerID":"aws:///'"$az"'/'"$iid"'"}}'
done