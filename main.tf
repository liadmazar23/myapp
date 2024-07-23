provider "aws" {
  region = "us-east-1" // AWS region
}

resource "aws_ecrpublic_repository" "myapp" {
  repository_name = "myapp" // Name for repo 
  catalog_data {
    description = "Public repository for myapp"
  }
}

output "repository_uri" {
  value = aws_ecrpublic_repository.myapp.repository_uri
}
