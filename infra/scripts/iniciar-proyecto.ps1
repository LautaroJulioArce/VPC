$INSTANCE_ID = "i-0a89bed63802175be"

Write-Host "Iniciando EC2..."

aws ec2 start-instances `
    --instance-ids $INSTANCE_ID `
    --output text | Out-Null

Write-Host "Esperando que la instancia quede running..."

aws ec2 wait instance-running `
    --instance-ids $INSTANCE_ID

$PUBLIC_IP = aws ec2 describe-instances `
    --instance-ids $INSTANCE_ID `
    --query "Reservations[0].Instances[0].PublicIpAddress" `
    --output text

Write-Host ""
Write-Host "EC2 iniciada correctamente."
Write-Host "IP publica: $PUBLIC_IP"
Write-Host "Web: http://$PUBLIC_IP"

#.\iniciar-proyecto.ps1 para iniciar la instancia EC2 y obtener la IP publica.