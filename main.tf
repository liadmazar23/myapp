# this is a tf main file to upload an image to priviate repo on ecr-us-west-2 #

provider "aws" {
  region = "us-west-2"
}

resource "aws_ecr_repository" "myapp" {
  name = "myapp"
}

resource "null_resource" "docker_build" {
  provisioner "local-exec" {
    command = <<EOT
      aws ecr get-login-password --region us-west-2 | docker login --username AWS --password-stdin ${aws_ecr_repository.myapp.repository_url}
      docker build -t myapp-tf:latest .
      docker tag myapp-tf:latest ${aws_ecr_repository.myapp.repository_url}:latest
      docker push ${aws_ecr_repository.myapp.repository_url}:latest
    EOT
  }

  depends_on = [aws_ecr_repository.myapp]
}
