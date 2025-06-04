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
  vpc_security_group_ids      = [aws_security_group.web_sg.id]

  metadata_options {
    http_tokens   = "required"
    http_endpoint = "enabled"
  }

  user_data = templatefile("${path.module}/user_data_script.tpl", {
    # Les clés ici doivent correspondre aux variables utilisées dans le fichier .tpl
    environment_name_tpl = var.environment_tag # var.environment_tag vient des variables du module
    project_name_tpl     = var.project_name    # var.project_name vient des variables du module
    instance_type        = var.instance_type
  })

  tags = {
    Name        = "WebServer-NGINX-${var.project_name}-${var.environment_tag}"
    Environment = var.environment_tag
    ManagedBy   = "Terraform"
    Project     = var.project_name
  }

}
