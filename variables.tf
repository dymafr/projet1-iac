variable "aws_region" {
  description = "La région AWS où les ressources seront déployées."
  type        = string
  default     = "eu-west-3"
}

variable "project_name" {
  description = "Nom du projet, utilisé pour le taggage des ressources."
  type        = string
  default     = "Projet1-IaC"
}

variable "vpc_cidr_block" {
  description = "Le bloc CIDR pour le VPC principal."
  type        = string
  default     = "10.0.0.0/16"
}
