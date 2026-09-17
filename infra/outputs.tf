output "ec2_public_ip" {
  description = "IP pública de la EC2 para acceder desde Internet."
  value       = aws_instance.publica.public_ip
}

output "ec2_private_ip" {
  description = "IP privada de la EC2 dentro de la VPC."
  value       = aws_instance.publica.private_ip
}

output "ec2_public_url" {
  description = "URL HTTP para abrir la aplicación web."
  value       = "http://${aws_instance.publica.public_ip}:80"
}
