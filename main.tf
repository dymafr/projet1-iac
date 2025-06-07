data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-kernel-*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.5.0"

  name = "${var.project_name}-VPC-${terraform.workspace}" // Nom du VPC par environnement
  cidr = var.vpc_cidr_block

  azs             = ["${var.aws_region}a", "${var.aws_region}b", "${var.aws_region}c"]
  private_subnets = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]

  enable_nat_gateway = terraform.workspace == "prod" ? true : false // NAT Gateway uniquement en prod
  single_nat_gateway = true

  enable_dns_hostnames = true
  enable_dns_support   = true

  tags = merge(
    local.common_tags,
    { "ManagedBy" = "HCP-Terraform" } // Ajout de notre nouveau tag ici
  )
}

# Appel de notre module local 'instance_web'
module "serveur_web_1" {
  source = "./modules/instance_web" # Chemin vers notre module

  project_name    = var.project_name
  environment_tag = terraform.workspace
  instance_type   = local.current_instance_config.instance_type
  ami_id          = data.aws_ami.amazon_linux_2023.id
  vpc_id          = module.vpc.vpc_id
  subnet_id       = module.vpc.public_subnets[0]
}
