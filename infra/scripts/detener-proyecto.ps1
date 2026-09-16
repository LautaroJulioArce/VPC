$INSTANCE_ID = "i-0a89bed63802175be"

Write-Host "Deteniendo EC2..."

aws ec2 stop-instances `
    --instance-ids $INSTANCE_ID `
    --output text | Out-Null

aws ec2 wait instance-stopped `
    --instance-ids $INSTANCE_ID

Write-Host "EC2 detenida correctamente."

# .\detener-proyecto.ps1 para detener la instancia EC2.