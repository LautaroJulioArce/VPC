# VPC AWS con Terraform, Docker y CI/CD

Laboratorio práctico de infraestructura en AWS desarrollado para aprender networking, infraestructura como código, contenedores y automatización de despliegues.

El proyecto comenzó con una EC2 administrada manualmente y fue evolucionando hasta un flujo automatizado donde GitHub Actions construye una imagen Docker, la publica en Amazon ECR y la EC2 descarga y ejecuta esa imagen mediante AWS Systems Manager.

## Arquitectura actual

La infraestructura está desplegada en `us-east-1` mediante Terraform.

Componentes principales:

- VPC `10.0.0.0/16`
- Subnet pública `10.0.1.0/24`
- Subnet privada `10.0.2.0/24`
- Internet Gateway
- Route Table pública
- Security Group
- EC2 Amazon Linux 2023
- Docker
- Nginx
- Amazon ECR
- AWS Systems Manager (SSM)
- IAM Roles
- GitHub Actions
- Autenticación OIDC entre GitHub y AWS

## Flujo de despliegue actual

```text
Desarrollador
    ↓
git add / commit / push
    ↓
GitHub
    ↓
GitHub Actions
    ↓
OIDC
    ↓
IAM Role temporal
    ↓
Docker build
    ↓
Amazon ECR
    ↓
imagen Docker versionada
    ↓
AWS Systems Manager
    ↓
EC2
    ↓
docker pull
    ↓
Docker container
    ↓
Nginx
    ↓
Aplicación web