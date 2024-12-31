resource "aws_security_group" "nexus_sonarqube_sg" {
  name   = "nexus-sonarqube-sg"
  vpc_id = data.terraform_remote_state.eks.outputs.vpc_id

  # Ingress for Nexus (8081) - Public access (optional)
  ingress {
    from_port   = 8081
    to_port     = 8081
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Ingress for SSH (22) - Restricted access
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Egress - Allow all outbound traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "nexus-sonarqube-sg"
  }
}
