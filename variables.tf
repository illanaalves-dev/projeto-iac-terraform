# Região da AWS onde a infraestrutura será criada
variable "aws_region" {
  description = "Região da AWS"
  type        = string
  default     = "us-east-2"
}

# Nome do projeto, usado como prefixo nas tags dos recursos
variable "project_name" {
  description = "Nome do projeto (prefixo das tags)"
  type        = string
  default     = "projeto-iac"
}

# Faixa de IPs da VPC
variable "vpc_cidr" {
  description = "CIDR da VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Faixa de IPs da sub-rede pública (com acesso à internet)
variable "public_subnet_cidr" {
  description = "CIDR da sub-rede pública"
  type        = string
  default     = "10.0.1.0/24"
}

# Faixa de IPs da sub-rede privada (sem acesso direto à internet)
variable "private_subnet_cidr" {
  description = "CIDR da sub-rede privada"
  type        = string
  default     = "10.0.2.0/24"
}

# Tipo da instância EC2 (t3.micro/t2.micro são elegíveis ao Free Tier)
variable "instance_type" {
  description = "Tipo da instância EC2"
  type        = string
  default     = "t3.micro"
}

# De onde o acesso SSH é permitido.
# Para mais segurança, troque pelo seu IP, ex.: "200.10.20.30/32"
variable "allowed_ssh_cidr" {
  description = "CIDR autorizado a acessar a porta 22 (SSH)"
  type        = string
  default     = "0.0.0.0/0"
}
