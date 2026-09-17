#!/bin/bash
set -e

REGION="us-east-1"
REGISTRY="034362066129.dkr.ecr.us-east-1.amazonaws.com"
IMAGE="$REGISTRY/vpc-web:latest"

aws ecr get-login-password --region "$REGION" | \
sudo docker login \
  --username AWS \
  --password-stdin "$REGISTRY"

# Si la descarga falla, el contenedor actual sigue funcionando.
sudo docker pull "$IMAGE"

# En el primer despliegue puede no existir un contenedor anterior.
sudo docker stop vpc-web-container || true
sudo docker rm vpc-web-container || true

# Recupera el servicio al reiniciar la EC2, salvo que se haya detenido manualmente.
sudo docker run -d \
  --restart unless-stopped \
  --name vpc-web-container \
  -p 80:80 \
  "$IMAGE"
