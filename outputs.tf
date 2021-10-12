output "canary" {
  description = "Instance IPs and hostname"
  value = {
    "public_ip"  = aws_instance.canary.public_ip
    "private_ip" = aws_instance.canary.private_ip
    "public_dns" = aws_instance.canary.public_dns
  }
}

output "arch" {
  description = "Instance IPs and hostname"
  value = {
    "public_ip"  = aws_instance.arch.public_ip
    "private_ip" = aws_instance.arch.private_ip
    "public_dns" = aws_instance.arch.public_dns
  }
}

output "ubuntu" {
  description = "Instance IPs and hostname"
  value = {
    "public_ip"  = aws_instance.ubuntu.public_ip
    "private_ip" = aws_instance.ubuntu.private_ip
    "public_dns" = aws_instance.ubuntu.public_dns
  }
}
