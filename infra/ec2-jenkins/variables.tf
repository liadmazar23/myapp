variable "aws_region" {
    description = "AWS region"
    type        = string
    default     = "us-east-1"
  }
  
  variable "instance_type" {
    description = "Instance type for Jenkins"
    type        = string
    default     = "t3.medium"
  }
  
  variable "key_name" {
    description = "Key name for SSH access"
    type        = string
    default     = "us-east-1-key"
  }