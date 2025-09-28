variable "region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "name" {
  description = "Base name for resources and Tailscale hostname"
  type        = string
  default     = "tailnet"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "vpc_id" {
  description = "VPC ID for the security group"
  type        = string
}

variable "subnet_id" {
  description = "Subnet ID for the instance"
  type        = string
}

variable "ssh_cidrs" {
  description = "CIDR blocks allowed to SSH"
  type        = list(string)
  default     = ["0.0.0.0/0"]
}

variable "enable_web_ingress" {
  description = "Open 80 and 443 on the security group for Funnel examples"
  type        = bool
  default     = false
}

variable "public_key" {
  description = "Optional SSH public key to install in AWS (leave empty to skip)"
  type        = string
  default     = ""
}

variable "tailscale_auth_key" {
  description = "Tailscale auth key with server auth (can be ephemeral)"
  type        = string
  sensitive   = true
}

variable "advertise_exit_node" {
  description = "Whether to advertise as an exit node"
  type        = bool
  default     = true
}

variable "advertise_routes" {
  description = "Optional CIDR(s) to advertise as subnet routes, e.g. 10.0.0.0/16"
  type        = string
  default     = ""
}
