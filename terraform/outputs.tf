output "connect_instructions" {
  value = <<EOT
Tailscale will register this node as: ${var.name}
Tailnet URLs will appear once 'tailscale up' completes on first boot.

If Tailscale SSH is enabled you can connect from another tailnet device:
  tailscale ssh ubuntu@${var.name}

AWS access:
  Public IP: ${aws_eip.this.public_ip}
  Public DNS: ${aws_instance.zanarkand.public_dns}
EOT
}
