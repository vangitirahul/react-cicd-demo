output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.react_server.id
}

output "public_ip" {
  description = "Public IP Address"
  value       = aws_instance.react_server.public_ip
}

output "private_ip" {
  description = "Private IP Address"
  value       = aws_instance.react_server.private_ip
}

output "instance_profile" {
  value = aws_iam_instance_profile.ec2_profile.name
}

output "security_group_id" {
  value = aws_security_group.react_app_sg.id
}
output "deployment_bucket" {
  value = aws_s3_bucket.deployment_bucket.bucket
}
