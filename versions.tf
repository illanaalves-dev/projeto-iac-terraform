# Versões do Terraform e dos providers utilizados no projeto
terraform {
  required_version = ">= 1.5.0"

  required_providers {
    # Provider da AWS: cria os recursos de infraestrutura
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    # Provider TLS: gera o par de chaves SSH
    tls = {
      source  = "hashicorp/tls"
      version = "~> 4.0"
    }
    # Provider Local: salva a chave privada (.pem) na sua máquina
    local = {
      source  = "hashicorp/local"
      version = "~> 2.0"
    }
  }
}

# Configuração do provider AWS (região definida em variables.tf)
provider "aws" {
  region = var.aws_region
}
