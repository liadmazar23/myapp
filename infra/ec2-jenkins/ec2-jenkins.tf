provider "aws" {
  region = var.aws_region
}

data "http" "external_ip" {
  url = "http://ifconfig.me/ip"
}

resource "aws_security_group" "jenkins_sg" {
  name        = "jenkins_sg"
  description = "Security group for Jenkins instance"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.external_ip.body)}/32"] 
  }

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["${chomp(data.http.external_ip.body)}/32"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "jenkins" {
  ami                         = "ami-0427090fd1714168b" # Amazon Linux 2 AMI
  instance_type               = var.instance_type
  key_name                    = var.key_name
  security_groups             = [aws_security_group.jenkins_sg.name]
  associate_public_ip_address = true

  user_data = <<-EOF
              #!/bin/bash

              # Update package index
              sudo yum update -y

              # Install Docker
              sudo yum install docker -y
              
              # Start Docker service
              sudo service docker start

              # Wait for Docker service to start
              sleep 30

              # Pull and run the Jenkins Docker container
              sudo docker run -d -p 8080:8080 -p 50000:50000 -e JENKINS_OPTS="--argumentsRealm.passwd.admin=admin --argumentsRealm.roles.user=admin" -e JAVA_OPTS="-Djenkins.install.runSetupWizard=false" jenkins/jenkins:lts

              # Check if Docker service is running
              sudo service docker status
              EOF

  tags = {
    Name = "JenkinsServer"
  }
}

output "instance_ip" {
  value = aws_instance.jenkins.public_ip
}