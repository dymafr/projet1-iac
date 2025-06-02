output "instance_id" {
  description = "L'ID de l'instance EC2 créée."
  value       = aws_instance.web_server.id
}

output "public_ip" {
  description = "L'adresse IP publique de l'instance EC2 créée."
  value       = aws_instance.web_server.public_ip
}

output "security_group_id" {
  description = "L'ID du groupe de sécurité créé."
  value       = aws_security_group.web_sg.id
}
