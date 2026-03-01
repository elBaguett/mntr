# https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.7/deploy/installation/#setup-iam-roles-for-service-accounts

helm repo add eks https://aws.github.io/eks-charts
helm repo update
helm upgrade -i aws-load-balancer-controller eks/aws-load-balancer-controller \
  -n kube-system \
  --set clusterName=kubernetes \
  --set region=eu-west-1 \
  --set vpcId=vpc-01c02478fb096116b \
  --set image.tag="v2.7.1" \
  --set webhook.port=9443 \
  --set 'extraArgs={--webhook-port=9443}'