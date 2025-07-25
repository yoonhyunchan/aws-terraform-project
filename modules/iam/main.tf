resource "aws_iam_policy" "aws_controller_provider_policy_for_k8s_controller" {
  name        = "AWSCloudProviderControllerIAMPolicy"
  description = "IAM Policy for AWS Controller Provider used by Kubernetes controller nodes"
  policy      = file("${path.module}/policies/AWSCloudProviderControllerIAMPolicy.json")
}

resource "aws_iam_policy" "aws_controller_provider_policy_for_k8s_compute" {
  name        = "AWSCloudProviderNodeIAMPolicy"
  description = "IAM Policy for AWS Controller Provider used by Kubernetes compute nodes"
  policy      = file("${path.module}/policies/AWSCloudProviderNodeIAMPolicy.json")
}

resource "aws_iam_policy" "aws_loadbalancer_controller_policy" {
  name        = "AWSLoadBalancerControllerIAMPolicy"
  description = "IAM Policy for AWS Loadbalancer Controller"
  policy      = file("${path.module}/policies/AWSLoadBalancerControllerIAMPolicy.json")
}

resource "aws_iam_policy" "external_dns_policy" {
  name        = "AllowExternalDNSUpdates"
  description = "IAM Policy for External DNS"
  policy      = file("${path.module}/policies/AllowExternalDNSUpdates.json")
}

data "aws_iam_policy_document" "ec2_assume_role_policy_doc" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "k8s_controller_role" {
  name               = "iam_role_for_k8s_controller"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy_doc.json
}
resource "aws_iam_role" "k8s_compute_role" {
  name               = "iam_role_for_k8s_compute"
  assume_role_policy = data.aws_iam_policy_document.ec2_assume_role_policy_doc.json
}


resource "aws_iam_policy_attachment" "aws_ccm_k8s_controller_attachment" {
  name       = "aws_ccm_k8s_controller_attachment"
  roles      = [aws_iam_role.k8s_controller_role.name]
  policy_arn = aws_iam_policy.aws_controller_provider_policy_for_k8s_controller.arn
}

resource "aws_iam_policy_attachment" "aws_ccm_k8s_compute_attachment" {
  name       = "aws_ccm_k8s_compute_attachment"
  roles      = [aws_iam_role.k8s_compute_role.name]
  policy_arn = aws_iam_policy.aws_controller_provider_policy_for_k8s_compute.arn
}

resource "aws_iam_policy_attachment" "aws_loadbalancer_controller_attachment" {
  name       = "aws_loadbalancer_controller_attachment"
  roles      = [aws_iam_role.k8s_compute_role.name]
  policy_arn = aws_iam_policy.aws_loadbalancer_controller_policy.arn
}

resource "aws_iam_policy_attachment" "external_dns_attachment" {
  name       = "external_dns_attachment"
  roles      = [aws_iam_role.k8s_compute_role.name]
  policy_arn = aws_iam_policy.external_dns_policy.arn
}

resource "aws_iam_instance_profile" "instance_profile_for_k8s_controller" {
  name = "AWSEC2InstanceProfileForKubernetesController"
  role = aws_iam_role.k8s_compute_role.name
}

resource "aws_iam_instance_profile" "instance_profile_for_k8s_compute" {
  name = "AWSEC2InstanceProfileForKubernetesCompute"
  role = aws_iam_role.k8s_compute_role.name
}
