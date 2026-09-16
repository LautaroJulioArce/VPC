output "ec2_public_ip" {
  value = aws_instance.publica.public_ip
}

output "ec2_private_ip" {
  value = aws_instance.publica.private_ip
}

output "ec2_public_url" {
  value = "http://${aws_instance.publica.public_ip}:80"
}