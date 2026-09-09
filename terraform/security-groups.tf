resource "aws_security_group" "jenkins" {
  name = "${var.project_name}-${var.environment}-jenkins-sg"
  description = "Security group for Jenkins EC2"
  vpc_id = aws_vpc.main.id

  # SSH
  ingress {
    description = "SSH from admin IP"
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # Jenkins UI
  ingress {
    description = "for Jenkins UI"
    from_port = 8080
    to_port = 8080
    protocol = "tcp"
    cidr_blocks = [var.admin_cidr]
  }

  # Outbound traffic
  egress {
    description = "Allow all outbound traffic"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins-sg"
  }
}
