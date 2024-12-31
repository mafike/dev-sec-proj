variable "environment" {
  description = "Environment for deployment"
  type        = string
  default     = "dev"
}

variable "availability_zone" {
  type    = string
  default = "us-east-2a"
}

variable "instance_type" {
  type    = string
  default = "t2.medium"
}

variable "mac_ip" {
  description = "Your Mac's public IP in CIDR format"
  type        = string
  default     = "203.0.113.5/32" # Replace this with your actual IP if not using dynamic input
  # terraform apply -var "mac_ip=$(curl -s http://checkip.amazonaws.com)/32"
}

variable "jenkins_port" {
  type    = number
  default = 8080
}
variable "alb_port" {
  type    = number
  default = 80
}