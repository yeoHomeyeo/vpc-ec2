variable "myregion_one" {
  description = "Region"
  type        = string
  default     = "us-east-1"
}

variable "env" {
  description = "The environment of the AWS infrastructure"
  type        = string
  default     = "dev"
}

variable "my_inst_type" {
  description = "The environment of the AWS infrastructure"
  type        = string
  default     = "t2.micro"
}
