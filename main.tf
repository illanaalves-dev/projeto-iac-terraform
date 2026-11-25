############################################
# AMI: busca a imagem mais recente do Amazon Linux 2023
############################################
data "aws_ami" "amazon_linux" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }
}

############################################
# Rede: VPC (rede virtual isolada na AWS)
############################################
resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = { Name = "${var.project_name}-vpc" }
}

############################################
# Sub-rede pública: recursos aqui podem ter IP público
############################################
resource "aws_subnet" "public" {
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = true

  tags = { Name = "${var.project_name}-subnet-publica" }
}

############################################
# Sub-rede privada: sem rota para a internet
############################################
resource "aws_subnet" "private" {
  vpc_id     = aws_vpc.main.id
  cidr_block = var.private_subnet_cidr

  tags = { Name = "${var.project_name}-subnet-privada" }
}

############################################
# Internet Gateway: porta de saída/entrada da VPC para a internet
############################################
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.project_name}-igw" }
}

############################################
# Tabela de roteamento pública: envia o tráfego externo (0.0.0.0/0) ao IGW
############################################
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = { Name = "${var.project_name}-rt-publica" }
}

# Associa a tabela pública à sub-rede pública
resource "aws_route_table_association" "public" {
  subnet_id      = aws_subnet.public.id
  route_table_id = aws_route_table.public.id
}

############################################
# Tabela de roteamento privada: apenas rota local da VPC (sem internet)
############################################
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  tags = { Name = "${var.project_name}-rt-privada" }
}

# Associa a tabela privada à sub-rede privada
resource "aws_route_table_association" "private" {
  subnet_id      = aws_subnet.private.id
  route_table_id = aws_route_table.private.id
}

############################################
# Security Group: firewall da instância EC2
############################################
resource "aws_security_group" "ssh" {
  name        = "${var.project_name}-sg-ssh"
  description = "Permite acesso SSH (porta 22) a instancia EC2"
  vpc_id      = aws_vpc.main.id

  # Entrada: SSH
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [var.allowed_ssh_cidr]
  }

  # Saída: libera todo o tráfego de saída
  egress {
    description = "Todo trafego de saida"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = { Name = "${var.project_name}-sg-ssh" }
}

############################################
# Par de chaves SSH: gerado pelo Terraform
############################################
resource "tls_private_key" "ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Registra a chave pública na AWS
resource "aws_key_pair" "ssh" {
  key_name   = "${var.project_name}-key"
  public_key = tls_private_key.ssh.public_key_openssh
}

# Salva a chave privada localmente (permissão 0400, exigida pelo SSH)
resource "local_sensitive_file" "private_key" {
  content         = tls_private_key.ssh.private_key_pem
  filename        = "${path.module}/${var.project_name}-key.pem"
  file_permission = "0400"
}

############################################
# Instância EC2 na sub-rede pública
############################################
resource "aws_instance" "web" {
  ami                         = data.aws_ami.amazon_linux.id
  instance_type               = var.instance_type
  subnet_id                   = aws_subnet.public.id
  vpc_security_group_ids      = [aws_security_group.ssh.id]
  key_name                    = aws_key_pair.ssh.key_name
  associate_public_ip_address = true

  tags = { Name = "${var.project_name}-ec2" }
}
