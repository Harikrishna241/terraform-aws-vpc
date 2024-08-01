variable "enable_dns_hostnames" {

    type = bool
    default = true
  
}

variable "project_name" {
    type = string
  
}

variable "environment" {
    type = string
    default = "dev"
  
}

variable "common_tags" {
  
  type = map
      default = {
        Project = "expense"
        Environmeent = "Dev"
        Terraform = "true"
    }
}

variable "vpc_tags" {
    type = map
    default = {}
  
}

###internet gaway variables
variable "igw_tags" {
    type = map
    default = {}
}

####Subnet vribles
variable "public_cidr_blocks" {
    type = list
    validation {
    # regex(...) fails if it cannot find a match
    condition     = length(var.public_cidr_blocks) == 2
    error_message = "Please provide 2 cirblocks"
  }
}
variable "private_backend_cidr_blocks" {
    type = list
    validation {
    # regex(...) fails if it cannot find a match
    condition     = length(var.private_backend_cidr_blocks) == 2
    error_message = "Please provide 2 cirblocks"
  }
  
}

variable "private_db_cidr_blocks" {
    type = list
    validation {
    # regex(...) fails if it cannot find a match
    condition     = length(var.private_db_cidr_blocks) == 2
    error_message = "Please provide 2 cirblocks"
  }
  
}