# Terraform for Tailscale Exit Node on AWS

This module launches an Ubuntu EC2 instance, installs Tailscale on first boot, and advertises it as an exit node. It also disables AWS source/dest check and attaches an Elastic IP.

## Usage

```hcl
module "zanarkand" {
  source               = "./terraform"
  region               = "us-east-1"
  name                 = "zanarkand"
  vpc_id               = "<your-vpc-id>"
  subnet_id            = "<your-subnet-id>"
  tailscale_auth_key   = "<tskey-auth-...>"
  enable_web_ingress   = false
  advertise_exit_node  = true
  advertise_routes     = "" # or "10.0.0.0/16"
  # public_key         = file("~/.ssh/id_rsa.pub") # optional
}
```

Then:

```bash
terraform init
terraform apply
```

Get the public IP from outputs, then select the node as an exit node in your Tailscale client.

## Notes

- Provide a **Tailscale auth key** with server auth. Ephemeral keys work well.  
- The instance runs `tailscale up --ssh --hostname=<name> --advertise-exit-node`.  
- NAT masquerade is added for exit node traffic.  
- Security group only opens SSH by default. Set `enable_web_ingress = true` if you intend to use Funnel examples later.
