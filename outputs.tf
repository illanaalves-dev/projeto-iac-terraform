# IP público da instância
output "ec2_public_ip" {
  description = "IP público da instância EC2"
  value       = aws_instance.web.public_ip
}

# Comando pronto para testar a conexão SSH
output "ssh_command" {
  description = "Comando para conectar via SSH"
  value       = "ssh -i ${var.project_name}-key.pem ec2-user@${aws_instance.web.public_ip}"
}
