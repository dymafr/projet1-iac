
output "web_server_public_ip" {
  description = "Adresse IP publique de l'instance EC2 NGINX."
  value       = module.serveur_web_1.public_ip # Référence la sortie du module
}

output "web_server_instance_id" {
  description = "ID de l'instance EC2 NGINX."
  value       = module.serveur_web_1.instance_id # Référence la sortie du module
}

output "vpc_id_from_module" {
  description = "ID du VPC créé par le module distant."
  value       = module.vpc.vpc_id
}

output "public_subnet_ids_from_module" {
  description = "Liste des IDs des sous-réseaux publics créés par le module VPC."
  value       = module.vpc.public_subnets
}

output "private_subnet_ids_from_module" {
  description = "Liste des IDs des sous-réseaux privés créés par le module VPC."
  value       = module.vpc.private_subnets
}
