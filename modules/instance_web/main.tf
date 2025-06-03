resource "aws_security_group" "web_sg" {
  name        = "web-sg-${var.project_name}-${lower(var.environment_tag)}"
  description = "Allow HTTP inbound traffic for ${var.project_name} WebServer"
  vpc_id      = var.vpc_id

  ingress {
    description      = "HTTP from anywhere"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description      = "Allow all outbound traffic"
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  tags = {
    Name        = "WebServer-SG-${var.project_name}"
    Project     = var.project_name
    ManagedBy   = "Terraform"
    Environment = var.environment_tag
  }
}


resource "aws_instance" "web_server" {
  ami                         = var.ami_id
  instance_type               = var.instance_type
  subnet_id                   = var.subnet_id
  associate_public_ip_address = true

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  vpc_security_group_ids = [aws_security_group.web_sg.id]

  user_data = <<-EOF
user_data = <<-EOF
#!/bin/bash
dnf update -y
dnf install nginx -y
systemctl start nginx
systemctl enable nginx

# on injecte les valeurs terraform dans des variables shell
ENVIRONMENT_TAG="${var.environment_tag}"
PROJECT_NAME="${var.project_name}"

TOKEN=$(curl -X PUT "http://169.254.169.254/latest/api/token" -H "X-aws-ec2-metadata-token-ttl-seconds: 21600")

INSTANCE_ID=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-id)
INSTANCE_TYPE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/instance-type)
AVAILABILITY_ZONE=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/placement/availability-zone)
PUBLIC_IPV4=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/public-ipv4)
PRIVATE_IPV4=$(curl -H "X-aws-ec2-metadata-token: $TOKEN" -s http://169.254.169.254/latest/meta-data/local-ipv4)

cat <<EOT > /usr/share/nginx/html/index.html
<!DOCTYPE html>
<html lang="fr">
  <head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Infos Instance EC2 (NGINX) - $ENVIRONMENT_TAG</title>
    <style>
      body { font-family: Arial, sans-serif; margin: 20px; background-color: #f0f8ff; color: #333; }
      h1 { color: #2072a9; }
      table { border-collapse: collapse; width: 60%; margin-top: 20px; box-shadow: 0 2px 5px rgba(0,0,0,0.15); }
      th, td { text-align: left; padding: 14px; border-bottom: 1px solid #cce5ff; }
      th { background-color: #2072a9; color: white; }
      tr:nth-child(even) { background-color: #e7f3fe; }
      tr:hover { background-color: #d1e7fd; }
    </style>
  </head>
  <body>
    <h1>Informations sur cette Instance EC2 (Servi par NGINX) - Environnement: $ENVIRONMENT_TAG</h1>
    <table>
      <tr><th>Attribut</th><th>Valeur</th></tr>
      <tr><td>ID de l'Instance</td><td>$INSTANCE_ID</td></tr>
      <tr><td>Type d'Instance</td><td>$INSTANCE_TYPE</td></tr>
      <tr><td>Zone de Disponibilité</td><td>$AVAILABILITY_ZONE</td></tr>
      <tr><td>IP Publique IPv4</td><td>$PUBLIC_IPV4</td></tr>
      <tr><td>IP Privée IPv4</td><td>$PRIVATE_IPV4</td></tr>
      <tr><td>Nom du Projet</td><td>$PROJECT_NAME</td></tr>
    </table>
  </body>
</html>
EOT
EOF

  tags = {
    Name        = "WebServer-NGINX-${var.project_name}"
    Environment = var.environment_tag
    ManagedBy   = "Terraform"
    Project     = var.project_name
  }
}
