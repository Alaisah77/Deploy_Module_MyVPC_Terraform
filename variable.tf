# VPC
variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

# Subnets (list of subnet CIDRs)
variable "subnets_cidr" {
  description = "List of CIDR blocks for the subnets (2 public, 1 private)"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

# Availability Zones (list of availability zones)
variable "availability_zones" {
  description = "List of availability zones for the subnets"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b"]
}

# Region variable
variable "region" {
  description = "The AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

# AMI ID for EC2 Instances
variable "ami_id" {
  description = "AMI ID to use for EC2 instances"
  type        = string
  default     = "ami-0ebfd941bbafe70c6"  # Replace with a valid AMI ID (Ubuntu/Debian)
}

# Key Name for EC2 Instances
variable "key_name" {
  description = "Key pair name for SSH access"
  type        = string
  default     = "my-terraform-key"  # Replace with your own key name
}
