provider "aws" {
  region = "us-east-1"
}

# Gerar chave SSH automaticamente
resource "tls_private_key" "generated_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "terraform_key" {
  key_name   = "terraform-generated-key"
  public_key = tls_private_key.generated_key.public_key_openssh
}

# Salvar chave privada localmente
resource "local_file" "private_key" {
  filename        = "terraform-generated-key.pem"
  content         = tls_private_key.generated_key.private_key_pem
  file_permission = "0400"
}

# Security Group permitindo SSH (22) e HTTP (80)
resource "aws_security_group" "allow_ssh_http" {
  name        = "allow_ssh_http"
  description = "Allow SSH and HTTP access"

  ingress {
    description = "Allow SSH"
    protocol    = "tcp"
    from_port   = 22
    to_port     = 22
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTP"
    protocol    = "tcp"
    from_port   = 80
    to_port     = 80
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "allow-ssh-http"
  }
}

# Instância EC2 com configuração automática via user_data
resource "aws_instance" "k8s_instance" {
  ami                    = "ami-053b0d53c279acc90" # Ubuntu 22.04 LTS
  instance_type          = "t2.medium"
  key_name               = aws_key_pair.terraform_key.key_name
  vpc_security_group_ids = [aws_security_group.allow_ssh_http.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install -y docker.io curl
              systemctl enable docker
              usermod -aG docker ubuntu

              curl -Lo ./kind https://kind.sigs.k8s.io/dl/latest/kind-linux-amd64
              chmod +x kind
              sudo mv kind /usr/local/bin/

              curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
              chmod +x kubectl
              mv kubectl /usr/local/bin/

              curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash

              kind create cluster
              EOF

  tags = {
    Name = "k8s-helm-validation"
  }
}

# Saída: IP público
output "ec2_public_ip" {
  value = aws_instance.k8s_instance.public_ip
}

# Comando SSH para conexão
output "ssh_command" {
  value = "ssh -i terraform-generated-key.pem ubuntu@${aws_instance.k8s_instance.public_ip}"
}
