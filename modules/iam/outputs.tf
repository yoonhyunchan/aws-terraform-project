output "instance_profile_name_for_k8s_controller" {
  description = "The name of the IAM instance profile for Kubernetes controller nodes."
  value       = aws_iam_instance_profile.instance_profile_for_k8s_controller.name
}

output "instance_profile_name_for_k8s_compute" {
  description = "The name of the IAM instance profile for Kubernetes compute nodes."
  value       = aws_iam_instance_profile.instance_profile_for_k8s_compute.name
}