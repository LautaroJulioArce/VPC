variable "ssh_allowed_cidr" {
  description = "CIDR autorizado para acceder por SSH a la EC2"
  type        = string
}

variable "ssh_public_key_path" {
  description = "Ruta local de la clave publica SSH"
  type        = string
}

