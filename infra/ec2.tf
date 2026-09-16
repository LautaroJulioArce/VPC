data "aws_ami" "amazon_linux_2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-2023.*-x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_key_pair" "vpc_lab" {
  key_name   = "vpc-lab-key"
  public_key = file(pathexpand(var.ssh_public_key_path))

  tags = {
    Name = "vpc-lab-key"
  }
}

resource "aws_instance" "publica" {
  ami           = "ami-007dd4cdc89d5d91d"
  instance_type = "t3.micro"

  subnet_id = aws_subnet.publica.id

  vpc_security_group_ids = [
    aws_security_group.ec2_publica.id
  ]

  key_name = aws_key_pair.vpc_lab.key_name

  associate_public_ip_address = true

  tags = {
    Name = "ec2-publica"
  }
  #este bloque de código adjunta el perfil de instancia IAM a la instancia EC2, lo que permite que la instancia utilice SSM para administración remota y otras funcionalidades proporcionadas por AWS Systems Manager.
  iam_instance_profile = aws_iam_instance_profile.ec2_ssm.name
}
