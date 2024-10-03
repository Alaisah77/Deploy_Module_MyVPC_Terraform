
region          = "us-east-1"  # Specify the region where your resources will be deployed
vpc_cidr         = "10.0.0.0/16"
subnets_cidr     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
availability_zones = ["us-east-1a", "us-east-1b"]
ami_id           = "ami-0ebfd941bbafe70c6"  # Replace with the correct AMI ID for Ubuntu/Debian
key_name         = "my-terraform-key"   # Your key pair for SSH access