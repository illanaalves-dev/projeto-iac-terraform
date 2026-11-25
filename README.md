# Projeto Prático de IaC com Terraform (AWS)

Infraestrutura provisionada: VPC, sub-rede pública e privada, Internet Gateway,
tabelas de roteamento, Security Group (SSH) e uma instância EC2.

## Pré-requisitos
- Conta AWS e credenciais configuradas (`aws configure`)
- Terraform instalado

## Como executar
```bash
terraform init
terraform plan
terraform apply
```

## Testar a conexão SSH
```bash
# use o comando exibido no output "ssh_command"
ssh -i projeto-iac-key.pem ec2-user@<IP_PUBLICO>
```

## Remover a infraestrutura (evita custos)
```bash
terraform destroy
```
