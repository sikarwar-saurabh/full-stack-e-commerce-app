
resource "aws_instance" "jenkins" {
  ami = var.ami_id
  instance_type = var.instance_type
  subnet_id = aws_subnet.public[0].id
  vpc_security_group_ids = [aws_security_group.jenkins.id]
  iam_instance_profile = aws_iam_instance_profile.jenkins.name
  associate_public_ip_address = true

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = "gp3"
    encrypted = true
    delete_on_termination = true
  }

  user_data = <<-EOF
              #!/bin/bash

              apt-get update -y

              apt-get install -y 
                ca-certificates 
                curl 
                gnupg 
                unzip 
                git 
                awscli

              # Docker
              install -m 0755 -d /etc/apt/keyrings

              curl -fsSL https://download.docker.com/linux/ubuntu/gpg 
                | gpg --dearmor -o /etc/apt/keyrings/docker.gpg

              chmod a+r /etc/apt/keyrings/docker.gpg

              echo 
                "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
                $(. /etc/os-release && echo "$VERSION_CODENAME") stable" 
                > /etc/apt/sources.list.d/docker.list

              apt-get update -y

              apt-get install -y 
                docker-ce 
                docker-ce-cli 
                containerd.io 
                docker-buildx-plugin 
                docker-compose-plugin

              systemctl enable docker
              systemctl start docker

              # Jenkins
              curl -fsSL https://pkg.jenkins.io/debian-stable/jenkins.io-2023.key 
                | tee /usr/share/keyrings/jenkins-keyring.asc > /dev/null

              echo deb [signed-by=/usr/share/keyrings/jenkins-keyring.asc] 
                https://pkg.jenkins.io/debian-stable binary/ 
                > /etc/apt/sources.list.d/jenkins.list

              apt-get update -y

              apt-get install -y fontconfig openjdk-21-jre jenkins

              usermod -aG docker jenkins

              systemctl enable jenkins
              systemctl restart jenkins
              EOF

  tags = {
    Name = "${var.project_name}-${var.environment}-jenkins"
  }
}

