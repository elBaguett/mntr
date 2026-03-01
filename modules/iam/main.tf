resource "aws_iam_user" "ci_deploy" {
  name = "ci-deploy-user"
}
resource "aws_iam_user" "admin" {
  name = "adminuser"
}

resource "aws_iam_policy" "least_privilege" {
  name        = "least-privilege"
  description = "Minimal EC2/S3"
  policy      = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ec2:*", "s3:*"]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "ci_deploy_attach" {
  user       = aws_iam_user.ci_deploy.name
  policy_arn = aws_iam_policy.least_privilege.arn
}
resource "aws_iam_user_policy_attachment" "admin_attach" {
  user       = aws_iam_user.admin.name
  policy_arn = aws_iam_policy.least_privilege.arn
}

resource "aws_iam_role" "load_balancer_controller" {
  name = "k8s-aws-load-balancer-controller"
  assume_role_policy = jsonencode({
    "Version": "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "load_balancer_controller" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "Policy for AWS Load Balancer controller"
  policy      = file("${path.module}/lbcontroller_policy.json") 
}

resource "aws_iam_role_policy_attachment" "attach_lb_policy" {
  role       = aws_iam_role.load_balancer_controller.name
  policy_arn = aws_iam_policy.load_balancer_controller.arn
}

resource "aws_iam_instance_profile" "load_balancer_controller_profile" {
  name = "k8s-aws-load-balancer-controller"
  role = aws_iam_role.load_balancer_controller.name
}