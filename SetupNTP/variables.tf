variable "vpc_id" {
  description = "The ID of the VPC where the instances will be launched"
  type        = string
  default     = "vpc-053ad2b881b4c78a5" # Your VPC ID
}

variable "subnet_id" {
  description = "The ID of the subnet where the instances will be launched"
  type        = list
  default     = ["subnet-04f96b891ee336e5a"] # Your Subnet ID
}

variable "ami_id" {
  description = "The AMI ID to use for the instances"
  type        = string
  default     = "ami-0522ab6e1ddcc7055" # Your AMI ID
}

variable "key_name" {
  description = "The key pair name to use for the instances"
  type        = string
  default     = "test" # Your key pair name
}

variable "security_group" {
  description = "The security group to associate with the instances"
  type        = string
  default     = "sg-0df7cfdcbd63f5c66" # Your security group name
}

